<#
.SYNOPSIS
    Retrieves the disk number of a mounted VHD file.

.DESCRIPTION
    This function checks if a specified VHD file is mounted and attempts to retrieve its associated disk number.
    It validates the path, handles errors gracefully, and provides clear feedback if the disk is not found.

.PARAMETER VHDPath
    The full path to the VHD or VHDX file.

.EXAMPLE
    Get-VHDMountNumber -VHDPath "C:\VHDs\Profile.vhdx"
#>
function Get-VHDMountNumber {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$VHDPath
    )

    if (-not (Test-Path -Path $VHDPath)) {
        throw "VHD file does not exist at path: $VHDPath"
    }
    
    try {
        # Get all disks and try to match by Location or Path
        $mountedDisk = Get-Disk | Where-Object {
            $_.Location -like "*$VHDPath*" -or $_.Path -like "*$VHDPath*"
        }

        if ($mountedDisk) {
            return $mountedDisk.Number
        } else {
            throw "VHD is not mounted or not found in disk list: $VHDPath"
        }
    }
    catch {
        Write-Error "An error occurred while retrieving the VHD mount number: $($_.Exception.Message)"
        return $null
    }
}
