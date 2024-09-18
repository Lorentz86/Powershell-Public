<#
.SYNOPSIS
Uploads files to Azure Blob Storage using AzCopy.

.DESCRIPTION
This script uploads files or directories to Azure Blob Storage using AzCopy. It can also download and update AzCopy if needed.

.PARAMETER StorageAccount
The name of the Azure Storage account.

.PARAMETER Container
The container or directory in Azure Blob Storage where the files need to be uploaded.

.PARAMETER Sastoken
The SAS token for the Azure Storage account.

.PARAMETER Path
The full path of the file or directory to be uploaded.

.PARAMETER Update
Optional. Indicates whether to download a newer version of AzCopy.

.EXAMPLE
Upload-ToAzureBlob -StorageAccount "mystorageaccount" -Container "mycontainer" -Sastoken "mysastoken" -Path "C:\myfile.txt"
#>

function Upload-ToAzureBlob {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, HelpMessage="Storage account name")]
        [string]$StorageAccount,
        
        [Parameter(Mandatory=$true, HelpMessage="Container or directory where the files need to be uploaded to")]
        [string]$Container,
    
        [Parameter(Mandatory=$true, HelpMessage="The File Service SAS Token")]
        [string]$Sastoken,
        
        [Parameter(Mandatory=$true, HelpMessage="Full path of the file or directory")]
        [string]$Path,
    
        [Parameter(Mandatory=$false, HelpMessage="Download a newer version of the AzCopyTool")]
        [ValidateSet($true,$false)]  
        [System.Boolean] $Update = $false
    )

    # Download and Update Part
    Write-Output "Loading AzCopy URL"
    $AZCopyUrl = "https://aka.ms/downloadazcopy-v10-windows"
    $FileName = "Azcopy"

    $AzCopyDir = "$($env:LOCALAPPDATA)\$Filename"
    Write-Output ("Checking if AzCopy directory {0} is available" -f $AzCopyDir)

    $AzCopyFile = $AzCopyDir + ".zip"

    try {
        if (!(Test-path $AzCopyDir)) {
            Write-Output ("No AzCopy detected at {0}, downloading zip to {1}" -f $AzCopyDir, $AzCopyFile)
            Invoke-WebRequest -Uri $AZCopyUrl -OutFile $AzCopyFile
            Write-Output ("Unzipping to {0}" -f $AzCopyDir)
            Write-Output ("File present: {0}" -f $(Test-path $AzCopyFile))
            Expand-Archive $AzCopyFile -DestinationPath $AzCopyDir -Force
            $AzCopyZip = Get-ChildItem -Path $AzCopyDir
            if ($AzCopyZip.name.Contains("azcopy_windows")) {
                Write-Output ("The current version is {0}" -f $AzCopyZip.Name)
            } else {
                Write-Output ("File download or extraction failed. Download AzCopy manually from {0} and extract the zip to {1}" -f $AZCopyUrl, $AzCopyDir)
                Write-Output ("After unzipping the file, run the script again. Press any key to quit")
                $null = Read-Host
                exit
            }
        }
    } catch {
        Write-Output ("An error occurred during AzCopy download or extraction: {0}" -f $_.Exception.Message)
        exit
    }

    if ($Update) {
        try {
            Write-Output ("Updating AzCopy")
            $OldFile = Get-ChildItem -Path $AzCopyDir | Where-Object -Property Name -like "azcopy*"
            Write-Output ("Loading old version")

            $OldVersion = $OldFile.Name.split("_") | Select-Object -Last        
            Invoke-WebRequest -Uri $AZCopyUrl -OutFile $AzCopyFile
            Expand-Archive $AzCopyFile -DestinationPath $AzCopyDir -Force
            $NewFiles = Get-ChildItem -Path $AzCopyDir | Where-Object -Property Name -like "azcopy*" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
            if (Test-Path $NewFile) {
                Remove-Item $OldFile -Force
            }
        } catch {
            Write-Output ("An error occurred during AzCopy update: {0}" -f $_.Exception.Message)
            exit
        }
    }

    # Check if the filepath exists for uploading the file. 
    try {
        if (Test-Path -Path $Path) {
            $UploadFiles = Get-ChildItem -Path $Path 
            Write-Output ("The following item(s) will be uploaded:")
            Write-Output ($UploadFiles.FullName)
        } else {
            Write-Output ("The requested file {0} is not present" -f $Path)
            Write-Output ("Please provide the full path of the file, e.g., C:\PathtoFile")
            Write-Output ("Press any key to quit:")
            $null = Read-Host
            Exit
        }
    } catch {
        Write-Output ("An error occurred while checking the file path: {0}" -f $_.Exception.Message)
        exit
    }

    # Determining AzCopyLocation
    try {
        $AzCopyFileLocation = Get-ChildItem -Path $AzCopyDir
        $env:Path += ";" + $AzCopyFileLocation
        $env:AzCopyDir = $AzCopyFileLocation
        if (!(Test-path "$env:AzCopyDir\azcopy.exe")) {
            throw "AzCopy executable not found in $env:AzCopyDir"
        }
    } catch {
        Write-Output ("An error occurred while determining AzCopy location: {0}" -f $_.Exception.Message)
        exit
    }

    # Start of File upload
    try {
        $FileName = $Path | Split-Path -Leaf
        Write-Output ("Transferring {0} to Azure" -f $Path)
        $AzureUrl = "https://" + $StorageAccount + ".file.core.windows.net/" + $Container + "/" + $FileName + "?" + $Sastoken 
        
        $FileUpload = azcopy copy $Path $AzureUrl --recursive=true
        Write-Output $FileUpload
    } catch {
        Write-Output ("An error occurred during file upload: {0}" -f $_.Exception.Message)
    }
}