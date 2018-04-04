<#
.SYNOPSIS 
Gets information about the physical drives attached to a computer.
.DESCRIPTION
Used to retrieve information about a computer's physical drives, specifically the amount of space free.

The script can be invoked as part of a remote command (i.e. Invoke-Command) or can be run as a 
stand alone script using the -ComputerName parameter.

.PARAMETER ComputerName
The name of the computer you want to get the information for.
.EXAMPLE
Get-PhysicalDrives -ComputerName WinTest01
.NOTES
NAME: Get-NumberOfCores
AUTHOR: Josh Feierman
LASTEDIT: 1/7/2011
#>

param
(
	[string]$ComputerName = "localhost"
)

#Get the base WMI object and format the results
$physicalDrives = Get-WmiObject -Class Win32_Volume -ComputerName $ComputerName | 
	select 	Name, 
			@{name="Capacity(GB)";expression={"{0:N2}" -f ($_.Capacity/1GB)}}, 
			@{name="SpaceFree(GB)";expression={"{0:N2}" -f ($_.FreeSpace/1GB)}},
			@{name="PercentFree";expression={"{0:P2}" -f ($_.FreeSpace/$_.Capacity)}};

return $physicalDrives;
