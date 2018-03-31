<#
.SYNOPSIS 
Creates SQL Agent Job to check database integrity.

.DESCRIPTION

.PARAMETER $SQLServer
SQL Server Name.  Defaults to local computer name.

.PARAMETER $Log
Path and name of log file for job step output.

.PARAMETER $Owner
Job owner account.

.OUTPUTS
Text.

.EXAMPLE
Include example text here:
 .\Create_DB_Integrity_Job.ps1 -SqlServer "SQL01" -Log "L:\SQLAgentLogs\DatabaseIntegrity.txt" -Owner "sa"

#>

Param ([string]$SQLServer = $env:COMPUTERNAME,
		[string]$Log = "L:\SQLAgentLogs\DatabaseIntegrity.txt",
        [string]$Owner = ""
)

# import sql cmdlets
Import-Module SQLPS;

# If running script on the sql server, set location to sql instance root
If ($SQLServer -eq $env:COMPUTERNAME) {
Set-Location SQLServer:\SQL\$env:COMPUTERNAME\Default
};

If ($Owner -eq "") { # if $Owner equals blank, get sa account name
$query = '"SELECT [name] FROM master.sys.syslogins WHERE [sid] = 0x01;"';
$P_query = "sqlps  -Command {
    Invoke-Sqlcmd -ServerInstance $SQLServer -Query $query -Verbose
}";
$sa = Invoke-expression $P_query;
$Owner = $sa.Name;
}
	
# create job
$svr = new-object ('Microsoft.SqlServer.Management.Smo.Server') $SQLServer;
$job = new-object ('Microsoft.SqlServer.Management.Smo.Agent.Job') ($svr.JobServer, 'Database Integrity');
$job.Description = 'Checks integrity of all databases.';
$job.OwnerLoginName = $Owner;
$job.Create();
$job.EmailLevel =[Microsoft.SqlServer.Management.Smo.Agent.CompletionAction]::OnFailure;
$job.OperatorToEmail = 'SQLServerAdmins';
$job.Alter();

# create job step
$js = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobStep') ($job, 'Exec msdb.dbo.DatabaseIntegrityCheck');
$js.SubSystem = 'TransactSql';
$js.Command = 'EXECUTE msdb.dbo.DatabaseIntegrityCheck @Databases = ''ALL_DATABASES''';
$js.OnSuccessAction = 'QuitWithSuccess';
$js.OnFailAction = 'QuitWithFailure';
$js.OutputFileName = $Log;
$js.JobStepFlags = '4'; #Include step output in history
$js.Create();

$jsid = $js.ID;
$job.ApplyToTargetServer($s.Name);
$job.StartStepID = $jsid;
$job.Alter();

# create schedule
$jbsch = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobSchedule') ($job, 'Daily 8PM');
$jbsch.FrequencyTypes = "Daily";
$jbsch.FrequencySubDayTypes = "Once";
$ts1 = new-object System.TimeSpan(20, 0, 0);
$ts2 = new-object System.TimeSpan(23, 59, 59);
$jbsch.ActiveStartTimeOfDay = $ts1;
$jbsch.ActiveEndTimeOfDay = $ts2;
$jbsch.FrequencyInterval = 1;
$d = new-object System.DateTime(2014, 1, 1);
$jbsch.ActiveStartDate = $d;
$jbsch.Create();