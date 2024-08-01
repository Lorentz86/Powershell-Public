# Script Teams Channels
The current script has 3 built in channels. Update, Security, Error. But you can add as many as you like. You you need to adjust the parameters names and webhook links. 
You can also remove the link, but then also remove the parameters. 

# Implementing webhooks from Power Automate. (Because the default webhooks are out of commission by the end of the year)
For implementing the powershell with teams webhooks you have to do the following: 
  1. Go to your Power Automate
  2. Choose to "Create" and look up the following template "Post to a channel when a webhook request is received" and choose the "Edit in advanced mode"
  3. Go to your Microsoft Teams and choose a channel you want to use. Click on the "..." on the top right corner of the channel and seletct "Get link to channel"
  4. You have something like :  "https://teams.microsoft.com/l/channel/19%3Af812bunchofnumbers0thread.tacv2/UpdateFeeds?groupId=a82asomegroupidnumber0cccb&tenantId="  # edited this link 
  5. In this link there are 2 items you need. The "groupdid" in my exaplme its "a82asomegroupidnumber0cccb" and the channel id so it's "19%3Af812bunchofnumbers0thread.tacv2" 
  6. In the advanced mode, select the "Post card in chat or channel"
  7. Copy the groupid into "Team" and the channel id into "Channel" 
  8. Give the script a name and save it. 
  9. Once saved choose in the advanced editor the "When a Teams webhook request is received", there should be an url. Thats the url of the webhook. 
  10. Repeat these steps until you have 3 webhooks if you use this script. Adjust as you see fit. 

# Adaptive Cards
In the script there is a default Adaptive Card. Its in the most simple form. You can add more cards as you see fit, but not every card is compatible with powershell. 
You can use this site: https://www.adaptivecards.io/designer/ to make your adaptive card. In the script under
$AdaptiveCards = @{
'default' = @{Current Json Payload in script}
'custom' = @{Custom Json Payload}
}
Do change the parameter in the beginning of the script. 

        [Parameter(Mandatory=$false, HelpMessage="Type of adaptive card")]
        [ValidateSet("default","custom")]
        [string]
        $MessageType = "default"

# Known Errors
Adaptive Cards version 1.3 is the highest version thats compatible with the webhooks and powershell. 
