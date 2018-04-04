
$modulePath = "$Env:USERPROFILE\Documents\WindowsPowerShell\Modules";
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path;
$scriptPathReplace = $scriptPath -replace "\\","\\";

#Test if the powershell profile directory exists
if (-not (Test-Path $modulePath))
{
	New-Item -Path $modulePath -ItemType directory;
}

#Get all child items under this path
$childFiles = Get-ChildItem -Path $scriptPath -Recurse

#Get the count of all child items to be copied
$countItemsToBeCopied = $childFiles.Count;
$countItemsCopied = 0;

foreach ($childFile in $childFiles)
{
	#If the type of object is FileSystemInfo, it is a file
	if ($childFile.GetType().Name -eq "FileInfo")
	{
		#Get the path minus the original execution path
		$newPath = $childFile.FullName -replace $scriptPathReplace,$modulePath
		
		#Copy the file
		Copy-Item -Path $childFile.VersionInfo.FileName -Destination $newPath
	}
	#Otherwise if it is a folder
	elseif ($childFile.GetType().Name -eq "DirectoryInfo")
	{
		#Get the path to the new folder
		$newPath = $childFile.FullName -replace $scriptPathReplace,$modulePath
		
		#Test if the folder already exists, and create it if it does not
		if (-not (Test-Path -Path $newPath))
		{
			New-Item -Path $newPath -ItemType directory
		}
	}
	
	$countItemsCopied ++;
	Write-Progress -Activity "Module Installation" -Status "Copying file or folder $childFile" -PercentComplete (100*($countItemsCopied/$countItemsToBeCopied))
	
}

Read-Host -prompt "Press Enter to continue...";