param
(
      [Parameter(Mandatory=$true)]
      [string[]]$databaseNames,
    
      [Parameter(Mandatory=$true)]
      [string]$appInstanceServerPath
)

. ..\Dev\Ref\DevConfigData.ps1
. ..\Dev\Ref\Version_Management.ps1

Write-Host "Executing database scripts"    

$workspace = Get-TfsWorkspace "$"

[string]$primaryDbName = $databaseNames[0]

$branchName = Split-Path $appInstanceServerPath -Leaf

[string]$sqlServerInstanceName = $DevConfigData.DevSqlServerInstanceName

if($branchName -imatch ($DevConfigData.ReleaseBranchNameFormat -f "(?<branchNumber>\d+)")){
    $sqlServerInstanceName =  $DevConfigData.ReleaseBranchSqlServerInstanceNameFormat -f ([int]$Matches["branchNumber"])
}

$installedVersionObject = GetNextInstalledVersion -primaryDbName $primaryDbName -appInstanceServerPath $appInstanceServerPath

[string]$paddedDeploymentVersion = GetPaddedVersionText -versionObject $installedVersionObject

[string]$deployScriptDirPath = $workspace.GetLocalItemForServerItem($appInstanceServerPath + "/" + $($DevConfigData.DbDeployRelativeDirPathSuffix))    

RecordInstallStart -serverName $DevConfigData.DevSqlServerName -instanceName $sqlServerInstanceName -databaseNames $databaseNames -versionNumber $paddedDeploymentVersion 

..\Shared\Database_ExecuteUpdateScripts.ps1 -versionNumber $paddedDeploymentVersion -serverName $DevConfigData.DevSqlServerName -dbInstanceName $sqlServerInstanceName `
    -primaryDbName $primaryDbName -dbDeployScriptPath $deployScriptDirPath -isDbBackedUp $true #Should be backed up nightly

RecordInstallEnd -serverName $DevConfigData.DevSqlServerName -instanceName $sqlServerInstanceName -databaseNames $databaseNames -versionNumber $paddedDeploymentVersion

Write-Host "Database update completed"
Write-Host