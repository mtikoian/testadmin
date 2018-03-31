<#This script:
1. Create a new VM based on an image in the image gallery
2. Instructs the user to go and sysprep the machine and create an image from it (this can't be done using Powershell)
3. Creates 3 new VMs based on the new image
4. Removes the 3 newly created VMs along with the VHDs that were created for them.
Clearly there is no point in creatinng 3 VMs and then immediately removing them, this is merely for demo purposes.
Jamie Thomson, 2013-11-01
#>
param(  $subscription="",              $serviceName="",            $storageAccount="", 
        $adminUsername="",             $adminPassword="",          $SourceImageName = "a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201310.01-en.us-127GB.vhd", #Windows Server 2012 Datacenter, October 2013
        $instanceSize = "ExtraSmall",  $location = "West Europe",  $templateVMName = ""
)
Function RemoveAllVMsFromAService {
param([string]$svcName)
    $VMs = Get-AzureVM $svcName -ErrorAction Stop
    foreach ($VM in $VMs)
    {
        $OSDisk = ($VM | Get-AzureOSDisk -ErrorAction Stop)
        "status = " + $VM.InstanceStatus
        if ($VM.InstanceStatus -eq "ReadyRole") {
            "Stopping VM " + $VM.Name
            Stop-AzureVM -Name $VM.Name -ServiceName $svcName -ErrorAction Stop
        }
        "Removing VM '" + $VM.Name + "' on '$svcName'"
        Remove-AzureVM -ServiceName $svcName -Name $VM.Name -ErrorAction Stop
        while (Get-AzureDisk -DiskName $OSDisk.DiskName -ErrorAction Stop | where {$_.AttachedTo -ne $null}) 
        {
            "Waiting for disk lease to be removed..."
            Start-Sleep -Seconds 30 -ErrorAction Stop
        }
        "Removing disk '" + $OSDisk.DiskName + "' on blob '$OSDisk.MediaLink'"
        Remove-AzureDisk -DiskName $OSDisk.DiskName -DeleteVHD -ErrorAction Stop
        #if your VM has datadisks you may want to add some code here to remove those too
    }
}
cls
<#Call to Import-Module assumes Azure Powershell is installed and configured 
http://www.windowsazure.com/en-us/manage/install-and-configure-windows-powershell/. 
It also assumes the location of Azure.psd1, so this might need editing accordingly 
depending on where you have installed it.#>
$AzureModulePath = 'C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1'
if (-not (Test-Path $AzureModulePath))
{
    "Nothing found at $AzureModulePath , either you have not installed Azure Powershell (install from http://www.windowsazure.com/en-us/manage/install-and-configure-windows-powershell/) or you have not installed it in the default location in which case edit this script accordingly"
    break
}
Import-Module $AzureModulePath -Verbose

if ($subscription -eq ""){$subscription = Read-Host "Please enter the name of the Azure subsciption in which you want to create your VMs (e.g. MSDN sub)"}
if ($serviceName -eq ""){$serviceName = Read-Host "Please enter the name that you want to give to the cloud service that will house your VMs (e.g. demoservice)"}
if ($adminUsername -eq ""){$adminUsername = Read-Host "What username should we give to the VM system administrator (this will be used for all VMs (e.g. sa)"}
if ($adminPassword -eq ""){$adminPassword = Read-Host "Please enter a password for the system administrator (>8 characters & meet complexity reqs)"}
if ($templateVMName -eq ""){$templateVMName = Read-Host "Your VM names will all have the same prefix. What would you like to use for that prefix (no underscores)? (e.g. MyVM)"}
if ($storageAccount -eq ""){$storageAccount = Read-Host "What storage account should we put all of your VMs into (if the storage account doesn't exist I'll create it for you. Please use all lower case) (e.g. vmstore)?"}
Add-AzureAccount -ErrorAction Stop
#Get-AzureSubscription 
"Setting '$subscription' as the default subscription"
Select-AzureSubscription -Default $subscription -ErrorAction Stop

if ((get-azureservice -ErrorAction Stop | where {$_.ServiceName -eq $serviceName} | select ServiceName ) -eq $null)
{
    "Creating Azure cloud service $serviceName"
    New-AzureService $serviceName -Location $location -ErrorAction Stop
}
if ((Get-AzureStorageAccount -ErrorAction Stop | where {$_.StorageAccountName -eq $storageAccount} | select StorageAccountName) -eq $null)
{
    "Creating storage account '$storageAccount' at $location with label $serviceName"
    New-AzureStorageAccount -StorageAccountName $storageAccount -Location $location -Label $serviceName -ErrorAction Stop
}
else
{
    "Storage account '$storageAccount' already exists. No need to create it."
}
"Setting '$storageAccount' as the current storage account"
Set-AzureSubscription -SubscriptionName $subscription -CurrentStorageAccountName $storageAccount -ErrorAction Stop

#Create a VM
"Creating VM '$templateVMName' as size '$instanceSize' (will wait for boot)"
New-AzureVMConfig -Name $templateVMName -InstanceSize $instanceSize -ImageName $sourceImageName -ErrorAction Stop `
    | Add-AzureProvisioningConfig –Windows -AdminUsername $adminUsername –Password $adminPassword -ErrorAction Stop `
    | New-AzureVM –ServiceName $serviceName -WaitForBoot -ErrorAction Stop
"VM '$templateVMName' has booted!"

Read-Host "Go and sysprep your newly created VM and create an image of it using the instructions here: 
https://www.windowsazure.com/en-us/manage/windows/how-to-guides/capture-an-image/. 
Call the image 
    $templateVMName
Go ahead, I'll wait for you... Press Enter when you're done!"

#Create VMs from the newly created image
$VMNameSuffixes = (1,2,3) #Create as many suffixes as you want to create virtual machines. Suffixes are a maximum of 3 chars.
foreach ($VMNameSuffix in $VMNameSuffixes)
{
    $VMName = "00" + $VMNameSuffix
    $VMName = $serviceName + $VMName.Substring($VMName.Length - 3)
    #$VMName
    
    $NewmImageName = (get-azurevmimage -ErrorAction Stop | where {$_.ImageName -eq $templateVMName}).ImageName
    "Creating VM '$VMName' as size '$instanceSize' (will wait for boot)"
    New-AzureVMConfig -Name $VMName -InstanceSize $instanceSize -ImageName $NewmImageName -ErrorAction Stop `
        | Add-AzureProvisioningConfig –Windows -AdminUsername $adminUsername –Password $adminPassword -ErrorAction Stop `
        | New-AzureVM –ServiceName $serviceName -WaitForBoot -ErrorAction Stop
    "VM '$VMName' has booted!"
}

"********Now removing your new VMs!!!********"
RemoveAllVMsFromAService $serviceName


