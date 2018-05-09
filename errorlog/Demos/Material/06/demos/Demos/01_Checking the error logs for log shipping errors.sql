-- Checking the error logs for log shipping errors

-- Confirm server name
SELECT @@SERVERNAME AS [Server Name];

SET NOCOUNT ON;

-- Return any log shipping jobs on this instance
SELECT [name], [enabled], [description] 
FROM msdb.dbo.sysjobs 
WHERE category_id = 6;


-- Return Agent job history error messages 
SELECT * 
FROM msdb.dbo.sysjobhistory
WHERE [message] LIKE N'%Operating system error%';

-- Return log shipping related error messages
SELECT error, severity, [description] 
FROM msdb.sys.sysmessages 
WHERE [description] LIKE N'%shipping%' 
AND msglangid = 1033;

-- Example error messages
-- The log shipping primary database %s.%s has backup threshold of %d minutes and has not performed a backup log operation for %d minutes. Check agent log and logshipping monitor information.
-- The log shipping secondary database %s.%s has restore threshold of %d minutes and is out of sync. No restore was performed for %d minutes. Restored latency is %d minutes. Check agent log and logshipping monitor information.

-- Look for text in the SQL Server error log
EXEC sys.xp_readerrorlog 0, 1, N'The log shipping primary database', Null;
EXEC sys.xp_readerrorlog 1, 1, N'The log shipping primary database', Null;
EXEC sys.xp_readerrorlog 2, 1, N'The log shipping primary database', Null;
EXEC sys.xp_readerrorlog 3, 1, N'The log shipping primary database', Null;
EXEC sys.xp_readerrorlog 4, 1, N'The log shipping primary database', Null;
EXEC sys.xp_readerrorlog 5, 1, N'The log shipping primary database', Null;

EXEC sys.xp_readerrorlog 0, 1, N'The log shipping secondary database', Null;
EXEC sys.xp_readerrorlog 1, 1, N'The log shipping secondary database', Null;
EXEC sys.xp_readerrorlog 2, 1, N'The log shipping secondary database', Null;
EXEC sys.xp_readerrorlog 3, 1, N'The log shipping secondary database', Null;
EXEC sys.xp_readerrorlog 4, 1, N'The log shipping secondary database', Null;
EXEC sys.xp_readerrorlog 5, 1, N'The log shipping secondary database', Null;




