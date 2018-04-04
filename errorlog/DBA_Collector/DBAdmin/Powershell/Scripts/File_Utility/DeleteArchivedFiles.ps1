<#
.SYNOPSIS
Used to delete all files that have the archive bit cleared on a given path.
.DESCRIPTION
This script deletes all files at the given path whose archive bit has been cleared.
If the -Recurse parameter is suppled, then it will search all lower paths as well.
.NOTES
	Author: Josh Feierman
.PARAMETER Path
The path at which to search for archived files
.PARAMETER Mask
The optional mask to include files by. If blank, all files are included.
.Parameter Recurse
If used the script will recursively search all directories under the given path.

#>

param
(
	[parameter(mandatory=$true)][string]$Path,
	[string]$Mask="*.*",
	[switch]$Recurse
)

Set-StrictMode -Version 2.0;

#region Variable Declaration

[System.IO.FileInfo]$fileInfo = $null; 		#The fileInfo object used to interrogate the returned file objects
[Object[]]$files = $null;					#The object used to hold returned files from the Get-ChildItem cmdlet

#endregion

#region Primary Code

#Retrieve all files in the specified directory

#If the -Recurse option is specified, search recursively
if ($Recurse)
{
	$files = Get-ChildItem -Path $Path -Include $Mask -Recurse;
}
#Otherwise just get the directory specified
else
{
	$files = Get-ChildItem -Path $Path -Include $Mask;
}

#Iterate over the returned files and delete any that have the archive flag cleared
foreach ($fileInfo in $files)
{
	if ($fileInfo.Attributes -notlike "*Archive*") 
	{
		Write-Host "Deleting file " $fileInfo.FullName;
		$fileInfo.Delete();
	}
	else
	{
		Write-Host "File " $fileInfo.FullName "does not have the archive bit cleared, ignoring.";
	}
}

#endregion