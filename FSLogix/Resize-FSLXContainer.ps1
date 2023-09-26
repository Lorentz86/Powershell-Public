# This script is to enlarge FSLogix Containers Important is that you add the  "C:\Program Files\FSLogix\Apps\frx.exe"
funtion Resize-FSLXContainer
{
 [CmdletBinding()]
 <#
.SYNOPSIS
Enlarges an FSLogix Container VHDX file by adding a specified amount of disk space.

.DESCRIPTION
This script allows you to resize an FSLogix Container VHDX file by adding a specified amount of disk space to accommodate user profiles. It checks for the presence of FSLogix Tools, verifies the source file, and ensures sufficient disk space before performing the resize operation.

.PARAMETER Source
Specifies the full path of the source file of the container VHDX.

.PARAMETER GigaByte
Specifies the amount in gigabytes (GB) to add to the container VHDX. The default is 5GB, and the maximum allowed value is 10GB.

.PARAMETER Dynamic
Indicates whether the VHDX file should be dynamic (1) or fixed (0). Default is 0 (fixed).

.PARAMETER Replace
Determines whether the source file should be replaced with the enlarged file. Default is True.

.EXAMPLE
Resize-FSLXContainer -Source "D:\FSLogix\Profile_User.VHDX" -GigaByte 10 -Dynamic 1 -Replace $false

This example resizes the specified FSLogix Container VHDX file by adding 10GB of disk space, making it dynamic, and retains both the original and enlarged files.

.NOTES
- Ensure that FSLogix Tools are installed before running this script.
- Backup important data before resizing VHDX files, especially when replacing the source file.
- Consider testing this script in a controlled environment before using it in a production setting.
#>
    param(
        [Parameter(Mandatory=$true, HelpMessage="The full path of the source file of the container")]
        [string]$Source,

        # Adjust this as is required in your org. 
        [Parameter(Mandatory=$true, HelpMessage="The required amount in gigabytes (GB) to add to the container. You can add up to 10GB max. The default value is 5GB")]
        [ValidateRange(1,10)]
        [byte]$GigaByte = 5,

        [Parameter(Mandatory=$true, HelpMessage="For dynamic disk the input should be 1 and for a fixed disk it should be 0, default is 0")]
        [ValidateSet(0,1)]
        [int]$Dynamic = 0,

        [Parameter(Mandatory=$true, HelpMessage="Should the source file be replaced? Default is True.")]
        [ValidateSet($true,$false)]
        [boolean]$Replace = $true

    )

    # Check of FSLogix Tools are installed
    $frxpath = "C:\Program Files\FSLogix\Apps\frx.exe"
    Write-Host ("Step 1: Check if FSLogix Tools are installed")
    if(Test-Path -Path $frxpath)
    {
        Write-Host ("`nFSLogix tools are present.`nContinue with script.")
    }
    Else
    {
        do
        {
            $Anykey = Read-Host -Prompt "`n`n`nfrx.exe not found please install FSLogix Tools or adjust path in script to correct location.`n`n`nPress 'q' to quit"
            if($Anykey -match 'q'){Write-Host "Exit"}
        } while($Anykey -notmatch 'q')
    }

    # Check if the source location is an actual virtual disk
    Write-Host ("Step 2: Check if the source in a virtual disk and get disk information.")
    if(Test-Path -Path $Source)
    {
        try
        {            
            $ContainerInfo = Get-DiskImage -ImagePath $source
        }
        catch
        {
            do
            {
                $Anykey = Read-Host -Prompt "`n`n`nThe following error occurred: $($_.Exception.Message)`n`n`nPress 'q' to quit"
                if($Anykey -match 'q'){Write-Host "Exit"}
            } while($Anykey -notmatch 'q')
        }
    }
    Else
    {
        do
        {
            $Anykey = Read-Host -Prompt "`n`n`nStep 2: Check if the source in a virtual disk and get disk information. `nNo VHD found. Please use a correct source path.`n`n`nPress 'q' to quit"
            if($Anykey -match 'q'){Write-Host "Exit"}
        } while($Anykey -notmatch 'q')
    }
    
    # Calculate current size and rounded whole upwards
    $ContainerSize = [Math]::Ceiling($ContainerInfo.Size / 1GB)
    
    $sizeGB = $GigaByte + $ContainerSize
    $sizeMbs = $sizeGB * 1024
    $EnoughSpace = $sizeGB + $ContainerSize

    # This is the start of a custom made function to test if there is enough space to continue this script. But you can remove /replace as you see fit. 
    Write-Host ("`nStep 3: Check if there is enough disk space.")

    Import-Module '\\servername\it$\PScript\Functions\Function_Conform-FreeDiskspace.ps1'
    $EnoughDiskSpace = Conform-FreeDiskSpace -DriveLetter D -RequiredFreeSpace $EnoughSpace
    if(!$EnoughDiskSpace)
    {
        do
        {
            $Anykey = Read-Host -Prompt "`nNot enough disk space.`nPlease create more space.`n`n`nPress 'q' to quit"
            if($Anykey -match 'q'){Write-Host "Exit"}
        } while($Anykey -notmatch 'q')
    }
    # end of custom module. 

    # Adjust the size the the vhd. 

    Write-Host ("`nStep 4: Enlarge the vhd.")
    try
    {
        
        $Destination = $Source -replace '\.vhdx', '_enlarged.vhdx'
        $command = "migrate-vhd -src `"$Source`" -dest `"$Destination`" -size-mbs=$sizeMbs -dynamic=$dynamic"
        Write-Host ("`nThis process can take a bit of time. You will be notified once the process is completed")
        Start-Process -FilePath $frxpath -ArgumentList $command -Wait -NoNewWindow -Verbose
    }
    catch{Write-Host "The folowing error occurred: $($_.Exception.Message)"}
    


    # Return True if there is a file at the destination and false if there isn't. 
    if($Replace)
    {
        Write-Host ("`nStep 5: This step is only here if you replace the vhd. Removeing and renaming the container.")
        
        if(Test-Path -Path $Destination )
        {
            Remove-Item -Path $Source
            Rename-Item -Path $Destination -NewName $Source
            if(Test-Path -Path $Source)
            {
                return $true
            }
            else{return $false}
        }
    }
    Else
    {
        return Test-Path -Path $Destination 
    }


      
    #Stop-Transcript
}
