New-Cluster -Name SQLCLUSTER -Node SQL01,SQL02,SQL03 -StaticAddress 10.0.0.5,10.0.1.5 -AdministrativeAccessPoint ActiveDirectoryAndDns -NoStorage

Set-ClusterOwnerNode -Resource "Cluster IP Address" -Owners SQL01,SQL02
Set-ClusterOwnerNode -Resource "Cluster IP Address 10.0.1.5" -Owners SQL03

(Get-ClusterNetwork -Name "Cluster Network 1").Name = "Primary Datacenter Network"
(Get-ClusterNetwork -Name "Cluster Network 2").Name = "Secondary Datacenter Network"

Set-ClusterQuorum -NodeAndFileShareMajority \\RRAS\SQLClusterWitness

(Get-ClusterNode SQL03).NodeWeight = 0
