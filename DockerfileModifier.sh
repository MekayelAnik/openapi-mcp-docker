#!/bin/bash
set -euxo pipefail
# Set variables first
REPO_NAME='openapi-mcp-server'
BASE_IMAGE=$(cat ./build_data/base-image 2>/dev/null || echo "python:3.13-alpine")
HAPROXY_IMAGE=$(cat ./build_data/haproxy-image 2>/dev/null || echo "haproxy:lts-alpine")
OPENAPI_MCP_VERSION=$(cat ./build_data/version 2>/dev/null || exit 1)
OPENAPI_MCP_PKG="awslabs.openapi-mcp-server==${OPENAPI_MCP_VERSION}"
SUPERGATEWAY_PKG='supergateway@latest'
DOCKERFILE_NAME="Dockerfile.$REPO_NAME"

# Create a temporary file safely
TEMP_FILE=$(mktemp "${DOCKERFILE_NAME}.XXXXXX") || {
    echo "Error creating temporary file" >&2
    exit 1
}

# Check if this is a publication build
if [ -e ./build_data/publication ]; then
    # For publication builds, create a minimal Dockerfile that just tags the existing image
    {
        echo "ARG BASE_IMAGE=$BASE_IMAGE"
        echo "ARG OPENAPI_MCP_VERSION=$OPENAPI_MCP_VERSION"
        echo "FROM $BASE_IMAGE"
    } > "$TEMP_FILE"
else
    # Write the Dockerfile content to the temporary file first
    {
        echo "ARG BASE_IMAGE=$BASE_IMAGE"
        echo "ARG OPENAPI_MCP_VERSION=$OPENAPI_MCP_VERSION"
        cat << EOF
FROM $HAPROXY_IMAGE AS haproxy-src
FROM $BASE_IMAGE AS build

# Author info:
LABEL org.opencontainers.image.authors="MOHAMMAD MEKAYEL ANIK <mekayel.anik@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/mekayelanik/openapi-mcp-docker"

# Copy the entrypoint script into the container and make it executable
COPY ./resources/ /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/banner.sh \\
    && if [ -f /usr/local/bin/build-timestamp.txt ]; then chmod +r /usr/local/bin/build-timestamp.txt; fi \\
    && mkdir -p /etc/haproxy \\
    && mv -vf /usr/local/bin/haproxy.cfg.template /etc/haproxy/haproxy.cfg.template \\
    && ls -la /etc/haproxy/haproxy.cfg.template

# Install required APK packages (Python base + Node.js for supergateway)
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main" > /etc/apk/repositories && \\
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \\
    apk --update-cache --no-cache add bash shadow su-exec tzdata haproxy netcat-openbsd openssl nodejs npm && \\
    rm -rf /var/cache/apk/*

# HAProxy with native QUIC/H3 support from official image
COPY --from=haproxy-src /usr/local/sbin/haproxy /usr/sbin/haproxy
RUN mkdir -p /usr/local/sbin && ln -sf /usr/sbin/haproxy /usr/local/sbin/haproxy

# Install awslabs.openapi-mcp-server from PyPI (cache mount reuses pip downloads across builds).
# Strategy: trust pip first. If the out-of-box install imports cleanly, keep
# whatever fastmcp pip resolved (future-proof for new awslabs + fastmcp releases).
# Only when imports fail do we fall back to per-era detection:
#   - 'fastmcp.server.providers.openapi'    -> fastmcp>=3.2.2,<4 (>=1.0.0 era)
#   - 'from fastmcp.server.openapi import ... RouteType'
#                                           -> fastmcp>=2.13.0,<2.14.0 (<=0.2.8 era)
#   - else ('from fastmcp.server.openapi import ... MCPType')
#                                           -> fastmcp>=2.14.0,<3.0.0 (0.2.9-0.2.15 era)
RUN --mount=type=cache,target=/root/.cache/pip \\
    echo "Installing package: ${OPENAPI_MCP_PKG}" && \\
    pip install "${OPENAPI_MCP_PKG}" && \\
    if python3 -c "from awslabs.openapi_mcp_server.server import main" 2>/dev/null; then \\
        echo "Out-of-box install imports cleanly; trusting upstream fastmcp pin"; \\
    else \\
        echo "Import failed with pip-resolved fastmcp; applying compat pin by detected import path" && \\
        PKG_DIR=\$(python3 -c "import awslabs.openapi_mcp_server, os; print(os.path.dirname(awslabs.openapi_mcp_server.__file__))") && \\
        if grep -rq 'fastmcp.server.providers.openapi' "\$PKG_DIR"; then \\
            echo "Detected fastmcp 3.x import path; pinning fastmcp>=3.2.2,<4" && \\
            pip install 'fastmcp>=3.2.2,<4'; \\
        elif grep -rq 'from fastmcp.server.openapi import.*RouteType' "\$PKG_DIR"; then \\
            echo "Detected legacy RouteType API; pinning fastmcp>=2.13.0,<2.14.0" && \\
            pip install 'fastmcp>=2.13.0,<2.14.0'; \\
        else \\
            echo "Detected mid-era MCPType API; pinning fastmcp>=2.14.0,<3.0.0" && \\
            pip install 'fastmcp>=2.14.0,<3.0.0'; \\
        fi && \\
        python3 -c "from awslabs.openapi_mcp_server.server import main"; \\
    fi && \\
    echo "Package installed successfully"

# Install Supergateway (cache mount shares npm cache with previous step)
RUN --mount=type=cache,target=/root/.npm \\
    echo "Installing Supergateway..." && \\
    npm install -g ${SUPERGATEWAY_PKG} --omit=dev --no-audit --no-fund --loglevel error && \\
    rm -rf /tmp/* /var/tmp/* && \\
    rm -rf /usr/local/lib/node_modules/npm/man /usr/local/lib/node_modules/npm/docs /usr/local/lib/node_modules/npm/html

# Use an ARG for the default port
ARG PORT=8050

# Add ARG for API key
ARG API_KEY=""

# Set an ENV variable from the ARG for runtime
ENV PORT=\${PORT}
ENV API_KEY=\${API_KEY}

# L7 health check: auto-detects HTTP/HTTPS via ENABLE_HTTPS env var
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \\
    CMD sh -c 'wget -q --spider --no-check-certificate \$([ "\$ENABLE_HTTPS" = "true" ] && echo https || echo http)://127.0.0.1:\${PORT:-8050}/healthz'

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EOF
    } > "$TEMP_FILE"
fi

# Atomically replace the target file with the temporary file
if mv -f "$TEMP_FILE" "$DOCKERFILE_NAME"; then
    echo "Dockerfile for $REPO_NAME created successfully."
else
    echo "Error: Failed to create Dockerfile for $REPO_NAME" >&2
    rm -f "$TEMP_FILE"
    exit 1
fi
