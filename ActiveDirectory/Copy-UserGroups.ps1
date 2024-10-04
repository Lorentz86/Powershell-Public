<#
.SYNOPSIS
    Copies group memberships from one user to another.

.DESCRIPTION
    This script retrieves the group memberships of a source user and adds the destination user to those groups.

.PARAMETER SourceUser
    The username of the source user whose group memberships will be copied.

.PARAMETER DestinationUser
    The username of the destination user who will be added to the groups.

.EXAMPLE
    .\Copy-UserGroups.ps1 -SourceUser "sourceUser" -DestinationUser "destinationUser"

.NOTES
    Author: Your Name
    Date: 2024-10-04
#>

function Copy-UserGroups {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceUser,

        [Parameter(Mandatory = $true)]
        [string]$DestinationUser
    )

    try {
        # Retrieve the groups of the source user
        $sourceGroups = Get-ADUser -Identity $SourceUser -Property MemberOf | Select-Object -ExpandProperty MemberOf

        if ($null -eq $sourceGroups) {
            Write-Error "No groups found for the source user."
            return
        }

        # Add the destination user to each group
        foreach ($group in $sourceGroups) {
            try {
                Add-ADGroupMember -Identity $group -Members $DestinationUser
                Write-Output "Added $DestinationUser to $group"
            } catch {
                Write-Error "Failed to add $DestinationUser to $group. Error: $_"
            }
        }
    } catch {
        Write-Error "An error occurred while retrieving groups for $SourceUser. Error: $_"
    }
}
