# Windows 11 Pro Multi-User Container Setup

Run multiple Windows 11 Pro instances in Docker containers with individual IP addresses using macvlan networking. Perfect for providing isolated Windows environments to multiple users via RDP.

## Features

- **User-Specific Windows Instances** - Each user gets their own dedicated Windows 11 Pro container
- **Macvlan Networking** - Each container has its own IP address on your local network
- **RDP Access** - Native Remote Desktop Protocol support for all platforms
- **Resource Management** - Configurable RAM, CPU, and disk allocation per user
- **Easy Management** - Simple management script for all common operations
- **Persistent Storage** - Windows installations persist across container restarts

## System Requirements

### Host Requirements

- **Operating System:** Linux (Ubuntu, Debian, or similar)
- **Docker:** Latest version with compose plugin
- **CPU:** Minimum 6 cores (2 per user + host overhead)
  - Recommended: 8-12 cores
- **RAM:** Minimum 20GB (6GB per user × 3 + 2GB host overhead)
  - Recommended: 24-32GB
- **Storage:** Minimum 200GB
  - 64GB per Windows instance × 3 = 192GB
  - + Docker images and host OS
- **Virtualization:** KVM support required
  - Check with: `lsmod | grep kvm`
  - Should show `kvm_intel` or `kvm_amd`
- **Network:** Static IP addresses or DHCP reservation for containers

### Verify KVM Support

```bash
# Check if KVM modules are loaded
lsmod | grep kvm

# Verify /dev/kvm exists
ls -la /dev/kvm

# Check hardware virtualization is enabled
egrep -c '(vmx|svm)' /proc/cpuinfo
# Should return a number > 0
```

If KVM is not enabled, you must enable virtualization in your BIOS/UEFI settings.

## Installation

### 1. Clone or Download Setup Files

```bash
# Navigate to desired location
cd /opt  # or any location you prefer

# If using git
git clone https://github.com/your-repo/PublicScripts.git
cd PublicScripts/docker/windows-multi-user

# Or manually download the files
mkdir -p windows-multi-user
cd windows-multi-user
# Copy docker-compose.yml, .env.example, and manage.sh here
```

### 2. Install Docker (if not already installed)

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group (optional, for non-root usage)
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect

# Verify installation
docker --version
docker compose version
```

### 3. Configure Network

#### Find Your Network Interface

```bash
# List network interfaces
ip addr
# or
ifconfig

# Look for your main network interface (e.g., eth0, ens18, enp0s3)
```

#### Determine Network Settings

You need to know:
- **Network Subnet:** Usually `192.168.1.0/24` or `192.168.0.0/24`
- **Gateway:** Usually `192.168.1.1` (your router IP)
- **Available IP Range:** Choose unused IPs in your network

**Example Network Layout:**
- Router: 192.168.1.1
- DHCP Range: 192.168.1.2 - 192.168.1.99
- **Container Range: 192.168.1.128 - 192.168.1.159** (what we'll use)
- User1: 192.168.1.130
- User2: 192.168.1.131
- User3: 192.168.1.132

### 4. Create Configuration

```bash
# Copy example configuration
cp .env.example .env

# Edit configuration
nano .env
```

**Key Settings to Configure in .env:**

```bash
# Set your network interface (from step 3)
NETWORK_INTERFACE=eth0  # Change to your interface

# Set your network details (from step 3)
NETWORK_SUBNET=192.168.1.0/24
NETWORK_GATEWAY=192.168.1.1

# Container IP addresses (must be unused on your network)
IP_USER1=192.168.1.130
IP_USER2=192.168.1.131
IP_USER3=192.168.1.132
```

**Resource Settings (defaults are good for start):**

```bash
# 6GB RAM per user (can adjust based on your host)
RAM_SIZE_USER1=6G
RAM_SIZE_USER2=6G
RAM_SIZE_USER3=6G

# 2 CPU cores per user
CPU_CORES_USER1=2
CPU_CORES_USER2=2
CPU_CORES_USER3=2

# 64GB disk per user (expandable later)
DISK_SIZE=64G
```

### 5. Make Management Script Executable

```bash
chmod +x manage.sh
```

## Usage

### Start All Containers

```bash
./manage.sh start
```

This will:
1. Create storage volumes for each user
2. Start all three Windows containers
3. Begin Windows 11 installation (takes 20-40 minutes)

### Monitor Installation Progress

**Option 1: Web Interface**
```bash
# Open in browser:
http://192.168.1.130:8006  # User 1
http://192.168.1.131:8006  # User 2
http://192.168.1.132:8006  # User 3
```

**Option 2: View Logs**
```bash
./manage.sh logs user1
./manage.sh logs user2
./manage.sh logs user3
```

### Check Status

```bash
./manage.sh status
```

Shows:
- Container status (running/stopped)
- IP addresses
- RDP connection details
- Web UI URLs

### Connect via RDP

After Windows installation completes (20-40 minutes):

**Default Credentials:**
- Username: `Docker`
- Password: `admin`
- **⚠️ IMPORTANT:** Change this password immediately after first login!

**Connection Methods:**

**Linux (Remmina or FreeRDP):**
```bash
# FreeRDP command line
xfreerdp /u:Docker /p:admin /v:192.168.1.130:3389

