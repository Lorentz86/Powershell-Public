# Script to sync Sharepoint document libraries faster. The Default for this setting is about 8 hours. 

$Path = "HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1"
$Name = "Timerautomount"
$Type = "QWORD"
$Value = 1

Try {
    $Registry = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop | Select-Object -ExpandProperty $Name
    If ($Registry -eq $Value){
        Write-Output "Timer Automount is zero"
        Exit 0
    } 
    Else
    {
        Set-ItemProperty -Path $Path -Name $Name -Type $Type -Value $Value 
        Write-Output "Timer Automount Set to zero, please logout/reboot."
    }
} 
Catch {
    Write-Warning "Another Issue Occured"
    Exit 1
}