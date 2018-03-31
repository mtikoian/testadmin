<#
	.SYNOPSIS
		New-ISPManagedPath
	.DESCRIPTION
		Add a new managed path
	.PARAMETER url
		Web Application URL
	.PARAMETER managedPathName
		Relative URL
	.EXAMPLE
		New-ISPManagedPath -url http://server_name -relativeUrl projects
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param 
(
	[string]$url = "$(Read-Host 'Web Application Url [e.g. http://server_name]')", 
	[string]$managedPathName = "$(Read-Host 'Managed Path Name [e.g. projects]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Checking managed path if exists already..."

		$managedPath = Get-SPManagedPath -WebApplication $url -Identity $managedPathName -ErrorAction SilentlyContinue
		if ($managedPath -ne $null) {
			Write-Error "Managed path $managedPathName already exists."
		} else {
			Write-Verbose "Creating managed path $managedPathName ..."
			New-SPManagedPath –RelativeURL $managedPathName -WebApplication $url
			Write-Verbose "Managed path $managedPathName created sucessfully"
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