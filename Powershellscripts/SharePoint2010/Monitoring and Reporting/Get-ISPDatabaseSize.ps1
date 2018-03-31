<#
	.SYNOPSIS
		Get-ISPDatabaseSize
	.DESCRIPTION
		Gets SharePoint database sizes
	.PARAMETER
	.EXAMPLE
		Get-SPDatabaseSize
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

		$sizings = @()

		foreach($db in Get-SPDatabase) {
			$dbSizing = New-Object -TypeName PSObject -Property @{
				DBName = $db.DisplayName
				SizeMB = $db.DiskSizeRequired
			}
			$sizings += $dbSizing
		}
		
		Write-Output $sizings
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