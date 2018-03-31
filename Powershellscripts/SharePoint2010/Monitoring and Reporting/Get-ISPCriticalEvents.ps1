<#
	.SYNOPSIS
		Get-ISPCriticalEvents
	.DESCRIPTION
		Get critical events for a given date range
	.PARAMETER start
		Start date
	.PARAMETER end
		End date
	.EXAMPLE
		Get-ISPCriticalEvents -start 2/1/2011 -end 2/2/2011
	.INPUTS
	.OUTPUTS
		Critical events
	.NOTES
		This can take some time to return depending on the size of the Event log
	.LINK
#> 

param(
	[DateTime]$start = "$(Read-Host 'Start Time [i.e. 2/1/2011]')",
	[DateTime]$end = "$(Read-Host 'End Time [i.e. 2/28/2011]')"
)

begin {
}
process {
	try {
		$PSSnapinSP = Get-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
		if ($PSSnapinSP -eq $Null) {
			Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction Stop
		}

		Write-Verbose "Retrieving critical events ..."

		If ($start -gt $end) {
			Throw "Start date must be less than end date."
		}

		$criticalEvents = Get-SPLogEvent -MinimumLevel Critical | where {($_.Timestamp -ge $start) -and ($_.Timestamp -le $end)}

		Write-Output $criticalEvents
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