-----------------------------------------------------
-- Restore of Notrhwind db on SQL Server 2014      --
-----------------------------------------------------
-- Connect to SQL2014\MSSQL2014INST01
RESTORE DATABASE [Northwind]
FROM DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\Northwind.bak'
WITH FILE = 1
	,MOVE N'Northwind' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\northwnd.mdf'
	,MOVE N'Northwind_log' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\northwnd.ldf'
	,NORECOVERY
	,NOUNLOAD
	,STATS = 5;

-- ERROR!
-- Use backup creatd on 2005
RESTORE DATABASE [Northwind]
FROM DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\Northwind-2005.bak'
WITH FILE = 1
	,MOVE N'Northwind' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\northwnd.mdf'
	,MOVE N'Northwind_log' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\northwnd.ldf'
	,RECOVERY
	,NOUNLOAD
	,STATS = 5;
