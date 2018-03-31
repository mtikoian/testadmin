<#
	.SYNOPSIS
		Export-ISPWeb
	.DESCRIPTION
		Export site subwebs
	.PARAMETER url
		Site Url
	.PARAMETER location
		Export location
	.EXAMPLE
		Export-ISPWeb -url http://server_name -location C:\Export
	.INPUTS
	.OUTPUTS
		Export file for each subweb in the site and a log file
	.NOTES
	.LINK
#> 

param 
(
	[string]$url = "$(Read-Host 'Site or Subsite Url [e.g. http://server_name/sites/site1]')", 
	[string]$location = "$(Read-Host 'Export Location  [e.g. C:\Export]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}
		
		Write-Verbose "Exporting subwebs in Site $url..."

		if(Test-Path $location -PathType container) { 

			$dateString = get-date -format "yyyy_MM_dd_hh_mm_ss"
			$SPWeb = Get-SPWeb -site $url

			foreach($web in $SPWeb) { 
				$filename = $dateString + "-" + $web.Url.replace("http://","").replace("-","_").replace("/","_") + ".exp"
				$pattern = "[{0}]" -f ([Regex]::Escape([String] [System.IO.Path]::GetInvalidFileNameChars())) 
				$filename = [Regex]::Replace($filename, $pattern, '')
				$filepath = New-Item -type file -path $location -name $filename

				Export-SPWeb $web -path $filepath -Force
			} 
		} else {
			Throw "Backup location: $location does not exist." 
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