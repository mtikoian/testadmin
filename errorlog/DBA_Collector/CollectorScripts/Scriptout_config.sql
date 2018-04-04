SET NOCOUNT ON;
USE master
GO

 

CREATE TABLE #SQLSrvValues
(
 [name] [varchar](48) NOT NULL,
 [description] [varchar](256) NOT NULL,
 [value] [sql_variant] NOT NULL,
 [minimum] [sql_variant] NOT NULL,
 [maximum] [sql_variant] NOT NULL,
 [value_in_use] [sql_variant] NOT NULL,
) ON [PRIMARY]

GO

 

EXEC ('INSERT INTO #SQLSrvValues
 ([name]
 ,[description]
 ,[value] 
 ,[minimum] 
 ,[maximum] 
 ,[value_in_use])
 SELECT 
 [name]
 ,[description]
 ,[value] 
 ,[minimum] 
 ,[maximum] 
 ,[value_in_use]
 FROM master.sys.configurations')

PRINT ''
PRINT '-- Execute code below to reconfigure SQL server'
PRINT 'USE MASTER'
PRINT 'GO'

 

DECLARE @ValueName VARCHAR (48)
 ,@CurValue SQL_VARIANT

DECLARE SQLValues CURSOR FOR SELECT [name], [value_in_use] FROM #SQLSrvValues
OPEN SQLValues
 FETCH NEXT FROM SQLValues INTO @ValueName, @CurValue
 
 WHILE @@FETCH_STATUS = 0
 BEGIN
 
 /* Creates T-SQL code to make the changes to the SQL server setting*/ 
 PRINT 'EXEC sp_configure '''+ @Valuename +''', '''+CONVERT(VARCHAR(20),@CurValue)+ ''';'
 PRINT 'RECONFIGURE WITH OVERRIDE;'
 
 
FETCH NEXT FROM SQLValues INTO @ValueName, @CurValue
END

CLOSE SQLValues
DEALLOCATE SQLValues
DROP TABLE #SQLSrvValues
GO
/*******************SQL2000************************/

--SELECT  Name, c.Value, low AS [minimum], high AS [Maximum],
--        master.dbo.syscurconfigs.value AS [Value In Use],
--        c.comment AS [Description]
--FROM    master.dbo.spt_values v
--        INNER JOIN master.dbo.sysconfigures c ON number = c.config
--        INNER JOIN master.dbo.syscurconfigs ON number = master.dbo.syscurconfigs.config
--WHERE   type = 'C'
--ORDER BY LOWER(name)