<#
.SYNOPSIS
Restores a backup to the specified server.
.PARAMETER ServerName
The name of the server to restore the database to.
.PARAMETER DatabaseName
The name of the database that should be restored
.PARAMETER BackupFilePath
The path to the backup file to be restored
.PARAMETER DataPath
The path to move all data files to.
.PARAMETER LogPath
The path to move all log file to.
.PARAMETER Replace
If specified, command will be set to use the REPLACE option to replace an existing database.
.PARAMETER GenerateNewFileName
If specified, new physical file names will be generated using the specified database name.
.PARAMETER Litespeed
If specified, the script will attempt to use Litespeed extended stored procedures
.PARAMETER Search
If specified, the script will search at the path specified and process all files found
.PARAMETER Recurse
If specified along with the -Search parameter, the script will search the specified location recursively
.PARAMETER SearchMask
The mask to qualify files if the -Search parameter is used
.PARAMETER SQLOnly
If specified, the script will output the SQL that would be created and not execute it
.PARAMETER SingleUser
If specified, the script will take the database to single user mode briefly to disconnect all current connections.
.PARAMETER NoRecovery
If specified, the script will restore the database with the NORECOVERY option, leaving the database in recovery for further restores.
.NOTES
	Current Version: 2.2.1
	
	Version 2.2.1 Changelog
	---------------------
	1. Fixed bug with extra '`' in data file path when not using Litespeed.
    2. Fixed bug where data file name not being generated when GenerateNewName is used and Litespeed is not used.


