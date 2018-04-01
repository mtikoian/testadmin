/*****************************************************************************************************

 Presented by: Miguel E Cebollero
 SoFlorida 2015 SQL Saturday #379
 AdventureWorks2014 Demo Database available at: https://msftdbprodsamples.codeplex.com/releases/view/125550

 *****************************************************************************************************/

:setvar DBName AdventureWorks2014
:setvar BackupDirFile C:\SQLSaturday\2015\SQLSat379\AdventureWorks2014.bak
:setvar RestoreDirData C:\SQLSaturday\2015\SQLSat379\DATA
:setvar RestoreDirLog C:\SQLSaturday\2015\SQLSat379\LOG

USE [master]
GO
SET NOCOUNT ON
GO

IF EXISTS (SELECT * FROM sys.databases where name='$(DBName)')
	DROP DATABASE [$(DBName)];
GO

-- Restore AdventureWorks2014
RESTORE DATABASE [$(DBName)] 
  FROM  DISK = N'$(BackupDirFile)' 
  WITH  FILE = 1
  ,  MOVE N'AdventureWorks2014_Data' TO N'$(RestoreDirData)\AdventureWorks2014_Data.mdf'
  ,  MOVE N'AdventureWorks2014_Log' TO N'$(RestoreDirLog)\AdventureWorks2014_Log.ldf'
  ,  NOUNLOAD,  REPLACE,  STATS = 5;
GO

ALTER AUTHORIZATION ON DATABASE::[$(DBName)] TO [SA];
GO

ALTER DATABASE [$(DBName)]
SET MULTI_USER 
GO

USE AdventureWorks2014;
GO
 UPDATE STATISTICS [Person].[Address];
 GO