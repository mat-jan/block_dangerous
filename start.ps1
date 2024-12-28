# Ścieżki do plików
$hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts" # Systemowy plik hosts
$backupFolder = Join-Path $env:SystemRoot "System32\drivers\etc\backup" # Folder kopii zapasowych
$tempCertFile = Join-Path $env:TEMP "cert_domains_hosts.txt" # Tymczasowy plik z listą CERT
$certUrl = "https://hole.cert.pl/domains/v2/domains_hosts.txt" # URL listy CERT

# Funkcja wykonująca kopię zapasową pliku hosts
function Backup-Hosts {
    if (!(Test-Path $backupFolder)) {
        New-Item -ItemType Directory -Path $backupFolder | Out-Null
        Write-Host "Utworzono folder kopii zapasowych: $backupFolder" -ForegroundColor Green
    }

    $backupFile = Join-Path $backupFolder ("hosts_backup_" + (Get-Date -Format "yyyyMMddHHmmss") + ".txt")
    Copy-Item -Path $hostsFile -Destination $backupFile -Force
    Write-Host "Wykonano kopię zapasową pliku hosts: $backupFile" -ForegroundColor Cyan
}

# Funkcja pobierająca i aktualizująca plik hosts
function Update-CertHosts {
    # Pobranie nowej listy
    try {
        Invoke-WebRequest -Uri $certUrl -OutFile $tempCertFile -ErrorAction Stop
        Write-Host "Pobrano listę CERT Polska." -ForegroundColor Green
    } catch {
        Write-Host "Nie udało się pobrać listy CERT Polska: $_" -ForegroundColor Red
        exit
    }

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
}

# Wykonanie funkcji
Backup-Hosts
Update-CertHosts
