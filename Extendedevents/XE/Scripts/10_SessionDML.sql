/* Script Source
http://msdn.microsoft.com/en-us/library/dd822788(v=sql.100).aspx
*/

IF EXISTS(SELECT * FROM sys.server_event_sessions 
	WHERE name='BufferManagerWatcher')
    DROP EVENT SESSION [BufferManagerWatcher] ON SERVER;
CREATE EVENT SESSION [BufferManagerWatcher]
ON SERVER
ADD EVENT sqlserver.buffer_manager_page_life_expectancy(
     WHERE (([package0].[less_than_equal_uint64]([count],(3000)))))
ADD TARGET package0.ring_buffer(
     SET max_memory=4096)
     
     
ALTER EVENT SESSION BufferManagerWatcher
ON SERVER
STATE=START
GO

ALTER EVENT SESSION BufferManagerWatcher
ON SERVER
STATE=STOP
GO

DROP EVENT SESSION BufferManagerWatcher
ON SERVER
GO