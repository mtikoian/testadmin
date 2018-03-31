<#
.SYNOPSIS
   Initialize-SP2010
.DESCRIPTION
   Initialization script to set up Console session
.EXAMPLE
   Initialize-SP2010
#>

If ($Host.Name -ne "ServerRemoteHost") {
	$Host.Runspace.ThreadOptions = "ReuseThread"
}

if ( (Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) {
	Add-PsSnapin Microsoft.SharePoint.PowerShell
}
Set-location $home