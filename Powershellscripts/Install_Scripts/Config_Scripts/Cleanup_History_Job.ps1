<#
.SYNOPSIS 
Creates a SQL Agent Job to run the Cleanup History SSISDB package.

.DESCRIPTION

.PARAMETER $SQLServer
SQL Server Name.  Defaults to local computer name.

.PARAMETER $Owner
Job owner account.

.OUTPUTS
Text.

.EXAMPLE
Include example text here:
 .\Cleanup_History_Job.ps1 -SqlServer "SQL01" -Owner "sa"

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

# Create Job Container
$svr = new-object ('Microsoft.SqlServer.Management.Smo.Server') $SQLServer;
$job = new-object ('Microsoft.SqlServer.Management.Smo.Agent.Job') ($svr.JobServer, 'Cleanup History');
$job.Description = 'Runs the Cleanup History SSISDB package.';
$job.OwnerLoginName = $Owner;
$job.Create();
$job.EmailLevel =[Microsoft.SqlServer.Management.Smo.Agent.CompletionAction]::OnFailure;
$job.OperatorToEmail = 'SQLServerAdmins';
$job.Alter();

# Create Job Step
$js = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobStep') ($job, 'Run Cleanup History Package');
$js.SubSystem = 'SSIS';
$js.Command = '/ISSERVER "\"\SSISDB\Maintenance Packages\Cleanup History\Package.dtsx\"" /SERVER ' + $SQLServer + ' /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E';
$js.OnSuccessAction = 'QuitWithSuccess';
$js.OnFailAction = 'QuitWithFailure';
$js.JobStepFlags = '32';
$js.Create();

$jsid = $js.ID;
$job.ApplyToTargetServer($s.Name);
$job.StartStepID = $jsid;
$job.Alter();

# Create Schedule
$jbsch = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobSchedule') ($job, 'Saturday 4AM');
$jbsch.FrequencyTypes = [Microsoft.SqlServer.Management.Smo.Agent.FrequencyTypes]::Weekly;
$jbsch.FrequencyInterval = [Microsoft.SqlServer.Management.Smo.Agent.WeekDays]::Saturday;
$jbsch.FrequencyRecurrenceFactor = 1;
$ts1 = new-object System.TimeSpan(4, 0, 0);
$ts2 = new-object System.TimeSpan(23, 59, 59);
$jbsch.ActiveStartTimeOfDay = $ts1;
$jbsch.ActiveEndTimeOfDay = $ts2;
$d = new-object System.DateTime(2014, 1, 1);
$jbsch.ActiveStartDate = $d;
$jbsch.Create();
