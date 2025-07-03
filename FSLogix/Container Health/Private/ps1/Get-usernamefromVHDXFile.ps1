function Get-UsernameFromVHDXFile {
    <#
        .SYNOPSIS
        Extracts the username from a VHDX file name.

        .DESCRIPTION
            This function takes the full path of a VHDX file and attempts to extract the username
            based on naming conventions like 'Profile_username.vhdx' or 'ODFC_username.vhdx'.

        .PARAMETER VHDXPath
            The full path to the VHDX file.

        .EXAMPLE
            get-usernamefromVHDXFile -VHDXPath "Z:\fslogix\Profile_jdoe.vhdx"
            Returns: jdoe
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$VHDXPath
    )

    try {
        if (-not (Test-Path -Path $VHDXPath)) {
            throw "File does not exist: $VHDXPath"
        }

        $fileName = [System.IO.Path]::GetFileName($VHDXPath)

        if ($fileName -match '^Profile_(.+?)\.vhdx$' -or $fileName -match '^ODFC_(.+?)\.vhdx$') {
            return $matches[1]
        } else {
            throw "Could not extract username from file name: $fileName"
        }
    }
    catch {
        Write-Error "An error occurred while extracting the username: $($_.Exception.Message)"
        return $null
    }
}