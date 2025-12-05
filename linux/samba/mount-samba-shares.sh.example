#!/bin/bash
#
# Samba Share Mounting Script for Linux Mint 22
# Automatically mounts Samba/CIFS network shares and adds them as bookmarks in Nemo file manager
# Requires: cifs-utils package
#

##########################################################################################################################################
# CONFIGURATION - Load from .env file or use defaults
##########################################################################################################################################

# Get the actual user who invoked sudo (not root)
# Determine the user's home directory for .env file location
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

# Default .env file location in user's home directory
DEFAULT_ENV_FILE="$USER_HOME/.env"

# Check if .env file exists and load it
if [ -f "$DEFAULT_ENV_FILE" ]; then
    echo -e "${GREEN}Loading configuration from: $DEFAULT_ENV_FILE${NC}"
    # Source the .env file to load all variables
    source "$DEFAULT_ENV_FILE"
else
    echo -e "${YELLOW}No .env file found at $DEFAULT_ENV_FILE${NC}"
    echo -e "${YELLOW}Tip: Create $DEFAULT_ENV_FILE to save your configuration${NC}"
fi

# Samba server hostname or IP address
# Can be overridden in .env file
SAMBA_SERVER="${SAMBA_SERVER:-your-nas-server.local}"

# Samba username for authentication
# Can be overridden in .env file
SAMBA_USER="${SAMBA_USER:-your-username}"

# Samba workgroup/domain (usually WORKGROUP for home networks)
# Can be overridden in .env file
SAMBA_WORKGROUP="${SAMBA_WORKGROUP:-WORKGROUP}"

# Base directory where shares will be mounted
# Can be overridden in .env file
MOUNT_BASE="${MOUNT_BASE:-/media/samba}"

# Define your Samba shares as an array
# Format: "share_name:mount_folder_name:bookmark_display_name"
# Can be overridden in .env file as SHARES=("share1:folder1:name1" "share2:folder2:name2")
if [ -z "${SHARES+x}" ]; then
    # Default shares if not defined in .env
    SHARES=(
        "public:Public:Public Share"
        "documents:Documents:My Documents"
        "media:Media:Media Files"
        "backups:Backups:Backup Storage"
    )
fi

##########################################################################################################################################
# SCRIPT START - DO NOT MODIFY BELOW UNLESS YOU KNOW WHAT YOU'RE DOING
##########################################################################################################################################

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if the script is run with sudo/root privileges
# Required for creating mount points and mounting shares
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}ERROR: This script must be run as root or with sudo${NC}"
    echo "Usage: sudo $0"
    exit 1
fi

# Check if cifs-utils is installed
# This package provides the mount.cifs command needed to mount Samba shares
if ! command -v mount.cifs &> /dev/null; then
    echo -e "${YELLOW}cifs-utils is not installed. Installing...${NC}"
    apt update
    apt install -y cifs-utils
    if [ $? -ne 0 ]; then
        echo -e "${RED}ERROR: Failed to install cifs-utils${NC}"
        exit 1
    fi
    echo -e "${GREEN}cifs-utils installed successfully${NC}"
fi

# Get Samba password - check if already set in .env, otherwise prompt
if [ -z "$SAMBA_PASSWORD" ]; then
    # Password not in .env file, prompt user
    echo -e "${YELLOW}Tip: Add SAMBA_PASSWORD=\"your-password\" to $DEFAULT_ENV_FILE to skip this prompt${NC}"
    echo -e "${YELLOW}Enter password for Samba user '${SAMBA_USER}':${NC}"
    read -s SAMBA_PASSWORD
    echo

    # Verify password was entered
    if [ -z "$SAMBA_PASSWORD" ]; then
        echo -e "${RED}ERROR: No password provided${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Password loaded from .env file${NC}"
fi

# Create base mount directory if it doesn't exist
if [ ! -d "$MOUNT_BASE" ]; then
    echo -e "${YELLOW}Creating base mount directory: $MOUNT_BASE${NC}"
    mkdir -p "$MOUNT_BASE"
    if [ $? -ne 0 ]; then
        echo -e "${RED}ERROR: Failed to create directory $MOUNT_BASE${NC}"
        exit 1
    fi
fi

# Get the actual user who invoked sudo (not root)
# This is important for setting correct ownership and adding bookmarks to the right user
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_UID=$(id -u "$ACTUAL_USER")
ACTUAL_GID=$(id -g "$ACTUAL_USER")

echo -e "${GREEN}Mounting Samba shares for user: $ACTUAL_USER${NC}"
echo "---------------------------------------------------"

# Array to store successfully mounted shares for bookmark creation
MOUNTED_PATHS=()
BOOKMARK_NAMES=()

