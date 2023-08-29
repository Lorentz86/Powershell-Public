# This script is to enlarge FSLogix Containers
funtion Resize-FSLXContainer
{
 [CmdletBinding()]
    param(

        [Parameter(Mandatory=$true, HelpMessage="The full path of the source file of the container")]
        [string]$Source,
    
        [Parameter(Mandatory=$true, HelpMessage="The full path of destination of the adjusted vhd")]
        [string]$Destination,

        # Adjust this as is required in your org. 
        [Parameter(Mandatory=$true, HelpMessage="The required amount in gigabytes (GB) to add to the container. You can add up to 10GB max. The default value is 5GB")]
        [ValidateRange(1,10)]
        [byte]$GigaByte = 5,

        [Parameter(Mandatory=$true, HelpMessage="For dynamic disk the input should be 1 and for a fixed disk it should be 0")]
        [ValidateSet(0,1)]
        [smallint]$dynamic


    )
    # location of the frx.exe.
    $frxpath = ".\C:\Program Files\FSLogix\Apps\frx.exe"

    if(!(Test-Path -Path $frxpath))
    {
        do
        {
            $Anykey = Read-Host -Prompt "`n`n`nLocation of frx.exe not found. `nPlease install FSLogix tools or adjust script to the correct frx.exe location. `n`n`nPress 'q' to quit"
            if($Anykey -match 'q'){Write-Host "Exit"}
        } while($Anykey -notmatch 'q')
    }

    # Check if the source location is an actual virtual disk
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
            $Anykey = Read-Host -Prompt "`n`n`nNo VHD found. Please use a correct source path.`n`n`nPress 'q' to quit"
            if($Anykey -match 'q'){Write-Host "Exit"}
        } while($Anykey -notmatch 'q')
    }
    
    # Calculate current size and rounded whole upwards
    $ContainerSize = [Math]::Ceiling($ContainerInfo.Size / 1GB)
    
    $sizeGB = $GigaByte + $ContainerSize
    $sizeMbs = $sizeGB * 1024

    # This is a custom made function to test if there is enough space to continue this script.
    Import-Module '\\fp01\it$\PScript\Functions\Function_Conform-FreeDiskspace.ps1'
    $EnoughDiskSpace = Conform-FreeDiskSpace -DriveLetter D -RequiredFreeSpace $sizeGB
    if(!$EnoughDiskSpace)
    {
        do
        {
            $Anykey = Read-Host -Prompt "Not enough disk space.`nPlease create more space.`n`n`nPress 'q' to quit"
            if($Anykey -match 'q'){Write-Host "Exit"}
        } while($Anykey -notmatch 'q')
    }

    # Adjust the size the the vhd. 
    try{$command = "$frxPath migrate-vhd -src ""$Source"" -dest ""$Destination"" -size-mbs=$sizeMbs -dynamic=$dynamic"}
    catch{Write-Host "The folowing error occurred: $($_.Exception.Message)"}    
}
