<#
.SYNOPSIS
Used to perform all post installation tasks for SQL Server setup.
.DESCRIPTION
The script is used to perform all post installation configuration tasks
for SQL Server. This includes (any item marked with "*" is not yet implemented):

1. Set the max server memory option to the total amount of memory on the server - 1GB.
2. Set the minimum server memory option to 128MB.
3. Set 'Cost Threshold For Parallelism' to 25.
4. Set 'Max Degreee Of Parallelism' to the number of CPU cores -1 (minimum 2).
5. Allow remote DAC connections.
*6. Setup alerts and maintenance.
7. Reconfigure model database to standards 
    -64MB autogrowth 
	-SIMPLE recovery
*8. Move TempDB files to location specified
*9. Create additional tempdb files to set number of files = # of CPU cores
*10. Apply lockdown scripts
*11. Change default log & data directory
*12. Change default backup directory
*13. Remove BuiltIn\Administrators if it exists and replace with a supplied group
.PARAMETER ServerName
The name of the server to execute against.
.PARAMETER InstanceName
The instance name to execute against.
.NOTES
	Author: Josh Feierman
	Version: 0.1.0
	
	Post SQL Server Installation Configuration Script by Joshua Feierman is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License.
	Permissions beyond the scope of this license may be available at josh@awanderingmind.com.
	
	http://creativecommons.org/licenses/by-sa/3.0/

#>

param
(
	[string]$ServerName="",
	[string]$InstanceName=""
)

Set-StrictMode -Version 2.0;
cls;

#region Global Variables

$sqlCmdText = ""; #SQL Command text
$sqlConn = New-Object System.Data.SqlClient.SqlConnection; #SQLConnection object to connect to SQL
$sqlCmd = New-Object System.Data.SqlClient.SqlCommand; #SQLCommand object to execute commands

$global:totalOperations = 7; #The number of total operations to complete, used in calculating completion percentage.
$global:totalCompletedOperations = 0; #The number of operations completed, used in calculating completion percentage.
$global:totalPercentComplete = 0; #The overall completion percentage.

#endregion

#region Variable check

