function Push-Message {
    [cmdletbinding()]
        <#
    .SYNOPSIS
        Sends a formatted message to a specified channel using Microsoft Teams webhook, with the ability to customize the message's appearance.

    .DESCRIPTION
        The `Push-Message` function allows you to send messages to specific channels in Microsoft Teams using webhooks. It provides the flexibility to customize the appearance of the message, including the theme color and font family.

    .PARAMETER Channel
        Specifies the target channel for the message. It must be one of the following options: 'Update,' 'Error,' or 'Security.'

    .PARAMETER Title
        Specifies the title of the message. This will be displayed prominently in the message card.

    .PARAMETER Message
        Specifies the main body of the message. This is where you can provide the content you want to convey.

    .PARAMETER MessageType
        Specifies the type of adaptive card to use. Currently, only 'default' is supported.

    .EXAMPLE
        Push-Message -Channel 'Update' -Title 'System Update' -Message 'A system update is available. Please review and schedule it.' -MessageType 'default'

        Sends a system update message to the 'Update' channel with a custom title and message, using the default adaptive card style.

    .EXAMPLE
        Push-Message -Channel 'Error' -Title 'Error Alert' -Message 'An error occurred in the application. Please investigate.' -MessageType 'default'

        Sends an error alert message to the 'Error' channel with a custom title and message, using the default adaptive card style.

    .NOTES
        File Name: Push-Message.ps1
        Author: [Gijs van den Berg]
        Version: 1.1
        Last Modified: [01-08-2024]

        This function is designed for sending formatted messages to Microsoft Teams channels using webhooks. Customize the appearance and content of your messages for various scenarios.
    #>
    param (
        [Parameter(Mandatory=$true, HelpMessage="Channel you want to send the message to")]  
        [ValidateSet('Update','Error','Security')]
        [string]
        $Channel,

        [Parameter(Mandatory=$true, HelpMessage="The title of the message")]  
        [string]
        $Title,

        [Parameter(Mandatory=$true, HelpMessage="The main body of the message")]  
        [string]
        $Message,

        [Parameter(Mandatory=$false, HelpMessage="Type of adaptive card")]
        [ValidateSet("default")]
        [string]
        $MessageType = "default"
    )

    # ChannelWebhooks
    $webhooks = @{
        'Update'   = "webhook1.example.com"
        'Security' = "webhook2.example.com"
        'Error'    = "webhook3.example.com"
    }

    $AdaptiveCards = @{
        'default' = @{
            '$schema' = "http://adaptivecards.io/schemas/adaptive-card.json"
            type = "AdaptiveCard"
            version = "1.3"
            body = @(
                @{
                    type = "TextBlock"
                    size = "Medium"
                    weight = "Bolder"
                    text = $Title
                },
                @{
                    type = "TextBlock"
                    text = $Message
                    wrap = $true
                }
            )
        }
    }

    $payload = @{
        type = "message"
        attachments = @(
            @{
                contentType = "application/vnd.microsoft.card.adaptive"
                contentUrl = $null
                content = $AdaptiveCards[$MessageType]
            }
        )
    }

    # Convert the payload to JSON format
    $CardJson = $payload | ConvertTo-Json -Depth 10

    # Debug output to check the JSON string
    $WebhookUrl = $webhooks[$Channel]
    $Headers = @{'Content-Type' = 'application/json'}

    # Return 
    $messageSend = 0

    try {
        while ($messageSend -ne 1) {
            $response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Headers $Headers -Body $CardJson
            if ($response -ne $null) {
                $messageSend = 1
            }
            Start-Sleep -Seconds 1
        }
    } catch {
        Write-Host "The following error occurred: $($_.Exception.Message)"
    }
}
