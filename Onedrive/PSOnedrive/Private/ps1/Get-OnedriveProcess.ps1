function Get-OnedriveProcess {
    <#
    .SYNOPSIS
        Retrieves the OneDrive process information.
    
    .DESCRIPTION
        This function checks for the OneDrive process and returns its details if found.
    
    .EXAMPLE
        Get-OnedriveProcess
        Returns the OneDrive process information if it is running.
    
    .NOTES
        Author: Gijs van den Berg
        Version: 1.0
        Date: July 2025
#>
    try {
        return Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Select-Object -Property Id, Name, Path
    }
    catch {
        Write-Error "An error occurred while retrieving OneDrive process information: $_"
    }
}
