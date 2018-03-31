#####################################################################################
## This function displays to the console and write the message to a log file

function DispMessage ([string] $Message, [boolean] $ErrorFlag=$False)
{
if ($ErrorFlag)
   {
     Write-Host $Message -foreground yellow
   }
else
   {
     Write-Host $Message
   }
   
}
#####################################################################################
## This function checks the execution success of SQL Script

function CheckSQLScriptError ([string] $LastEXC, [string] $LastCommand, [string] $Result, [string] $sqlfile)
{
 

  if ($LastEXC -ne 0 -or !$LastCommand)
	 {
               
       DispMessage ""
	   DispMessage "## Error: SQL Script Execution Failed - $sqlfile" $True
       DispMessage "## Error: Check for errors in the execution log file" $True
	   exit
	}
  else
	{
	  DispMessage ""
      DispMessage "---> SQL Script $sqlfile Completed OK" 
      DispMessage ""
	}
}

#####################################################################################
## This function checks the execution success of SQL statement

function CheckSQLStmtError ([string] $LastEXC, [string] $LastCommand, [string] $Result)
{
 

  if ($LastEXC -ne 0 -or !$LastCommand)
	 {
               
	   DispMessage "## Error: SQL Statement Execution Failed" $True
       DispMessage "## Error Message -> $Result" $True
	   exit
	}
  else
	{
	  DispMessage ""
      DispMessage "---> SQL Statement Completed OK" 
      DispMessage ""
	}
}

#####################################################################################
## This function checks the execution success of a executable

function CheckExeError ([string] $LastEXC, [string] $LastCommand, [string] $Result, [string] $Exefile)
{
 

  if ($LastEXC -ne 0 -or !$LastCommand)
	 {
               
       DispMessage ""
	   DispMessage "## Error: Exe file Execution Failed - $Exefile" $True
       DispMessage "## Error: Check for errors in the execution log file" $True
	   exit
	 }
	else
	 {
	  DispMessage ""
      DispMessage "---> Exe File $Exefile Completed OK" 
      DispMessage ""
	 }
}

# Run information
$ImportDir = "C:\APresentation\SQLSat382PowershellGems\13_LoadPerfData"
$CounterFile = "C:\APresentation\SQLSat382PowershellGems\13_LoadPerfData\counters.txt"
$SQLServer = "dbinsight01"
$TruncatePerfSum = $True  #truncate summary table

# Process Perfmon log files using Relog.exe 
$fileList = get-childitem "$ImportDir" | where {$_.extension -eq ".blg"} 
	foreach ($file in $fileList)
	{
	  $PMFile = $file.fullname
	  Write-Host "--> Processing file -> $PMFile"
      & relog "$PMFile" -cf $CounterFile -f SQL -o SQL:SQLPerf!SQLPerf  ## ODBC configuration called SQLPerf for SQLPerf database
	  CheckExeError $LastExitCode $? $result "Relog $PMFile"
	}

## Truncate int Perfsummary
if ($TruncatePerfSum)
{
  $SQLText = "truncate table perfsummary;"
  
  Dispmessage "---> Running -> $SQLText"
  
  $result = & C:\"Program Files"\"Microsoft SQL Server"\110\Tools\Binn\sqlcmd.exe -S $SQLServer -Q "$SQLText" -E -b -d "SQLPerf"
  CheckSQLStmtError $LastExitCode $? $Result
}

## Import int Perfsummary
$SQLText = "insert into PerfSummary select 'Log1' LogId, ObjectName + ' ' + CounterName + ' ' + isnull(InstanceName, '') as Counter, convert(datetime, rtrim(convert(varchar(23),CounterDateTime))) CounterDateTime, CounterValue from dbo.CounterData a inner join dbo.CounterDetails b on a.CounterId = b.Counterid order by CounterDateTime, Counter"

Dispmessage "---> Running -> $SQLText"

$result = & C:\"Program Files"\"Microsoft SQL Server"\110\Tools\Binn\sqlcmd.exe -S $SQLServer -Q "$SQLText" -E -b -d "SQLPerf"
CheckSQLStmtError $LastExitCode $? $Result