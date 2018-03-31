##############################################################################
#
# NAME: 	CreatePerfmonJobs.ps1
#
# AUTHOR: 	Phil Ekins - House of Brick
# EMAIL: 	pekins@houseofbrick.com
#
# COMMENT:  Powershell conversion and update from AG version of 11/16/2012
#
# PARAMETERS:
#			None
#
# EXAMPLE:
#			CreatePerfmonJobs.ps1
#
# CHANGELOG:
# 1.0 2012-11-16 - Dos based Version
# 2.0 2015-01-04 - Converted to Powershell and updated counters - added self updating
# 2.1 2015-05-14 - Reviewed Counter List for 2012
#
##############################################################################

## Error Handling
$ErrorActionPreference= 'Stop'
Trap {
    Write-Host $_.Exception 
}

CLS
Write-Host "HoB Performance Counters Data Collection Script"

$InstallPath = "C:\PerfLogs"
Write-Host "Install Path Set to $InstallPath"

IF (!(Test-Path $InstallPath\SQLServerPerf)) {
	New-Item -ItemType directory -Path $InstallPath\SQLServerPerf | Out-Null 
	Write-Host "Creating Directory $InstallPath\SQLServerPerf"
 }
	
IF (!(Test-Path $InstallPath\SQLServerPerf\Read_Me.txt)) { 
	New-Item -ItemType file -Path "$InstallPath\SQLServerPerf\Read_Me.txt" -force -Confirm:$false | Out-Null 
	$Readme = "SQLServerPerf - Creates a Perfmon Counter Log collector to collect Microsoft SQL Server-related data
	Created by Hob Consultant - House of Brick Technologies - 11/15/2012
	Modified 1/3/2012 - Ported to Powershell
	******************************************************************
	\Logs - the target folder for the .blg files created by the Perfmon counter log when it is running
	\BatchFiles\SQLPerfmonCollector-Create.bat - batch file to create the 'SQLServerPerf' counter log, start the counter log, and create two Windows Scheduled Tasks:
		>>'Cycle SQLServerPerf Perfmon Counter Log' - runs daily at 23:59:58 to stop the counter log and start it again in order to begin a new log file
		>>'Start SQLServerPerf Perfmon Counter Log' - runs on system startup to start the counter log when the system reboots
	\BatchFiles\SQLPerfmonCollector-Cycle.bat - batch file called by the Scheduled Task to stop and start the counter log
	\BatchFiles\SQLPerfmonCollector-Start.bat - batch file called by the Scheduled Task to start the counter log
	\BatchFiles\SQLPerfmonCollector-Stop.bat - batch file to stop the counter log - not currently used but included for completeness
	\BatchFiles\SQLServer.cfg - config file with the list of PerfMon counters to be collected by the SQLServerPerf counter log collector - referenced by the SQLPerfmonCollector-Create.bat
	****************************************************************** "
	out-file -filepath "$InstallPath\SQLServerPerf\Read_Me.txt" -inputobject $Readme -Encoding Ascii 
	Write-Host "Creating File Read_Me.txt"
	}
	
IF (!(Test-Path $InstallPath\SQLServerPerf\BatchFiles)) {
	New-Item -ItemType directory -Path $InstallPath\SQLServerPerf\BatchFiles | Out-Null 
	Write-Host "Creating Directory $InstallPath\SQLServerPerf\BatchFiles"
	}

IF (!(Test-Path $InstallPath\SQLServerPerf\BatchFiles\CreatePerfmonJobs.ps1)) { 
	New-Item -ItemType file -Path "$InstallPath\SQLServerPerf\BatchFiles\CreatePerfmonJobs.ps1" -force -Confirm:$false | Out-Null 
	$CreatePerfmonJobs = $MyInvocation.MyCommand | Select -Exp ScriptContents
	out-file -filepath "$InstallPath\SQLServerPerf\BatchFiles\CreatePerfmonJobs.ps1" -inputobject $CreatePerfmonJobs -Encoding Ascii
	}
	
