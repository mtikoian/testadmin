<#
.SYNOPSIS 
Creates SQL Agent Job to alert SQL Admins when disk space is low.

.DESCRIPTION

.PARAMETER $SQLServer
SQL Server Name.  Defaults to local computer name.

.PARAMETER $Owner
Job owner account.

.OUTPUTS
Text.

.EXAMPLE
Include example text here:
 .\Disk_Space_Alert.ps1 -SqlServer "SQL01" -Owner "sa"

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
	
# create job
$svr = new-object ('Microsoft.SqlServer.Management.Smo.Server') $SQLServer;
$job = new-object ('Microsoft.SqlServer.Management.Smo.Agent.Job') ($svr.JobServer, 'Disk Space Alert');
$job.Description = 'Alerts SQL Admins when disk space is low.';
$job.OwnerLoginName = $Owner;
$job.Create();
$job.EmailLevel =[Microsoft.SqlServer.Management.Smo.Agent.CompletionAction]::OnFailure;
$job.OperatorToEmail = 'SQLServerAdmins';
$job.Alter();

$js = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobStep') ($job, 'Email Alert');
$js.SubSystem = 'TransactSql';
$js.Command = 'SET NOCOUNT ON
DECLARE @operator nvarchar(100)
SET @operator = (SELECT email_address FROM msdb.dbo.sysoperators WHERE name = ''SQLServerAdmins'')
CREATE TABLE #tbldiskSpace
(
DriveName VARCHAR(3),
FreeSpace VARCHAR(10)
)

CREATE TABLE ##tblAlert
(Drive VARCHAR(3),
Threshold VARCHAR(10),
FreeSpace VARCHAR(10)
)

INSERT INTO #tbldiskSpace EXEC master..XP_FixedDrives

IF (SELECT CAST([FreeSpace] AS INT)/1024 FROM #tbldiskSpace WHERE [DriveName] = ''C'') < 5
	BEGIN
	INSERT INTO ##tblAlert VALUES (''C'', '' 5 GB'', (SELECT ROUND(CAST([FreeSpace] AS INT)/1024, 1) FROM #tbldiskSpace WHERE [DriveName] = ''C''));
	END

IF (SELECT CAST([FreeSpace] AS INT)/1024 FROM #tbldiskSpace WHERE [DriveName] = ''E'') < 10
	BEGIN
	INSERT INTO ##tblAlert VALUES (''E'', ''10 GB'', (SELECT ROUND(CAST([FreeSpace] AS INT)/1024, 1) FROM #tbldiskSpace WHERE [DriveName] = ''E''));
	END

IF (SELECT CAST([FreeSpace] AS INT)/1024 FROM #tbldiskSpace WHERE [DriveName] = ''F'') < 15
	BEGIN
	INSERT INTO ##tblAlert VALUES (''F'', ''15 GB'', (SELECT ROUND(CAST([FreeSpace] AS INT)/1024, 1) FROM #tbldiskSpace WHERE [DriveName] = ''F''));
	END

IF (SELECT CAST([FreeSpace] AS INT)/1024 FROM #tbldiskSpace WHERE [DriveName] = ''G'') < 10
	BEGIN
	INSERT INTO ##tblAlert VALUES (''G'', ''10 GB'', (SELECT ROUND(CAST([FreeSpace] AS INT)/1024, 1) FROM #tbldiskSpace WHERE [DriveName] = ''G''));
	END

IF (SELECT CAST([FreeSpace] AS INT)/1024 FROM #tbldiskSpace WHERE [DriveName] = ''H'') < 15
	BEGIN
	INSERT INTO ##tblAlert VALUES (''H'', ''15 GB'', (SELECT ROUND(CAST([FreeSpace] AS INT)/1024, 1) FROM #tbldiskSpace WHERE [DriveName] = ''H''));
	END

IF (SELECT CAST([FreeSpace] AS INT)/1024 FROM #tbldiskSpace WHERE [DriveName] = ''I'') < 10
	BEGIN
	INSERT INTO ##tblAlert VALUES (''I'', ''10 GB'', (SELECT ROUND(CAST([FreeSpace] AS INT)/1024, 1) FROM #tbldiskSpace WHERE [DriveName] = ''I''));
	END

IF (SELECT CAST([FreeSpace] AS INT)/1024 FROM #tbldiskSpace WHERE [DriveName] = ''L'') < 5
	BEGIN
	INSERT INTO ##tblAlert VALUES (''L'', ''5 GB'', (SELECT ROUND(CAST([FreeSpace] AS INT)/1024, 1) FROM #tbldiskSpace WHERE [DriveName] = ''L''));
	END

IF (SELECT CAST([FreeSpace] AS INT)/1024 FROM #tbldiskSpace WHERE [DriveName] = ''M'') < 5
	BEGIN
	INSERT INTO ##tblAlert VALUES (''M'', '' 5 GB'', (SELECT ROUND(CAST([FreeSpace] AS INT)/1024, 1) FROM #tbldiskSpace WHERE [DriveName] = ''M''));
	END

IF (SELECT COUNT([Drive]) FROM ##tblAlert) > 0
	BEGIN
	IF (SELECT COUNT([FreeSpace]) FROM ##tblAlert WHERE [FreeSpace] < 1) > 0
		BEGIN
		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = ''SQL_Admin'',
		@recipients = @operator,
		@query = ''SELECT * FROM ##tblAlert'',
		@importance = ''High'',
		@subject = ''***** ' + $SQLServer + ' Disk Space Critical *****'';
		END
	ELSE
		BEGIN
		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = ''SQL_Admin'',
		@recipients = @operator,
		@query = ''SELECT * FROM ##tblAlert'',
		@subject = ''***** ' + $SQLServer + ' Disk Space Low *****'';
		END
	END

DROP TABLE ##tblAlert;
DROP TABLE #tbldiskSpace;';
$js.OnSuccessAction = 'QuitWithSuccess';
$js.OnFailAction = 'QuitWithFailure';
$js.Create();

$jsid = $js.ID;
$job.ApplyToTargetServer($s.Name);
$job.StartStepID = $jsid;
$job.Alter();

$jbsch = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobSchedule') ($job, 'Hourly');
$jbsch.FrequencyTypes = "Daily";
$jbsch.FrequencySubDayTypes = "Hour";
$jbsch.FrequencySubDayinterval = 1;
$ts1 = new-object System.TimeSpan(0, 0, 0);
$ts2 = new-object System.TimeSpan(23, 59, 59);
$jbsch.ActiveStartTimeOfDay = $ts1;
$jbsch.ActiveEndTimeOfDay = $ts2;
$jbsch.FrequencyInterval = 1;
$d = new-object System.DateTime(2014, 1, 1);
$jbsch.ActiveStartDate = $d;
$jbsch.Create();