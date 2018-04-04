<#
.SYNOPSIS
   Copies a database from one server to another
.PARAMETER Origin
   The name of the origin server.
.PARAMETER DatabaseName
   The name of the database to copy.
.PARAMETER Destination
   The name of the destination server.
.PARAMETER BackupPath
   The path at which to back the database up to, and restore it from.
.PARAMETER Force
   If specified will forcibly overwrite the database on the destination if it already exists.
#>
[Cmdletbinding()]
param
(
	[parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
	[string]$Origin,
	[parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
	[string]$DatabaseName,
	[parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
	[string]$Destination,
	[parameter(mandatory=$true)]
	[string]$BackupPath,
  [parameter(mandatory=$false)]
  [switch]$Force
)
Begin
{
	Set-StrictMode -Version 2

	function Check-Module
 {
		param($ModuleName)

		if (-not (Get-Module -Name $ModuleName))
		{
			if (Get-Module -ListAvailable -Name $ModuleName)
			{
				Import-Module -Name $ModuleName
			} 
			else
			{
				throw "Module $ModuleName is not available."
			}
		}
	}

	try
	{
		Check-Module -ModuleName "SQLServer"
		Check-Module -ModuleName "adoLib"
		Check-Module -ModuleName "SQLPS"
		Check-Module -ModuleName "SQLBackupHelper"
	}
	catch
	{
		Write-Warning "Required module could not be loaded."
		Write-Warning $_.Exception.Message
		Write-Warning "Script will now exit."
		break
	}
}
process
{
	# Test if the given path exists
	if (-not (Test-Path $BackupPath))
	{
    Write-Warning "Path '$BackupPath' does not exist."
    Write-Warning "Iteration skipped."
    return
  }
  
  # Test if the database exists at the source server
  if (-not (Invoke-Sqlcmd -ServerInstance $Origin -Database "master" -Query "SELECT 1 FROM sys.databases WHERE name = '$DatabaseName'"))
  {
    Write-Warning "Database $DatabaseName does not exist at origin server $Origin."
    Write-Warning "Iteration skipped."
    return
  }
  
  # Test if the database exists at the destination server
  if ((Invoke-Sqlcmd -ServerInstance $Destination -Database "master" -Query "SELECT 1 FROM sys.databases WHERE name = '$DatabaseName'"))
  {
    if (-not $Force)
    {
      Write-Warning "Database $DatabaseName exists at destination server $Destination and the '-Force' switch was not specified."
      Write-Warning "Iteration skipped."
      return
    }
  }
  
  # Backup the database to the shared folder
  $filename = "$($DatabaseName)_$((Get-Date).ToString(`"yyyyMMddHHmm`"))"
  Backup-SqlDatabase -ServerInstance $Origin -Database $DatabaseName -BackupFile "$BackupPath\$filename" -CopyOnly
  
  # Restore the database to the destination server
  $restoreArgs = @{
    BackupFile = "$BackupPath\$filename"
    ServerName = $Destination
    Replace = $Force
    SingleUser = $Force
    GenerateNewFileName = $true
    DatabaseName = $DatabaseName
  }
  sqlbackuphelper\Restore-SQLDatabase @restoreArgs
  
  # Delete the backup file
  Remove-Item "$BackupPath\$filename"
}

