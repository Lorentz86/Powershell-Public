# Import the following Powershell Modules. 
# PnP.PowerShell
# AzureAD

$AdGroups = Import-Csv -Path $(Get-Childitem *.csv)

for($i=0; $i -lt $AdGroups.count; $i++)
{
    if(($AdGroups[$i].DirectoryFullName -eq "") -and ($AdGroups[$i].DirectoryDisplayName -match " "))
    {
        $AdGroups[$i].DirectoryFullName = $AdGroups[$i].DirectoryDisplayName -replace " ","-"
    }
    elseif ($AdGroups[$i].DirectoryFullName -eq "") 
    {
        $AdGroups[$i].DirectoryFullName = $AdGroups[$i].DirectoryDisplayName
    }
}

$cred = Get-Credential
$SPurl = "https://examplecomapny.sharepoint.com/sites/"
Connect-AzureAD -Credential $cred

foreach($Group in $AdGroups.DirectoryFullName)
{
    $SPsiteurl = $SPurl + $Group
    Connect-PnPOnline -Url $SPsiteurl -Credentials $cred
    $GetSiteGroups = Get-PnPSiteGroup
    
    foreach($sitegroup in $GetSiteGroups)
    {
        if($sitegroup.LoginName -match "Eigenaars") 
        {
            $ADstring = "SHP-"+$group + "-Beheer"
            $ADGroup = Get-AzureADGroup -SearchString $ADstring
            Write-Host("$($sitegroup.Loginname) matches $($ADGroup.DisplayName)")
        }
        elseif($sitegroup.LoginName -match "Leden") 
        {
            $ADstring = "SHP-"+$group + "-Leden"
            $ADGroup = Get-AzureADGroup -SearchString $ADstring
            Write-Host("$($sitegroup.Loginname)) matches $($ADGroup.DisplayName)")
        }
        elseif($sitegroup.LoginName -match "Bezoekers") 
        {
            $ADstring = "SHP-"+$group + "-Bezoeker"
            $ADGroup = Get-AzureADGroup -SearchString $ADstring
            Write-Host("$($sitegroup.Loginname)) matches $($ADGroup.DisplayName)")
        }
    }
    Disconnect-PnPOnline
}