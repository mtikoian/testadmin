<#
	.SYNOPSIS
		Set-ISPLogLevel
	.DESCRIPTION
		Set log level for single or multiple categories
	.PARAMETER evtsev
		Event severity
	.PARAMETER id
		Specifies single or multiple categories to set the throttle for
	.EXAMPLE
		Set-ISPLogLevel -evtsev ErrorCritical -id "Web Content Management:Asset Library"
		Set-ISPLogLevel -evtsev ErrorCritical -id "Web Content*:*"
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param(
	[string]$evtsev = "$(Read-Host 'Event Severity [e.g. None, ErrorCritical, Error, Warning, Information, Verbose]')",
	[string]$id = "$(Read-Host 'Area:Name [e.g. Web Content*:*]')" 
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Resetting SPLogLevel for a given identity ..."

		Set-SPLogLevel -EventSeverity $evtsev -Identity $id

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