<#
.SYNOPSIS 
Creates SQL Agent Job to delete old sql backup files.

.DESCRIPTION
Recursively prunes SQL backup files based on retention paramenter specified.
Executing account must have dbcreate or higher permissions to the SQL Server and R/W access to backup location.

.PARAMETER $SQLServer
SQL Server Name.  Defaults to local computer name.

.PARAMETER $Log
Path and name of log file for job step output.

.PARAMETER $Owner
Job owner account.

.PARAMETER $BackupUser
Login account to execute job.

.PARAMETER $BackupPwd
Login account password.

.PARAMETER $LoginType
SQL or WindowsUser
		
.PARAMETER $TLogDaysToKeep 
Number of days to keep Transaction Log backups

.PARAMETER $DiffDaysToKeep 
Number of days to keep Differential backups

.PARAMETER $FullDaysToKeep
Number of days to keep (daily) Full backups

.PARAMETER $FullWeeksToKeep
Number of weeks to keep (weekly) Full backups

.PARAMETER $WeekdayToKeep
Day of week for (weekly) Full backup

.PARAMETER $FullMonthsToKeep
Number of months to keep First Weekly Full backup of each month
.OUTPUTS
Text.

.EXAMPLE
Include example text here:
 .\Delete_SQL_Backups_Job.ps1 -SqlServer "SQL01" -Log "L:\SQLAgentLogs\Backups_Deleted.txt" -Owner "sa"

#>


Param ([string]$SQLServer = $env:COMPUTERNAME,
		[string]$Log = "L:\SQLAgentLogs\Backups_Deleted.txt",
        [string]$Owner = "",
        [string]$BackupUser = "",
        [string]$BackupPwd = "",
        [string]$LoginType = "WindowsUser",
        [string]$BackupPath = "\\server\share\*",
        [int]$TLogDaysToKeep = 4, # Number of days to keep Transaction Log backups
        [int]$DiffDaysToKeep = 14, # Number of days to keep Differential backups
        [int]$FullDaysToKeep = 14, # Number of days to keep (daily) Full backups
        [int]$FullWeeksToKeep = 8, # Number of weeks to keep (weekly) Full backups
        [string]$WeekdayToKeep = "Friday", # Day of week for (weekly) Full backup
        [int]$FullMonthsToKeep = 6 # Number of months to keep First Weekly Full backup of each month
)

$Script = 'Param ([string]$SQLServer = "' + $SQLServer + '",
		[string]$BackupPath = "' + $BackupPath + '", # Top level backup folder
        [int]$TLogDaysToKeep = ' + $TLogDaysToKeep + ', # Number of days to keep Transaction Log backups
        [int]$DiffDaysToKeep = ' + $DiffDaysToKeep + ', # Number of days to keep Differential backups
        [int]$FullDaysToKeep = ' + $FullDaysToKeep + ', # Number of days to keep (daily) Full backups
        [int]$FullWeeksToKeep = ' + $FullWeeksToKeep + ', # Number of weeks to keep (weekly) Full backups
        [string]$WeekdayToKeep = "' + $WeekdayToKeep + '", # Day of week for (weekly) Full backup
        [int]$FullMonthsToKeep = ' + $FullMonthsToKeep + ' # Number of months to keep First Weekly Full backup of each month
)

