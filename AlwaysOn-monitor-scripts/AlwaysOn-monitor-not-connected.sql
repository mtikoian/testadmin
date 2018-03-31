
-- check non-connected
select replica_server_name, 
	is_local, role_desc, operational_state_desc, connected_state_desc,  
	recovery_health_desc, synchronization_health_desc, last_connect_error_description,
	last_connect_error_timestamp
from sys.dm_hadr_availability_replica_states ars
inner join sys.availability_replicas ar on ars.replica_id=ar.replica_id
where connected_state_desc != 'CONNECTED'
