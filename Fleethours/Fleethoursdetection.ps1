# Registry keys
$regHKCU = "HKCU:\Software\LogicWay"
$regHKLM = "HKLM:\SOFTWARE\Wow6432Node\Logicway"
$regpaths = @($regHKCU, $regHKLM)
$Installed = $false

# Functie om InstallDir op te halen
function Get-InstallDir {
    param($regPath)
    if (Test-Path $regPath) {
        $installDir = (Get-ItemProperty -Path $regPath).InstallDir
        if ($installDir) {
            return $installDir
        }
    }
    return $null
}

# Stap 1: Check registry
foreach ($regpath in $regpaths) {
    $installDir = Get-InstallDir -regPath $regpath
    if ($installDir -and (Test-Path (Join-Path $installDir "TripLog.exe"))) {
        $Installed = $true
        break
    }
}

# Stap 2: Zoek op alle lokale drives (alleen als nog niet gevonden)
if (-not $Installed) {
    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -gt 0 } | Select-Object -ExpandProperty Root
    foreach ($drive in $drives) {
        $found = Get-ChildItem -Path $drive -Filter "TripLog.exe" -Recurse -ErrorAction SilentlyContinue
        if ($found) {
            $Installed = $true
            break
        }
    }
}

# Exitcode
if ($Installed) {
    exit 0
} else {
    exit 1
}