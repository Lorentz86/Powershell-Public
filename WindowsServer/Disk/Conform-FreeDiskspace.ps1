# This script will check the availible disk space of a certain Drive.
function Conform-FreeDiskSpace {
    <#
    .SYNOPSIS
    Checks if the free disk space on a drive meets the specified requirement.
    
    .DESCRIPTION
    This function checks the free disk space on a specified drive and returns
    $true if the free space is greater than or equal to the specified amount and $false if it's less.
    
    .PARAMETER DriveLetter
    The name of the drive to check.
    
    .PARAMETER RequiredFreeSpace
    The required amount of free space in gigabytes (GB).
    
    .EXAMPLE
    PS C:\> Conform-FreeDiskSpace -DriveLetter "C" -RequiredFreeSpace 10
    Checks if there is at least 10GB of free space available on the "C" volume.
    
    .NOTES
    File Name      : Conform-FreeDiskSpace.ps1
    Author         : Gijs van den Berg
    Prerequisite   : PowerShell V2
    Copyright 2011 - Wezenberg Transport. All rights reserved.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="The name of the driveLetter to check.")]
        [string]$DriveLetter,

        [Parameter(Mandatory=$true, HelpMessage="The required amount of free space in gigabytes (GB).")]
        [long]$RequiredFreeSpace
    )

    $DriveInfo = Get-Volume -DriveLetter $DriveLetter

    if ($null -eq $DriveInfo) {
        Write-Host "Drive '$DriveLetter' not found."
        return $false
    }
    $RequiredFreeSpaceGB = $RequiredFreeSpace * 1GB
    $freeSpace = $DriveInfo.SizeRemaining
    if ($freeSpace -ge $RequiredFreeSpaceGB) {
        return $true
    } else {
        return $false
    }
}