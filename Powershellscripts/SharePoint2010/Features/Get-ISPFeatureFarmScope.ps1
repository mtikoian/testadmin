<#
	.SYNOPSIS
		Get-ISPFeatureFarmScope
	.DESCRIPTION
		Get all features at the Farm scope
	.PARAMETER
	.EXAMPLE
		Get-ISPFeatureFarmScope
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
		
		Write-Verbose "Getting Farm Scope Features..."
		
		$features = Get-SPFeature -Farm -Limit All | Sort-Object DisplayName
		
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