if ($ServerName -eq "")
{
	Write-Warning "You must provide a server name.";
	$ServerName = Read-Host -Prompt "Please enter a server name (do not include the `"\InstanceName`").";
}

if ($InstanceName -eq "")
{
	Write-Warning "You have not provided an Instance Name. This means that the script will connect to the default instance. Is this correct?";
	$response = Read-Host -Prompt "Please enter 'y' or 'n'.";
	
	if ($response -eq "n")
	{
		$InstanceName = Read-Host -Prompt "Please enter an instance name.";
	}
}

#endregion

#region Startup Code

if ($InstanceName -ne "")
{
	$sqlConn.ConnectionString = "Server=" + $ServerName + "\" + $InstanceName + ",1433;trusted_connection=true";
}
else
{
	$sqlConn.ConnectionString = "Server=" + $ServerName + ",1433;trusted_connection=true";
}

#endregion

#region Common Functions

function executeSqlCommand 
{
	
	param 
	(
		[string]$CommandText=""
	)
	$sqlConn.Open();
	$sqlCmd.Connection = $sqlConn;
	$sqlCmd.CommandText = $CommandText;
	$sqlCmd.ExecuteNonQuery();
	$sqlConn.Close();
	
}

function throwError
{
	param
	(
		[string]$ErrorMessage,
		[switch]$Exit
	);
	
	Write-Error $ErrorMessage
	Write-Error $Error[1].ToString();
	if ($Exit)
	{
		Read-Host -Prompt "Press any key to exit...";
		exit;
	}
}

function writeGlobalProgress
{
	param
	(
		[string]$Status,
		[switch]$IncrementProgress
	)
	
	#If we are incrementing the percentage complete, increment the total operations completed and recalculate
	if ($IncrementProgress)
	{
		$global:totalCompletedOperations ++;
		$global:totalPercentComplete = ($global:totalCompletedOperations/$global:totalOperations)*100;
	}
	
	Write-Progress -Activity "Post SQL Server Installation Configuration" -Status $Status -PercentComplete $global:totalPercentComplete -Id 1;
}

#endregion

cls;

writeGlobalProgress -Status "Testing connectivity to server $ServerName";
#region Test Connection

	try
	{
		executeSqlCommand -CommandText "SELECT @@SERVERNAME;"
	}
	catch [System.Exception]
	{
		$errMsg = "";
		if ($InstanceName -ne "")
		{
			$errMsg = "Could not connect to server $ServerName\$InstanceName";
		}
		else
		{
			$errMsg = "Could not connect to server $ServerName";
		}
		
		throwError -ErrorMessage $errMsg -Exit;
	}

#endregion
writeGlobalProgress -Status "Connectivity testing completed." -IncrementProgress;


writeGlobalProgress -Status "Setting advanced options on."
#region Advanced Options
try
{
	#Construct SQL command for advanced options and execute
	$sqlCmdText = "exec sp_configure 'show advanced options', 1;RECONFIGURE WITH OVERRIDE;";
	executeSqlCommand -CommandText $sqlCmdText;
}
catch [System.Exception]
{
	$errMsg = "Could not set advanced options.";
	throwError -ErrorMessage $errMsg -Exit;
}
#endregion
writeGlobalProgress -Status "Advanced Options set on." -IncrementProgress;

writeGlobalProgress -Status "Setting server memory options";
#region Max  and minimum server memory

$totalMemoryMB = 0; #the amount of memory isntalled on the server
$minMemoryMB = 128; #the minimum amount of memory for SQL to consume
$maxMemoryMB = 0; #the maxmimum amount of memory for SQL to consume (will be set later)

try
{
	Write-Progress -Activity "Server Memory Options" -Status "Retrieving total memory allocated" -ParentId 1 -PercentComplete 33
	#Get the total amount of memory
	$wmiObj = Get-WmiObject -ComputerName $ServerName -Class Win32_ComputerSystem;
	$totalMemoryMB = [Math]::Round($wmiObj.TotalPhysicalMemory/1MB,0);
	
	#Calculate maximum server memory
	$maxMemoryMB = $totalMemoryMB - 1024;
	
	#Construct SQL command for max server memory and execute
	write-progress -Activity "Server Memory Options" -Status "Setting max server memory to $maxMemoryMB MB" -ParentId 1 -PercentComplete 66
	$sqlCmdText = "exec sp_configure 'max server memory', $maxMemoryMB;RECONFIGURE WITH OVERRIDE;";
	executeSqlCommand -CommandText $sqlCmdText;
	
	#Construct SQL command for min server memory and execute
	write-progress -Activity "Server Memory Options" -Status "Setting min server memory to $minMemoryMB MB" -ParentId 1 -PercentComplete 99
	$sqlCmdText = "exec sp_configure 'max server memory', $maxMemoryMB;RECONFIGURE WITH OVERRIDE;";
	executeSqlCommand -CommandText $sqlCmdText;
	
}
catch [System.Exception]
{
	$errMsg = "Could not set maximum server memory.";
	throwError -ErrorMessage $errMsg -Exit;
}
Write-Progress -ParentId 1 -Activity "Server Memory Options" -Status "Memory options completed." -Completed;

#endregion
writeGlobalProgress -Status "Server memory has been configured" -IncrementProgress;

writeGlobalProgress -Status "Setting cost threshold for parallelism";
#region Cost Threshold For Parallelism

$sqlCmdText = "exec sp_configure 'cost threshold for parallelism', 25;RECONFIGURE WITH OVERRIDE";

try
{
	executeSqlCommand -CommandText $sqlCmdText;
}
catch [System.Exception]
{
	throwError -ErrorMessage "Error setting cost threshold for parallelism." -Exit
}

#endregion
writeGlobalProgress -Status "Cost Threshold For Parallelism set" -IncrementProgress;

writeGlobalProgress -Status "Setting Max Degree Of Parallelism";
#region MAX DOP

$numberOfCores = 0; #The number of logical/physical cores on the box
$maxDOP = 0; #The maximum degree of parallelism (to be set later)

try
{
	Write-Progress -Activity "MAX DOP" -Status "Retrieving WMI object" -PercentComplete 0 -ParentId 1;
	#Get the WMI object for processors
	$wmiObj = Get-WmiObject -Class Win32_Processor -ComputerName $ServerName;
	Write-Progress -Activity "MAX DOP" -Status "Retrieved WMI object" -PercentComplete 25 -ParentId 1;
	
	#Set the ScriptBlock parameter
	$scriptBlock = 
	{
		#If the NumberOfCores property is available, use it
		if ($_ | Get-Member | Where {$_.Name -eq "NumberOfCores"})
		{
			$numberOfCores += $_.NumberOfCores;
		}
		#Otherwise just increment the counter
		else
		{
			$numberOfCores ++;
		}
	};
	
	#Iterate over the objects and increment processor counter
	Write-Progress -Activity "MAX DOP" -Status "Calculating number of cores..." -PercentComplete 25 -ParentId 1;
	$wmiObj | ForEach-Object -Process $scriptBlock;
	Write-Progress -Activity "MAX DOP" -Status "Calculated number of cores" -PercentComplete 50 -ParentId 1;
	
	Write-Progress -Activity "MAX DOP" -Status "Calculating max DOP..." -PercentComplete 50 -ParentId 1;
	#Calculate the MAX DOP
	switch ($numberOfCores)
	{
		(1) { $maxDOP = 2; }
		default { $maxDOP = $numberOfCores - 1;}
	}
	Write-Progress -Activity "MAX DOP" -Status "Calculated number of cores" -PercentComplete 75 -ParentId 1;
	
	#Construct the statement to set Max DOP
	Write-Progress -Activity "MAX DOP" -Status "Executing command to set Max DOP..." -PercentComplete 75 -ParentId 1;
	$sqlCmdText = "exec sp_configure 'Max Degree Of Parallelism', $maxDOP;RECONFIGURE WITH OVERRIDE";
	executeSqlCommand -CommandText $sqlCmdText;
	Write-Progress -Activity "MAX DOP" -Status "Max DOP set" -PercentComplete 100 -Completed -ParentId 1;
	
}
catch [System.Exception]
{
	throwError -ErrorMessage "Error setting Max Degree Of Parallelism" -Exit;
}



#endregion
writeGlobalProgress -Status "Max DOP set" -IncrementProgress;

writeGlobalProgress -Status "Setting remote DAC connection";
#region Remote DAC

$sqlCmdText = "exec sp_configure 'remote admin connections',1;RECONFIGURE WITH OVERRIDE";

try
{
	executeSqlCommand -CommandText $sqlCmdText;
}
catch [System.Exception]
{
	throwError -ErrorMessage "Error setting remote DAC connection" -Exit;
}

#endregion
writeGlobalProgress -Status "Remote DAC enabled" -IncrementProgress;

writeGlobalProgress -Status "Configuring 'model' database to standards";
#region Model Database 

$sqlCmdText = @"
ALTER DATABASE MODEL
	MODIFY FILE
	(
		NAME = modeldev,
		FILEGROWTH = 64mb
	);
ALTER DATABASE MODEL
	MODIFY FILE
	(
		NAME = modellog,
		FILEGROWTH = 64mb
	);
ALTER DATABASE MODEL SET RECOVERY SIMPLE;
"@;

try
{
	executeSqlCommand -CommandText $sqlCmdText;
}
catch [System.Exception]
{
	throwError -ErrorMessage "Error setting 'model' database to standards" -Exit;
}

#endregion
writeGlobalProgress -Status "Model database set to standards" -IncrementProgress;

Read-Host -Prompt "Press enter to exit";