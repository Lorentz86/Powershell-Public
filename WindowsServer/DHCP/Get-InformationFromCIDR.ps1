<#
.SYNOPSIS
   Get-InformationFromCIDR function retrieves subnet information based on CIDR notation.

.DESCRIPTION
   This function takes a CIDR string as input and searches for corresponding subnet information
   in a predefined list. The list contains details such as Subnet Mask, Wildcard Mask, Total Free
   IP Addresses, and Total Usable IP Addresses.

.PARAMETER CIDR
   Specifies the CIDR notation for which subnet information is to be retrieved.

.NOTES
   File: Get-InformationFromCIDR.ps1
   Author: Gijs van den berg
   Version: 1.0
   Date: 26-01-2024

.EXAMPLE
   Get-InformationFromCIDR -CIDR "/24"
   Retrieves subnet information for the CIDR notation "/24".

.EXAMPLE
   Get-InformationFromCIDR -CIDR "/16"
   Retrieves subnet information for the CIDR notation "/16".

#>

function Get-InformationFromCIDR {
    [CmdletBinding()]
    param (
      [Parameter(Mandatory=$true, HelpMessage="Give the CIDR in the /24 notation")]
      [string]$CIDR
    )
    $Notations = @"
CIDR,SubnetMask,WildcardMask,TotalFreeIpAddress,TotalUsibleIpAddress
/32,255.255.255.255,0.0.0.0,1,1
/31,255.255.255.254,0.0.0.1,2,2
/30,255.255.255.252,0.0.0.3,4,2
/29,255.255.255.248,0.0.0.7,8,6
/28,255.255.255.240,0.0.0.15,16,14
/27,255.255.255.224,0.0.0.31,32,30
/26,255.255.255.192,0.0.0.63,64,62
/25,255.255.255.128,0.0.0.127,128,126
/24,255.255.255.0,0.0.0.255,256,254
/23,255.255.254.0,0.0.1.255,512,510
/22,255.255.252.0,0.0.3.255,1024,1022
/21,255.255.248.0,0.0.7.255,2048,2046
/20,255.255.240.0,0.0.15.255,4096,4094
/19,255.255.224.0,0.0.31.255,8192,819
/18,255.255.192.0,0.0.63.255,16384,16382
/17,255.255.128.0,0.0.127.255,32768,32766
/16,255.255.0.0,0.0.255.255,65536,65534
/15,255.254.0.0,0.1.255.255,131072,13107
/14,255.252.0.0,0.3.255.255,262144,262142
/13,255.248.0.0,0.7.255.255,524288,524286
/12,255.240.0.0,0.15.255.255,1048576,1048574
/11,255.224.0.0,0.31.255.255,2097152,2097150
/10,255.192.0.0,0.63.255.255,4194304,4194302
/9,255.128.0.0,0.127.255.255,8388608,8388606
/8,255.0.0.0,0.255.255.255,16777216,16777214
/7,254.0.0.0,1.255.255.255,33554432,33554430
/6,252.0.0.0,3.255.255.255,67108864,67108862
/5,248.0.0.0,7.255.255.255,134217728,134217726
/4,240.0.0.0,15.255.255.255,268435456,268435454
/3,224.0.0.0,31.255.255.255,536870912,536870910
/2,192.0.0.0,63.255.255.255,1073741824,1073741822
/1,128.0.0.0,127.255.255.255,2147483648,2147483646
/0,0.0.0.0,255.255.255.255,4294967296,4294967294
"@

    $Data = $Notations | ConvertFrom-Csv
    $list = [System.Collections.Generic.List[Object]]::new($data)

    try
    {
        $information = $list | Where-Object -Property CIDR -Match $CIDR
        return $information
    }
    catch
    {
            $ErrorMessage = $($_.Exception.Message)
            Write-Verbose $ErrorMessage 
            return $false        
    }
}