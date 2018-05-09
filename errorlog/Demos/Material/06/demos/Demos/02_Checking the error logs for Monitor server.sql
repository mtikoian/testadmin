-- Checking the error logs for Monitor server

-- Confirm server name
SELECT @@SERVERNAME AS [Server Name];

-- Return any log shipping jobs on this instance
SELECT [name], [enabled], [description] 
FROM msdb.dbo.sysjobs 
WHERE category_id = 6;


-- Return log shipping related error messages
SELECT error, severity, [description] 
FROM msdb.sys.sysmessages 
WHERE [description] LIKE N'%shipping%' 
AND msglangid = 1033;


-- Return job history error messages 
SELECT * 
FROM msdb.dbo.sysjobhistory
WHERE [message] LIKE N'%Operating system error%';



