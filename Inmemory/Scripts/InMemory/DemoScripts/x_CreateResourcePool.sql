
/**********************************************************************************************
 
 Notes: Create resource pool and bind the database to it
		This is not necessary, but it ensures that you will leave resources available for the
		rest of the server.

 **********************************************************************************************/

:setvar DBName AdventureWorks2014
:setvar MaxMemPct 80
 
IF EXISTS (SELECT * FROM sys.resource_governor_resource_pools rp join sys.databases d on rp.pool_id=d.resource_pool_id WHERE d.name=N'$(DBName)')
BEGIN
	EXEC sp_xtp_unbind_db_resource_pool '$(DBName)'
END
GO

IF NOT EXISTS (SELECT * FROM sys.resource_governor_resource_pools WHERE name=N'Pool_$(DBName)')
BEGIN		
	CREATE RESOURCE POOL Pool_$(DBName) 
		WITH ( MAX_MEMORY_PERCENT = $(MaxMemPct) );
	ALTER RESOURCE GOVERNOR RECONFIGURE;
END
GO

EXEC sp_xtp_bind_db_resource_pool '$(DBName)', 'Pool_$(DBName)'
GO

ALTER DATABASE $(DBName) SET OFFLINE WITH ROLLBACK IMMEDIATE
GO
ALTER DATABASE $(DBName) SET ONLINE
GO

USE $(DBName)
GO

/********** For memory-optimized tables, automatically map all lower isolation levels (including READ COMMITTED) to SNAPSHOT ****************/

ALTER DATABASE CURRENT SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON
GO