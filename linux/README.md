# Linux Scripts

Collection of Linux system administration and setup scripts.

## Available Scripts

### DNS - Dynamic DNS Updates
Location: [linux/dns/](dns/)

Automated IPv6 Dynamic DNS updates for Cloudflare. Updates your DNS records automatically when your IP address changes.

**Features:**
- IPv6 support
- Cloudflare API integration
- Automatic change detection

**Setup:**
```bash
cd dns
cp .env.example .env
# Edit .env with your Cloudflare API credentials
chmod +x ddns6.sh
./ddns6.sh
```

Add to crontab for automatic updates:
```bash
*/5 * * * * /path/to/ddns6.sh
```

### LAMP - LAMP Stack Installation
Location: [linux/lamp/](lamp/)

Automated installation script for a complete LAMP (Linux, Apache, MariaDB, PHP) stack with phpMyAdmin.

**What it installs:**
- Apache2 web server
- MariaDB database server
- PHP and required modules
- phpMyAdmin for database management

**Usage:**
```bash
cd lamp
chmod +x install-lamp.sh
sudo ./install-lamp.sh
```

The script will prompt for:
- Network interface name (e.g., eth0)
- MySQL root password

### Syncthing - File Synchronization
Location: [linux/syncthing/](syncthing/)

Automated installation and setup of Syncthing for continuous file synchronization.

**Features:**
- Installs latest Syncthing version
- Configures systemd service
- Enables web GUI access on port 8384

**Usage:**
```bash
cd syncthing
chmod +x install-syncthing.sh
sudo ./install-syncthing.sh
```

Access the web interface at: `http://your-server-ip:8384`

### Initial Setup (Example)
Location: [linux/initial-setup.sh.example](initial-setup.sh.example)

Template for initial server provisioning. Customize this script for your environment.

**What it does:**
- System updates
- User creation
- SSH key deployment
- Basic software installation

**Setup:**
```bash
cp initial-setup.sh.example initial-setup.sh
# Edit initial-setup.sh and customize the variables
chmod +x initial-setup.sh
sudo ./initial-setup.sh
```

## Requirements

- Ubuntu/Debian-based Linux distribution
- Root or sudo access
- Internet connection for package downloads

## Security Notes

- Always review scripts before execution
- Store sensitive data (API keys, passwords) in `.env` files
- Never commit `.env` files to version control
- Use strong passwords for database installations
