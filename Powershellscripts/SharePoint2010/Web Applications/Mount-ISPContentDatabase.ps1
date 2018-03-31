<#
	.SYNOPSIS
		Mount-ISPContentDatabase
	.DESCRIPTION
		Mount content database for specified Web Application
	.PARAMETER url
		Web Application Url
	.PARAMETER dbname
		Database name
	.PARAMETER serverInstance
		Database server instance
	.EXAMPLE
		Mount-ISPContentDatabase
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param 
(
	[string]$url = "$(Read-Host 'Web Application Url [e.g. http://portal]')", 
	[string]$dbname = "$(Read-Host 'Database name [e.g. SharePoint2007_Portal_Content]')",
	[string]$dbserver = "$(Read-Host 'Database server instance [e.g. spsql1]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Mount content database for specified Web Application Url..."

		Mount-SPContentDatabase –Name $dbname –DatabaseServer $dbserver –WebApplication $url

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