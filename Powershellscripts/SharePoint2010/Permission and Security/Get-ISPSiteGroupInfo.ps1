<#
	.SYNOPSIS
		Get-ISPSiteGroupInfo
	.DESCRIPTION
		Get group and group member information for a site collection
	.PARAMETER url
		Site Url
	.EXAMPLE
		Get-ISPSiteGroupInfo -url http://server_name
	.INPUTS
	.OUTPUTS
		Site group information report
	.NOTES
	.LINK
#> 

param (
	[string]$url = "$(Read-Host 'Site Url [e.g. http://server_name or leave blank to list all]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Creating Site Group Information Report ..."

		if ($url -eq "" ) {
			$SPSite = Get-SPSite 
		} else {
			$SPSite = Get-SPSite $url
		}
		
		foreach ($iSite in $SPSite) {
			""
			$SPWeb = Get-SPWeb $iSite.URL
			"Site Name: " + $SPWeb.tostring()
			"Site URL: " + $SPWeb.Url 
			"Site Description: " + $SPWeb.Description

			foreach ($iWeb in $SPWeb) {
				$SPGroups = $iWeb.SiteGroups
				foreach ($iGroup in $SPGroups) {
					""
					"  Group Name: " + $iGroup.Name + " Group Owner: " + $iGroup.Owner 
					"  Group Description: " + $iGroup.Description
					"  User Count: " + $iGroup.Users.Count
					foreach( $iUser in $iGroup.Users) {
						""
						"    User Name: " + $iUser.Name 
						"    User LoginName: " + $iUser.LoginName 
						"    User ID: " + $iUser.ID 
						"    User Email: " + $iUser.Email
						"    User Note: " + $iUser.Note
						"    IsApplicationPrincipal: " + $iUser.IsApplicationPrincipal
						"    IsSiteAdmin: " + $iUser.IsSiteAdmin
						"    IsDomainGroup: " + $iUser.IsSiteAdmin
						"    IsSiteAuditor: " + $iUser.IsSiteAuditor
					}
				}
			}
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