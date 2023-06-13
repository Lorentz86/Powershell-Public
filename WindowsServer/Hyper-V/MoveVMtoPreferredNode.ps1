#Script To move VMS to their preferred nodes. 
# PS Modules Needed FailoverClusters.
# Make a csv file containing VM's and their preferred nodes. Example will be uploaded
$prefNodes = Import-csv "Path to File"


$AllFailOverVMs = Get-ClusterResource | Where-Object -Property ResourceType -EQ "Virtual Machine"

foreach($prefNode in $prefNodes)
{
    foreach($VM in $AllFailOverVMs)
    {
        $vmname = $VM.Name.Replace("Virtual Machine ","")
        
        if($vmname.Equals($prefNode.'Virtual Machine'))
        {
            # the ! reverts the output of equals. 
            if(!$VM.OwnerNode.Name.Equals($prefNode.'Preferred Node'))
            {
                Write-Host "Moving $vmname to $($prefNode.'Preferred Node')"
                Move-ClusterVirtualMachineRole -Name $vmname -Node $prefNode.'Preferred Node' -Verbose
            }
        }
    }
}