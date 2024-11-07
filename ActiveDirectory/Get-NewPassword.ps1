function Get-NewPassword {
    <#
    .SYNOPSIS
    Generates a new password using the password.ninja API with specified parameters.

    .PARAMETER Length
    The minimum length of the password. Default is 12.

    .EXAMPLE
    Get-NewPassword -Length 16
    #>

    param (
        [int]$Length = 12
    )

    $Url = "https://password.ninja/api/password?"
    $MinLength = "minPassLength=" + $Length

    $RandomArray = @{
        Animals = "&animals=true"
        Colour = "&colours=true"
        Food = "&food=true"
        Instruments = "&Instruments=true"
        shapes = "&shapes=true"
        sports = "&sports=true"
        transport = "&transport=true"
    }

    try {
        $randomValueArray = $RandomArray.Values | Get-Random -Count 2
        $randomValueString = $randomValueArray[0] + $randomValueArray[1]

        $Symbols = "&symbols=true"
        $CapitalLetter = "&capitals=true"
        $TotalUrl = $Url + $MinLength + $randomValueString + $CapitalLetter + $Symbols

        $Password = Invoke-RestMethod -Method Get -Uri $TotalUrl
        return $Password
    }
    catch {
        Write-Error "An error occurred while generating the password: $_"
    }
}
