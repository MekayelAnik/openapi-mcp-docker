<p align="center"><img src="https://www.openapis.org/wp-content/uploads/sites/31/2018/02/OpenAPI_Logo_Pantone-1.png" alt="OpenAPI Logo" width="200"></p>

# OpenAPI MCP Server

<p align="center">
  <a href="https://hub.docker.com/r/mekayelanik/openapi-mcp-server"><img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/mekayelanik/openapi-mcp-server?style=flat-square&logo=docker"></a>
  <a href="https://hub.docker.com/r/mekayelanik/openapi-mcp-server"><img alt="Docker Stars" src="https://img.shields.io/docker/stars/mekayelanik/openapi-mcp-server?style=flat-square&logo=docker"></a>
  <a href="https://github.com/MekayelAnik/openapi-mcp-docker/pkgs/container/openapi-mcp-server"><img alt="GHCR" src="https://img.shields.io/badge/GHCR-ghcr.io%2Fmekayelanik%2Fopenapi--mcp--server-blue?style=flat-square&logo=github"></a>
  <a href="https://github.com/MekayelAnik/openapi-mcp-docker/blob/main/LICENSE"><img alt="License: GPL-3.0" src="https://img.shields.io/badge/License-GPL--3.0-blue?style=flat-square"></a>
  <a href="https://hub.docker.com/r/mekayelanik/openapi-mcp-server"><img alt="Platforms" src="https://img.shields.io/badge/Platforms-amd64%20%7C%20arm64-lightgrey?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/openapi-mcp-docker/stargazers"><img alt="GitHub Stars" src="https://img.shields.io/github/stars/MekayelAnik/openapi-mcp-docker?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/openapi-mcp-docker/forks"><img alt="GitHub Forks" src="https://img.shields.io/github/forks/MekayelAnik/openapi-mcp-docker?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/openapi-mcp-docker/issues"><img alt="GitHub Issues" src="https://img.shields.io/github/issues/MekayelAnik/openapi-mcp-docker?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/openapi-mcp-docker/commits/main"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/MekayelAnik/openapi-mcp-docker?style=flat-square"></a>
</p>

### Multi-Architecture Docker Image for OpenAPI Integration

---

## Table of Contents

