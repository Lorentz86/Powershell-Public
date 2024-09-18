<#
.SYNOPSIS
    Retrieves the status of a specified service and checks if it is running.

.DESCRIPTION
    This script takes the name of a service as input and retrieves its status. 
    If the service is not running, it returns the current status of the service.

.PARAMETER ServiceName
    The name of the service to check.

.EXAMPLE
    Get-ServiceStatus -ServiceName "wuauserv"
    This command checks the status of the Windows Update service.

.NOTES
    Author: Gijs van den Berg
    Date: 2024-08-29
#>

function Get-ServiceStatus {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage="What is the name of the service?")]
        [string]$ServiceName
    )

    try {
        # Get the service
        $Service = Get-Service -Name $ServiceName -ErrorAction Stop

        # Check the status
        if ($Service.Status -ne "Running") {
            Write-Output "The service '$ServiceName' is currently $($Service.Status)."
        } else {
            Write-Output "The service '$ServiceName' is running."
        }
    } catch {
        Write-Error "Failed to retrieve the status of the service '$ServiceName'. Please ensure the service name is correct."
    }
}
