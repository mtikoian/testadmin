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