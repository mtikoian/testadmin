[string]$versionNumber = "01.0006.000099.0"
[string]$serverName = "S4000PC-D-SQe01\SdnhPublished"
[string]$dbInstanceName = $null
[string]$primaryDbName = "WorkItem_22458_Sdnh"
#[bool]$isDbBackedUp = $true 
[string]$dbDeployScriptPath = "C:\CfsWorkspace\sdnh\devbranches\workitem_22511\database\Deploy"
 
C:\CfsWorkspace\Sdnh\ProcessScripts\Shared\Database_ExecuteUpdateScripts.ps1 -versionNumber $versionNumber -serverName $serverName -dbInstanceName $dbInstanceName -primaryDbName $primaryDbName -isDbBackedUp $true -dbDeployScriptPath $dbDeployScriptPath