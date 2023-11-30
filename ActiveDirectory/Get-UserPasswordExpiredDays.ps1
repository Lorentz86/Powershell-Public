Function Get-UserPasswordExpiredDays {
    [CmdletBinding()]
    <#
    .SYNOPSIS
       Get the number of days until a user's password expires in Active Directory.

    .DESCRIPTION
       This function retrieves the expiration time of a user's password in Active Directory
       and calculates the number of days until it expires.

    .PARAMETER Username
       Specifies the username for which to check the password expiration.

    .EXAMPLE
       Get-UserPasswordExpiredDays -Username "JohnDoe"

    .NOTES
       File: Get-UserPasswordExpiredDays.ps1
       Author: Your Name
       Version: 1.0
       Last Updated: [Date]
    #>
    param (
        [Parameter(Mandatory=$true, HelpMessage="The username")]
        [string]$Username
    )
    
    try {
        # Look if the User exists in AD.
        $userData = Get-ADUser -Identity $Username -Properties *, msDS-UserPasswordExpiryTimeComputed -ErrorAction Stop

        # Get the properties
        $ExpireDate = [datetime]::FromFileTime($userData.'msDS-UserPasswordExpiryTimeComputed')
        $currentDate = Get-Date

        # Calculate the time that's left
        $daysDifference = ($ExpireDate - $currentDate).Days

        # Return information
        return $daysDifference
    }
    catch {
        Write-Error "Error: $_"
        return $null
    }
}