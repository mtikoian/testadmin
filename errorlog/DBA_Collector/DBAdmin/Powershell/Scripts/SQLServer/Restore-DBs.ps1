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

[Cmdletbinding()]
param
(
	[parameter(mandatory=$true)]
	[string]$Path,
	[parameter(mandatory=$true)]
	[string]$ServerName,
	[parameter(mandatory=$true)]
	[string]$NotificationEMail,
	[parameter(mandatory=$true)]
	[string]$LogFilePath
)

#region Common functions
function Check-ModuleAvailable
{
  <#
    .SYNOPSIS
      Checks if the specified module is available, and (if the "-Load" switch is specified)
      loads it if it is not already loaded.
    .PARAMETER ModuleName
      The name of the module to load.
    .PARAMETER Load
      If specified will load the module if it is not already loaded.
    .NOTES
      Author: Josh Feierman
      Date: 7/2/2012
      Version: 1.0
  #>
  [Cmdletbinding()]
  param
  (
    [parameter(mandatory=$true)]
    $ModuleName,
    [parameter(mandatory=$false)]
    [switch]$Load
  )
  if (-not (Get-Module $ModuleName))
  {
    if (-not (Get-Module -Name $ModuleName -ListAvailable))
    {
      throw "Module $ModuleName is not available."
    }
    elseif ($Load)
    {
      try
      {
        Import-Module $ModuleName
      }
      catch
      {
        $errMsg = "Could not load module '$ModuleName'. Error is: $($_.Exception.Message)"
        throw $errMsg
      }
    }
  }
}

#endregion

#Module checks
try
{
  Check-Module -ModuleName "SQLServer" -Load
  Check-Module -ModuleName "SQLPS" -Load
  Check-Module -ModuleName "SQLBackupHelper" -Load
}
catch
{
  Write-Warning "Could not load required modules."
  Write-Warning $_.Exception.Message
  Write-Warning "Script will now exit"
  break
}