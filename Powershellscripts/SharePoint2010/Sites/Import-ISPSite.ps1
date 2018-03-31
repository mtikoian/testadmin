<#
	.SYNOPSIS
		Import-ISPSite
	.DESCRIPTION
		Import site from any export file created by Export-ISPSite
	.PARAMETER url
		Site Url
	.PARAMETER selectedFile
		Import file name
	.EXAMPLE
		Import-ISPSite -url http:/server_name/sites/site1 -selectedFile C:\Export\ExportFile.exp
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param 
(
	[string]$url = "$(Read-Host 'Site Url [e.g. http:/server_name/sites/site1]')", 
	[string]$selectedfile = "$(Read-Host 'Selected file [e.g. c:\Export\ExportSite.exp]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Importing site ..."

		if(Test-Path $SelectedFile) {
			Import-SPWeb $url -path $selectedfile -Confirm
		} else {
			Throw "Selected file [ $selectedfile ] does not exist or is not accessible."
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