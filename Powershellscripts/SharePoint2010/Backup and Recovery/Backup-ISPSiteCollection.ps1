<#
	.SYNOPSIS
		Backup-ISPSiteCollection
	.DESCRIPTION
		This example backs up a Site Collection to a selected
		directory and saves the backup activity to an XML file which can be used for the restore operation.
	.PARAMETER url
		Site URL
	.PARAMETER location
		Backup directory
	.EXAMPLE
		Backup-ISPSiteCollection -url http://server_name -location c:\-Backup
	.INPUTS
	.OUTPUTS
		Backup file for each Site in the Site Collection
		XML log of activity used to perform a restore
	.NOTES
	.LINK
#> 

param 
(
	[string]$url = "$(Read-Host 'Site Collection Url [e.g. http://server_name]')", 
	[string]$location = "$(Read-Host 'Backup Location  [e.g. C:\Backup]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}
		
		Write-Verbose "Backing up Site: $url ..."

		if(Test-Path $location -PathType container) { 
			$backuplist = @{}
			$dateString = get-date -format "yyyy_MM_dd_hh_mm_ss"
			$SPSite = Get-SPSite $url -limit all

			foreach($site in $SPSite) {
				$filename = $dateString + "-" + $site.Url.replace("http://","").replace("-","_").replace("/","_") + ".bak"
				$pattern = "[{0}]" -f ([Regex]::Escape([String] [System.IO.Path]::GetInvalidFileNameChars())) 
				$filename = [Regex]::Replace($filename, $pattern, '')
				$filepath = New-Item -type file -path $location -name $filename

				Backup-SPSite $site.Url -path $filepath -force

				$backuplist[$site.Url] = $filename
			}

			$XMLfilepath = New-Item -type file -path $location -name "Backuplog$dateString.xml"

			Write-Verbose "XML log file - $XMLfilepath created"

			$backuplist | Export-Clixml $XMLfilepath -Force 
		} else {
			Throw "Backup location: $location does not exist." 
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