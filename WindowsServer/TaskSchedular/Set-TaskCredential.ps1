<#
.SYNOPSIS
    Updates the password for all scheduled tasks running under a specified user.

.DESCRIPTION
    This function updates the password for all scheduled tasks that are running under the specified user account.
    It uses the Task Scheduler cmdlets to find and update the tasks.

.EXAMPLE
    Set-TaskCredential

.NOTES
    Author: Your Name
    Date: 2024-11-04
#>

function Set-TaskCredential {
    try {
        # Prompt for the new credentials
        $TaskCredential = Get-Credential

        # Get all scheduled tasks for the specified user
        $Tasks = Get-ScheduledTask | Where-Object { $_.Principal.UserId -eq $TaskCredential.UserName }

        if ($Tasks.Count -eq 0) {
            Write-Output "No scheduled tasks found for user $($TaskCredential.UserName)."
            return
        }

        # Update each task with the new password
        $Tasks | ForEach-Object {
            try {
                $_ | Set-ScheduledTask -User $TaskCredential.UserName -Password $TaskCredential.GetNetworkCredential().Password
                Write-Output "Updated task: $($_.TaskName)"
            } catch {
                Write-Error "Failed to update task: $($_.TaskName). Error: $_"
            }
        }

        Write-Output "All tasks updated successfully."
    } catch {
        Write-Error "An error occurred while updating tasks. Error: $_"
    }
}
