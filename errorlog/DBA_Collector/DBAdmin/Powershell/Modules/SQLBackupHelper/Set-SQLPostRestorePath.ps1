<#
.SYNOPSIS
    Sets the location where the post restore scripts reside.
.PARAMETER Path
    The path where the post restore scripts reside.
#>
function Set-SQLPostRestorePath 
{
  [Cmdletbinding()]
  param
  (
    [parameter(mandatory=$true)]
    [string]$Path
  )
  begin
  {
    if (Get-Variable -Name "SQLPostRestorePath" -Scope Global -ErrorAction SilentlyContinue)
    {
      Write-Verbose "Variable does not exist. Creating it."
      Set-Variable -Name "SQLPostRestorePath" -Scope Global -Value $Path
    }
    else
    {
      Write-Verbose "Variable exists, setting its value."
      New-Variable -Name "SQLPostRestorePath" -Scope Global -Value $Path
    }
  }
}

