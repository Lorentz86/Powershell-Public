<#
.SYNOPSIS
    Requires a user to reset their password on next login.

.DESCRIPTION
    This function takes a username as input and sets the "User must change password at next logon" flag for that user in Active Directory.

.PARAMETER username
    The username of the user who needs to reset their password on next login.

.EXAMPLE
    Set-PasswordResetOnNextLogin -username "jdoe"
#>
function Set-PasswordResetOnNextLogin {
    param (
        [string]$username
    )

    try {
        Write-Host "Starting process to require password reset on next login for user: $username"

        # Get the user object
        $user = Get-ADUser -Identity $username
        Write-Host "Retrieved user object for: $username"

        if ($user -eq $null) {
            Write-Host "User not found: $username"
            return
        }

        # Set the "User must change password at next logon" flag
        Set-ADUser -Identity $username -ChangePasswordAtLogon $true
        Write-Host "Password reset on next login has been set for user: $username"
    }
    catch {
        Write-Host "An error occurred while setting password reset on next login for user: $username. Error: $_"
    }
}

