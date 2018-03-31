$DBExcludeList = "master,model,msdb"
$DbIncludeList = "SQLDBA,test,test1"

$ExcludeList = $DBExcludeList.split(",")

$IncludeList = $DBIncludeList.split(",")

$Query = 
			"select substring(name,1,30) DBName, 
			case when databasepropertyex(name,'Status') <> 'ONLINE' then 'Database Status is ' + convert(char(15),databasepropertyex(name,'Status')) 
			      else 'Database Status is OK' end DatabaseStatus
			from sysdatabases
		    "

## Connection and Command stuff		         
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.connectionstring = "Server = dbinsight01; Database = master;Integrated Security = True; Connect Timeout=30"

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand $Query, $SqlConnection
$SqlCmd.CommandTimeout = 60
$SqlConnection.open()

$dr = $SqlCmd.ExecuteReader()

#######################################  
#### Exlude List		  
while($dr.Read())
  {
  	$DbName = $dr.GetValue(0)
	$Status = $dr.GetValue(1)
  	
	# don't process DB in Exludelist
	if ($ExcludeList -notcontains $DbName)
	    {
	      $msg = $msg + "`r`n  DbName : $DbName | $Status"
	      $RecordCount++;
		}
	else 
	    { write-host "--> Database $DbName is in the Exclude List - DB will be bypassed" }

  }
  Write-Host $msg

#######################################  
#### Include list

#while($dr.Read())
#  {
#  	$DbName = $dr.GetValue(0)
#	$Status = $dr.GetValue(1)
#  	
#	# process DBs in Include list only
#	if ($IncludeList -contains $DbName)
#	    {
#	      $msg = $msg + "`r`n  DbName : $DbName | $Status"
#	      $RecordCount++;
#		}
#	else 
#	    { write-host "--> Database $DbName is not in Include List - DB will be bypassed" }
#
#  }
#  Write-Host $msg
####################################### 

  $dr.Close()
  $dr.Dispose()