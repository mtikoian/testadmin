-----------------------------------------------------
-- Backup of Notrhwind db on SQL 2000              --
-----------------------------------------------------

-- Perform backup
BACKUP 
	DATABASE [Northwind] 
TO 
	DISK = N'D:\Microsoft SQL Server\MSSQL2000INST01\MSSQL$MSSQL2000INST01\BACKUP\Northwind.bak' 
WITH 
	FORMAT, 
	STATS = 10;
GO


