<#
.SYNOPSIS
Used to perform routine Windows maintenance tasks.
.DESCRIPTION
Performs routine maintenance tasks, such as
	-Clearing out of all temp files
	-Backup of files to specified network location
	-Check of fragmentation levels on all drives and alerting the user if any need work
.NOTES
Author: Josh Feierman - 3/31/2011
.PARAMETER Config
The path to the XML configuration file.
#>

param
(
	[string]$Config = "config.xml"
)

Set-StrictMode -Version 2.0;

#Load config file
$configXML = [xml](Get-Content $config);

#Clear temp files
if ($configXML.Config.ClearTempFiles.execute -eq "True")
{
	#Get the path for temporary files
	$tempFilePath = $Env:TEMP;
	
	#Delete recursively under that path
	Remove-Item -Path $tempFilePath\* -Recurse -Verbose;
	
}

#If backups are configured, run them
if ($configXML.Config.Backups.execute -eq "True")
{
	#Get the remote location
	$remoteServer = $configXML.Config.Backups.RemotePath.ServerName;
	#Enter a ping loop to see if the server is available
	$pingResult = 1;
	while ($pingResult -ne 0)
	{
		ping -n 1 $remoteServer;
		$pingResult = $LASTEXITCODE;
	}
	#If remote folder does not exist, create it
	$remoteFolder = $configXML.Config.Backups.RemotePath.Folder;
	if ((Test-Path -Path \\$remoteServer\$remoteFolder) -eq $false)
	{
		New-Item -Path \\$remoteServer\$remoteFolder -ItemType "directory";
	}
	#Loop through each Path element and process
	foreach ($backupPath in $configXML.Config.Backups.Paths.Path)
	{
		#Get the folder location and properties
		$backupFolder = $backupPath.get_InnerText();
		$backupMask = $backupPath.mask;
		$backupRecurse = $backupPath.recurse;
		
		#If the specified path's last character is a "\", remove it
		if ($backupFolder.EndsWith("\")) {$backupFolder = $backupFolder.Substring(0,$backupFolder.Length - 1);}
		
		$backupCmd = "ROBOCOPY $backupFolder \\$remoteServer\$remoteFolder\" + (Split-Path $backupFolder -Leaf) + " $backupMask /MIR /R:5 /W:10";
		if ($backupRecurse -eq $true) { $backupCmd += " /E";}
		
		Invoke-Expression $backupCmd;
		
	}
	
	Read-Host -Prompt "Press enter to continue";
}

