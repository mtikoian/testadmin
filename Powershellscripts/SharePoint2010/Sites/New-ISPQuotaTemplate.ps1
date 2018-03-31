<#
	.SYNOPSIS
		Set-ISPQuotaTemplate
	.DESCRIPTION
		Add a new quota template to the Quota Templates Collection
	.PARAMETER name
		Quota template name
	.PARAMETER storageMaxLevel
		Storage maximum level
	.PARAMETER storageWarnLevel
		Storage warning level
	.EXAMPLE
		New-SPQuotaTemplate -Name "Custom" -StorageMaximumLevel 2GB -StorageWarningLevel 1GB
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#>

Param(
	[String]$name = "$(Read-Host 'Quota Template Name: [e.g. Custom]')",
	[Int64]$storageMaximumLevel = 2GB,
	[Int64]$storageWarningLevel = 1GB
)

begin {
	[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Instantiating an instance of an SPQuotaTemplate class"

		$quota = New-Object Microsoft.SharePoint.Administration.SPQuotaTemplate

		Write-Verbose "Setting properties on the Quota object"

		$quota.Name = $name
		$quota.StorageMaximumLevel = $storageMaximumLevel
		$quota.StorageWarningLevel = $storageWarningLevel

		Write-Verbose "Getting an instance of an SPWebService class"

		$service = [Microsoft.SharePoint.Administration.SPWebService]::ContentService

		Write-Verbose "Adding the $($Name) Quota Template to the Quota Templates Collection"

		$service.QuotaTemplates.Add($quota)
		$service.Update()
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