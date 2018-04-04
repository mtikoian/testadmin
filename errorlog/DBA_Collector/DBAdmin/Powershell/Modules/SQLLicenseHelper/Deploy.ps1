# Get the profile path
$profilePath = (Split-Path $PROFILE) + "\Modules\SQLBackupHelper\";

#Find the path of the script that is executing
$scriptPath = Split-path $MyInvocation.MyCommand.Path;

#Create a dummy file just in case the directory doesn't exist
New-Item -Path $profilePath\touch.txt -ItemType File -Force;

#Copy the module files to the profile path
Get-ChildItem -Path $scriptPath -exclude "Deploy.ps1" | Copy-Item -Destination $profilePath;