<#



#>


<#
.SYNOPSIS
Creates a partition on the specified disk number.

.PARAM DiskNumber
The disk number on which to create the partition.

.PARAM Align
The size in KB of the partition's alignment.

.PARAM Size
The size in MB of the partition (if left blank the partition will be as large as the device.

.PARAM Offset
The size (in KB) to offset the partition

.PARAM MountPath
The path at which to mount the partition. Will be created if it does not exist.

.PARAM MountPoint
If selected, the specified MountPath will be treated as a Mount Point, not a standalone drive letter.
#>
function Create-DiskPartition
{

    param
    (
        [parameter (mandatory=$true)][int]$DiskNumber,
        [int]$Align = 32,
        [int]$Size,
        [int]$Offset,
        [parameter(mandatory=$true)][string]$MountPath,
        [switch]$MountPoint
    )
    
    Set-StrictMode -Version "Latest";
    
    $diskpartCmd = "";  #The command to pass to Diskpart
    $partitionCmd = ""; #The command specific to creating the partition
    
    #Construct the command (up to the point where the partition is created)
    $diskpartCmd = @"
    select disk $DiskNumber
    online disk 
    attributes disk clear readonly
"@;
    
    #Construct the command to create the partition
    $partitionCmd = "create partition primary align=$Align";
    #If Size is specified, add it
    if ($Size -ne $null)
    {
        $partitionCmd += " size=$Size";
    }
    #If Offset is specified, add it
    if ($Offset -ne $null)
    {
        $partitionCmd += " offset=$Offset";
    }
    
    #Add the partiton command to the parent Diskpart command
    $diskpartCmd += "`n" + $partitionCmd;
    
    #Add the command to assign the mount point
    if ($MountPoint)
    {
        $diskpartCmd += "`n" + "assign mount=$MountPath";
    }
    else
    {
        $diskpartCmd += "`n" + "assign letter=$MountPath";
    }
    
    #Add one more new line
    $diskpartCmd += "`n";
    
    #Execute the command
    $diskpartCmd | diskpart
    
    #Check the return code
    if ($LASTERROREXIT -ne 0)
    {
        Write-Error "An error has occurred process the requested commands.";
    }
    

}