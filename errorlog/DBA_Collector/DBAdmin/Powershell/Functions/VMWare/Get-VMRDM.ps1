function Get-VMRDM
{
param
(
	$VM
)
$VM = Get-View -ViewType VirtualMachine -Filter @{"name"="^$VM`$"}

$report = @()

# Report on all the VMs that have a RDM
foreach($dev in $vm.Config.Hardware.Device){
	if(($dev.gettype()).Name -eq "VirtualDisk"){
		if(($dev.Backing.CompatibilityMode -eq "physicalMode") -or
		($dev.Backing.CompatibilityMode -eq "virtualMode")){
			$esx = Get-View $vm.Runtime.Host
			$lun = $esx.Config.StorageDevice.ScsiLun | where {$_.Uuid -eq $dev.Backing.LunUuid}
			$report += New-Object PSObject -Property @{
				VMName = $vm.Name
				VMHost = ($esx).Name
				HDLabel = $dev.DeviceInfo.Label
				HDDeviceName = $dev.Backing.DeviceName
				HDFileName = $dev.Backing.FileName
				HDMode = $dev.Backing.CompatibilityMode
				HDSize = $dev.CapacityInKB
				LunDisplayName = $lun.DisplayName
				HDCtrlType = ($vm.Config.Hardware.Device | where {$_.Key -eq $dev.ControllerKey}).GetType().Name
				HDController = $dev.ControllerKey
				HDUnit = $dev.UnitNumber
				HDDiskMode = $dev.Backing.DiskMode
				LunCanonical = $lun.CanonicalName
				LunDeviceName = $lun.DeviceName
			}
		}
	}
}

$report
}