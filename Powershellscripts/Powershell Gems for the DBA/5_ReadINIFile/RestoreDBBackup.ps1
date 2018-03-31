#****************************************************************************************************************************
#** RestoreDBBackup.ps1
#** -----------------
#** Performs a database restore to the specified destination SQL Server (typically a reporting server). 
#** The restore process restores the latest backup file in the backup directory for each database specified in the INI file. The database backup file name must contain
#** the DBName specified in the INI.
#** Database restart processing and retries are available. A restore is based on an include list 
#** of Dbs in the INI config file. It also kills all connections specific to the database to be restored.  
#**	The final recovery state of the restored database can be specified in the INI file. IE recover, No recover or Standby. Default is  Recover
#**               
#** The RestoreDBBackup INI file and initial parameters passed drives the functionality of the RestoreDBBackup.ps1 script. The INI file has a name format of
#** RestoreDbBackup.ini. 
#** 
#** Parameters:
#**------------------
#** SQLServer    - SQL Server name  (Mandatory) - SQLServer name where script is being run.
#** ConfigFile   - Full file specification to the RestoreDBBackup INI file (Mandatory)
#** LogDir       - Log directory where the RestoreDBBackup log file and restart files will be written. eg c:\sqljoblogs
#** DebugMode    - outputs more messages to the log file. Especially around database and restarts.
#**
#** Logging
#** ------------------
#** The script creates a new log for each run under the LOGDIR folder. The log file name format is
#** RestoreDBBackup_<SQLInstance>_<yyyymmddhhmmss>.log
#**
#** Mod History:
#** -------------------
#** Version Date        Who   Description
#** 1.0     17/02/2015  RR    Initial Coding

param (
	   [string] $SQLServer,
	   [string] $Configfile,  # full path usually local
	   [string] $LogDir = "c:\SQLJobLogs",      # Must use a Share if running on a cluster.
	   [switch] $DebugMode
)

##############################################################################################################################
### Functions
##############################################################################################################################

##############################################################################################################################
### DisplayUsage Function 

Function DisplayUsage ()
{
 Write-Host " " 
 Write-Host "Run Command Format is ...." -foreground green
 Write-Host "powershell.exe c:\SQLRDS\RestoreDBBackup.ps1 " -foreground green
 Write-Host "   -SQLSERVER <SQLServer> " -foreground green
 Write-Host "   -CONFIGFILE <ConfigFileName>  " -foreground green
 Write-Host "   -LOGDIR <LogDir>   " -foreground green
}

Function ExitWithError ([int] $ErrorFlag, [Object] $SQLConn = $null )
{
  if ($SQLConn)
     {
      remove-SQLConnection $SQLConn
	 }
  Dispmessage "## Script is exiting with errors" $true	 
	 	 
  exit $ErrorFlag
}

#####################################################################################
## This function removes all spaces in a string

Function Remove-Spaces {
  param($target)

  begin {
    filter Do-RemoveSpaces { $_ -replace "\s *", "" }
  }

  process { if($_) { $_ | Do-RemoveSpaces } }

  end { if($target) {$target | Do-RemoveSpaces} }
}

#####################################################################################
## This function checks if a file exists, if it does returns $true else returns $false

Function CheckFileExists ( [string] $Filespec)
{
 if (Test-Path -path $Filespec -pathtype leaf) 
      {
        DispMessage "---> File exists -> $Filespec"
        return $True
      }
   else 
      {
        DispMessage "---> File not found -> $Filespec" $True
        return $False
      }
}

##############################################################################################################################
## Validate parameters
function ValidateParams ([string] $ServerOrVirtualName, [string] $ConfigFile, [string] $LogDir) 
{
  
    if (!$SQLServer)
	   {
        Write-Host "## Error: SQLServer parameter is blank"  -foreground yellow
		DisplayUsage
        Exit 1
       }  
	
    if (Test-Path -Path "$ConfigFile" -pathtype leaf)
	      { 
	        Write-Host "---> Maint Task Config file Exists -> $ConfigFile"
	        Write-Host " "
	      }
	    else 
	      {
	        Write-Host "## Error: Restore DB Task Config file -> $ConfigFile not found"  -foreground yellow
			DisplayUsage
	        Exit 1
	      }
	
	
	if (!$LogDir)
	   {
        Write-Host "## Error: Log Dir parameter is blank"  -foreground yellow
		DisplayUsage
        Exit 1
       }

	if (Test-Path("$LogDir"))
       { 
        Write-Host "---> Log Dir Exists -> $LogDir"
        Write-Host " "
       }
    else 
       {
        Write-Host "## Error: Log Dir -> $LogDir not found"  -foreground yellow
		DisplayUsage
        Exit 1
       }
}

