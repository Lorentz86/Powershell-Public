function Get-FolderAudit {
    <#
    .SYNOPSIS
        Retrieves audit events for a specified folder path from the Windows Security log.
    
    .DESCRIPTION
        The Get-FolderAudit function retrieves audit events related to a specified folder path from the Windows Security log. 
        It looks for event ID 4663 within the past hour, which corresponds to "An attempt was made to access an object."
    
    .PARAMETER Path
        The path of the folder to audit.
    
    .EXAMPLE
        Get-FolderAudit -Path "C:\Users\Public\Documents"
    
    .NOTES
        Requires administrative privileges to access the Security log.
    #>
    
    function Get-FolderAudit {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true, HelpMessage = "Path of audit location")]
            [string]$Path
        )
    
        if (-not (Test-Path -Path $Path)) {
            Write-Error "Path does not exist"
            return
        }
    
        try {
            $Events = Get-WinEvent -FilterHashtable @{
                LogName   = "Security"
                ID        = 4663
                StartTime = (Get-Date).AddHours(-1)
            } | Where-Object { $_.Message -like "*$Path*" }
    
            if ($Events) {
                return $Events
            } else {
                Write-Output "No audit events found for the specified path in the past hour."
            }
        } catch {
            Write-Error "An error occurred while retrieving audit events: $_"
        }
    }
    
    }