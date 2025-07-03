function Get-RDSUserSession{
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Checks if a user is logged in on an RDS (Remote Desktop Services) server by examining active user sessions.

    .DESCRIPTION
    This script function helps you determine if a user with a specified username is currently logged in on an RDS server managed by a Connection Broker. It checks for the presence of an active user session with the specified username.

    .PARAMETER Username
    Specifies the username of the person whose login status is to be checked.

    .PARAMETER ConnectionBroker
    Specifies the server that acts as the Connection Broker for the RDS environment.

    .NOTES
    - Ensure that the "RemoteDesktop" module is available for this script to work correctly.
    - Use this function to determine if a user is actively using an RDS session.

    .EXAMPLE
    Test-RDSUserSession -Username "JohnDoe" -ConnectionBroker "RDSCB01"

    This example checks if the user "JohnDoe" is currently logged in on an RDS server managed by the Connection Broker "RDSCB01."

    #>
    param(
        [Parameter(Mandatory=$true, HelpMessage="The username of the person to check if he / she is logged in on an RDS")]
        [ValidateNotNullOrEmpty()]
        [string]$Username,

        [Parameter(Mandatory=$true, HelpMessage="The server that acts as the Connection Broker for the RDS environment")]
        [ValidateNotNullOrEmpty()]
        [string]$ConnectionBroker
    )

    # Load the PSmododule  
    # Specify the name of the module you want to check
    $moduleName = "RemoteDesktop"

    # Check if the module is already imported
    if (Get-Module -Name $moduleName -ListAvailable -ErrorAction SilentlyContinue) {
        Write-Information -MessageData "$moduleName module is already imported."
    }
    else {
        # Attempt to install and import the module
        try {
            Write-Host -MessageData "Attempting to install and import $moduleName module..."
            Install-Module -Name $moduleName -Force -Scope CurrentUser -AllowClobber -ErrorAction Stop
            Import-Module -Name $moduleName -ErrorAction Stop
            Write-Host -MessageData "$moduleName module has been successfully installed and imported."
        }
        catch {
            Write-Host "Error: Failed to install and import $moduleName module."
            Write-Host "Press 'q' to quit or any other key to continue..."
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            if ($key.Character -eq 'q') {
                Write-Host "Exiting script."
                exit 1
            }
        }
    }

    try {
        $AllUsers = Get-RDUserSession -ConnectionBroker $ConnectionBroker
        if($AllUsers.username -contains $Username){return $true}
        else{return $false}
    }
    catch {
        Write-Error "An error occurred while retrieving user sessions: $($_.Exception.Message)"
        return $false
    }
}