##############################################################################################################################
## Display message in console and write to log file

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
   
Add-Content $logfile $Message
}

#####################################################################################
## This function checks if the passed variable is numeric

function isNumeric ($x) 
{    $x2 = 0    
     $isNum = [System.Int32]::TryParse($x, [ref]$x2)    
     return $isNum
}

#####################################################################################
## This function removes all spaces in a string
Function Remove-Spaces {
  param($target)

  begin {
    filter Do-RemoveSpaces { $_ -replace "\s *", "" }
  }

  process { if($_) { $_ | Do-RemoveSpaces } }

  end { if($target) {$target | Do-RemoveSpaces} }
}

#####################################################################################
## This function checks if a file exists, if it does returns $true else returns $false

Function CheckFileExists ( [string] $Filespec)
{
 if (Test-Path -path $Filespec -pathtype leaf) 
      {
        DispMessage "---> File exists -> $Filespec"
        return $True
      }
   else 
      {
        DispMessage "---> File not found -> $Filespec" $True
        return $False
      }
}

#####################################################################################
## This function gets the file name part of full file specification

Function Get-FileName {  
     Param([string]$path)  
     $names = $path.Split('\\')  
     $names[$names.Count - 1]  
 } 

#####################################################################################
## This function reads ini file and creates hash table key=value pairs

# Get-Settings Reads an ini file into a hash table
# Each line of the .ini File will be processed through the pipe.
# The splitted lines fill a hastable. Empty lines and lines beginning with
# '[' or ';' are ignored. $ht returns the results as a hashtable.
function ReadIniFile()
{
	BEGIN
	{
		$ht = @{}
	}
	PROCESS
	{
		[string[]] $key = [regex]::split($_,'=')
		if(($key[0].CompareTo("") -ne 0) `
		-and ($key[0].StartsWith("[") -ne $True) `
		-and ($key[0].StartsWith(";") -ne $True))
		{
            $IniName = $key[0].trim()
            if ($key[1]) {$IniValue = $key[1].trim()} else {$IniValue = $key[1]}
			$ht.Add($IniName, $IniValue)
		}
	}
	END
	{
		return $ht
	}
}

#####################################################################################
## This function validates the INI file keys and values

Function ValidateINI ([Object] $htIni)
{
## Check Ini file keys are valid - need commas at beginning and end of string of each key.	
	$inilist = ",StatementTimeout,ProcessRetries,RetryDelaySec,`
,BDBackupDir,RDRestoreTLogPath,RDRestoreDBs,RDRestoreSQLServer,`
,RDRestoreDataPath,RDRestoreDBState,ConnectTimeout,"
		
	foreach ($I in $htIni.keys)
				{   
					$str = $I.trim()
					if ("$IniList" -notlike "*,$str,*")
						{
							DispMessage ""
							DispMessage "## Error: DBMaint INI File has invalid Key -> $str" $True
							DispMessage "## Valid INI File Keys are ->" $True
							DispMessage $inilist.replace(","," * ")
							ExitWithError 1
						} 
				}

	# Check if all ini file keys are in the INI file
	$IniListArray = $inilist.split(",") | Where-Object { $_ -like "*[a-z|A-Z]*"}  ## put Mandatory list of keys in array
	foreach ($str in $IniListArray) 
	{
	if ($htIni.keys -notcontains $str  )  #if the mandatory ini key value is not in the keys read in then error.
		{
		  DispMessage "## Error: Mandatory Key not found in the INI File -> $str" $true
		  ExitWithError 1
	    }
	}
	
	# Verify that a numeric value is specified for numeric INI file fields
	foreach ($I in $htIni.keys)
        	{   
        		$str = $I.trim()
        		if ($str -like "*no" -or $str -like "*limit" -or $str -eq "StatementTimeOut" `
				     -or $str -eq "ProcessRetries" -or $str -eq "RetryDelaySec" -or $str -eq $ConnectTimeout)
                      {
						if (-not (isNumeric($htIni.item("$str"))))   # $str is the key name, check that the value for the key is numeric
						   {
						     DispMessage "## Error: $Str value is not numeric -> $($htIni.item("$str"))" $true
							 ExitWithError 1
						   }
        			  } 
        	}

				
			
	# Make sure the RDRestoreDBState INI field has valid restore state values			
	if ("RECOVERY,NORECOVERY,STANDBY" -notlike "*$($($htIni.item("RDRestoreDBState")).toupper())*")
	{
	   DispMessage "##Error: RDRestoreDBState has an invalid value -> $($htIni.item("RDRestoreDBState"))" $true
	   DispMessage "Valid Values are (RECOVERY,NORECOVERY,STANDBY)" $true
	   ExitWithError 1
	}
		

}



