# Teams-Channels-SPO-Rename-Sync
This is a simple script that will be able to bring in sync Teams Channels Names to their SharePoint Online Library Counterparts

Microsoft has announced in Late 2021 that Teams will get a new functionality that will make renaming Teams Channels in the Application to rename also the SharePoint Online Library Folder corresponding to that Channel.

Relevant Microsoft Roadmap Article is available here:
https://www.microsoft.com/en-us/microsoft-365/roadmap?filters=&searchterms=72211

This behaviour will be automatically applied to newly created Channels after the moment the feature will drop. Older created Channels, previous to the deployment of the feature, will inherit the ability to rename their SPO Folders, but will not do so automatically.

The purpose of this script is to allow a Tenant Admin to scan through all the Teams Channels in the organization and identify which Channels have a mismatch between their Teams Display Name and their SharePoint Online Folder.

In order to do so, we are leveraging the SharePointOnline Management PowerShell Module and the GraphAPI PowerShell SDK.

We are looking at establishing a GraphAPI Session with the relevant Graph Permissions in place:
Connect-MgGraph -Scopes "Channel.ReadBasic.All", "ChannelSettings.Read.All","ChannelSettings.ReadWrite.All","Group.Read.All","Group.ReadWrite.All","Directory.Read.All","Directory.ReadWrite.All"

We are then establishing a SPO PowerShell Connection as well:
Connect-SPOService -Url "https://contoso-admin.sharepoint.com"

We then try to get all the SPO Sites that are belonging to Teams by running:
$Teams = Get-SPOSite -Limit All | Where {$_.IsTeamsConnected -eq $True}

We then iterate through the list of Teams returned by the SPO Manangement Module, and using the Get-MgTeamChannel from the Microsoft.Graph.Teams module, we are pulling the Channels belonging to each individual Team (we are leveraging the GroupID property contained for each of the Object in the $Teams list).

We do a second iteration through the list of Channels for each individual Team as we are interested to check the sync for each Channel in the Organization. We then use the Get-MgTeamChannelFileFolder cmdlet in order to extract the File Folder for each individual Channel (this command takes as parameters the Team GroupID and the Channel ID in order to work).

Once we have both the Channel Name and the SPO Library Folder Name, we simply do a comparison between the two to see if they match or not. If they match we simply display a succesfull message. If they don't, we do two renames: one to bring in sync to a common denominator both the Channel Name and the SPO Library Folder Name, and then another to bring both of them to their initial Channel Name. For this we use the Update-MgTeamChannel.

The Update-MgTeamChannel has three parameters, the Team GroupID, the Channel ID and the Body Parameters of the Request we sent.
To change just the Name of the Channel we can use a simple request: $params = @{ DisplayName = "Temporary GraphAPI Rename" }
For Channels that need updating, we display the fact that a mismatch was found, that the temporary rename has been performed and that the final rename has been completed.

This script is very useful if you have had users in the Organization that have previously renamed their Channels and now are finding confusing the fact that a specific Channel might be named "Test Rename" while the Folder in SharePoint Online might be called "Original Name".


Documentation Reference:
https://docs.microsoft.com/en-us/graph/api/channel-patch?view=graph-rest-1.0&tabs=powershell
https://docs.microsoft.com/en-us/graph/api/channel-get-filesfolder?view=graph-rest-1.0&tabs=http