IF (!(Test-Path $InstallPath\SQLServerPerf\BatchFiles\SQLPerfmonCollector-Stop.bat)) { 
	New-Item -ItemType file -Path "$InstallPath\SQLServerPerf\BatchFiles\SQLPerfmonCollector-Stop.bat" -force -Confirm:$false | Out-Null 
	$SQLPerfmonCollector_Stop = "logman stop sqlserverperf"
	out-file -filepath "$InstallPath\SQLServerPerf\BatchFiles\SQLPerfmonCollector-Stop.bat" -inputobject $SQLPerfmonCollector_Stop -Encoding Ascii
	Write-Host "Creating File SQLPerfmonCollector-Stop.bat"
	}
	
IF (!(Test-Path $InstallPath\SQLServerPerf\BatchFiles\SQLPerfmonCollector-Start.bat)) { 
	New-Item -ItemType file -Path "$InstallPath\SQLServerPerf\BatchFiles\SQLPerfmonCollector-Start.bat" -force -Confirm:$false | Out-Null 
	$SQLPerfmonCollector_Start = "logman start sqlserverperf"
	out-file -filepath "$InstallPath\SQLServerPerf\BatchFiles\SQLPerfmonCollector-Start.bat" -inputobject $SQLPerfmonCollector_Start -Encoding Ascii 
	Write-Host "Creating File SQLPerfmonCollector-Start.bat"
	}
	
IF (!(Test-Path $InstallPath\SQLServerPerf\BatchFiles\SQLPerfmonCollector-Cycle.bat)) { 
	New-Item -ItemType file -Path "$InstallPath\SQLServerPerf\BatchFiles\SQLPerfmonCollector-Cycle.bat" -force -Confirm:$false | Out-Null 
	$SQLPerfmonCollector_Cycle = "logman stop sqlserverperf
	timeout /T 2
	POWERSHELL.EXE -ExecutionPolicy Unrestricted $InstallPath\SQLServerPerf\BatchFiles\CreatePerfmonJobs.ps1 
	logman start sqlserverperf"
	out-file -filepath "$InstallPath\SQLServerPerf\BatchFiles\SQLPerfmonCollector-Cycle.bat" -inputobject $SQLPerfmonCollector_Cycle -Encoding Ascii 
	Write-Host "Creating File SQLPerfmonCollector-Cycle.bat"
	}

IF (!(Test-Path $InstallPath\SQLServerPerf\Logs)) {
	New-Item -ItemType directory -Path $InstallPath\SQLServerPerf\Logs | Out-Null
	Write-Host "Creating Directory $InstallPath\SQLServerPerf\Logs"
	}

## Create Perfmon Counters
[Array]$PerfCounters = "Memory\Available MBytes",
"Memory\Pages/sec",
"Access Methods\Forwarded Records/sec",
"Access Methods\Full Scans/sec",
"Access Methods\Index Searches/sec",
"Buffer Manager\Buffer cache hit ratio",
"Buffer Manager\Checkpoint Pages/sec",
"Buffer Manager\Free List Stalls/sec",
"Buffer Manager\Lazy writes/sec",
"Buffer Manager\Page reads/sec",
"Buffer Manager\Page writes/sec",
"Buffer Manager\Readahead pages/sec",
"Buffer Node(*)\Page life expectancy",
"Buffer Node(*)\Remote node page lookups/sec",
"Databases\Transactions/sec",
"General Statistics\User Connections",
"Latches\Latch Waits/sec",
"Latches\Average Latch wait Time (ms)",
"Locks(_Total)\Average Wait Time (ms)",
"Locks(_Total)\Lock Waits/sec",
"Locks(_Total)\Number of Deadlocks/sec",
"Memory Manager\Target Server Memory (KB)",
"Memory Manager\Total Server Memory (KB)",
"Memory Manager\Memory Grants Pending",
"SQL Statistics\Batch Requests/sec",
"SQL Statistics\SQL Compilations/sec",
"SQL Statistics\SQL Re-Compilations/sec",
"Paging File(*)\% Usage",
"PhysicalDisk(*)\Avg. Disk sec/Read",
"PhysicalDisk(*)\Avg. Disk sec/Write",
"PhysicalDisk(*)\Disk Reads/sec",
"PhysicalDisk(*)\Disk Writes/sec",
"Process(sqlservr)\% Privileged Time",
"Process(sqlservr)\% Processor Time",
"Processor(*)\% Privileged Time",
"Processor(*)\% Processor Time",
"System\Processor Queue Length",
"Database Replica\Transaction Delay",
"Database Replica\Mirrored Write Transactions/sec",
"Availability Replica\Bytes Sent to Replica/sec",
"Availability Replica\Sends to Replica/sec",
"Availability Replica\Receives from Replica/sec",
"Availability Replica\Flow Control Time (ms/sec)",
"Availability Replica\Flow Control Time",
"Availability Replica\Resent message/sec"


 