- [Overview](#overview)
- [Supported Architectures](#supported-architectures)
- [Available Tags](#available-tags)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [MCP Client Configuration](#mcp-client-configuration)
- [Network Configuration](#network-configuration)
- [Updating](#updating)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)
- [Support & License](#support--license)

---

## 😎 Buy Me a Coffee ☕︎
**Your support encourages me to keep creating/supporting my open-source projects.** If you found value in this project, you can buy me a coffee to keep me inspired.

<p align="center">
<a href="https://07mekayel07.gumroad.com/coffee" target="_blank">
<img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="217" height="60">
</a>
</p>

## Overview

OpenAPI MCP Server is a Model Context Protocol server that bridges OpenAPI specifications with LLMs (Large Language Models). It loads OpenAPI specs from URLs or local files and exposes the API operations as MCP tools. Built on Alpine Linux for minimal footprint and maximum security, wrapped with Supergateway for HTTP/SSE/WebSocket transport.

### Key Features

- **OpenAPI Spec Loading** - Load specs from URL or local file path
- **Multiple Authentication Types** - Supports none, basic, bearer, api_key, and AWS Cognito
- **Multi-Architecture Support** - Native support for x86-64 and ARM64
- **Multiple Transport Protocols** - HTTP, SSE, and WebSocket support
- **Secure by Design** - Alpine-based with minimal attack surface, HAProxy with TLS/CORS support
- **High Performance** - ZSTD compression for faster deployments
- **Production Ready** - Stable releases with comprehensive testing
- **Easy Configuration** - Simple environment variable setup

---

## Supported Architectures

| Architecture | Tag Prefix | Status |
|:-------------|:-----------|:------:|
| **x86-64** | `amd64-<version>` | Stable |
| **ARM64** | `arm64v8-<version>` | Stable |

> Multi-arch images automatically select the correct architecture for your system.

---

## Available Tags

| Tag | Stability | Description | Use Case |
|:----|:---------:|:------------|:---------|
| `stable` | High | Most stable release | **Recommended for production** |
| `latest` | High | Latest stable release | Stay current with stable features |
| `0.2.15` | High | Specific version | Specific version | Version pinning for consistency |
| `beta` | Low | Beta releases | **Testing only** |

### System Requirements

- **Docker Engine:** 23.0+
- **RAM:** Minimum 512MB
- **CPU:** Single core sufficient

> **CRITICAL:** Do NOT expose this container directly to the internet without proper security measures (reverse proxy, SSL/TLS, authentication, firewall rules).

---

## Quick Start

### Docker Compose (Recommended)

```yaml
services:
  openapi-mcp-server:
    image: mekayelanik/openapi-mcp-server:stable
    container_name: openapi-mcp-server
    restart: unless-stopped
    ports:
      - "8050:8050"
    environment:
      - PORT=8050
      - INTERNAL_PORT=38011
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Dhaka
      - PROTOCOL=HTTP
      - ENABLE_HTTPS=false
      - HTTP_VERSION_MODE=auto
      # OpenAPI configuration
      - API_NAME=my-api
      - API_BASE_URL=https://api.example.com
      - API_SPEC_URL=https://api.example.com/openapi.json
      # - API_SPEC_PATH=/specs/openapi.json
      # Authentication (choose one)
      - AUTH_TYPE=none
      # - AUTH_TYPE=bearer
      # - AUTH_TOKEN=your-bearer-token
      # - AUTH_TYPE=api_key
      # - AUTH_API_KEY=your-api-key
      # - AUTH_API_KEY_NAME=X-API-Key
      # - AUTH_API_KEY_IN=header
      # Optional: require Bearer token auth at HAProxy layer
      # - API_KEY=replace-with-strong-secret
    hostname: openapi-mcp-server
    domainname: local
```

**Deploy:**
```bash
docker compose up -d
docker compose logs -f openapi-mcp-server
```

### Docker CLI

```bash
docker run -d \
  --name=openapi-mcp-server \
  --restart=unless-stopped \
  -p 8050:8050 \
  -e PORT=8050 \
  -e INTERNAL_PORT=38011 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Dhaka \
  -e PROTOCOL=HTTP \
  -e ENABLE_HTTPS=false \
  -e HTTP_VERSION_MODE=auto \
  -e API_NAME=my-api \
  -e API_BASE_URL=https://api.example.com \
  -e API_SPEC_URL=https://api.example.com/openapi.json \
  -e AUTH_TYPE=none \
  mekayelanik/openapi-mcp-server:stable
```

### Access Endpoints

| Protocol | Endpoint | Use Case |
|:---------|:---------|:---------|
| **HTTP** | `http://host-ip:8050/mcp` | Best compatibility (recommended) |
| **SSE** | `http://host-ip:8050/sse` | Real-time streaming |
| **WebSocket** | `ws://host-ip:8050/message` | Bidirectional communication |

When HTTPS is enabled (`ENABLE_HTTPS=true`), use TLS endpoints:

| Protocol | Endpoint |
|:---------|:---------|
| **SHTTP** | `https://host-ip:8050/mcp` |
| **SSE** | `https://host-ip:8050/sse` |
| **WebSocket** | `wss://host-ip:8050/message` |

> **Security Warning:** The container now defaults to HTTP (`ENABLE_HTTPS=false`) for easier local setup. Use `ENABLE_HTTPS=true` for production, public networks, or any untrusted environment.
>
> **ARM Devices:** Allow 30-60 seconds for initialization before accessing endpoints.

---

## Configuration

### Environment Variables

#### Container Configuration

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `PORT` | `8050` | External server port |
| `INTERNAL_PORT` | `38011` | Internal MCP server port used by supergateway |
| `PUID` | `1000` | User ID for file permissions |
| `PGID` | `1000` | Group ID for file permissions |
| `TZ` | `Asia/Dhaka` | Container timezone ([TZ database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)) |
| `PROTOCOL` | `SHTTP` | Default transport protocol |

#### API Configuration

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `API_NAME` | `awslabs-openapi-mcp-server` | API name identifier |
| `API_BASE_URL` | *(empty)* | Base URL for the API |
| `API_SPEC_URL` | *(empty)* | URL to OpenAPI specification |
| `API_SPEC_PATH` | *(empty)* | Local path to OpenAPI specification file |

#### Authentication Configuration

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `AUTH_TYPE` | `none` | Authentication type (`none`, `basic`, `bearer`, `api_key`, `cognito`) |
| `AUTH_USERNAME` | *(empty)* | Basic auth username |
| `AUTH_PASSWORD` | *(empty)* | Basic auth password |
| `AUTH_TOKEN` | *(empty)* | Bearer token |
| `AUTH_API_KEY` | *(empty)* | API key value |
| `AUTH_API_KEY_NAME` | `api_key` | API key parameter name |
| `AUTH_API_KEY_IN` | `header` | Where to send API key (`header`, `query`, `cookie`) |

#### AWS Cognito Authentication

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `AUTH_COGNITO_CLIENT_ID` | *(empty)* | Cognito client ID |
| `AUTH_COGNITO_USERNAME` | *(empty)* | Cognito username |
| `AUTH_COGNITO_PASSWORD` | *(empty)* | Cognito password |
| `AUTH_COGNITO_CLIENT_SECRET` | *(empty)* | Cognito client secret |
| `AUTH_COGNITO_DOMAIN` | *(empty)* | Cognito domain |
| `AUTH_COGNITO_SCOPES` | *(empty)* | Cognito scopes |
| `AUTH_COGNITO_USER_POOL_ID` | *(empty)* | Cognito user pool ID |
| `AUTH_COGNITO_REGION` | `us-east-1` | AWS region for Cognito |

#### Server Configuration

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `SERVER_HOST` | `127.0.0.1` | Server bind host |
| `SERVER_PORT` | `8000` | Internal server port |
| `SERVER_DEBUG` | `false` | Enable debug mode |
| `SERVER_MESSAGE_TIMEOUT` | `60` | Message timeout in seconds |

#### TLS / HTTPS Configuration

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `ENABLE_HTTPS` | `false` | Enables TLS termination in HAProxy |
| `TLS_CERT_PATH` | `/etc/haproxy/certs/server.crt` | TLS cert path |
| `TLS_KEY_PATH` | `/etc/haproxy/certs/server.key` | TLS private key path |
| `TLS_PEM_PATH` | `/etc/haproxy/certs/server.pem` | Combined PEM file used by HAProxy |
| `TLS_CN` | `localhost` | CN for auto-generated certificate |
| `TLS_SAN` | `DNS:<TLS_CN>` | SAN for auto-generated certificate |
| `TLS_DAYS` | `365` | Auto-generated cert validity period |
| `TLS_MIN_VERSION` | `TLSv1.3` | Minimum TLS protocol (`TLSv1.2` or `TLSv1.3`) |
| `HTTP_VERSION_MODE` | `auto` | `auto`, `all`, `h1`, `h2`, `h3`, `h1+h2` |

#### Security Configuration

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `API_KEY` | *(empty)* | Enables Bearer token auth at HAProxy layer (`Authorization: Bearer <API_KEY>`) |
| `CORS` | *(empty)* | Comma-separated CORS origins, supports `*` |

### HTTPS and HTTP Version Notes

- If `ENABLE_HTTPS=true` and cert files are missing, the container auto-generates a self-signed certificate.
- If `TLS_CERT_PATH` and `TLS_KEY_PATH` exist, they are merged into `TLS_PEM_PATH` and used directly.
- `HTTP_VERSION_MODE=h3` (or `auto`) enables HTTP/3 only when HAProxy build includes QUIC; otherwise it safely falls back.

### API Key Authentication Notes

- Set `API_KEY` to enforce authentication at reverse proxy level.
- Expected header format: `Authorization: Bearer <API_KEY>`.
- Localhost health checks remain accessible for liveness/readiness.

### User & Group IDs

Find your IDs and set them to avoid permission issues:

```bash
id username
# uid=1000(user) gid=1000(group)
```

### Timezone Examples

```yaml
- TZ=Asia/Dhaka        # Bangladesh
- TZ=America/New_York  # US Eastern
- TZ=Europe/London     # UK
- TZ=UTC               # Universal Time
```

---

## MCP Client Configuration

### Transport Support

| Client | HTTP | SSE | WebSocket | Recommended |
|:-------|:----:|:---:|:---------:|:------------|
| **VS Code (Cline/Roo-Cline)** | Yes | Yes | No | HTTP |
| **Claude Desktop** | Yes | Yes | Experimental | HTTP |
| **Claude CLI** | Yes | Yes | Experimental | HTTP |
| **Codex CLI** | Yes | Yes | Experimental | HTTP |
| **Codeium (Windsurf)** | Yes | Yes | Experimental | HTTP |
| **Cursor** | Yes | Yes | Experimental | HTTP |

---

### VS Code (Cline/Roo-Cline)

Configure in `.vscode/settings.json`:

```json
{
  "mcp.servers": {
    "openapi-mcp": {
      "url": "http://host-ip:8050/mcp",
      "transport": "http"
    }
  }
}
```

---

### Claude Desktop App/Claude Code

**With API_KEY:**
```
claude mcp add-json openapi-mcp '{"type":"http","url":"http://localhost:8050/mcp","headers":{"Authorization":"Bearer <YOUR_API_KEY>"}}'
```

**Without API_KEY:**
```
claude mcp add-json openapi-mcp '{"type":"http","url":"http://localhost:8050/mcp"}'
```

---

### Codex CLI

Configure in `~/.codex/config.json`:

```json
{
  "mcpServers": {
    "openapi-mcp": {
      "transport": "http",
      "url": "http://host-ip:8050/mcp"
    }
  }
}
```

---

### Codeium (Windsurf)

Configure in `.codeium/mcp_settings.json`:

```json
{
  "mcpServers": {
    "openapi-mcp": {
      "transport": "http",
      "url": "http://host-ip:8050/mcp"
    }
  }
}
```

---

### Cursor

Configure in `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "openapi-mcp": {
      "transport": "http",
      "url": "http://host-ip:8050/mcp"
    }
  }
}
```

---

### Testing Configuration

Verify with [MCP Inspector](https://github.com/modelcontextprotocol/inspector):

```bash
npm install -g @modelcontextprotocol/inspector
mcp-inspector http://host-ip:8050/mcp
```

---

## Network Configuration

### Comparison

| Network Mode | Complexity | Performance | Use Case |
|:-------------|:----------:|:-----------:|:---------|
| **Bridge** | Easy | Good | Default, isolated |
| **Host** | Moderate | Excellent | Direct host access |
| **MACVLAN** | Advanced | Excellent | Dedicated IP |

---

### Bridge Network (Default)

```yaml
services:
  openapi-mcp-server:
    image: mekayelanik/openapi-mcp-server:stable
    ports:
      - "8050:8050"
```

**Benefits:** Container isolation, easy setup, works everywhere
**Access:** `http://localhost:8050/mcp`

---

### Host Network (Linux Only)

```yaml
services:
  openapi-mcp-server:
    image: mekayelanik/openapi-mcp-server:stable
    network_mode: host
```

**Benefits:** Maximum performance, no NAT overhead, no port mapping needed
**Considerations:** Linux only, shares host network namespace
**Access:** `http://localhost:8050/mcp`

---

### MACVLAN Network (Advanced)

```yaml
services:
  openapi-mcp-server:
    image: mekayelanik/openapi-mcp-server:stable
    mac_address: "AB:BC:CD:DE:EF:01"
    networks:
      macvlan-net:
        ipv4_address: 192.168.1.100

networks:
  macvlan-net:
    driver: macvlan
    driver_opts:
      parent: eth0
    ipam:
      config:
        - subnet: 192.168.1.0/24
          gateway: 192.168.1.1
```

**Benefits:** Dedicated IP, direct LAN access
**Considerations:** Linux only, requires additional setup
**Access:** `http://192.168.1.100:8050/mcp`

---

## Updating

### Docker Compose

```bash
docker compose pull
docker compose up -d
docker image prune -f
```

### Docker CLI

```bash
docker pull mekayelanik/openapi-mcp-server:stable
docker stop openapi-mcp-server && docker rm openapi-mcp-server
# Run your original docker run command
docker image prune -f
```

### One-Time Update with Watchtower

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --run-once \
  openapi-mcp-server
```

---

## Troubleshooting

### Pre-Flight Checklist

- Docker Engine 23.0+
- Port 8050 available
- Sufficient startup time (ARM devices)
- Latest stable image
- Correct configuration

### Common Issues

#### Container Won't Start

```bash
# Check Docker version
docker --version

# Verify port availability
sudo netstat -tulpn | grep 8050

# Check logs
docker logs openapi-mcp-server
```

#### Permission Errors

```bash
# Get your IDs
id $USER

# Update configuration with correct PUID/PGID
# Fix volume permissions if needed
sudo chown -R 1000:1000 /path/to/volume
```

#### Client Cannot Connect

```bash
# Test connectivity
curl http://localhost:8050/mcp
curl http://host-ip:8050/mcp
curl -k https://localhost:8050/mcp
curl -k https://host-ip:8050/mcp

# Check firewall
sudo ufw status

# Verify container
docker inspect openapi-mcp-server | grep IPAddress
```

#### Slow ARM Performance

- Wait 30-60 seconds after start
- Monitor: `docker logs -f openapi-mcp-server`
- Check resources: `docker stats openapi-mcp-server`
- Use faster storage (SSD vs SD card)

### Debug Information

When reporting issues, include:

```bash
# System info
docker --version && uname -a

# Container logs
docker logs openapi-mcp-server --tail 200 > logs.txt

# Container config
docker inspect openapi-mcp-server > inspect.json
```

---

## Additional Resources

### Documentation
- [OpenAPI MCP Upstream](https://github.com/awslabs/mcp)
- [PyPI Package](https://pypi.org/project/awslabs.openapi-mcp-server/)
- [MCP Inspector](https://github.com/modelcontextprotocol/inspector)

### Docker Resources
- [Docker Compose Best Practices](https://docs.docker.com/compose/production/)
- [Docker Networking](https://docs.docker.com/network/)
- [Docker Security](https://docs.docker.com/engine/security/)

### Monitoring
- [Diun - Update Notifier](https://crazymax.dev/diun/)
- [Watchtower](https://containrrr.dev/watchtower/)

---

## 😎 Buy Me a Coffee ☕︎
**Your support encourages me to keep creating/supporting my open-source projects.** If you found value in this project, you can buy me a coffee to keep me inspired.

<p align="center">
  <a href="https://07mekayel07.gumroad.com/coffee" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="217" height="60">
  </a>
</p>

## Support & License

### Getting Help

**Docker Image Issues:**
- GitHub: [openapi-mcp-docker/issues](https://github.com/MekayelAnik/openapi-mcp-docker/issues)

**OpenAPI MCP Issues:**
- GitHub: [awslabs/mcp/issues](https://github.com/awslabs/mcp/issues)

### Contributing

We welcome contributions:
1. Report bugs via GitHub Issues
2. Suggest features
3. Improve documentation
4. Test beta releases

### License

GPL License. See [LICENSE](https://raw.githubusercontent.com/MekayelAnik/openapi-mcp-docker/refs/heads/main/LICENSE) for details.

OpenAPI MCP server has its own license - see [upstream repository](https://github.com/awslabs/mcp).

---

<div align="center">

[Back to Top](#openapi-mcp-server)

</div>
