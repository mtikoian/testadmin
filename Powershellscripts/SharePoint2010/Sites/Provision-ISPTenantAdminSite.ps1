<#
	.SYNOPSIS
		Provision-ISPTenantAdminSite
	.DESCRIPTION
		Create a site subscription, add a Tenant Administration site and assign subscription
	.PARAMETER url
		Site Url
	.PARAMETER ownerEmail
		Owner email address
	.PARAMETER ownerAlias
		Domain user account
	.EXAMPLE
		Provision-ISPTenantAdminSite -url http:/server_name/sites/site1 -ownerEmail someone@domain.com -ownerAlias <domain\user>
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param 
(
	[string]$url = "$(Read-Host 'Site Url [e.g. http:/server_name/sites/site1]')", 
	[string]$ownerEmail = "$(Read-Host 'Owner Email (Optional) [e.g. someone@domain.com]')",
	[string]$ownerAlias = "$(Read-Host 'Owner Alias [e.g. <domain\user>]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Provisioning Tenant Administrative Site..."

		#Create Site Subscription
		$subscription = New-SPSiteSubscription

		#Create a Tenant Administration Site
		if ($ownerEmail -ne "") {
			$site = New-SPSite –Url $url –Template TenantAdmin#0 –OwnerEmail $ownerEmail –OwnerAlias $ownerAlias –SiteSubscription $subscription
		} else {
			$site = New-SPSite –Url $url –Template TenantAdmin#0 –OwnerAlias $ownerAlias –SiteSubscription $subscription
		}
		if (!$error) {
			#Assign the Tenant Administration Site
			Set-SPSiteAdministration –Identity $url –AdministrationSiteType TenantAdministration
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