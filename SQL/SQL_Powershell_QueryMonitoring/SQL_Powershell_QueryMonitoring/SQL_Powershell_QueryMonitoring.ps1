#
# This script has been tested on Powershell 5.1
# This script needs PS module SqlServer
# Database should have WhoisActive installed. See http://whoisactive.com/ or install DBAtools and Install-DbaWhoIsActive -sqlinstance sqlserver -database databasename. See https://dbatools.io/. 
# The user you run this script should have permissions to run queries on the database. 
#

# PSmodule check
try {Import-module -name sqlserver -ErrorAction Stop | Out-Null 
$Module = Get-module -Name sqlserver -ErrorAction Stop
}
catch {Write-Warning "Could not find PS module sqlserver "}
if ($Module) {Write-Host "PSmodule is installed"}
Else {
	Get-Module -ListAvailable | Out-Null
	Install-Module -Name 'sqlserver' -ErrorAction Stop | Out-Null
	Import-Module -Name 'sqlserver' -ErrorAction Stop | Out-Null
}

# Triggers // should be the same as the Trigger.bat. Check the readme.

$locTrigger = "\\Examplesrv\Exampleloc\"
$Trigger = Get-Childitem -Path $locTrigger | Where-Object {$_.Name -eq "trigger.txt"}

if($Trigger){

# Filename
$filename = (Get-Date -Format ddMMyyyy) + 'SQLActive.txt'

# Location where Logfiles can be written to
$locLog = "\\Examplesrv\Exampleloc\$filename"

# SQL Server settings
$SQLparams = @{
ServerInstance = 'SQLsrv1' # SQL server
Database = 'ExampleDB' # Database Name
Query = 'sp_whoisactive' # SQL Query
}

# Timer
$timer = new-timespan -Minutes 1
$clock = [diagnostics.stopwatch]::StartNew()
Write-Host "Start-Timer"
while ($clock.elapsed -lt $timer){
$Output = Invoke-Sqlcmd @SQLparams

#Output of Files
If($Output){$Output | Out-File $locLog -Append}
Else {Write-Host "No active query"}
 
Start-Sleep -Seconds 5
}
Write-Host "Timer End"

# Cleaning up files
foreach($t in $Trigger){$t.FullName | Remove-Item}

}

Else {Write-Host "No trigger found"}

# End of script

