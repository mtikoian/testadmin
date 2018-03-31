param
(    
    [Parameter(Mandatory = $true)]
    [string]$backupDbName,

    [Parameter(Mandatory = $true)]
    [string] $serverName,

    [Parameter(Mandatory = $true)]
    [string] $backupFilePath 
)

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null

[Microsoft.SqlServer.Management.Smo.Server]$smoServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server $serverName

[Microsoft.SqlServer.Management.Smo.BackupDeviceItem]$smoBackupDevice = New-Object -TypeName Microsoft.SqlServer.Management.Smo.BackupDeviceItem $backupFilePath, "File"

[Microsoft.SqlServer.Management.Smo.Backup]$smoBackup = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Backup
$smoBackup.Action = [Microsoft.SqlServer.Management.Smo.BackupActionType]::Database
$smoBackup.BackupSetDescription = 'Full backup of ' + $backupDbName
$smoBackup.BackupSetName = $backupDbName + ' Backup'
$smoBackup.Database = $backupDbName
$smoBackup.MediaDescription = 'Disk'
$smoBackup.Devices.Add($smoBackupDevice)
$smoBackup.CompressionOption = 1
$smoBackup.PercentCompleteNotification = 10
$smoBackup.Initialize = $true

$percentBackupEventHandler = [Microsoft.SqlServer.Management.Smo.PercentCompleteEventHandler] { Write-Host "Backed up $backupDbName" $_.Percent "%" }
$completedBackupEventHandler = [Microsoft.SqlServer.Management.Common.ServerMessageEventHandler] { Write-Host "Database" $backupDbName "backed up successfully." }

Write-Host "Attempting to back up $backupDbName database on $backupFilePath"

try
{
    $smoBackup.add_PercentComplete($percentBackupEventHandler)
    $smoBackup.add_Complete($completedBackupEventHandler)
    $smoBackup.SqlBackup($smoServer)
    Write-Host
}
catch
{
    throw "Backup could not be accomplished. $($_.Exception.GetBaseException().Message)"
} 
finally
{
    $smoBackup.remove_PercentComplete($percentBackupEventHandler)
    $smoBackup.remove_Complete($completedBackupEventHandler)
}
