# PublicScripts

A collection of useful automation scripts for Linux and Windows system administration and setup.

## Repository Structure

```
PublicScripts/
├── linux/              # Linux-related scripts
│   ├── dns/           # Dynamic DNS scripts (Cloudflare)
│   ├── lamp/          # LAMP stack installation
│   ├── samba/         # Samba network share mounting
│   └── syncthing/     # Syncthing installation
├── windows/           # Windows-related scripts
│   ├── examples/      # Example scripts for customization
│   └── init.ps1       # Main initialization script
├── docker/            # Docker-based setups
│   └── windows-multi-user/  # Multi-user Windows 11 containers
├── adblocker/         # Ad blocker configurations
└── secrets/           # Private configurations (not in git)
```

## Getting Started

### Linux Scripts

Browse the [linux/](linux/) directory for server setup and configuration scripts:
- **DNS**: Automated Cloudflare DDNS updates with IPv6 support
- **LAMP**: Quick LAMP stack installation with MariaDB and phpMyAdmin
- **Samba**: User-space Samba share mounting with GVFS/GIO
- **Syncthing**: Automated Syncthing installation and service setup

### Windows Scripts

The [windows/](windows/) directory contains PowerShell scripts for automated Windows setup:
- **init.ps1.example**: Main initialization script that clones and executes user-specific scripts
- **examples/**: Template scripts for software installation and network drive mapping

### Docker Setups

The [docker/](docker/) directory contains Docker-based environments:
- **Windows Multi-User**: Run multiple Windows 11 Pro containers with macvlan networking for multi-user RDP access

### Adblocker

Configuration files for ad-blocking applications in [adblocker/](adblocker/).

## Secrets Management

Private and sensitive configurations should be stored in the `secrets/` folder, which is excluded from version control via `.gitignore`. Use the example files as templates:

- Copy `.example` files and customize for your environment
- Store sensitive data in `secrets/` folder
- Never commit credentials or private network information

## Usage Examples

### Linux: Install LAMP Stack
```bash
cd linux/lamp
chmod +x install-lamp.sh
sudo ./install-lamp.sh
```

### Linux: Setup Dynamic DNS
```bash
cd linux/dns
cp .env.example .env
# Edit .env with your Cloudflare credentials
chmod +x ddns6.sh
./ddns6.sh
```

### Linux: Mount Samba Shares
```bash
cd linux/samba
cp .env.example ~/.env
nano ~/.env  # Configure your Samba server and shares
chmod 600 ~/.env
./mount-samba-shares.sh
```

### Docker: Windows Multi-User Setup
```bash
cd docker/windows-multi-user
cp .env.example .env
nano .env  # Configure network settings and resources
./manage.sh start
```

### Windows: Run Initialization Script
```powershell
# Copy and customize init.ps1.example first
.\init.ps1
```

## Contributing

Feel free to submit issues or pull requests for improvements.

## License

These scripts are provided as-is for personal and educational use.

## Security Notes

- Review all scripts before execution
- Never commit sensitive data (API keys, passwords, private network info)
- Use the `secrets/` folder for private configurations
- Customize example files for your specific environment
