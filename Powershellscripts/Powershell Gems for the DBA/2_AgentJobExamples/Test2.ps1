## works when running via Operating System (CmdExec) job type

<#SQL Server Agent implements a job subsystem that allows users to directly run PowerShell scripts
in SQL Server Agent. Internally this is implemented by reusing the SQLPS.EXE shell stub (which is 
another shape of POWERSHELL.EXE, but preconfigured for SQL Server).
#>

# Best to run in Operating System (CmdExec) so that Exit 1 set job to fail and you get output of write-host

try {
	$d = '1/1/2011'

	$SnapshotDate = [datetime]::ParseExact($Snapshotdate, "dd/MM/yyyy h:mm:ss tt", $null)

}
catch 
{
	write-host "Caught an exception:"  -ForegroundColor yellow
	write-host  "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor yellow
	write-host  "Exception Message: $($_.Exception.Message)" -ForegroundColor yellow
    exit 1
}