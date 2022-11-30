# This script can be used for Onedrive Migration. 

# Location of OneDrive Migration Folder
$OneDriveMigrationFolder = "\\servername\OnedriveMigration$"
$OneDriveMigrationLogFolder = $OneDriveMigrationFolder + "\" + "Log"
$Username = [System.Environment]::UserName

#User migration Folder
$Foldername = "Onedrive_" + $Username.ToString()
$UserMigrationFolder = $OneDriveMigrationFolder + "\" + $Foldername

#Exclude folders and items. Remove or add as you see fit
$ExcludedFolders = @("AppData","Application Data","OneDrive","Downloads","Links","Saved Games","Searches","Videos","Music","Windows")
$ExcludeItems = @('$Recycle.Bin')
$ExcludeHomeFolderDirictories = @("Documents","Desktop","Contacts","Favorites","TMS_TEST","cdn.odc.officeapps.live.com","AppData","Bureaublad","Contactpersonen","Documenten","Favorieten","TMS","WINDOWS")

# Make a Folder for the user if it doesn't exist yet. 
if(Get-ChildItem -Path $OneDriveMigrationFolder | Where-Object -Property Name -EQ $Foldername) {Write-Host("OneDriveMigration file found.")}
else 
{
    Write-Host("OneDriveMigration has not been found")
    New-Item -ItemType Directory -Name $Foldername -Path $OneDriveMigrationFolder
}

# Scanning multiple folders. This creates an Array. 
$UserFolders = Get-ChildItem C:\Users\$Username | Where-Object Name -NotIn $ExcludedFolders

# If its only 1 folder cast it to an array so you can add it to the Folderlist. Replace H:\ for the driveletter your Homefolder has. 
[array]$HomeDirectories = Get-ChildItem H:\ -Directory| Where-Object Name -NotIn $ExcludeHomeFolderDirictories

#Loose Items No Folders. Replace H:\ for the driveletter your Homefolder has. 
[array]$HomeFiles = Get-ChildItem H:\ -File

# Making a list of Folders. 
$DirectoryList = New-Object System.Collections.Generic.List[array]

# Making a list of items
$ItemsList = New-Object System.Collections.Generic.List[array]

# Adding Folders to the List
$DirectoryList.Add($UserFolders)
$DirectoryList.Add($HomeDirectories)

# Adding Folders with Items only in the list
$ItemsList.Add($HomeFiles)

#Function to Write to a txt log file. SO you can see what items are giving you trouble. 
function Write-CopyLog 
{
    param
    (
        [string[]]$Logmessage
    )
    if (!(Test-Path -Path $OneDriveMigrationLogFolder)) {New-Item -ItemType Directory -Path $OneDriveMigrationLogFolder}
    $UserLogFile = $OneDriveMigrationLogFolder + "\" + $Username + "_" + $(Get-Date -Format yyyyMMdd) + ".txt"
    if (!(Test-Path -path $UserLogFile)) {New-Item -ItemType File -Path $UserLogFile}
    $message = "`n$($Username) - $($Logmessage)"
    Add-Content -Path $UserLogFile -Value $message
}

# Loop throught all Directories
Foreach ($DirLib in $DirectoryList)
{
    # Copy Folders that havent been copied yet. 
    Foreach($UserFolder in $DirLib)
    {
        $Foldername = $UserMigrationFolder + "\" + $UserFolder.Name.ToString()
        
        # Test if the folder has been made in the migration map, if not copy map and contents to the migration folder.
        if(!(Test-Path $Foldername))
        {
            try 
            {
                Copy-Item -Path $UserFolder.FullName -Destination $UserMigrationFolder -Recurse
            }
            catch
            {
                Write-CopyLog -Logmessage "$($UserFolder.FullName) could not be copied"
            }
        }
        Else
        {
            # It can happen that the Destination folder is empty and gives errors to the compare object. This line will solve that issue. 
            if(((Get-ChildItem -Recurse $UserFolder.FullName -Exclude "*RECYCLE.BIN*").count -gt 0) -and ((Get-ChildItem -Path $UserMigrationFolder).count -eq 0))
            {
                try 
                {
                    Get-ChildItem -Recurse $UserFolder.FullName | Where-Object Name -NotIn $ExcludeItems  | Copy-Item -Destination $Foldername
                }

                catch 
                {
                    Write-CopyLog -Logmessage "One or more items from $($UserFolder.FullName) could not be copied"
                }
            }

            # Compares Items in Homefolders with Destination. 
            Else
            {
                try 
                {
                $Original = Get-ChildItem -Recurse $UserFolder.FullName | Where-Object Name -NotIn $ExcludeItems
                $Destination = Get-ChildItem -Recurse $Foldername | Where-Object Name -NotIn $ExcludeItems

                $FileDiffs = Compare-Object -ReferenceObject $Original -DifferenceObject $Destination
                }
                catch {
                    Write-Host("No new files found")
                }
                

                foreach ($FileDiff in $FileDiffs)
                {
                    if($FileDiff.SideIndicator -eq "<=")
                    {
                        try
                        {
                            Copy-Item -Path $FileDiff.InputObject.Fullname -Destination $Foldername -ErrorAction SilentlyContinue
                        }

                        catch
                        {
                            Write-CopyLog -Logmessage "$($FileDiff.InputObject.Fullname) could not be copied" 
                        }
                    }
                    elseif($FileDiff.SideIndicator -eq "=>")
                    {
                        try
                        {
                            Remove-Item -Path -Recurse $FileDiff.InputObject.Fullname -Force -ErrorAction SilentlyContinue
                        }
                        
                        catch
                        {
                            Write-CopyLog -Logmessage "$($FileDiff.InputObject.Fullname) could not be copied"
                        }
                    }
                }
            }
        }
    }
}

# Loop through all Files
foreach ($itemarray in $ItemsList)
{
    #Check if files are already there
    try 
    {
        # Compare object gives an error if there are not files present in the destination folder. This line solves that error.
        if((Get-ChildItem -Path $UserMigrationFolder -File).count -eq 0)
        {
            Foreach($item in $itemarray)
            {
                try
                {
                    Copy-Item -Path $item.fullname -Destination $UserMigrationFolder
                }
                catch
                {
                    Write-CopyLog -Logmessage "$($item.fullname) could not be copied"
                }
            }
        }
        Else
        {
            try
            {
                $DestinationFiles = Get-ChildItem -Path $UserMigrationFolder -File
                $ItemDiffs = Compare-Object -ReferenceObject $itemarray -DifferenceObject $DestinationFiles

                foreach ($ItemDiff in $ItemDiffs)
                {
                    if($ItemDiff.SideIndicator -eq "<=")
                    {
                        try
                        {
                            Copy-Item -Path $FileDiff.InputObject.Fullname -Destination $Foldername -ErrorAction SilentlyContinue
                        }

                        catch
                        {
                            Write-CopyLog -Logmessage "$($ItemDiff.InputObject.Fullname) could not be copied" 
                        }
                    }
                    elseif($ItemDiff.SideIndicator -eq "=>")
                    {
                        try
                        {
                            Remove-Item -Path -Recurse $ItemDiff.InputObject.Fullname -Force -ErrorAction SilentlyContinue
                        }
                        
                        catch
                        {
                            Write-CopyLog -Logmessage "$($ItemDiff.InputObject.Fullname) could not be copied"
                        }
                    }
                }

            }
            
            catch
            {
                Write-Host "Nothing to Compare"
            }
        }

    }
    catch 
    {
        Write-CopyLog -Logmessage "$($itemarray) could not be copied"
    }
}