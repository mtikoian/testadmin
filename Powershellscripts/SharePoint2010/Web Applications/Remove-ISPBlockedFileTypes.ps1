<#
	.SYNOPSIS
		Remove-ISPBlockedFileTypes
	.DESCRIPTION
		Remove blocked file types
	.PARAMETER url
		Web Application Url
	.PARAMETER ext
		Extension to remove from blocked file types
	.EXAMPLE
		Remove-ISPBlockedFileTypes -url http://server_name -ext ade
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param 
(
	[string]$url = "$(Read-Host 'Web Application Url [e.g. http://server_name]')", 
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

		Write-Verbose "Removing blocked file type by extension..."

		$spwebapps = Get-SPWebApplication $url
		Foreach($webapp in $spwebapps){
			$webapp.BlockedFileExtensions.Remove($ext)
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