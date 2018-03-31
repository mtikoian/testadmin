<#
	.SYNOPSIS
		Test-ISPUnregisteredFeatures
	.DESCRIPTION
		Shows the unregistered features that are available on the file system and shows
		results without registering them
	.EXAMPLE
		Test-ISPUnregisteredFeatures
	.INPUTS
	.OUTPUTS
	.NOTES
		Unregistered is defined as Deployed but Uninstalled
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

		Write-Verbose "Getting unregistered features ..."

		$unregistered = Install-SPFeature -ScanForFeatures

		Write-Output $unregistered

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