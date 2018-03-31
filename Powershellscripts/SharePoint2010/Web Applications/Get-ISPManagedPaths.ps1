<#
	.SYNOPSIS
		Get-ISPManagedPath
	.DESCRIPTION
		Get managed paths for a given Web Application
	.PARAMETER url
		Web Application Url
	.EXAMPLE
		Get-ISPManagedPath -url http://server_name
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param 
(
	[string]$url = "$(Read-Host 'Web Application Url [e.g. http://server_name]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Get managed path..."

		$managedPath = Get-SPManagedPath –WebApplication $url
		
		Write-Output $managedPath

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