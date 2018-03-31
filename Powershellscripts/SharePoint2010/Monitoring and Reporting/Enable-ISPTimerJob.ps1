<#
	.SYNOPSIS
		Enable-ISPTimerJob
	.DESCRIPTION
		Enable a timer job by name
	.PARAMETER timerJob
		Timer job name
		This parameter can be an exact match or a regular expression
	.EXAMPLE
		Enable-ISPTimerJob -timerJob SearchAndProcess
		Enable-ISPTimerJob -timerJob "Search*"
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param 
(
	[string]$timerJob = "$(Read-Host 'Timer job [e.g. SearchAndProcess]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Enabling timer job(s) ..."

		$enableTimerJob = Get-SPTimerJob | where {$_.Name -match $timerJob}
		$enableTimerJob | Enable-SPTimerJob 
		
		Write-Output $enableTimerJob | select Name, IsDisabled, Schedule

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