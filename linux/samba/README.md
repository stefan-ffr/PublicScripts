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

# Edit the configuration
nano mount-samba-shares.sh
```

## Configuration

Edit the script and customize these variables:

### Basic Settings

```bash
# Your Samba server hostname or IP
SAMBA_SERVER="your-nas-server.local"

# Your Samba username
SAMBA_USER="your-username"

# Workgroup (usually WORKGROUP for home networks)
SAMBA_WORKGROUP="WORKGROUP"

# Where to mount the shares
MOUNT_BASE="/media/samba"

# Optional: Path to password file (leave empty to be prompted)
SAMBA_PASSWORD_FILE=""
```

### Define Your Shares

```bash
SHARES=(
    "share_name:mount_folder:bookmark_name"
    "public:Public:Public Share"
    "documents:Documents:My Documents"
    "media:Media:Media Files"
)
```

Format: `"samba_share_name:local_folder_name:bookmark_display_name"`

**Examples:**
- `"photos:Photos:NAS Photos"` - Mounts `//server/photos` to `/media/samba/Photos` with bookmark "NAS Photos"
- `"backup:Backup:Backup Drive"` - Mounts `//server/backup` to `/media/samba/Backup` with bookmark "Backup Drive"

## Usage

### Run the Script

```bash
chmod +x mount-samba-shares.sh
sudo ./mount-samba-shares.sh
```

The script will:
1. Prompt for your Samba password
2. Install cifs-utils if needed
3. Create mount directories
4. Mount all configured shares
5. Add bookmarks to Nemo

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

## Using a Password File (Optional)

For automated mounting without user interaction, you can store the password in a file.

### Option 1: User Home Directory (Recommended)

The script automatically checks for `~/.samba-password` in your home directory:

```bash
# Create the password file in your home directory
nano ~/.samba-password

# Add only your password (one line, no username)
your-password-here

# Save and exit (Ctrl+X, Y, Enter)

# Secure the file (readable only by you)
chmod 600 ~/.samba-password
```

Now run the script - no password prompt!
```bash
sudo ./mount-samba-shares.sh
# Password automatically loaded from ~/.samba-password
```

### Option 2: Custom Location

You can also specify a custom password file location:

```bash
# Create password file at custom location
sudo nano /etc/samba-password
# Add your password

# Secure the file
sudo chmod 600 /etc/samba-password

# Configure the script
# Edit mount-samba-shares.sh and set:
SAMBA_PASSWORD_FILE="/etc/samba-password"
```

### Priority Order

The script checks for passwords in this order:
1. Custom `SAMBA_PASSWORD_FILE` (if configured in script)
2. `~/.samba-password` (in user's home directory)
3. Interactive prompt (if no file found)

### Security Notes

- The script checks file permissions and warns if they're insecure (should be 600)
- Only the first line of the file is used
- The script displays which file it's reading from
- Never commit password files to version control
- `~/.samba-password` is automatically ignored by git (in user home, not in repo)

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
