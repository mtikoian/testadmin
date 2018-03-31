. ..\Dev\Ref\DevConfigData.ps1
. ..\Dev\Ref\Enumerations.ps1
. ..\Dev\Ref\Function_Misc.ps1
. ..\Shared\Ref\Function_Misc.ps1
. ..\Shared\Ref\Version_Management.ps1

[string]$trunkServerPath = "$($DevConfigData.ReleaseBranchesServerDirPath)/$($DevConfigData.TrunkName)"

AssertNoPendingChanges -serverPath $trunkServerPath

$branchServerPath =  ..\Dev\Ref\Branch_PromptForName.ps1 -branchType $BranchTypeEnum.Dev -branchState $BranchStateEnum.Existing

AssertNoPendingChanges -serverPath $branchServerPath

Write-Host "Updating development branch $branchServerPath from trunk.."
Write-Host

if(..\Dev\DevBranch_UpdateFromTrunk.ps1 -branchServerPath $branchServerPath)
{
    throw "Development branch was updated from trunk. Verify that the update did not cause issues and re-run script."
}

Write-Host "Development branch $branchServerPath already up-to-date with trunk."
Write-Host


$workspace = Get-TfsWorkspace "$"

$localPathForTrunk = $workspace.GetLocalItemForServerItem($trunkServerPath)
        
$branchHistories = Get-TfsItemHistory $branchServerPath  -Recurse | Sort-Object -Property ChangesetId
$changeSetIdFrom = $null
$changeSetIdTo = $null

foreach($branchHistory in $branchHistories)
{
    $commentMatchRegex = [Regex]::Escape($DevConfigData.DoNotMergeStatement)

    if($branchHistory.Comment -inotmatch $commentMatchRegex)
    {
        if($changeSetIdFrom -eq $null)
        {
            $changeSetIdFrom = $branchHistory.ChangesetId
        }

        $changeSetIdTo = $branchHistory.ChangesetId        
    }
}

if($changeSetIdFrom -eq $null)
{
    Write-Warning "No changes available for merge." 
    return
}

Write-Host "Merging from Branch $branchServerPath to trunk ...."
Write-Host
Cmd_ExecuteCommand "tf merge /recursive /format:detailed /version:$changeSetIdFrom~$changeSetIdTo $branchServerPath $trunkServerPath/"
Write-Host                
Write-Host "Merge completed."
Write-Host

Write-Host "Re-configuring trunk files ...."
Write-Host

..\Dev\Ref\AppInstance_Reconfigure.ps1 -sourceInstanceServerPath $branchServerPath -targetInstanceServerPath $trunkServerPath
Write-Host
Write-Host "Re-configured files in trunk."
Write-Host

#Undo check-out on unchanged files
tfpt uu $trunkServerPath /recursive | Out-Null

Write-Host "Review merge results ..."
Write-Host
Pause    

Write-Host
Write-Host "Perform peer code review ..."
Write-Host
Pause

[int]$workItemId = GetWorkItemNumberFromBranchName -branchName (split-path $branchServerPath -Leaf)

Write-Host
$workItemCodeReviewers = ..\Dev\CodeReview.ps1 -appInstanceServerPath $trunkServerPath -workItemNumber $workItemId
    
$developerDetails = GetUserDetails -userName $env:USERNAME 
[string]$emailBody = "Code review for $($developerDeatils.FullName) developed by $($developerDetails.FullName) passed review from $($workItemCodeReviewers.CodeReviewerFormattedName)."
#..\Shared\Email_Send.ps1 -emailToAddrs $workItemCodeReviewers.CodeReviewerEmail -emailCcs $developerDetails.Email -emailSubject "Code Review Passed" -emailBody $emailBody
Write-Host

Write-Host "Code Review complete."
Write-Host

$workItemDetails = ..\Dev\Ref\WorkItem_GetDetails.ps1 -workItemNumbers $workItemId -returnWorkItemObject $true
$workItem = $workItemDetails[$workItemId]
$workItemField = $workItem.Fields["History"]
[string]$workItemComment = "In development branch code review passed." 

if([string]::IsNullOrWhiteSpace($workItemCodeReviewers.CodeReviewerFormattedName))
{
    $workItemComment += " Code peer reviewer name [" + $workItemCodeReviewers.CodeReviewerFormattedName + "]."
}

if([string]::IsNullOrWhiteSpace($workItemCodeReviewers.DbReviewerFormattedName))
{
    $workItemComment += " Database peer reviewer name [" + $workItemCodeReviewers.DbReviewerFormattedName + "]."
}

$workItemField.Value = $workItemComment
$workItem.Save()

Write-Host "In development branch code review passed."
Write-Host

Write-Host "Rolling back merge ..."
tf undo $trunkServerPath /recursive | Out-Null
Write-Host "Merge rolled back."#

Pause