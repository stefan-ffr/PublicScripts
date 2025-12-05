# Windows Scripts

Collection of PowerShell scripts for automated Windows system setup and configuration.

## Available Scripts

### init.ps1.example - Main Initialization Script

Main entry point for automated Windows setup. This script:
- Checks for and installs Git if needed
- Clones user-specific configurations from your repository
- Executes PowerShell and Bash scripts for the specified user

**Setup:**
1. Copy and customize for your environment:
   ```powershell
   Copy-Item init.ps1.example init.ps1
   ```

2. Edit `init.ps1` and customize:
   - `$repoUrl`: Your repository URL
   - Path structure in `git sparse-checkout set`

3. Run as Administrator:
   ```powershell
   .\init.ps1
   ```

### Examples Directory

Template scripts that can be customized for your needs:

#### basic-setup.ps1.example
Automated software installation using Chocolatey package manager.

**What it does:**
- Installs Chocolatey if not present
- Installs common software packages
- Executes computer-specific scripts

**Included software:**
- Google Chrome
- Firefox
- 7-Zip
- Git
- Visual Studio Code
- Notepad++
- Bitwarden

**Usage:**
```powershell
Copy-Item examples\basic-setup.ps1.example basic-setup.ps1
# Customize the software list if needed
.\basic-setup.ps1
```

#### network-drives.sh.example
Maps network drives on Windows systems.

**Setup:**
```bash
cp examples/network-drives.sh.example network-drives.sh
# Edit network-drives.sh with your network paths
bash network-drives.sh
```

## Requirements

- Windows 10/11 or Windows Server
- PowerShell 5.1 or later
- Administrator privileges
- Internet connection

## Usage Pattern

The typical workflow:

1. **Initial Setup:**
   - Customize `init.ps1.example` with your repository URL
   - Save as `init.ps1`

2. **Run on New Machine:**
   - Run `init.ps1` as Administrator
   - Enter the user-specific subfolder name
   - Scripts are automatically cloned and executed

3. **User-Specific Configs:**
   - Store per-user/per-computer scripts in `secrets/windows/USERNAME/`
   - These are cloned and executed by `init.ps1`

## Security Notes

- Always run scripts as Administrator
- Review scripts before execution
- Store sensitive configurations in the `secrets/` folder (excluded from git)
- Never commit credentials or private network information
- Use WSL for bash script execution on Windows

## Customization

### Adding Software to Chocolatey List

Edit the `$programme` array in `basic-setup.ps1`:
```powershell
$programme = @(
    "googlechrome",
    "your-package-name"
)
```

Find packages at: https://community.chocolatey.org/packages

### Network Drives

Customize the network paths in `network-drives.sh`:
```bash
net use X: \\your-server\share /persistent:yes
```

## Troubleshooting

**Execution Policy Error:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Git Not Found:**
The `init.ps1` script automatically installs Git if not present.

**Chocolatey Installation Fails:**
Manually install from: https://chocolatey.org/install
