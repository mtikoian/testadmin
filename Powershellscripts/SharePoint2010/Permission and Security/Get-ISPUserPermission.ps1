<#
	.SYNOPSIS
		Get-ISPUserPermission
	.DESCRIPTION
		Get site users and permissions
	.PARAMETER url
		Site Url
	.EXAMPLE
		Get-ISPUserPermission -url http://server_name
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param (
	[string]$url = "$(Read-Host 'url [e.g. http://server_name]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Getting Site User Permissions ..."

		$userPermissions = Get-SPUser -Web $url | 
			select UserLogin, 
			@{name="User roles"; expression={$_.Roles}}, 
			@{name="Groups roles";expression={$_.Groups | % {$_.Roles}}},
			Groups

		Write-Output $userPermissions
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