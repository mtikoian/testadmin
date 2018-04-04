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

function Execute-QueuedJob
{

  [Cmdletbinding()]
  param
  (
    [parameter(mandatory=$true)]
    [System.Collections.Queue]$Queue,
    [parameter(mandatory=$true)]
    [System.Management.Automation.ScriptBlock]$ScriptBlock,
    [parameter(mandatory=$true)]
    [System.Collections.ArrayList]$JobOutputCollection
  )
  
  
  if ($Queue.Count -gt 0)
  {
  
    $newJob = Start-Job -ScriptBlock $ScriptBlock -ArgumentList $Queue.Dequeue();
    Register-ObjectEvent -InputObject $newJob -EventName StateChanged -Action { 
      Execute-QueuedJob -Queue $Queue -ScriptBlock $ScriptBlock -JobOutputCollection $JobOutputCollection; 
      Unregister-Event $eventsubscriber.SourceIdentifier;
      $JobOutputCollection += Receive-Job $eventsubscriber.SourceIdentifier;
      Remove-Job $eventsubscriber.SourceIdentifier; } | Out-Null;
  
  }

}
function Get-VMPerformance
{

  [Cmdletbinding()]
  param
  (
  
    [parameter(mandatory=$true)]
    [string]$ExportPath,
    [parameter(mandatory=$true)]
    [int]$MaxJobs,
	[parameter(mandatory=$true,ValueFromPipeline=$true)]
	[VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl[]]$VM
  
  )
  
  # Define the variable to hold job results
  $jobResults = [System.Collections.ArrayList]::Synchronized((New-Object System.collections.ArrayList))
  
  # Create the queue and enqueue all VMs
  $vmQueue = [System.Collections.Queue]::Synchronized((New-Object System.Collections.Queue));
  
  $VMs | ForEach-Object {$vmQueue.Enqueue($_)};
  
  # Create the script block to actually do the work
  $sctiptBlock = {
    param ($VM)
    Get-Stat -IntervalMins 5 -Disk -Cpu -Memory -Entity $VM;
  };
  
  # Start the requisite number of jobs
  for ($counter = 0; $counter -le $MaxJobs; $counter ++)
  {
  
    Execute-JobFromQueue -ScriptBlock $scriptBlock -
  
  }
  
  # Pause while jobs are queued or executing
  while (($vmQueue.Count -gt 0) -or ((Get-Job -State Running).Count -gt 0))
  {
  
   Start-Sleep -Seconds 5; 
  
  }
  
  # Process the results
  

}
