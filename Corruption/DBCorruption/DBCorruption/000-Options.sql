USE [master]
RESTORE DATABASE [AdventureWorks2014] FROM  DISK = N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Backup\AdventureWorks2014.bak' WITH  FILE = 1,  MOVE N'AdventureWorks2014_Data' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\Data\AdventureWorks2014_Data.mdf',  MOVE N'AdventureWorks2014_Log' TO N'D:\Microsoft SQL Server\MSSQL12.MSSQL2014INST01\MSSQL\TLog\AdventureWorks2014_Log.ldf',  NOUNLOAD,  STATS = 5
GO


-- Show where checksum options can be set



USE [master]
GO
ALTER DATABASE [AdventureWorks2014] SET PAGE_VERIFY CHECKSUM  WITH NO_WAIT
GO




SELECT * FROM msdb.dbo.suspect_pages

-- The type of error; one of:
--   1 = An 823 error that causes a suspect page (such as a disk error) or an 824 error other than a bad checksum or a torn page (such as a bad page ID).
--   2 = Bad checksum.
--   3 = Torn page.
--   4 = Restored (page was restored after it was marked bad).
--   5 = Repaired (DBCC repaired the page).
--   7 = Deallocated by DBCC.



DBCC 
	CHECKDB (AdventureWorks2014) 
WITH 
	DATA_PURITY,  -- Causes DBCC CHECKDB to check the database for column values that are not valid or out-of-range
	ALL_ERRORMSGS, -- Displays all reported errors per object. All error messages are displayed by default.
	NO_INFOMSGS ; -- Suppresses all informational messages.






--Cleanup
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'AdventureWorks2014'
GO
USE [master]
GO
ALTER DATABASE [AdventureWorks2014] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
DROP DATABASE [AdventureWorks2014]
GO