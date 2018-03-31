<#
	.SYNOPSIS
		Set-ISPLogLevelFromXML
	.DESCRIPTION
		Sets SPLogLevel from the XML file created using Save-ISPLogLevelToXML
	.PARAMETER xmlfile
		Saved settings file
	.EXAMPLE
		Set-SPLogLevelFromXML -xmlfile c:\SharePointLogSetting.xml
	.INPUTS
	.OUTPUTS
	.NOTES
	.LINK
#> 

param (
	[string]$xmlfile = "$(Read-Host 'Saved File Name [e.g. c:\LogSetting.xml]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Set SPLogLevel from saved XML settings ..."

		if (Test-Path $xmlfile) {
			$cfg = [xml] (get-content $xmlfile)

			$nodelist = $cfg.selectnodes("Objects/Object")

			foreach ($item in $nodelist) {
				$property =$item.property 
				$area =($property | ?{$_.Name -match "Area"}).'#text'
				$name =($property | ?{$_.Name -match "Name"}).'#text'
				$traceSeverity =($property | ?{$_.Name -match "TraceSeverity"}).'#text'
				$eventSeverity =($property | ?{$_.Name -match "EventSeverity"}).'#text'
				$identity = $area + ":" + $name
				Set-SPLogLevel -Identity $identity -TraceSeverity $traceSeverity -EventSeverity $eventSeverity
			} 
		} else {
			Throw "Setup file not found"
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