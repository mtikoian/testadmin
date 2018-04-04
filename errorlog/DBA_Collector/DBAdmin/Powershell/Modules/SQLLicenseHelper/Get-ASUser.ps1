<#
  .SYNOPSIS
  Gets a list of users from the specified Analysis Services instance.
  
#>
function Get-ASUsers
{
  [Cmdletbinding()]
  param
  (
    [parameter(mandatory=$true,ValueFromPipeline=$true)]
    [string[]]$ServerName,
    [parameter(mandatory=$false)]
    [String[]]$IncludeDomains
  )
  
  begin
  {
    Set-StrictMode -Version 2
    
    try
    {
      [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices") | Out-Null
      $AMO = New-Object Microsoft.AnalysisServices.Server
    }
    catch
    {
      Write-Warning "Error loading AMO assembly."
      Write-Warning $_.Exception.Message
      Write-Warning "Function will now exit."
      Return
    }
    
    $userList = @()
  }
  process
  {
    foreach ($Server in $ServerName)
    {
      
    }
  }
}