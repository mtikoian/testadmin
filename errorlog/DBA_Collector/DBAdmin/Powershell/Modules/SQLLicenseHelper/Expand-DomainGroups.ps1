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

filter Expand-DomainGroup
{
	[Cmdletbinding()]
	param
	(
		[parameter(ValueFromPipeline=$true)]
		$InputObject
	)
	begin
	{
		function Expand-DomainGroupInternal
		{
			[Cmdletbinding()]
			param
			(
				[parameter(mandatory=$true,ValueFromPipeline=$true)]
				[System.DirectoryServices.DirectoryEntry]$ADObject
			)
			process
			{
				if ($ADObject.Properties["objectClass"] -contains "group")
				{
					foreach ($member in $ADObject.Properties["member"])
					{
						$memberObj = New-Object system.DirectoryServices.DirectoryEntry "LDAP://$member"
						
						if ($memberObj.Properties["objectClass"] -contains "group")
						{
							Expand-DomainGroupInternal -ADObject $memberObj
						}
						else
						{
							$memberObj |
								Select-Object @{n="Name";e={$_.displayName[0]}},
											  @{n="LogonName";e={$_.properties.samaccountname[0]}},
											  @{n="LastLogon";e={[DateTime]::FromFileTime($_.ConvertLargeIntegerToInt64($_.lastLogon[0]))}}
						}
					}
				}

			}
		}
	}
	process
	{
		try
		{
		$domain = $InputObject.Name.Substring(0,$InputObject.Name.IndexOf("\"))
		$de = New-Object System.DirectoryServices.DirectoryEntry "LDAP://$domain"
		$ds = New-Object System.DirectoryServices.DirectorySearcher $de
	
		Write-Verbose "Checking $($InputObject.Name)"
		$ds.Filter = "(samAccountName=$($InputObject.Name.Substring($InputObject.Name.IndexOf(`"\`")+1)))"
		$adObj = $ds.FindOne().GetDirectoryEntry()
		
		Expand-DomainGroupInternal -ADObject $adObj | 
			Add-Member -MemberType NoteProperty -Name ServerName -Value $InputObject.ServerName -PassThru |
			Add-Member -MemberType NoteProperty -Name GroupName -Value $InputObject.Name -PassThru
		}
		catch
		{
			Write-Warning "Error processing $($InputObject.Name)"
			Write-Warning $_.Exception.Message
		}
	}
}