Import-Module SQLPS; # Remove Import-Module command for SQL 2008 R2 or earlier versions.
cd c:\;
ForEach ($backupfile in Get-ChildItem $BackupPath -Recurse -Include "*.bak", "*.trn") {
    $SQLQuery = "RESTORE HEADERONLY FROM DISK = ''" + $backupfile + "'' WITH FILE = 1";
    $backupinfo = Invoke-SqlCmd -Server $SQLServer -Query $SQLQuery;

    # Remove Transaction Log Backups older than $TLogDaysToKeep days
    If ($backupinfo.BackupType -eq 2 -and $backupinfo.BackupStartDate -le ((Get-Date).AddDays(-1 * $TLogDaysToKeep))) {
        write-output "Removing Log Backup: $backupfile";
        Remove-Item $backupfile
    }
    
    # Remove Differential Backups older than $DiffDaysToKeep days
    If ($backupinfo.BackupType -eq 5 -and $backupinfo.BackupStartDate -le ((Get-Date).AddDays(-1 * $DiffDaysToKeep))) {
        write-output "Removing Differential Backup: $backupfile";
        Remove-Item $backupfile
    }
    
    ## Remove Full Backups 
    # Exclude Full Backups newer than $FullDaysToKeep
    If ($backupinfo.BackupType -eq 1 -and $backupinfo.BackupStartDate -le ((Get-Date).AddDays(-1 * $FullDaysToKeep)) ) {
        # Exclude Full Backups on $WeekdayToKeep that are newer than $FullWeeksToKeep
        If ($backupinfo.BackupStartDate.DayofWeek -ne $WeekdayToKeep -or $backupinfo.BackupStartDate -le ((Get-Date).AddDays(-7 * $FullWeeksToKeep)) ) {  
            # Exclude First Weekly Full Backup of each month for $FullMonthsToKeep
            If ($backupinfo.BackupStartDate.DayofWeek -ne $WeekdayToKeep -or $backupinfo.BackupStartDate.Day -gt 7 -or $backupinfo.BackupStartDate -le ((Get-Date).AddMonths(-1 * $FullMonthsToKeep)) ) {  
                write-output "Removing Full Backup: $backupfile";
                Remove-Item $backupfile
            }
        }
    }

}'

# import sql cmdlets
Import-Module SQLPS;

# If running script on the sql server, set location to sql instance root
If ($SQLServer -eq $env:COMPUTERNAME) {
Set-Location SQLServer:\SQL\$env:COMPUTERNAME\Default
};

# create server login
$svr = new-object ('Microsoft.SqlServer.Management.Smo.Server') $SQLServer;
$login = new-object ('Microsoft.SqlServer.Management.Smo.Login') $svr, $BackupUser;
$login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::$LoginType;
$login.Create($BackupPwd);

# add login to role
$svrperm = $svr.Roles["dbcreator"];
$svrperm.AddMember($BackupUser);

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
$job = new-object ('Microsoft.SqlServer.Management.Smo.Agent.Job') ($svr.JobServer, 'Cleanup Backups');
$job.Description = 'Deletes old backup files.  Executing account must have dbcreator or higher permissions to the SQL Server and R/W access to backup location.';
$job.OwnerLoginName = $Owner;
$job.Create();
$job.EmailLevel =[Microsoft.SqlServer.Management.Smo.Agent.CompletionAction]::OnFailure;
$job.OperatorToEmail = 'SQLServerAdmins';
$job.Alter();

# create job step
$js = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobStep') ($job, 'Delete Backups');
$js.SubSystem = 'PowerShell';
$js.Command = $Script;
$js.OnSuccessAction = 'QuitWithSuccess';
$js.OnFailAction = 'QuitWithFailure';
$js.OutputFileName = $Log;
$js.JobStepFlags = '32'; #Include step output in history
$js.Create();

$jsid = $js.ID;
$job.ApplyToTargetServer($s.Name);
$job.StartStepID = $jsid;
$job.Alter();

# create schedule
$jbsch = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobSchedule') ($job, 'Daily 11:30PM');
$jbsch.FrequencyTypes = "Daily";
$jbsch.FrequencySubDayTypes = "Once";
$ts1 = new-object System.TimeSpan(23, 30, 0);
$ts2 = new-object System.TimeSpan(23, 59, 59);
$jbsch.ActiveStartTimeOfDay = $ts1;
$jbsch.ActiveEndTimeOfDay = $ts2;
$jbsch.FrequencyInterval = 1;
$d = new-object System.DateTime(2014, 1, 1);
$jbsch.ActiveStartDate = $d;
$jbsch.Create();