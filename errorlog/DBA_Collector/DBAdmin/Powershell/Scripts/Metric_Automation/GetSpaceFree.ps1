function Get-SpaceFree
{
	<#
	.SYNOPSIS
	Gets a list of logical drives on the machine(s) specified. If OutFile is specified, the results will be outputted to a .csv file.
	.NOTES
		Author: Josh Feierman
	.PARAMETER ComputerName
	The name of the computer to retrieve space information for.
	.PARAMETER OutFile
	The name / path of the file to output results to.
	#>

	param
	(
		[parameter(mandatory=$false)][string[]]$ComputerName,
		[parameter(mandatory=$false)][string]$OutFile
	)

	#region Variable Declaration
	
	#$Credential = $null;		#The stored credential for remoting if required.
	$wmiDrives = $null;			#The results of the Get-WMI command.
	$scriptBlock = $null;		#The script block to collect the WMI data.
	$formattedResults = $null;	#The formatted/coalesced results of the WMI commands.

	#endregion

	#Initialize the script block
	$scriptBlock = {
		Get-WmiObject -Class Win32_Volume | ? {$_.DriveType -eq 3};
	}

	#Begin branching for remote versus local data gathering.
	if ($ComputerName -ne $null)
	{
		#Collect the credential for remote use
		if ($Credential -eq $null)
		{
			$Credential = Get-Credential;
		}
		
		#Invoke the remote command
		$wmiDrives = Invoke-Command -ScriptBlock $scriptBlock -Credential $Credential -ComputerName $ComputerName
	}
	else
	{
		$wmiDrives = &$scriptBlock;
	}
	
	#Begin branching for output to screen versus file.
	
	$formattedResults = $wmiDrives | select @{label="ComputerName";expression={$_.PSComputerName}},@{label="Drive";expression={$_.Name}},@{label="Capacity";expression={"{0:N2}" -f ($_.Capacity/1mb)}},@{label="SpaceFreeMB";expression={"{0:N2}" -f ($_.FreeSpace/1MB)}},@{label="PercentFree";expression={"{0:N2}" -f (($_.FreeSpace/$_.Capacity)*100)}};
	
	if ($OutFile -ne "")
	{
		$formattedResults | ForEach-Object { $line = "`"" + $_.Drive + "`"," + $_.SpaceFreeMB + "," + $_.PercentFree + "`n"; Add-Content -Path $OutFile $line;};
	}
	else
	{
		$formattedResults | sort-object PercentFree | ft;
	}
}
