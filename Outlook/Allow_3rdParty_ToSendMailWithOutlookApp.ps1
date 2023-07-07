# Script to enable Outlook Settings that other 3rd party apps can send a mail by outlook application. 
# This scripts Enables the folowing option: Outlook -> File -> Options -> Programmatic Access Security > Never Warn

$regPath = ".\SOFTWARE\Microsoft\Office\ClickToRun\REGISTRY\MACHINE\Software\Wow6432Node\Microsoft\Office\16.0\Outlook\Security"
# Optional to log because windows sometimes removes this key. To enable change loglocation and remove # before $Loglocation and $Event
#$LogLocation = "[fullpath].csv"

$Event = @()
Push-Location
Set-Location HKLM:

if(!(Test-Path -Path $regPath))
{
    New-Item -Path ".\SOFTWARE\Microsoft\Office\ClickToRun\REGISTRY\MACHINE\Software\Wow6432Node\Microsoft\Office\16.0\Outlook\Security"
    Set-ItemProperty -Path $regPath -Name "ObjectModelGuard" -Value 2
    if(Test-Path -Path $regPath)
    {
        $checkStatus = Get-ItemProperty -Path $regPath
        $Event = [PScustomObject]@{
            Date = Get-Date -Format "dd-MM-yyyy"
            Log = "Outlook Security Object not present in Registry"
            ChangeEvent = "Enabled ObjectModelGuard with value $($checkStatus.ObjectModelGuard)"
        }
        Pop-Location
        #$Event | Export-Csv -Path $LogLocation -Append -NoTypeInformation -Delimiter ";"
    }
    Else
    {
        $Event = [PScustomObject]@{
            Date = Get-Date -Format "dd-MM-yyyy"
            Log = "Outlook Security Object not present in Registry"
            ChangeEvent = "Failed to make a change"
        }
        Pop-Location
        #$Event | Export-Csv -Path $LogLocation -Append -NoTypeInformation -Delimiter ";"
    }  
}
else
{
    Write-Information -MessageData "Item $regpath already there"
}
