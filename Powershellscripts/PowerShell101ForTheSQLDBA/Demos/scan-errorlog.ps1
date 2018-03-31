#scan-errorlog.ps1
#This script scans through the current errorlog on the defined server and returns errors and their descriptions.
#
# Change log:
# September 14, 2012: Allen White
#   Initial Version
# September 19, 2012: Allen White
#   Added start date parameter to only return errors after specified date

param(
	[string]$inst=$null,
	[datetime]$startdt='1900-01-01'
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

# Connect to the specified SQL Server instance
$s = new-object ('Microsoft.SqlServer.Management.Smo.Server') $inst

# Get the current error log
$err = $s.ReadErrorLog()

# Initialize a new collection, then concatenate the errorlog properties together
$errlog = @()
$err | where {$_.LogDate -ge $startdt} | foreach {
	$errlog += [string] $_.LogDate + ' ' + $_.ProcessInfo + ' ' + $_.Text
	}

# Search the errorlog and return any error and the subsequent detailed message
$errlog | select-string -pattern 'Error:' -context 0,1
