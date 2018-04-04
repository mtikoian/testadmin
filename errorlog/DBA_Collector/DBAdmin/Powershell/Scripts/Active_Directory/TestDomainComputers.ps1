[Cmdletbinding()]
param
(
	[parameter(mandatory=$true)][string]$SearchRoot
)
Begin
{

$de = New-Object System.DirectoryServices.DirectoryEntry "LDAP://$SearchRoot"
$ds = New-Object system.DirectoryServices.DirectorySearcher $de
$ds.filter = "objectClass=Computer"

$Computers = $ds.FindAll()

$report = @();

$totalCount = $Computers.Count;
$currentCount = 0;
$percentComplete = 0;

$runspacePool = [Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1,10);
$runspacePool.Open()

$scriptBlock = 
{
  param ($computer)
  
  $pingResult = Test-Connection -ComputerName $computer -Quiet -Count 1
  
  $returnObject = "" | Select-Object @{n="Computer";e={$computer}},
                                     @{n="Responding";e={$pingResult}}
  $returnObject
  
}

$runspaces = @()

}
process
{
  foreach ($computer in $computers)
  {
    Write-Verbose "Queuing computer $computer"
    
    $computerName = ($computer.GetDirectoryEntry()).Name
    $runspaceRow = "" | Select-Object @{n="Computer";e={$computerName}},
                                      @{n="Runspace";e={}},
                                      @{n="InvokeHandle";e={}}
                                      
    $powershell = [Management.Automation.PowerShell]::Create()
    $powershell.RunspacePool = $runspacePool
    $powershell.AddScript($scriptBlock).AddArgument($computerName)
    $runspaceRow.Runspace = $powershell
    $runspaceRow.InvokeHandle = $powershell.BeginInvoke()
    
    $runspaces += $runspaceRow
    
  }
  
  $totalCount = $runspaces.Count
  
  while (($runspaces | Where-Object {$_.InvokeHandle.IsCompleted -eq $false}).Count -gt 0)
  {
    $completedCount = ($runspaces | Where-Object {$_.InvokeHandle.IsCompleted -eq $true}).Count
    Write-Verbose "Completed $completedCount of $totalCount"
  }
  
  foreach ($runspaceRow in $runspaces)
  {
    $report += $runspaceRow.Runspace.EndInvoke($runspaceRow.InvokeHandle)
    $runspaceRow.Runspace.dispose()
  }
}
end
{
  $report | ConvertTo-Html | Out-File -filepath "$env:temp\pingtest.html";
  & "$env:temp\pingtest.html";
}