$ArrCounters = $Null

ForEach ($Counter IN $PerfCounters) {
	$Counter2 = $Counter -replace "(\*)", "~"

	IF ($Counter2 -like "*(~)*") {
		$CounterSplit=$Counter2.split("\")                          
		$CounterGroup=$CounterSplit[0].replace("(~)","")
		$CounterDetail=$CounterSplit[1]
		[Array]$ArrCounters += (Get-Counter -ListSet "*$CounterGroup").pathsWithInstances | Where {$_ -like "*\$CounterDetail"} | Where {$_ -notlike "*_total*"}
	}
	Else {
		$CounterSplit=$Counter2.split("\")                          
		$CounterGroup=$CounterSplit[0].replace("(~)","")
		$CounterDetail=$CounterSplit[1]
		IF ($CounterGroup -like "*(*)*") {
			$CounterGroupSplit=$CounterGroup.split("(") 
			$CounterGroup=$CounterGroupSplit[0]
			$ProcessName = $CounterGroupSplit[1].replace(")","")
			[Array]$ArrCounters += (Get-Counter -ListSet "*$CounterGroup").pathsWithInstances | Where {$_ -like "*\$CounterDetail" -and $_ -like "*$ProcessName*"}
		}
		Else {
			[Array]$ArrCounters += (Get-Counter -ListSet "*$CounterGroup").paths | Where {$_ -like "*\$CounterDetail"} 
		}
	}
}

IF (!(Test-Path $InstallPath\SQLServerPerf\BatchFiles\SQLServer.cfg)) {

	out-file -filepath "$InstallPath\SQLServerPerf\BatchFiles\SQLServer.cfg" -inputobject $ArrCounters -Encoding Ascii 
	
	Write-Host "Creating PerfMon Counter - SQLServerPerf"

	logman create counter SQLServerPerf -f bin -si 300 -v nnnnnn -o "$InstallPath\SQLServerPerf\Logs\SQLServerPerf" -cf "$InstallPath\SQLServerPerf\BatchFiles\SQLServer.cfg"
	Start-Sleep 2
	Write-Host "Starting PerfMon Counter - SQLServerPerf"
	logman start sqlserverperf 
	Start-Sleep 2
	Write-Host "Creating Scheduled Tasks - 'SQLServerPerf - Cycle Perfmon Counter Log'"
	schtasks /create /tn "SQLServerPerf - Cycle Perfmon Counter Log" /tr $InstallPath\sqlserverperf\BatchFiles\SQLPerfmonCollector-Cycle.bat /sc daily /st 23:59:58 /ed 01/01/2099 /ru system 
	Start-Sleep 2
	Write-Host "Creating Scheduled Tasks - 'SQLServerPerf - Start Perfmon Counter Log'"
	schtasks /create /tn "SQLServerPerf - Start Perfmon Counter Log" /tr $InstallPath\sqlserverperf\BatchFiles\SQLPerfmonCollector-Start.bat /sc onstart /ru system 
	Write-Host "Creation Complete."
}
Else {
	Write-Host "Counter Already Exists!"
	out-file -filepath "$InstallPath\SQLServerPerf\BatchFiles\SQLServer.cfg" -inputobject $ArrCounters -Force -Encoding Ascii 
	Write-Host "Updating Existing Counter"
	logman update counter SQLServerPerf -cf "$InstallPath\SQLServerPerf\BatchFiles\SQLServer.cfg"
	Write-Host "Update Complete."
}






