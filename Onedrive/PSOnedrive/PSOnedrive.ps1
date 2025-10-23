param(
    [Parameter(Mandatory = $true)]
    [string]$OnedrivePath,

    [Parameter(Mandatory = $false)]
    [int]$MaxWaitTimeSeconds = 300 ,

    [Parameter(Mandatory = $false)]
    [int]$CheckIntervalSeconds = 15
)

