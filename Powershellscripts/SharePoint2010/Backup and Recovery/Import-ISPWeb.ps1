<#
	.SYNOPSIS
		Import-ISPWeb
	.DESCRIPTION
		Import site subwebs exported by Export-ISPWeb
	.PARAMETER url
		Site URL
	.PARAMETER exportFile
		Exported file to import
	.EXAMPLE
		Import-ISPWeb -url http://server_name -selectedfile c:\Export\ExportFile.exp
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param 
(
	[string]$url = "$(Read-Host 'Site Url [e.g. http://server_name]')", 
	[string]$exportFile = "$(Read-Host 'Export File [e.g. c:\Export\ExportFile.exp]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if( $PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Importing subwebs from specified export file..."

		if(Test-Path $exportFile) {
			#  Default behavior is add new versions to the current file
			Import-SPWeb $url -path $exportFile -confirm:$True
		} else {
			Write-Error "Export file: $exportFile not found." 
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