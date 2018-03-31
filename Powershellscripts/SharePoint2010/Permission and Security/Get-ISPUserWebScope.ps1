<#
	.SYNOPSIS
		Get-ISPUserWebScope
	.DESCRIPTION
		Get SharePoint user accounts matching Web scope
	.PARAMETER url
		Web Url
	.EXAMPLE
		Get-ISPUserWebScope -url http://server_name
	.INPUTS
	.OUTPUTS
		Users
	.NOTES
	.LINK
#> 

param (
	[string]$url = "$(Read-Host 'Web Url [e.g. http://server_name]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Get SharePoint user accounts matching Web Scope ..."

		$users = Get-SPUser -web $url

		Write-Output $users
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