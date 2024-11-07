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

    try {
        # Define the options
        $Options = @{
            Animals = "&animals="
            Colour = "&colours="
            Food = "&food="
            Instruments = "&Instruments="
            Shapes = "&shapes="
            Sports = "&sports="
            Transport = "&transport="
        }

        # Randomly select two options to be true
        $TrueOptions = $Options.Keys | Get-Random -Count 2

        # Randomize the order of the options
        $RandomizedOptions = $Options.GetEnumerator() | Sort-Object { Get-Random }

        # Build the options string
        $OptionsString = ""
        foreach ($option in $RandomizedOptions) {
            if ($TrueOptions -contains $option.Key) {
                $OptionsString += $option.Value + "true"
            } else {
                $OptionsString += $option.Value + "false"
            }
        }

        # Extra options
        $Symbols = "&symbols=true"
        $CapitalLetter = "&capitals=true"
        $NumAtEnd = "&numAtEnd=3"
        $ExcludeSymbols = "&excludeSymbols=pf"

        # Generate the URL
        $TotalUrl = $Url + $MinLength + $OptionsString + $CapitalLetter + $Symbols + $NumAtEnd + $ExcludeSymbols

        # Retrieve the password
        $Password = Invoke-RestMethod -Method Get -Uri $TotalUrl
        return $Password
    }
    catch {
        Write-Error "An error occurred while generating the password: $_"
    }
}
