USE DBAMAINT
GO


if exists (select ROUTINE_NAME from INFORMATION_SCHEMA.ROUTINES with (nolock)
             where ROUTINE_TYPE = 'PROCEDURE' 
             and ROUTINE_SCHEMA = 'dbo' 
             and ROUTINE_NAME = 'p_admDatabaseGrowthStats')
BEGIN
    drop procedure dbo.p_admDatabaseGrowthStats
    PRINT 'Procedure p_admDatabaseGrowthStats: Dropped'
END

go

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE DBO.p_admDatabaseGrowthStats
as
/****************************************************************************************
' Name		    : p_admDatabaseGrowthStats
' Author	    : Alfredo Giotti 
' Description	: this Stored Procedure gathers Database size statistics 
'               : and stores it in the DB_GROWTH_STATS table.
'               : It utilizes Linked server.
'
' Parameters	:
' Name				[I/O]	Description
' @strServerName :              [ I }   Servername
'---------------------------------------------------------------------------------------
' Return Value	:        
' Success:                      [ O ] 
'
' Revisions:
' --------------------------------------------------------------------------------------
' Ini |	Date	   |	Description 
' --------------------------------------------------------------------------------------
******************************************************************************************/
SET NOCOUNT ON
if OBJECT_ID('tempdb.dbo.##tmpIndexSpace') IS NOT NULL
 drop table ##tmpIndexSpace

DECLARE @statement varchar(8000),
        @dbname varchar(50),
        @strMessage varchar(128),
        @CURRENTRUNDATE datetime,
        @intDatabaseID integer,
        @USER varchar(20),
        @logsize real,
        @logspaceused real,
        @IndexStatement varchar(8000)

--initialize constants
SET @CURRENTRUNDATE = CONVERT(VARCHAR(10), GETDATE(), 101)
SET @USER = USER

--delete records if we are rerunning
DELETE FROM DB_GROWTH_STATS
WHERE Statdate = @CURRENTRUNDATE

CREATE TABLE ##tmpIndexSpace
(   databaseid  int not null,
	reserved	dec(15) null,
	data		dec(15) null,
	indexp		dec(15) null
)

CREATE TABLE ##tmpLOG ([DBName] varchar(50),
                      [LogSize] real,
                      [LogSpaceUsed] real,
                      [Status] int
                      )

CREATE TABLE ##tmpStats ([databaseid] int,
                         [dbname] sysname,
                         [totalextents] int,
                         [usedextents] int,
                         [logsize] real,
                         [logspaceused] real
                        )

CREATE TABLE ##tmpSFS ([fileid] int,
                       [filegroup] int,
                       [totalextents] int,
                       [usedextents] int,
                       [name] varchar(1024),
                       [filename] varchar(1024)
                      )

CREATE TABLE #tmpSFSdb ([dbname] sysname,
                        [fileid] int,
                        [filegroup] int,
                        [totalextents] int,
                        [usedextents] int,
                        [name] varchar(1024),
                        [filename] varchar(1024)
                      )

--if databases were relocated then update records
IF EXISTS (SELECT 1 
           FROM DB_GROWTH_STATS gs JOIN MASTER..SYSDATABASES ms ON gs.DatabaseName = ms.name
           AND gs.DatabaseId <> ms.dbid)
BEGIN
    UPDATE gs
    SET gs.DatabaseId = ms.DBID
    FROM DB_GROWTH_STATS gs JOIN MASTER..SYSDATABASES ms ON gs.DatabaseName = ms.name
    WHERE gs.DatabaseId <> ms.dbid
END


--retieve all database statistics and insert into temp table
DECLARE db_cursor CURSOR FOR 
SELECT [name], [dbid]
FROM master.dbo.sysdatabases 
WHERE dbid > 6
ORDER BY [name]

OPEN  db_cursor

