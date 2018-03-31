#   <Group name="AG_TEST_2" backupDirectory="\\Shared\Backup\Directory" HADREndpointName="HadrEndPoint" HADREndpointPort="5022">
#       <Primary name="PrimaryServer_2_Site_1\Instance"/>
#        <Secondaries>
#            <Server secondary="SecondaryServer1Site1\Instance" replicationMode="SynchronousCommit" failoverMode="Automatic"/>
#            <Server secondary="SecondaryServer1Site2\Instance" replicationMode="AsynchronousCommit" failoverMode="Manual"/>
#        </Secondaries>
#        <SqlAgDatabases> 
#           <DB name="AG_TEST_1_DB"/>
#           <DB name="AG_TEST_2_DB"/>
#           <DB name="AG_TEST_3_DB"/>
#        </SqlAgDatabases>
#        <AGListener name="AG_Test_2_Listener" port="1434">
#            <IpAddress ipaddress="10.10.1.xxx" subnetmask="255.255.255.0" />
#            <IpAddress ipaddress="10.10.2.xxx" subnetmask="255.255.255.0" />
#        </AGListener>
#    </Group>

$configFile =  "C:\APresentation\SQLSat382PowershellGems\6_ReadXMLINI\AOAG.xml"

## Read in xml config file, converted to XML data type
$xml = [xml](Get-Content $configFile)

## Iterate through each AG Group node.
foreach($group in $xml.AvailabilityGroups.Group)
{
  # group name
    $availabilityGroupName = $group.name
	Write-Host "AG Group Name -> $availabilityGroupName"
	
  #Pimary 
    $availabilityGroupPrimaryReplica = $group.Primary.name
	Write-Host "-> Primary -> $availabilityGroupPrimaryReplica"

  #Get secondary SQL Servers in AG Group
    foreach ($server in $group.Secondaries.Server)
	{
        $SecondaryReplicaServer = $server.secondary
		$replicationmode = $server.replicationMode
        Write-host "---> Replica $SecondaryReplicaServer - RepMode -> $replicationmode"
    }
	  
  #Get DBs for AG
    foreach ($db in $group.SqlAgDatabases.DB)
	{
        $DBName = $db.name
        Write-host "---> AG Database -> $DBName"
    } 
    

	## Listener Config Ino
	$availabilityGroupListener = $group.AGListener.name
    $availabilityGroupListenerPort = $group.AGListener.port
	Write-Host "--> Listener Name -> $availabilityGroupListener | Port $availabilityGroupListenerPort"
	
	## Listener Ip Address
	foreach ($Listener in $group.AGListener.IpAddress)
	{
        $ListenerIPAddress = $Listener.ipaddress
        Write-host "---> Listener IP Address -> $ListenerIPAddress"
    }
	
	Write-Host " "
	
}	