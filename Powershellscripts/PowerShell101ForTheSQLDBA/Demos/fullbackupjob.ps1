#fullbackupjob.ps1
#This script creates a SQL Server Agent job which will run a PowerShell script once a day to backup user databases.
#
# Change log:
# June 7, 2008: Allen White
#   Initial Version

# Load SMO assembly, and if we're running SQL 2008 DLLs load the SMOExtended and SQLWMIManagement libraries
$v = [System.Reflection.Assembly]::LoadWithPartialName( 'Microsoft.SqlServer.SMO')
if ((($v.FullName.Split(','))[1].Split('='))[1].Split('.')[0] -ne '9') {
  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended') | out-null
  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SQLWMIManagement') | out-null
  }

# Handle any errors that occur
Trap {
  # Handle the error
  $err = $_.Exception
  write-output $err.Message
  while( $err.InnerException ) {
  	$err = $err.InnerException
  	write-output $err.Message
  	};
  # End the script.
  break
  }

$s = new-object ('Microsoft.SqlServer.Management.Smo.Server') 'SQLTBWS\INST01'

$j = new-object ('Microsoft.SqlServer.Management.Smo.Agent.Job') ($s.JobServer, 'FullBackup') 
$j.Description = 'Backup User Databases'
$j.Category = '[Uncategorized (Local)]'
$j.OwnerLoginName = 'sa'
$j.Create() 
$jid = $j.JobID

$js = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobStep') ($j, 'Step 01')
$js.SubSystem = 'CmdExec'
$js.Command = 'powershell "& C:\Demos\backup.ps1"'
$js.OnSuccessAction = 'QuitWithSuccess' 
$js.OnFailAction = 'QuitWithFailure' 
$js.Create()
$jsid = $js.ID 

$j.ApplyToTargetServer($s.Name)
$j.StartStepID = $jsid
$j.Alter()

$jsch = new-object ('Microsoft.SqlServer.Management.Smo.Agent.JobSchedule') ($j, 'Sched 01')
$jsch.FrequencyTypes = 'Daily'
$jsch.FrequencySubDayTypes = 'Once'
$startts = new-object System.Timespan(2, 0, 0)
$jsch.ActiveStartTimeOfDay = $startts
$endts = new-object System.Timespan(23, 59, 59)
$jsch.ActiveEndTimeOfDay = $endts
$jsch.FrequencyInterval = 1
$jsch.ActiveStartDate = get-date
$jsch.Create()
