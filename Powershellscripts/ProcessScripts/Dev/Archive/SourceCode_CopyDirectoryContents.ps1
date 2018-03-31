param(
    [string]$sourceServerPath,
    [string[]]$targetServerPaths = @()
)

cd $PSScriptRoot

if(($sourceServerPath.Length -le 0) -or ($targetServerPaths.Length -le 0)){
    $sourceServerPath = Read-Host "Enter source server path (ex: $/CSES)"
    $targetServerPaths += Read-Host "Enter target server path (ex: $/CSES)"

    if(($sourceServerPath.Length -le 0) -or ($targetServerPaths.Length -le 0)){
        throw "Invalid paths"
        exit
    }
}

$workspace = Get-TfsWorkspace $PSScriptRoot
$sourceLocalPath = $workspace.GetLocalItemForServerItem($sourceServerPath)

foreach($targetServerPath in $targetServerPaths)
{
    $targetLocalPath = $workspace.GetLocalItemForServerItem($targetServerPath)

    $sourceLocalFiles = Get-ChildItem $sourceLocalPath

    foreach($fwFile in $sourceLocalFiles){
        $targetExistsOnSever = $workspace.VersionControlServer.ServerItemExists($targetServerPath + "/" + $fwFile.Name, [Microsoft.TeamFoundation.VersionControl.Client.ItemType]::Any)
        $targetLocalFullName = $targetLocalPath + "\" + $fwFile.Name

        if($targetExistsOnSever){
            Write-Host "Checking out: $targetLocalFullName"
            Add-TfsPendingChange -Edit $targetLocalFullName | Out-Null
        }

        copy $fwFile.FullName $targetLocalPath
        Write-Host "File copied: $($fwFile.Name)"

        if(-not $targetExistsOnSever){
            Add-TfsPendingChange -Add $targetLocalFullName
            Write-Host "Added to source control: $targetLocalFullName"
        }

        Write-Host
    }
}