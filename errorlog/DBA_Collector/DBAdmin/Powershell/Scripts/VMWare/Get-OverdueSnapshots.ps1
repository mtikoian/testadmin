<#
.SYNOPSIS
 Retrieves a list of snapshots that are overdue (based on the provided -Days parameter).
.DESCRIPTION
 Retrieves a list of snapshots that are overdue (based on the provided -Days parameter). 
 
 If run without the  "-Scheduled" switch, the script creates a CSV file and displays it 
 in Excel (or whatever is the default viewer for .csv files).
 
 
.NOTES
 Author - Josh Feierman
.PARAMETER Days
 The number of days which, if a snapshot is older than, it will be considered overdue.
.PARAMETER Scheduled
 If set, indicates that the script is being run in non-interactive mode, and will result in
 e-mails being sent to the server owners.
.PARAMETER VIServer
 The name of the vCenter server to connect to (required only if "-Scheduled" is specified).
.PARAMETER CC
 The e-mail address to copy all notification e-mails on (required only if "-NotifyOwners" is specified).
.PARAMETER AsHTML
 Will generate the report as HTML instead of a CSV file
#>

param
(
	[parameter(mandatory=$true)][int]$Days,
	[parameter()][switch]$Scheduled,
	[parameter()][string]$VIServer,
	[parameter()][switch]$NotifyOwners,
	[parameter()][string]$CC,
	[parameter()][switch]$AsHTML
)

#If we're running in scheduled mode, we need to 1) import the VMWare snap-in, 2) connect to the vCenter server
if ($Scheduled)
{
  If ($VIServer -eq $null) { throw "You must specify a vCenter server using the '-VIServer' parameter when running in scheduled mode.";}
  Add-PSSnapin VMware.VimAutomation.Core;
  Connect-VIServer $VIServer;
}

#Get a list of VMs with snapshots
$vms = Get-View -ViewType "VirtualMachine" | Where-Object {$_.Snapshot -ne $null} | Select-Object MORef | % {Get-VIObjectByVIView -MORef $_.MORef};

#Iterate through and retrieve information about the snapshots
$snapshots = @();

$totalCount = $vms.Count;
$currentCount = 0;
$percentComplete = 0;

foreach ($vm in $vms)
{
	Write-Progress -Activity "Retrieving snapshot information" -Status "Retrieving for VM $($vm.Name) ($($currentCount) of $($totalCount))" -PercentComplete $percentComplete;
	
	$vmSnapshots = Get-Snapshot -VM $vm.Name;
	
	foreach ($snapshot in $vmSnapshots)
	{
		if ($snapshot.Created -le [DateTime]::Today.AddDays(-$Days))
		{
			$snapshotInfo = "" | select VMName, OwnerEMail, SnapshotName, SnapshotDate, SnapshotSize;
			$snapshotInfo.VMName = $vm.Name;
			$snapshotInfo.SnapshotName = $snapshot.Name;
			$snapshotInfo.SnapshotDate = $snapshot.Created;
			$snapshotInfo.SnapshotSize = $snapshot.SizeMB;
			$snapshotInfo.OwnerEMail = $vm.CustomFields["Owner E-Mail"];
			
			$snapshots += $snapshotInfo;
		}
	}
	
	$currentCount ++;
	$percentComplete = $currentCount / $totalCount * 100;
	
}

Write-Progress -Activity "Retrieving snapshot information" -Status "Complete" -Completed;

$tempFileName = [System.IO.Path]::GetTempFileName();
if ($AsHTML)
{
  #Get the CSS file content
  $css = Get-Content .\Report.css;
  
  #Export to html
  $snapshots | Sort-Object OwnerEMail,SnapshotName,VMName | ConvertTo-Html -Head "<title>Snapshot Report</title><style type=`"text/css`">$css</style>" | Out-File "$tempFileName.html";
}
else
{
  $snapshots | Sort-Object OwnerEMail,SnapshotName,VMName | Export-Csv -Path "$tempFileName.csv" -NoTypeInformation;
}

if (!$Scheduled -and $AsHTML)
{
  Invoke-Item "$tempFileName.html";
}
elseif (!$Scheduled)
{
  Invoke-Item "$tempFileName.csv";
}
else
{
  # Future placeholder for scheduled use
}
