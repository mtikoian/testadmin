##### Parameters #####
param
(
	[string]$Servername = "",
	[bool]$ShowExcel = $false,
	[string]$Savepath = "",
	[string]$ServerListFile = ""
)

function getServerRoleMembers($sheetnum)
{
	
	## Get members of server level roles ##
	write-progress -Activity "Retrieving members of server level roles" -Status "Setting Up Worksheet" -percentcomplete -1 -ParentId 2
	if ($wb.Sheets.Count -lt $sheetnum) 
	{
		$ws = $wb.Sheets.Add()
	}
	else
	{
		$ws = $wb.Sheets.Item($sheetnum)
	}
	$ws.Name = "Server Level Role Members"
	$row = 1
	$col = 1
	
	$ws.Cells.Item($row,$col) = "Role Name"
	$ws.Cells.Item($row,$col).Font.Bold = $true
	$col ++
	$ws.Cells.Item($row,$col) = "Member Name"
	$ws.Cells.Item($row,$col).Font.Bold = $true
	$col ++
	
	$row++
	$rolecount = $server.Roles.Count
	$currentrole = 1
	foreach ($role in $server.Roles)
	{
		write-progress -Activity "Retrieving members of server level roles" -Status "Collecting Data for role $role" -PercentComplete ($currentrole/$rolecount*100) -ParentId 2
		foreach ($member in $role.EnumServerRoleMembers())
		{
			$col = 1
			$ws.Cells.Item($row,$col) = $role.Name
			$col++
			$ws.Cells.Item($row,$col) = $member
			$row ++
		}
		$currentrole ++
	}
	$ws.UsedRange.EntireColumn.AutoFit() | out-null
}
		
function getSQLAgentJobInfo($sheetnum)
{
	## Get SQL Agent job information ##
	write-progress -Activity "Retrieving SQL Agent Job information" -Status "Setting Up Worksheet" -percentcomplete -1 -ParentId 2
	if ($wb.Sheets.Count -lt $sheetnum) 
	{
		$ws = $wb.Sheets.Add()
	}
	else
	{
		$ws = $wb.Sheets.Item($sheetnum)
	}
	$ws.Name = "SQL Agent Jobs"
	$row = 1
	$col = 1
	
	$ws.Cells.Item($row,$col) = "Job Name"
	$ws.Cells.Item($row,$col).Font.Bold = $true
	$col ++
	#$ws.Cells.Item($row,$col) = "Job Description"
	#$ws.Cells.Item($row,$col).Font.Bold = $true
	#$col ++
	$ws.Cells.Item($row,$col) = "Job Owner"
	$ws.Cells.Item($row,$col).Font.Bold = $true
	$col ++
	$ws.Cells.Item($row,$col) = "Last Run Date"
	$ws.Cells.Item($row,$col).Font.Bold = $true
	$col ++
	$ws.Cells.Item($row,$col) = "Last Run Result"
	$ws.Cells.Item($row,$col).Font.Bold = $true
	$col ++
	$ws.Cells.Item($row,$col) = "Enabled"
	$ws.Cells.Item($row,$col).Font.Bold = $true
	$col ++
	
	$row ++
	
	$jobcount = $server.JobServer.Jobs.Count
	$currentjob = 1
	foreach ($job in $server.JobServer.Jobs)
	{
		$col = 1
		$badrow = $false
		write-progress -Activity "Retrieving SQL Agent Job information" -Status "Collecting data for $job" -percentcomplete ($currentjob/$jobcount*100) -ParentId 2
		$ws.Cells.Item($row,$col) = $job.Name
		$col ++
		#$ws.Cells.Item($row,$col) = $job.Description
		#$col ++
		$ws.Cells.Item($row,$col) = $job.OwnerLoginName
		if ($job.OwnerLoginName -ne 'sa') {$ws.Cells.Item($row,$col).Font.Color = $red;$badrow = $true}
		$col ++
		$ws.Cells.Item($row,$col) = $job.LastRunDate
		$col ++
		if ($job.LastRunOutcome -eq 1) {$ws.Cells.Item($row,$col) = 'Succeeded'}
		elseif ($job.LastRunOutcome -eq 0) {$ws.Cells.Item($row,$col) = 'Failed'}
		else {$ws.Cells.Item($row,$col) = 'Unknown'}
		if ($job.LastRunOutcome -ne 1) {$ws.Cells.Item($row,$col).Font.Color = $red;$badrow = $true}
		$col ++
		$ws.Cells.Item($row,$col) = $job.IsEnabled
		$col ++
		
		if ($badrow -eq $true) 
		{
			$ws.Cells.Item($row,1).Interior.Color = $yellow
		}
		
		$row ++
		$currentjob ++
	}
	$ws.UsedRange.EntireColumn.AutoFit() | out-null
}

