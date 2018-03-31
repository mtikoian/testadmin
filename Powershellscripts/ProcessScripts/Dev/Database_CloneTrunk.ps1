param
(
    [Parameter(Mandatory=$true)]
    [string]$dbNamePrefix
)

. ..\Dev\Ref\DevConfigData.ps1
. ..\Shared\Ref\MultiThreading.ps1

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null

[string]$instanceName = $DevConfigData.DevSqlServerName + "\" + $DevConfigData.DevSqlServerInstanceName
[Microsoft.SqlServer.Management.Smo.Server]$smoServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server ($instanceName)

#Verify that the intended database does not already exist.
$existingDbNames = $smoServer.Databases | Select-Object -ExpandProperty Name
 
[string[]]$dbBackupList = $DevConfigData.TrunkDatabaseNames

$processes = @()

foreach($backupDb in $dbBackupList) 
{
    [string]$cloneDbName = $dbNamePrefix+"_"+$backupDb

    $processes += StartPowershellAsync -scriptFilePath "..\Dev\Database_Clone.ps1" -arguments "$cloneDbName $backupDb" 
}

if($processes.Length -gt 0)
{
    WaitForExecution -processes $processes
}