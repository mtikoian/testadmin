<#
.SYNOPSIS
   Gets a list of paths for devices on the specified host
.PARAMETER VMHost
   The host to retrieve paths for. Can be input via the pipeline.
.PARAMETER Summarize
   If used, will group the results by CanonicalName and report a count of active paths,
   as well as the current multipath strategy.
.EXAMPLE
   <An example of using the script>
#>
function Get-VMHostStoragePaths
{
	[Cmdletbinding()]
	param
	(
		[parameter(mandatory=$true,ValueFromPipeline=$true)]
		[VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]$VMHost,
    [parameter(mandatory=$false,ValueFromPipeline=$true)]
    [string]$CanonicalName,
		[parameter(mandatory=$false)]
		[switch]$Summarize
	)
	begin
	{
		Set-StrictMode -Version 2
		$paths = @()
	}
	process
	{
		$storageSystemView = Get-View $VMHost.ExtensionData.ConfigManager.StorageSystem
		
		foreach ($LUN in $storageSystemView.StorageDeviceInfo.ScsiLun)
		{
			if (($LUN.CanonicalName -eq $CanonicalName) -or ($CanonicalName -eq ""))
      {
        $LUNPaths = $storageSystemView.StorageDeviceInfo.MultipathInfo.Lun | 
                Where-Object {$_.Lun -eq $LUN.Key} |
                Select-Object -ExpandProperty Path 
        foreach ($LUNPath in $LUNPaths)
        {
          $SCSIPath = $storageSystemView.StorageDeviceInfo.PlugStoreTopology.Path |
                  Where-Object {$_.Name -eq $LUNPath.Name}
          $Adapter = $storageSystemView.StorageDeviceInfo.HostBusAdapter |
                  Where-Object {$_.Key -eq $LUNPath.Adapter}
          $path = New-Object PSObject -Property @{
                LUNKey = $LUN.Key
                CanonicalName = $LUN.CanonicalName
                Adapter = $Adapter.Device
                Target = $SCSIPath.TargetNumber
                Channel = $SCSIPath.ChannelNumber
                LUN = $SCSIPath.LunNumber
                State = $LUNPath.State
                PathState = $LUNPath.PathState
              }
          $paths += $path
        }
      }
		}
	}
	end
	{
		if ($Summarize)
		{
			$summarizedPaths = @()
			
			foreach ($groupedPath in ($paths | Group-Object CanonicalName))
			{
				$activePaths = [array]($groupedPath.Group | Where-Object {$_.State -eq "Active"})
				if ($activePaths) {$activeCount = $activePaths.Count}
				else {$activeCount = 0}
				$standbyPaths = [array]($groupedPath.Group | Where-Object {$_.State -eq "Standby"})
				if ($standbyPaths) {$standbyCount = $standbyPaths.Count}
				else {$standbyCount = 0}
				$multiPathPolicy = ($storageSystemView.StorageDeviceInfo.MultipathInfo.Lun | 
										Where-Object {$_.Lun -eq $groupedPath.Group[0].LUNKey}).Policy.Policy
				$pathSummary = New-Object PSObject -Property @{
									CanonicalName = $groupedPath.Name
									LUNKey = $groupedPath.Group[0].LUNKey
									ActivePaths = $activeCount
									StandbyPaths = $standbyCount
									MultiPathPolicy = $multiPathPolicy
								}
				$summarizedPaths += $pathSummary
			}
			
			Write-Output $summarizedPaths
		}
		else
		{
			Write-Output $paths
		}
	}
	
}