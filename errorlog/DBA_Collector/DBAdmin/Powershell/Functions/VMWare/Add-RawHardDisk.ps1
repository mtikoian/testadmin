function Add-RawHardDisk{
	param($vm, $FileName,$controller, $unitnumber, $capacity)

	$vmMo = $vm | Get-View
	$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
	$chg = New-Object VMware.Vim.VirtualDeviceConfigSpec
	$chg.operation = "add"
	$dev = New-Object VMware.Vim.VirtualDisk
	$dev.CapacityInKB = $capacity
	$dev.Key = - 100
	$back = New-Object VMware.Vim.VirtualDiskRawDiskMappingVer1BackingInfo
	$back.fileName = $Filename
	$back.compatibilityMode = ""
	$back.diskMode = "independent_persistent"
	$dev.Backing = $back
	$dev.ControllerKey = $controller
	$dev.UnitNumber = $unitnumber
	$chg.device = $dev
	$spec.deviceChange += $chg
	$taskMoRef = $vmMo.ReconfigVM_Task($spec)
	$task = Get-View $taskMoRef
	while("running","queued" -contains $task.Info.State){
		$task.UpdateViewData("Info.State")
	}
	$task.UpdateViewData("Info.Result")
}
