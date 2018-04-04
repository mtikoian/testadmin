--Script to calculate information about the Data Files

SET  QUOTED_IDENTIFIER OFF
SET  NOCOUNT ON
SET  TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @dbname   SYSNAME
DECLARE @string   VARCHAR (4000)
SET @string = ''

IF OBJECT_ID('tempdb..#dbstats') IS NOT NULL
  DROP TABLE #dbstats;
  
CREATE TABLE #dbstats
(
   database_name   SYSNAME,
   data_file_size_mb DECIMAL(8,2),
   data_file_used_size_mb DECIMAL(8,2),
   log_file_size_mb DECIMAL(8,2)--,
   --largest_index_name SYSNAME,
   --largest_index_size_mb SYSNAME--,
--   index_detail_xml XML
)



DECLARE
   dbnames_cursor CURSOR FAST_FORWARD FOR
      SELECT name FROM master.sys.databases WHERE state NOT IN (1,6) ORDER BY name; 

OPEN dbnames_cursor;

FETCH NEXT FROM dbnames_cursor INTO @dbname

WHILE (@@fetch_status = 0)
BEGIN
   
   RAISERROR('Starting collection for database %s.',10,1,@dbname) WITH NOWAIT;
   SET @string = '
   USE ' + QUOTENAME(@dbname) + ';
  WITH IndexUsage AS
  (
  select  sds.name filegroup_name,
          so.name object_name,
          si.name index_name,
          si.index_id index_id,
          sau.used_pages * 8 / 1024 index_size_mb
  from    sys.indexes si
            join sys.objects so
              on si.object_id = so.object_id
                 and so.schema_id <> 4 -- exclude sys schema
            join sys.partitions sp
              on si.index_id = sp.index_id
                 and si.object_id = sp.object_id
            join sys.allocation_units sau
              on CASE sau.type
                    WHEN 1 THEN sp.hobt_id
                    WHEN 2 THEN sp.partition_id
                    WHEN 3 THEN sp.hobt_id
                 END = sau.container_id
            join sys.data_spaces sds
              on sau.data_space_id = sds.data_space_id 
  ),
  LargestIndex AS
  (
  SELECT  TOP 1
          iu.index_name,
          iu.index_size_mb
  FROM    IndexUsage iu
  WHERE   iu.index_id > 0 --exclude heaps
  ORDER BY iu.index_size_mb DESC
  ), FileSize AS
  (
  SELECT  SUM(CASE df.type_desc WHEN ''ROWS'' THEN df.size ELSE 0 END * 8 / 1024) data_file_size_mb,
          sum(CASE df.type_desc WHEN ''ROWS'' THEN FILEPROPERTY(df.name,''SpaceUsed'') ELSE 0 END * 8 / 1024) data_file_used_size_mb,
          SUM(CASE df.type_desc WHEN ''LOG'' THEN df.size ELSE 0 END * 8 / 1024) log_file_size_mb
  FROM    sys.database_files df
  )
  INSERT  #dbstats
  SELECT  DB_NAME() database_name,
        fs.data_file_size_mb,
        fs.data_file_used_size_mb,
        fs.log_file_size_mb--,
        --li.index_name largest_index_name,
        --li.index_size_mb largest_index_size_mb--,
        --CAST((
        --  SELECT  iu.filegroup_name,
        --          iu.object_name,
        --          iu.index_name,
        --          iu.index_size_mb
        --  FROM    IndexUsage iu
        --  ORDER BY iu.index_size_mb DESC
        --  FOR XML PATH (''Index'')
        --) AS XML) index_detail_xml
  FROM    FileSize fs
          --JOIN LargestIndex li
          --  ON 1=1
'

   --PRINT @string
   EXEC (@string)

   FETCH NEXT FROM dbnames_cursor INTO @dbname
   
END

CLOSE dbnames_cursor
DEALLOCATE dbnames_cursor

--SELECT DBName,
--       FileGroupName,
--       FileGroupType,
--       TotalSizeInMb,
--       UsedSizeInMb
--  FROM #dbstats;
  
SELECT * FROM #dbstats


DROP TABLE #dbstats
