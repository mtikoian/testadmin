-- missing both priamry and TLog




















-- Restore from backup ;)
RESTORE DATABASE [AdventureWorks2014_Demo06] 
FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014-FullRecovery.bak' 
WITH  FILE = 1,  
MOVE N'AdventureWorks2014_Default' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo06_PRIMARY.mdf',  
MOVE N'AdventureWorks2014_Data' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo06_Data.ndf',  
MOVE N'AdventureWorks2014_Index' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo06_Index.ndf',  
MOVE N'AdventureWorks2014_RO' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Demo06_RO.ndf',  
MOVE N'AdventureWorks2014_TLog' 
TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\AdventureWorks2014_Demo06_TLog.ldf',  NOUNLOAD,  STATS = 5
GO

BACKUP DATABASE [AdventureWorks2014_Demo06] TO  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo06_01.bak' WITH FORMAT, INIT,  NAME = N'AdventureWorks2014_Demo06-Full Database Backup', COMPRESSION,  STATS = 10
GO

BACKUP LOG [AdventureWorks2014_Demo06] TO  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014_Demo06-TLog_01.bak' WITH INIT
