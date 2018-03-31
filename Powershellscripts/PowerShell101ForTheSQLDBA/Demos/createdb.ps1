#createdb.ps1
#Creates a new database using our specifications
#
# Change log:
# December 10, 2009: Allen White
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
$dbname = 'SMO_DB'

$syslogname = $dbname + '_SysData'
$applogname = $dbname + '_AppData'
$loglogname = $dbname + '_Log'

# Determine the default file locations
$fileloc = $s.Settings.DefaultFile
$logloc = $s.Settings.DefaultLog
if ($fileloc.Length -eq 0) {
    $fileloc = $s.Information.MasterDBPath
    }
if ($logloc.Length -eq 0) {
    $logloc = $s.Information.MasterDBLogPath
    }

$dbsysfile = $fileloc + '\' + $syslogname + '.mdf'
$dbappfile = $fileloc + '\' + $applogname + '.ndf'
$dblogfile = $logloc + '\' + $loglogname + '.ldf'

# Instantiate the database object and add the filegroups
$db = new-object ('Microsoft.SqlServer.Management.Smo.Database') ($s, $dbname)
$sysfg = new-object ('Microsoft.SqlServer.Management.Smo.FileGroup') ($db, 'PRIMARY')
$db.FileGroups.Add($sysfg)
$appfg = new-object ('Microsoft.SqlServer.Management.Smo.FileGroup') ($db, 'AppFG')
$db.FileGroups.Add($appfg)

# Create the file for the system tables
$dbdsysfile = new-object ('Microsoft.SqlServer.Management.Smo.DataFile') ($sysfg, $syslogname)
$sysfg.Files.Add($dbdsysfile)
$dbdsysfile.FileName = $dbsysfile
$dbdsysfile.Size = [double](5.0 * 1024.0)
$dbdsysfile.GrowthType = 'Percent'
$dbdsysfile.Growth = 25.0
$dbdsysfile.IsPrimaryFile = 'True'

# Create the file for the Application tables
$dbdappfile = new-object ('Microsoft.SqlServer.Management.Smo.DataFile') ($appfg, $applogname)
$appfg.Files.Add($dbdappfile)
$dbdappfile.FileName = $dbappfile
$dbdappfile.Size = [double](25.0 * 1024.0)
$dbdappfile.GrowthType = 'Percent'
$dbdappfile.Growth = 25.0
$dbdappfile.MaxSize = [double](100.0 * 1024.0)

# Create the file for the log
$dblfile = new-object ('Microsoft.SqlServer.Management.Smo.LogFile') ($db, $loglogname)
$db.LogFiles.Add($dblfile)
$dblfile.FileName = $dblogfile
$dblfile.Size = [double](10.0 * 1024.0)
$dblfile.GrowthType = 'Percent'
$dblfile.Growth = 25.0

# Create the database
$db.Create()

# Set the default filegroup to AppFG
$appfg = $db.FileGroups['AppFG']
$appfg.IsDefault = $true
$appfg.Alter()
$db.Alter()
