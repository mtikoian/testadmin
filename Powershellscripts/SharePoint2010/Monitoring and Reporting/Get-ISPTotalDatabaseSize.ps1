<#
	.SYNOPSIS
		Get-ISPTotalDatabaseSize
	.DESCRIPTION
		Gets SharePoint total database size required for backup
	.PARAMETER
	.EXAMPLE
		Get-SPTotalDatabaseSize
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		} 

		Write-Verbose "Getting database sizings..."

		$totalDBSize = 0

		foreach($db in Get-SPDatabase) {
			$totalDBSize += $db.DiskSizeRequired
		}
		
		Write-Output "Total Storage (in MB) = $("{0:n0}" -f ($totalDBSize/1024/1024))"
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