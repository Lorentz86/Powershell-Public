function Get-ClusterHypervisorVMNames
{
    [cmdletbinding()]
    <#
    .SYNOPSIS
        Retrieves a list of Virtual Machine (VM) names from a Hyper-V Failover Cluster or standalone Hypervisor.

    .DESCRIPTION
        This function connects to a specified Hypervisor, whether it's part of a Failover Cluster or standalone,
        and retrieves the names of VMs. You can optionally filter the results by specifying VM group names.

    .PARAMETER HypervisorName
        The name or IP address of the Hypervisor you want to connect to.

    .PARAMETER Filter
        An array of VM group names (OwnerGroup) that you want to exclude from the results. (Optional)

    .EXAMPLE
        # Retrieve all VM names from a standalone Hyper-V host
        Get-ClusterHypervisorVMNames -HypervisorName "HVHost1"

        # Retrieve VM names from a Hyper-V Failover Cluster, excluding specified groups
        Get-ClusterHypervisorVMNames -HypervisorName "HVClusterNode1" -Filter @("Group1", "Group2")

    .NOTES
        File Name      : Get-ClusterHypervisorVMNames.ps1
        Author         : Gijs van den Berg
        Prerequisite   : PowerShell with Hyper-V module installed.
        Copyright 2023

    #>
    param(
        [Parameter(Mandatory=$true, HelpMessage="Hypervisor you want to connect.")]  
        [string]
        $HypervisorName,

        [Parameter(Mandatory=$false, HelpMessage="What VMS you want to filter")]  
        [array]
        $Filter
    )

    if(!(Test-Connection $HypervisorName -Quiet))
    {
        Write-Error "Cannot connect to $HypervisorName"
        return $false
    }

    if($Filter)
    {
        $Filter = $Filter | ConvertTo-Json
        $VMS = Invoke-Command -ComputerName $HypervisorName -ScriptBlock {
            param($filtervm)
            $filter = $filtervm | ConvertFrom-Json
            $AllVM = Get-ClusterResource | Where-Object ResourceType -eq "Virtual Machine"
            $AllVM = $AllVM | Where-Object {$_.OwnerGroup -notin $filter} | Select-Object -ExpandProperty OwnerGroup | Select-Object -ExpandProperty Name
            return $AllVM
        } -ArgumentList $Filter

        return $VMS
    }
    else
    {
        $VMS = Invoke-Command -ComputerName $HypervisorName -ScriptBlock {
            $AllVM = Get-ClusterResource | Where-Object ResourceType -eq "Virtual Machine"
            $AllVM = $AllVM | Select-Object -ExpandProperty OwnerGroup | Select-Object -ExpandProperty Name
            return $AllVM
        }

        return $VMS
    }
}
