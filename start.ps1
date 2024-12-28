# Ustawienia
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$backupFolder = Join-Path $env:SystemRoot "System32\drivers\etc\backup"
$backupFile = Join-Path $backupFolder "hosts_backup.txt"
$tempCertFile = Join-Path $env:TEMP "cert_domains_hosts.txt"
$certUrl = "https://hole.cert.pl/domains/v2/domains_hosts.txt"

# Funkcja do logowania błędów
function Log-Error {
    $message = $args[0]
    $logFile = Join-Path $env:USERPROFILE "Downloads\error.log"
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - ERROR: $message"
    Add-Content -Path $logFile -Value $logMessage
}

# Funkcja wykonująca kopię zapasową pliku hosts
function Backup-Hosts {
    try {
        # Sprawdzamy, czy folder backupowy istnieje
        if (!(Test-Path $backupFolder)) {
            New-Item -ItemType Directory -Path $backupFolder | Out-Null
            Write-Host "Utworzono folder kopii zapasowych: $backupFolder" -ForegroundColor Green
        }

        # Wczytanie zawartości pliku hosts (jeśli istnieje kopia zapasowa)
        $backupContent = @()
        if (Test-Path $backupFile) {
            $backupContent = Get-Content -Path $backupFile
        }

        # Pobranie zawartości aktualnego pliku hosts
        $hostsContent = Get-Content -Path $hostsFile

        # Usunięcie starych wpisów CERT z kopii zapasowej (jeśli istnieją)
        $startMarker = "# START CERT.PL HOSTS LIST"
        $endMarker = "# END CERT.PL HOSTS LIST"
        $cleanedBackup = $backupContent | Where-Object { 
            ($_ -notlike "$startMarker*") -and ($_ -notlike "$endMarker*")
        }

        # Pobranie nowych wpisów z pliku hosts
        $newCertHosts = $hostsContent | Where-Object { $_ -notlike "#*" -and $_ -notlike "" }
        $newCertBlock = @("$startMarker") + $newCertHosts + @("$endMarker")

        # Dodanie nowych wpisów z listy CERT do kopii zapasowej, jeśli ich tam jeszcze nie ma
        $updatedBackup = $cleanedBackup + $newCertBlock

        # Zapisanie zaktualizowanej kopii zapasowej
        Set-Content -Path $backupFile -Value $updatedBackup -Force
        Write-Host "Zaktualizowano kopię zapasową pliku hosts: $backupFile" -ForegroundColor Cyan
    } catch {
        Log-Error "Nie udało się wykonać kopii zapasowej pliku hosts: $_"
        throw
    }
}

# Funkcja pobierająca listę złośliwych domen z CERT Polska
function Download-CertDomains {
    try {
        Write-Host "Pobieranie listy złośliwych domen z CERT Polska..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $certUrl -OutFile $tempCertFile
        Write-Host "Listę złośliwych domen pobrano pomyślnie!" -ForegroundColor Green
    } catch {
        Log-Error "Błąd podczas pobierania listy złośliwych domen z CERT Polska: $_"
        throw
    }
}

# Funkcja aktualizująca plik hosts
function Update-Hosts {
    try {
        Write-Host "Aktualizowanie pliku hosts..." -ForegroundColor Yellow
        $certContent = Get-Content -Path $tempCertFile
        $newContent = @()

        # Dodanie nowych wpisów z listy CERT
        $newContent += "# START CERT.PL HOSTS LIST"
        $newContent += $certContent
        $newContent += "# END CERT.PL HOSTS LIST"

        # Zapisanie nowych wpisów do pliku hosts
        Set-Content -Path $hostsFile -Value $newContent -Force
        Write-Host "Plik hosts został zaktualizowany." -ForegroundColor Green
    } catch {
        Log-Error "Błąd podczas aktualizacji pliku hosts: $_"
        throw
    }
}

# Główna logika skryptu
function Main {
    # Sprawdzanie, czy skrypt działa jako administrator
    if (-not (Test-Path $hostsFile)) {
        Write-Host "Brak dostępu do pliku hosts. Upewnij się, że uruchomisz skrypt jako administrator." -ForegroundColor Red
        return
    }

    # Wykonanie kopii zapasowej pliku hosts
    Backup-Hosts

    # Pobranie listy złośliwych domen z CERT Polska
    Download-CertDomains

    # Zaktualizowanie pliku hosts
    Update-Hosts
}

# Uruchomienie głównej funkcji
Main
