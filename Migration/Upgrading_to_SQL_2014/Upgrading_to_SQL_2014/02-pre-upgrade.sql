-----------------------------------------------------
-- Pre-upgrade steps on SQL 2000                   --
-----------------------------------------------------
-- Run Upgrade Advisor and review report
-- Connect to SQL2k5\MSSQL2000INST01
-- Run CHECKDB 
DBCC CHECKDB (Northwind)
WITH ALL_ERRORMSGS
	,-- Displays all reported errors per object. All error messages are displayed by default.
	NO_INFOMSGS;-- Suppresses all informational messages.

-- Check and set autogrowth of database and log files
USE [Northwind]
GO

SELECT NAME
	,fileid
	,filename
	,filegroup = filegroup_name(groupid)
	,'size' = convert(NVARCHAR(15), convert(BIGINT, size) * 8) + N' KB'
	,'maxsize' = (
		CASE maxsize
			WHEN - 1
				THEN N'Unlimited'
			ELSE convert(NVARCHAR(15), convert(BIGINT, maxsize) * 8) + N' KB'
			END
		)
	,'growth' = (
		CASE STATUS & 0x100000
			WHEN 0x100000
				THEN convert(NVARCHAR(15), growth) + N'%'
			ELSE convert(NVARCHAR(15), convert(BIGINT, growth) * 8) + N' KB'
			END
		)
	,'usage' = (
		CASE STATUS & 0x40
			WHEN 0x40
				THEN 'log only'
			ELSE 'data only'
			END
		)
FROM sysfiles;

-- Enable auto update stats
ALTER DATABASE [Northwind]

SET AUTO_UPDATE_STATISTICS ON
WITH NO_WAIT;
GO


