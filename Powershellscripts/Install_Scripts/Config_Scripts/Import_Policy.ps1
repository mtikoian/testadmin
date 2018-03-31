<#
.SYNOPSIS 
Imports an xml management policy to the specified SQL instance.

.DESCRIPTION

.PARAMETER $SQLServer
SQL Server Name.

.PARAMETER $PolicyPath
Path to policy xml file.

.OUTPUTS
Text.

.EXAMPLE
Include example text here:
 .\Import_Policy.ps1 -SqlServer "SQL01" -PolicyPath "C:\Temp\policy.xml"

#>

Param ([string]$SQLServer = "(Get-Item .)",
		[string]$PolicyPath = ""
)

# import sql cmdlets
Import-Module SQLPS;

Set-Location SQLServer:\SQL\$env:COMPUTERNAME\Default

$Connectionstring = "server=$SQLServer;Trusted_Connection=true";
$Conn = New-Object Microsoft.SQlServer.Management.Sdk.Sfc.SqlStoreConnection($Connectionstring);
$PolicyStore = New-Object Microsoft.SqlServer.Management.DMF.PolicyStore($Conn);
$PolicyXmlPath = $PolicyPath;
$xmlReader = [System.Xml.XmlReader]::Create($PolicyXmlPath);
$PolicyStore.ImportPolicy($xmlReader, [Microsoft.SqlServer.Management.Dmf.ImportPolicyEnabledState]::Unchanged, $true, $true);
