<#
.SYNOPSIS
    Retrieves the first available drive letter (or all available letters) from C to Z,
    excluding those currently in use, assigned to CD-ROM drives, or specified manually.

.DESCRIPTION
    This function scans the system for used drive letters, including those assigned to partitions
    and CD-ROM drives. It also allows the user to specify additional letters to exclude.
    By default, it returns the first available drive letter, but can optionally return all available letters.

.PARAMETER AdditionalExclude
    An optional array of drive letters to exclude in addition to the default list (A–E).

.PARAMETER AllAvailable
    If specified, returns all available drive letters instead of just the first one.

.EXAMPLE
    Get-AvailableDriveLetter
    Returns the first available drive letter from C to Z, excluding A–E and CD-ROMs.

.EXAMPLE
    Get-AvailableDriveLetter -AdditionalExclude @('F', 'G') -AllAvailable
    Returns all available drive letters excluding A–G and CD-ROMs.

.NOTES
    Author: Gijs van den Berg
    Version: 1.1
    Date: July 2025
#>

function Get-AvailableDriveLetter {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidatePattern("^[A-Z]$")]
        [String[]]$AdditionalExclude = @(),

        [Parameter(Mandatory = $false)]
        [Switch]$AllAvailable
    )

    try {
        # Default exclusions
        $defaultExclude = @('A', 'B', 'C', 'D', 'E')

        # Get used drive letters from partitions
        $usedLetters = Get-Partition | Where-Object { $_.DriveLetter } | Select-Object -ExpandProperty DriveLetter

        # Get drive letters assigned to CD-ROM drives
        $cdromLetters = Get-CimInstance -ClassName Win32_CDROMDrive | ForEach-Object {
            ($_.Drive -split ':')[0]
        }

        # Combine all exclusions
        $excludedLetters = @($defaultExclude + $AdditionalExclude + $usedLetters + $cdromLetters) | Sort-Object -Unique

        # Candidate letters from C to Z
        $candidateLetters = [char[]](67..90) | ForEach-Object { [string]$_ }

        # Filter out excluded letters
        $availableLetters = $candidateLetters | Where-Object { $_ -notin $excludedLetters }

        if (-not $availableLetters) {
            throw "No available drive letters found."
        }

        if ($AllAvailable.IsPresent) {
            return $availableLetters
        } else {
            return $availableLetters[0]
        }

    }
    catch {
        Write-Error "An error occurred while retrieving available drive letters: $_"
        return $null
    }
}