# Or use Remmina GUI:
# - Protocol: RDP
# - Server: 192.168.1.130:3389
# - Username: Docker
# - Password: admin
```

**Windows (Built-in RDP):**
```cmd
# Command line
mstsc /v:192.168.1.130:3389

# Or use GUI:
# 1. Press Win+R
# 2. Type: mstsc
# 3. Enter: 192.168.1.130
```

**macOS (Microsoft Remote Desktop):**
1. Install "Microsoft Remote Desktop" from App Store
2. Add PC: 192.168.1.130
3. Enter credentials

### Get Connection Details

```bash
./manage.sh connect user1
./manage.sh connect user2
./manage.sh connect user3
```

## Management Commands

### Start/Stop/Restart

```bash
# Start all containers
./manage.sh start

# Start specific user
./manage.sh start user1

# Stop all containers
./manage.sh stop

# Stop specific user
./manage.sh stop user2

# Restart all containers
./manage.sh restart

# Restart specific user
./manage.sh restart user3
```

### View Logs

```bash
# Follow logs in real-time (Ctrl+C to exit)
./manage.sh logs user1
```

### Update Windows Image

```bash
# Pull latest dockurr/windows image
./manage.sh pull
```

### Remove Containers (Keep Data)

```bash
# Stops and removes containers but preserves Windows installations
./manage.sh clean
```

### Delete Everything

```bash
# WARNING: Deletes containers AND all Windows data
./manage.sh nuke
```

## Post-Installation Setup

### 1. Change Default Password

**Immediately after first RDP login:**

```cmd
# Open Command Prompt as Administrator
net user Docker NewSecurePassword123!

# Or use Windows Settings:
# Settings > Accounts > Sign-in options > Password > Change
```

### 2. Create User Accounts

**Option 1: Command Line**
```cmd
# Create new user
net user username password /add

# Add to Administrators group
net localgroup Administrators username /add
```

**Option 2: PowerShell**
```powershell
# Create user
New-LocalUser -Name "username" -Password (ConvertTo-SecureString "password" -AsPlainText -Force)

# Add to Administrators
Add-LocalGroupMember -Group "Administrators" -Member "username"
```

**Option 3: GUI**
1. Press `Win+R`
2. Type `lusrmgr.msc`
3. Manage users graphically

### 3. Windows Updates

```cmd
# Open Windows Update
# Settings > Windows Update > Check for updates
```

Run Windows Update to get latest security patches.

### 4. Install Software

Use Windows Update, download installers, or PowerShell:

```powershell
# Example: Install Chocolatey package manager
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Then install software
choco install googlechrome -y
choco install 7zip -y
```

## Networking Details

### Macvlan Mode

This setup uses **macvlan networking**, which gives each container its own IP address on your local network.

**Advantages:**
- Each container appears as a separate device on your network
- No port conflicts
- Clean, simple connection (just use container IP)
- Proper network isolation

**Important Note:**
The host machine **cannot** directly communicate with containers in macvlan mode without additional configuration. Users on other devices can connect normally.

### Firewall Configuration

If you have a firewall on your network:
- **Allow RDP (port 3389)** from trusted devices to container IPs
- **Allow HTTP (port 8006)** for web interface (optional, can be disabled)

## Resource Management

### Adjust Resources Per User

Edit `.env` file:

```bash
# Give User 1 more resources
RAM_SIZE_USER1=8G
CPU_CORES_USER1=4

# Reduce User 3 resources
RAM_SIZE_USER2=4G
CPU_CORES_USER2=1
```

Then restart:
```bash
./manage.sh restart user1
./manage.sh restart user3
```

### Increase Disk Size

You can increase disk size without losing data:

```bash
# Edit .env
DISK_SIZE=128G  # Increase from 64G to 128G

# Restart containers
./manage.sh restart

# Inside Windows, extend partition:
# 1. Open Disk Management (diskmgmt.msc)
# 2. Right-click C: drive
# 3. Extend Volume
```

## Troubleshooting

### Container Won't Start

**Check KVM:**
```bash
ls -la /dev/kvm
lsmod | grep kvm
```

**Check Logs:**
```bash
./manage.sh logs user1
```

**Common Issues:**
- KVM not available: Enable virtualization in BIOS
- Permission denied on /dev/kvm: Add user to kvm group
- IP conflict: Change IP addresses in .env

### Cannot Connect via RDP

**Verify Container is Running:**
```bash
./manage.sh status
```

**Check Windows Installation Progress:**
- Open web interface: `http://<container-ip>:8006`
- Installation takes 20-40 minutes

