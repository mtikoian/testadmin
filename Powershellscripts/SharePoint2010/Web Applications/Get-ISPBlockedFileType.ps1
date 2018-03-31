<#
	.SYNOPSIS
		Get-ISPBlockedFileType
	.DESCRIPTION
		Get blocked file types for a given Web Application
	.PARAMETER url
		Web Application Url
	.EXAMPLE
		Get-ISPBlockedFileType -url http://server_name
	.INPUTS
	.OUTPUTS
		Blocked file types
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

		Write-Verbose "Get blocked file types..."

		$blockedFileTypes = @()

		$spwebapps = Get-SPWebApplication $url
		Foreach($webapp in $spwebapps){
			$blockedFileTypes += $webapp.BlockedFileExtensions
		}

		Write-Output $blockedFileTypes	

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