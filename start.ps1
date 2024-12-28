# Script to download the list of malicious domains from CERT Polska, make a backup copy of the hosts file
# and update the hosts file on the computer.

# Determining paths
$hostsFile = "C:\Windows\System32\drivers\etc\hosts"
$backupFolder = "C:\Windows\System32\drivers\etc\backup"
$errorLog = "$env:USERPROFILE\Downloads\error.log"
$tempFile = "$env:TEMP\cert_hosts_temp.txt"

# Error logging function
function Log-Error {
    param (
        [string]$message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - ERROR: $message"
    Write-Output $logMessage
    Add-Content -Path $errorLog -Value $logMessage
}

# Creating a backup folder if it doesn't exist
if (-not (Test-Path $backupFolder)) {
    try {
        New-Item -Path $backupFolder -ItemType Directory -Force
    } catch {
        Log-Error "Failed to create backup folder: $backupFolder"
        exit
    }
}

# Backing up the hosts file
$backupFile = "$backupFolder\hosts_backup.txt"
try {
    Copy-Item -Path $hostsFile -Destination $backupFile -Force
} catch {
    Log-Error "Failed to backup hosts file: $hostsFile"
    exit
}

# Downloading the list of malicious domains from CERT Polska
try {
    Invoke-WebRequest -Uri "https://hole.cert.pl/domains/v2/domains_hosts.txt" -OutFile $tempFile -ErrorAction Stop
} catch {
    Log-Error "Error downloading the list of malicious domains from CERT Polska."
    exit
}

# Loading the contents of a temporary file
$tempContent = Get-Content -Path $tempFile

# Usuwanie pliku tymczasowego
Remove-Item -Path $tempFile -Force

# Hosts file modification - adding new domains
try {
    $startMarker = "# START CERT.PL HOSTS LIST"
    $endMarker = "# END CERT.PL HOSTS LIST"

    # Loading the current contents of the hosts file
    $hostsContent = Get-Content -Path $hostsFile

    # Removing previous CERT.PL entries
    $hostsContent = $hostsContent | Where-Object { $_ -notmatch $startMarker -and $_ -notmatch $endMarker }

    # Adding new entries
    $hostsContent += "$startMarker"
    $hostsContent += $tempContent
    $hostsContent += "$endMarker"

    # Saving the updated hosts file
    Set-Content -Path $hostsFile -Value $hostsContent -Force
} catch {
    Log-Error "Error updating hosts file."
    exit
}

Write-Output "Hosts file update completed successfully."
