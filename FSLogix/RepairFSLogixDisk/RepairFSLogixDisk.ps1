# Script to repair FSLogix disks
# This script will compact and optimize VHDX files in a specified folder
# Start Logging

param (
    [Parameter(Mandatory = $false)]
    [string]$FolderPath,

    [Parameter(Mandatory = $false)]
    [string]$ConnectionBroker,

    [Parameter(Mandatory = $false)]
    [string]$TargetUser,

    [Parameter(Mandatory = $false)]
    [string]$TargetVHDXPath
)

if(-not(Test-Path "$Env:Appdata\PSFSLogix")){
    New-Item -Path "$Env:Appdata\PSFSLogix" -ItemType Directory | Out-Null
}

$logFile = "$Env:Appdata\PSFSLogix\RepairFSLogixDisk.log"

if(-not(Test-Path $logFile)){
    New-Item -Path $logFile -ItemType File | Out-Null
}

Start-Transcript -Path $logFile -Append -Force

# Single Loop or VHDX Targetting
if ($TargetVHDXPath) {
    $vdiskFiles = Get-Item -Path $TargetVHDXPath
} else {
    $vdiskFiles = Get-ChildItem -Recurse -Path $FolderPath -Filter *.vhdx -File
}

if ($TargetUser) {
    Write-Host "Targeting VHDX files for user: $TargetUser"
    $vdiskFiles = $vdiskFiles | Where-Object { $_.Name -like "*$TargetUser*" }
} else {
    Write-Host "No specific user targeted."
}

<# 
   I use Get-UsernameFromVHDXFile as a "custom function". I use the flip flop user names and drives FSLogix GPO. So i get ODFC_Username.vhdx and Profile_Username.vhdx
   If you use a different naming convention, you can change the function to suit your needs.
#>

$vdiskFiles | ForEach-Object {
    param($vdisk)
    $username = Get-UsernameFromVHDXFile -VHDXPath $vdisk.FullName
    if ($username) {
        Write-Host "Found username '$username' in VHDX file '$($vdisk.FullName)'"
    }
    else {
        Write-Host "Could not extract username from VHDX file '$($vdisk.FullName)'. Skipping this file."
        return
    }
    # Check if user is nog logged on
    if (-not (Get-RDSUserSession -Username $username -ConnectionBroker $ConnectionBroker)) {
        try {
            Write-Host "User '$username' is not logged on. Starting repair for this VHDX file."
            $DriveLetter = Get-AvailableDriveLetter
            Mount-VHD -Path $vdisk.FullName -ErrorAction Stop
            $diskNumber = Get-VHDMountNumber -VHDPath $vdisk.FullName
            Set-Partition -DiskNumber $diskNumber -PartitionNumber 1 -NewDriveLetter $DriveLetter
        }
        catch {
            Write-Error "An error occurred while mounting the VHDX file: $($_.Exception.Message)"
            return
        }      
        Write-Host "Mounted VHD is on Disk $diskNumber with Drive Letter $DriveLetter"
        # Run disk maintenance commands
        Repair-FsLogixDisk -DriveLetter $DriveLetter

        try {
            Write-Host "Removing access path and optimizing VHD for $($vdisk.FullName)"
            Remove-PartitionAccessPath -DiskNumber $diskNumber -AccessPath "$DriveLetter`:`\"
            Dismount-VHD -Path $vdisk.FullName -ErrorAction Stop
            Optimize-VHD -Path $vdisk.FullName -Mode Full
        }
        catch {
            Write-Error "An error occurred while dismounting or optimizing the VHDX file: $($_.Exception.Message)"
            return
        }


    } else {
        Write-Host "User '$username' is currently logged on. Skipping repair for this VHDX file."
        return
    }
}

# End of Transcript
Stop-Transcript