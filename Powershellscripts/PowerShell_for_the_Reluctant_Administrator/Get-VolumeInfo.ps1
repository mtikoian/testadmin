#  ptp  20150525  Get storage volume information from one or more computers

Function Get-VolumeInfo {
<#
.SYNOPSIS
Returns storage volumne information from one or more computers.

.DESCRIPTION
The following information is returned by this function for each volume on each computer:

.PARAMETER ComputerName
A computername or list of computer names separated by commas.

Information about the storage volumes on each computer will be requested in turn, formatted
and returned as the function result.

.Parameter Scale
The Capacity and Free Space will be scaled by this factor to make the output more usable.

.OUTPUTS
ComputerName String  - The argument (IP, DNS Name, friendly name, etc.) used to specify the computer

SystemName   String  - The name of the computer (useful when informaton from multiple computers are returned)

DriveLetter  String  - The local drive letter for this volume

PctFree      Int     - The percentage of free space on this volume

Capacity     Int64   - The scaled capacity of this volume (note that the scale is part of the column name).

FreeSpace    Int64   - The available storage left on this volume (scale is also part of this column name).

BlockSize    Int     - The size of a block, always specified in bytes

FileSystem   String  - The filesystem format for this volume

Compressed   Boolean - Indicates if this volume is actively software compressed

DriveType    String  - What type of drive hosts this storage volume

.Example
C:\PS> Get-VolumeInfo

Return the information about the volumes on the current machine, using the default (1GB) scaling

.Example
C:\PS> Get-VolumeInfo -Scale 1MB

Return the information about the volumes on the current machine, with the Capacity and Free space
expressed in MegaBytes.

.Example
C:\PS> Get-VolumeInfo -ComputerName Server1.fabrikam.com

Return the information about the volumes on the Server1.fabrikam.com server, scaled in GigaBytes

.Example
C:\PS> Get-VolumeInfo -ComputerName 123.45.67.89, ., MyServer | Out-Gridview

Return the volume information about the volumes on the machine at IP addresss 123.45.67.89,
and . (the local machine), and the machine named MyServer. Pipe the output into Out-Gridview
to make it easier to use.

#>
   Param (
      [parameter(
         HelpMessage = "Enter the name of one or more computers, separated by commas.",
         mandatory = $False,
         ValueFromPipelineByPropertyName = $True
      )]
      [alias('CN', 'MachineName')]
      [string[]]
      $ComputerName = $env:Computername,
      [parameter(HelpMessage = "Enter the scaling factor (i.e. 1GB) for drive sizes.",
         Mandatory = $False,
         ValueFromPipelineByPropertyName = $True
      )]
         [ValidateSet(1, 1KB, 1MB, 1GB, 1TB)]
      [int64]
      $Scale = 1GB
   )

   Process {
      $ScaleLabel = switch ($scale) {
         1       { "";    break; }
         1KB     { " KB"; break; }
         1MB     { " MB"; break; }
         1GB     { " GB"; break; }
         1TB     { " TB"; break; }
         default { " ??"; break; }
      };

      foreach ($ThisComputer in $ComputerName) {
         Get-WmiObject -ComputerName $ThisComputer Win32_Volume |
            Select-Object @{ Name = 'ComputerName'; Expression = { $ThisComputer }},
               SystemName, DriveLetter,
               @{ Name = "PctFree"; Expression = {If ($null -eq $_.Capacity) {0} else {[math]::Truncate(1e2 * $_.FreeSpace / $_.Capacity) }}},
               @{ Name = $("Capacity" + $ScaleLabel); Expression = { [math]::Truncate($_.Capacity / $Scale) }},
               @{ Name = $("FreeSpace" + $ScaleLabel); Expression = {[math]::Truncate($_.FreeSpace / $Scale) }}, 
               BlockSize, FileSystem, Compressed,
               @{ Name = "DriveType"; Expression = {switch ($_.DriveType) { 2 { "Removable"} 3 { "Local" } 4 { "Network" } 5 { "CD"} 6 { "RAM" } default { "? " + $_.DriveType }}}}
      }
   }
}
