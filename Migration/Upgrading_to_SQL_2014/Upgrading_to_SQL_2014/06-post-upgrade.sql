-----------------------------------------------------
-- Post-upgrade steps on SQL Server 2005           --
-----------------------------------------------------
-- Change comptability level to 90 (2005)
EXEC dbo.sp_dbcmptlevel @dbname = N'Northwind'
	,@new_cmptlevel = 90;
GO

-- Change DB Owner
USE [Northwind]
GO

EXEC dbo.sp_changedbowner @loginame = N'systemadministrator'
	,@map = false;
GO

-- Best practise is to set db_owner to sa
-- of course rename sa to some other username and disable it ;)
-- Enable checksum option
USE [master]
GO

ALTER DATABASE [Northwind]

SET PAGE_VERIFY CHECKSUM
WITH NO_WAIT;
GO

-- Run CHECKDB 
DBCC CHECKDB (Northwind)
WITH DATA_PURITY
	,-- Causes DBCC CHECKDB to check the database for column values that are not valid or out-of-range
	ALL_ERRORMSGS
	,-- Displays all reported errors per object. All error messages are displayed by default.
	NO_INFOMSGS;-- Suppresses all informational messages.
GO

-- Run UPDATEUSAGE
DBCC UPDATEUSAGE (Northwind);
GO

-- Reports and corrects pages and row count inaccuracies in the catalog views. These inaccuracies may cause incorrect space usage reports returned by the sp_spaceused system stored procedure.
-- Change recovery model to FULL
ALTER DATABASE [Northwind]

SET RECOVERY FULL;
GO

-- Perform full backup
BACKUP DATABASE [Northwind] TO DISK = N'D:\Microsoft SQL Server\MSSQL2005INST01\MSSQL.1\MSSQL\Backup\Northwind-2005.bak'
WITH CHECKSUM
	,STATS = 10;
GO

-- Copy backup to SQL 2014
-- Refresh all views
USE [Northwind];
GO

DECLARE @viewName AS VARCHAR(255)

DECLARE listOfViews CURSOR
FOR
SELECT '[' + SCHEMA_NAME(uid) + '].[' + NAME + ']'
FROM sysobjects
WHERE xtype = 'V'

OPEN listOfViews

FETCH NEXT
FROM listOfViews
INTO @viewName

WHILE (@@FETCH_STATUS <> - 1)
BEGIN
	FETCH NEXT
	FROM listOfViews
	INTO @viewName

	BEGIN TRY
		EXEC sp_refreshview @viewName

		PRINT @viewName + ' refreshed OK'
	END TRY

	BEGIN CATCH
		PRINT @viewName + ' refresh failed'
	END CATCH
END

CLOSE listOfViews

DEALLOCATE listOfViews
