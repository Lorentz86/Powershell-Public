<#
.SYNOPSIS
    This script performs a transaction log backup of a specified SQL Server database.

.DESCRIPTION
    The function performs a transaction log backup of a SQL Server database with compression.
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
    Start-TransactionLogBackup -SQLServerInstance "localhost\SQL2019" -DatabaseName "TestDB" -Path "C:\Backups\" -Log $true
#>

function Start-TransactionLogBackup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage="Name of the SQL Server instance")]  
        [string] $SQLServerInstance,

        [Parameter(Mandatory=$true, HelpMessage="Name of the Database")]  
        [string] $DatabaseName,

        [Parameter(Mandatory=$true, HelpMessage="Local path of the backup")]
        [ValidateScript({Test-Path $_ -and (Get-Item $_).PSIsContainer})]
        [string] $Path,

        [Parameter(Mandatory=$true, HelpMessage="Enable Logging")]  
        [ValidateSet($true, $false)]
        [bool] $Log
    )

    # Enable verbose output
    $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent = $true

    try {
        if ($Log) {
            $logFile = Join-Path -Path $Path -ChildPath "TransactionLogBackupLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
            Start-Transcript -Path $logFile -Append
        }

        $backupFilePath = Join-Path -Path $Path -ChildPath "$DatabaseName_TransactionLog.trn"
        
        Write-Verbose "Starting transaction log backup for database '$DatabaseName' on server '$SQLServerInstance'."
        Write-Verbose "Backup file will be stored at '$backupFilePath'."

        $backupQuery = @"
BACKUP LOG [$DatabaseName]
TO DISK = N'$backupFilePath'
WITH NOFORMAT, NOINIT,
NAME = N'$DatabaseName-Transaction Log Backup', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
"@

        # Execute the backup query
        Invoke-Sqlcmd -ServerInstance $SQLServerInstance -Query $backupQuery -QueryTimeout 1800
        
        # Check if the backup file was created
        if (Test-Path -Path $backupFilePath) {
            Write-Host "Transaction log backup of database '$DatabaseName' completed successfully. Backup file located at: $backupFilePath" -ForegroundColor Green
        } else {
            Write-Error "Transaction log backup of database '$DatabaseName' failed. Backup file was not created."
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
