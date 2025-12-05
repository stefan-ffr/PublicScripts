# Samba Share Mounting for Linux Mint 22

Automatically mount Samba/CIFS network shares in user space and make them appear in Nemo file manager.

## Features

- **User-space mounts** - No sudo required, mounts only visible to your user
- Automatic installation of required packages (gvfs-backends)
- Mounts multiple Samba shares with a single command
- Mounted shares automatically appear in Nemo's sidebar
- Secure password storage in .env file
- Automatic duplicate detection
- Colored output for better readability
- Uses GVFS/GIO for native desktop integration

## Requirements

- Linux Mint 22 (or other Ubuntu/Debian-based distributions with Nemo/GNOME)
- NO sudo required for mounting (only for initial package installation)
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

### Create Configuration File

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

# Define your shares (share_name:bookmark_name)
SHARES=(
    "public:Public Share"
    "documents:My Documents"
    "media:Media Files"
)
```

### Share Format

**New simplified format:** `"samba_share_name:bookmark_display_name"`

GVFS/GIO handles mount paths automatically in `/run/user/$UID/gvfs/`

**Examples:**
- `"photos:NAS Photos"` - Mounts `//server/photos` with bookmark "NAS Photos"
- `"backup:Backup Drive"` - Mounts `//server/backup` with bookmark "Backup Drive"

## Usage

### Run the Script

**No sudo required!** Simply run:

```bash
./mount-samba-shares.sh
```

The script will:
1. Load configuration from `~/.env` (if it exists)
2. Prompt for your Samba password (if not in .env file)
3. Install gvfs-backends if needed (requires sudo only for this step)
4. Mount all configured shares in user space
5. Shares automatically appear in Nemo's sidebar under "Network"

### View Mounted Shares

Open Nemo (Files) and check the sidebar under "Network". Your shares appear automatically!

Or use the command line:

```bash
gio mount -l  # List all mounted filesystems
```

### Unmount Shares

To unmount a specific share:

```bash
gio mount -u smb://username@server/share
```

To unmount all your Samba shares:

```bash
gio mount -l | grep "^Mount.*smb://" | while read -r line; do
    uri=$(echo "$line" | sed 's/.*(\([0-9]\+\)).*/\1/')
    gio mount -u "$uri"
done
```

## How It Works

1. **Configuration Loading**: The script checks for `~/.env` in your home directory
2. **Password Handling**: If `SAMBA_PASSWORD` is not set in the .env file, you'll be prompted
3. **User-Space Mounting**: Uses GVFS/GIO to mount shares in `/run/user/$UID/gvfs/`
4. **Automatic Integration**: Shares appear automatically in Nemo's sidebar under "Network"

### Benefits of User-Space Mounts

- **No sudo required**: Mounts are created by the user, not root
- **User-specific**: Each user has their own mounts
- **Desktop integration**: Automatically appear in file manager
- **Secure**: Credentials managed by GNOME Keyring
- **Easy unmounting**: Right-click in Nemo and select "Unmount"

### Benefits of .env Configuration

- **Reusable**: Easy to use the same configuration across different machines
- **Secure**: Keep all sensitive data in one file with proper permissions (600)
- **Flexible**: Override any setting without editing the script
- **Portable**: Simply copy `~/.env` to another system

## Making Mounts Permanent (Optional)

### Option 1: Run Script at Login (Recommended for User Mounts)

Add the script to your startup applications:

1. Open "Startup Applications" from the menu
2. Click "Add"
3. Name: "Mount Samba Shares"
4. Command: `/path/to/mount-samba-shares.sh`
5. Click "Add"

### Option 2: System-Wide Mounts with /etc/fstab

If you prefer traditional system-wide mounts (requires sudo to mount):

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
