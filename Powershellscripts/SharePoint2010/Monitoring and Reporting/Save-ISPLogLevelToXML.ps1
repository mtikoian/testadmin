<#
	.SYNOPSIS
		Save-ISPLogLevelToXML
	.DESCRIPTION
		Saves the SPLogLevel information to an XML file so it can be used later by Set-ISPLogLevelFromXML
	.PARAMETER identity
		Identity Area:Name 
		Wildcards are valid
	.EXAMPLE
		Save-ISPLogLevelToXML -identity "SharePoint*:*" -xmlfile c:\SharePointLogSetting.xml
	.INPUTS
	.OUTPUTS
		XML file with SPLogLevel settings
	.NOTES
	.LINK
#> 

param (
	[string]$identity = "$(Read-Host 'Identity Area:Name [e.g. Web Content*:*]')", 
	[string]$xmlfile = "$(Read-Host 'Save File Name [e.g. C:\LogSetting.xml]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Saving SharePoint LogLevel Properties for specified identity ..."

		(Get-SPLogLevel -identity $identity | Select Area,Name,TraceSeverity,EventSeverity | ConvertTo-XML -NoTypeInformation ).Save($xmlfile)
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