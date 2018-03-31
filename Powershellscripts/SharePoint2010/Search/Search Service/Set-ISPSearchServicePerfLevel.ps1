<#
	.SYNOPSIS
		Set-ISPSearchServicePerfLevel
	.DESCRIPTION
		Set the Search Service Performance Level
	.PARAMETER level
		Performance level
	.EXAMPLE
		Set-ISPSearchServicePerfLevel -level Reduced
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param 
(
	[string]$level = "$(Read-Host 'Performance Level [Valid choices: Reduced, Partly Reduced, Maximum]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Setting Search Service performance level ..."

		Set-SPSearchService -PerformanceLevel $Level

		if (!$Error) {
			Write-Output "Search Service Performance Level set to $Level"
		}
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