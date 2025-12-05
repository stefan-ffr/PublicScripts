#!/bin/bash
#
# Samba Share Mounting Script for Linux Mint 22
# Mounts Samba/CIFS network shares in user space (no sudo required)
# Uses GVFS/GIO for user-specific mounts that automatically appear in Nemo
# Requires: gvfs-backends package
#

##########################################################################################################################################
# CONFIGURATION - Load from .env file or use defaults
##########################################################################################################################################

# Get user's home directory for .env file location
USER_HOME="$HOME"

# Default .env file location in user's home directory
DEFAULT_ENV_FILE="$USER_HOME/.env"

# Color codes for output (define early for use in config section)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Define your Samba shares as an array
# Format: "share_name:bookmark_display_name"
# Note: GVFS handles mount paths automatically in ~/.gvfs or /run/user/$UID/gvfs
# Can be overridden in .env file as SHARES=("share1:name1" "share2:name2")
if [ -z "${SHARES+x}" ]; then
    # Default shares if not defined in .env
    SHARES=(
        "public:Public Share"
        "documents:My Documents"
        "media:Media Files"
        "backups:Backup Storage"
    )
fi

##########################################################################################################################################
# SCRIPT START - DO NOT MODIFY BELOW UNLESS YOU KNOW WHAT YOU'RE DOING
##########################################################################################################################################

# Check if gvfs-backends is installed
# This package provides GVFS support for mounting Samba shares
if ! dpkg -l | grep -q gvfs-backends; then
    echo -e "${YELLOW}gvfs-backends is not installed. Installing...${NC}"
    sudo apt update
    sudo apt install -y gvfs-backends
    if [ $? -ne 0 ]; then
        echo -e "${RED}ERROR: Failed to install gvfs-backends${NC}"
        exit 1
    fi
    echo -e "${GREEN}gvfs-backends installed successfully${NC}"
fi

# Check if gio command is available
# gio is the command-line interface to GVFS
if ! command -v gio &> /dev/null; then
    echo -e "${RED}ERROR: gio command not found. Please install gvfs-bin package.${NC}"
    exit 1
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

echo -e "${GREEN}Mounting Samba shares for user: $USER${NC}"
echo "---------------------------------------------------"

# Array to store successfully mounted shares
MOUNTED_URIS=()
MOUNT_SUCCESS=0

# Loop through each defined share
for SHARE_INFO in "${SHARES[@]}"; do
    # Split the share info by colon
    # New format: "share_name:bookmark_display_name"
    IFS=':' read -r SHARE_NAME BOOKMARK_NAME <<< "$SHARE_INFO"

    # Construct SMB URI for gio mount
    # Format: smb://[workgroup;]username@server/share
    if [ -n "$SAMBA_WORKGROUP" ] && [ "$SAMBA_WORKGROUP" != "WORKGROUP" ]; then
        SMB_URI="smb://${SAMBA_WORKGROUP};${SAMBA_USER}@${SAMBA_SERVER}/${SHARE_NAME}"
    else
        SMB_URI="smb://${SAMBA_USER}@${SAMBA_SERVER}/${SHARE_NAME}"
    fi

    echo -e "${YELLOW}Processing share: $SHARE_NAME${NC}"
    echo -e "  URI: $SMB_URI"

    # Check if already mounted using gio mount -l
    if gio mount -l | grep -q "$SMB_URI"; then
        echo -e "${YELLOW}  Share already mounted${NC}"
        MOUNTED_URIS+=("$SMB_URI")
        MOUNT_SUCCESS=$((MOUNT_SUCCESS + 1))
        continue
    fi

    # Mount the share using gio mount
    # gio mount handles authentication interactively, but we can use expect or pass credentials via URI
    # For non-interactive mounting, we need to store credentials in GNOME Keyring or use a helper

    # Try mounting with password in URI (less secure but works without interaction)
    # URL-encode the password for special characters
    ENCODED_PASSWORD=$(printf %s "$SAMBA_PASSWORD" | jq -sRr @uri 2>/dev/null || echo "$SAMBA_PASSWORD")

    if [ -n "$SAMBA_WORKGROUP" ] && [ "$SAMBA_WORKGROUP" != "WORKGROUP" ]; then
        MOUNT_URI="smb://${SAMBA_WORKGROUP};${SAMBA_USER}:${ENCODED_PASSWORD}@${SAMBA_SERVER}/${SHARE_NAME}"
    else
        MOUNT_URI="smb://${SAMBA_USER}:${ENCODED_PASSWORD}@${SAMBA_SERVER}/${SHARE_NAME}"
    fi

    # Attempt to mount the share
    # gio mount will create the mount in /run/user/$UID/gvfs/ automatically
    gio mount "$MOUNT_URI" 2>&1 | while IFS= read -r line; do
        echo "    $line"
    done

    # Check if mount was successful by checking gio mount -l
    sleep 1  # Give GVFS a moment to register the mount
    if gio mount -l | grep -q "$(echo $SMB_URI | sed 's/:.*@/@/')"; then
        echo -e "${GREEN}  Successfully mounted: $SMB_URI${NC}"
        MOUNTED_URIS+=("$SMB_URI")
        MOUNT_SUCCESS=$((MOUNT_SUCCESS + 1))

        # GVFS automatically adds bookmarks to Nemo, but we can verify
        # The mount point is in /run/user/$UID/gvfs/
        GVFS_MOUNT=$(gio mount -l | grep "$SHARE_NAME" | grep "Mount(" | sed 's/.*-> //' || echo "")
        if [ -n "$GVFS_MOUNT" ]; then
            echo -e "  ${GREEN}Mount point: $GVFS_MOUNT${NC}"
        fi
    else
        echo -e "${RED}  ERROR: Failed to mount $SMB_URI${NC}"
        echo -e "${YELLOW}  Tip: Check server name, share name, username, and password${NC}"
    fi
done

echo "---------------------------------------------------"
echo -e "${GREEN}Done! $MOUNT_SUCCESS share(s) mounted successfully.${NC}"
echo -e "${YELLOW}Note: Mounted shares appear automatically in Nemo's sidebar under 'Network'${NC}"
echo ""
echo "Useful commands:"
echo "  gio mount -l           # List all mounted filesystems"
echo "  gio mount -u <URI>     # Unmount a specific share"
echo "  gio mount -u smb://${SAMBA_USER}@${SAMBA_SERVER}/<share>  # Example unmount"
