# Konfiguracja
$domenaDoCERT = "https://cert.pl" # Docelowa domena CERT Polska
$plikWejsciowy = "domains_to_check.txt" # Lista domen do sprawdzenia
$plikNiebezpieczne = "dangerous_domains.txt" # Lista niebezpiecznych domen
$plikWyjsciowy = "redirect_list.txt" # Plik wynikowy
$plikBackup = "redirect_list_backup.txt" # Plik kopii zapasowej

# Wczytaj dane
if (!(Test-Path $plikWejsciowy)) {
    Write-Host "Plik z listą domen ($plikWejsciowy) nie istnieje!" -ForegroundColor Red
    exit
}

if (!(Test-Path $plikNiebezpieczne)) {
    Write-Host "Plik z listą niebezpiecznych domen ($plikNiebezpieczne) nie istnieje!" -ForegroundColor Red
    exit
}

$domenyDoSprawdzenia = Get-Content $plikWejsciowy
$niebezpieczneDomeny = Get-Content $plikNiebezpieczne

# Utworzenie kopii zapasowej pliku wynikowego
if (Test-Path $plikWyjsciowy) {
    Copy-Item $plikWyjsciowy $plikBackup -Force
    Write-Host "Kopia zapasowa została utworzona: $plikBackup" -ForegroundColor Green
}

# Tworzenie listy przekierowań
$przekierowania = @()
foreach ($domena in $domenyDoSprawdzenia) {
    if ($niebezpieczneDomeny -contains $domena) {
        $przekierowania += "$domena -> $domenaDoCERT"
    }
}

# Synchronizacja: dodaj nowe i usuń nieaktualne linie
if (Test-Path $plikWyjsciowy) {
    $aktualnePrzekierowania = Get-Content $plikWyjsciowy
    $przekierowania = $przekierowania | Sort-Object | Get-Unique
    $aktualnePrzekierowania = $aktualnePrzekierowania | Sort-Object | Get-Unique
    $nowePrzekierowania = $przekierowania | Where-Object { $_ -notin $aktualnePrzekierowania }
    $usunietePrzekierowania = $aktualnePrzekierowania | Where-Object { $_ -notin $przekierowania }
    
    # Zapisanie zaktualizowanej listy
    $przekierowania | Out-File $plikWyjsciowy -Encoding UTF8
    Write-Host "Plik zaktualizowany. Dodano: $($nowePrzekierowania.Count), Usunięto: $($usunietePrzekierowania.Count)" -ForegroundColor Cyan
} else {
    # Pierwsze utworzenie pliku wynikowego
    $przekierowania | Out-File $plikWyjsciowy -Encoding UTF8
    Write-Host "Plik wynikowy został utworzony: $plikWyjsciowy" -ForegroundColor Green
}

# Harmonogram aktualizacji codziennie o 12:00
$taskName = "UpdateRedirectList"
$scriptPath = (Get-Item -Path $MyInvocation.MyCommand.Definition).FullName

if (!(Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName})) {
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$scriptPath`""
    $trigger = New-ScheduledTaskTrigger -Daily -At "12:00PM"
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount
    Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName -Description "Codzienna aktualizacja listy przekierowań"
    Write-Host "Zadanie harmonogramu zostało utworzone: $taskName" -ForegroundColor Green
} else {
    Write-Host "Zadanie harmonogramu już istnieje." -ForegroundColor Yellow
}
