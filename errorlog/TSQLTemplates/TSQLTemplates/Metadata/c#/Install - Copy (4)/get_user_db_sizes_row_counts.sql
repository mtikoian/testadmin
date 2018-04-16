--Date: 8/10/2011
--Written by: Tom Sawyer
--Purpose: document success of db restore by providing row counts on top 5 tables (with rows > 0)
SET NOCOUNT ON
 
PRINT 'Date\Time: '+cast(getdate() as varchar(50))
EXEC master..sp_MSForeachdb '
USE [?]
IF ''?'' not in (''master'',''model'',''msdb'',''msdb'',''tempdb'',''pubs'',''northwind'',''pubs'',''AdventureWorks'',''AdventureWorks_DW'')
BEGIN
    PRINT ''Database: ''+db_name()
	PRINT ''Database Size Info:''

	CREATE TABLE #FileStats
	( FileID       SmallInt
	, FileGroup    SmallInt
	, TotalExtents INT
	, UsedExtents  INT
	, Name         VarChar(256)  
	, FileName     VarChar(520) 
	)
	INSERT #FileStats EXEC (''DBCC ShowFileStats with NO_INFOMSGS'')


	SELECT sum((CAST(usedExtents AS bigint) * 65536)/1048576) AS ''Used(MB)'' , 
	sum((CAST((TotalExtents - UsedExtents) AS bigint) * 65536)/1048576) AS ''Unused(MB)'' , 
	sum((CAST(TotalExtents AS bigint) * 65536) / 1048576) AS ''Total(MB)''
	FROM #FileStats 

	DROP TABLE #FileStats
	
	--get row counts on top 5 user tables (that have > 0 rows) 

	SELECT top (5) s.name+''.''+o.name+'' Rows:''+cast(p.row_count as varchar(50)) as ''Top 5 User Tables with row count > 0:''
	from sys.objects o, sys.dm_db_partition_stats p, sys.schemas s 
	where o.object_id = p.object_id and o.schema_id=s.schema_id and o.type = ''U'' and p.row_count > 0 and p.index_id = 1 
	order by o.name
END
'
