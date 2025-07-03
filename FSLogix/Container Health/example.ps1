# Define the folder path containing the virtual disks
$folderPath = "Z:\fslogix-profiles"

# Function to get an available drive letter, excluding floppy and CD-ROM drives
function Get-AvailableDriveLetter {
# Get used drive letters
$usedLetters = Get-Partition | Where-Object { $_.DriveLetter } | Select-Object -ExpandProperty DriveLetter
# Get drive letters assigned to CD-ROM drives
$cdromLetters = Get-CimInstance -ClassName Win32_CDROMDrive | Select-Object -ExpandProperty Drive | ForEach-Object { $_[0] }
# Define reserved letters for floppy disks
$reservedLetters = @('A', 'B', 'C', 'D', 'E')
# Combine used, CD-ROM, and reserved letters
$excludedLetters = $usedLetters + $cdromLetters + $reservedLetters | Sort-Object | Get-Unique
# Get available letters from C to Z, excluding the ones above
$availableLetters = [char[]](67..90) | Where-Object { $_ -notin $excludedLetters }
if ($availableLetters) {
return $availableLetters[0]
}
throw "No available drive letters found"
}

# Function to get the disk number of a newly mounted VHD
function Get-MountedVHDDiskNumber {
param (
[string]$VHDPath
)
# Get disk information after mounting
$disks = Get-Disk
# Look for the disk with the VHD path in its location or signature
$mountedDisk = $disks | Where-Object { $_.Location -eq $VHDPath -or $_.Path -eq $VHDPath }
if ($mountedDisk) {
return $mountedDisk.Number
}
throw "Could not determine disk number for VHD: $VHDPath"
}

# Get all VHD and VHDX files in the folder
$vdiskFiles = Get-ChildItem -Recurse -Path $folderPath -Filter *.vhdx -File

# Loop through each virtual disk file and compact it
foreach ($vdisk in $vdiskFiles) {
Write-Host "Compacting $($vdisk.FullName)..."

try {
# Mount the VHD
Mount-VHD $vdisk.FullName -ErrorAction Stop

# Get the disk number of the mounted VHD
$diskNumber = Get-MountedVHDDiskNumber -VHDPath $vdisk.FullName
Write-Host "Mounted VHD is on Disk $diskNumber"

# Find an available drive letter
$driveLetter = Get-AvailableDriveLetter
Write-Host "Using drive letter $driveLetter"

# Assign the drive letter to the partition (assuming first partition, typically 1 for VHDs)
Get-Partition -DiskNumber $diskNumber -PartitionNumber 1 | Set-Partition -NewDriveLetter $driveLetter

# Run disk maintenance commands
chkdsk "$($driveLetter):" /f /x /forceofflinefix /scan
chkdsk "$($driveLetter):" /sdcleanup /x
defrag "$($driveLetter):" /x
defrag "$($driveLetter):" /k /l
defrag "$($driveLetter):" /x
defrag "$($driveLetter):" /k

# Dismount the VHD
Dismount-VHD $vdisk.FullName

# Optimize the VHD
Optimize-VHD -Path $vdisk.FullName -Mode Full

Write-Host "Compaction of $($vdisk.FullName) completed."
}
catch {
Write-Host "Error processing $($vdisk.FullName): $_"
# Ensure VHD is dismounted in case of error
try { Dismount-VHD $vdisk.FullName -ErrorAction SilentlyContinue } catch {}
}
}

Write-Host "All virtual disks in the folder have been compacted."