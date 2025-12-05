#!/bin/bash
#
# Windows Multi-User Container Management Script
# Provides easy commands to manage Windows containers
#

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Function to display help
show_help() {
    echo -e "${BLUE}Windows Multi-User Container Management${NC}"
    echo ""
    echo "Usage: ./manage.sh [command] [options]"
    echo ""
    echo "Commands:"
    echo "  start [user]      Start all containers or specific user container"
    echo "  stop [user]       Stop all containers or specific user container"
    echo "  restart [user]    Restart all containers or specific user container"
    echo "  status            Show status of all containers"
    echo "  logs [user]       Show logs for specific user container"
    echo "  connect [user]    Show RDP connection details for user"
    echo "  pull              Pull latest dockurr/windows image"
    echo "  clean             Stop and remove all containers (keeps data)"
    echo "  nuke              DANGER: Remove containers AND delete all data"
    echo ""
    echo "Examples:"
    echo "  ./manage.sh start             # Start all containers"
    echo "  ./manage.sh start user1       # Start only user1 container"
    echo "  ./manage.sh status            # Show status"
    echo "  ./manage.sh connect user2     # Show connection info for user2"
    echo "  ./manage.sh logs user3        # Show logs for user3"
}

# Function to check if .env exists
check_env() {
    if [ ! -f ".env" ]; then
        echo -e "${YELLOW}Warning: .env file not found${NC}"
        echo -e "${YELLOW}Creating .env from .env.example...${NC}"
        if [ -f ".env.example" ]; then
            cp .env.example .env
            echo -e "${GREEN}.env file created. Please edit it with your configuration!${NC}"
            echo -e "${YELLOW}Edit .env and run this command again.${NC}"
            exit 1
        else
            echo -e "${RED}Error: .env.example not found${NC}"
            exit 1
        fi
    fi
}

# Function to start containers
start_containers() {
    local user=$1
    check_env

    if [ -n "$user" ]; then
        echo -e "${GREEN}Starting container for $user...${NC}"
        docker compose up -d "windows-$user"
    else
        echo -e "${GREEN}Starting all Windows containers...${NC}"
        docker compose up -d
    fi

    echo ""
    echo -e "${BLUE}Installation Progress:${NC}"
    echo "Windows installation takes 20-40 minutes."
    echo "Monitor progress:"
    echo "  - Web UI: http://<container-ip>:8006"
    echo "  - Logs: ./manage.sh logs <user>"
}

# Function to stop containers
stop_containers() {
    local user=$1

    if [ -n "$user" ]; then
        echo -e "${YELLOW}Stopping container for $user...${NC}"
        docker compose stop "windows-$user"
    else
        echo -e "${YELLOW}Stopping all Windows containers...${NC}"
        docker compose stop
    fi
}

# Function to restart containers
restart_containers() {
    local user=$1

    if [ -n "$user" ]; then
        echo -e "${YELLOW}Restarting container for $user...${NC}"
        docker compose restart "windows-$user"
    else
        echo -e "${YELLOW}Restarting all Windows containers...${NC}"
        docker compose restart
    fi
}

# Function to show status
show_status() {
    echo -e "${BLUE}Windows Container Status:${NC}"
    echo ""
    docker compose ps
    echo ""

    # Load .env if exists
    if [ -f ".env" ]; then
        source .env

        echo -e "${BLUE}Connection Information:${NC}"
        echo ""
        echo -e "${GREEN}User 1:${NC}"
        echo "  IP Address: ${IP_USER1:-192.168.1.130}"
        echo "  RDP: ${IP_USER1:-192.168.1.130}:3389"
        echo "  Web UI: http://${IP_USER1:-192.168.1.130}:8006"
        echo ""
        echo -e "${GREEN}User 2:${NC}"
        echo "  IP Address: ${IP_USER2:-192.168.1.131}"
        echo "  RDP: ${IP_USER2:-192.168.1.131}:3389"
        echo "  Web UI: http://${IP_USER2:-192.168.1.131}:8006"
        echo ""
        echo -e "${GREEN}User 3:${NC}"
        echo "  IP Address: ${IP_USER3:-192.168.1.132}"
        echo "  RDP: ${IP_USER3:-192.168.1.132}:3389"
        echo "  Web UI: http://${IP_USER3:-192.168.1.132}:8006"
    fi
}