# Loop through each defined share
for SHARE_INFO in "${SHARES[@]}"; do
    # Split the share info by colon
    IFS=':' read -r SHARE_NAME MOUNT_FOLDER BOOKMARK_NAME <<< "$SHARE_INFO"

    # Full path where this share will be mounted
    MOUNT_POINT="$MOUNT_BASE/$MOUNT_FOLDER"

    # UNC path to the Samba share
    SHARE_PATH="//$SAMBA_SERVER/$SHARE_NAME"

    echo -e "${YELLOW}Processing share: $SHARE_NAME${NC}"

    # Create mount point directory if it doesn't exist
    if [ ! -d "$MOUNT_POINT" ]; then
        mkdir -p "$MOUNT_POINT"
        if [ $? -ne 0 ]; then
            echo -e "${RED}  ERROR: Failed to create mount point $MOUNT_POINT${NC}"
            continue
        fi
    fi

    # Check if the share is already mounted
    if mountpoint -q "$MOUNT_POINT"; then
        echo -e "${YELLOW}  Share already mounted at $MOUNT_POINT${NC}"
        MOUNTED_PATHS+=("$MOUNT_POINT")
        BOOKMARK_NAMES+=("$BOOKMARK_NAME")
        continue
    fi

    # Mount the Samba share
    # Options explained:
    # - username: Samba username for authentication
    # - password: Samba password (passed securely)
    # - workgroup: Windows workgroup/domain
    # - uid/gid: Set ownership to the actual user (not root)
    # - file_mode/dir_mode: Set permissions (0755 = rwxr-xr-x)
    # - iocharset: Character encoding (utf8 for international characters)
    mount -t cifs "$SHARE_PATH" "$MOUNT_POINT" \
        -o username="$SAMBA_USER",password="$SAMBA_PASSWORD",workgroup="$SAMBA_WORKGROUP",uid="$ACTUAL_UID",gid="$ACTUAL_GID",file_mode=0755,dir_mode=0755,iocharset=utf8

    # Check if mount was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  Successfully mounted: $SHARE_PATH -> $MOUNT_POINT${NC}"
        MOUNTED_PATHS+=("$MOUNT_POINT")
        BOOKMARK_NAMES+=("$BOOKMARK_NAME")
    else
        echo -e "${RED}  ERROR: Failed to mount $SHARE_PATH${NC}"
        # Remove empty mount point
        rmdir "$MOUNT_POINT" 2>/dev/null
    fi
done

echo "---------------------------------------------------"

# Add bookmarks to Nemo file manager
# Nemo uses GTK bookmarks stored in ~/.config/gtk-3.0/bookmarks
BOOKMARK_FILE="/home/$ACTUAL_USER/.config/gtk-3.0/bookmarks"
BOOKMARK_DIR=$(dirname "$BOOKMARK_FILE")

# Create the config directory if it doesn't exist
if [ ! -d "$BOOKMARK_DIR" ]; then
    echo -e "${YELLOW}Creating GTK config directory for user $ACTUAL_USER${NC}"
    sudo -u "$ACTUAL_USER" mkdir -p "$BOOKMARK_DIR"
fi

# Create or read existing bookmarks
if [ ! -f "$BOOKMARK_FILE" ]; then
    sudo -u "$ACTUAL_USER" touch "$BOOKMARK_FILE"
fi

# Read existing bookmarks to avoid duplicates
existing_bookmarks=$(cat "$BOOKMARK_FILE" 2>/dev/null || echo "")

# Add bookmarks for each successfully mounted share
echo -e "${GREEN}Adding bookmarks to Nemo file manager...${NC}"
for i in "${!MOUNTED_PATHS[@]}"; do
    MOUNT_POINT="${MOUNTED_PATHS[$i]}"
    BOOKMARK_NAME="${BOOKMARK_NAMES[$i]}"

    # Convert file path to URI format (file://)
    BOOKMARK_URI="file://$MOUNT_POINT $BOOKMARK_NAME"

    # Check if bookmark already exists
    if echo "$existing_bookmarks" | grep -q "file://$MOUNT_POINT"; then
        echo -e "${YELLOW}  Bookmark already exists: $BOOKMARK_NAME${NC}"
    else
        # Add bookmark
        echo "$BOOKMARK_URI" | sudo -u "$ACTUAL_USER" tee -a "$BOOKMARK_FILE" > /dev/null
        echo -e "${GREEN}  Added bookmark: $BOOKMARK_NAME${NC}"
    fi
done

# Set correct ownership and permissions for bookmark file
chown "$ACTUAL_USER":"$ACTUAL_USER" "$BOOKMARK_FILE"
chmod 644 "$BOOKMARK_FILE"

echo "---------------------------------------------------"
echo -e "${GREEN}Done! Samba shares have been mounted and bookmarks added.${NC}"
echo -e "${YELLOW}Note: You may need to restart Nemo or press F5 to see the bookmarks.${NC}"
echo ""
echo "To unmount all shares, run: sudo umount $MOUNT_BASE/*"
echo "To make mounts permanent, add entries to /etc/fstab"