**Network Issues:**
- Ping container IP: `ping 192.168.1.130`
- Check firewall rules
- Verify macvlan configuration

### Slow Performance

**Without KVM, performance is very poor.** Verify KVM is working:

```bash
# Inside container logs, you should see:
./manage.sh logs user1 | grep -i kvm
# Should show KVM acceleration enabled
```

**Increase Resources:**
- Add more RAM in .env
- Add more CPU cores in .env
- Reduce number of simultaneous users

### Windows Installation Stuck

**Reset Installation:**
```bash
# Stop container
./manage.sh stop user1

# Remove Windows installation
rm -rf storage/user1/*

# Start again (fresh install)
./manage.sh start user1
```

## Advanced Configuration

### Add More Users

1. Edit `docker-compose.yml`:

```yaml
  windows-user4:
    image: dockurr/windows
    container_name: windows-user4
    hostname: win11-user4
    environment:
      VERSION: "win11"
      DISK_SIZE: "${DISK_SIZE:-64G}"
      RAM_SIZE: "${RAM_SIZE_USER4:-6G}"
      CPU_CORES: "${CPU_CORES_USER4:-2}"
    devices:
      - /dev/kvm
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    networks:
      windows_network:
        ipv4_address: ${IP_USER4:-192.168.1.133}
    volumes:
      - ${STORAGE_PATH:-./storage}/user4:/storage
    stop_grace_period: 2m
    restart: unless-stopped
    labels:
      - "user=user4"
```

2. Add to `.env`:
```bash
IP_USER4=192.168.1.133
RAM_SIZE_USER4=6G
CPU_CORES_USER4=2
```

3. Start:
```bash
./manage.sh start user4
```

### Auto-Start on Boot

```bash
# Enable containers to start on system boot
docker compose up -d

# Or use systemd service (advanced)
```

### Backup Windows Installation

```bash
# Stop container
./manage.sh stop user1

# Backup storage
tar -czf user1-backup.tar.gz storage/user1/

# Restore if needed
tar -xzf user1-backup.tar.gz -C storage/
```

## Security Best Practices

1. **Change Default Password** immediately after installation
2. **Use Strong Passwords** for all Windows accounts
3. **Enable Windows Firewall** inside containers
4. **Keep Windows Updated** with latest security patches
5. **Restrict RDP Access** to trusted networks only
6. **Use VPN** for remote access instead of exposing RDP to internet
7. **Regular Backups** of storage volumes
8. **Monitor Container Logs** for suspicious activity

## Licensing

**⚠️ IMPORTANT LICENSING INFORMATION:**

- Each Windows container instance requires a **valid Windows 11 Pro license**
- Running 3 containers = 3 licenses required
- Dockurr does **NOT** provide Windows licenses
- You are responsible for license compliance
- For legal multi-user RDP, consider Windows Server with RDS CALs

**This setup is intended for:**
- Development/testing environments
- Personal use with proper licensing
- Educational purposes
- Users who have purchased appropriate licenses

## Helpful Commands

```bash
# Check host resources
htop  # CPU/RAM usage
df -h  # Disk usage

# Docker container stats
docker stats

# View all running containers
docker ps

# Restart Docker daemon
sudo systemctl restart docker

# View container details
docker inspect windows-user1

# Execute command in container
docker exec -it windows-user1 bash
```

## Support and Resources

- **Dockurr GitHub:** https://github.com/dockur/windows
- **Docker Documentation:** https://docs.docker.com/
- **Windows 11 Documentation:** https://docs.microsoft.com/windows/

## FAQ

**Q: Can I use Windows 10 instead of Windows 11?**
A: Yes, change `VERSION: "win11"` to `VERSION: "win10"` in docker-compose.yml

**Q: Can multiple users connect to the same container?**
A: No, Windows 11 Pro only allows one RDP session at a time. Each user needs their own container.

**Q: How much internet bandwidth is needed?**
A: Initial Windows download is ~5-6 GB per container. RDP uses minimal bandwidth.

**Q: Can I run this on Windows or macOS host?**
A: Macvlan networking is Linux-only. On Windows/macOS, use port mapping instead of macvlan.

**Q: What if I don't have enough resources for 3 users?**
A: Start with fewer containers, or reduce RAM/CPU per user in .env file.

## Changelog

- **v1.0** - Initial release
  - 3 user support
  - Macvlan networking
  - Management script
  - Comprehensive documentation
