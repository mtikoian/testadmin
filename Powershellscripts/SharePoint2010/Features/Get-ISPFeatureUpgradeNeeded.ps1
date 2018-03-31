<#
	.SYNOPSIS
		Get-ISPFeatureUpgradeNeeded
	.DESCRIPTION
		Get features that need upgrading
	.PARAMETER featureName
		Feature name
	.EXAMPLE
		Get-ISPFeatureUpgradeNeeded -feature MyCustomFeature
	.INPUTS
	.OUTPUTS
		Feature needing upgrade
	.NOTES
	.LINK
		http://www.sharepointnutsandbolts.com/2010/08/feature-upgrade-part-5-using-powershell.html
#> 

param 
(
	[string]$featureName = "$(Read-Host 'Feature name [e.g. MyCustomFeature]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Query for features requiring upgrading ..."
		
		$fd = Get-SPFeature $featureName
		
		switch ($fd.Scope) {
			"Farm" {
				$output = [Microsoft.SharePoint.Administration.SPWebService]::AdministrationService.QueryFeatures($fd.Id, $true) 
				break
			}
			"WebApplication" {
				$output = [Microsoft.SharePoint.Administration.SPWebService]::QueryFeaturesInAllWebServices($fd.Id, $true) 
				break
			}
			"Site" {
				$output = foreach ($webapp in Get-SPWebApplication) { 
					$webapp.QueryFeatures($fd.Id, $true) 
				}
				break
			}
			"Web" {
				$output = foreach ($site in Get-SPSite -Limit All) {
					$site.QueryFeatures($fd.Id, $true) 
				}
				break
			}
		}	
		
		Write-Output $output

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