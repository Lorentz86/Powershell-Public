<#
.SYNOPSIS
    Checks if a user's password was reset in the last 14 days.

.DESCRIPTION
    This function takes a username as input and returns a boolean indicating whether the user's password was reset in the last 7 days. It uses the Get-ADUser cmdlet to retrieve the user's PasswordLastSet property and calculates the time difference between the current date and the last password reset date.

.PARAMETER username
    The username of the user to check.

.EXAMPLE
    $result = Get-HasPasswordReset -username "jdoe"
    Write-Output "Password reset in the last 14 days: $result"
#>
function Get-HasPasswordReset {
    param (
        [string]$username
    )

    try {
        Write-Host "Starting password reset check for user: $username"

        # Get the user object
        $user = Get-ADUser -Identity $username -Properties PasswordLastSet
        Write-Host "Retrieved user object for: $username"

        if ($user -eq $null) {
            Write-Host "User not found: $username"
            return $false
        }

        # Calculate the time difference
        $passwordLastSet = $user.PasswordLastSet
        $timeDifference = (Get-Date) - $passwordLastSet
        Write-Host "Password last set on: $passwordLastSet"

        # Check if the password was reset in the last 7 days
        if ($timeDifference.TotalDays -le 14) {
            Write-Host "Password was reset in the last 14 days for user: $username"
            return $true
        } else {
            Write-Host "Password was not reset in the last 14 days for user: $username"
            return $false
        }
    }
    catch {
        Write-Host "An error occurred while checking password reset for user: $username. Error: $_"
        return $false
    }
}