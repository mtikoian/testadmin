<#
	.SYNOPSIS
		Disable-ISPTimerJob
	.DESCRIPTION
		Disable a timer job by name
	.PARAMETER timerJob
		Timer job name 
		This parameter can be an exact match or a regular expression
	.EXAMPLE
		Disable-ISPTimerJob -timerJob "SearchAndProcess"
		Disable-ISPTimerJob -timerJob "Search*"
	.INPUTS
	.OUTPUTS
	.NOTES
		
	.LINK
#> 

param 
(
	[string]$timerJob = "$(Read-Host 'Timer Job [e.g. SearchAndProcess]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Disabling timer job(s) ..."

		$disableTimerJob = Get-SPTimerJob | where {$_.Name -match $timerJob} 
		$disableTimerJob | Disable-SPTimerJob
		
		Write-Output $disableTimerJob | select Name, IsDisabled, Schedule

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