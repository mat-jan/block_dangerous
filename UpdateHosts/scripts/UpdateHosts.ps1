# Ustawienie ścieżek
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$backupFolder = "C:\Windows\System32\drivers\etc\backup"
$errorLog = "$env:USERPROFILE\Downloads\error.log"
$tempFile = "$env:TEMP\cert_hosts_temp.txt"

# Funkcja logowania błędów
function Log-Error {
    param (
        [string]$message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - ERROR: $message"
    Write-Output $logMessage
    Add-Content -Path $errorLog -Value $logMessage
}

# Tworzenie folderu kopii zapasowych
if (-not (Test-Path $backupFolder)) {
    try {
        New-Item -Path $backupFolder -ItemType Directory -Force
    } catch {
        Log-Error "Nie udało się utworzyć folderu kopii zapasowych: $backupFolder"
        exit
    }
}

# Tworzenie kopii zapasowej pliku hosts
$backupFile = "$backupFolder\hosts_backup_$(Get-Date -Format 'yyyyMMddHHmmss').txt"
try {
    Copy-Item -Path $hostsFile -Destination $backupFile -Force
} catch {
    Log-Error "Nie udało się utworzyć kopii zapasowej pliku hosts: $hostsFile"
    exit
}

# Pobieranie listy złośliwych domen z CERT Polska
try {
    Invoke-WebRequest -Uri "https://hole.cert.pl/domains/v2/domains_hosts.txt" -OutFile $tempFile -ErrorAction Stop
} catch {
    Log-Error "Błąd podczas pobierania listy złośliwych domen z CERT Polska."
    exit
}

# Ładowanie zawartości pliku tymczasowego
$tempContent = Get-Content -Path $tempFile

# Usuwanie pliku tymczasowego
Remove-Item -Path $tempFile -Force

# Modyfikacja pliku hosts
try {
    $startMarker = "# START CERT.PL HOSTS LIST"
    $endMarker = "# END CERT.PL HOSTS LIST"

    # Ładowanie aktualnej zawartości pliku hosts
    $hostsContent = Get-Content -Path $hostsFile

    # Usunięcie poprzednich wpisów CERT.PL
    $hostsContent = $hostsContent | Where-Object { $_ -notmatch $startMarker -and $_ -notmatch $endMarker }

    # Dodanie nowych wpisów
    $hostsContent += "$startMarker"
    $hostsContent += $tempContent
    $hostsContent += "$endMarker"

    # Zapisanie zaktualizowanego pliku hosts
    Set-Content -Path $hostsFile -Value $hostsContent -Force
} catch {
    Log-Error "Błąd podczas aktualizacji pliku hosts."
    exit
}

Write-Output "Aktualizacja pliku hosts zakończona sukcesem."
