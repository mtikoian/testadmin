<#
	.SYNOPSIS
		Deploy-ISPFeatures
	.DESCRIPTION
		Deploys, installs and enables features
	.PARAMETER url
		Site Url
	.PARAMETER featureFolder
		Feature folder to deploy
	.PARAMETER overwrite
		Overwrite feature if it already exists
	.EXAMPLE
		Deploy-ISPFeatures -url http://server_name -featureFolder C:\features\MyFeature -overwrite $false
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param 
(
	[string]$url = "$(Read-Host 'url [e.g. http://server_name]')", 
	[string]$featurefolder = "$(Read-Host 'featurefolder  [e.g. c:\Features\MyFeature]')",
	[boolean]$overwrite = $true
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Deploy, install and enable feature folder ..."

		if (Test-Path $featurefolder -PathType container)
		{
			$separators = '\'
			$field = $featurefolder.Split($separators,[stringsplitoptions]::RemoveEmptyEntries)
			$displayName = $field[$field.count -1]
			$displayName
			Copy-Item $featurefolder "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\14\TEMPLATE\FEATURES" -Recurse -Force -Confirm 

			$a = Get-SPFeature $displayName -ErrorAction silentlycontinue
			if( $a -ne $Null) {
				if ($overwrite -eq $true) {
					Disable-SPFeature $displayName -url $url
					Uninstall-SPFeature $displayName -force 
					Install-SPFeature $displayName -force
					Enable-SPFeature $displayName -url $url 
				}
			} else {
				Install-SPFeature $displayName -force
				Enable-SPFeature $displayName -url $url 
			}
		} else {
			Throw "$featurefolder does not exist." 
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