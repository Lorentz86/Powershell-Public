<#
.SYNOPSIS
    Collects Autopilot hardware info and exports to CSV. Username and BIOS serial are optional.
    Includes detailed logging.
#>

[CmdletBinding()]
param(
    [string]$AssignedUser,
    [string]$BiosSerialNumber = $null
)

# Set InformationPreference to Continue for visible logging
$InformationPreference = 'Continue'

Write-Information "=== Starting Autopilot Hardware Info Collection Script ==="

# Set execution policy for this process only
Write-Information "Setting execution policy for this process..."
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force

# Ensure TLS 1.2 is used for secure downloads
Write-Information "Setting TLS 1.2 for secure downloads..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Uncomment to create directory if not exists if you want antother directory than script root
<#
# Ensure output directory exists
$HWIDPath = "C:\Intune\AutoPilotHWID"

if (!(Test-Path $HWIDPath)) {
    Write-Information "Creating output directory at $HWIDPath..."
    New-Item -Type Directory -Path $HWIDPath | Out-Null
} else {
    Write-Information "Output directory already exists at $HWIDPath."
}
#>

# Force install NuGet provider if not present
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    Write-Information "NuGet provider not found. Installing NuGet provider..."
    Install-PackageProvider -Name NuGet -Force
} else {
    Write-Information "NuGet provider already installed."
}

# Force install WindowsAutopilotIntune script module if not present
if (-not (Get-Command Get-WindowsAutopilotInfo -ErrorAction SilentlyContinue)) {
    Write-Information "Get-WindowsAutopilotInfo script not found. Installing script..."
    Install-Script -Name Get-WindowsAutopilotInfo -Force
} else {
    Write-Information "Get-WindowsAutopilotInfo script already installed."
}

# Add script path to environment variable (if needed)
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"

# Try to get BIOS serial number if not provided
if (-not $BiosSerialNumber) {
    Write-Information "No BIOS serial number provided. Attempting to retrieve using PowerShell..."
    try {
        $BiosSerialNumber = (Get-WmiObject -Class Win32_BIOS | Select-Object -ExpandProperty SerialNumber)
        if ($BiosSerialNumber) {
            Write-Information "BIOS serial number retrieved: $BiosSerialNumber"
        } else {
            Write-Information "BIOS serial number could not be retrieved. Leaving as null."
        }
    } catch {
        Write-Information "Error retrieving BIOS serial number: $_"
        $BiosSerialNumber = $null
    }
} else {
    Write-Information "Using provided BIOS serial number: $BiosSerialNumber"
}

# Collect hardware info
Write-Information "Collecting hardware information..."
$HWInfo = [PSCustomObject]@{
    'Device Serial Number' = $null
    'Windows Product ID'   = $null
    'Hardware Hash'        = $null
    'Group Tag'            = $null
    'Assigned User'        = $AssignedUser
    'BIOS Serial Number'   = $BiosSerialNumber
}

try {
    $DevInfo = Get-WindowsAutopilotInfo
    if($HWInfo.'Device Serial Number' -eq $null) {
        $HWInfo.'Device Serial Number' = $DevInfo.'Device Serial Number'
    }
    $HWInfo.'Hardware Hash'        = $DevInfo.'Hardware Hash'
    if($HWInfo.'Hardware Hash'){Write-Information -MessageData "Succesfully collected Hardware hash"}
    else{Write-Warning -Message "Could not collect hardware hash"}
    if($HWInfo.'Device Serial Number'){Write-Information -MessageData "Succesfully collected Device Serial Number"}
    else{Write-Warning -Message "Could not collect Device Serial Number"}
    Write-Information "Hardware information collected successfully."
} catch {
    Write-Warning -message "Failed to collect hardware information: $_"
}

# Export to CSV
$Date = Get-Date -Format "yyyyMMdd"
$Filename = "AutoPilot_"+ $HWInfo.'Device Serial Number' + "_" + "$Date.csv"
$Outfile = "$PSScriptRoot\$Filename"
Write-Information "Exporting hardware info to $Outfile..."
$CSVList = $HWInfo | ConvertTo-Csv -NoTypeInformation -Delimiter ","
$CSVList | ForEach-Object { $_ -replace '"', '' } | Out-File $Outfile

Write-Information "=== Script completed. Hardware info exported to $Outfile ==="
