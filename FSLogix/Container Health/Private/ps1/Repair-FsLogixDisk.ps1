<#
.SYNOPSIS
    Performs a full repair and optimization sequence on a mounted FSLogix VHDX disk.

.DESCRIPTION
    This function runs a series of disk maintenance commands on a mounted FSLogix user disk.
    It checks for file system errors, cleans up metadata, defragments files, consolidates slabs,
    and performs TRIM operations to prepare the disk for optimal compaction.

.PARAMETER DriveLetter
    The drive letter assigned to the mounted VHDX disk.

.EXAMPLE
    Repair-FsLogixDisk -DriveLetter "Z"

.NOTES
    Author: Gijs van den Berg
    Version: 1.0
    Date: July 2025

    The order of operations is carefully chosen to maximize disk health and compaction efficiency:
    1. chkdsk /f /x /forceofflinefix /scan — Fixes file system errors and forces dismount.
    2. chkdsk /sdcleanup /x — Cleans up unused security descriptors.
    3. defrag /x — Full defragmentation to consolidate free space.
    4. defrag /k /l — Slab consolidation and TRIM to inform storage of unused blocks.
    5. defrag /x — Second pass to finalize consolidation.
    6. defrag /k — Final slab consolidation before Optimize-VHD.

    This sequence ensures the disk is in optimal condition before compaction.
#>
function Repair-FsLogixDisk {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DriveLetter
    )

    try {
        if (-not (Test-Path -Path "$DriveLetter`:\")) {
            throw "Drive $DriveLetter does not exist or is not accessible."
        }

        Write-Host "Attempting to repair disk at $DriveLetter..."
        chkdsk "$($DriveLetter):" /f /x /forceofflinefix /scan
        chkdsk "$($DriveLetter):" /sdcleanup /x
        defrag "$($DriveLetter):" /x
        defrag "$($DriveLetter):" /k /l
        defrag "$($DriveLetter):" /x
        defrag "$($DriveLetter):" /k

        Write-Host "Disk repair completed successfully for $DriveLetter."
    }
    catch [System.IO.IOException] {
        Write-Error "An I/O error occurred while repairing the disk: $_"
    }
    catch [System.UnauthorizedAccessException] {
        Write-Error "Access denied while trying to repair the disk: $_"
    }
    catch {
        Write-Error "An error occurred while repairing the disk: $_"
    }
}
