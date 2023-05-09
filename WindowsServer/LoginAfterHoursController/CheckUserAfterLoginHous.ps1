# This script is to check if there are user logins after working hours. If there is suspicious login activity you will be notified.
# Powershell 5.1
#

# Logname and ID of events
$RemoteConnectionLogname = "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational"
$RemoteLoginId = 1149 


$LocalConnectionLogname = "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational"
$LocalLoginID = 25
$LocalLogoutID = 24


$LastHour = (Get-date).AddHours(-1)
$Events = Get-WinEvent -logname $RemoteConnectionLogname | ? TimeCreated -GT $LastHour | ? id -eq $RemoteLoginId

Funtion Get-LocalLoginEventLogs()
{
    
}