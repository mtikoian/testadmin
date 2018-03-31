"SQL01", "SQL02", "SQL03" | % {
	Write-Host "Adding Failover Clustering feature to server $($_)";
	Install-WindowsFeature -ComputerName $_ -Name "Failover-Clustering" -IncludeManagementTools;
	# Note: before Server 2012 you need to use Add-WindowsFeature Failover-Clustering
}