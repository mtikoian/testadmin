<#
	.SYNOPSIS
		Get-ISPFeatureSiteScope
	.DESCRIPTION
		Get features at the Site Scope
	.EXAMPLE
		Get-ISPFeatureSiteScope
	.INPUTS
	.OUTPUTS
		Features
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

		Write-Verbose "Getting features at the Site Scope ..."

		$features = Get-SPFeature -Limit All | Where-Object {$_.Scope -eq "SITE"} | Sort-Object DisplayName

		Write-Output $features
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