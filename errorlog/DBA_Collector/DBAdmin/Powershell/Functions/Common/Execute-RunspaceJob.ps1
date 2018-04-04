<#
.SYNOPSIS
   Executes a set of parameterized script blocks asynchronously using runspaces, and returns the resulting data.
.PARAMETER ScriptBlock
   The script block to execute. Should contain one or more parameters.
.PARAMETER ArgumentList
  A hashtable containing data about the entity to be processed. The key should be a unique string to 
  identify the entity to be processed, such as a server name. The value should be another hashtable
  of arguments to be passed into the script block.
.PARAMETER ThrottleLimit
  The maximum number of concurrent threads to use. Defaults to 10.
.EXAMPLE
   
#>

function Execute-RunspaceJob
{
	[Cmdletbinding()]
	param
	(
		[parameter(mandatory=$true)]
		[System.Management.Automation.ScriptBlock]$ScriptBlock,
		[parameter(mandatory=$true,ValueFromPipeline=$true)]
		[System.Collections.Hashtable]$ArgumentList,
		[parameter(mandatory=$false)]
		[int]$ThrottleLimit = 10
	)

	begin
  {
    #Instantiate runspace pool
    $runspacePool = [runspacefactory]::CreateRunspacePool(1,$ThrottleLimit)
    $runspacePool.Open()
    
    #Array to hold runspace data
    $runspaces = @()
    
    #Array to hold return data
    $data = @()
  }
  process
  {
    foreach ($Argument in $ArgumentList.Keys)
    {
      $rowIdentifier = $Argument
      Write-Verbose "Queuing item $rowIdentifier for processing."
      
      $runspaceRow = "" | Select-Object @{n="Key";e={$rowIdentifier}},
                                        @{n="Runspace";e={}},
                                        @{n="InvokeHandle";e={}}
      $powershell = [powershell]::Create()
      $powershell.RunspacePool = $runspacePool
      $powershell.AddScript($scriptBlock).AddParameters($ArgumentList[$rowIdentifier]) | Out-Null
      
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
      Write-Verbose "Retrieving data for item $($runspaceRow.Key)."
      if ($runspaceRow.Runspace.InvocationStateInfo.State -eq "Failed")
      {
        $errorMessage = $runspaceRow.Runspace.InvocationStateInfo.Reason.Message
        Write-Warning "Processing of item $($runspaceRow.Key) failed with error: $errorMessage"
      }
      else
      {
        $data += $runspaceRow.Runspace.EndInvoke($runspaceRow.InvokeHandle)
      }
      $runspaceRow.Runspace.dispose()
    }
    
    $runspacePool.Close()
    
    Write-Output $data
  }
}