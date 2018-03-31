-- check primary
SELECT primary_replica
	,primary_recovery_health_desc
	,secondary_recovery_health_desc
	,synchronization_health_desc
FROM sys.dm_hadr_availability_group_states
WHERE primary_replica != 'PRIMARY-DB01' 
	OR primary_recovery_health_desc != 'ONLINE'
	OR synchronization_health_desc != 'HEALTHY'

