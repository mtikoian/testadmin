#####################################################################################
## Create SQL connection
function New-RDSQLConnection ([string] $SQLServer, [int] $StatementTimeout, [int] $ConnectTimeout)
{
	try
	  {
	    write-host "-> Creating a new SQL Connection for Restore SQL Server"
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
	    write-host "##Error: SQL Connection Check failed" $true
		write-host $ex.message $true
	    $ex = $ex.InnerException
	    while ($ex.InnerException)
	    {
	        write-host $ex.InnerException.message $true
	        $ex = $ex.InnerException
	    };
		ExitWithError 1 $RDSQLConn
	  }
}

####################################################################################
## This function disconnects a SMO connection and removes the connection variable.

function Remove-SQLConnection ([Object] $SQLConn)
{  
 try 
   {
    write-host "----> Removed the SQL Connection"
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
    write-host "##Error: SQL Connection disconnection failed" $true
	write-host $ex.message $true
    $ex = $ex.InnerException
    while ($ex.InnerException)
    {
        write-host $ex.InnerException.message $true
        $ex = $ex.InnerException
    };
	Exit 1
  }
}

#####################################################################################
## This function checks if a file exists, if it does returns $true else returns $false

Function CheckFileExists ( [string] $Filespec)
{
 if (Test-Path -path $Filespec -pathtype leaf) 
      {
        write-host "---> File exists -> $Filespec"
        return $True
      }
   else 
      {
        write-host "---> File not found -> $Filespec" $True
        return $False
      }
}

####################################################################################
## This function load the SMO assemblies.

Function LoadUPSMOAssembly ()
{
 try 
     {
    # Load SMO assembly
	$v = [System.Reflection.Assembly]::LoadWithPartialName( 'Microsoft.SqlServer.SMO')
	
	 }
  catch
     {
        write-host "## Error: Loading SMO Assembly Failed" $True
        write-host "## SQL Error Message -> $error[0]" $True
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

#################################################
# Sample ProcessDB to trigger failure on processing a DB
Function ProcessDB ([string] $Db, [Ref] $DBMaintErrorFlag)
{

   #For this example deliberately cause string to return error for Test1
   If ($Db -eq "[test1]")
   {
      write-host "## Found issue with processing $DB "
      $DBMaintErrorFlag.value = "ProcessError"
	  #$DBMaintErrorFlag.value = "DBProcessed"  # uncomment to process test1 in example
   }
   else
    {
	  $DBMaintErrorFlag.value = "DBProcessed"
	}
}

################################################################
### MAIN

##------------------------------------------------------------------ 
#Generate Include Restore Db List

[string] $DBRestoreDBList = "SQLDBA,test,test1,test2"

# add [] to the db name and lower case the name and then store in array..
[String[]] $IncludeExcludeDbsArray = $DBRestoreDBList.split(",") | ForEach-Object {if ($_.substring(0,1) -ne "[") {"[" + $_.trim().tolower() + "]"}}

## if there are DBs in include list this show initial list, otherwise exit
if ($IncludeExcludeDbsArray) 
	{  write-host "--> #### Restore DB List (from INI) #####"; foreach ($i in $IncludeExcludeDbsArray) {write-host "--> Restore Db -> $i"}} 
else
	{ 
	 	   write-host "-> No Databases to Process - exiting" $true
           write-host ""
           $Date = Get-Date -format "dd-MMM-yyyy HH:mm:ss"
	       write-host "-> Script Completed - $Date"
           exit 0
   }
   

##--------------------------------------------------------------------------- 
## Load the SMO assemblies
LoadUPSMOAssembly

## Get SQL connection
[Object] $RDSQLConn = New-RDSQLConnection 'dbinsight01' 60 60

# set the databases to process
[Object] $DBToProcessList =  $IncludeExcludeDbsArray 

##--------------------------------------------------------------------------- 
## DB Restart Processing.

# Set up restart file 
[string] $RestartFile = "c:\sqlrds\mssqlserver\RestoreDB`_Mssqlserver.DBProcessed" 
[Boolean] $RemoveRestartFlag = $True

## if file is there when starting up script
if (CheckFileExists($RestartFile))
{ 
	## If restart file exists but size is 0 the get rid of it
	if ((get-childitem $RestartFile).length -eq 0) 
	    { Remove-Item $RestartFile }
	else ## Restart file has completed dbs
	{ ## Get the Db to Process excluding the dbs completed.
		[String[]] $CompletedDbs = get-content $RestartFile
		
		## get list back based on $DBToProcessList minus $CompletedDbs
		[Object] $DBToProcessListFinal = Compare-Arrays $DBToProcessList $CompletedDbs  
		
		# its the difference between $DBToProcessList minus $CompletedDbs string arrays
		$DBToProcessList = $DBToProcessListFinal.left  
		
		write-host "--> #### DBs Completed ####"; foreach ($i in $CompletedDbs) {write-host "--> Db Completed -> $i"}
		write-host "--> #### DBs To Process Excluding Previously Completed ####"; foreach ($i in $DBToProcessList) {write-host "--> Db To Process -> $i"}
	}
}
else  # no restart file found so create a new one.
{
	write-host "-> Create Database Restart File"
	New-Item -Path $RestartFile -type file
}

##--------------------------------------------------------------------------- 
## Process each DB left in the DBToProcessList  

[string] $DBMaintErrorFlag = ""
[Boolean] $RemoveRestartFlag = $true

foreach ($DbItem in $DBToProcessList)
{
	write-host "####################################################"
	write-host "-> Processing Database -> $DbItem" -ForegroundColor yellow

	# if the database processed successfully then add to completed restart file 
	# other set the errorflag - this allows the process to continue to the 
	# next database - this assume non-fatal failure in script
    ProcessDB $DBItem ([Ref] $DBMaintErrorFlag)  #### passing DBMaintErrorFlag by Reference so it can get updated in Function
	
	if ($DBMaintErrorFlag -eq "DbProcessed")  ## all good, add to completed file
		{
		write-host "-> Add processed database to restart file"
		Add-Content -Path $RestartFile -Value $DbItem
		}

	else # its no good set overall failure flag 
		{
		Write-Host "--> $DBItem not written to Processed DB List in Restart File"
		$RemoveRestartFlag = $False  ## fatal error don't remove restart
	}
} ## end db processing loop

## if we got this far then maint task has completed successfully therefore remove it
if ((CheckFileExists($RestartFile)) -and $RemoveRestartFlag)
{ 
  write-host "-> Restore Task Completed - Removing database restart file"
  Remove-Item $RestartFile 
}

Remove-SQLConnection $RDSQLConn 
