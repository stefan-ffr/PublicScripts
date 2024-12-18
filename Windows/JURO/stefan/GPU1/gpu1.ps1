# Computernamen auslesen
$computerName = $env:COMPUTERNAME
Write-Host "Der Computername ist: $computerName"

# Liste der wichtigsten Programme
Write-Host "Es werden noch die Zusatzprogramme für $computerName installiert."
$programme = @(
    "googlechrome",
    "7zip",
    "notepadplusplus",
    "bitwarden"
)

# Programme installieren
foreach ($programm in $programme) {
    choco install $programm -y --no-progress
}
