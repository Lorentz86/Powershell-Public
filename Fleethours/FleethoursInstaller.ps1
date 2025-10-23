
# Zoek naar de installer (bijv. Triplog*.exe)
$LookForFile = Get-ChildItem -Path $PSScriptRoot -Filter "Triplog*.exe" | Select-Object -First 1

if (-not $LookForFile) {
    Write-Error "Installer niet gevonden in map: $PSScriptRoot"
    exit 1
}

$installerPath = $LookForFile.FullName

# Parameters voor stille installatie met log en geforceerde sluiting van applicaties
$arguments = "/VERYSILENT /NORESTART /SP- /SUPPRESSMSGBOXES /CLOSEAPPLICATIONS /FORCECLOSEAPPLICATIONS /DIR=`"C:\Program Files\FleetHours`" /LOG=`"$PSScriptRoot\FleetHours_Install.log`""

try {
    Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait -NoNewWindow
    Write-Information "FleetHours installatie voltooid." -InformationAction Continue

    # Bestand dat gekopieerd moet worden
    $sourceFile = Join-Path $PSScriptRoot "config.edlf"

    # Controleer of bestand bestaat
    if (-not (Test-Path $sourceFile)) {
        Write-Error "Bronbestand niet gevonden: $sourceFile"
        exit 1
    }

    # Functie om InstallDir op te halen
    function Get-InstallDir {
        $regHKLM = "HKLM:\SOFTWARE\Wow6432Node\Logicway"
        if (Test-Path $regHKLM) {
            $installDir = (Get-ItemProperty -Path $regHKLM).InstallDir
            if ($installDir) {
                return $installDir
            }
        }
        return $null
    }

    # Haal installatiemap op
    $installDir = Get-InstallDir

    if ($installDir -and (Test-Path $installDir)) {
        $destinationFile = Join-Path $installDir "config.edlf"
        Copy-Item -Path $sourceFile -Destination $destinationFile -Force
        Write-Information "Bestand gekopieerd naar: $destinationFile" -InformationAction Continue
    } else {
        Write-Error "Installatiemap niet gevonden, bestand niet gekopieerd."
        exit 1
    }


} catch {
    Write-Error "Installatie mislukt: $_"
    exit 1
}
