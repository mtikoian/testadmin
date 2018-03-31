<#
	.SYNOPSIS
		Export-ISPSite
	.DESCRIPTION
		Export site
	.PARAMETER url
		Site url to export
	.PARAMETER location
		Export location
	.EXAMPLE
		Export-ISPSite -url http://server_name/sites/site1 -location C:\Export
	.INPUTS
	.OUTPUTS
		Export file to specified location
	.NOTES
	.LINK
#> 

param 
(
	[string]$url = "$(Read-Host 'Site Url [e.g. http://server_name/sites/site1]')",
	[string]$location = "$(Read-Host 'Location [e.g. C:\export]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Exporting Site ..."

		if(Test-Path $location -PathType container)
		{
			$dateString = get-date -format "yyyy_MM_dd_hh_mm_ss"

			$filename = $dateString + "-Site-" + $url.replace("http://","").replace("-","_").replace("/","_") + ".exp" 
			$pattern = "[{0}]" -f ([Regex]::Escape([String] [System.IO.Path]::GetInvalidFileNameChars())) 
			$filename = [Regex]::Replace($filename, $pattern, '')
			$filepath = $location + "\" + $filename
 
			Export-SPWeb -identity $url -path $filepath -IncludeVersions CurrentVersion
		} else {
			Throw "Export location: $location does not exist or is not accessible." 
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