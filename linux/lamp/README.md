# LAMP Stack Installation

Automated installation script for a complete LAMP (Linux, Apache, MariaDB, PHP) stack with phpMyAdmin.

## What Gets Installed

- **Apache2**: Web server
- **MariaDB**: Database server (MySQL-compatible)
- **PHP**: Server-side scripting language with required modules
- **phpMyAdmin**: Web-based database management interface

## Usage

```bash
chmod +x install-lamp.sh
sudo ./install-lamp.sh
```

## Prompts

The script will ask for:
1. **Network interface name** (e.g., `eth0`, `ens33`)
   - Used to determine your server's IP address
2. **MySQL root password**
   - Set a strong password for database access

## After Installation

- Web server: `http://your-ip-address/`
- phpMyAdmin: `http://your-ip-address/phpmyadmin`
- Login with username `root` and your chosen password

## Requirements

- Ubuntu/Debian-based system
- Root or sudo privileges
- Active internet connection

## Security Recommendations

- Change default phpMyAdmin URL after installation
- Use strong passwords
- Configure firewall rules appropriately
- Consider disabling remote root access to MySQL
