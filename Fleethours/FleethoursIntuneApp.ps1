<#
.SYNOPSIS
    Packages the Fleethours Triplog installer into an IntuneWin format using IntuneWinAppUtil.exe.

.DESCRIPTION
    This script validates paths, checks for required files, and runs the packaging tool to prepare the Fleethours app for Intune deployment.
#>

param(
    [string]$prepToolPath   = 'C:\intune\IntuneWinAppUtil.exe',
    [string]$sourcePath     = 'C:\intune\Input Fleethours',
    [string]$outputPath     = 'C:\intune\output Fleethours'
)
Set-infoemationPreference -InformationAction Continue
Write-Information "=== Fleethours Intune App Packaging ===" -InformationAction Continue
Write-Information "Preparation Tool: $prepToolPath" -InformationAction Continue
Write-Information "Source Path: $sourcePath" -InformationAction Continue
Write-Information "Output Path: $outputPath" -InformationAction Continue

# Define expected script filenames
$installScript   = "FleethoursInstaller.ps1"
$uninstallScript = "FleethoursUninstall.ps1"

# Validate all required paths
foreach ($path in @($prepToolPath, $sourcePath, $outputPath)) {
    if (-not (Test-Path $path)) {
        Write-Error "Path does not exist: $path"
        exit 1
    }
}

# Locate the Triplog installer
$setupFile = Get-ChildItem -Path $sourcePath -Filter 'Triplog*.exe' | Select-Object -First 1
if (-not $setupFile) {
    Write-Error "No Triplog installer found in: $sourcePath"
    exit 1
} else {
    Write-Information "Installer found: $($setupFile.Name)" -InformationAction Continue
}

# Validate presence of install/uninstall scripts
foreach ($script in @($installScript, $uninstallScript)) {
    $scriptPath = Join-Path -Path $sourcePath -ChildPath $script
    if (-not (Test-Path $scriptPath)) {
        Write-Error "Missing script: $scriptPath"
        exit 1
    } else {
        Write-Information "Script found: $script" -InformationAction Continue
    }
}

# Run the packaging tool
Write-Information "Creating Intune Win App package..." -InformationAction Continue
& $prepToolPath -c -s $sourcePath -o $outputPath

Write-Information "Intune Win App package created successfully in '$outputPath'."
Write-Information "=== Fleethours Intune App packaging process completed ==="