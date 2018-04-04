<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>

function Get-RSUsers
{
	[Cmdletbinding()]
	param
	(
		[parameter(mandatory=$true,ValueFromPipeline=$true)]
		[string[]]$ServerName,
		[parameter(mandatory=$false)]
		[string[]]$IncludeDomains
	)
	
	begin
	{
		Set-StrictMode -Version 2
		
		$results = @()
	}
	process
	{
		foreach ($Server in $ServerName)
		{
			$rsWS = New-WebServiceProxy -URI "http://$ServerName/ReportServer/ReportService2005.asmx" -UseDefaultCredential
			$results += $rsWs.GetPolicies("/",[ref]$null) |
								Where-Object {$IncludeDomains -contains $_.GroupUserName.Substring(0,$_.GroupUserName.IndexOf("\")) -or 
											  $IncludeDomains -eq $null} |
								Select-Object @{n="Name";e={$_.GroupUserName}},
											@{n="LoginType";e={"WindowsGroup"}},
											@{n="ServerName";e={$Server}}
		}
	}
	end 
	{
		Write-Output $results
	}
}