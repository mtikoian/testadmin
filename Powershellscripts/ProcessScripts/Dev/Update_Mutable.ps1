$ErrorActionPreference = "stop"

#region References
. ..\Dev\Ref\DevConfigData.ps1
. ..\Dev\Ref\Function_Misc.ps1
. ..\Shared\Ref\Function_Misc.ps1
#end region

Write-Host "Unregister Paths: STARTING---------------------------------------"
..\Dev\Paths_Unregister.ps1
Write-Host "Unregister Paths: COMPLETE---------------------------------------"
Write-Host

Write-Host "Register Paths: STARTING---------------------------------------"
..\Dev\Paths_Register.ps1
Write-Host "Register Paths: COMPLETE---------------------------------------"
Write-Host

Write-Host "Updating Process Scripts Folder"
    tf get $DevConfigData.ProcessScriptsServerPath /recursive
Write-Host "Complete Process Scripts Folder Update"
Write-Host

Write-Host "Workstation Setup: STARTING---------------------------------------"
..\Dev\Workstation_Setup.ps1
Write-Host "Workstation Setup: COMPLETE---------------------------------------"
Write-Host

[string[]]$appInstanceServerDirPaths = Get-TfsChildItem "$($DevConfigData.ReleaseBranchesServerDirPath)/*" -Folders | Select-Object -ExpandProperty ServerItem
$appInstanceServerDirPaths = $appInstanceServerDirPaths + (Get-TfsItemProperty "$($DevConfigData.DevBranchesServerDirPath)/*" | Where-Object {($_.IsInWorkspace -eq $true) -and ($_.TargetServerItem -ine $DevConfigData.DevBranchesServerDirPath)} | Select-Object -ExpandProperty TargetServerItem)

foreach($dirPath in $appInstanceServerDirPaths)
{
    Write-Host "Update `"$($dirPath)`" application instance: STARTING---------------------------------------"
    ..\Dev\AppInstance_Update.ps1 -appInstanceServerPath "$dirPath"
    Write-Host "Update `"$($dirPath)`" application instance: COMPLETE---------------------------------------"
    Write-Host
}

#Update release folder in case subfolders are deleted/destroyed so they get cleaned up. 
#This call does not replace application update becasue it may perform other tasks specific to an instance.
Write-Host "Cleanup `"$($DevConfigData.ReleaseBranchesServerDirPath)`": STARTING---------------------------------------"
    tf get $DevConfigData.ReleaseBranchesServerDirPath /recursive
Write-Host "Cleanup `"$($DevConfigData.ReleaseBranchesServerDirPath)`": COMPLETE---------------------------------------"
Write-Host

$workspace = Get-TfsWorkspace "$"
[string]$devBranchesRootDirPath = $workspace.GetLocalItemForServerItem($DevConfigData.DevBranchesServerDirPath)

if(Test-Path $devBRanchesRootDirPath)
{
    [object[]]$itemsUnderDevBranchRoot = Get-ChildItem $devBranchesRootDirPath
    [string[]]$pathsToDelete = @()

    foreach($item in $itemsUnderDevBranchRoot)
    {
        $tfsItemProperty = Get-TfsItemProperty $item.FullName

        if($tfsItemProperty -eq $null -or $tfsItemProperty.DeletionId -ine 0){   
            $pathsToDelete += $item.FullName
        }    
    }

    if($pathsToDelete.Count -gt 0){
        DeleteToRecycleBin -filePaths $pathsToDelete
    }
}