<#
	.SYNOPSIS
		Get-ISPQuotaTemplate
	.DESCRIPTION
		Configure each site in site collection to use quota template
	.EXAMPLE
		Get-ISPQuotaTemplate
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

begin {
	[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Get quota templates in Quota Template Collection ..."

		$quotaTemplates = [Microsoft.SharePoint.Administration.SPWebService]::ContentService.QuotaTemplates

		Write-Output $quotaTemplates

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