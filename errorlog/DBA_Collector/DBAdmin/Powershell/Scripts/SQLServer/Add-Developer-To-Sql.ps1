<#
.SYNOPSIS
   Adds a develpment team or user to a SQL Server instance.
.DESCRIPTION
   This script performs the necessary actions to grant a developer access to
   a SQL Server instance. It creates the login, and grants certain standard rights.
.PARAMETER UserName
   The name (including domain, in the format "<domain>\<user>", of the user
   to add to the server.
.PARAMETER ServerName
   The name of the SQL server to add the user to.
.PARAMETER LoginType
  The type of login that is being created. If the user is a Windows domain group,
  enter "WindowsGroup". If the user is a single user, enter "WindowsUser".
#>

[Cmdletbinding()]
param
(
  [parameter(mandatory=$true,
             ParameterSetName="CLI")]
  [string]$UserName,
  [parameter(mandatory=$true,
             ParameterSetName="CLI")]
  [string]$ServerName,
  [parameter(mandatory=$true,
             ParameterSetName="CLI")]
  [ValidateSet("WindowsUser","WindowsGroup")]
  [string]$LoginType
)
begin
{

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
    [Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlEnum")
  }
  catch
  {
    Write-Warning "Could not load required assemblies. Please make sure the SMO Assembly is installed."
    Write-Warning "http://www.microsoft.com/en-us/download/details.aspx?id=29065"
    Write-Warning $_.Exception.Message
    return
  }

  function Add-DeveloperToSQL
  {
    [Cmdletbinding()]
    param
    (
      [parameter(mandatory=$true,
                ParameterSetName="CLI")]
      [string]$UserName,
      [parameter(mandatory=$true,
                ParameterSetName="CLI")]
      [string]$ServerName,
      [parameter(mandatory=$true,
              ParameterSetName="CLI")]
      [ValidateSet("WindowsUser","WindowsGroup")]
      [string]$LoginType
    )
    
    $smoServer = New-Object microsoft.SqlServer.Management.Smo.Server $ServerName
    
    try
    {
      # Create the login at the server level if it doesn't exist
      if (-not ($smoServer.Logins.Contains($UserName)))
      {
        Write-Verbose "User $UserName does not exist, will create it."
        $newLogin = New-Object Microsoft.SqlServer.Management.Smo.Login $smoServer,$UserName
        $newLogin.LoginType = $LoginType
        $newLogin.Create()
      }
      else
      {
        Write-Verbose "User $UserName already exists."
      }
      
      # Add the user at the database level
      $db = $smoServer.Databases["master"]
      if ($db.Users.Contains($UserName))
      {
        Write-Verbose "User $UserName already exists in the master database."
      }
      else
      {
        $User = New-Object Microsoft.SqlServer.Management.Smo.User $db,$UserName
        $User.Create()
        Write-Verbose "User $UserName created in master database."
      }
      
      # Add the login to the "urole_SSMS_users" role in the master database
      Write-Verbose "Adding user $UserName to 'urole_SSMS_users' role."
      $role = $db.Roles["urole_SSMS_users"]
      $role.AddMember($UserName)
      
      # Grant the "VIEW ANY DATABASE" and "VIEW SERVER STATE" permissions
      Write-Verbose "Granting standard server level rights to $UserName."
      $sqlQuery = "GRANT VIEW ANY DATABASE TO [$UserName]; GRANT VIEW SERVER STATE TO [$UserName]"
      Invoke-Sqlcmd -ServerInstance $ServerName -Query $sqlQuery -ErrorAction Stop
      
      # Add the login to the "msdb" database
      $db = $smoServer.Databases["msdb"]
      if ($db.Users.Contains($UserName))
      {
        Write-Verbose "User $UserName already exists in the msdb database."
      }
      else
      {
        $User = New-Object Microsoft.SqlServer.Management.Smo.User $db,$UserName
        $User.Create()
        Write-Verbose "User $UserName created in msdb database."
      }
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
  Add-DeveloperToSQL @PSBoundParameters
}