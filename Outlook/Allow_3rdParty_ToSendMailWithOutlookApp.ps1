# Script to enable Outlook Settings that other 3rd party apps can send a mail by outlook application. 
# This scripts Enables the folowing option: Outlook -> File -> Options -> Programmatic Access Security > Never Warn

$regPath = ".\SOFTWARE\Microsoft\Office\ClickToRun\REGISTRY\MACHINE\Software\Wow6432Node\Microsoft\Office\16.0\Outlook\Security"
# Optional to log because windows removes this key from time to time. 
# To enable logging remove # down below before $Loglocation enter fullpath of where you want the log to go and remove <# at line 19
#$LogLocation = "[fullpath].csv"

$Event = @()
Push-Location
Set-Location HKLM:
 
if(!(Test-Path -Path $regPath)) # This will check if the key exists and reverts the output ($True becomes $False)
{
    New-Item -Path ".\SOFTWARE\Microsoft\Office\ClickToRun\REGISTRY\MACHINE\Software\Wow6432Node\Microsoft\Office\16.0\Outlook\Security"
    Set-ItemProperty -Path $regPath -Name "ObjectModelGuard" -Value 2

    # This part is for logging purposes remove <# down below if logging is enabled
    <#
    if(Test-Path -Path $regPath) 
    {
        $checkStatus = Get-ItemProperty -Path $regPath
        $Event = [PScustomObject]@{
            Date = Get-Date -Format "dd-MM-yyyy"
            Log = "Outlook Security Object not present in Registry"
            ChangeEvent = "Enabled ObjectModelGuard with value $($checkStatus.ObjectModelGuard)"
        }
        Pop-Location
        $Event | Export-Csv -Path $LogLocation -Append -NoTypeInformation -Delimiter ";"
    }
    Else
    {
        $Event = [PScustomObject]@{
            Date = Get-Date -Format "dd-MM-yyyy"
            Log = "Outlook Security Object not present in Registry"
            ChangeEvent = "Failed to make a change"
        }
        Pop-Location
        $Event | Export-Csv -Path $LogLocation -Append -NoTypeInformation -Delimiter ";"
    }  
    #>
}
else
{
    Write-Information -MessageData "Item $regpath already there"
}
