##
## Powershell script for NSClient to check if cluster resources are running on their preferred owner
##
## Written by Roderick Bant - NedStars B.V.
##
## This Only works on a 2 node cluster
##

ImportSystemModules

## Get this Node's name

$Computer = Get-Content env:ComputerName

## Set Script Output variable

$OutputData = ""
$ErrorsDetected = 0
$GroupsOnNode = 0

## Get list of Nodes that do not equal this Node's Name

$ClusterNodes = Get-ClusterNode | Where-Object { $_.Name -ne $Computer }

[string] $OtherNode = $ClusterNodes

## Get all the Cluster Resources in the Cluster on this node

$ClusterGroups = Get-ClusterNode $Computer | Get-ClusterGroup | ?{ $_ | Get-ClusterResource }

foreach ( $Clustergroup in $ClusterGroups )
	{
		$O = 0
		## get the preferred owner of the clusterresource
		$colItems = Get-ClusterOwnerNode -Group $ClusterGroup


		[string]$strONodes = $colItems.OwnerNodes

			foreach ($ONode in $colItems.OwnerNodes)
			{
			$O++
			}

			## If there is more then one Preferred Owner, do nothing
			if ($O -gt 1)
			{
			$OutputData = "$colItems.ClusterGroup has multiple preffered nodes - " + $OutputData
			$GroupsOnNode++
			}
			## If there is only one preferred owner, grab the node name
			elseif ($O -eq 1)
			{
			[string]$pf = $colItems.OwnerNodes -Replace " ", ""
			}

		[string]$currentGroup = $ClusterGroup
		$Currentowner = Get-ClusterGroup -Name $currentGroup
		$Currentowner = $Currentowner.ownernode
		[string]$strCurrentOwner = $Currentowner

		## If the Current owner is the preferred owner, do nothing
	
		if ($strCurrentOwner -eq $pf) 
		{
		$OutputData = "$ClusterGroup is on its preferred owner $pf - " + $OutputData
		$GroupsOnNode++
		}

		## If the Current owner is not the preferred owner, record the error
		if ( $strCurrentOwner -ne $pf )
		{
		$OutputData = "$ClusterGroup is on $CurrentOwner but should be on $pf - " + $OutputData
		$ErrorsDetected++
		$GroupsOnNode++
		}
}

	if ($ErrorsDetected -ge 1)
	{	
	$exitstatus = 2
	$FinalOutput = "CRITICAL: $OutputData | 'Cluster Groups on This Node'=$GroupsOnNode;0;0"
	}
	if ($errorsDetected -eq 0)
	{
	$exitstatus = 0
	$FinalOutput = "OK: $OutputData | 'Cluster Groups on This Node'=$GroupsOnNode;0;0"
	}
write-host "$FinalOutput"
exit $exitstatus