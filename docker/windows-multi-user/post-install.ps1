# Windows Container Post-Installation Script
# Automatically installs Chocolatey and software packages
# Runs on first boot after Windows installation

# Log file for troubleshooting
$LogFile = "C:\post-install.log"

function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $LogFile -Append
    Write-Host $Message
}

Write-Log "=== Starting Post-Installation Script ==="

# Set execution policy
Write-Log "Setting execution policy..."
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force

# Disable IE Enhanced Security Configuration
Write-Log "Disabling IE Enhanced Security Configuration..."
try {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0 -Force
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0 -Force
    Write-Log "IE Enhanced Security Configuration disabled"
} catch {
    Write-Log "Warning: Could not disable IE ESC - $_"
}

# Disable Windows Defender (optional, can be enabled if needed)
Write-Log "Disabling Windows Defender real-time protection..."
try {
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
    Write-Log "Windows Defender real-time protection disabled"
} catch {
    Write-Log "Warning: Could not disable Windows Defender - $_"
}

# Disable Windows Update (to prevent automatic updates during container runtime)
Write-Log "Disabling Windows Update service..."
try {
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Set-Service -Name wuauserv -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Log "Windows Update service disabled"
} catch {
    Write-Log "Warning: Could not disable Windows Update - $_"
}

# Install Chocolatey
Write-Log "Installing Chocolatey package manager..."
try {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    # Verify installation
    $chocoPath = "$env:ProgramData\chocolatey\bin\choco.exe"
    if (Test-Path $chocoPath) {
        Write-Log "Chocolatey installed successfully"

        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } else {
        throw "Chocolatey installation failed - executable not found"
    }
} catch {
    Write-Log "ERROR: Chocolatey installation failed - $_"
    Write-Log "Continuing without Chocolatey..."
}

# Wait a moment for Chocolatey to fully initialize
Start-Sleep -Seconds 5

# Install software packages via Chocolatey
if (Test-Path "$env:ProgramData\chocolatey\bin\choco.exe") {
    Write-Log "Installing software packages..."

    # Google Chrome
    Write-Log "Installing Google Chrome..."
    try {
        & choco install googlechrome -y --no-progress --limit-output
        Write-Log "Google Chrome installed successfully"
    } catch {
        Write-Log "ERROR: Google Chrome installation failed - $_"
    }

    # Bitwarden
    Write-Log "Installing Bitwarden..."
    try {
        & choco install bitwarden -y --no-progress --limit-output
        Write-Log "Bitwarden installed successfully"
    } catch {
        Write-Log "ERROR: Bitwarden installation failed - $_"
    }

    # Optional: Install additional useful tools (uncomment if needed)
    # Write-Log "Installing 7-Zip..."
    # & choco install 7zip -y --no-progress --limit-output

    # Write-Log "Installing Notepad++..."
    # & choco install notepadplusplus -y --no-progress --limit-output

    # Write-Log "Installing VLC Media Player..."
    # & choco install vlc -y --no-progress --limit-output

    Write-Log "All software packages installed"
} else {
    Write-Log "ERROR: Chocolatey not available, skipping software installation"
}

# Configure RDP settings
Write-Log "Configuring RDP settings..."
try {
    # Enable RDP
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 -Force

    # Enable RDP through Windows Firewall
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

    # Disable Network Level Authentication (for easier access, can be re-enabled for security)
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 0 -Force

    Write-Log "RDP configured successfully"
} catch {
    Write-Log "ERROR: RDP configuration failed - $_"
}

# Set all user accounts to not require password change
Write-Log "Configuring user account settings..."
try {
    $users = @("user1", "user2", "user3", "Administrator")
    foreach ($user in $users) {
        # Set password to never expire
        Set-LocalUser -Name $user -PasswordNeverExpires $true -ErrorAction SilentlyContinue
        Write-Log "Password for $user set to never expire"
    }
} catch {
    Write-Log "Warning: Could not configure all user accounts - $_"
}

# Create a desktop shortcut for installed applications
Write-Log "Creating desktop shortcuts..."
try {
    $DesktopPath = "C:\Users\Public\Desktop"

    # Chrome shortcut
    $ChromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    if (Test-Path $ChromePath) {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("$DesktopPath\Google Chrome.lnk")
        $Shortcut.TargetPath = $ChromePath
        $Shortcut.Save()
        Write-Log "Chrome desktop shortcut created"
    }

    # Bitwarden shortcut
    $BitwardenPath = "C:\Program Files\Bitwarden\Bitwarden.exe"
    if (Test-Path $BitwardenPath) {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("$DesktopPath\Bitwarden.lnk")
        $Shortcut.TargetPath = $BitwardenPath
        $Shortcut.Save()
        Write-Log "Bitwarden desktop shortcut created"
    }
} catch {
    Write-Log "Warning: Could not create desktop shortcuts - $_"
}

# Disable auto-logon for security
Write-Log "Disabling auto-logon..."
try {
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoAdminLogon' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultUserName' -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultPassword' -ErrorAction SilentlyContinue
    Write-Log "Auto-logon disabled"
} catch {
    Write-Log "Warning: Could not disable auto-logon - $_"
}

# Create a welcome message file on the desktop
Write-Log "Creating welcome message..."
try {
    $WelcomeMessage = @"
Windows Container Setup Complete!
===================================

This Windows container has been automatically configured with:
- 3 User Accounts: user1, user2, user3
- Administrator account enabled
- Google Chrome installed
- Bitwarden password manager installed
- Remote Desktop (RDP) enabled

Default Passwords:
- Administrator: Admin@123
- user1: User1@123
- user2: User2@123
- user3: User3@123

IMPORTANT SECURITY NOTICE:
Please change all default passwords immediately!

To change your password:
1. Press Ctrl+Alt+Del
2. Select "Change a password"
3. Enter current password and new password

Or use Command Prompt:
net user <username> <new-password>

Installed Software:
- Google Chrome: Start > Google Chrome
- Bitwarden: Start > Bitwarden

Installation Log: C:\post-install.log

Container configured on: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

    $WelcomeMessage | Out-File -FilePath "C:\Users\Public\Desktop\README.txt" -Encoding UTF8
    Write-Log "Welcome message created on desktop"
} catch {
    Write-Log "Warning: Could not create welcome message - $_"
}

# Final cleanup
Write-Log "Performing final cleanup..."
try {
    # Clear temp files
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue

    # Clear Chocolatey cache
    if (Test-Path "$env:ChocolateyInstall\cache") {
        Remove-Item -Path "$env:ChocolateyInstall\cache\*" -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Log "Cleanup completed"
} catch {
    Write-Log "Warning: Cleanup had some errors - $_"
}

Write-Log "=== Post-Installation Script Completed ==="
Write-Log "System is ready for use. Please log in with one of the configured user accounts."

# Optional: Restart computer to finalize all settings
# Uncomment the following line if you want automatic restart after installation
# Write-Log "Restarting computer in 30 seconds..."
# shutdown /r /t 30 /c "Post-installation complete. System will restart."
