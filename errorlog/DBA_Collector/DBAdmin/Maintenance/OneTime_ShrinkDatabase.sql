DECLARE  @Current_Used_Size BIGINT
        ,@Data_File_Nm SYSNAME
        ,@Current_Data_Size BIGINT
        ,@Largest_Index_Size BIGINT
        ,@Desired_DB_Size BIGINT
        ,@For_Real_Fl BIT
        ,@Database_Nm SYSNAME;


-- Set this to '1' if you want to really run the shrink
SET @For_Real_Fl = 1;

SET @Database_Nm = DB_NAME();

SELECT
  @Data_File_Nm = df.name,
  @Current_Data_Size = df.size * 8 / 1024,
  @Current_Used_Size = FILEPROPERTY(df.name,'SpaceUsed') * 8 / 1024
FROM
  sys.database_files df
WHERE
  df.type_desc = 'ROWS';

with IndexUsage AS
(
select  si.name index_name,
        SUM(sau.used_pages) * 8 / 1024 index_size_mb
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
group by  si.name
)
SELECT
  @Largest_Index_Size = MAX(index_size_mb)
FROM
  IndexUsage;


SET @Desired_DB_Size = @Current_Used_Size + @Largest_Index_Size + ((@Current_Used_Size + @Largest_Index_Size) * .20);

RAISERROR('Current database file size: %I64d.',10,1,@Current_Data_Size) WITH NOWAIT;
RAISERROR('Current used file size: %I64d.',10,1,@Current_Used_Size) WITH NOWAIT;
RAISERROR('Largest index size: %I64d.',10,1,@Largest_Index_Size) WITH NOWAIT;
RAISERROR('Desired database size: %I64d.',10,1,@Desired_DB_Size) WITH NOWAIT;

WHILE @Current_Data_Size > @Desired_DB_Size BEGIN

  SET @Current_Data_Size = @Current_Data_Size - 10240;

  IF @Current_Data_Size < @Desired_DB_Size 
    SET @Current_Data_Size = @Desired_DB_Size;

  RAISERROR('Shrinking file to %I64d MB...',10,1,@Current_Data_Size) WITH NOWAIT;

  IF @For_Real_Fl = 1
    DBCC SHRINKFILE(@Data_File_Nm,@Current_Data_Size);

END

IF @For_Real_Fl = 1
EXEC master.dbo.IndexOptimize @Databases = @Database_Nm, @PageCountLevel = 1, @FragmentationLevel1 = 10, @FragmentationMedium = 'INDEX_REBUILD_OFFLINE';