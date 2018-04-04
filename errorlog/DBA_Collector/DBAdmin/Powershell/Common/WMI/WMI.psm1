#######################################################################################################################
# File:             WMI.psm1                                                                                          #
# Author:           Josh Feierman                                                                                     #
# Publisher:                                                                                                          #
# Copyright:        © 2011 . All rights reserved.                                                                     #
# Usage:            To load this module in your Script Editor:                                                        #
#                   1. Open the Script Editor.                                                                        #
#                   2. Select "PowerShell Libraries" from the File menu.                                              #
#                   3. Check the WMI module.                                                                          #
#                   4. Click on OK to close the "PowerShell Libraries" dialog.                                        #
#                   Alternatively you can load the module from the embedded console by invoking this:                 #
#                       Import-Module -Name WMI                                                                       #
#                   Please provide feedback on the PowerGUI Forums.                                                   #
#######################################################################################################################

Set-StrictMode -Version 2

function Get-NumberOfCores
{
	<#
	.SYNOPSIS 
	Gets the total number of physical CPU cores for the given computer.
	.PARAMETER ComputerName
	The name of the computer you want to get the information for.
	.EXAMPLE
	Get-NumberOfCores -ComputerName WinTest01
	.NOTES
	NAME: Get-NumberOfCores
	AUTHOR: Josh Feierman
	LASTEDIT: 1/7/2011
	#>
	
	param
	(
		[string]$ComputerName = "localhost"
	)

	#Get the processor object
	$ComputerSystem = Get-WmiObject -Class win32_ComputerSystem -ComputerName $ComputerName;
	
	if (($ComputerSystem.Properties | Where {$_.Name -eq "NumberOfLogicalProcessors"}) -eq $null)
	{
		return $ComputerSystem.NumberOfProcessors;
	}
	else
	{
		return $ComputerSystem.NumberOfLogicalProcessors;
	}
}

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

