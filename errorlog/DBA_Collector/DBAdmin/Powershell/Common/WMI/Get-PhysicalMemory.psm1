function Get-PhysicalMemory 
{
	<#
	.SYNOPSIS
	Gets the amount of physical memory for the specified computer (in MB).
	.PARAMETER ComputerName
	The name of the computer to query.
	.EXAMPLE
	Get-PhysicalMemory -ComputerName test-computer
	.NOTES
	Author: Josh Feierman
	Created Date: 1/7/2011
	#>

	param
	(
		[string]$ComputerName = 'localhost'
	)

	#Get the base ComputerSystem object
	$ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ComputerName;

	#Retrieve the amount of physical memory
	$PhysicalMemory = [Math]::Round($ComputerSystem.TotalPhysicalMemory/1MB,0);

	return $PhysicalMemory;
}