<#
	.SYNOPSIS
		Set-ISPQuotaTemplate
	.DESCRIPTION
		Configure each site in site collection to use quota template
	.PARAMETER url
		Site Collection Url
	.PARAMETER template
		Quota template name
	.EXAMPLE
		Set-ISPQuotaTemplate -url http://server_name -template MyTemplate
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 
param 
(
	[string]$url = "$(Read-Host 'Site collection url: [e.g. http://server_name]')",
	[string]$template = "$(Read-Host 'Quota template: [e.g. MyTemplate]')" 
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

		Write-Verbose "Configuring site collection to use specified quota template ..."

		$quotaTemplate = [Microsoft.SharePoint.Administration.SPWebService]::ContentService.QuotaTemplates | 
			Where-Object {$_.Name -eq $template}

		Set-SPSite -Identity $url -QuotaTemplate $quotaTemplate
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