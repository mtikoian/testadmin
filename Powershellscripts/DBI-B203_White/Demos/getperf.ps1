#getperf.ps1
#Evaluates the SQL Server instances on a Windows server and returns performance data for each instance running

param(
	[string]$srv=$null,
	[int]$interval=$null,
	[datetime]$endat=$null
	)

$m = New-Object ('Microsoft.SqlServer.Management.Smo.WMI.ManagedComputer') $srv                              
$inst = $m.ServerInstances | select @{Name="SrvName"; Expression={$m.Name}}, Name

#Define the destination server and database names
$sqlsrv = "SQLTBWS\INST01"
$destdb = "ServerAnalysis"

#Initialize the Performance Counters for the machine
$ppt = New-Object System.Diagnostics.PerformanceCounter
$ppt.CategoryName = 'Processor'
$ppt.CounterName = '% Processor Time'
$ppt.InstanceName = '_Total'
$pptv = $ppt.NextValue()
$mab = New-Object System.Diagnostics.PerformanceCounter
$mab.CategoryName = 'Memory'
$mab.CounterName = 'Available MBytes'
$pfu = New-Object System.Diagnostics.PerformanceCounter
$pfu.CategoryName = 'Paging File'
$pfu.CounterName = '% Usage'
$pfu.InstanceName = '_Total'
$drs = New-Object System.Diagnostics.PerformanceCounter
$drs.CategoryName = 'PhysicalDisk'
$drs.CounterName = 'Avg. Disk sec/Read'
$drs.InstanceName = '_Total'
$dws = New-Object System.Diagnostics.PerformanceCounter
$dws.CategoryName = 'PhysicalDisk'
$dws.CounterName = 'Avg. Disk sec/Write'
$dws.InstanceName = '_Total'
$pql = New-Object System.Diagnostics.PerformanceCounter
$pql.CategoryName = 'System'
$pql.CounterName = 'Processor Queue Length'

#Initialize our instance counter collections
$fr = @()
$ps = @()
$bch = @()
$ple = @()
$lg = @()
$bp = @()
$brs = @()
$cs = @()
$rcs = @()


$inst | ForEach-Object { 
	if ($_.Name -eq 'MSSQLSERVER') {
		$srvnm = $_.Name
		}
	else {
		$srvnm = 'MSSQL$' + $_.Name
		}
	$stat = get-service -name $srvnm | select Status
	if ($stat.Status -eq 'Running') {
		$iname = $srvnm
		if ($iname -eq 'MSSQLSERVER') {
			$iname = 'SQLServer'
			}
		
		#Initialize the performance counters for each instance
		$frinit = New-Object System.Diagnostics.PerformanceCounter
		$frinit.CategoryName = $iname + ':Access Methods'
		$frinit.CounterName = 'Forwarded Records/sec'
		$frv = $frinit.NextValue()
		$fr += $frinit
		$psinit = New-Object System.Diagnostics.PerformanceCounter
		$psinit.CategoryName = $iname + ':Access Methods'
		$psinit.CounterName = 'Page Splits/sec'
		$psv = $psinit.NextValue()
		$ps += $psinit
		$bchinit = New-Object System.Diagnostics.PerformanceCounter
		$bchinit.CategoryName = $iname + ':Buffer Manager'
		$bchinit.CounterName = 'Buffer cache hit ratio'
		$bchv = $bchinit.NextValue()
		$bch += $bchinit
		$pleinit = New-Object System.Diagnostics.PerformanceCounter
		$pleinit.CategoryName = $iname + ':Buffer Manager'
		$pleinit.CounterName = 'Page life expectancy'
		$plev = $pleinit.NextValue()
		$ple += $pleinit
		$lginit = New-Object System.Diagnostics.PerformanceCounter
		$lginit.CategoryName = $iname + ':Databases'
		$lginit.CounterName = 'Log Growths'
		$lginit.InstanceName = '_Total'
		$lgv = $lginit.NextValue()
		$lg += $lginit
		$bpinit = New-Object System.Diagnostics.PerformanceCounter
		$bpinit.CategoryName = $iname + ':General Statistics'
		$bpinit.CounterName = 'Processes blocked'
		$bpv = $bpinit.NextValue()
		$bp += $bpinit
		$brsinit = New-Object System.Diagnostics.PerformanceCounter
		$brsinit.CategoryName = $iname + ':SQL Statistics'
		$brsinit.CounterName = 'Batch Requests/sec'
		$brsv = $brsinit.NextValue()
		$brs += $brsinit
		$csinit = New-Object System.Diagnostics.PerformanceCounter
		$csinit.CategoryName = $iname + ':SQL Statistics'
		$csinit.CounterName = 'SQL Compilations/sec'
		$csv = $csinit.NextValue()
		$cs += $csinit
		$rcsinit = New-Object System.Diagnostics.PerformanceCounter
		$rcsinit.CategoryName = $iname + ':SQL Statistics'
		$rcsinit.CounterName = 'SQL Re-Compilations/sec'
		$rcsv = $rcsinit.NextValue()
		$rcs += $rcsinit
		}
	}
		
