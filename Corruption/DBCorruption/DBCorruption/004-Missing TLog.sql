-- Missing TLog


USE [AdventureWorks2014_Demo04]
GO
SELECT * FROM [AdventureWorks2014_Demo04].[Sales].[SalesOrderDetail] 







ALTER DATABASE [AdventureWorks2014_Demo04] 
SET EMERGENCY









ALTER DATABASE [AdventureWorks2014_Demo04] SET SINGLE_USER WITH ROLLBACK IMMEDIATE











DBCC CHECKDB ('AdventureWorks2014_Demo04', REPAIR_ALLOW_DATA_LOSS)








ALTER DATABASE [AdventureWorks2014_Demo04] SET MULTI_USER

USE [AdventureWorks2014_Demo04]
GO
SELECT * FROM [AdventureWorks2014_Demo04].[Sales].[SalesOrderDetail] 


