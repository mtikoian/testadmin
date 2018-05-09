-- Database Mirroring MetaData


-- Connect to Principal instance
:CONNECT LABDB01
-- Contains one row for each mirrored database on the instance of SQL Server 
SELECT DB_NAME(database_id) AS [Database Name], mirroring_state_desc, mirroring_role_desc, 
       mirroring_safety_level_desc, mirroring_partner_name, mirroring_partner_instance
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;


-- Connect to Mirror instance
:CONNECT LABDB04
-- Contains one row for each mirrored database on the instance of SQL Server
SELECT DB_NAME(database_id) AS [Database Name], mirroring_state_desc, mirroring_role_desc, 
       mirroring_safety_level_desc, mirroring_partner_name, mirroring_partner_instance
FROM sys.database_mirroring
WHERE mirroring_guid IS NOT NULL;

-- sys.database_mirroring (Transact-SQL)
-- http://bit.ly/2nab964 


-- Contains one row for the database mirroring endpoint of an instance of SQL Server
SELECT [name], protocol_desc, [type_desc], state_desc, role_desc, connection_auth_desc, 
       is_encryption_enabled, encryption_algorithm_desc
FROM sys.database_mirroring_endpoints;

-- sys.database_mirroring_endpoints (Transact-SQL)
-- http://bit.ly/2AczTQi



-- Connect to Principal instance
:CONNECT LABDB01
-- Returns a row for each connection established for database mirroring
SELECT connection_id, state_desc, connect_time, login_time, authentication_method, 
       login_state_desc, encryption_algorithm_desc, is_receive_flow_controlled, 
	   is_send_flow_controlled, last_activity_time
FROM sys.dm_db_mirroring_connections;

-- Database Mirroring - sys.dm_db_mirroring_connections
-- http://bit.ly/2Af4Wvi
