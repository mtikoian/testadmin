# Verify Cluster Nodes are up	
param([string] $cluster)
Import-Module FailoverClusters

Get-ClusterNode -cluster $cluster | Select Name,State | Sort-Object State -Descending | Select-Object Name,State | ForEach-Object{
    $name = $_.Name
    $state = $_.State

    If ($state -eq "Down")
    {
       Write-Host "$name is $state" 
		exit 2
    } 
    Elseif ($state -eq "Paused")
    {
		Write-Host “$name is $state”
		exit 1
    }
	Else
	{
		Write-Host “$name is $state”
	}
}
exit 0