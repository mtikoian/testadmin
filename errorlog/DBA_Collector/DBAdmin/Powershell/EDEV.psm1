#######################################################################################################################
# File:             EDEV.psm1                                                                                         #
# Author:           Josh Feierman                                                                                     #
# Publisher:        SEI                                                                                               #
# Copyright:        © 2011 SEI. All rights reserved.                                                                  #
# Usage:            To load this module in your Script Editor:                                                        #
#                   1. Open the Script Editor.                                                                        #
#                   2. Select "PowerShell Libraries" from the File menu.                                              #
#                   3. Check the EDEV module.                                                                         #
#                   4. Click on OK to close the "PowerShell Libraries" dialog.                                        #
#                   Alternatively you can load the module from the embedded console by invoking this:                 #
#                       Import-Module -Name EDEV                                                                      #
#                   Please provide feedback on the PowerGUI Forums.                                                   #
#######################################################################################################################

Set-StrictMode -Version 2

# TODO: Define your module here.
#Get the location where the current script resides
$currentPath = $PSScriptRoot;
Write-Verbose "Current path is $currentPath";

#Load all modules under the Modules subdirectory
$scriptsToLoad = Get-ChildItem -Path $currentPath\Functions -Include "*.ps1" -Recurse;
Write-Verbose "There are $($scriptsToLoad.Count) scripts to load.";

$totalCount = $scriptsToLoad.Count;
$currentCount = 0;
$percentComplete = 0;

foreach ($script in $scriptsToLoad)
{

	Write-Progress -Activity "Loading Scripts" -Status "Loading script $($script) ($($currentCount) of $($totalCount))" -PercentComplete $percentComplete;
	Write-Verbose "Loading script $($script) ($($currentCount) of $($totalCount))";
	. $script;
	$currentCount ++;
	$percentComplete = $currentCount / $totalCount * 100;

}
