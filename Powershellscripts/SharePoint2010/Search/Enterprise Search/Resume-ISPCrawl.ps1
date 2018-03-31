<#
	.SYNOPSIS
		Resume-ISPCrawl
	.DESCRIPTION
		Resume crawl source for Enterprise Search Service
	.EXAMPLE
		Resume-ISPCrawl
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

		Write-Verbose "Resuming Enterprise Search Service crawl source ..."

		$crawlSource = Get-SPEnterpriseSearchCrawlContentSource -SearchApplication (Get-SPEnterpriseSearchServiceApplication)

		foreach($item in $crawlSource)
		{
			$item.ResumeCrawl()
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