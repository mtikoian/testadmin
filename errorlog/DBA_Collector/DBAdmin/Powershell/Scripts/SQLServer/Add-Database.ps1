<#
.SYNOPSIS
   Adds a new database to the specified SQL Server.
.DESCRIPTION
   This script performs the necessary actions to add a new database to a SQL
   instance based on SEI's SOP.
   
   1. Create the database according to the size specified.
   2. Set the database owner to 'sa'.
   3. Grants the specified group db_owner access.
   
.PARAMETER DatabaseName
   The name of the database to be created.
.PARAMETER ServerName
   The name of the SQL server to add the database to.
.PARAMETER OwnerGroup
  The name of the domain group that will be given ownership rights. Should be specified as
  "<domain>\<group>".
#>

[Cmdletbinding()]
param
(
  [parameter(mandatory=$true,
             ParameterSetName="CLI")]
  [string]$DatabaseName,
  [parameter(mandatory=$true,
             ParameterSetName="CLI")]
  [string]$ServerName,
  [parameter(mandatory=$true,
             ParameterSetName="CLI")]
  [string]$OwnerGroup,
  [parameter(mandatory=$true,
             ParameterSetName="CLI")]
  [int]$DataSizeMB,
  [parameter(mandatory=$true,
             ParameterSetName="CLI")]
  [int]$LogSizeMB
)
begin
{

  Set-StrictMode -Version 2
  
  if (-not (Get-Module SQLServer))
  {
    if (-not (Get-Module SQLServer -ListAvailable))
    {
      Write-Warning "The SQLServer module is not available. Please download and install SQLPSX."
      Write-Warning "http://sqlpsx.codeplex.com"
      return
    }
    Import-Module SQLServer
  }
  
  if (-not (Get-Module SQLPS))
  {
    if (-not (Get-Module SQLPS -ListAvailable))
    {
      Write-Warning "The SQLPS module is not available. Please download and install SQL 2012 Powershell Extensions."
      Write-Warning "http://www.microsoft.com/en-us/download/details.aspx?id=29065"
      return
    }
    Import-Module SQLPS
  }
  
  try
  {
    [Reflection.Assembly]::LoadWithPartialName("Microsoft.SQLServer.SMO")
  }
  catch
  {
    Write-Warning "Could not load required assemblies. Please make sure the SMO Assembly is installed."
    Write-Warning "http://www.microsoft.com/en-us/download/details.aspx?id=29065"
    Write-Warning $_.Exception.Message
    return
  }

  function Add-Database
  {
    [Cmdletbinding()]
    param
    (
      [parameter(mandatory=$true,
                ParameterSetName="CLI")]
      [string]$DatabaseName,
      [parameter(mandatory=$true,
                ParameterSetName="CLI")]
      [string]$ServerName,
      [parameter(mandatory=$true,
                ParameterSetName="CLI")]
      [string]$OwnerGroup,
      [parameter(mandatory=$true,
                 ParameterSetName="CLI")]
      [int]$DataSizeMB,
      [parameter(mandatory=$true,
                ParameterSetName="CLI")]
      [int]$LogSizeMB
    )
    
    $smoServer = New-Object microsoft.SqlServer.Management.Smo.Server $ServerName
    
    try
    {
      # Check if the database already exists
      if ($smoServer.Databases.Contains($DatabaseName))
      {
        Write-Verbose "Database $DatabaseName already exists."
      }
      else
      {
        Write-Verbose "Database $DatabaseName does not exist. It will now be created."
        $DataSize = $DataSizeMB*1024
        $LogSize = $LogSizeMB*1024
        Add-SqlDatabase -dbname $DatabaseName -dataSize $DataSize -logSize $LogSize -sqlserver $ServerName
      }
      
      # Set Database Owner to 'sa'
      $db = $smoServer.Databases[$DatabaseName]
      $db.SetOwner("sa")
      $db.Alter()
      
      # Add group to 'db_owner' role
      if ($db.Users.Contains($OwnerGroup))
      {
        Write-Verbose "User $OwnerGroup already exists in the master database."
      }
      else
      {
        $User = New-Object Microsoft.SqlServer.Management.Smo.User $db,$OwnerGroup
        $User.Create()
        Write-Verbose "User $OwnerGroup created in master database."
      }
      
      # Add the login to the "urole_SSMS_users" role in the master database
      Write-Verbose "Adding user $OwnerGroup to 'db_owner' role."
      $role = $db.Roles["db_owner"]
      $role.AddMember($OwnerGroup)
    }
    catch
    {
      Write-Warning "Error occurred during processing."
      Write-Warning $_.Exception.Message
    }
  }
}
process
{
  Add-Database @PSBoundParameters
}