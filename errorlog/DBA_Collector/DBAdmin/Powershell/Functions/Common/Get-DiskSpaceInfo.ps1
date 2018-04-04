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

function Get-DiskSpaceInfo
{
  [Cmdletbinding()]
  param
  (
    [parameter(mandatory=$true)]
    [string[]]$Computer
  )
  begin
  {
    $runspacePool = [Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1,10);
    $runspacePool.Open()
    
    $scriptBlock = 
    {
      param($Computer)
      Get-WmiObject -Class Win32_Volume -ComputerName $computer -Filter "DriveType = 3"|
        Select-Object @{n="Computer";e={$computer}},
                      @{n="DiskName";e={$_.Name}},
                      @{n="Label";e={$_.Label}},
                      @{n="CapacityMB";e={($_.Capacity/1MB)}},
                      @{n="FreeSpaceMB";e={($_.FreeSpace/1MB)}},
                      @{n="PercentFree";e={[Math]::Round((($_.FreeSpace / $_.Capacity)*100),2)}}
    }

    $runspaces = @()
    $report = @()
  }
  process
  {
    foreach ($myComputer in $Computer)
    {
      Write-Verbose "Queuing computer $myComputer"
      
      $runspaceRow = "" | Select-Object @{n="Computer";e={$myComputer}},
                                        @{n="Runspace";e={}},
                                        @{n="InvokeHandle";e={}}
      $powershell = [Management.Automation.PowerShell]::Create()
      $powershell.RunspacePool = $runspacePool
      $powershell.AddScript($scriptBlock).AddArgument($myComputer) | Out-Null
      $runspaceRow.Runspace = $powershell
      $runspaceRow.InvokeHandle = $powershell.BeginInvoke()
      
      $runspaces += $runspaceRow
    }
  }
  end
  {
    $totalCount = $runspaces.Count
    
    while (($runspaces | Where-Object {$_.InvokeHandle.IsCompleted -eq $false}).Count -gt 0)
    {
      $completedCount = ($runspaces | Where-Object {$_.InvokeHandle.IsCompleted -eq $true}).Count
      Write-Verbose "Completed $completedCount of $totalCount"
      Start-Sleep -Seconds 1
    }
    
    foreach ($runspaceRow in $runspaces)
    {
      $report += $runspaceRow.Runspace.EndInvoke($runspaceRow.InvokeHandle)
      $runspaceRow.Runspace.dispose()
    }
    
    $runspacePool.Close()
    
    $report
  }
}