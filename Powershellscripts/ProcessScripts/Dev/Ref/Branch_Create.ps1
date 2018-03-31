Param 
(
    [Parameter(Mandatory=$true)]
    [string]$sourceServerPath,

    [Parameter(Mandatory=$true)]
    [string]$serverPathForNewBranch   
)

$workspace = Get-TfsWorkspace "$"
$localPathForNewBranch = $workspace.GetLocalItemForServerItem($serverPathForNewBranch)

Write-Host "Creating branch: $localPathForNewBranch"
Write-Host "Please wait..."
Write-Host

..\Dev\Ref\Exe_Execute.ps1 "tf branch `"$sourceServerPath`" `"$serverPathForNewBranch`"" | Out-Null

Write-Host "Branch created: $localPathForNewBranch"