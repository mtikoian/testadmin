BACKUP DATABASE [CorruptDemoDB] 
TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\CorruptDemoDB.bak' 
WITH NOFORMAT, NOINIT,  NAME = N'CorruptDemoDB-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

BACKUP DATABASE [CorruptDemoDB] 
TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\CorruptDemoDBCorrupted.bak' 
WITH NOFORMAT, NOINIT,  NAME = N'CorruptDemoDB-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

