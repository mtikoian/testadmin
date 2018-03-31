<#
.SYNOPSIS 
Configures SQL Server to cycle error logs nightly

.DESCRIPTION

.PARAMETER $SQLServer
SQL Server Name.  Defaults to local computer name.

.PARAMETER $Owner
Job owner account.

.OUTPUTS
Text.

.EXAMPLE
Include example text here:
 .\Configure_SQL_Error_Logs.ps1 -SqlServer "SQL01" -Owner "sa"

#>

Param ([string]$SQLServer = $env:COMPUTERNAME,
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
	
$svr = new-object ('Microsoft.SqlServer.Management.Smo.Server') $SQLServer;
$job = new-object ('Microsoft.SqlServer.Management.Smo.Agent.Job') ($svr.JobServer, 'Cycle SQL Error Log');
$job.Description = 'Closes the current error log file and cycles the error log (like a server restart).';
$job.OwnerLoginName = $Owner;
$job.Create();
$job.EmailLevel =[Microsoft.SqlServer.Management.Smo.Agent.CompletionAction]::OnFailure;
$job.OperatorToEmail = 'SQLServerAdmins';
$job.Alter();

$js = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobStep') ($job, 'Cycle Error Log');
$js.SubSystem = 'TransactSql';
$js.Command = 'EXEC sp_cycle_errorlog';
$js.OnSuccessAction = 'GoToNextStep';
$js.OnFailAction = 'QuitWithFailure';
$js.JobStepFlags = '4'; #Include step output in history
$js.Create();

$jsid = $js.ID;
$job.ApplyToTargetServer($s.Name);
$job.StartStepID = $jsid;
$job.Alter();

$js = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobStep') ($job, 'Cycle Agent Error Log');
$js.DatabaseName = 'msdb';
$js.SubSystem = 'TransactSql';
$js.Command = 'EXEC sp_cycle_agent_errorlog';
$js.OnSuccessAction = 'QuitWithSuccess';
$js.OnFailAction = 'QuitWithFailure';
$js.JobStepFlags = '4'; #Include step output in history
$js.Create();

$jbsch = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobSchedule') ($job, 'Daily 12AM');
$jbsch.FrequencyTypes = "Daily";
$jbsch.FrequencySubDayTypes = "Once";
$ts1 = new-object System.TimeSpan(0, 0, 0);
$ts2 = new-object System.TimeSpan(23, 59, 59);
$jbsch.ActiveStartTimeOfDay = $ts1;
$jbsch.ActiveEndTimeOfDay = $ts2;
$jbsch.FrequencyInterval = 1;
$d = new-object System.DateTime(2014, 1, 1);
$jbsch.ActiveStartDate = $d;
$jbsch.Create();