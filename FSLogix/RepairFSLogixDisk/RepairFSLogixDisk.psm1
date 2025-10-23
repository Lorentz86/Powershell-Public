# Import all Private functions
$privateFunctions = Get-ChildItem -Path "$PSScriptRoot\private\ps1" -Filter *.ps1 -Recurse
foreach ($script in $privateFunctions) {
    try {
        . $script.FullName
    } catch {
        Write-Error "Failed to import private function: $($script.FullName). Error: $_"
    }
}

# Import all Public functions
$publicFunctions = Get-ChildItem -Path "$PSScriptRoot\public\ps1" -Filter *.ps1 -Recurse
foreach ($script in $publicFunctions) {
    try {
        . $script.FullName
    } catch {
        Write-Error "Failed to import public function: $($script.FullName). Error: $_"
    }
}
