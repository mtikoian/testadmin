<#
	.SYNOPSIS
		Remove-ISPManagedPath
	.DESCRIPTION
		Remove managed path
	.PARAMETER url
		Web Application Url
	.PARAMETER managedPathName
		Relative Url
	.EXAMPLE
		Remove-ISPManagedPath -url http://server_name -relativeUrl projects
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param 
(
	[string]$utl = "$(Read-Host 'Web Application Url [e.g. http://server_name]')", 
	[string]$managedPathName = "$(Read-Host 'Managed Path Name [e.g. projects]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Removing managed path..."

		Remove-SPManagedPath –Identity $managedPathName –WebApplication $url –Confirm:$false

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