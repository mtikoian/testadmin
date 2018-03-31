<#
	.SYNOPSIS
		Add-ISPBlockedFileType
	.DESCRIPTION
		Add blocked file type to each web application in collection
	.PARAMETER url
		Url scope of web applications
	.PARAMETER ext
		Extension of file type to block
	.EXAMPLE
		Add-ISPBlockedFileType -url http:\\server_name -ext ade
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param 
(
	[string]$utl = "$(Read-Host 'Web Application Url [e.g. http://server_name]')", 
	[string]$ext = "$(Read-Host 'Extension [e.g. ade]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Blocking specified file type by extension..."

		$spwebapps = Get-SPWebApplication $url
		Foreach($webapp in $spwebapps){
			$webapp.BlockedFileExtensions.Add($ext)
			$webapp.Update()
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