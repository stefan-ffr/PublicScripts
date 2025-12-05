# Samba Share Mounting for Linux Mint 22

Automatically mount Samba/CIFS network shares and add them as bookmarks in the Nemo file manager.

## Features

- Automatic installation of required packages (cifs-utils)
- Mounts multiple Samba shares with a single command
- Adds mounted shares as bookmarks in Nemo file manager
- Secure password input (hidden)
- Automatic duplicate detection for bookmarks
- Colored output for better readability
- Proper file ownership and permissions

## Requirements

- Linux Mint 22 (or other Ubuntu/Debian-based distributions with Nemo)
- Sudo/root privileges
- Access to a Samba server
- Valid Samba credentials

## Installation

```bash
# Download the example script
cd linux/samba

# Create your customized version
cp mount-samba-shares.sh.example mount-samba-shares.sh

# Make it executable
chmod +x mount-samba-shares.sh
```

## Configuration

The script uses a `.env` file for configuration, making it easy to reuse for different environments.

### Option 1: Using .env File (Recommended)

Create a configuration file in your home directory:

```bash
# Copy the example configuration
cp .env.example ~/.env

# Edit your configuration
nano ~/.env

# Secure the file (important for password protection!)
chmod 600 ~/.env
```

Edit `~/.env` and customize these variables:

```bash
# Your Samba server hostname or IP
SAMBA_SERVER="your-nas-server.local"

# Your Samba username
SAMBA_USER="your-username"

# Your Samba password
SAMBA_PASSWORD="your-password"

# Workgroup (usually WORKGROUP for home networks)
SAMBA_WORKGROUP="WORKGROUP"

# Where to mount the shares
MOUNT_BASE="/media/samba"

# Define your shares
SHARES=(
    "public:Public:Public Share"
    "documents:Documents:My Documents"
    "media:Media:Media Files"
)
```

### Option 2: Edit the Script Directly

If you prefer, you can edit the script directly. The script will use default values if no `.env` file is found.

### Share Format

Format: `"samba_share_name:local_folder_name:bookmark_display_name"`

**Examples:**
- `"photos:Photos:NAS Photos"` - Mounts `//server/photos` to `/media/samba/Photos` with bookmark "NAS Photos"
- `"backup:Backup:Backup Drive"` - Mounts `//server/backup` to `/media/samba/Backup` with bookmark "Backup Drive"

## Usage

### Run the Script

```bash
sudo ./mount-samba-shares.sh
```

The script will:
1. Load configuration from `~/.env` (if it exists)
2. Prompt for your Samba password (if not in .env file)
3. Install cifs-utils if needed
4. Create mount directories
5. Mount all configured shares
6. Add bookmarks to Nemo

### View Bookmarks

Open Nemo (Files) and check the sidebar. Your network shares should appear there. If not, press `F5` to refresh or restart Nemo:

```bash
nemo -q  # Quit Nemo
nemo &   # Restart Nemo
```

### Unmount Shares

To unmount all shares:

```bash
sudo umount /media/samba/*
```

To unmount a specific share:

```bash
sudo umount /media/samba/Documents
```

## How It Works

1. **Configuration Loading**: The script checks for `~/.env` in your home directory
2. **Password Handling**: If `SAMBA_PASSWORD` is not set in the .env file, you'll be prompted
3. **Mounting**: Each share is mounted to its specified location
4. **Bookmarks**: Successfully mounted shares are added to Nemo's sidebar

### Benefits of .env Configuration

- **Reusable**: Easy to use the same configuration across different machines
- **Secure**: Keep all sensitive data in one file with proper permissions (600)
- **Flexible**: Override any setting without editing the script
- **Portable**: Simply copy `~/.env` to another system

## Making Mounts Permanent (Optional)

To automatically mount shares at boot, add them to `/etc/fstab`:

1. Create a credentials file:

```bash
sudo nano /etc/samba-credentials
```

Add:
```
username=your-username
password=your-password
workgroup=WORKGROUP
```

2. Secure the credentials file:

```bash
sudo chmod 600 /etc/samba-credentials
```

3. Add to `/etc/fstab`:

```bash
sudo nano /etc/fstab
```

Add entries like:
```
//server/share  /media/samba/Share  cifs  credentials=/etc/samba-credentials,uid=1000,gid=1000,file_mode=0755,dir_mode=0755  0  0
```

Replace `uid=1000` and `gid=1000` with your actual user ID (find with `id -u` and `id -g`).

## Troubleshooting

### "Permission denied" when mounting

- Check your Samba credentials
- Verify the share name exists on the server
- Ensure you have access rights to the share

### "mount error(2): No such file or directory"

- Check if the Samba server is reachable: `ping your-nas-server.local`
- Verify the share name is correct
- Try accessing via: `smbclient -L //your-server -U your-username`

### Bookmarks don't appear in Nemo

- Restart Nemo: `nemo -q && nemo &`
- Check bookmark file: `cat ~/.config/gtk-3.0/bookmarks`
- Make sure the mount succeeded before bookmarks were added

### "cifs-utils not found"

The script automatically installs it, but you can manually install:
```bash
sudo apt update
sudo apt install cifs-utils
```

## Security Notes

- Never hardcode passwords in scripts for production use
- Use credentials files with restricted permissions
- Consider using Kerberos for enterprise environments
- Regularly update your Samba server and client packages

## Advanced Options

### Custom Mount Options

Edit the `mount` command in the script to add options:

```bash
mount -t cifs "$SHARE_PATH" "$MOUNT_POINT" \
    -o username="$SAMBA_USER",password="$SAMBA_PASSWORD",\
    vers=3.0,noserverino,nounix
```

Common options:
- `vers=3.0` - Force SMB version 3.0
- `noserverino` - Better compatibility with some NAS devices
- `nounix` - Disable Unix extensions
- `ro` - Mount read-only

### Find Available Shares

To see all shares on a server:

```bash
smbclient -L //your-server -U your-username
```

## Related Commands

```bash
# List all mounted CIFS shares
mount -t cifs

# Check if a path is a mount point
mountpoint /media/samba/Share

# View mount options for a share
mount | grep /media/samba

# Force unmount (use with caution)
sudo umount -f /media/samba/Share
```
