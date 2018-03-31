<#
	.SYNOPSIS
		Set-ISPWebAppQuotaTemplate
	.DESCRIPTION
		Replace quota template across all site collections in a web application
	.PARAMETER url
		Web Application Url
	.PARAMETER templateName
		Quota template name
	.EXAMPLE
		Set-ISPWebAppQuotaTemplate -url http://server_name -templateName MyTemplate1
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 
param 
(
	[string]$url = "$(Read-Host 'Web Application Url: [e.g. http://server_name]')",
	[string]$templateName = "$(Read-Host 'Quota Template: [e.g. MyTemplate1]')"
)

begin {
	[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Replacing quota template across all site collections in a web application ..."

		$contentService = [Microsoft.SharePoint.Administration.SPWebService]::ContentService
		$quotaTemplate = $contentService.QuotaTemplates[$templateName]
		Get-SPWebApplication $url | Get-SPSite -Limit all |
			ForEach-Object { $_.Quota = $quotaTemplate }
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