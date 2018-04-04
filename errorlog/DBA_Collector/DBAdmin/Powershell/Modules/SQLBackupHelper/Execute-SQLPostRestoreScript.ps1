<#
.SYNOPSIS
   Executes post restore scripts for a specific database and server.
.PARAMETER ServerName
  The name of the server against which to run the post restore scripts.
.PARAMETER DatabaseName
  The name of the database against which to execute the scripts.
#>
function Execute-SQLPostRestoreScript
{
  [Cmdletbinding()]
  param
  (
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$ServerName,
    [parameter(mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]$DatabaseName
  )
  begin
  {
    Set-StrictMode -Version 2
    
    $oldpath = Get-Location
    
    # Check if SQLPS module is loaded
    if (-not (Get-Module SQLPS))
    {
      if (-not (Get-Module SQLPS -ListAvailable))
      {
        Write-Warning "The SQLPS module is not available. Please download and install SQL 2012 Powershell Extensions."
        Write-Warning "http://www.microsoft.com/en-us/download/details.aspx?id=29065"
        break
      }
      Import-Module SQLPS
    }
    
    # Check if the post restore script path is configured and exists
    if ($global:SQLPostRestorePath)
    {
      if (-not (Test-Path $global:SQLPostRestorePath))
      {
        Write-Warning "SQL Post Restore path configured ('$global:SQLPostRestorePath') does not exist. Exiting."
        break
      }
    }
    else
    {
      Write-Warning "SQL Post Restore path is not set. Please configure using the Set-SQLPostRestorePath function. Exiting."
      break
    }
  }
  process
  {
    try
    {
      # Setup variable array
      $sqlcmdVars = "DatabaseName=$DatabaseName","SQLScriptPath=$global:SQLPostRestorePath\Common"
      
      # Execute all common scripts
      if (Test-Path "$global:SQLPostRestorePath\Common")
      {
        Set-Location "$global:SQLPostRestorePath\Common"
        foreach ($Script in (Get-ChildItem "$global:SQLPostRestorePath\Common" -Filter "*.sql"))
        {
          Write-Verbose "Executing $($Script.FullName)"
          Invoke-Sqlcmd -ErrorAction Stop -ServerInstance $ServerName -Database $DatabaseName -Variable $sqlcmdVars -AbortOnError -InputFile $Script.FullName
        }
      }
      
      Set-Location $global:SQLPostRestorePath
      # Look first for a script named Servername\DatabaseName.sql
      if (Test-Path "$global:SQLPostRestorePath\$ServerName\$DatabaseName.sql")
      {
        $Script = Get-Item "$global:SQLPostRestorePath\$ServerName\$DatabaseName.sql"
        Set-Location "$global:SQLPostRestorePath\$ServerName"
      }
      # Else look for one named DatabaseName.sql
      elseif (Test-Path "$global:SQLPostRestorePath\$DatabaseName.sql")
      {
        $Script = Get-Item "$global:SQLPostRestorePath\$DatabaseName.sql"
        Set-Location $global:SQLPostRestorePath
      }
      # No script found, output a warning
      else
      {
        Write-Warning "No post restore script found for database $DatabaseName, server $ServerName"
        return
      }
      Write-Verbose "Executing $($Script.FullName)"
      $sqlcmdVars[1] = "SQLScriptPath=$(Split-Path $Script.FullName)"
      Invoke-Sqlcmd -ErrorAction Stop -ServerInstance $ServerName -Database $DatabaseName -Variable $sqlcmdVars -AbortOnError -InputFile $Script.FullName
    }
    catch
    {
      Write-Warning "Error processing post restore for server $ServerName, database $DatabaseName."
      Write-Warning $_.Exception.Message
    }
    finally
    {
      Set-Location $oldpath
    }
  }
}
