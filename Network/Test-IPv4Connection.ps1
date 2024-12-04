# Powershell 7.1+
function Test-IPv4Connection {
    param (
        [Parameter(Mandatory=$true)]
        [ValidatePattern('^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$')]
        [string]$IPv4Address,
        
        [Parameter(Mandatory=$true)]
        [string]$LogFilePath
    )

    # Controleer of het logbestand kan worden aangemaakt
    if (-not (Test-Path $LogFilePath)) {
        try {
            New-Item -Path $LogFilePath -ItemType File -Force
        } catch {
            Write-Error "Kan het logbestand niet aanmaken: $_"
            return
        }
    }

    # Functie om te loggen
    function Log-Result {
        param (
            [string]$From,
            [string]$ToIPv4Address,
            [string]$Status,
            [string]$Latency,
            [string]$LogFilePath
        )
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "$timestamp,$FromIPv4Address,$ToIPv4Address,$Status,$Latency"
        Add-Content -Path $LogFilePath -Value $logEntry
    }

    # Ping de opgegeven IPv4-adres
    $pingResult = Test-Connection -ComputerName $IPv4Address -Count 1 -ErrorAction SilentlyContinue

    if ($pingResult.Status -notmatch "Success") {
        Log-Result -From $pingResult.Source -ToIPv4Address $IPv4Address -Status $pingResult.Status -LogFilePath $LogFilePath -Latency $pingResult.Latency
    }
    else{Write-Information -MessageData $pingResult.Status}
}