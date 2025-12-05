# Syncthing Installation

Automated installation and configuration of Syncthing for continuous file synchronization.

## What is Syncthing?

Syncthing is an open-source, continuous file synchronization program that synchronizes files between devices without requiring a central server.

## What the Script Does

1. Updates system packages
2. Installs required dependencies
3. Adds Syncthing repository
4. Installs Syncthing
5. Creates and enables systemd service
6. Configures web GUI to listen on all interfaces (port 8384)

## Usage

```bash
chmod +x install-syncthing.sh
sudo ./install-syncthing.sh
```

## After Installation

Access the web interface at:
```
http://your-server-ip:8384
```

## First-Time Setup

1. Open the web interface
2. Configure folders to sync
3. Add remote devices
4. Set up sync relationships

## Service Management

```bash
# Check status
sudo systemctl status syncthing@root

# Start service
sudo systemctl start syncthing@root

# Stop service
sudo systemctl stop syncthing@root

# Restart service
sudo systemctl restart syncthing@root
```

## Security Notes

- The web GUI is accessible from all interfaces (0.0.0.0:8384)
- Consider setting up authentication in the web interface
- Use firewall rules to restrict access if needed
- For production use, configure HTTPS

## Requirements

- Ubuntu/Debian-based system
- Root or sudo privileges
- Internet connection
