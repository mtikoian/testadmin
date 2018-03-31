<#
	.SYNOPSIS
		Uninstall-ISPFeature
	.DESCRIPTION
	.PARAMETER feature
		Feature folder name
	.EXAMPLE
		Uninstall-ISPFeature -feature MyCustomFeature
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
		http://msdn.microsoft.com/en-us/library/ms442691.aspx
#> 

param 
(
	[string]$feature = "$(Read-Host 'Feature name [e.g. MyCustomFeature]')" 
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Uninstall feature ..."
		
		Uninstall-SPFeature $feature -Force -Confirm:$True

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