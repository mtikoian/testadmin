<#
	.SYNOPSIS
		Get-ISPSolutionFeatures
	.DESCRIPTION
		Gets features for a given Solution
	.PARAMETER solution
		Solution Name
	.EXAMPLE
		Get-ISPSolutionFeatures -solution MyCustomeSolution.wsp
	.INPUTS
	.OUTPUTS
		Features
	.NOTES
	.LINK
#> 

param 
(
	[string]$solution = "$(Read-Host 'Solution name: [e.g. MyCustomeSolution.wsp]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Getting solution features ..."

		$features = @()

		$solution = Get-SPSolution $solution -ErrorAction SilentlyContinue
		foreach ($grp in Get-SPFeature | where {$_.SolutionID -eq $solution.id} | Group-Object SolutionId) {
			foreach ($fd in $grp.Group | sort DisplayName ) {
				$feature = New-Object -TypeName PSObject -Property @{
					SolutionName = $solution.Name
					SolutionId = $solution.Id
					FeatureName = $fd.DisplayName
					FeatureId = $fd.Id
					FeatureScope = $fd.Scope
				}
				$features += $feature
			}
		}

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