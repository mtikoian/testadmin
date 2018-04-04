<#

#>

[Cmdletbinding()]
param
(
    [parameter(mandatory=$true)]
    [string]$ClusterName
)

Set-StrictMode -Version Latest;

# Get all presented LUNs
$allLUNs = Get-Cluster $ClusterName | Get-VMHost | Get-Random | Get-ScsiLun;

# Get all RDM Luns
$rdmLUNs = Get-VM -Location $ClusterName | `
    Get-HardDisk -DiskType "RawVirtual","RawPhysical" | `
    Select-Object @{n="VMName";e={$_.Parent}},@{n="DiskName";e={$_.Name}},ScsiCanonicalName;

# Get all datastore LUNs
$datastoreLUNs = Get-Cluster $ClusterName | `
    Get-VMHost | `
    Get-Random | `
    Get-Datastore | `
    Get-View | `
    Select @{n="DatastoreName";e={$_.Name}},@{n="ScsiCanonicalName";e={$_.Info.Vmfs.Extent[0].DiskName}};
    
# Load SQL Compact Edition DLL
Add-Type -Path "$env:ProgramFiles\Microsoft SQL Server Compact Edition\v3.5\Desktop\System.Data.SqlServerCe.dll";

$# Instantiate a connection
$scriptPath = Split-Path $MyInvocation.MyCommand.Path;
$connString = "Data Source=$scriptPath\FreeLuns.sdf";
$sqlConn = New-Object "System.Data.SqlServerCe.SqlCeConnection" $connString;
$sqlConn.Open();
$sqlCmd = $sqlConn.CreateCommand();

# Insert all LUNs
foreach ($lun in $allLUNs)
{
    $sql = "INSERT all_luns VALUES ('$($lun.CanonicalName)','$($lun.ConsoleDeviceName)','$($lun.CapacityMB)')";
    $sqlCmd.CommandText = $sql;
    $sqlCmd.ExecuteNonQuery();
}
