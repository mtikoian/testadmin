<#

.SYNOPSIS
Exports and imports various details from a vCenter instance.

.DESCRIPTION

Exports / imports the following from vCenter:

-Folder structure
-VM location
-Folder / VM permissions (VM folder only)
-Custom attribute values (not attribute definition iteself)

Export files are stored in the user's %temp% directory as .CSV files.

Known issues:

-If two folder with the same name exist under a single root folder, the importing of folders / permissions / VM locations may fail.


.EXAMPLE
VCenterMigration.ps1 -Server SomeServer.contoso.com -Action Export -Datacenter MyDatacenter

Exports the MyDatacenter datacenter config from SomeServer.contoso.com.

.EXAMPLE
VCenterMigration.ps1 -Server SomeServer2.contoso.com -Action Import -Datacenter MyDatacenter

Imports the exported configuration into the MyDatacenter datacenter on server SomeServer2.contoso.com.

.NOTES
	Author - Josh Feierman
	
.PARAMETER Server
 The vCenter server to execute the action against.
.PARAMETER Action
 The action to take (either "import" or "export".
.PARAMETER Datacenter
 The name of the datacenter to import or export information on.

#>

param
(
	[parameter(position=0,mandatory=$true)][string]$Server,
	[parameter(position=1,mandatory=$true)][ValidateSet('import','export')][string]$Action,
	[parameter(position=2,mandatory=$true)][string]$Datacenter
)

filter Get-FolderPath {
    $_  | % {
        $row = "" | select Name, Path, Id, ParentId
        $row.Name = $_.Name;
        $row.Id = $_.MoRef;

        $current = Get-View $_.Parent;
        $row.ParentId = $_.Parent;
        $path = $_.Name;
        do {
            $parent = $current;
            if($parent.Name -ne "vm"){$path = $parent.Name + "\" + $path;}
            $current = Get-View $current.Parent;
        } while ($current.Parent -ne $null)
        $row.Path = $path;
        $row;
    }
}

function Export-VMFolders
{
    param
    (
        [string]$sourceVI,
        [VMware.Vim.Datacenter]$datacenter
    )
    ## Export all folders
    $report = @();
    $folders = Get-View -ViewType folder -SearchRoot $datacenter.MoRef -Server $sourceVI;
    
    ##Iterate over the folder objects and retrieve the full path
    $totalCount = $folders.Count;
    $currentCount = 0;
    $percentComplete = 0;
    foreach ($line in $folders) {
        $row = $line | Select-Object Name,@{Name="Id";e={$_.MORef}},@{Name="ParentMORef";e={$_.Parent}},@{N="ParentID";e={[int]([Regex]::Match($_.Parent,"[A-Za-z\-]*([0-9]*)").Groups[1].Value)}},NewId;
        $report += $row;
        $currentCount +=1;
        $percentComplete = $currentCount / $totalCount * 100;
        Write-Progress -Activity "Retrieving Folder Paths" -Status "Retrieving folder path for folder name $($line.Name)" -PercentComplete $percentComplete;
    }
    Write-Progress -Activity "Retrieving Folder Paths" -Status "Retrieval complete" -Completed;
    $report | Export-Csv "$env:temp\Folders-with-FolderPath.csv" -NoTypeInformation
}

function Import-VMFolders
{
    param
    (
        [VMware.Vim.Datacenter]$Datacenter,#The vCenter datacenter object to place all the folders at
        [string]$destVI #The name of the destination vCenter server
    )   
    
    #Import list of folders
    #The first collection is simply an ordered list, for iterative ordered processing
    $folders = Import-Csv "$env:temp\Folders-with-FolderPath.csv" | Sort-Object -Property @{Expression={[int]::Parse($_.ParentId)}};
    #We're constructing a separate hash table for use as a "database" of sorts
    $folderHash = @{};
    $folders | %{$folderHash.Add($_.Id,$_);};
    
    #Set progress counters
    $totalCount = $folders.Count;
    $currentCount = 1;
    $percentComplete = 0;
    
    foreach($folder in $folders){
    
        #Write progress information
        $percentComplete = $currentCount / $totalCount * 100;
        Write-Progress -Activity "Creating Folders" -Status "Creating folder $($folder.Name).." -PercentComplete $percentComplete;
        
        try
        {
#            $pathKeys = @();    #Variable to hold the path folder names
#            $pathKeys = $folder.Path.Split("\"); #Split the folder path into separate names
            $currentKey = "";   #Holds the current folder key name
            $currentObject = $null;     #Holds the current object
            
            #If there's only one item in the split path, and it matches the name of the folder, then we need to set the
            #root path of the folder to be the root object's VM folder, since it is not under any subfolders.
#            if (($pathKeys.Count -eq 1) -and ($pathKeys[0] -eq $folder.Name) -and (-not ("datastore","network","host","vm" -contains $folder.Name)))
#            {
#                $currentObject = Get-View -Server $destVI -Id $Datacenter.VMFolder;
#            }
#            #Else if the name of the folder is certain root folders, skip this one
#            elseif ("datastore","network","host","vm" -contains $folder.Name) 
#            {
#                continue;
#            }
#            #Otherwise we have to take an iterative approach to get down to the true parent object
#            else
#            {
#                # We're now going to iterate through the item keys in order, so that we eventually get the object reference for
#                # the true parent folder of the object we're on right now.
#                for ($i = 0;$i -lt $pathKeys.Count -1; $i++)
#                {
#                    $currentKey = $pathKeys[$i];
#                    
#                    #If the current object is null, we're at the root
#                    if ($currentObject -eq $null)
#                    {
#                        $currentObject = Get-View -ViewType folder -SearchRoot $rootDatacenter.MORef -Filter @{"name"="$($currentKey)"} -Server $destVI;
#                    }
#                    #Otherwise, we start the search at the current object
#                    else
#                    {
#                        $currentObject = Get-View -ViewType folder -SearchRoot $currentObject.MORef -Filter @{"name"="$($currentKey)"} -Server $destVI;
#                    }
#                
#                }
#            }
            
            #If we are dealing with one of the root system folders, we just want to retrieve the new ID
            #and update the hashtable
            if ("datastore","network","host","vm" -contains $folder.Name)
            {
                $newFolder = Get-View -ViewType folder -Filter @{"Name"="^$($folder.Name)"} -SearchRoot $datacenter.MORef;
                $folderHash[$folder.Id].NewId = $newFolder.MORef;
            }
            #Otherwise, we need to get the parent folder of the current object based on the New ID property
            else
            {
                $newId = $folderHash[$folder.ParentMORef].NewId;
                $parentFolder= Get-VIObjectByVIView -MORef $newId;
            
                $newFolder = Get-Folder -Location $parentFolder -Name $folder.Name -ErrorAction SilentlyContinue;
                if ($newFolder -eq $null)
                {
                    #Create the new folder
                    $newFolder = New-Folder -Name $folder.Name -Location $parentFolder -Server $destVI;
                }
            
                $folderHash[$folder.Id].NewId =  $newFolder.Id;
                $folder.NewId = $newFolder.Id;
            }
        }
        catch [System.Exception]
        {
            Write-Error "Error occurred processing Folder $($folder.Name)."
            Write-Error $Error[1];
            $Error.Clear();
        }
        #Increment progress
        $currentCount ++;
        
    }
    
    #Export final results
    $folders | Export-Csv -Path "$env:temp\Folders-With-Folderpaths-Final.csv" -NoTypeInformation;
}

function Export-VMPermissions
{

    param
    (
        [VMware.Vim.Datacenter]$datacenter,
        [string]$sourceVI
    )

    $folders = Get-View -ViewType folder -SearchRoot $datacenter.MORef -Server $sourceVI;
    $vms = Get-View -ViewType virtualmachine -SearchRoot $datacenter.MORef -Server $sourceVI;
    $permissions = (Get-VIObjectByVIView -MORef $datacenter.MORef -Server $sourceVI) | Get-VIpermission
    
    $totalCount = $folders.Count + $vms.Count + $permissions.Count;
    $currentCount = 1;
    $percentComplete = 0;
            
    $report = @()
    foreach($folder in $folders){
        
        Write-Progress -Activity "Retrieving folder permissions" -Status "Retrieving permission for $($folder.Name)" -PercentComplete $percentComplete;
        $perms = (Get-VIObjectByVIView -MORef $folder.MORef -Server $sourceVI) | Get-VIPermission -Server $sourceVI;
        if ($perms -eq $null) {continue;}
        foreach($perm in $perms)
        {
            $row = "" | select EntityId, FolderName, Role, Principal, IsGroup, Propagate
            $row.EntityId = $perm.EntityId
            $Foldername = (Get-View -id $perm.EntityId).Name
            $row.FolderName = $foldername
            $row.Principal = $perm.Principal
            $row.Role = $perm.Role
            $row.IsGroup = $perm.IsGroup
            $row.Propagate = $perm.Propagate
            $report += $row
        }
        $currentCount ++;
        $percentComplete = $currentCount / $totalCount * 100;
    }

    foreach($vm in $vms){

        Write-Progress -Activity "Retrieving VM permissions" -Status "Retrieving permission for $($vm.Name)" -PercentComplete $percentComplete;
        $perms = (Get-VIObjectByVIView -MORef $vm.MORef -Server $sourceVI) | Get-VIPermission -Server $sourceVI; 
        if ($perms -eq $null) 
        {
            $currentCount ++; 
            $percentComplete = $currentCount / $totalCount * 100;
            continue;
        }
        foreach ($perm in $perms)
        {
            $row = "" | select EntityId, FolderName, Role, Principal, IsGroup, Propagate
            $row.EntityId = $perm.EntityId
            $Foldername = (Get-View -id $perm.EntityId).Name
            $row.FolderName = $foldername
            $row.Principal = $perm.Principal
            $row.Role = $perm.Role
            $row.IsGroup = $perm.IsGroup
            $row.Propagate = $perm.Propagate
            $report += $row
        }
        $currentCount ++; 
        $percentComplete = $currentCount / $totalCount * 100;

    }

    foreach($perm in $permissions){
        Write-Progress -Activity "Retrieving global permissions" -Status "Retrieving permission for $perm.Principal" -PercentComplete $percentComplete;        
        if ($perm -eq $null) {continue;}
        $row = "" | select EntityId, FolderName, Role, Principal, IsGroup, Propagate
        $row.EntityId = $perm.EntityId
        $Foldername = (Get-View -id $perm.EntityId).Name
        $row.FolderName = $foldername
        $row.Principal = $perm.Principal
        $row.Role = $perm.Role
        $row.IsGroup = $perm.IsGroup
        $row.Propagate = $perm.Propagate
        $report += $row
        $percentComplete = $currentCount / $totalCount * 100;        
    }

    $report | Sort-Object -Unique -Property EntityId, FolderName, Role, Principal | export-csv "$env:temp\perms.csv" -NoTypeInformation


}

function Export-VMLocations
{
    param
    (
        $sourceVI,
        [VMware.Vim.Datacenter]$datacenter
    )
    ##Export all VM locations
    $report = @()
    $vmList = Get-View -SearchRoot $datacenter.MORef -ViewType VirtualMachine;
    
    $currentCount = 0;
    $totalCount = $vmList.Count;
    
    foreach ($vm in $vmList)
    {
        $percentComplete = $currentCount / $totalCount * 100;
        Write-Progress -Activity "Exporting VM locations" -Status "Exporting location for VM $($vm.Name)" -PercentComplete $percentComplete;
        $report += $vm | select Name, @{n="Id";e={$_.MORef}}, @{n="ParentId";e={$_.Parent}};
        $currentCount +=1;
    }

    $report | Export-Csv "$env:temp\vms-with-FolderPath.csv" -NoTypeInformation
    Write-Progress -Activity "Exporting VM locations" -Status "Export complete" -Completed;

}

function Export-VMCustomAttributes
{

    ##Export VM Custom Attributes and notes
    
    param
    (
        $sourceVI,
        [VMware.Vim.Datacenter]$datacenter
    )
    $vmlist = Get-VIObjectByVIView $datacenter.MORef | get-vm 
    
    $totalCount = $vmlist.Count;
    $currentCount = 0;
    
    $Report =@()
        foreach ($vm in $vmlist) {
            $percentComplete = $currentCount / $totalCount * 100;
            Write-Progress -Activity "Exporting custom properties" -Status "Exporting properties for VM $($vm.Name)" -PercentComplete $percentComplete;
            
            $customattribs = $vm | select -ExpandProperty CustomFields;
            foreach ($attrib in $customattribs)
            {
                $row = "" | Select Name, Key, Value
                $row.name = $vm.Name
                $row.Key = $attrib.key
                $row.Value = $attrib.value
                $Report += $row;
            }
            
            $currentCount += 1;
        }

    $report | Export-Csv "$env:temp\vms-with-attributes.csv" -NoTypeInformation
    Write-Progress -Activity "Exporting custom properties" -Status "Export complete." -Completed;


}

function Import-VMLocations
{

    ##move the vm's to correct location
    param
    (
        [string]$destVI,
        [VMware.Vim.Datacenter]$datacenter
    )
    $VMfolder = @()
    $VMfolder = import-csv "$env:temp\VMs-with-FolderPath.csv" | Sort-Object -Property Name
	$folderHash = @{};
	$folderFile = Import-Csv "$env:temp\Folders-With-Folderpaths-Final.csv";
	$folderFile | %{ $folderHash.Add($_.Id,$_); };
	
	$totalCount = $VMfolder.Count;
	$currentCount = 0;
	$percentComplete = 0;
	
    foreach($guest in $VMfolder){
        
		Write-Progress -Activity "Moving VMs" -Status "Moving VM $($guest.Name)" -PercentComplete $percentComplete;
		
		$newFolderId = $folderHash[$guest.ParentId].NewId;
		$newFolder = Get-View -Id $newFolderId | % { Get-VIObjectByVIView -MORef $_.MORef; };
		$vm = Get-View -ViewType VirtualMachine -SearchRoot $datacenter.MORef -Filter @{"name"="$($guest.Name)"} | %{ Get-VIObjectByVIView -MORef $_.MORef }
		
		if ($vm -eq $null)
		{
			Write-Warning "VM $($guest.Name) not found, continuing on.";
			$currentCount ++;
			$percentComplete = $currentCount / $totalCount * 100;
			continue;
		}
			
        Move-VM $vm -Destination $newFolder | Out-Null; 
		
		$currentCount ++;
		$percentComplete = $currentCount / $totalCount * 100;
    }


}

function Import-VMCustomAttributes
{

    ##Import VM Custom Attributes and Notes
    param
    (
        [string]$destVI,
        [VMware.Vim.Datacenter]$datacenter
    )
    $NewAttribs = Import-Csv "$env:temp\vms-with-attributes.csv"
	$totalCount = $NewAttribs.Count;
	$currentCount = 0;
	$percentComplete = 0;
	
	$rootDatacenter = Get-VIObjectByVIView -MORef $datacenter.MORef;

    foreach ($line in $NewAttribs) {
	
		Write-Progress -Activity "Importing VM Attributes" -Status "Importing for VM $($line.Name) ($($currentCount) of $($totalCount))" -PercentComplete $percentComplete;
		$vm = Get-VM -Name $line.Name -Location $rootDatacenter -ErrorAction SilentlyContinue -Server $destVI;
		if ($vm -eq $null)
		{
			Write-Warning "VM $($line.Name) not found, continuing on.";
		}
		else
		{
    		Set-CustomField -Entity $vm -Name $line.Key -Value $line.Value -confirm:$false | Out-Null;
		}
		
		$currentCount ++;
		$percentComplete = $currentCount / $totalCount * 100;
    
    }


}

function Import-VMPermissions
{

    ##Import Permissions and folders
    param
    (
        [string]$destVI,
        [VMware.Vim.Datacenter]$rootDatacenter
    )
    $permissions = @()
    $permissions = Import-Csv "$env:temp\perms.csv"
    $folders = @();
    $folders = Import-Csv "$env:temp\Folders-With-Folderpaths-Final.csv";
    
    #Progress counter
    $totalCount = $permissions.Count;
    $currentCount = 1;
    $percentComplete = 0;

    foreach ($perm in $permissions) {
        $Error.Clear();
        $percentComplete = $currentCount / $totalCount * 100;
        Write-Progress -Activity "Importing Permissions" -Status "Adding permission for principal $($perm.Principal) to object $($perm.Foldername)" -PercentComplete $percentComplete;

        try 
        {
            $entity = ""
            $entity = New-Object VMware.Vim.ManagedObjectReference
            
            switch -wildcard ($perm.EntityId)
                {
                     Folder* { 
                     $entity.type = "Folder"
					 $folder = $folders | Where-Object {$_.Id -eq $perm.EntityId};
					 if ($folder -eq $null)
					 {
					 	Write-Warning "Folder $($perm.FolderName) not found, continuing on.";
					 }
					 else
					 {
                     	$entity.value = $folder.NewId.Trimstart("Folder-");
					 }
                     }
                     VirtualMachine* { 
                     $entity.Type = "VirtualMachine"
					 $vm = Get-View -ErrorAction SilentlyContinue -ViewType VirtualMachine -SearchRoot $datacenter.MORef -Filter @{"name"="$($perm.FolderName)"}
					 if ($vm -eq $null)
					 {
					 	Write-Warning "VM $($perm.FolderName) not found, continuing on.";
					 }
					 else
					 {
                     	$entity.value = $vm.MORef.Value;
					 }
                    }
                    default {
                        continue;
                    }
                }
			
			if ($entity.value -eq $null)
			{
				Write-Warning "Entity not found for ID '$($perm.EntityId)', name '$($perm.FolderName)'.";
			}
			else
			{
	            $setperm = New-Object VMware.Vim.Permission
	            $setperm.principal = $perm.Principal
	                if ($perm.isgroup -eq "True") {
	                    $setperm.group = $true
	                    } else {
	                    $setperm.group = $false
	                    }
	            $setperm.roleId = (Get-virole -Server $destVI -Name $perm.Role).id
	            if ($perm.propagate -eq "True") {
	                    $setperm.propagate = $true
	                    } else {
	                    $setperm.propagate = $false
	                    }
	                        
	            $doactual = Get-View -Id 'AuthorizationManager-AuthorizationManager' -Server $destVI;
	            $doactual.SetEntityPermissions($entity, $setperm)
			}
        }
        catch [System.Exception]
        {
            Write-Error "Error processing $($perm)";
            Write-Error $Error[1];
        }
        
        $currentCount++;
    }


}

function Add-VMHostAdmin
{

    param([string[]]$vmhosts = $null)

    $report = @();  #Holds the results of setting the passwords for the hosts
    
    #Load assembly for generating passwords
    [Reflection.Assembly]::LoadWithPartialName(“System.Web”) | Out-Null;
        
    #Prompt for credentials to connect to hosts
    $esx_host_creds = $host.ui.PromptForCredential("ESX/ESXi Credentials Required", "Please enter credentials to log into the ESX/ESXi host.", "", "")

    foreach ($vmhost in $vmhosts){

    Write-Host "Connection to server $vmhost";
    
    #Connect to host
    connect-viserver $vmhost -credential $esx_host_creds > $NULL 2>&1

    #Initialize a new object to hold the information
    $row = "" | select Hostname, Password;
    
    #Generate random password
    $password = [System.Web.Security.Membership]::GeneratePassword(15,5);
    
    #Create the user
    $existingUser = Get-VMHostAccount -Id vcuser -ErrorAction SilentlyContinue;
    if ($existingUser -eq $null)
    {
        New-VMHostAccount -user -id vcuser -password $password -description "EDev VC User account";
        Write-Host "`tUser does not exist, it has been created.";
    }
    else
    {
        $existingUser = New-Object VMware.Vim.HostPosixAccountSpec;
        $existingUser.id = "vcuser";
        $existingUser.Password = $password;
        
        $acctMgr = Get-View (Get-View ServiceInstance).Content.accountManager;
        $acctMgr.UpdateUser($existingUser);
        Write-Host "`tUser already exists, password has been reset.";
    }
    
    #Store the information
    $row.Hostname = $vmhost;
    $row.Password = $password;
    $report += $row;

    #Grant the authorization
    $AuthMgr = Get-View (Get-View ServiceInstance).Content.AuthorizationManager
    $Entity = Get-Folder ha-folder-root | Get-View
    $Perm = New-Object VMware.Vim.Permission
    $Perm.entity = $Entity.MoRef
    $Perm.group = $false
    $Perm.principal = "vcuser"
    $Perm.propagate = $true
    $Perm.roleId = ($AuthMgr.RoleList | where {$_.Name -eq "Admin"}).RoleId
    $AuthMgr.SetEntityPermissions($Entity.MoRef,$Perm)

    Disconnect-viserver;
    }
    
    $report | Export-Csv -Path$env:TEMP\accountlist.csv -NoTypeInformation;
    Write-Warning "Account information has been saved to $env:Temp\accountlist.csv. This file contains unsecured information and should be deleted or " +
                  "moved to a secure location as soon as possible.";    

}

$Error.Clear();

try
{
	#Validate the parameters and prompt user to confirm.
	$msg = "About to perform '$Action' on vCenter server '$Server', do you want to proceed?";

	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
	    "Join the computer to a specified domain."

	$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
	    "Leave the machine as it is.."

	$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

	$result = $host.ui.PromptForChoice("Confirm Action", $msg, $options, 0);

	#If the user selected "No", we need to abort.
	if ($result -eq 1)
	{
		Write-Host -ForegroundColor Yellow -BackgroundColor Black -Object "Aborting script execution upon request.";
		exit 0;
	}

	try { Connect-VIServer $Server; }
	catch [System.Exception] {throw "Error connection to specified vCenter server '$Server'.";}

	$datacenterObj = Get-View -ViewType Datacenter -Filter @{"name"="$Datacenter"};
	if ($datacenterObj -eq $null) {throw "Could not retrieve datacenter specified '$Datacenter' from vCenter server '$Server'.";}

	if ($Action -eq "Export")
	{

		Export-VMFolders -sourceVI $Server -datacenter $datacenterObj;
		Export-VMLocations -sourceVI $Server -datacenter $datacenterObj;
		Export-VMCustomAttributes -sourceVI $Server -datacenter $datacenterObj;
		Export-VMPermissions -sourceVI $Server -datacenter $datacenterObj;

	}
	elseif ($Action -eq "Import")
	{
	
		Import-VMFolders -destVI $Server -datacenter $datacenterObj;
		Import-VMPermissions -destVI $Server -datacenter $datacenterObj;
		Import-VMLocations -destVI $Server -datacenter $datacenterObj;
		Import-VMCustomAttributes -destVI $Server -datacenter $datacenterObj;
	
	}
	
	Disconnect-VIServer -Server $Server -Confirm:$false;

}
catch [System.Exception]
{

	Write-Host -ForegroundColor Red "An error has occurred executing script. See details below.";
	Write-Host -ForegroundColor Red $Error;
	exit 1;

}

exit 0;