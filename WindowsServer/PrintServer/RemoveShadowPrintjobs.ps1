# Script to remove shadow print jobs
try {
    $ShadowJobs = Get-ChildItem -Path "C:\Windows\System32\spool\PRINTERS"
    if($ShadowJobs.count -gt 0){
        Write-Host "Found $($ShadowJobs.count) shadow print jobs. Removing them now..."
        # Stop the Spooler service to remove shadow print jobs  
        Stop-Service -Name "Spooler" -Force -ErrorAction Stop
        $SpoolerService = Get-Service -Name "Spooler"
        if($SpoolerService.Status -eq 'Stopped'){
            Write-Host "Spooler service stopped successfully."
            # Remove shadow print jobs
            foreach ($job in $ShadowJobs) {
                Write-Host "Removing shadow print job: $($job.FullName)"
                # Use Remove-Item to delete the shadow print job files
                Remove-Item -Path $job.FullName -Force
            }
        }
    }
    else {
        Write-Host "No shadow print jobs found."
    }
    # Restart the Spooler service
    Start-Service -Name "Spooler" -ErrorAction Stop
    Write-Host "Spooler service restarted successfully."
    

}
catch {
    Write-Error "An error occurred while removing shadow print jobs: $_"
}
