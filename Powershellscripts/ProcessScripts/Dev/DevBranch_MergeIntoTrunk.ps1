. ..\Dev\Ref\DevConfigData.ps1
. ..\Dev\Ref\Enumerations.ps1
. ..\Dev\Ref\Function_Misc.ps1
. ..\Shared\Ref\Function_Misc.ps1
. ..\Shared\Ref\Version_Management.ps1

[string]$trunkServerPath = "$($DevConfigData.ReleaseBranchesServerDirPath)/$($DevConfigData.TrunkName)"

AssertNoPendingChanges -serverPath $trunkServerPath

$branchServerPath =  ..\Dev\Ref\Branch_PromptForName.ps1 -branchType $BranchTypeEnum.Dev -branchState $BranchStateEnum.Existing

AssertNoPendingChanges -serverPath $branchServerPath

function ShelveAndUndoMergeResults([string]$localPathForTrunk, [string] $shelvesetDetails)
{
    [string]$branchName = Split-Path $branchServerPath -Leaf
    [string]$shelvesetTitle = "$branchname - Merge into trunk unsuccessful [reference only]"

    Write-Host
    Write-Host "Shelving merge results ..."
    tf shelve $shelvesetTitle "$localPathForTrunk\*.*" /recursive /replace /comment:"Shelving pending changes as there were issues during merge - $shelvesetDetails" | Out-Null
    Write-Host "Merge results shelved. Shelveset name: $shelvesetTitle"
    Write-Host
    Write-Warning "Do not unshelve this shelveset in trunk. Return to branch to make corrections."

    Write-Host
    Write-Host "Rolling back merge ..."
    tf undo $trunkServerPath /recursive | Out-Null
    Write-Host "Merge rolled back."
}

Write-Host "Updating development branch $branchServerPath from trunk.."
Write-Host

if(..\Dev\DevBranch_UpdateFromTrunk.ps1 -branchServerPath $branchServerPath)
{
    throw "Development branch was updated from trunk. Verify that the update did not cause issues and re-run script."
}

Write-Host "Development branch $branchServerPath up-to-date with trunk."
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


Write-Host "Working on reconfiguring trunk files. Please wait ...."
Write-Host

[string[]]$fileServerPaths = GetFileServerPathsFromPendingChanges -serverPath $trunkServerPath

if($fileServerPaths -ne $null)
{
    Write-Host "Reconfiguring trunk files ...."
    Write-Host

    ..\Dev\Ref\AppInstance_Reconfigure.ps1 -sourceInstanceServerPath $branchServerPath -targetInstanceServerPath $trunkServerPath -fileServerPaths $fileServerPaths

    Write-Host
    Write-Host "Reconfguration complete."
    Write-Host
}
else
{
    Write-Host "No pending changes to reconfigure in $trunkServerPath"
}

Write-Host
#Undo check-out on unchanged files
tfpt uu $trunkServerPath /recursive | Out-Null

Write-Host "Review merge results ..."
Write-Host
Pause    

$tfGetPreview =  tf get $trunkServerPath /recursive /preview

if($tfGetPreview -ne "All files are up to date.")
{   
    ShelveAndUndoMergeResults $localPathForTrunk -shelvesetDetails "Scripts are not up-to-date"
    throw "Files are not up-to-date. Please take an update and try merge process again."
}

Write-Host
       
#region DB update

try
{
   ..\Dev\Ref\AppInstance_ExecuteUpdateScripts.ps1 -databaseNames $DevConfigData.TrunkDatabaseNames -appInstanceServerPath $trunkServerPath
}
catch
{
    ShelveAndUndoMergeResults $localPathForTrunk -shelvesetDetails "Error occurred while executing database scripts"
    throw
}
#endregion

# Get Branch name from the branch server path
$branchName = split-path $branchServerPath -Leaf
# Get work item id from the branch name
$workItemId = GetWorkItemNumberFromBranchName -branchName $branchName

..\Dev\Checkin.ps1 -checkinServerPath $trunkServerPath -workItemNumbers $workItemId -areWorkItemsResolved $true -comment "Merging $branchServerPath changes to trunk." -codeReviewerUserName $codeReviewer | Out-Null
 
Write-Host "Deleting branch: $branchName"
write-Host "Please close all files related to this branch."
Write-Host
Pause
Write-Host
..\Dev\Branch_Delete.ps1 -branchServerPath $branchServerPath

Pause