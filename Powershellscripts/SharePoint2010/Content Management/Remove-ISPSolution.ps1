<#
	.SYNOPSIS
		Remove-ISPSolution
	.DESCRIPTION
		Uninstalls and removes a selected solution
	.PARAMETER solutionName
		Solution name
	.EXAMPLE
		Remove-ISPSolution -solutionName SharePointProject.wsp
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param (
	[string]$solutionName = "$(Read-Host 'Solution Name  [e.g. SharePointProject.wsp]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if( $PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Removing Solution..."

		$solution = Get-SPSolution -Identity $solutionName 

		if ($solution -ne $null) {
			if($solution.Deployed -eq $true) {
				Uninstall-SPSolution -identity $solutionName -AllWebApplications 
			}
			
			# Wait for uninstall job to complete
			if ($solution.JobExists) {
				while ( $solution.JobExists ) {
					sleep 1
				}
			}

			Remove-SPSolution -identity $solutionName -force
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