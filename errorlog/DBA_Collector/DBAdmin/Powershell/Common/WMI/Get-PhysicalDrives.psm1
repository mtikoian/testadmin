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
	
	#Variable declaration
	[int]$numCores = 0;
	
	#Get the processor object
	$processors = Get-WmiObject -Class win32_processor -ComputerName $ComputerName;
	
	<#
	If the number of processor objects returned is greater than 1, we need to iterate through them.
	Otherwise, we can assume only one processor is present.
	#>
	if ($processors.Count -gt 0)
	{
		foreach ($processor in $processors)
		{
			#If the .NumberOfCores property is populated (a multi-core processor), we need to use it
			if ($processor.NumberOfCores -ne $null)
			{
				$numCores = $numCores + $processor.NumberOfCores;
			}
			else
			{
				$numCores ++;
			}
		}
	}
	else
	{
		$numCores = 1;
	}
	
	return $numCores;
}