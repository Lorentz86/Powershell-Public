function Get-FSLXContainerSize{
    [CmdletBinding()]
    <#
   .SYNOPSIS
   This script provides information about FSLogix container VHD or VHDX files and can check if a mounted disk is nearly full. It calculates and returns details such as file size, total size, free space, and used space percentage.
   
   .DESCRIPTION
   The "Get-FSLXContainerSize" function retrieves information about FSLogix container VHD or VHDX files. It calculates and returns various properties, including file size, total size, free space, and used space percentage. Additionally, it can check if the disk is more than 90% full and return a Boolean result.
   
   .PARAMETER Source
   Specifies the full path of the source file of the container. This parameter is mandatory.
   
   .PARAMETER Info
   Specifies whether to return disk information. Set this option to true or false. The default value is true.
   
   .PARAMETER IsFull
   Specifies whether to check if the disk has more than 10% of free space and return a Boolean result. If set to true, disk information will not be returned. The default value is false.
   
   .EXAMPLE
   Get-FSLXContainerSize -Source "C:\Path\To\Container.vhdx"
   Retrieve information about an FSLogix container VHD or VHDX file located at the specified path.
   
   .EXAMPLE
   Get-FSLXContainerSize -Source "C:\Path\To\Container.vhdx" -IsFull $true
   Check if the FSLogix container disk has more than 90% of free space and return a Boolean result.
   
   .NOTES
   File extension validation: This function checks if the provided source file has a .vhd or .vhdx extension and prompts the user to adjust the path if not.
   
   #>
       param(
           [Parameter(Mandatory=$true, HelpMessage="The full path of the source file of the container")]
           [string]$Source,
   
           [Parameter(Mandatory=$false, HelpMessage="Set this option with true or false, return disk information")]
           [ValidateSet($true,$false)]
           [boolean]$Info = $true,
   
           [Parameter(Mandatory=$false, HelpMessage="Will return True if disk has more than 10% of freespace. Will not return disk info.")]
           [ValidateSet($true,$false)]
           [boolean]$IsFull = $false
   
       ) 
              
           if (!($Source -like "*.vhd" -or $Source -like "*.vhdx"))
       {
           do
           {
               $Anykey = Read-Host -Prompt "`n`n`nThe source address does not have a .vhd or vhdx extention. Please adjust the destination path.`n`n`nPress 'q' to quit"
               if($Anykey -match 'q'){Write-Host "Exit"}
           } while($Anykey -notmatch 'q')
       }
           
           # When a disk is mounted it will give an error. 
           try
           {
               # This part filters and calculates the info I want to have
               $DiskImg = Get-DiskImage -ImagePath $Source | Select-Object Attached,ImagePath,@{Name="FileSize(GB)";Expression={"{0:N2} GB" -f ($_.FileSize / 1GB)}},
               @{Name="Size(GB)";Expression={"{0:N2} GB" -f ($_.Size / 1GB)}},
               @{Name="Freespace(GB)";Expression={"{0:N2} GB" -f (($_.Size - $_.FileSize) / 1GB)}},
               @{Name="UsedSpace";Expression={"{0:N0} %" -f ((100 * $_.FileSize) / $_.Size)}}
   
                if($IsFull)
                {
                   $Info=$false
                   $Freespace = [int]($DiskImg.UsedSpace.Split(" ") | Select-Object -First 1)
                   if($Freespace -ge 90)
                   {
                       return $True
                   }
                   else{return $False}
                }
                if($Info){return $DiskImg}
           }
           catch{return "The following error occured: $($_.Exception.Message)"}
   }