while ($endat -gt (get-date)) {
	$dt = get-date
	
	#Send the next set of machine counters to our database
	$q = "declare @ServerID int; exec [Analysis].[insServerStats]"
	$q = $q + " @ServerID OUTPUT"
	$q = $q + ", @ServerNm='" + [string]$srv + "'"
	$q = $q + ", @PerfDate='" + [string]$dt + "'"
	$q = $q + ", @PctProc=" + [string]$ppt.NextValue()
	$q = $q + ", @Memory=" + [string]$mab.NextValue()
	$q = $q + ", @PgFilUse=" + [string]$pfu.NextValue()
	$q = $q + ", @DskSecRd=" + [string]$drs.NextValue()
	$q = $q + ", @DskSecWrt=" + [string]$dws.NextValue()
	$q = $q + ", @ProcQueLn=" + [string]$pql.NextValue()
	$q = $q + "; select @ServerID as ServerID"
	$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
	$SrvID = $res.ServerID


	#Now loop through the existing instances and initialize the counters for each SQL Server instance
	$i = 0
	$inst | ForEach-Object { 
		if ($_.Name -eq 'MSSQLSERVER') {
			$srvnm = $_.Name
			}
		else {
			$srvnm = 'MSSQL$' + $_.Name
			}
		$stat = get-service -name $srvnm | select Status
		if ($stat.Status -eq 'Running') {
			$iname = $srvnm
			if ($iname -eq 'MSSQLSERVER') {
				$iname = 'SQLServer'
				}
			
			#Send the next set of instance counters to the database
			$q = "declare @InstanceID int; exec [Analysis].[insInstanceStats]"
			$q = $q + " @InstanceID OUTPUT"
			$q = $q + ", @ServerID=" + [string]$SrvID
			$q = $q + ", @ServerNm='" + [string]$srv + "'"
			$q = $q + ", @InstanceNm='" + [string]$_.Name + "'"
			$q = $q + ", @PerfDate='" + [string]$dt + "'"
			$q = $q + ", @FwdRecSec=" + [string]$fr[$i].NextValue()
			$q = $q + ", @PgSpltSec=" + [string]$ps[$i].NextValue()
			$q = $q + ", @BufCchHit=" + [string]$bch[$i].NextValue()
			$q = $q + ", @PgLifeExp=" + [string]$ple[$i].NextValue()
			$q = $q + ", @LogGrwths=" + [string]$lg[$i].NextValue()
			$q = $q + ", @BlkProcs=" + [string]$bp[$i].NextValue()
			$q = $q + ", @BatReqSec=" + [string]$brs[$i].NextValue()
			$q = $q + ", @SQLCompSec=" + [string]$cs[$i].NextValue()
			$q = $q + ", @SQLRcmpSec=" + [string]$rcs[$i].NextValue()
			$q = $q + "; select @InstanceID as InstanceID"
			$res = invoke-sqlcmd -ServerInstance $sqlsrv -Database $destdb -Query $q
			$InstID = $res.InstanceID
			$i += 1
			
			}
		}
	
	Start-Sleep -s $interval
	}

