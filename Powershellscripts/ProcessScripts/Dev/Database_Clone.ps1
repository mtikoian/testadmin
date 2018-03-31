Param 
(
    [Parameter(Mandatory=$true)]
    [string]$cloneDbName,

    [Parameter(Mandatory=$true)]
    [string]$backupDbName
)

. ..\Dev\Ref\DevConfigData.ps1

[string]$instanceName = $DevConfigData.DevSqlServerName + "\" + $DevConfigData.DevSqlServerInstanceName

#region Backup database

[string]$backupDirPath = $DevConfigData.DevSqlServerBackupDirPath 
[string]$backupDateTime = Get-Date -Format yyyyMMddHHmmss 
[string]$backupFilePath = $backupDirPath + "\" + $backupDbName + "_db_" + $backupDateTime + ".bak"

..\Shared\Database_Backup.ps1 -backupDbName $backupDbName -serverName $instanceName -backupFilePath $backupFilePath

#endregion

#region Restore database

$mdfPhysicalFilePath = $DevConfigData.DevSqlDataFileDirPath + "\" + $cloneDbName + "_Data.mdf"
$ldfPhysicalFilePath = $DevConfigData.DevSqlLogFileDirPath + "\" + $cloneDbName + "_Log.ldf"

..\Shared\Database_Restore.ps1 -serverName $instanceName -backupFilePath $backupFilePath -databaseName $cloneDbName `
                                                 -mdfPhysicalFilePath $mdfPhysicalFilePath -ldfPhysicalFilePath $ldfPhysicalFilePath

#endregion