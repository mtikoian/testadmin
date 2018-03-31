<#
	.SYNOPSIS
		Start-ISPCrawl
	.DESCRIPTION
		Start crawl source for Enterprise Search Service
	.EXAMPLE
		Start-ISPCrawl
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Starting Enterprise Search Service crawl source ..."

		$crawlSource = Get-SPEnterpriseSearchCrawlContentSource -SearchApplication (Get-SPEnterpriseSearchServiceApplication)

		foreach($item in $crawlSource)
		{
			$item.StartFullCrawl()
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