<#
	.SYNOPSIS
		Start-ISPTimerJob
	.DESCRIPTION
		Start a timer job by name
	.PARAMETER timerJob
		Timer job name
		This parameter can be an exact match or a regular expression
	.EXAMPLE
		Start-ISPTimerJob -timerJob SearchAndProcess
		Start-ISPTimerJob -timerJob "Search*"
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param 
(
	[string]$sptimerjob = "$(Read-Host 'Timer job [e.g. SearchAndProcess]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Starting timer job(s) ..."

		$startTimerJob = Get-SPTimerJob | where {$_.Name -match $sptimerjob} 
		$startTimerJob | Start-SPTimerJob
		
		Write-Output $startTimerJob | select Name, Schedule, LastRunTime

	}
	catch [Exception] {
		Write-Error $Error[0]
		$err = $_.Exception
		while ( $err.InnerException ) {
			$err = $err.InnerException
			Write-Output $err.Message
		}
	}
}