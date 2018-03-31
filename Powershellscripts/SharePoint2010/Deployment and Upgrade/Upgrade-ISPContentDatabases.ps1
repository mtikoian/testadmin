<#
	.SYNOPSIS
		Upgrade-ISPContentDatabases
	.DESCRIPTION
		Check the upgrade status of all content databases and update if needed
	.PARAMETER
	.EXAMPLE
		Upgrade-ISPContentDatabases
	.INPUTS
	.OUTPUTS
		Content Databases that were upgraded
	.NOTES
	.LINK
#> 

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if( $PSSnapinSP -eq $Null)
		{
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Check status for content databases that require upgrading..."

		$upgraded = @()

		$databases = Get-SPDatabase
		foreach($db in $Databases)
		{
			if ($db.Type -eq "Content Database") { 
				if ($db.NeedsUpgrade -eq $true ) { 
					$contentDB = New-Object -TypeName PSObject -Property @{
						DisplayName = $db.DisplayName
						ID = $db.id
					}
			
					Write-Verbose "Upgrading content database: " + $db.DisplayName

					Upgrade-SPContentDatabase -Identity $db.id 
					$upgraded += $contentDB
				}
			}
		}
		
		Write-Output $upgraded
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