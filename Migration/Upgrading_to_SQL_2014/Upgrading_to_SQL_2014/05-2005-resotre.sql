-----------------------------------------------------
-- Restore of Notrhwind db on SQL Server 2005      --
-----------------------------------------------------


-- Connect to SQL2k5\MSSQL2005INST01

RESTORE 
	DATABASE [Northwind] 
FROM 
	DISK = N'D:\Microsoft SQL Server\MSSQL2005INST01\MSSQL.1\MSSQL\Backup\Northwind.bak' 
WITH  
	FILE = 1,  
MOVE N'Northwind' 
	TO N'D:\Microsoft SQL Server\MSSQL2005INST01\MSSQL.1\MSSQL\Data\Northwind.mdf',  
MOVE N'Northwind_log' 
	TO N'D:\Microsoft SQL Server\MSSQL2005INST01\MSSQL.1\MSSQL\Data\Northwind.ldf',  
	NOUNLOAD,  
	STATS = 5;
GO

-- Check output for lines with information about version upgrade