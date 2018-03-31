. ..\Dev\Ref\DevConfigData.ps1

function CreateChildWorkItem(
    [Parameter(Mandatory = $true)]
    [int]$parentWorkItemNumber, 

    [Parameter(Mandatory = $true)]
    [string]$newItemTitle,

    [Parameter(Mandatory = $true)]
    [string]$newItemAssignedTo,

    [string]$newItemIterationPath = $null,
    [int]$newItemIterationID = $null,

    [string]$newItemAreaPath = $null,
    [int]$newItemAreaID = $null,

    [string]$newItemDescription = $null
)
{
    Write-Host "Starting Creation of Child Work Item for $newItemTitle..."

    if($workItemNumber -eq 0)
    {
        $workItemNumber = ..\Dev\Ref\WorkItem_PromptForNumber.ps1
    }

    [Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.WorkItemTracking.Client") | Out-Null
    [Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.VersionControl.Client")  | Out-Null

    $workspace = Get-TfsWorkspace "$"
    $workItemStore = $workspace.VersionControlServer.TeamProjectCollection.GetService([type]"Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemStore")

    $parentWorkItem = $workItemStore.GetWorkItem($parentWorkItemNumber)

    $project = $parentWorkItem.Project

    #region required parameter field assignment    

    $newWorkitem = $project.workitemtypes[$DevConfigData.TfsWorkItemPerfIssueType].newworkitem()
    $newWorkItem.Fields["Title"].Value = $newItemTitle
    $newWorkItem.Fields["Assigned To"].Value = $newItemAssignedTo

    $linkType = $workItemStore.WorkItemLinkTypes[[Microsoft.TeamFoundation.WorkItemTracking.Client.CoreLinkTypeReferenceNames]::Hierarchy]
    $parentLink = new-object Microsoft.TeamFoundation.WorkItemTracking.Client.WorkItemLink($linkType.ReverseEnd, $parentWorkItemNumber) 

    $newWorkItem.WorkItemLinks.Add($parentLink) | Out-Null

    #endregion

    #region optional parameter field assignment

    if([string]::IsNullOrWhiteSpace($newItemIterationPath)){
        $newItemIterationPath = $parentWorkItem.Fields["Iteration Path"].Value
    }    

    if($newItemIterationId -eq $null -or $newItemIterationId -le 0){
        $newItemIterationId = $parentWorkItem.Fields["Iteration ID"].Value
    }    

    if([string]::IsNullOrWhiteSpace($newItemAreaPath)){
        $newItemAreaPath = $parentWorkItem.Fields["Area Path"].Value
    }   

    if($newItemAreaId -eq $null -or $newItemAreaId -le 0){
        $newItemAreaId = $parentWorkItem.Fields["Area ID"].Value
    }    

    if(![string]::IsNullOrWhiteSpace($newItemDescription)){
        $newWorkitem.Fields["Description"].Value = $newItemDescription
    }

    $newWorkitem.Fields["Iteration Path"].Value = $newItemIterationPath
    $newWorkitem.Fields["Iteration ID"].Value = $newItemIterationId
    $newWorkitem.Fields["Area Path"].Value = $newItemAreaPath
    $newWorkitem.Fields["Area ID"].Value = $newItemAreaId

    #endregion

    #region missed required fields assignment

    $requiredBlankFields = $newWorkitem.fields | Where-Object{$_.IsRequired -eq $true -and $_.IsEditable -eq $true -and ($_.Value -eq $null -or $_.Value -eq "" -or $_.Value -eq 0)}

    [string]$cmdToAssignFieldValues = $null

    foreach($requiredBlankField in $requiredBlankFields)
    {
        $cmdToAssignFieldValues = "`$newWorkItem.Fields[`"$($requiredBlankField.Name)`"].Value = `$parentWorkItem.Fields[`"$($requiredBlankField.Name)`"].Value"
        iex $cmdToAssignFieldValues
    }

    #endregion

    try
    {
        $newWorkItem.Save()
    }
    catch
    {
        throw "The new work item ($newItemTitle) could not be created. `n`r $($Error[0].Exception.Message)"
    }

    return $newWorkitem
}