#>
function Restore-SQLDatabase
{
	#Debug only!
	#param
	#(
	#	[string]$ServerName="CTCSQL2005",
	#	[string]$DatabaseName="SFIM_test",
	#	[string]$BackupFilePath="\\ctcsql2005\h$\DBase Data1\backups\MT2627036\ITVerpAMS_53\FullDBBackupSLS_ITVerpAMS_53_20110112215318.BAK",
	#	[string]$DataPath="H:\DBase Data1",
	#	[string]$LogPath="I:\DBase Log1",
	#	[switch]$Replace=$true,
	#	[switch]$GenerateNewFileName=$true
	#)

	param
	(
		[parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$ServerName,
		[parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$DatabaseName,
		[parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)][string]$BackupFile,
		[parameter(mandatory=$false)][string]$DataPath,
		[parameter(mandatory=$false)][string]$LogPath,
		[switch]$Replace=$false,
		[switch]$GenerateNewFileName=$false,
		[parameter(mandatory=$false,ValueFromPipelineByPropertyName=$true)][switch]$Litespeed=$false,
		[switch]$SQLOnly,
		[switch]$SingleUser,
		[switch]$NoRecovery
	)
BEGIN {
	#region Variable Declaration


	[string]$sqlText="";
	[string]$sqlProgressText = "";
	[bool]$hasLitespeed = $false;
	[string]$moveCmd="";
	$fileRow = $null;
	$cmdResult = $null;
	[String[]]$moveArray = "";
	[string]$invokeExpression="";
	[int]$intFileCounter = 1;

	#endregion



	#region Common functions

	function hasLitespeed
	{
		$sqlText = "IF EXISTS (SELECT 1 FROM master.sys.objects WHERE type = 'X' AND name = 'xp_restore_database') SELECT 1 AS Result ELSE SELECT 0 AS Result";
		$cmdResult = Invoke-Query -Connection $global:SQLConn -sql $sqlText;
		return $cmdResult.Result;
		
		$cmdResult = $null;
		
	}
  
  	function Split-Path2 
	{
		param
		(
			[string]$path
		)
		
		[string]$strFinalPath = "";
		
		#Split the path by the "\" character
		$arrPathSplit = $path.Split("\");
		
		#Join all but the last item in the array (assumed to be the filename)
		for ($i = 0; $i -le $arrPathSplit.Count - 2; $i ++)
		{
			$strFinalPath += $arrPathSplit[$i] + "\";
		}
		
		$strFinalPath = $strFinalPath.TrimEnd("\");
		
		return $strFinalPath;
  }	

	
	#endregion

	$Error.Clear();
}
	#region Main Code
PROCESS {
	
  try
	{

    #### Begin v2.1 Changes ####
		#Check if adoLib is installed
		if (!(Get-Module -ListAvailable -Name adoLib))
		{
			Write-Error "adoLib module not available, exiting.";
			return
		}
		
		#Import adoLib module
		Import-Module adoLib -Global | Out-Null;
        
        #### End v2.1 Changes ####
        
    #Acquire connection to server
    $global:SQLConn = New-Connection -Server $ServerName -database "master";
        
		foreach ($backupFile in $BackupFile)
    {
      #Get the list of files from the backup
      if ($Litespeed)
      {
        $sqlText = "exec master..xp_restore_filelistonly @filename = '" + $backupFile + "'";
      }
      else
      {
        $sqlText = "RESTORE FILELISTONLY FROM DISK = '" + $backupFile + "'";
      }
      $cmdResult = Invoke-Query -Connection $global:SQLConn -SQL $sqlText;
      if ($cmdResult -eq $null) {throw "Could not read database backup media information.";}
      
      #Iterate over the results and create the MOVE commands
      foreach ($fileRow in $cmdResult)
      {
        if ($fileRow.Type -eq 'D') #If the file is a data (not log) file
        {
          #If the DataPath variable is empty, we first want to see if the database exists, so we can restore it to the same location
          if (($DataPath -eq $null) -or ($DataPath -eq ""))
              {
            $sqlText = "SELECT name, filename FROM master..sysaltfiles WHERE name = @filename AND dbid = DB_ID(@dbname)";
            $sqlParams = @{filename=$fileRow.LogicalName;dbname=$DatabaseName};
            $altFileRow = Invoke-Query -connection $global:SQLConn -sql $sqlText -parameters $sqlParams;
            #If the row returned is not null, the database exists and we want to use the same path.
            if ($altFileRow -ne $Null)
              {
                $DataPath = Split-Path2 $altFileRow.Filename;
            }
            #Otherwise, the database does not exist and we'll use the default data path
            else
            {
                $DataPath = Get-SqlDefaultDir -sqlserver $ServerName -dirtype "Data"; 
            }
              }
          if ($fileRow.PhysicalName -match ".*\.mdf") #If the file is a primary data file (would love to find another way besides the extension)
          {
            if ($GenerateNewFileName) #Generate a new file name based on the database name
            {
              #Litespeed versus non litespeed formatted commands
              if ($Litespeed)
              {
                $moveCmd += "MOVE `"" + $fileRow.LogicalName + "`" TO `"" + $DataPath + "\" + $DatabaseName + ".mdf`"`n";
              }
              else
              {
                $moveCmd += "MOVE '" + $fileRow.LogicalName + "' TO '" + $DataPath + "\" + $DatabaseName + ".mdf'`n"
              }
            }
            else #Use the original file logical name
            {
              #Litespeed versus non litespeed formatted commands
              if ($Litespeed)
              {
                $moveCmd += "MOVE `"" + $fileRow.LogicalName + "`" TO `"" + $DataPath + "\" + $fileRow.LogicalName + ".mdf`"`n";
              }
              else
              {
                $moveCmd += "MOVE '" + $fileRow.LogicalName + "' TO '" + $DataPath + "\" + $fileRow.LogicalName + ".mdf'`n";
              }
            }
          }
          else #If this is a data file, but not the primary one
          {
            if ($GenerateNewFileName) #Generate a new file name based on the database name
            {
              if ($Litespeed)
              {
                $moveCmd += "MOVE `"" + $fileRow.LogicalName + "`" TO `"" + $DataPath + "\" + $DatabaseName + "_" + $fileRow.LogicalName + ".ndf`"`n";
              }
              else
              {
                $moveCmd += "MOVE '" + $fileRow.LogicalName + "' TO '" + $DataPath + "\" + $DatabaseName + "_" + $fileRow.LogicalName + ".ndf'`n";
              }
            }
            else #Use the original logical file name
            {
              if ($Litespeed)
              {
                $moveCmd += "MOVE `"" + $fileRow.LogicalName + "`" TO `"" + $DataPath + "\" + $fileRow.LogicalName + ".ndf`"`n";
              }
              else 
              {
                $moveCmd += "MOVE '" + $fileRow.LogicalName + "' TO '" + $DataPath + "\" + $DatabaseName + "_" + $fileRow.LogicalName + ".ndf'`n";
              }
              
            }
            $intFileCounter ++; #Increment the file counter for naming purposes
          }
        }
        else #If the file is a log file
        {
          
          #If the log path is not specified, first check if the database exists so we can use the same path.
          if (($LogPath -eq $null) -or ($LogPath -eq ""))
              {
              $sqlText = "SELECT name, filename FROM master..sysaltfiles WHERE name = @filename AND dbid = DB_ID(@dbname)";
            $sqlParams = @{filename=$fileRow.LogicalName;dbname=$DatabaseName};
            $altFileRow = Invoke-Query -connection $global:SQLConn -sql $sqlText -parameters $sqlParams;
            #If the row returned is not null, the database exists and we want to use the same path.
            if ($altFileRow -ne $Null)
              {
                $LogPath = Split-Path2 $altFileRow.Filename;
            }
            else 
            {
                $LogPath = Get-SqlDefaultDir -sqlserver $ServerName -dirtype "Log"; 
            }
              }
  
          if ($GenerateNewFileName) #Generate a new name based on the database name
          {
            if ($Litespeed)
            {
              $moveCmd += "MOVE `"" + $fileRow.LogicalName + "`" TO `"" + $LogPath + "\" + $DatabaseName + ".ldf`"`n";
            }
            else
            {
              $moveCmd += "MOVE '" + $fileRow.LogicalName + "' TO '" + $LogPath + "\" + $DatabaseName + ".ldf'`n";
            }
          }
          else #Use the original logical file name
          {
            if ($Litespeed)
            {
              $moveCmd += "MOVE `"" + $fileRow.LogicalName + "`" TO `"" + $LogPath + "\" + $fileRow.LogicalName + ".ldf`"`n";
            }
            else
            {
              $moveCmd += "MOVE '" + $fileRow.LogicalName + "' TO '" + $LogPath + "\" + $fileRow.LogicalName + ".ldf'`n";
            }
          }
        }
      }
  
      #Construct the restore command
      if ($Litespeed)
      {
        $sqlText = "exec master..xp_restore_database @database = '$DatabaseName', @filename = '" + $backupFile.Replace("$","`$") + "', @with = 'STATS=1'";
      }
      else
      {
        $sqlText = "RESTORE DATABASE [$DatabaseName] FROM DISK ='" + $BackupFile.Replace("$","`$") + "' WITH STATS=1";
      }
      
      #Append the MOVE commands
      $moveArray = $moveCmd -split "`n"
      foreach ($moveCmd in $moveArray)
      {
        if ($moveCmd -ne "")
        {
          if ($Litespeed)
          {
            $sqlText += ", @with = '$moveCmd'";
          }
          else
          {
            $sqlText += ", $moveCmd";
          }
        }
      }
      
      #If -Replace was specified, add that command
      if ($Replace)
      {
        if ($Litespeed)
        {
          $sqlText += ", @with = 'REPLACE'";
        }
        else
        {
          $sqlText += ", REPLACE";
        }
      }
      
      #If -NoRecovery was specified, add that command
      if ($NoRecovery)
      {
        if ($Litespeed)
        {
          $sqlText += ", @with = 'NORECOVERY'";
        }
        else
        {
          $sqlText += ", NORECOVERY";
        }
      }
      
      #If -SingleUser was specified, add those commands
      if ($SingleUser)
      {
        $sqlText = "ALTER DATABASE [$DatabaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;ALTER DATABASE [$DatabaseName] SET MULTI_USER;" + $sqlText;
        $sqlText += ";ALTER DATABASE [$DatabaseName] SET MULTI_USER;";
      }
  
      if ($SQLOnly)
      {
        Write-Host $sqlText "`n";
      }
      else
      {
        $scriptBlock = 
              {
                  param
                  (
                      [String]$sqlText,
                      [String]$ServerName
                  )
                  
                  Import-Module SQLServer;
                  Import-Module adoLib
                  
                  try
                  {
                      $SQLConn = New-Connection -server $ServerName;
                      Invoke-Sql -timeout 0 -connection $SQLConn -sql $sqlText;
                  }
                  catch [System.Exception]
                  {
                      throw $_
                  }
                  finally
                  {
                      if ($SQLConn -ne $null)
                      {
                          if ($SQLConn.State -eq "Open")
                          {
                              $SQLConn.Close();
                          }
                          $SQLConn = $null;
                      }   
                  }
                  
              };
              
              $job = Start-Job -ScriptBlock $scriptBlock -ArgumentList $sqlText,$ServerName -Name "PSRestoreJob-$DatabaseName";
              #$invokeExpression = "Start-Job -InitializationScript {Import-Module SQLPSX} -ScriptBlock {Invoke-Sql -Timeout 65535 -Connection $global:SQLConn -Sql `"$sqlText`";} -Name `"PSRestoreJob-$DatabaseName`"";
        #$job = Invoke-Expression -Command $invokeExpression;
  
        $sqlProgressText = @"	
    SELECT der.percent_complete, der.estimated_completion_time/1000 estimated_completion_time 
    FROM sys.dm_exec_requests der CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) dest
    WHERE der.command = 'RESTORE DATABASE' and dest.text LIKE '%$DatabaseName%'
"@;
        
        #While job is running, show progress and wait
        while ($job.State -eq "Running")
        {
          $cmdResult = Invoke-Query -connection $global:SQLConn -SQL $sqlProgressText;
          if ($cmdResult -ne $null) {Write-Progress -Activity "Database Restoration" -Status "Restoring database $DatabaseName" -PercentComplete $cmdResult.percent_complete -SecondsRemaining $cmdResult.estimated_completion_time;}
          sleep 5
        }
        
        #Check if job has any error messages
              if ($job.State -eq "Failed")
              {
                  Receive-Job $job
                  throw 'Restore job failed, please see job output.'
              }
      }
      
      $props = @{
        'ServerName' = $ServerName
        'DatabaseName' = $DatabaseName
      }
      
      $outputObj = New-Object PSObject -Property $props
      
      Write-Output $outputObj

    }


	}

	catch [System.Exception]
	{
		Write-Error $_.Exception.ToString();
	}
	
	finally
	{
		#Close global connection and dispose
        if (($global:SQLConn -ne $null) -and ($global:SQLConn.State -eq "Open"))
        {
            $global:SQLConn.Close();
            $global:SQLConn.Dispose();
        }
        [GC]::Collect();
	}
}
	#endregion

END {

}
}