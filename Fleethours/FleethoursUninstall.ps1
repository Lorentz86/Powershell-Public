
# Pad voor logging
$logDir = Join-Path $env:APPDATA "FleetHoursUninstall"
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

$logFile = Join-Path $logDir ("Uninstall_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".log")

# Functie voor logging
function Write-Log {
    param([string]$Message)
    $timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    $entry = "$timestamp - $Message"
    Add-Content -Path $logFile -Value $entry
    Write-Information $Message -InformationAction Continue
}

Write-Log "Start uninstall FleetHours..."

# Registry keys
$regHKCU = "HKCU:\Software\LogicWay"
$regHKLM = "HKLM:\SOFTWARE\Wow6432Node\Logicway"

function Get-InstallDir {
    if (Test-Path $regHKLM) {
        $installDir = (Get-ItemProperty -Path $regHKLM).InstallDir
        if ($installDir) {
            Write-Log "InstallDir gevonden: $installDir"
            return $installDir
        }
    }
    Write-Log "InstallDir niet gevonden in registry."
    return $null
}

function Remove-FleetHoursFiles($path) {
    if (Test-Path $path) {
        Write-Log "Verwijder bestanden in: $path"
        Remove-Item -Path $path -Recurse -Force
    } else {
        Write-Log "Pad niet gevonden: $path"
    }
}

# Haal InstallDir op
$installDir = Get-InstallDir

# Als InstallDir niet gevonden is, zoek op C:\ en D:\
if (-not $installDir) {
    Write-Log "Zoek naar Triplog.exe op C:\ en D:\"
    $searchPaths = @("C:\", "D:\")
    foreach ($drive in $searchPaths) {
        $found = Get-ChildItem -Path $drive -Filter "Triplog.exe" -Recurse -ErrorAction SilentlyContinue
        if ($found) {
            $installDir = $found.DirectoryName
            Write-Log "Triplog gevonden op: $installDir"
            break
        }
    }
}

# Verwijder bestanden
if ($installDir) {
    Remove-FleetHoursFiles -path $installDir
}

# Verwijder registry keys
foreach ($key in @($regHKCU, $regHKLM)) {
    if (Test-Path $key) {
        Write-Log "Verwijder registry key: $key"
        Remove-Item -Path $key -Recurse -Force
    }
}

Write-Log "Uninstall voltooid."
