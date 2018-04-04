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

function Get-SQLServerUsers
{
	[Cmdletbinding()]
	param
	(
		[Parameter(mandatory=$false)]
		[string[]]$IncludeDomains,
		[Parameter(mandatory=$true,ValueFromPipeline=$true)]
		[string[]]$ServerName
	)
	
	begin
	{
		Set-StrictMode -Version 2
		
		[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SQLServer.Management.SMO") | Out-Null
		
		$userList = @()
	}
	process
	{
		foreach ($Server in $ServerName)
		{
			$smoServer = New-Object Microsoft.SqlServer.Management.Smo.Server $Server
			
			$userList += $smoServer.Logins | 
				Where-Object {"WindowsUser","WindowsGroup" -contains $_.LoginType } |
				Where-Object {$IncludeDomains -contains $_.Name.Substring(0,$_.Name.IndexOf("\")) -or 
							  $IncludeDomains -eq $null} |
				Select-Object Name,LoginType,@{n="ServerName";e={$Server}}
			
		}
	}
	end
	{
		$userList
	}
}