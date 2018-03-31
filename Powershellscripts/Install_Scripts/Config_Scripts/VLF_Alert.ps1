<#
.SYNOPSIS 
Creates SQL Agent Job to alert SQL Admins when database Virtual Log File count is high.

.DESCRIPTION

.PARAMETER $SQLServer
SQL Server Name.  Defaults to local computer name.

.PARAMETER $Owner
Job owner account.

.OUTPUTS
Text.

.EXAMPLE
Include example text here:
 .\VLF_Alert.ps1 -SqlServer "SQL01" -Owner "sa"

#>

Param ([string]$SQLServer = $env:COMPUTERNAME,
	    [string]$SQLInstance = "Default",
        [string]$Owner = ""
)

# import sql cmdlets
Import-Module SQLPS;

# If running script on the sql server, set location to sql instance root
If ($SQLServer -eq $env:COMPUTERNAME) {
Set-Location SQLServer:\SQL\$SQLServer`\$SQLInstance
};

If ($SQLInstance -ne "Default") {
[string]$ServerInstance = $SQLServer + "\" + $SQLInstance;
}
Else {
[string]$ServerInstance = $SQLServer
};

If ($Owner -eq "") { # if $Owner equals blank, get sa account name
$query = '"SELECT [name] FROM master.sys.syslogins WHERE [sid] = 0x01;"';
$P_query = "Invoke-Sqlcmd -ServerInstance $ServerInstance -Query $query";
$sa = Invoke-expression $P_query;
$Owner = $sa.Name;
}
	
[string]$cmd = @'
SET NOCOUNT ON
DECLARE @operator nvarchar(100),
		@maxVLF int,
		@SQL varchar(100),
		@servername varchar(50),
		@es varchar(100)

SET @maxVLF = 30;
SET @operator = (SELECT email_address FROM msdb.dbo.sysoperators WHERE name = 'SQLServerAdmins');
SET @SQL = 'SELECT * FROM ##VLFCountResults WHERE [VLFCount] >= ' + CAST(@maxVLF AS varchar(5));
SET @es = '***** ' + @@SERVERNAME + 'Max VLF Count Alert*****'

-- (adapted from Michelle Ufford) 
CREATE TABLE #VLFInfo (RecoveryUnitID int, FileID  int,
					   FileSize bigint, StartOffset bigint,
					   FSeqNo      bigint, [Status]    bigint,
					   Parity      bigint, CreateLSN   numeric(38));
	 
CREATE TABLE ##VLFCountResults(DatabaseName sysname, VLFCount int);
	 
EXEC sp_MSforeachdb N'Use [?]; 

				INSERT INTO #VLFInfo 
				EXEC sp_executesql N''DBCC LOGINFO([?])''; 
	 
				INSERT INTO ##VLFCountResults 
				SELECT DB_NAME(), COUNT(*) 
				FROM #VLFInfo; 

				TRUNCATE TABLE #VLFInfo;'
	 
IF (SELECT MAX([VLFCount]) FROM ##VLFCountResults) >= @maxVLF
	BEGIN
		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'SQL_Admin',
		@recipients = @operator,
		@query = @SQL,
		@subject = @es;
	END;
	 
DROP TABLE #VLFInfo;
DROP TABLE ##VLFCountResults;
'@;

# create job
$svr = new-object ('Microsoft.SqlServer.Management.Smo.Server') $ServerInstance;
$job = new-object ('Microsoft.SqlServer.Management.Smo.Agent.Job') ($svr.JobServer, 'VLF Alert');
$job.Description = 'Alerts SQL Admins when the number of Virtual Log Files in a database is high.';
$job.OwnerLoginName = $Owner;
$job.Create();
$job.EmailLevel =[Microsoft.SqlServer.Management.Smo.Agent.CompletionAction]::OnFailure;
$job.OperatorToEmail = 'SQLServerAdmins';
$job.Alter();

$js = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobStep') ($job, 'Email VLF Count');
$js.SubSystem = 'TransactSql';
$js.Command = $cmd;
$js.OnSuccessAction = 'QuitWithSuccess';
$js.OnFailAction = 'QuitWithFailure';
$js.Create();

$jsid = $js.ID;
$job.ApplyToTargetServer($s.Name);
$job.StartStepID = $jsid;
$job.Alter();

$jbsch = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobSchedule') ($job, 'Daily 3AM');
$jbsch.FrequencyTypes = "Daily";
$jbsch.FrequencySubDayTypes = "Once";
$jbsch.FrequencySubDayinterval = 1;
$ts1 = new-object System.TimeSpan(3, 0, 0);
$ts2 = new-object System.TimeSpan(23, 59, 59);
$jbsch.ActiveStartTimeOfDay = $ts1;
$jbsch.ActiveEndTimeOfDay = $ts2;
$jbsch.FrequencyInterval = 1;
$d = new-object System.DateTime(2014, 1, 1);
$jbsch.ActiveStartDate = $d;
$jbsch.Create();