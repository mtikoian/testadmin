-----------------------------------------------------
-- Usage of mirroring for upgrade                 --
-- from SQL Server 2005 to SQL Server 2014         --
-----------------------------------------------------
-- Connect to SQL2014\MSSQL2014INST01
-- Restore backup of AdventureWorks database
RESTORE DATABASE [AdventureWorks]
FROM DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks.bak'
WITH FILE = 1
	,MOVE N'AdventureWorks_Data' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks_Data.mdf'
	,MOVE N'AdventureWorks_Log' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\AdventureWorks_Log.ldf'
	,NORECOVERY
	,STATS = 10;
GO

RESTORE LOG [AdventureWorks]
FROM DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks-Log.bak'
WITH FILE = 1
	,NORECOVERY
	,STATS = 10
GO

-- Use GUI to configure Mirroring from SQL 2005 to SQL 2014
44444

-- Connect to SQL2K5\MSSQL2005INST01
-- Failover to SQL 2014
ALTER DATABASE [AdventureWorks]

SET PARTNER FAILOVER;
	-- Show SQL Server Log
