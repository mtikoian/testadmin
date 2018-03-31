<#
	.SYNOPSIS
		Get-ISPUsageServiceInfo
	.DESCRIPTION
		Gets and displays the Usage Service Information
	.EXAMPLE
		Get-ISPUsageServiceInfo
	.INPUTS
	.OUTPUTS
		Usage Service Information report
	.NOTES
	.LINK
#> 

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Getting Usage Service Information report..."

		$UsageService = Get-SPUsageService
		
		"UsageService Info "
		"========================================================================="
		"Log enabled: " + $UsageService.LoggingEnabled 
		"Log file location: " + $UsageService.UsageLogDir 
		"Maximum log file size: " + $UsageService.UsageLogMaxSpaceGB + " GB"
		"Creates a new usage log file every : " + $UsageService.UsageLogCutTime + " minutes" 
		""
		"Events to log: " 
		"========================================================================="
		Get-SPUsageDefinition 

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