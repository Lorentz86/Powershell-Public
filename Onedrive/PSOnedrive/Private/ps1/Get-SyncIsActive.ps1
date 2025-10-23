function Get-SyncIsActive {
    <#
    .SYNOPSIS
        Checks if the OneDrive sync process is active.
    
    .DESCRIPTION
        This function checks if the OneDrive sync process is currently running and returns a boolean value.
    
    .EXAMPLE
        Get-SyncIsActive
        Returns: True if OneDrive sync is active, otherwise False.
    
    .NOTES
        Author: Gijs van den Berg
        Version: 1.0
        Date: July 2025
#>
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]$OnedrivePaths
    )
    $FilesInUse = 0
    
    try {
        foreach ($path in $OnedrivePaths) {
            if (-not (Test-Path -Path $path)) {
                Write-Error "OneDrive path does not exist: $path"
                return $false
            }
            $RecentFiles = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue |  Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-2) }
            $FilesInUse += $RecentFiles.Count
        }
        return $FilesInUse -gt 0

    }
    catch {
        Write-Error "An error occurred while checking OneDrive sync status: $_"
        return $false
    }
}