# Function to show logs
show_logs() {
    local user=$1

    if [ -z "$user" ]; then
        echo -e "${RED}Error: Please specify a user (user1, user2, or user3)${NC}"
        echo "Usage: ./manage.sh logs <user>"
        exit 1
    fi

    echo -e "${BLUE}Showing logs for $user (press Ctrl+C to exit):${NC}"
    docker compose logs -f "windows-$user"
}

# Function to show connection details
show_connection() {
    local user=$1

    if [ -z "$user" ]; then
        echo -e "${RED}Error: Please specify a user (user1, user2, or user3)${NC}"
        echo "Usage: ./manage.sh connect <user>"
        exit 1
    fi

    # Load .env
    if [ ! -f ".env" ]; then
        echo -e "${RED}Error: .env file not found${NC}"
        exit 1
    fi
    source .env

    # Get IP based on user
    case $user in
        user1)
            IP=${IP_USER1:-192.168.1.130}
            ;;
        user2)
            IP=${IP_USER2:-192.168.1.131}
            ;;
        user3)
            IP=${IP_USER3:-192.168.1.132}
            ;;
        *)
            echo -e "${RED}Error: Invalid user. Use user1, user2, or user3${NC}"
            exit 1
            ;;
    esac

    echo -e "${BLUE}Connection Details for $user:${NC}"
    echo ""
    echo -e "${GREEN}IP Address:${NC} $IP"
    echo ""
    echo -e "${GREEN}RDP Connection:${NC}"
    echo "  Address: $IP"
    echo "  Port: 3389"
    echo "  Default Username: Docker"
    echo "  Default Password: admin"
    echo "  ${YELLOW}IMPORTANT: Change password after first login!${NC}"
    echo ""
    echo -e "${GREEN}Web Interface:${NC}"
    echo "  URL: http://$IP:8006"
    echo "  Use for: Monitoring installation progress"
    echo ""
    echo -e "${BLUE}RDP Commands:${NC}"
    echo "  Linux: xfreerdp /u:Docker /p:admin /v:$IP:3389"
    echo "  Windows: mstsc /v:$IP:3389"
    echo "  macOS: Use Microsoft Remote Desktop app"
}

# Function to pull latest image
pull_image() {
    echo -e "${GREEN}Pulling latest dockurr/windows image...${NC}"
    docker compose pull
}

# Function to clean containers
clean_containers() {
    echo -e "${YELLOW}This will stop and remove all containers but keep data${NC}"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose down
        echo -e "${GREEN}Containers removed. Data preserved in ./storage${NC}"
    else
        echo -e "${BLUE}Cancelled${NC}"
    fi
}

# Function to nuke everything
nuke_all() {
    echo -e "${RED}WARNING: This will DELETE ALL CONTAINERS AND DATA!${NC}"
    echo -e "${RED}This action CANNOT be undone!${NC}"
    read -p "Type 'DELETE' to confirm: " confirm

    if [ "$confirm" = "DELETE" ]; then
        docker compose down -v
        rm -rf storage/
        echo -e "${RED}All containers and data deleted${NC}"
    else
        echo -e "${BLUE}Cancelled${NC}"
    fi
}

# Main command handling
case "${1:-help}" in
    start)
        start_containers "$2"
        ;;
    stop)
        stop_containers "$2"
        ;;
    restart)
        restart_containers "$2"
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs "$2"
        ;;
    connect)
        show_connection "$2"
        ;;
    pull)
        pull_image
        ;;
    clean)
        clean_containers
        ;;
    nuke)
        nuke_all
        ;;
    help|--help|-h|*)
        show_help
        ;;
esac