function getPhysicalServerInfo($sheetnum)
{
	## Get physical server info ##
	write-progress -Activity "Retrieving Physical Server Information" -Status "Setting Up Worksheet" -percentcomplete -1 -ParentId 2
	$ws = $wb.Worksheets.Item($sheetnum)
	$ws.Name = "Hardware Information"
	$row = 1
	
	#Physical computer#
	$CS = get-wmiobject -ComputerName $Servername -class win32_computersystem
	$OS = get-wmiobject -ComputerName $ServerName -class win32_operatingsystem
	$Procs = get-wmiobject -ComputerName $ServerName -class win32_processor

	write-progress -Activity "Retrieving Physical Server Information" -Status "Collecting data" -percentcomplete (1/9*100) -ParentId 2
	$ws.Cells.Item($row,1) = "Manufacturer"
	$ws.Cells.Item($row,1).Font.Bold = $true
	$ws.Cells.Item($row,2) = $CS.Manufacturer
	$ws.Cells.Item($row,2).HorizontalAlignment = -4131
	$row ++
	write-progress -Activity "Retrieving Physical Server Information" -Status "Collecting data" -percentcomplete (2/9*100) -ParentId 2
	$ws.Cells.Item($row,1) = "Model"
	$ws.Cells.Item($row,1).Font.Bold = $true
	$ws.Cells.Item($row,2) = $CS.Model
	$ws.Cells.Item($row,2).HorizontalAlignment = -4131
	$row ++
	write-progress -Activity "Retrieving Physical Server Information" -Status "Collecting data" -percentcomplete (3/9*100) -ParentId 2
	$ws.Cells.Item($row,1) = "Domain Membership"
	$ws.Cells.Item($row,1).Font.Bold = $true
	$ws.Cells.Item($row,2) = $CS.Domain
	$ws.Cells.Item($row,2).HorizontalAlignment = -4131
	$row ++
	write-progress -Activity "Retrieving Physical Server Information" -Status "Collecting data" -percentcomplete (4/9*100) -ParentId 2
	$ws.Cells.Item($row,1) = "OS Version"
	$ws.Cells.Item($row,1).Font.Bold = $true
	$ws.Cells.Item($row,2) = $OS.Caption
	$ws.Cells.Item($row,2).HorizontalAlignment = -4131
	$row ++
	write-progress -Activity "Retrieving Physical Server Information" -Status "Collecting data" -percentcomplete (5/9*100) -ParentId 2
	$ws.Cells.Item($row,1) = "Service Pack"
	$ws.Cells.Item($row,1).Font.Bold = $true
	$ws.Cells.Item($row,2) = $OS.ServicePackMajorVersion
	$ws.Cells.Item($row,2).HorizontalAlignment = -4131
	$row ++
	write-progress -Activity "Retrieving Physical Server Information" -Status "Collecting data" -percentcomplete (6/9*100) -ParentId 2
	$ws.Cells.Item($row,1) = "Number Of Processors"
	$ws.Cells.Item($row,1).Font.Bold = $true
	$ws.Cells.Item($row,2) = $Procs.Count
	$ws.Cells.Item($row,2).HorizontalAlignment = -4131
	$row ++
	write-progress -Activity "Retrieving Physical Server Information" -Status "Collecting data" -percentcomplete (7/9*100) -ParentId 2
	$ws.Cells.Item($row,1) = "Processor Description"
	$ws.Cells.Item($row,1).Font.Bold = $true
	if ($Procs.Count -gt 1)
	{
		$ws.Cells.Item($row,2) = $Procs[1].Name
	}
	else
	{
		$ws.Cells.Item($row,2) = $Procs.Name
	}
	$ws.Cells.Item($row,2).HorizontalAlignment = -4131
	$row ++
	$ws.Cells.Item($row,1) = "Total Number Of Cores"
	$ws.Cells.Item($row,1).Font.Bold = $true
	if ($Procs.Count -gt 1)
	{
		$ws.Cells.Item($row,2) = $Procs[1].NumberOfCores * $Procs.Count
	}
	else 
	{
		$ws.Cells.Item($row,2) = $Procs.NumberOfCores
	}
	$ws.Cells.Item($row,2).HorizontalAlignment = -4131
	write-progress -Activity "Retrieving Physical Server Information" -Status "Collecting data" -percentcomplete (8/9*100) -ParentId 2
	$row ++
	$ws.Cells.Item($row,1) = "Total Physical Memory"
	$ws.Cells.Item($row,1).Font.Bold = $true
	$ws.Cells.Item($row,2) = $CS.TotalPhysicalMemory / 1mb
	$ws.Cells.Item($row,2).HorizontalAlignment = -4131
	$row ++
	write-progress -Activity "Retrieving Physical Server Information" -Status "Collecting data" -percentcomplete (9/9*100) -ParentId 2
		
	$ws.UsedRange.EntireColumn.AutoFit() | out-null
}

