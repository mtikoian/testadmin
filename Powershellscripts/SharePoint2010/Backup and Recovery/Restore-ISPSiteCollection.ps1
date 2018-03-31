<#
	.SYNOPSIS
		Restore-ISPSiteCollection
	.DESCRIPTION
		Reads in the XML file created by Backup-ISPWebApplication and restores the backup
	.PARAMETER backupDirectory
		Backup directory
	.PARAMETER backuplog
		Backup log
	.EXAMPLE
		Restore-ISPSiteCollection -backupDirectory C:\Backup\ -backupLog C:\Backup\backuplog.xml
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param 
(
	[string]$backupDirectory = "$(Read-Host 'Backup Directory  [e.g. C:\Backup]')",
	[string]$backupLog = "$(Read-Host 'Backup Log File [e.g. backuplog.xml]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if( $PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}
		
		Write-Verbose "Restoring Web Application backup...."
		
		$backuplog = $backupdirectory + "\" + $backuplog
		
		if (Test-Path $backupdirectory -pathtype container) {
			if (Test-Path $backuplog) {
				$ExportList = Import-Clixml $backuplog
				foreach($item in $ExportList) {
					$dir = Get-Item $backupdirectory
					$keys = $item.Keys
					$value = $item.Values 
					
					Write-Verbose "Restore Site $keys"
					Write-Verbose "Restore File $value"
					
					$file = $dir | Get-ChildItem | where {$_.name -match $value}
					
					if(Test-Path $file.FullName) {
						Restore-SPSite $keys -Path $file.FullName
					} else {
						Write-Verbose "Backup file $value not found. Skipping to next site to restore..."
					} 
				} 
			} else {
				Throw "Backup log: $backuplog not found." 
			}
		} else {
			Throw "Backup directory: $backupdirectory not found." 
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