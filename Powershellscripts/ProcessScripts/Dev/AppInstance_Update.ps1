param(
    [string]$appInstanceServerPath = $null
)

$workspace = Get-TfsWorkspace "$"

#region References
. ..\Dev\Ref\DevConfigData.ps1
. ..\Dev\Ref\Enumerations.ps1
. ..\Dev\Ref\Function_Misc.ps1
. ..\Shared\Ref\Function_Misc.ps1
#endregion

if([string]::IsNullOrEmpty($appInstanceServerPath))
{
    $appInstanceServerPath = ..\Dev\Ref\Branch_PromptForName.ps1 -branchType $BranchTypeEnum.Any -branchState $BranchStateEnum.Existing
}

Write-Host "Updating `"$appInstanceServerPath`""
Write-Host


foreach($relativeCheckChangesDirPath in $($DevConfigData.RelativeDirPathsToScorch).Keys){
    $instanceCheckChangesDirPath = $appInstanceServerPath  + "/" + $relativeCheckChangesDirPath
    $tfGetPreview =  tf get $instanceCheckChangesDirPath /recursive /preview

    if($tfGetPreview -ne "All files are up to date."){
        
        $scorchServerPath = $appInstanceServerPath + "/" + $DevConfigData.RelativeDirPathsToScorch[$relativeCheckChangesDirPath]            
        Write-Host "Clearing $scorchServerPath due to library changes"

        tfpt scorch $workspace.GetLocalItemForServerItem($scorchServerPath) /noprompt /recursive | Out-Null

        Write-Host "$scorchServerPath cleared"
        Write-Host
    }
}

#Calling tf.exe to update the branch
Cmd_ExecuteCommand "tf.exe get $appInstanceServerPath /recursive" 

Write-Host "Update `"$appInstanceServerPath`" Complete."