<#
.SYNOPSIS
Loads a .csv PerfMon file into the PerfDW database for analysis.
.NOTES
	Author: Josh Feierman
.PARAMETER FileName
The name of the file to parse.
.PARAMETER ServerName
The name of the database server on which to import the data into.
.PARAMETER Truncate
Will truncate all the tables in the DB before running. Useful to clear out existing data.

#>

param
(
	[string]$FileName = "$env:temp\perfmon.csv",
	[string]$ServerName = "SEIEDEVUTILDB01",
	[switch]$Truncate,
  [switch]$Load
)

Set-StrictMode -Version 2.0;

#region Variables

$csvData = $null;
$prop = $null;
$propDef = "";
$exportCounter = 0;
$exportTotalCount = 0;
[datetime]$counterTime = [datetime]::Now;
[datetime]$startTime = [datetime]::Now;
[datetime]$endTime = [datetime]::Now;
[int]$timeElapsed = 0;
[int]$timeRemaining = 0;
$counterMachine = "";
$counterObject = "";
$counterInstance = "";
$counterName= "";
$counterVal = 0.000;
$percentComplete = 0;
$line = "";
$streamWriter = New-Object System.IO.StreamWriter("$env:temp\temp.csv");

#endregion

#region Pre-work

#Import the CSV file
$csv = Import-Csv -Path $FileName;

#If the -Truncate switch was used, truncate the tables
if ($Truncate)
{
	Invoke-Sqlcmd -ServerInstance $ServerName -Database "PerfMonDW" -Query "TRUNCATE TABLE PerfMon.stgCounterData";
	Invoke-Sqlcmd -ServerInstance $ServerName -Database "PerfMonDW" -Query "TRUNCATE TABLE PerfMon.dimCounter";
	Invoke-Sqlcmd -ServerInstance $ServerName -Database "PerfMonDW" -Query "TRUNCATE TABLE PerfMon.factCounterData";
}

#endregion


#region Transform CSV file to normalized format

Write-Progress -Activity "Exporting CSV file" -Status "Exporting" -PercentComplete 0;

$streamWriter.WriteLine("CounterTimestamp,Machine,Object,Instance,Name,Value")

$exportTotalCount = $csv.Count;

foreach ($csvData in $csv)
{
	
	$startTime = [datetime]::Now;
	foreach ($prop in ($csvData | Get-Member -MemberType NoteProperty))
	{
	
		$propDef = $prop.Definition;
		
		if ($prop.Name -like "(PDH-CSV*")
		{
			$counterTime = [datetime]::Parse([Regex]::Replace($propDef,".*=(.*)","`$1"));
		}
		else
		{
			$counterMachine = [Regex]::Replace($prop.Name,"\\\\([^\\]*)\\.*","`$1");
			$counterObject = [Regex]::Replace($prop.Name,"\\\\.*\\([^\\(]*)[\\(].*","`$1");
			if ([regex]::Match($prop.Name,".*\([^(KB)]*\).*").Success -eq $true)
			{
				$counterInstance = [Regex]::Replace($prop.Name,"\\\\.*\\.*\((.*)\).*","`$1");
			}
			else {$counterInstance = "";}
			$counterName = [regex]::Replace($prop.Name,"\\\\.*\\.*\\(.*)","`$1");
			$counterVal = [Regex]::Replace($propDef,".*=(.*)","`$1");
			
			#Add-Content -Value $counterTime","$counterMachine","$counterObject","$counterInstance","$counterName","$counterVal -Path "$Env:temp\test.csv";
			$line = $counterTime.ToString("yyyy-MM-dd") + " " + $counterTime.ToString("HH") + ":" + $counterTime.ToString("mm");
			$streamWriter.WriteLine("$line,$counterMachine,$counterObject,$counterInstance,$counterName,$counterVal");
		}
		
	}
  $streamWriter.Flush()
	$endTime = [datetime]::Now;
	$timeElapsed = $timeElapsed + ($endTime - $startTime).TotalMilliseconds;
	$exportCounter ++;
	$timeRemaining = (($timeElapsed/$exportCounter) * ($exportTotalCount-$exportCounter))/1000;
	$percentComplete = ($exportCounter/$exportTotalCount)*100;
	Write-Progress -Activity "Exporting CSV file" -Status "Exporting" -PercentComplete $percentComplete -SecondsRemaining $timeRemaining;
}

$streamWriter.Close();
$streamWriter.Dispose();

#endregion

#region BCP in the file

if ($Load)
{
  [string]$exp = "bcp PerfMonDW.PerfMon.stgCounterData IN $env:Temp\temp.csv -S $ServerName -T -c -t `",`" -b 10000";
  Invoke-Expression -Command $exp;
}

#endregion