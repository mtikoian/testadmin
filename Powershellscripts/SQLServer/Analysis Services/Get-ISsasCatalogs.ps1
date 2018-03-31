<#
	.SYNOPSIS
		Get-ISsasCatalogs
	.DESCRIPTION
		Retrieve SQL Server SSAS Catalogs
	.PARAMETER serverInstance
		SQL Server 2012 Instance
	.EXAMPLE
		.\Get-ISsasCatalogs -serverInstance Server01\sql2012
	.INPUTS
	.OUTPUTS
		Analysis Services Catalogs created in Database Engine
	.NOTES
	.LINK
#>
param (
	[string]$serverInstance = "$(Read-Host 'Server Instance [e.g. server01\sql2012]')"
)

begin {
	#Requires 'sqlps' Module
	if (-not(Get-Module -name sqlps)) { 
		if(Get-Module -ListAvailable | Where-Object { $_.name -eq "sqlps" }) { 
			Import-Module -Name sqlps -DisableNameChecking
		} else { 
			Throw "SQL Server 2012 'sqlps' module is not available" 
		} 
	} 
}
process {
	try {
		Write-Verbose "Gets SSIS catalogs..."

		$instance = $serverInstance.split("\")[1]
		if ($instance -eq "") { 
			$ssisCatalogs = Get-ChildItem SQLSERVER:\SSIS\$serverInstance\DEFAULT\Catalogs 
		} else { 
			$ssisCatalogs = Get-ChildItem SQLSERVER:\SSIS\$serverInstance\Catalogs 
		}
		
		Write-Output $ssisCatalogs
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