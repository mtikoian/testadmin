<#
	.SYNOPSIS
		Deploy-ISPSolution
	.DESCRIPTION
		Adds and installs a Solution
	.PARAMETER url
		Web Application URL
	.PARAMETER solutionFile
		Solution file
	.EXAMPLE
		Deploy-ISPSolution -url  http://server_name -solution C:\SharePointProject.wsp
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param (
	[string]$url = "$(Read-Host 'Web Application Url [e.g. http://server_name]')", 
	[string]$solutionFile = "$(Read-Host 'Solution [e.g. C:\SharePointProject.wsp]')"
)

begin {
}
process {
	try {
		$PSSnapinSharePoin = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if( $PSSnapinSharePoin -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Add/install Solution to Web Application..."

		$file = Get-ChildItem $solutionFile
		$solution = Get-SPSolution -Identity $file.Name -ErrorAction SilentlyContinue

		if ($solution -eq $null) {
			$adminSvc = "SharePoint 2010 Administration"
			$service = Get-Service -DisplayName $adminSvc
			if ($service.Status -ne "Running") {
				Start-Service -DisplayName $adminSvc
				while ( (get-service -Name $adminSvc).Status -ne "Running" ) {
					Start-Sleep -Seconds 1
				}
			}
			Add-SPSolution -literalpath $solutionFile
			Install-SPSolution -identity $file.Name -GACDeployment -webapplication $url 
		} else {
			Throw "A solution with the same name already exists in the solution store."
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