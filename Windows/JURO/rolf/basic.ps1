# Chocolatey installieren, wenn es noch nicht vorhanden ist
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey wird installiert..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    Write-Host "Chocolatey ist bereits installiert."
}

# Liste der wichtigsten Programme
$programme = @(
    "googlechrome",
    "firefox",
    "7zip",
    "git",
    "vscode",
    "notepadplusplus"
)

# Programme installieren
foreach ($programm in $programme) {
    choco install $programm -y --no-progress
}

# Computernamen auslesen
$computerName = $env:COMPUTERNAME
Write-Host "Der Computername ist: $computerName"

# Verzeichnis mit dem Computernamen
$targetDirectory = "./$computerName"
if (-not (Test-Path $targetDirectory)) {
    Write-Host "Das Verzeichnis $targetDirectory existiert nicht. Skript wird beendet."
    exit 1
}

# Alle Bash- und PowerShell-Skripte ausführen
Get-ChildItem -Path $targetDirectory -Recurse -Include *.ps1,*.sh | ForEach-Object {
    $script = $_.FullName
    if ($script -like "*.ps1") {
        Write-Host "PowerShell-Skript wird ausgeführt: $script"
        & $script
    } elseif ($script -like "*.sh") {
        Write-Host "Bash-Skript wird ausgeführt: $script"
        bash $script
    }
}
