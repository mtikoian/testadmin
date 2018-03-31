# Verify Cluster Resources are Online
param([string] $cluster)
Import-Module FailoverClusters

Get-ClusterResource -cluster $cluster | Select Name,State | Sort-Object State -Descending | Select-Object Name,State | ForEach-Object{
    $name = $_.Name
    $state = $_.State

    If ($state -ne "Online")
    {
       Write-Host "$name is $state" 
		exit 2
    } 
    Else
    {
		Write-Host “$name is $state”
    }
}
exit 0