function getSQLServerLevelInfo ($sheetnum)
{
	## Get server level info ##
	# Rename first worksheet
	$ws = $wb.Worksheets.Item($sheetnum)
	$ws.Name = "Server Info"
	
	write-progress "Retrieving SQL Server Information" -Status "Collecting Data" -percentcomplete 0 -ParentId 2
	$propcount = $server.Properties.Count
	$currentprop = 1
	
	foreach ($prop in $server.Properties)
	{
		write-progress "Retrieving SQL Server Information" -Status "Examining property $prop" -percentcomplete ($currentprop/$propcount*100) -ParentId 2
		$ws.Cells.Item($row,1) = $prop.Name
		$ws.Cells.Item($row,1).Font.Bold = $true
		$ws.Cells.Item($row,2) = $prop.Value
		$ws.Cells.Item($row,2).HorizontalAlignment = -4131
		$row ++
		$currentprop ++
		
	}
	$ws.UsedRange.EntireColumn.AutoFit() | out-null
}

function getSQLDBLevelInfo ($sheetnum)
{
	## Database Level Info ##
	write-progress -activity "Retrieving Database Information" -Status "Setting Up Worksheet" -percentcomplete 0 -ParentId 2
	$ws = $wb.Worksheets.Item($sheetnum)
	$ws.Activate();
	$ws.Name = "Database Info"
	
	# Populate Header Row #
	$ws.Cells.Item(1,1) = "Database Name"
	$ws.Cells.Item(1,2) = "Date Created"
	$ws.Cells.Item(1,3) = "Status"
	$ws.Cells.Item(1,4) = "Auto Close Enabled"
	$ws.Cells.Item(1,5) = "Auto Create Stats Enabled"
	$ws.Cells.Item(1,6) = "Auto Shrink Enabled"
	$ws.Cells.Item(1,7) = "Auto Update Stats Async Enabled"
	$ws.Cells.Item(1,8) = "Auto Update Stats Enabled"
	$ws.Cells.Item(1,9) = "Service Broker Enabled"
	$ws.Cells.Item(1,10) = "Case Sensitive Enabled"
	$ws.Cells.Item(1,11) = "Read Committed Snapshot Enabled"
	$ws.Cells.Item(1,12) = "Recovery Model"
	$ws.Cells.Item(1,13) = "Last Backup Date"
	$ws.Cells.Item(1,14) = "Last Log Backup Date"
	$ws.Cells.Item(1,15) = "Last DBCC Date"
	$ws.Cells.Item(1,16) = "Owner"
	$ws.Cells.Item(1,17) = "Trustworthy"
	#$ws.Cells.Item(1,18) = "Size"
	#$ws.Cells.Item(1,19) = "Space Free"
	
	# Set header to bold #
	$ws.Range("A1:S1").Font.Bold = $true
	
	$row = 2
	
	$dbcount = $server.Databases.Count
	$currentdb = 1
	
	foreach ($db in $server.Databases)
	{
		$badrow = $false
		write-progress -activity "Retrieving Database Information" -Status "Examining database $db" -percentcomplete ($currentdb/$dbcount*100) -ParentId 2
		
		$ws.Cells.Item($row,1) = $db.Name
		$ws.Cells.Item($row,2) = $db.CreateDate
		$ws.Cells.Item($row,3) = $db.Status
		if ($db.Status -ne 1) {$ws.Cells.Item($row,3).Font.Color = $red; $badrow = $true}
		$ws.Cells.Item($row,4) = $db.AutoClose
		if ($db.AutoClose -ne $false) {$ws.Cells.Item($row,4).Font.Color = $red; $badrow = $true}
		$ws.Cells.Item($row,5) = $db.AutoCreateStatisticsEnabled
		$ws.Cells.Item($row,6) = $db.AutoShrink
		if ($db.AutoShrink -ne $false) {$ws.Cells.Item($row,6).Font.Color = $red; $badrow = $true}
		$ws.Cells.Item($row,7) = $db.AutoUpdateStatisticsAsync
		$ws.Cells.Item($row,8) = $db.AutoUpdateStatisticsEnabled
		$ws.Cells.Item($row,9) = $db.BrokerEnabled
		if ($db.BrokerEnabled -ne $false) {$ws.Cells.Item($row,9).Font.Color = $red; $badrow = $true}
		$ws.Cells.Item($row,10) = $db.CaseSensitive
		if ($db.CaseSensitive -ne $false) {$ws.Cells.Item($row,10).Font.Color = $red; $badrow = $true}
		$ws.Cells.Item($row,11) = $db.IsReadCommittedSnapshotOn
		if ($db.RecoveryModel -eq 3) {$ws.Cells.Item($row,12) = "SIMPLE"}
		elseif ($db.RecoveryModel -eq 1) {$ws.Cells.Item($row,12) = "FULL"}
		else {$ws.Cells.Item($row,12) = "BULK LOGGED"}
		$ws.Cells.Item($row,13) = $db.LastBackupDate
		$ws.Cells.Item($row,13).NumberFormat = "[$-409]m/d/yy h:mm AM/PM;@"
		if ($db.LastBackupDate -lt [DateTime]::Now.Date.AddDays(-2)) {$ws.Cells.Item($row,13).Font.Color = $red; $badrow = $true}
		$ws.Cells.Item($row,14) = $db.LastLogBackupDate
		$ws.Cells.Item($row,14).NumberFormat = "[$-409]m/d/yy h:mm AM/PM;@"
		if (($db.LastLogBackupDate -lt [DateTime]::Now.AddMinutes(-120)) -and ($db.RecoveryModel -eq 1)) {$ws.Cells.Item($row,14).Font.Color = $red; $badrow = $true}
		$ws.Cells.Item($row,16) = $db.Owner
		IF ($db.Owner -ne 'sa') {$ws.Cells.Item($row,16).Font.Color = $red; $badrow = $true}
		$ws.Cells.Item($row,17) = $db.Trustworthy
		#$ws.Cells.Item($row,18) = "{0:N3}" -f $db.Size
		#$ws.Cells.Item($row,19) = "{0:N3}" -f $db.SpaceAvailable
	
		# Begin get last DBCC run date
		if ($db.Status -eq "Normal")
		{
			$UseSQL = "USE [" + $db.Name + "]"
			$ServerConn.ExecuteNonQuery($UseSQL) | out-null
			$LastDBCC = $ServerConn.ExecuteScalar($sql)
			$ws.Cells.Item($row,15) = $LastDBCC
			$ws.Cells.Item($row,15).NumberFormat = "[$-409]m/d/yy h:mm AM/PM;@"
			if ($LastDBCC -lt [DateTime]::Now.Date.AddDays(-7) -or ($LastDBCC -eq '1/1/1900 12:00AM')) {$ws.Cells.Item($row,15).Font.Color = $red; $badrow = $true}
		}
		if ($badrow)
		{
			$ws.Cells.Item($row,1).Interior.Color = $yellow
		}
		
		$row ++
		$currentdb ++
		
	}
	
	# Auto-fit columns and freeze pane for easy viewing #
	$ws = $wb.Sheets.Item("Database Info")
	$ws.Activate()
	$ws.Range("B2").Select() | out-null
	$excel.ActiveWindow.FreezePanes = $true
	$ws.UsedRange.EntireColumn.AutoFit() | out-null
}

