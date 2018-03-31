<#
	.SYNOPSIS
		Stop-ISPCrawl
	.DESCRIPTION
		Stop crawl source for Enterprise Search Service
	.EXAMPLE
		Stop-ISPCrawl
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

		Write-Verbose "Stopping Enterprise Search Service crawl source ..."

		$crawlSource = Get-SPEnterpriseSearchCrawlContentSource -SearchApplication (Get-SPEnterpriseSearchServiceApplication)

		foreach($item in $crawlSource)
		{
			$item.StopCrawl()
			
			do { Start-Sleep 1 }
			while ( $item.CrawlStatus -ne "Idle" )
		}
		
		Write-Output "Stop crawl request on all sources is complete"

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