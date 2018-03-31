<#
.SYNOPSIS 
Creates Log Backup SQL Agent Job for all databases, excluding Tempdb and ReportServerTempdb.

.DESCRIPTION
Creates Log Backup Job using Ola Hallengren's DatbaseBackup stored procedure.

.PARAMETER $SQLServer
SQL Server Name.  Defaults to local computer name.

.PARAMETER $BackupPath
Path to location for backup files.

.PARAMETER $Log
Path and name of log file for job step output.

.PARAMETER $Owner
Job owner account.

.OUTPUTS
Text.

.EXAMPLE
Include example text here:
 .\Log_Backup_Job.ps1 -SqlServer "SQL01" -BackupPath "\\server\share" -Log "L:\SQLAgentLogs\Log_Backup.txt" -Owner "sa"

#>

Param ([string]$SQLServer = $env:COMPUTERNAME,
		[string]$BackupPath = "\\server\share",
		[string]$Log = "L:\SQLAgentLogs\Log_Backup.txt",
        [string]$Owner = ""
)

# import sql cmdlets
Import-Module SQLPS;

Set-Location SQLServer:\SQL\$env:COMPUTERNAME\Default

# If running script on the sql server, set location to sql instance root
If ($SQLServer -eq $env:COMPUTERNAME) {
Set-Location SQLServer:\SQL\$env:COMPUTERNAME\Default
};

# create job
$svr = new-object ('Microsoft.SqlServer.Management.Smo.Server') $SQLServer;
$job = new-object ('Microsoft.SqlServer.Management.Smo.Agent.Job') ($svr.JobServer, 'Log Backup');
$job.Description = 'Executes a full backup for all databases, excluding Tempdb and ReportServerTempdb.';
$job.OwnerLoginName = $Owner;
$job.Create();
$job.EmailLevel =[Microsoft.SqlServer.Management.Smo.Agent.CompletionAction]::OnFailure;
$job.OperatorToEmail = 'SQLServerAdmins';
$job.Alter();

# create job step
$js = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobStep') ($job, 'Exec msdb.dbo.DatabaseBackup');
$js.SubSystem = 'TransactSql';
$js.Command = 'EXEC msdb.dbo.DatabaseBackup
	@Databases = ''ALL_DATABASES, -Tempdb, -ReportServerTempdb'',
	@Directory = ''' + $BackupPath + ''',
	@BackupType = ''LOG'',
	@Verify = ''Y'',
	@Compress = ''Y'',
	@ChangeBackupType = ''Y'',
	@CheckSum = ''Y''';
$js.OnSuccessAction = 'QuitWithSuccess';
$js.OnFailAction = 'QuitWithFailure';
$js.OutputFileName = $Log;
$js.JobStepFlags = '4'; #Include step output in history
$js.Create();

$jsid = $js.ID;
$job.ApplyToTargetServer($s.Name);
$job.StartStepID = $jsid;
$job.Alter();

# create job schedule
$jbsch = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobSchedule') ($job, '15min 12AM-10PM');
$jbsch.FrequencyTypes = "Daily";
$jbsch.FrequencySubDayTypes = "Minute";
$jbsch.FrequencySubDayinterval = 15;
$ts1 = new-object System.TimeSpan(0, 0, 0);
$ts2 = new-object System.TimeSpan(21, 59, 59);
$jbsch.ActiveStartTimeOfDay = $ts1;
$jbsch.ActiveEndTimeOfDay = $ts2;
$jbsch.FrequencyInterval = 1;
$d = new-object System.DateTime(2014, 1, 1);
$jbsch.ActiveStartDate = $d;
$jbsch.Create();

$jbsch = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobSchedule') ($job, '15min 11PM-12AM');
$jbsch.FrequencyTypes = "Daily";
$jbsch.FrequencySubDayTypes = "Minute";
$jbsch.FrequencySubDayinterval = 15;
$ts1 = new-object System.TimeSpan(23, 0, 0);
$ts2 = new-object System.TimeSpan(23, 59, 59);
$jbsch.ActiveStartTimeOfDay = $ts1;
$jbsch.ActiveEndTimeOfDay = $ts2;
$jbsch.FrequencyInterval = 1;
$d = new-object System.DateTime(2014, 1, 1);
$jbsch.ActiveStartDate = $d;
$jbsch.Create();