####################################################################################
## This function load the SMO assemblies.

Function LoadUPSMOAssembly ()
{
 try 
     {
    # Load SMO assembly, and if we're running SQL 2008 DLLs load the SMOExtended and SQLWMIManagement libraries
	$v = [System.Reflection.Assembly]::LoadWithPartialName( 'Microsoft.SqlServer.SMO')
	
	if ((($v.FullName.Split(','))[1].Split('='))[1].Split('.')[0] -ne '9') 
	   {
	     [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended') | out-null
	     [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SQLWMIManagement') | out-null
       }
	 }
  catch
     {
        DispMessage "## Error: Loading SMO Assembly Failed" $True
        DispMessage "## SQL Error Message -> $error[0]" $True
        ExitWithError 1
     }
}

####################################################################################
## This function compares two arrays and returns the result Array 1 - Array 2.

function Compare-Arrays {
    param(
        [Parameter(Mandatory=$true)][Object[]]$a1,
        [Parameter(Mandatory=$true)][Object[]]$a2
    )
    @(Compare-Object -ReferenceObject $a1 -DifferenceObject $a2 -IncludeEqual | 
        % -begin { 
            $toreturn = New-Object PSObject -Property @{Left=@(); Equal=@()} 
          } -process { 
            if ($_.SideIndicator -eq "<=" -and $_.SideIndicator -ne "==") { $toreturn.Left += $_.InputObject }
			elseif ($_.SideIndicator -eq "==") {   $toreturn.Equal += $_.InputObject }

          } -end { 
            $toreturn 
          }
    )
}



####################################################################################
## This function creates and returns a new SMO connection using Windows Authentication
## of the currently logged in Windows Account context for the Restore Server.

function New-RDSQLConnection ([string] $SQLServer, [int] $StatementTimeout, [int] $ConnectTimeout)
{
	try
	  {
	    Dispmessage "-> Creating a new SQL Connection for Restore SQL Server"
		$RDSQLConn = new-object ('Microsoft.SqlServer.Management.Smo.Server') $SQLServer
		$RDSQLConn.connectioncontext.applicationName = "RestoreDBBackup"
		$RDSQLConn.connectioncontext.connectTimeout = $ConnectTimeout
		$RDSQLConn.ConnectionContext.StatementTimeout = $StatementTimeout 
		$RDSQLConn.connectioncontext.connect()
		return $RDSQLConn
	  }
	catch
	  {
	    $ex = $_.Exception
	    Dispmessage "##Error: SQL Connection Check failed" $true
		Dispmessage $ex.message $true
	    $ex = $ex.InnerException
	    while ($ex.InnerException)
	    {
	        Dispmessage $ex.InnerException.message $true
	        $ex = $ex.InnerException
	    };
		ExitWithError 1 $RDSQLConn
	  }
}

####################################################################################
## This function checks if the SMO connect is opened if not it reconnects
## Some types of integrity check errors causes a SMO connection to get disconnected

function Check-SQLConnection ( [Object] $SQLConn)
{
try
  {
	if ($SQLConn.connectioncontext.isopen -eq $true) 
	    {
	     if ($Debugmode) {Dispmessage "----> SQL Connection is available"}
	    } 
	else 
		{
		 Dispmessage "----> SQL Connection Unavailable - Reconnecting"
	     $SQLConn.connectioncontext.connect()
	    }
  }
catch
  {
    $ex = $_.Exception
    Dispmessage "##Error: SQL Connection Check failed" $true
	Dispmessage $ex.message $true
    $ex = $ex.InnerException
    while ($ex.InnerException)
    {
        Dispmessage $ex.InnerException.message $true
        $ex = $ex.InnerException
    };
	ExitWithError 1 $SQLConn
  }
}

####################################################################################
## This function disconnects a SMO connection and removes the connection variable.

function Remove-SQLConnection ([Object] $SQLConn)
{  
 try 
   {
    Dispmessage "----> Removed the SQL Connection"
	if ($SQLConn.connectioncontext.isopen -eq $true)
	   {
	     $SQLConn.connectioncontext.disconnect()
	   }
    #Remove-Variable -Name $SQLConn -Scope 1
	$SQLConn = $null
   }
 catch
  {
    $ex = $_.Exception
    Dispmessage "##Error: SQL Connection disconnection failed" $true
	Dispmessage $ex.message $true
    $ex = $ex.InnerException
    while ($ex.InnerException)
    {
        Dispmessage $ex.InnerException.message $true
        $ex = $ex.InnerException
    };
	Exit 1
  }
}

####################################################################################
## This function checks a SMO error, if found, it displays the error and sets the 
## DBMaintErrorFlag to true to flag an overall error for the script.

function ShowError ($DbMaintErrObj)
{
        $ex = $DbMaintErrObj.Exception
        Dispmessage $ex.message $true
        $ex = $ex.InnerException		
        while ($ex.InnerException)
        {  
            Dispmessage $ex.InnerException.message $true
            $ex = $ex.InnerException
        }
		
}


####################################################################################
## This function prepares for and executes the required Database/Diff/Tlog restores.
## The RDRestoreDiffTLogs equal "Y" then function will check for the latest Diff backup
## If found then if finds all TL backups since the Diff backup, if not found, if finds 
## all TLOG backups since database backup. If no Diff or TLOG backups are found then
## on the database restore is performed.

Function PerformRestoreDbForReporting ([string] $SQLServerName, [string] $DbName, [Object] $RDSQLConn, [Object] $IniHashtable, [Ref] $DBMaintErrorFlag)
{
   $DBMaintErrorFlag.value = "DBProcessed"
   
    ## need to remove [] brackets 
	if ($dbname.substring(0,1) -eq "[") {$dbname = $dbname.replace("[","").replace("]","") }

    [string] $RestoreSQLServer  = $IniHashtable.item("RDRestoreSQLServer")
	[string] $RestoreDataPath  = $IniHashtable.item("RDRestoreDataPath")
	[string] $RestoreTLogPath   = $IniHashtable.item("RDRestoreTLogPath")
	[string] $RestoreDBState    = $IniHashtable.item("RDRestoreDBState")
	
	# get all backups root dirs
	[string] $DBBackupDir = $IniHashtable.item("BDBackupDir").toupper()


	[int] $RetryCount  = $IniHashtable.item("ProcessRetries")
    [int] $RetryDelaySec  = $IniHashtable.item("RetryDelaySec")
	   
	Dispmessage ""
	Dispmessage "-> Perform Restore Database"
	Dispmessage "--> Processing Options..."	  
	Dispmessage "---> RetryCount = $RetryCount | RetryDelaySec = $RetryDelaySec"
	Dispmessage "---> RestoreSQLServer = $RestoreSQLServer | RestoreDataPath = $RestoreDataPath"
	Dispmessage "---> RestoreTLogPath = $RestoreTLogPath | RestoreDBState = $RestoreDBState" 
	Dispmessage "---> DB BackupDir = $DBBackupDir  "

	Dispmessage "-------------------------------------------"
	
	# Must have paths for files to restore.	
	If (!$RestoreDataPath -or !$RestoreTLogPath)
	   {
	     Dispmessage "## Error: The Restore Database Data or TLog Path INI field is blank"
		 $DBMaintErrorFlag.value = "ProcFlagError"
		 return
	   }
   
   #----------------------------------------------------------------------------   
   #Get lastest full database backup - not found then flag an error exit function so next DB can be processed.
   $LastFullDBBackup = Get-ChildItem "$DBBackupDir" | Where-Object {$_.name -like "*$DbName*" } | sort -property $_.lastwritetime -Descending | select -first 1
   if (!$LastFullDBBackup)
      {
	     Dispmessage "--> No full database backup found for database" $true
		 Dispmessage "--> Restore processing bypassed"
		 $DBMaintErrorFlag.value = "ProcFlagError"
		 return
	  }

   Dispmessage "---> Lastest Full DB backup file -> $LastFullDBBackup"
   
   ## Get the latest full backup time - this will be used as the starting point to find the latest Diff or if no Diffs, the TLOG backups since this time.
   $LastBackupUpdate =  $LastFullDBBackup.lastwritetime	
   Dispmessage "---> Last DB Backup File Modify Date/Time -> $LastBackupUpdate"
	
   
   #----------------------------------------------------------------------------
   # Perform the database restore
   
   [string] $BackupFile = "$DBBackupDir\$LastFullDBBackup"
    ## check if the backup is accessible
	if (Test-Path $BackupFile)
	   { Dispmessage "---> DB Backup file is accessible -> $BackupFile" }
	else
	   {
	     Dispmessage "## Error: DB Backup file not accessible -> $BackupFile"
	     Dispmessage "## The DB restore will be bypassed"
		 $DBMaintErrorFlag.value = "DBProcFlagError"; 
		 return
	   }
	   
   [string] $DBMaint2ErrorFlag = ""  
   [Boolean] $ExtraRestoresExist = $false

   ## call the RestoreDatabase function to process the restore.
   RestoreDatabase $DbName $RDSQLConn $BackupFile $ExtraRestoresExist $RestoreDBState $RestoreDataPath $RestoreTLogPath $RetryCount $RetryDelaySec ([Ref] $DBMaint2ErrorFlag)
   if ($DBMaint2ErrorFlag -eq "ProcFlagError") 
       { 
	     Dispmessage "---> Error occurred in DB Restore processing - bypassing further restore processing"
	     $DBMaintErrorFlag.value = "DBProcFlagError"; 
         Return
	   }  

}

####################################################################################
## This function restores a full database backup, the restore takes into account
## multi-file database. The function will first kill all processes accessing the database 
## to be restored. The restore is performed using a UNC path to the backup file on the
## source server. Note: This assumes the Restore SQL Service account has read access to the
## backup share (and sub directory) on the source SQL Server.
## 1 or more retries is performed for each remove process if a failure occurs.
## The recovery setting depends on whether there are any further backups to 
## restore and if no more restores are required then the Recovery State INI file
## value will determine the final state of the database.

Function RestoreDatabase ([string] $DbName, [object] $RDSQLConn, [string] $BackupFile, [boolean] $ExtraRestoresExist, [string] $RestoreDBState,
                          [string] $DataBackupPath, [string] $TLBackupPath, [int] $RetryCount, [int] $RetryDelaySec, [Ref] $DBMaint2ErrorFlag)

{
 [int] $retries = 1
 [string] $RestoreDBErrorFlag = ""
 While ($retries -le $RetryCount -and $RestoreDBErrorFlag -ne "RestoreDBProcessed" )
   {
	 try
	  { 
	    $RestoreDBErrorFlag = "RestoreDBProcessed"
		Check-SQLConnection $RDSQLConn
		$Restore = new-object Microsoft.SqlServer.Management.Smo.Restore  
		$Restore.Action = 'Database' 
		$Restore.Database = $dbname 
		$Restore.ReplaceDatabase = $true 

		if ($ExtraRestoresExist) # Either Diff or TLOG restores to come so use norecovery option for restore.
			{ $Restore.Norecovery = $true }
		else
			{ ## No more restores so set the final recovery state 
				if ($RestoreDBState -eq "NoRecovery") 
					{ $Restore.Norecovery = $true}
				elseif ($RestoreDBState -eq "Recovery") 
					{ $Restore.Norecovery = $false}
				else	# use standby mode
					{
					 $Restore.Norecovery = $true
					 $Restore.standbyfile = "$DataBackupPath\$DbName_undo.dat"
					}
			}

		$backupDevice = New-Object("Microsoft.SqlServer.Management.Smo.BackupDeviceItem") ("$BackupFile", "File") 
		$Restore.Devices.Add($backupDevice)  
		
		$DataFiles = $Restore.ReadFileList($RDSQLConn)  
	
		# Restore setup new locations for every file for the database.
		ForEach ($DataRow in $DataFiles) 
		{  
			$LogicalName = $DataRow.LogicalName  
			$PhysicalName = Get-FileName -path $DataRow.PhysicalName  
			$RestoreData = New-Object("Microsoft.SqlServer.Management.Smo.RelocateFile")  
			$RestoreData.LogicalFileName = $LogicalName 

			if ($DataRow.Type -eq "D") 
				{  
				# Restore Data file  
				$RestoreData.PhysicalFileName = $DataBackupPath + "\" + $PhysicalName 
				}  
			Else 
				{  
				# Restore Log file  
				$RestoreData.PhysicalFileName = $TLBackupPath + "\" + $PhysicalName 
				}  

			$Restore.RelocateFiles.Add($RestoreData)     
		}  

		#$RDSQLConn.Databases[$dbname].DatabaseOptions.RecoveryModel = "Simple"
				
		# Perform database restore processing
		Dispmessage "----> Killing connections on $DbName"
		# this kills all processes on database, even ones not viewable by sysprocesses
		$RDSQLConn.KillAllProcesses("$DbName")
		
		Dispmessage "----> Restoring Database $DbName"
		# Perform the restore.
		$InitialTime = Get-Date -Format "yyyy/MM/dd hh:mm:ss"
		$Restore.SqlRestore($RDSQLConn)
		$endtime = Get-Date -Format "yyyy/MM/dd hh:mm:ss"
		Dispmessage "-----> Database Restore Completed | Initial Time: $initialtime End Time: $endtime" 
	  }  
     catch ## if error then show it, set error flag and continue for retry
	  {
	    ShowError $_  continue
	    if ($_.exception.message.length -gt 0) {$RestoreDBErrorFlag = "RestoreDBProcFlagError"} ## Restore error found
		Dispmessage "-----> Retrying Failed Process - Retry No -> $retries"
		Dispmessage "-----> Sleeping for $RetryDelaySec seconds"
		Start-Sleep -s $RetryDelaySec
		$Restore = $null 
	  }		
	$retries++ 
  }	
  if ($RestoreDBErrorFlag -eq "RestoreDBProcFlagError") { $DBMaint2ErrorFlag.value = "ProcFlagError"}
     
  $Restore = $null 

}


##---------------------------------------------------------------------
# Function to Check Log Size and Rotate as Needed
	function RotateLog($log) {
        $threshold = 10 # Size of File in Megabytes when Log Should Be Rotated
        $file = Get-Item "$log" # Get Log File
        $filedir = $file.directory.fullname # Get Log Directory
        $filesize = $file.length/1MB # Get Current Size of File
        $datetime = Get-Date -uformat "%Y%m%d-%H%M" # Get Current Date and Time
        $fdatetime = Get-Date -uformat "%B %e, %Y - %H%M hours" # Get Formatted Current Date and Time
        $arcdir = "$filedir\archive" # Specify Log Archive Directory
        if ((Test-Path -Path $arcdir -PathType container) -ne $True) # Verify that the Archive Directory Exists - If not, Create it
        {
            New-Item $arcdir -Type directory # Create Directory if it does not Exist
        }
		Dispmessage "--> $File size is -> $filesize"
        if ($filesize -gt $threshold) { # Compare Log File Size to Specified Threshold
            $filename = $file.name -replace $file.extension,"" # Remove File Extension from Name
            $newname = "${filename}_archive_${datetime}.txt" # Specify New Name for Archived Log
            Rename-Item -Path $file.fullname -NewName $newname # Rotate Current Log to Archive
            Move-Item $filedir\$newname -Dest "$arcdir" # Move Archived Log to Archive Directory
            Dispmessage "$rotationmessage" # Echo Log Rotation Message to Console if Active
            
        }
		PurgeLogFiles $arcdir "_archive_" 14
		
    }

# Function to purge renamed log files in the archive dir older than 15 days
Function PurgeLogFiles ([String] $TargetDir, [String] $FileString, [int] $RetentionDays)
{
  
   $CutOffDateTime = [DateTime]::Now.AddDays(-$RetentionDays)
   Dispmessage "--> Log file cut off date -> $CutOffDateTime"
   
   $FilesToDelete = Get-ChildItem $TargetDir | Where-Object {$_.name -like "*$FileString*" -and $_.extension -eq ".txt" -and $_.CreationTime -lt $CutOffDateTime}
  
  if ($FilesToDelete)
	   {
			$FilesToDelete | foreach-object {Dispmessage "---> File to delete -> $_" }

			## Remove files
			$FilesToDelete | Remove-item -Force -ErrorAction SilentlyContinue  # need to change erroraction for command to ensure error handling is hit
			# Try Catch won't work on this command so have to use this method
	        if (!$?)
			   {
			     Dispmessage "---> ## Error: Remove log files failed" $True
				 Dispmessage "---> ## Error Message -> $($Error[0])" $True
				 exit 1
			   }
			else 
			   {
			     Dispmessage "--> Removal of old log files in $TargetDir Completed" 
			   }	  
	   }
	else
	   {
	     Dispmessage "--> No log files to purge in $TargetDir"
	   }

}							  								  

##############################################################################################################################
## MAIN 
##############################################################################################################################
## Initialise Variables

$ErrorActionPreference = "continue"
[string] $Date = Get-Date -format "dd-MMM-yyyy HH:mm:ss "
[string] $Now = Get-date -format yyyyMMddhhmmss
[string] $FormatDate = Get-date -format "yyyy-MM-dd:hh:mm:ss"
[int] $exitflag = 0
[Boolean]  $MaintTaskErrorFlag = $false
[string] $DBMaintErrorFlag = ""

# Get the SQL instance name
[string] $SQLInstance = $SQLServer.split("\")[1]
If (!$SQLInstance) { $SQLInstance = "MSSQLSERVER"}

# Set servername or virtualname variable - depending if its a cluster is what the first
# part of the SQLServer variable represents.
[string] $ServerOrVirtualName = $SQLServer.split("\")[0]

[string] $SQLServerName =  ""

## need sqlserver name for backup dir path
if ($SQLInstance -eq "MSSQLSERVER")
  {$SQLServerName = $ServerOrVirtualName}
else
  {$SQLServerName = "$ServerOrVirtualName`$$SQLInstance"}

# Set up log file for the run
[string] $logfile = "$LogDir\$SQLInstance\RestoreDBBackup.log"

if (-not (Test-path("$LogDir\$SQLInstance"))) {New-Item "$LogDir\$SQLInstance"  -type directory}

Dispmessage " "
Dispmessage "-> RestoreDBBackup Started -> $Date" 
Dispmessage " "
Dispmessage " "

ValidateParams $ServerOrVirtualName $ConfigFile $LogDir 

# Read RestoreReplicaDB INI file into hash table
$IniHashtable = ( Get-Content $ConfigFile | ReadIniFile)

$DisableErrorExitField = "N"

# Validate the ini file fields and values
ValidateINI $IniHashtable

##------------------------------------------------------------------ 
#Generate Include Restore Db List

[string] $RDRestoreDBList = $($IniHashtable.item("RDRestoreDBs")).trim()
# add [] to the db name and lower case the name and then store in array..
[String[]] $IncludeExcludeDbsArray = $RDRestoreDBList.split(",") | ForEach-Object {if ($_.substring(0,1) -ne "[") {"[" + $_.trim().tolower() + "]"}}
if ($IncludeExcludeDbsArray) 
	{     if ($DebugMode) {Dispmessage "--> #### Restore DB List (from INI) #####"; foreach ($i in $IncludeExcludeDbsArray) {Dispmessage "--> Restore Db -> $i"}} }
else
	{ 
	 	   Dispmessage "-> No Databases to Process - exiting" $true
           Dispmessage ""
           $Date = Get-Date -format "dd-MMM-yyyy HH:mm:ss"
	       DispMessage "-> RestoreDB Completed -> $Date"
           exit 0
   }
   

##--------------------------------------------------------------------------- 
## Load the SMO assemblies
LoadUPSMOAssembly

##--------------------------------------------------------------------------- 
# Connect to the specified instance, assumes Windows Auth
[int] $StatementTimeout = $IniHashtable.item("StatementTimeout")
[int] $ConnectTimeout = $IniHashtable.item("ConnectTimeout")

# For the Restore Db processing connect Destination SQL Server.

[string] $RDRestoreSQLServer  = $IniHashtable.item("RDRestoreSQLServer")
if (!$RDRestoreSQLServer)
    {
	  Dispmessage "## Error: Restore SQL Server INI field is blank"
	  ExitWithError 1 
	}
	
[Object] $RDSQLConn = New-RDSQLConnection $RDRestoreSQLServer $StatementTimeout $ConnectTimeout
   
       
##------------------------------------------------------------------ 
# SEt the databases to process
[Object] $DBToProcessList =  $IncludeExcludeDbsArray 
                
##------------------------------------------------------------------ 
# DB Restart Processing.

# Set up restart file 
[string] $RestartFile = "$LogDir\$SQLInstance\RestoreDBBackupTask`_$SQLInstance.DBProcessed" 
[Boolean] $RemoveRestartFlag = $True

if (CheckFileExists($RestartFile))
{ 
	## If restart file exists but size is 0 the get rid of it
	if ((get-childitem $RestartFile).length -eq 0) 
	{ Remove-Item $RestartFile }
	else ## Restart file has completed dbs
	{ ## Get the Db to Process excluding the dbs completed.
		[String[]] $CompletedDbs = get-content $RestartFile
		[Object] $DBToProcessListFinal = Compare-Arrays $DBToProcessList $CompletedDbs  ## get list back based on $DBToProcessList - $CompletedDbs
		$DBToProcessList = $DBToProcessListFinal.left  
		if ($DebugMode) { Dispmessage "--> #### DBs Completed ####"; foreach ($i in $CompletedDbs) {Dispmessage "--> Db Completed -> $i"}}
		Dispmessage "--> #### DBs To Process Excluding Previously Completed ####"; foreach ($i in $DBToProcessList) {Dispmessage "--> Db To Process -> $i"}
	}
}
else  # no restart file found so create a new one.
{
	Dispmessage "-> Create Database Restart File"
	New-Item -Path $RestartFile -type file
}

Dispmessage ""

##------------------------------------------------------------------  
## For Each Db to process perform the deploy action   

foreach ($DbItem in $DBToProcessList)
{
	Dispmessage "####################################################"
	Dispmessage "-> Processing Database -> $DbItem" $true
	$DbErrorFlag = ""

	## Run Restore Replica DB function
	$DbErrorFlag = PerformRestoreDbForReporting $SQLServerName $Dbitem $RDSQLConn $IniHashtable ([Ref] $DBMaintErrorFlag) 


	# if the database processed successfully then add to completed restart file 
	# other set the errorflag - this allows the process to continue to the 
	# next database - this assume non-fatal failure in script

	if ($DBMaintErrorFlag -eq "DbProcessed")  ## all good, add to completed file
		{
		Dispmessage "-> Add processed database to restart file"
		Add-Content -Path $RestartFile -Value $DbItem
		}

	else # its no good set overall failure flag 
		{
		$MaintTaskErrorFlag = $True
		$RemoveRestartFlag = $False  ## fatal error don't remove restart
	}
} ## end db processing loop

## if we got this far then maint task has completed successfully therefore remove it
if ((CheckFileExists($RestartFile)) -and $RemoveRestartFlag)
{ 
Dispmessage "-> Restore Task Completed - Removing database restart file"
Remove-Item $RestartFile 
}
	

Dispmessage "-> Disconnect RDSQLConn"
Remove-SQLConnection $RDSQLConn 
	
##------------------------------------------------------------------ 
## At least one db has had a failure
if ($MaintTaskErrorFlag)
   {
     Dispmessage   " "
     Dispmessage "## Error: An Error was found in the processing" $true
	 Dispmessage "## Error: See previous error messages for context" $true
	 ExitWithError 1
   }

RotateLog $logfile

##------------------------------------------------------------------ 
## End Processing 
DispMessage " "
$Date = Get-Date -format "dd-MMM-yyyy HH:mm:ss"
DispMessage "-> RestoreDB Completed -> $Date"
exit 0