function getServerInfo ($ServerName)
{	
	# Initialize objects
	$wb = $excel.WorkBooks.Add()
	$ws = $null
	
	write-progress -Activity "Collecting information for server $ServerName" -Status "Setting up SMO objects" -PercentComplete 0 -Id 2 -ParentID 1
	$server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $Servername
	$ServerConn = New-Object ('Microsoft.SqlServer.Management.Common.ServerConnection') $ServerName
	$ServerConn.Connect()
	$database = $null
	
	write-progress -Activity "Collecting information for server $ServerName" -Status "Physical Server Info" -PercentComplete 0 -Id 2 -ParentID 1
	getPhysicalServerInfo(1)
	write-progress -Activity "Collecting information for server $ServerName" -Status "SQL Server Info" -PercentComplete 20 -Id 2 -ParentID 1
	getSQLServerLevelInfo(2)
	write-progress -Activity "Collecting information for server $ServerName" -Status "Database Info" -PercentComplete 40 -Id 2 -ParentID 1
	getSQLDBLevelInfo(3)
	write-progress -Activity "Collecting information for server $ServerName" -Status "Agent Job Info" -PercentComplete 60 -Id 2 -ParentID 1
	getSQLAgentJobInfo(4)
	write-progress -Activity "Collecting information for server $ServerName" -Status "Server Role Members" -PercentComplete 80 -Id 2 -ParentID 1
	getServerRoleMembers(5)
	write-progress -Activity "Collecting information for server $ServerName" -Status "Complete" -PercentComplete 100 -Id 2 -ParentID 1
	
	# Cleanup
	if ($Savepath -ne "")
	{
		$Savepath = $Savepath + "\" + $servername + ".xlsx"
		$wb.SaveAs($Savepath)
		$wb.Close()
	}
	$ServerConn.Disconnect()
	$ServerConn = $null
	$server = $null
}

