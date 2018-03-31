SELECT replica_server_name
	,DB_NAME(database_id) [Database]
	,synchronization_state_desc
	,synchronization_health_desc
	,database_state_desc
	,is_suspended
	,suspend_reason_desc
FROM sys.dm_hadr_database_replica_states drs
INNER JOIN sys.availability_replicas ar ON drs.replica_id = ar.replica_id
WHERE synchronization_state_desc != 'SYNCHRONIZED'
	OR synchronization_health_desc != 'HEALTHY'
	OR (database_state_desc IS NOT NULL	AND database_state_desc != 'ONLINE')
	OR is_suspended != 0
