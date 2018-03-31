#getdiskusage.ps1
#This script gets disk usage from the specified SQL Server instance.
#
# Change log:
# October 30, 2010: Allen White
#   Initial Version

# Get the SQL Server instance name from the command line
param(
  [string]$inst=$null
  )

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

$sqlsrv = 'SQLTBWS\INST01'
$destdb = 'ServerAnalysis'

# Connect to the requested instance
$s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $inst

$q = "declare @instance_id int; exec [Analysis].[getInstanceID]"
$q = $q + " @instance_id OUTPUT"
$q = $q + ", @Parent='" + $s.Information.Parent + "'
$q = $q + "; select @instance_id as instance_id"
$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
$instance_id = $res.instance_id

# Grab the databases collection for the instance
$dbs = $s.Databases

# Cycle through and record the size and space available data for each database
$dbs | foreach {
	$db = $_
	if ($db.IsAccessible -eq $True) {
		$q = "declare @database_id int; exec [Analysis].[getDatabaseID]"
		$q = $q + " @database_id OUTPUT, @instance_id=" + [string]$instance_id
		$q = $q + ", @Name='" + $db.Name + "'"
		$q = $q + "; select @database_id as database_id"	
		$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
		$dbid = $res.database_id

		$q = "exec [Analysis].[insDatabaseUsage]"
		$q = $q + ", @database_id=" + [string]$dbid
		if ($db.Size.length -ne 0) {
			$q = $q + ", @Size=" + [string]$db.Size
			}
		if ($db.SpaceAvailable.length -ne 0) {
			$q = $q + " @SpaceAvailable=" + [string]$db.SpaceAvailable
			}
		$q = $q + ";"	

		$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
		}
	}
