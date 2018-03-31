<#
	.SYNOPSIS
		Update-ISPSolution
	.DESCRIPTION
		Updates a selected solution
	.PARAMETER solutionName
		Solution Name
	.PARAMETER solutionFile
		Solution File
	.EXAMPLE
		Update-ISPSolution -solutionName SharePointProject.wsp -solutionFile c:\SharePointProject.wsp
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param (
	[string]$solutionName = "$(Read-Host 'Solution Name [e.g. SharePointProject.wsp]')",
	[string]$solutionFile = "$(Read-Host 'Solution File  [e.g. c:\SharePointProject.wsp]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if( $PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Updating Solution..."

		Update-SPSolution -Identity $solutionName -LiteralPath $solutionFile -GACDeployment
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