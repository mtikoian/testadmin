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

function Get-VMHardDisk
{

  [Cmdletbinding()]
  param
  (
    [parameter(mandatory=$true,ValueFromPipeline=$true)]
    [object]$VM
  )
  
  if ($VM.GetType().Name -ne "VirtualMachine")
  {
    $VM = Get-VM $VM | Get-View
  }
  
  $disks = $VM.Config.Hardware.Device | Where-Object {$_.GetType().Name -eq "VirtualDisk"}
  
  foreach ($disk in $disks)
  {
    $controller = $VM.Config.Hardware.Device | Where-Object {$_.Key -eq $disk.ControllerKey}
    Add-Member -InputObject $disk -MemberType NoteProperty -Name "ControllerBusNumber" -Value $controller.BusNumber
  }
  
  $disks
}