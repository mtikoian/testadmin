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

function Get-LastSQLBackup
{
  [Cmdletbinding()]
  param
  (
    [parameter(mandatory=$true)]
    [string]$SQLServer
  )
  [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SQLServer.Management.SMO") | Out-Null
  
  $SQLServerObj = New-Object microsoft.SqlServer.Management.Smo.Server $SQLServer
  
  $SQLServerObj.Databases |
    Select-Object Name, RecoveryModel, LastBackupDate, LastDifferentialBackupDate, LastLogBackupDate
  
}