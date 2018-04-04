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
      try
      {
        $AMO.Connect("Data Source=$Server")
        
        #Server level users
        #Note: we filter out anything not containing the backslash
        #to exclude SIDs which come through on deleted users
        $userList += $AMO.Roles | 
                      Select-Object -ExpandProperty Members | 
                      Where-Object {$_.Name.IndexOf("\") -gt 0} |
                      Where-Object {$IncludeDomains -contains $_.Name.Substring(0,$_.Name.IndexOf("\")) -or $IncludeDomains -eq $null} |
                      Select-Object Name, @{n="ServerName";e={$Server}}
        
        #Database level users
        #Note: we filter out anything not containing the backslash
        #to exclude SIDs which come through on deleted users
        foreach ($DB in $AMO.Databases)
        {
          $userList += $DB.Roles | 
                          Select-Object -ExpandProperty Members | 
                          Where-Object {$_.Name.IndexOf("\") -gt 0} |
                          Where-Object {$IncludeDomains -contains $_.Name.Substring(0,$_.Name.IndexOf("\")) -or $IncludeDomains -eq $null} |
                          Select-Object Name, @{n="ServerName";e={$Server}}
        }
      }
      catch
      {
        Write-Warning "Error processing server $Server"
        Write-Warning $_.Exception.Message
      }
      finally
      {
        if ($AMO.Connected)
        {
          $AMO.Disconnect()
        }
      }
    }
  }
  end
  {
    Write-Output $userList
  }
}