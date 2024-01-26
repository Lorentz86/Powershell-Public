<#
.SYNOPSIS
   Get-IP function retrieves DHCP lease information for a client based on MAC address.

.DESCRIPTION
   This function takes a MAC address, optional CIDR subnet mask, and computer name as input
   parameters. It checks for the presence of the DHCP module, formats the MAC address, and
   retrieves DHCP lease information for the client within the specified subnet.

.PARAMETER MacAddress
   Specifies the MAC address (full or partial) for which DHCP lease information is to be retrieved.

.PARAMETER CIDR
   Specifies the subnet mask in CIDR notation (e.g., '/24' for 255.255.255.0). Default is '/22'.

.NOTES
   File: Get-IP.ps1
   Author: Gijs van den Berg
   Version: 1.0
   Date: 26-01-2024

.EXAMPLE
   Get-IP -MacAddress "00:11:22:33:44:55" -CIDR "/24"
   Retrieves DHCP lease information for the specified MAC address within the '/24' subnet.

.EXAMPLE
   Get-IP -MacAddress "00-11-22-33-44-55"
   Retrieves DHCP lease information for the specified MAC address within the default '/22' subnet.

#>

function Get-IP 
{
    param(
        [Parameter(Mandatory=$true, HelpMessage="Give the full of a partmac adress")]
        [string]$MacAddress,

        [Parameter(Mandatory=$false, HelpMessage="Give the subnestmask in CIDR notation like  '/24' when the subnet is 255.255.255.0")]
        [string]$CIDR = "/22"

    )
    Import-Module "" #Import the Get-InformationfromCIDR.ps1

    # Check if DHCP module is installed. 
    try
    {
        $Module = Get-Module -name DhcpServer
        if(!$Module)
        {
            $Detail =  "No DHCP Module installed, please run this script from a Windows Server with DHCP module installed."
            return $Detail    
        }
    }
    catch
    {
            $Detail =  "No DHCP Module installed, please run this script from a Windows Server with DHCP module installed."
            $ErrorMessage = $($_.Exception.Message)
            Write-Verbose $ErrorMessage 
            return $Detail,$ErrorMessage  
    }

    # Formatting the Mac Adress
    if($MacAddress -match ":")
    {
        Write-Host "Mac Address contains :, getting replaced by -"
        $MacAddress = $MacAddress -replace ":","-"
    }
    if($MacAddress -notmatch "-") 
    {
        Write-Host "Mac Address doesn't contain -, adding -"
        $MacAddress = $MacAddress -split '(..)' -ne '' -join '-'
    }
    
    # Get the correct subnet using the custom function
    $SubnetMask = Get-InformationFromCIDR -CIDR $CIDR | Select-Object -ExpandProperty Subnetmask


    # Choosing the scope based on the subnet
    $Scopes = Get-DhcpServerv4Scope | Where-Object -Property SubnetMask -Match $SubnetMask |Select-Object -Property ScopeID,Name

    # Looking for the mac
    try
    {
        foreach ($Scope in $Scopes)
        {
            $ClientInformation = Get-DhcpServerv4Lease -ScopeId $Scope.ScopeID | Where-Object -Property ClientID -Like $MacAddress
            if($ClientInformation)
            {
                return $ClientInformation
            }
            else
            {
                return "Could not for an Ip adress in $scope"
            }
        }
    }
    catch
    {
            $ErrorMessage = $($_.Exception.Message)
            Write-Verbose $ErrorMessage 
            return $false
    }
   
}
