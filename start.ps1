# Funkcja sprawdzająca, czy PowerShell działa jako administrator
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal [Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Uruchomienie skryptu w trybie administratora, jeśli nie ma uprawnień
if (-not (Test-Administrator)) {
    Write-Host "Uruchamianie skryptu w trybie administratora..."
    Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Ścieżki do plików
$hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts" # Systemowy plik hosts
$backupFolder = Join-Path $env:SystemRoot "System32\drivers\etc\backup" # Folder kopii zapasowych
$tempCertFile = Join-Path $env:TEMP "cert_domains_hosts.txt" # Tymczasowy plik z listą CERT
$errorLogFile = Join-Path $env:USERPROFILE\Downloads "error.log" # Plik logów błędów
$certUrl = "https://hole.cert.pl/domains/v2/domains_hosts.txt" # URL listy CERT

# Funkcja logująca błędy
function Log-Error {
    param (
        [string]$Message
    )
    Add-Content -Path $errorLogFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Message"
    Write-Host "Błąd zapisano w pliku: $errorLogFile" -ForegroundColor Red
}

# Funkcja wykonująca kopię zapasową pliku hosts
function Backup-Hosts {
    try {
        if (!(Test-Path $backupFolder)) {
            New-Item -ItemType Directory -Path $backupFolder | Out-Null
            Write-Host "Utworzono folder kopii zapasowych: $backupFolder" -ForegroundColor Green
        }

        $backupFile = Join-Path $backupFolder ("hosts_backup_" + (Get-Date -Format "yyyyMMddHHmmss") + ".txt")
        Copy-Item -Path $hostsFile -Destination $backupFile -Force
        Write-Host "Wykonano kopię zapasową pliku hosts: $backupFile" -ForegroundColor Cyan
    } catch {
        Log-Error "Nie udało się wykonać kopii zapasowej pliku hosts: $_"
        throw
    }
}

# Funkcja pobierająca i aktualizująca plik hosts
function Update-CertHosts {
    try {
        # Pobranie nowej listy
        Invoke-WebRequest -Uri $certUrl -OutFile $tempCertFile -ErrorAction Stop
        Write-Host "Pobrano listę CERT Polska." -ForegroundColor Green

        # Wczytanie zawartości systemowego pliku hosts
        $hostsContent = Get-Content -Path $hostsFile -ErrorAction Stop

        # Usunięcie starych wpisów CERT z pliku hosts
        $startMarker = "# START CERT.PL HOSTS LIST"
        $endMarker = "# END CERT.PL HOSTS LIST"
        $cleanedHosts = $hostsContent | Where-Object { 
            ($_ -notlike "$startMarker*") -and ($_ -notlike "$endMarker*")
        }

        # Pobranie nowych wpisów z listy CERT
        $newCertHosts = Get-Content -Path $tempCertFile | Where-Object { $_ -notlike "#*" -and $_ -notlike "" }
        $newCertBlock = @("$startMarker") + $newCertHosts + @("$endMarker")

        # Zapisanie zaktualizowanego pliku hosts
        $updatedHosts = $cleanedHosts + $newCertBlock
        Set-Content -Path $hostsFile -Value $updatedHosts -Force -Encoding UTF8
        Write-Host "Zaktualizowano plik hosts z listą CERT Polska." -ForegroundColor Green
    } catch {
        Log-Error "Nie udało się zaktualizować pliku hosts: $_"
        throw
    }
}

# Wykonanie skryptu z obsługą błędów
try {
    Backup-Hosts
    Update-CertHosts
} catch {
    Log-Error "Ogólny błąd podczas wykonywania skryptu: $_"
}
