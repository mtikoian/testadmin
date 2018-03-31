USE master;
GO
-- Create the Event Session
IF EXISTS ( SELECT *
				FROM sys.server_event_sessions
				WHERE name = 'TreeHuggerCPU' )
	DROP EVENT SESSION TreeHuggerCPU 
    ON SERVER;
GO

EXECUTE xp_create_subdir 'C:\Database\XE';
GO

CREATE EVENT SESSION TreeHuggerCPU ON SERVER
ADD EVENT sqlserver.perfobject_processor (
	ACTION ( sqlos.cpu_id, sqlos.numa_node_id, package0.collect_cpu_cycle_time,
	sqlserver.server_instance_name,
	package0.collect_system_time ) --WHERE sqlserver.client_app_name <> 'Microsoft SQL Server Management Studio - Transact-SQL IntelliSense'
	)
ADD TARGET package0.event_file ( SET filename = N'C:\Database\XE\TreeHuggerCPU.xel' );

/* start the session */
ALTER EVENT SESSION TreeHuggerCPU 
ON SERVER 
STATE = START;
GO

USE master;
GO

SELECT event_data.value('(event/@name)[1]', 'varchar(50)') AS event_name
		, event_data.value('(event/@timestamp)[1]', 'varchar(50)') AS [TIMESTAMP]
		, event_data.value('(event/action[@name="server_instance_name"]/value)[1]',
							'varchar(max)') AS ServerInstance
		, event_data.value('(event/action[@name="numa_node_id"]/value)[1]',
							'varchar(max)') AS NUMANodeID
		, event_data.value('(event/action[@name="cpu_id"]/value)[1]',
							'varchar(max)') AS CPUID
		, event_data.value('(event/action[@name="collect_cpu_cycle_time"]/value)[1]',
							'varchar(max)') AS CPUCycleTime
		, event_data.value('(event/action[@name="collect_system_time"]/value)[1]',
							'varchar(max)') AS SystemTime
		, event_data.value('(event/data[@name="parking_status"]/value)[1]',
							'varchar(max)') AS ProcessorParkStatus
		, event_data.value('(event/data[@name="processor_frequency"]/value)[1]',
							'varchar(max)') AS ProcessorFrequency
		, event_data.value('(event/data[@name="percent_maximum_frequency"]/value)[1]',
							'varchar(max)') AS PercentMaxProcessorFrequency
		, event_data.value('(event/data[@name="processor_state_flags"]/value)[1]',
							'varchar(max)') AS ProcessorState
		, event_data.value('(event/data[@name="instance_name"]/value)[1]',
							'varchar(max)') AS CPUInstance
	FROM ( SELECT CONVERT(XML, t2.event_data) AS event_data
				FROM ( SELECT target_data = CONVERT(XML, target_data)
							FROM sys.dm_xe_session_targets t
								INNER JOIN sys.dm_xe_sessions s
									ON t.event_session_address = s.address
							WHERE t.target_name = 'event_file'
								AND s.name = 'TreeHuggerCPU'
						) cte1
					CROSS APPLY cte1.target_data.nodes('//EventFileTarget/File') FileEvent ( FileTarget )
					CROSS APPLY sys.fn_xe_file_target_read_file(FileEvent.FileTarget.value('@name',
																'varchar(1000)'),
																NULL, NULL, NULL) t2
			) AS evts ( event_data )
	ORDER BY SystemTime;

/* stop the session */
ALTER EVENT SESSION TreeHuggerCPU 
ON SERVER 
STATE = STOP;
GO

/* tests */
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO
EXEC sp_configure 'xp_cmdshell', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO

 --max power saving
EXECUTE xp_cmdshell 'powercfg -SETACTIVE SCHEME_MAX';
GO
--now look at the XE
 --balanced power saving
EXECUTE xp_cmdshell 'powercfg -SETACTIVE SCHEME_BALANCED';
--now look at the XE
--min power saving
EXECUTE xp_cmdshell 'powercfg -SETACTIVE SCHEME_MIN'; 
--now look at the XE