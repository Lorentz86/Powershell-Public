# You need Powershell AD module. 
# Make a template group in the correct UI in AD. 

$AdGroups = Import-Csv -Path $(Get-Childitem *.csv)
$TemplateName = "SHP-Template"
$OU = (Get-ADGroup $TemplateName -Properties Description).DistinguishedName -replace "CN=$TemplateName,",""
$OU = $OU -replace "CN=$TemplateName,",""

$SharePointGroups = @("Beheer","Leden","Bezoeker")

foreach($SPGroup in $SharePointGroups)
{
    foreach($AdGroup in $AdGroups)
    {
        if($AdGroup.DirectoryFullName -ne "") {$AdGroupName = $AdGroup.DirectoryFullName}
        elseif (($AdGroup.DirectoryFullName -eq "") -and ($AdGroup.DirectoryDisplayName -match " ")){$AdGroupName = $AdGroup.DirectoryDisplayName -replace " ","-"}
        else {$AdGroupName = $AdGroup.DirectoryDisplayName}
        Write-Host("SHP-$AdGroupName-$SPGroup")
        New-ADGroup -Name "SHP-$AdGroupName-$SPGroup" -SamAccountName "SHP-$AdGroupName-$SPGroup" -GroupScope Global -Verbose -Path $OU
    }
}
