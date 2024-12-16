# Ensure script runs with elevated privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an Administrator." -ForegroundColor Red
    Exit
}

# Check if PowerShell is already installed
if (-not (Get-Command "pwsh" -ErrorAction SilentlyContinue)) {
    Write-Host "PowerShell is not installed. Installing..." -ForegroundColor Yellow
    # Download and install PowerShell
    $InstallerPath = "$env:TEMP\PowerShell-Installer.msi"
    Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/latest/download/PowerShell-7.3.7-win-x64.msi" -OutFile $InstallerPath
    Start-Process msiexec.exe -ArgumentList "/i", $InstallerPath, "/quiet", "/norestart" -Wait
    Remove-Item $InstallerPath

    # Verify installation
    if (-not (Get-Command "pwsh" -ErrorAction SilentlyContinue)) {
        Write-Host "Failed to install PowerShell. Exiting." -ForegroundColor Red
        Exit
    }
    Write-Host "PowerShell installed successfully." -ForegroundColor Green
}

# Prompt user to select a subfolder
$userFolder = Read-Host "Please enter the name of the subfolder to process"

# Clone only the specified subfolder from the repository
$tempFolder = "$env:TEMP\PublicScripts\Windows\JURO\$userFolder"
if (Test-Path $tempFolder) {
    Remove-Item -Recurse -Force $tempFolder
}

Write-Host "Cloning specified subfolder from repository..." -ForegroundColor Yellow
Invoke-Expression "git clone --depth 1 --filter=blob:none --sparse https://github.com/stefan-ffr/PublicScripts.git $tempFolder"
Set-Location -Path $tempFolder
Invoke-Expression "git sparse-checkout set Windows/JURO/$userFolder"

# Base folder containing the user subfolder
$scriptFolder = Join-Path -Path $tempFolder -ChildPath "Windows\JURO\$userFolder"
if (-not (Test-Path $scriptFolder)) {
    Write-Host "The specified subfolder does not exist in the repository. Exiting." -ForegroundColor Red
    Exit
}

# Execute all PowerShell scripts in the specified folder
Get-ChildItem -Path $scriptFolder -Filter *.ps1 -Recurse | ForEach-Object {
    Write-Host "Executing PowerShell script: $($_.FullName)" -ForegroundColor Cyan
    & "pwsh" -File $_.FullName
}

# Execute all Bash scripts in the specified folder
Get-ChildItem -Path $scriptFolder -Filter *.sh -Recurse | ForEach-Object {
    Write-Host "Executing Bash script: $($_.FullName)" -ForegroundColor Cyan
    & "wsl" bash $_.FullName
}

Write-Host "All scripts executed successfully." -ForegroundColor Green
