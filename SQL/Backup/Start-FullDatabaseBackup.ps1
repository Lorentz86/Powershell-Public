<#
.SYNOPSIS
    This script performs a full database backup of a specified SQL Server database.

.DESCRIPTION
    The function performs a full backup of a SQL Server database with compression.
    It logs the process verbosely, handles errors using try-catch, and verifies that the backup file is created.

.PARAMETER SQLServerInstance
    The name of the SQL Server instance.

.PARAMETER DatabaseName
    The name of the database to back up.

.PARAMETER Path
    The local path where the backup file will be stored.

.PARAMETER Log
    Enable logging (true/false).

.EXAMPLE
    Start-FullDatabaseBackup -SQLServerInstance "localhost\SQL2019" -DatabaseName "TestDB" -Path "C:\Backups\" -Log $true
#>

function Start-FullDatabaseBackup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage="Name of the SQL Server instance")]  
        [string] $SQLServerInstance,

        [Parameter(Mandatory=$true, HelpMessage="Name of the Database")]  
        [string] $DatabaseName,

        [Parameter(Mandatory=$true, HelpMessage="Local path of the backup")]
        [ValidateScript({(Test-Path $_) -and (Get-Item $_).PSIsContainer})]
        [string] $Path,

        [Parameter(Mandatory=$true, HelpMessage="Enable Logging")]  
        [ValidateSet($true, $false)]
        [bool] $Log
    )

    # Enable verbose output
    $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent = $true

    try {
        if ($Log) {
            $logFile = Join-Path -Path $Path -ChildPath "BackupLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
            Start-Transcript -Path $logFile -Append
        }

        $backupFilePath = Join-Path -Path $Path -ChildPath "$DatabaseName.bak"
        
        Write-Verbose "Starting backup for database '$DatabaseName' on server '$SQLServerInstance'."
        Write-Verbose "Backup file will be stored at '$backupFilePath'."

        $backupQuery = @"
BACKUP DATABASE [$DatabaseName]
TO DISK = N'$backupFilePath'
WITH NOFORMAT, NOINIT,
NAME = N'$DatabaseName-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
"@

        # Execute the backup query
        Invoke-Sqlcmd -ServerInstance $SQLServerInstance -Query $backupQuery -QueryTimeout 1800
        
        # Check if the backup file was created
        if (Test-Path -Path $backupFilePath) {
            Write-Host "Backup of database '$DatabaseName' completed successfully. Backup file located at: $backupFilePath" -ForegroundColor Green
        } else {
            Write-Error "Backup of database '$DatabaseName' failed. Backup file was not created."
        }

    } catch [System.Exception] {
        Write-Error "An error occurred: $_.Exception.Message"
        Write-Verbose $_.Exception.StackTrace
    } finally {
        if ($Log) {
            Stop-Transcript
        }
    }
}
