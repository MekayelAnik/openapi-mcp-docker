#!/usr/bin/env bash
# Standard colors mapped to 8-bit equivalents
ORANGE='\033[38;5;208m'
BLUE='\033[38;5;12m'
ERROR_RED='\033[38;5;9m'
GREEN='\033[38;5;2m'
SWAGHGER_GREEN='\033[38;5;82m'
ASH_GRAY='\033[38;5;250m'
NC='\033[0m'

# Constants
BUILD_TIMESTAMP=$(cat /usr/local/bin/build-timestamp.txt 2>/dev/null || echo "")

# Function to print separator line
print_separator() {
    printf "\n"
    printf "\n______________________________________________________________________________________________________________________________________________"
    printf "\n"
}

# Print ASCII art
print_ascii_art() {
    printf "${GREEN}    /SSSSSS                                 /SSSSSS  /SSSSSSS  /SSSSSS       /SS      /SS  /SSSSSS  /SSSSSSS   ${NC}\n"
    printf "${GREEN}   /SS__  SS                               /SS__  SS| SS__  SS|_  SS_/      | SSS    /SSS /SS__  SS| SS__  SS  ${NC}\n"
    printf "${GREEN}  | SS  \ SS  /SSSSSS   /SSSSSS  /SSSSSSS | SS  \ SS| SS  \ SS  | SS        | SSSS  /SSSS| SS  \__/| SS  \ SS  ${NC}\n"
    printf "${GREEN}  | SS  | SS /SS__  SS /SS__  SS| SS__  SS| SSSSSSSS| SSSSSSS/  | SS        | SS SS/SS SS| SS      | SSSSSSS/  ${NC}\n"
    printf "${GREEN}  | SS  | SS| SS  \ SS| SSSSSSSS| SS  \ SS| SS__  SS| SS____/   | SS        | SS  SSS| SS| SS      | SS____/   ${NC}\n"
    printf "${GREEN}  | SS  | SS| SS  | SS| SS_____/| SS  | SS| SS  | SS| SS        | SS        | SS\  S | SS| SS    SS| SS        ${NC}\n"
    printf "${GREEN}  |  SSSSSS/| SSSSSSS/|  SSSSSSS| SS  | SS| SS  | SS| SS       /SSSSSS      | SS \/  | SS|  SSSSSS/| SS        ${NC}\n"
    printf "${GREEN}   \______/ | SS____/  \_______/|__/  |__/|__/  |__/|__/      |______/      |__/     |__/ \______/ |__/        ${NC}\n"
    printf "${GREEN}            | SS                                                                                               ${NC}\n"
    printf "${GREEN}            | SS                                                                                               ${NC}\n"
    printf "${GREEN}            |__/                                                                                               ${NC}\n"
    printf "\n"
    printf "\n"
    printf "${GREEN}                /SSSSSS  /SSSSSSSS /SSSSSSS  /SS    /SS /SSSSSSSS /SSSSSSS                                     ${NC}\n"
    printf "${GREEN}               /SS__  SS| SS_____/| SS__  SS| SS   | SS| SS_____/| SS__  SS                                    ${NC}\n"
    printf "${GREEN}              | SS  \__/| SS      | SS  \ SS| SS   | SS| SS      | SS  \ SS                                    ${NC}\n"
    printf "${GREEN}              |  SSSSSS | SSSSS   | SSSSSSS/|  SS / SS/| SSSSS   | SSSSSSS/                                    ${NC}\n"
    printf "${GREEN}               \____  SS| SS__/   | SS__  SS \  SS SS/ | SS__/   | SS__  SS                                    ${NC}\n"
    printf "${GREEN}               /SS  \ SS| SS      | SS  \ SS  \  SSS/  | SS      | SS  \ SS                                    ${NC}\n"
    printf "${GREEN}              |  SSSSSS/| SSSSSSSS| SS  | SS   \  S/   | SSSSSSSS| SS  | SS                                    ${NC}\n"
    printf "${GREEN}               \______/ |________/|__/  |__/    \_/    |________/|__/  |__/                                    ${NC}\n"
    printf "\n"                                                                    
}

# Print Maintainer information
print_maintainer_info() {
    printf "\n"
    printf "${ASH_GRAY} ███╗   ███╗██████╗        ███╗   ███╗███████╗██╗  ██╗ █████╗ ██╗   ██╗███████╗██╗          █████╗ ███╗   ██╗██╗██╗  ██╗                 ${NC}\n"
    printf "${ASH_GRAY} ████╗ ████║██╔══██╗       ████╗ ████║██╔════╝██║ ██╔╝██╔══██╗╚██╗ ██╔╝██╔════╝██║         ██╔══██╗████╗  ██║██║██║ ██╔╝                 ${NC}\n"
    printf "${ASH_GRAY} ██╔████╔██║██║  ██║       ██╔████╔██║█████╗  █████╔╝ ███████║ ╚████╔╝ █████╗  ██║         ███████║██╔██╗ ██║██║█████╔╝                  ${NC}\n"
    printf "${ASH_GRAY} ██║╚██╔╝██║██║  ██║       ██║╚██╔╝██║██╔══╝  ██╔═██╗ ██╔══██║  ╚██╔╝  ██╔══╝  ██║         ██╔══██║██║╚██╗██║██║██╔═██╗                  ${NC}\n"
    printf "${ASH_GRAY} ██║ ╚═╝ ██║██████╔╝██╗    ██║ ╚═╝ ██║███████╗██║  ██╗██║  ██║   ██║   ███████╗███████╗    ██║  ██║██║ ╚████║██║██║  ██╗                 ${NC}\n"
    printf "${ASH_GRAY} ╚═╝     ╚═╝╚═════╝ ╚═╝    ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝                 ${NC}\n"
}

# Print system information
print_system_info() {
    print_separator

    local disp_port="$PORT"
    local display_ip=$(ip route 2>/dev/null | awk '/default/ {print $3}' || echo "unknown")
    local port_display=":$disp_port"
    [[ "$disp_port" == '80' ]] && port_display=""

printf "${GREEN} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Starting OpenAPI MCP Server! <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< \n${NC}"
printf "${ORANGE} ==================================${NC}\n"
printf "${ORANGE} PUID: %s${NC}\n" "$PUID"
printf "${ORANGE} PGID: %s${NC}\n" "$PGID"
printf "${ORANGE} MCP IP Address: %s\n${NC}" "$display_ip"
printf "${ORANGE} MCP Server PORT: ${GREEN}%s\n${NC}\n" "${disp_port:-80}"
printf "${ORANGE} ==================================${NC}\n"
printf "${ERROR_RED} Note: You may need to change the IP address to your host machine IP\n${NC}"
[[ -n "$BUILD_TIMESTAMP" && -f "$BUILD_TIMESTAMP" ]] && BUILD_TIMESTAMP=$(cat "$BUILD_TIMESTAMP") && printf "${ORANGE}${BUILD_TIMESTAMP}${NC}\n"
    printf "${BLUE}This Container was started on:${NC} ${GREEN}$(date)${NC}\n"
}

# Main execution
main() {
    print_separator
    print_ascii_art
    print_maintainer_info
    print_system_info
}

main
