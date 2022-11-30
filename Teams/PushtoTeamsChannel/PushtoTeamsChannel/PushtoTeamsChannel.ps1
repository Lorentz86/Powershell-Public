<#
  .SYNOPSIS
  Send a message to a teams channel using a webhook. 

  .DESCRIPTION
  You can import this script using Import-module [path of script].ps1. 
  Link how to make a webhook in a teams chanel: 
  https://docs.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook 
  Paste the link in the [Process] part of the script. 

  .PARAMETER Channel
  Specifies the channel where the message should be in. 

  .PARAMETER Title
   Specifies the Title of the message

   .PARAMETER Message
   Specifies the content of the message

  .INPUTS
  None. You cannot pipe objects to PushtoTeamschannel.ps1.

  .OUTPUTS
  If you run this script in ISE you will reciece a "1" if the message has been delivered. 

  .EXAMPLE
  PS> Push-Message -Channel "Update" -Title "Example" -Message "This is an example"  

  .EXAMPLE
  PS> Push-Message -Channel "Security" -Title "Example" -Message "This is an example of a security warning"  

  .EXAMPLE with variable
  PS> Push-Message -Channel "Security" -Title $Title -Message $Message  

#>

function Push-Message 
{
	[cmdletbinding()]
	param 
	(
		[Parameter(Mandatory=$true)]  
		[ValidateSet("Update","Error","Security")] # Adjust Channel names that you use. I have set up 3 channels, so add or remove if needed. 
		[string]
		$Channel,

		[Parameter(Mandatory=$true)]  #Title parameter
		[string]
		$Titel,

		[Parameter(Mandatory=$true)]  #Message parameter
		[string]
		$Message
	)

	$Update = 'Update'
	$Errors = 'Error'
	$Security = 'Security'
									#$JSONBody contains the payload of the message.  
	$JSONBody = [PSCustomObject][Ordered]@{
	"@type" = "MessageCard"
	"@context" = "<http://schema.org/extensions>"
	"summary" = "$Channel"
	"themeColor" = '0078D7'
	"title" = "$Title"}




	if ($Update,$Errors,$Security -notcontains $Channel)
	{
		Write-host "Please input a channel The following have been configuered: $Update, $Error or $Security"
	}
	elseif ($Channel -eq $Update)
	{
		$webhook = "https://yourdomain.webhook.office.com"
	}
	elseif ($Channel -eq $Error) 
	{
		$webhook = "https://yourdomain.webhook.office.com"
	}
	elseif ($Channel -eq $Security) 
	{
		$webhook = "https://yourdomain.webhook.office.com"
	}
	
	$Body = ConvertTo-Json $JSONBody

	End
	{
		Invoke-RestMethod -uri $webhook -Method Post -body $Body -ContentType 'application/json' # This command will send a message to the webhook.

	}
}
