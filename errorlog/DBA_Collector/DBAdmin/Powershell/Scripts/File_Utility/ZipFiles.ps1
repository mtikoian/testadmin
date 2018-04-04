<#
.SYNOPSIS
Used to archive all files on a given path.
.DESCRIPTION
This script archives all files at a given path, using the 7-zip utility. Files are
zipped into an archive with the same name as the file. Once the file is zipped it is deleted.
.NOTES
	Author: Josh Feierman
.PARAMETER Path
The path at which to search for files to be zipped.
.PARAMETER Mask
The optional mask to include files by. If blank, all files are included.
.Parameter Recurse
If used the script will recursively search all directories under the given path.

#>

param
(
	[parameter(mandatory=$true)][string]$Path,
	[string]$Mask="*",
	[switch]$Recurse
)

#region Variable Declaration

[Object[]]$files = $null;					#Stores the retrieved file information objects
[System.IO.FileInfo]$fileInfo = $null;		#Used to iterate the file info objects and interrogate them.
[String]$7Zip = "";							#The path to the 7-zip executable
[String]$archivePath = "";					#The path to the archive file (constructed using file name)

#endregion

#Get the path to the 7-zip executeable
$7zip = "C:\Program Files\7-Zip\7z.exe";

#Get all file objects

if ($Recurse)
{
	$files = Get-ChildItem -Path $Path -Include $Mask -Recurse;
}
else
{
	$files = Get-ChildItem -Path $Path\$Mask;
}

#If no files are found, exit
if ($files -eq $null) { exit 0;}

#Iterate all files and zip
foreach ($fileInfo in $files)
{
	#Archive the file
	$archivePath =  $fileInfo.FullName + ".7z";
	& $7zip a $archivePath $fileInfo.FullName
	
	#If the archive was successful, then delete the file
	if ($LASTEXITCODE -eq 0)
	{
		$fileInfo.Delete();
	}
	else
	{
		Write-Error "Could not archive file $fileInfo, see output for details.";
	}
}

if ($Error)
{
	exit 1;
}

