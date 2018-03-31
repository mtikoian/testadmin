<#
	.SYNOPSIS
		Add-ISPListToQuickLaunch
	.DESCRIPTION
		Add a list to the QuickLaunch bar
	.PARAMETER url
		Web Application Url
	.PARAMETER list
		List to add
	.EXAMPLE
		Add-ISPListToQuickLaunch -url http://moss -list Users
	.INPUTS
	.OUTPUTS
	.NOTES
		Adapted From Niklas Goude Script
	.LINK
#> 

param (
	[string]$url = "$(Read-Host 'Web Application Url [e.g. http://moss]')", 
	[string]$List = "$(Read-Host 'List [e.g. My List]')"
)

begin {
	[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction silentlycontinue
		if( $PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}
		
		Write-Verbose "Adding List to QuickLaunch bar..."
		
		$OpenWeb = Get-SPWeb $url
		$OpenList = $OpenWeb.Lists[$List]
		$OpenList.OnQuickLaunch = $true
		$OpenList.Update()
		$OpenWeb.Dispose()
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