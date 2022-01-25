Install-Module -Name Microsoft.Graph.Teams
Install-Module -Name Microsoft.Online.SharePoint.PowerShell

Import-Module Microsoft.Graph.Teams
Import-Module Microsoft.Online.SharePoint.PowerShell

Connect-MgGraph -Scopes "Channel.ReadBasic.All", "ChannelSettings.Read.All","ChannelSettings.ReadWrite.All","Group.Read.All","Group.ReadWrite.All","Directory.Read.All","Directory.ReadWrite.All"

Connect-SPOService -Url "https://contoso-admin.sharepoint.com"

$Teams = Get-SPOSite -Limit All | Where {$_.IsTeamsConnected -eq $True}

foreach ($i in $Teams) {
    
    $ChannelsPerTeam = Get-MgTeamChannel -TeamId $i.Groupid

    foreach ($j in $ChannelsPerTeam) {

        $SPOLibrary = Get-MgTeamChannelFileFolder -TeamId $i.Groupid -ChannelId $j.Id
        $SPOLibraryFolderName = $SPOLibrary.Name 

        if ($SPOLibraryFolderName -ne $j.DisplayName) {
        
            $ChannelName = $j.DisplayName
            $params = @{ DisplayName = "Temporary GraphAPI Rename" }

            Write-Host "[ACTION] Channel: $($j.DisplayName) from Team: $($i.Title) mismatched SharePoint Online Folder Name: $($SPOLibraryFolderName)"
            #Update-MgTeamChannel -TeamId $i.Groupid -ChannelId $j.Id -BodyParameter $params
            Write-Host "[ACTION] Temporary Rename Succesfull"

            $params = @{ DisplayName = $ChannelName }

            #Update-MgTeamChannel -TeamId $i.Groupid -ChannelId $j.Id -BodyParameter $params
            Write-Host "[ACTION] Rename to: $($ChannelName) for the Channel and Library Successful"

        } else {

            Write-Host "[NO ACTION] Channel: $($j.DisplayName) from Team: $($i.Title) has the same SharePoint Online Folder Name: $($SPOLibraryFolderName)"

        }        

    }

}