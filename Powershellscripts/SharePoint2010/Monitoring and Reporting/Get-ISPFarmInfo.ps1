<#
    .SYNOPSIS
        Get-ISPFarmInfo
    .DESCRIPTION
        Gets and lists farm information
    .EXAMPLE
        Get-ISPFarmInfo
    .INPUTS
    .OUTPUTS
        Farm information report
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

		Write-Verbose "Get farm information report..."

		$Farm = Get-SPFarm

		"Farm Info "
		"========================================================================="
		"Farm Name: " + $Farm.DisplayName;
		"Configuration database version : " + $Farm.BuildVersion.ToString();
		""
		"" 
		foreach( $spServer in $Farm.Servers)
		{
			"Server Info: " + $spServer.Displayname + "   Address: " + $spServer.Address
			"========================================================================="
			$Server = Get-SPServer $spServer.Displayname
			foreach( $spService in $Server.ServiceInstances)
			{
				"Service: " + $spService.Typename 
			}
			""
			""
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