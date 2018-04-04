function Add-VMHardDisk
{

param
(
    [string]$HardDiskPath,
    [string]$DataCenterName,
    [int]$CapacityMB
)

$serviceInstance = Get-View ServiceInstance;
$vDiskmanager = get-view $serviceInstance.Content.VirtualDiskManager;
$vDataCenter = Get-View -ViewType DataCenter -Filter @{"Name"=$DataCenterName};
$vDiskSpec = New-Object VMWare.Vim.FileBackedVirtualDiskSpec;
$vDiskSpec.AdapterType = 'lsiLogic';
$vDiskSpec.CapacityKb = $CapacityMB * 1024;
$vDiskSpec.DiskType = 'eagerZeroedThick';
$vTaskRef = $vDiskmanager.CreateVirtualDisk_Task($HardDiskPath,$vDataCenter.MoRef,$vDiskSpec);
$vTask = Get-View $vTaskRef;
while ("running","queued" -contains $vTask.Info.State)
{
    $vTask.UpdateViewData();
}
if ($vTask.Info.State -eq "error")
{
    Write-Error "Error occurred while creating virtual disk."
    Write-Error $vTask.Info.Error;
}
else
{
    Write-Host "Disk was created successfully.";
}

}