/*============================================================================
  File:     2a_DMVs.sql

  SQL Server Versions: 2012 onwards
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2014, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

/*
	What packages exist, from what module are they loaded?
	Packages are top level containers of metadata for the other objects that exist inside of XE  
	contain a combination of events, actions, targets, maps, predicates and types
*/
SELECT [p].[name], [p].[description], [m].[name]
FROM [sys].[dm_xe_packages] [p]
JOIN [sys].[dm_os_loaded_modules] [m] on [p].[module_address] = [m].[base_address];



/*
	What events can I use?
	An event corresponds to a specific point in code where something	
	of interest occurs inside the Database Engine
*/
SELECT [name], [object_type], [description]
FROM [sys].[dm_xe_objects]
WHERE [object_type] = N'event'
ORDER BY [name];
GO


/*
	List the package associated with the event
*/
SELECT 
	[xo].[name], 
	[xo].[description], 
	[xp].[name] AS [package]
FROM [sys].[dm_xe_objects] [xo]
JOIN [sys].[dm_xe_packages] [xp]
	ON [xo].[package_guid] = [xp].[guid]
WHERE [xo].[object_type] = N'event'
ORDER BY [xo].[name];
GO


/*
	If we want to capture the sp_statement_completed event,
	what elements are part of the default payload?
	Note that in some cases, an element is optional (capabilities_desc)
*/
SELECT [object_name], [name], [column_id], [type_name], 
	[column_type], [capabilities_desc], [description]
FROM [sys].[dm_xe_object_columns]
WHERE [object_name] = N'sp_statement_completed'
AND [column_type] <> 'readonly';
GO

/*
	what actions can I add?
*/
SELECT 
	[xp].[name] AS [Package],
	[xo].[name] AS [Action],
	[xo].[description] AS [Description]
FROM [sys].[dm_xe_packages] AS [xp]
JOIN [sys].[dm_xe_objects] AS [xo]
	ON [xp].[guid] = [xo].package_guid
WHERE ([xp].[capabilities] IS NULL OR [xp].[capabilities] & 1 = 0)
	AND ([xo].[capabilities] IS NULL OR [xo].[capabilities] & 1 = 0)
	AND [xo].[object_type] = 'action';

/*
	If we want to capture information about waits,
	what elements are part of the default payload?
	Note that wait_type is part of the default payload,
	and it's [type_name] is wait_types.  What are the wait_types?
*/
SELECT [object_name], [name], [column_id], [type_name], 
	[column_type], [capabilities_desc], [description]
FROM [sys].[dm_xe_object_columns]
WHERE [object_name] = N'wait_info'
AND [column_type] <> 'readonly';
GO

/*
	What are the 'wait_types' maps?
*/
SELECT [xmv].[name], [xmv].[map_key], [xmv].[map_value]
	FROM sys.dm_xe_map_values [xmv]
	JOIN sys.dm_xe_packages [xp]
		ON [xmv].[object_package_guid] = [xp].[guid]
	WHERE [xmv].[name] = N'wait_types';
GO


/*
	If we want to capture the lock_escalation event,
	what elements are part of the default payload?
	Note that for the mode element, the type_name is lock_mode
*/
SELECT [object_name], [name], [column_id], [type_name], 
	[column_type], [capabilities_desc], [description]
FROM [sys].[dm_xe_object_columns]
WHERE [object_name] = N'lock_escalation'
AND [column_type] <> 'readonly';
GO

/*
	What are the 'lock_mode' maps?
*/
SELECT [xmv].[name], [xmv].[map_key], [xmv].[map_value]
	FROM sys.dm_xe_map_values [xmv]
	JOIN sys.dm_xe_packages [xp]
		ON [xmv].[object_package_guid] = [xp].[guid]
	WHERE [xmv].[name] = N'lock_mode';
GO



/*
	What global predicates are available?
*/
SELECT 
    [p].[name] AS [package_name],
    [o].[name] AS [predicate_name],
    [o].[description]
FROM [sys].[dm_xe_packages] AS [p]
INNER JOIN [sys].[dm_xe_objects] AS [o]
    ON [p].[guid] = [o].[package_guid]
WHERE ([p].[capabilities] IS NULL OR [p].[capabilities] & 1 = 0)
  AND [o].[object_type] = 'pred_source'



/*
	Create event session for wait_info event
	Scripted version below, note the wait_types
*/


CREATE EVENT SESSION [WaitStatsInfo] 
ON SERVER 
ADD EVENT sqlos.wait_info(
    WHERE ([wait_type]=(66))) 
ADD TARGET package0.ring_buffer
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,
MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO


/*
	clean up
*/
DROP EVENT SESSION [WaitStatsInfo] ON SERVER;




/*
	Drop the event session if it exists
*/
IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'Track_Queries')
	DROP EVENT SESSION [Track_Queries] ON SERVER;
GO


/*
	Create the event session
*/
CREATE EVENT SESSION [Track_Queries] 
	ON SERVER 
	ADD EVENT sqlserver.sp_statement_completed(SET collect_statement=(1)
		ACTION(sqlserver.client_app_name,sqlserver.database_id,sqlserver.session_id,sqlserver.session_nt_username)
		WHERE ([sqlserver].[is_system]=(0))) 	
	ADD TARGET package0.event_file(SET filename=N'C:\Temp\XEvents\Track_Queries.xel'),
	ADD TARGET package0.ring_buffer(SET max_events_limit=(10000),max_memory=(2048))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
GO

/*
	Start it
*/

/*
	run PS scripts
*/

/*
	look at buffer data
*/

/*
	stop the event session
*/

/*
	look at file output
*/