##### Variable Declaration ######

clear

# Check inputs
if ($Savepath -eq "")
{
	write-error -Message "A value for parameter SavePath was not provided." -RecommendedAction "Please provide a path to save the audit file(s) at."
	return
}
if (($ServerName -eq "") -and ($ServerListFile -eq ""))
{
	write-error -Message "Neither the ServerName or ServerListFile parameters were provided values." -RecommendedAction "You must provide either a single server name using the ServerName parameter, or provide a file with a list of servers using the ServerListFile parameter."
	return
}

## Excel objects ##
write-progress -Activity "SQL Server Audit Script" -Status "Setting up Excel objects" -PercentComplete 0 -Id 1
$excel = New-Object -ComObject Excel.Application
$row = 1
$col = 1
$Yellow = 65535
$Red = 255
$White = 16777215
if ($ShowExcel) {$excel.Visible = $true}
## SQL variable ##
$sql = @"
CREATE TABLE #tmp
(
    ParentObject NVARCHAR(260),
    Object NVARCHAR(260),
    Field NVARCHAR(260),
    Value NVARCHAR(260)
);

INSERT #tmp
EXEC('DBCC DBINFO WITH TABLERESULTS');

select top 1 Value 
from #tmp
where Field = 'dbi_dbccLastKnownGood'

DROP TABLE #tmp;
"@

# Load SMO assembly
write-progress -Activity "SQL Server Audit Script" -Status "Loading SMO assembly" -PercentComplete 0 -Id 1
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
write-progress -Activity "SQL Server Audit Script" -Status "Beginning data collection" -PercentComplete 0 -Id 1

# If a file is given, begin looping
if ($ServerListFile -ne "")
{
	# Get the contents of the file #
	$Servers = get-content $ServerListFile
	
	# Setup the counter variables
	$ServerCount = $Servers.Count
	$CurrentServer = 1
	
	write-progress -Activity "SQL Server Audit Script" -Status "Collecting Data" -PercentComplete 0 -Id 1
	
	foreach ($Servername in $Servers)
	{
		write-progress -Activity "SQL Server Audit Script" -Status "Collecting Data for Server $Servername" -PercentComplete ($CurrentServer/$ServerCount*100) -Id 1
		getServerInfo($ServerName)
		$CurrentServer ++
	}
}
else
{
		write-progress -Activity "SQL Server Audit Script" -Status "Collecting Data for Server $Servername" -PercentComplete 0 -Id 1
		getServerInfo($ServerName)
}

#Cleanup
$excel.Quit()
$excel = $null
$wb = $null
$ws = $null
	


