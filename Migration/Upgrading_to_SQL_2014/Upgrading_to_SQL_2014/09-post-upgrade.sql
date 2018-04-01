-----------------------------------------------------
-- Post-upgrade steps on SQL Server 2014           --
-----------------------------------------------------
-- Connect to SQL2014\MSSQL2014INST01
-- Change comptability level to 120 (2014)
ALTER DATABASE [Northwind]

SET COMPATIBILITY_LEVEL = 120;
GO

-- Change DB Owner
USE [Northwind]
GO

EXEC dbo.sp_changedbowner @loginame = N'systemadministrator'
	,@map = false;
GO

-- Run CHECKDB 
DBCC CHECKDB (Northwind)
WITH DATA_PURITY
	,ALL_ERRORMSGS
	,NO_INFOMSGS;
GO

-- Run UPDATEUSAGE
DBCC UPDATEUSAGE (Northwind);
GO

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

-- Update indexes on all tables
EXECUTE [dbo].[IndexOptimize] @Databases = 'Northwind'
	,@FragmentationLow = 'INDEX_REBUILD_OFFLINE'
	,@FragmentationMedium = 'INDEX_REBUILD_OFFLINE'
	,@FragmentationHigh = 'INDEX_REBUILD_OFFLINE'
	,@FragmentationLevel1 = 5
	,@FragmentationLevel2 = 30
	,@PageCountLevel = 1

-- Change recovery model to FULL
ALTER DATABASE [Northwind]

SET RECOVERY FULL;
GO

-- Perform full backup
BACKUP DATABASE [Northwind] TO DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\Northwind-2014.bak'
WITH CHECKSUM
	,STATS = 10;
GO


