. ..\Dev\Ref\DevConfigData.ps1
. ..\Dev\Ref\Enumerations.ps1
. ..\Dev\Ref\Function_Misc.ps1
. ..\Shared\Ref\Function_Misc.ps1

[string]$nameForNewBranch = ..\Dev\Ref\Branch_PromptForName.ps1 -branchType $BranchTypeEnum.Dev -returnFullServerPath $false -branchState $BranchStateEnum.New
Write-Host

[string]$serverPathForNewBranch = $DevConfigData.DevBranchesServerDirPath +"/$nameForNewBranch"
[string]$doNotMergeStatement = $DevConfigData.DoNotMergeStatement

..\Dev\Ref\Branch_Create.ps1 -sourceServerPath ($DevConfigData.ReleaseBranchesServerDirPath + "/" + $DevConfigData.TrunkName) -serverPathForNewBranch $serverPathForNewBranch
Write-Host

$workItemId = GetWorkItemNumberFromBranchName -branchName $nameForNewBranch
$workspace = Get-TfsWorkspace "$"
$localPathForNewBranch = $workspace.GetLocalItemForServerItem($serverPathForNewBranch)

#region Initial Check-in
Write-Host "Starting initial check-in: $localPathForNewBranch"
Write-Host

.\Checkin.ps1 -checkinServerPath $serverPathForNewBranch -workItemNumbers $workItemId -comment "$doNotMergeStatement Created $nameForNewBranch branch." -areWorkItemsResolved $false -skipConfirmation $true | Out-Null
Write-Host

Write-Host "Completed initial check-in: $localPathForNewBranch"
Write-Host
#endregion

#region Reconfigure
Write-Host "Starting reconfigure: $localPathForNewBranch"
Write-Host "Please wait..."
Write-Host

..\Dev\Ref\AppInstance_Reconfigure.ps1 -sourceInstanceServerPath ($DevConfigData.ReleaseBranchesServerDirPath + "/" + $DevConfigData.TrunkName) -targetInstanceServerPath $serverPathForNewBranch
Write-Host

Write-Host "Starting reconfigure check-in: $localPathForNewBranch"
Write-Host

.\Checkin.ps1 -checkinServerPath $serverPathForNewBranch -workItemNumbers $workItemId -comment "$doNotMergeStatement Reconfigured $nameForNewBranch branch." -areWorkItemsResolved $false -skipConfirmation $true | Out-Null
Write-Host

Write-Host "Completed reconfigure check-in: $localPathForNewBranch"
Write-Host

Write-Host "Completed reconfigure: $localPathForNewBranch"
Write-Host
#endregion

#region Database
Write-Host "Starting database creation: $nameForNewBranch"
Write-Host "Please wait..."
Write-Host

.\Database_CloneTrunk.ps1 -dbNamePrefix $nameForNewBranch
Write-Host

Write-Host "Completed database creation: $nameForNewBranch"
#endregion

#create website - TODO