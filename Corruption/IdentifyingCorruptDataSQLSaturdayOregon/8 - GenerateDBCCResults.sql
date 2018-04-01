USE master;
GO

SET NOCOUNT ON;
 
/* Drop temp table if it exists */

TRUNCATE TABLE CorruptDemoDB..DBCCResults;
 
IF OBJECT_ID('tempdb..#databases') IS NOT NULL
BEGIN
 
    DROP TABLE #databases
 
END
 
/* Declare local variables and create temp tables */
DECLARE @sqlstr NVARCHAR(2000);
DECLARE @dbname SYSNAME;
DECLARE @loopcount TINYINT = 1;
DECLARE @looplimit TINYINT;
 
CREATE TABLE #databases
(dbname SYSNAME);
 
/* This will generate statements for all user databases 
   Change the WHERE clause to limit or expand the results */
INSERT INTO #databases
SELECT name FROM master.sys.databases
WHERE name = 'CorruptDemoDB';
 
/* Get the loop limit */
SELECT @looplimit = @@ROWCOUNT;
 
/* Build the DBCC CHECKDB statement for each database 
   This code will print each statement
   Replace the PRINT statement with EXEC sp_executesql @sql str to execute the code */
WHILE @loopcount <= @looplimit
BEGIN
 
    SELECT TOP 1 @dbname = dbname FROM #databases;
 
    SELECT @sqlstr = 'INSERT INTO CorruptDemoDB..DBCCResults EXEC(''DBCC CHECKDB(' + @dbname + ') WITH TABLERESULTS, NO_INFOMSGS'')';

	--PRINT @sqlstr;
 
    EXEC sp_executesql @sqlstr;
 
    SELECT @loopcount += 1;
 
    DELETE FROM #databases WHERE dbname = @dbname;
 
END

SELECT * FROM CorruptDemoDB..DBCCResults;