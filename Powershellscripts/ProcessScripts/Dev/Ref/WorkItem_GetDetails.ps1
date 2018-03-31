param(
[parameter(Mandatory=$true)]
[int[]] $workItemNumbers,

[bool] $returnWorkItemObject = $false
)

[Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.WorkItemTracking.Client") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.VersionControl.Client")  | Out-Null

[hashtable] $workItemDetails = $null

if($workItemNumbers.Length -gt 0)
{
    $workspace = Get-TfsWorkspace "$"
    $workItemStore = $workspace.VersionControlServer.TeamProjectCollection.GetService([type]"Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemStore")

    foreach($workItemNumber in $workItemNumbers)
    {
        [string]$invalidWorkItems = ""
        try
        {
            $workItem = $workItemStore.GetWorkItem($workItemNumber)
            
            if($workItemDetails -eq $null)
            {
                $workItemDetails = @{}
            }

            if($returnWorkItemObject)
            {
                $workItemDetails.Add($($workItem.Id), $workItem)
            }
            else
            {
                $workItemDetails.Add($($workItem.Id), "$($workItem.Id): $($workItem.Title) [Assigned To: $($workItem.Fields["Assigned To"].Value)]" )
            }
        }
        catch
        {
            $invalidWorkItems = $invalidWorkItems + $workItemNumber+", "
        }

        if(![string]::IsNullOrEmpty($invalidWorkItems))
        {
            Write-Warning "One or more work items ($($invalidWorkItems.TrimEnd(", "))) could not be located. Work item(s) queried: $($workItemNumbers -join ", ")"
        }
    }
}

return $workItemDetails