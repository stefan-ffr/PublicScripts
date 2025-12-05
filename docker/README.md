# Docker Setups

Collection of Docker-based setups and configurations.

## Available Setups

### Windows Multi-User

Run multiple Windows 11 Pro instances in Docker containers with individual IP addresses.

**Location:** [windows-multi-user/](windows-multi-user/)

**Features:**
- Multiple isolated Windows 11 Pro containers
- Macvlan networking (each container gets own IP)
- RDP access for each user
- Easy management via shell script
- Configurable resources per user

**Quick Start:**
```bash
cd windows-multi-user
cp .env.example .env
nano .env  # Configure your network settings
./manage.sh start
```

**System Requirements:**
- Linux host with KVM support
- Minimum: 6 CPU cores, 20GB RAM, 200GB storage
- Docker with compose plugin

**Use Cases:**
- Multi-user remote desktop access
- Development/testing environments
- Isolated Windows environments
- Training/education labs

See [windows-multi-user/README.md](windows-multi-user/README.md) for detailed documentation.