FETCH NEXT FROM db_cursor INTO @dbname, @intDatabaseID
WHILE @@FETCH_STATUS = 0
BEGIN

    --gather logspace and store in temp table
    INSERT INTO ##tmpLOG EXECUTE ('dbcc sqlperf (logspace)')
    
    --gather file stats and store in temp table
    SET @statement = 'USE ' + @dbname + '  
                     INSERT INTO ##tmpSFS EXECUTE(''DBCC SHOWFILESTATS'')'
    EXEC(@statement)

    --gather index size
    SET @IndexStatement = 'USE ' + @dbname + '
    declare @pages int
    insert into ##tmpIndexSpace (databaseid, reserved)
    select db_id(db_name()), sum(convert(dec(15),reserved))
    from sysindexes
    where indid in (0, 1, 255)
    
    select @pages = sum(convert(dec(15),dpages))
    from sysindexes
    where indid < 2
    
    select @pages = @pages + isnull(sum(convert(dec(15),used)), 0)
    from sysindexes
    where indid = 255
    
    update ##tmpIndexSpace
    set data = @pages
    where databaseid = ' + CAST(@intDatabaseID as varchar) + '
    
    update ##tmpIndexSpace
    set indexp = (select sum(convert(dec(15),used)) from sysindexes where indid in (0, 1)) 
    where databaseid = ' + CAST(@intDatabaseID as varchar)
  
    EXEC(@IndexStatement)

    --take those inserted records and insert with database name
    INSERT INTO #tmpSFSdb 
    SELECT @dbname, * 
    FROM ##tmpSFS

    --cleanup holding database
    DELETE FROM ##tmpSFS
    
    --retrieve logsize
    SELECT @logsize= logsize 
    FROM ##tmpLOG 
    WHERE dbname = @dbname
    
    --calculate log space used
    SELECT @logspaceused = ((logsize*logspaceused)/100.0)
    FROM ##tmpLOG 
    WHERE dbname = @dbname
    
    INSERT INTO ##tmpStats (databaseid, DBName, totalextents, usedextents, logsize, logspaceused)
    select @intDatabaseID,
           dbname,
           sum(totalextents), 
           sum(usedextents),
           cast(@logsize as varchar),
           cast(@logspaceused as varchar)
    FROM #tmpSFSdb
    WHERE DBName = @dbname
    GROUP BY dbname

    TRUNCATE TABLE ##tmpLOG
    
   FETCH  NEXT FROM db_cursor INTO @dbname, @intDatabaseID
END
CLOSE db_cursor
DEALLOCATE db_cursor


--insert records from temp table
INSERT INTO DB_GROWTH_STATS (Statdate, 
                             DatabaseId,
                             DatabaseName,
                             DataSize, 
                             DataUsed, 
                             LogSize, 
                             LogUsed,
                             LastUpdatedBy,
                             LastUpdatedDt,
                             IndexSize)
SELECT @CURRENTRUNDATE,
       s.databaseid,
       DBName,
       (totalextents*64/1024) as datasize,
       (usedextents*64/1024) as dataused,
       logsize,
       logspaceused,
       @USER,
       GETDATE(),
       index_size
FROM ##tmpStats s,
       (select databaseid, index_size = ltrim(str(indexp * d.low / 1024,15,0))
       from ##tmpIndexSpace, master.dbo.spt_values d
       where d.number = 1
       and d.type = 'E') as indexsize
WHERE s.databaseid = indexsize.databaseid

if OBJECT_ID('tempdb.dbo.##tmpLOG') IS NOT NULL
 drop table ##tmpLOG

if OBJECT_ID('tempdb.dbo.##tmpStats') IS NOT NULL
 drop table ##tmpStats

if OBJECT_ID('tempdb.dbo.##tmpSFS') IS NOT NULL
 drop table ##tmpSFS

if OBJECT_ID('tempdb.dbo.#tmpSFSdb') IS NOT NULL
 drop table #tmpSFSdb

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO