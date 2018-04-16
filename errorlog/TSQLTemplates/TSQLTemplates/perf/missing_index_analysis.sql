SET NOCOUNT ON;
SET DEADLOCK_PRIORITY -8;

IF OBJECT_ID('tempdb.dbo.#index_specs') IS NOT NULL
  DROP TABLE dbo.#index_specs
IF OBJECT_ID('tempdb.dbo.#index_missing') IS NOT NULL
  DROP TABLE dbo.#index_missing
IF OBJECT_ID('tempdb.dbo.#index_usage')  IS NOT NULL
  DROP TABLE dbo.#index_usage

CREATE TABLE dbo.#index_specs (
  object_id int NOT NULL,
  index_id int NOT NULL,
  min_compression int NULL,
  max_compression int NULL,
  drive char(1) NULL,
  alloc_mb decimal(9, 1) NOT NULL,
  alloc_gb AS CAST(alloc_mb / 1024.0 AS decimal(9, 2)),
  used_mb decimal(9, 1) NOT NULL,
  used_gb AS CAST(used_mb / 1024.0 AS decimal(9, 2)),
  rows bigint NULL,
  table_mb decimal(9, 1) NULL,
  table_gb AS CAST(table_mb / 1024.0 AS decimal(9, 2)),
  size_rank int NULL,
  approx_max_data_width bigint NULL,
  UNIQUE CLUSTERED ( object_id, index_id )
  )

DECLARE @list_missing_indexes bit
DECLARE @list_missing_indexes_summary bit
DECLARE @include_schema_in_table_names bit
DECLARE @table_name_pattern sysname
DECLARE @order_by smallint --1=table_name; 2=size; -2=size DESC;.
DECLARE @format_counts smallint --1=with commas, no decimals; 2/3=with K=1000s,M=1000000s, with 2=0 dec. or 3=1 dec. places;.
DECLARE @debug smallint

--NOTE: showing missing indexes can take some time; set to 0 if you don't want to wait.
SET @list_missing_indexes = 1
SET @list_missing_indexes_summary = 0
SET @include_schema_in_table_names = 1
SET @table_name_pattern = 'sent'
SET @order_by = 1
SET @format_counts = 3
SET @debug = 0

PRINT 'Started @ ' + CONVERT(varchar(30), GETDATE(), 120)

DECLARE @is_compression_available bit
DECLARE @sql varchar(max)

IF CAST(SERVERPROPERTY('ProductVersion') AS varchar(30)) LIKE '9%'
OR (CAST(SERVERPROPERTY('Edition') AS varchar(40)) NOT LIKE '%Developer%' AND 
  CAST(SERVERPROPERTY('Edition') AS varchar(40)) NOT LIKE '%Enterprise%')
  SET @is_compression_available = 0
ELSE
  SET @is_compression_available = 1

SET @sql = '
INSERT INTO #index_specs ( object_id, index_id,' +
  CASE WHEN @is_compression_available = 0 THEN '' ELSE '
  min_compression, max_compression,' END + '
  alloc_mb, used_mb, rows )
SELECT 
  base_size.object_id, 
  base_size.index_id, ' +
  CASE WHEN @is_compression_available = 0 THEN '' ELSE '
  base_size.min_compression,
  base_size.max_compression,' END + '
  (base_size.total_pages + ISNULL(internal_size.total_pages, 0)) / 128.0 AS alloc_mb,
  (base_size.used_pages + ISNULL(internal_size.used_pages, 0)) / 128.0 AS used_mb,
  base_size.row_count AS rows
FROM (
  SELECT
    dps.object_id,
    dps.index_id, ' + 
    CASE WHEN @is_compression_available = 0 THEN '' ELSE '
    ISNULL(MIN(p.data_compression), 0) AS min_compression,
    ISNULL(MAX(p.data_compression), 0) AS max_compression,' END + '  
    SUM(dps.reserved_page_count) AS total_pages,
      SUM(dps.used_page_count) AS used_pages,
      SUM(CASE WHEN dps.index_id IN (0, 1) THEN dps.row_count ELSE 0 END) AS row_count
  FROM sys.dm_db_partition_stats dps ' +
  CASE WHEN @is_compression_available = 0 THEN '' ELSE '
  INNER JOIN sys.partitions p /* WITH (NOLOCK)*/ ON
    p.partition_id = dps.partition_id ' END + '
  WHERE dps.object_id > 100
  GROUP BY 
    dps.object_id,
    dps.index_id
) AS base_size
LEFT OUTER JOIN (
  SELECT 
    it.parent_id,
    SUM(dps.reserved_page_count) AS total_pages,
      SUM(dps.used_page_count) AS used_pages
  FROM sys.internal_tables it /* WITH (NOLOCK)*/
  INNER JOIN sys.dm_db_partition_stats dps /* WITH (NOLOCK)*/ ON 
    dps.object_id = it.parent_id
  WHERE it.internal_type IN ( ''202'', ''204'', ''211'', ''212'', ''213'', ''214'', ''215'', ''216'' )
  GROUP BY
    it.parent_id
) AS internal_size ON base_size.index_id IN (0, 1) AND internal_size.parent_id = base_size.object_id
'
IF @debug >= 1
  PRINT @sql
EXEC(@sql)

UPDATE [is]
SET approx_max_data_width = index_cols.approx_max_data_width
FROM #index_specs [is]
INNER JOIN (
  SELECT index_col_ids.object_id, index_col_ids.index_id, 
    SUM(CASE WHEN c.max_length = -1 THEN 16 ELSE c.max_length END) AS approx_max_data_width
  FROM (
    SELECT ic.object_id, ic.index_id, ic.column_id
    --,object_name(ic.object_id)
    FROM sys.index_columns ic
    WHERE
    ic.object_id > 100
    UNION
    SELECT i_nonclus.object_id, i_nonclus.index_id, ic_clus.column_id
    --,object_name(i_nonclus.object_id)
    FROM sys.indexes i_nonclus
    CROSS APPLY (
    SELECT ic_clus2.column_id
      --,object_name(ic_clus2.object_id),ic_clus2.key_ordinal
    FROM sys.index_columns ic_clus2
    WHERE
      ic_clus2.object_id = i_nonclus.object_id AND
      ic_clus2.index_id = 1 AND
      ic_clus2.key_ordinal > 0 --technically superfluous, since clus index can't have include'd cols anyway
    ) AS ic_clus
    WHERE
    i_nonclus.object_id > 100 AND
    i_nonclus.index_id > 1
  ) AS index_col_ids
  INNER JOIN sys.columns c ON c.object_id = index_col_ids.object_id AND c.column_id = index_col_ids.column_id
  GROUP BY index_col_ids.object_id, index_col_ids.index_id  
) AS index_cols ON index_cols.object_id = [is].object_id AND index_cols.index_id = [is].index_id

UPDATE ispec
SET table_mb = ispec_ranking.table_mb,
  size_rank = ispec_ranking.size_rank
FROM #index_specs ispec
INNER JOIN (
  SELECT *, ROW_NUMBER() OVER(ORDER BY table_mb DESC, rows DESC, OBJECT_NAME(object_id)) AS size_rank
  FROM (
    SELECT object_id, SUM(alloc_mb) AS table_mb, MAX(rows) AS rows
    FROM #index_specs
    GROUP BY object_id
  ) AS ispec_allocs    
) AS ispec_ranking ON
  ispec_ranking.object_id = ispec.object_id

IF @list_missing_indexes = 1
BEGIN
  SELECT
    IDENTITY(int, 1, 1) AS ident,
    DB_NAME(mid.database_id) AS Db_Name,
    CONVERT(varchar(10), GETDATE(), 120) AS capture_date,
    ispec.size_rank, ispec.table_mb,
    CASE WHEN @format_counts = 1 THEN REPLACE(CONVERT(varchar(20), CAST(dps.row_count AS money), 1), '.00', '')
     WHEN @format_counts = 2 THEN CAST(CAST(dps.row_count * 1.0 / CASE ca1.row_count_suffix 
       WHEN 'M' THEN 1000000 WHEN 'K' THEN 1000 ELSE 1 END AS int) AS varchar(20)) + ca1.row_count_suffix
     WHEN @format_counts = 3 THEN CAST(CAST(dps.row_count * 1.0 / CASE ca1.row_count_suffix 
       WHEN 'M' THEN 1000000 WHEN 'K' THEN 1000 ELSE 1 END AS decimal(14, 1)) AS varchar(20)) + ca1.row_count_suffix
     ELSE CAST(dps.row_count AS varchar(20)) END AS row_count,
    CASE WHEN @include_schema_in_table_names = 1 THEN OBJECT_SCHEMA_NAME(mid.object_id) + '.' 
     ELSE '' END + OBJECT_NAME(mid.object_id /*, mid.database_id*/) AS Table_Name,
    mid.equality_columns, mid.inequality_columns, mid.included_columns,    
    user_seeks, user_scans, cj1.max_days_active, unique_compiles, 
    last_user_seek, last_user_scan, 
    CAST(avg_total_user_cost AS decimal(9, 2)) AS avg_total_user_cost,
    CAST(avg_user_impact AS decimal(9, 2)) AS [avg_user_impact%],
    system_seeks, system_scans, last_system_seek, last_system_scan,
    CAST(avg_total_system_cost AS decimal(9, 2)) AS avg_total_system_cost,
    CAST(avg_system_impact AS decimal(9, 2)) AS [avg_system_impact%],
    mid.statement, mid.object_id, mid.index_handle
  INTO #index_missing
  FROM sys.dm_db_missing_index_details mid /*WITH (NOLOCK)*/
  CROSS JOIN (
    SELECT DATEDIFF(DAY, create_date, GETDATE()) AS max_days_active FROM sys.databases /*WITH (NOLOCK)*/ WHERE name = 'tempdb'
  ) AS cj1
  LEFT OUTER JOIN sys.dm_db_missing_index_groups mig /*WITH (NOLOCK)*/ ON
    mig.index_handle = mid.index_handle
  LEFT OUTER JOIN sys.dm_db_missing_index_group_stats migs /*WITH (NOLOCK)*/ ON
    migs.group_handle = mig.index_group_handle
  LEFT OUTER JOIN sys.dm_db_partition_stats dps /*WITH (NOLOCK)*/ ON
    dps.object_id = mid.object_id AND
    dps.index_id IN (0, 1)
  CROSS APPLY (
    SELECT CASE WHEN dps.row_count >= 1000000 THEN 'M' WHEN dps.row_count >= 1000 THEN 'K' ELSE '' END AS row_count_suffix
  ) AS ca1
  OUTER APPLY (
    SELECT ispec.table_mb, ispec.size_rank
    FROM dbo.#index_specs ispec
    WHERE
    ispec.object_id = mid.object_id AND
    ispec.index_id IN (0, 1)
  ) AS ispec
  WHERE
    1 = 1 
    AND mid.database_id = DB_ID()
    AND OBJECT_NAME(mid.object_id) LIKE @table_name_pattern
    AND OBJECT_NAME(mid.object_id) NOT LIKE 'tmp%'
  ORDER BY
    --avg_total_user_cost * (user_seeks + user_scans) DESC,
    Db_Name,
    CASE WHEN @order_by IN (-2, 2) THEN ispec.size_rank * -SIGN(@order_by) ELSE 0 END,
    Table_Name,
    equality_columns, inequality_columns,
    user_seeks DESC
  SELECT *
  FROM #index_missing
  ORDER BY ident
  IF @list_missing_indexes_summary = 1
  BEGIN
    SELECT 
    derived.Size_Rank, derived.table_mb,
    derived.Table_Name, derived.Equality_Column, derived.Equality#, derived.User_Seeks, 
    ISNULL((SELECT SUM(user_seeks)
     FROM #index_missing im2
     CROSS APPLY DBA.dbo.DelimitedSplit8K (inequality_columns, ',') ds
     WHERE im2.Size_Rank = derived.Size_Rank AND
       LTRIM(RTRIM(ds.Item)) = derived.Equality_Column
    ), 0) AS Inequality_Seeks,
    derived.User_Scans, derived.Last_User_Seek, derived.Last_User_Scan,
    derived.Max_Days_Active, derived.Avg_Total_User_Cost, derived.Approx_Total_Cost
    FROM (
    SELECT 
      Size_Rank, MAX(table_mb) AS table_mb, Table_Name, LTRIM(RTRIM(ds.Item)) AS Equality_Column, 
      SUM(user_seeks) AS User_Seeks, SUM(user_scans) AS User_Scans,
      MAX(last_user_seek) AS Last_User_Seek, MAX(last_user_scan) AS Last_User_Scan,
      MIN(max_days_active) AS Max_Days_Active,
      MAX(avg_total_user_cost) AS Avg_Total_User_Cost,
      (SUM(user_seeks) + SUM(user_scans)) * MAX(avg_total_user_cost) AS Approx_Total_Cost,
      MAX(ds.ItemNumber) AS Equality#
    FROM #index_missing
    CROSS APPLY DBA.dbo.DelimitedSplit8K (equality_columns, ',') ds
    WHERE equality_columns IS NOT NULL
    GROUP BY size_rank, Table_Name, LTRIM(RTRIM(ds.Item))
    ) AS derived
    ORDER BY Size_Rank, Table_Name, Approx_Total_Cost DESC    
  END --IF
END --IF



PRINT 'Index Usage Stats @ ' + CONVERT(varchar(30), GETDATE(), 120)

-- list index usage stats (seeks, scans, etc.)
SELECT 
  IDENTITY(int, 1, 1) AS ident,
  DB_NAME() AS db_name,
  --ispec.drive AS drv,
  ispec.size_rank, ispec.alloc_mb - ispec.used_mb AS unused_mb, 
  CASE WHEN @include_schema_in_table_names = 1 THEN OBJECT_SCHEMA_NAME(i.object_id /*, DB_ID()*/) + '.' 
   ELSE '' END + OBJECT_NAME(i.object_id /*, i.database_id*/) AS Table_Name,  
  CASE WHEN @format_counts = 1 THEN REPLACE(CONVERT(varchar(20), CAST(dps.row_count AS money), 1), '.00', '')
   WHEN @format_counts = 2 THEN CAST(CAST(dps.row_count * 1.0 / CASE ca1.row_count_suffix 
     WHEN 'M' THEN 1000000 WHEN 'K' THEN 1000 ELSE 1 END AS int) AS varchar(20)) + ca1.row_count_suffix
   WHEN @format_counts = 3 THEN CAST(CAST(dps.row_count * 1.0 / CASE ca1.row_count_suffix 
     WHEN 'M' THEN 1000000 WHEN 'K' THEN 1000 ELSE 1 END AS decimal(14, 1)) AS varchar(20)) + ca1.row_count_suffix
   ELSE CAST(dps.row_count AS varchar(20)) END AS row_count,
  ispec.table_gb, ispec.alloc_gb AS index_gb,
  SUBSTRING('NY', CAST(i.is_primary_key AS int) + CAST(i.is_unique_constraint AS int) + 1, 1) +
  CASE WHEN i.is_unique = CAST(i.is_primary_key AS int) + CAST(i.is_unique_constraint AS int) THEN '' 
   ELSE '.' + SUBSTRING('NY', CAST(i.is_unique AS int) + 1, 1) END AS [Uniq?],
  REPLACE(i.name, oa1.table_name, '~') AS index_name,
  --fc_row_count.formatted_value AS row_count,
  i.index_id,
  ispec.approx_max_data_width AS [data_width], 
  CAST(CAST(ispec.used_mb AS float) * 1024.0 * 1024.0 / NULLIF(dps.row_count, 0) AS int) AS cmptd_row_size,
  key_cols AS key_cols,
  LEN(nonkey_cols) - LEN(REPLACE(nonkey_cols, ',', '')) + 1 AS nonkey_count,
  nonkey_cols AS nonkey_cols,
  ius.user_seeks, ius.user_scans, --ius.user_seeks + ius.user_scans AS total_reads,
  ius.user_lookups, ius.user_updates,
  dios.leaf_delete_count + dios.leaf_insert_count + dios.leaf_update_count as leaf_mod_count,
  dios.range_scan_count, dios.singleton_lookup_count,
  DATEDIFF(DAY, STATS_DATE ( i.object_id , i.index_id ), GETDATE()) AS stats_days_old,
  DATEDIFF(DAY, CASE 
    WHEN o.create_date > cj1.sql_startup_date AND o.create_date > o.modify_date THEN o.create_date 
    WHEN o.modify_date > cj1.sql_startup_date AND o.modify_date > o.create_date THEN o.modify_date 
    ELSE cj1.sql_startup_date END, GETDATE()) AS max_days_active,
  dios.row_lock_count, dios.row_lock_wait_in_ms,
  dios.page_lock_count, dios.page_lock_wait_in_ms,  
  ius.last_user_seek, ius.last_user_scan,
  ius.last_user_lookup, ius.last_user_update,
  fk.Reference_Count AS fk_ref_count,
  i.fill_factor,
  ius2.row_num,
  CASE 
    WHEN ispec.max_compression IS NULL THEN '(Not applicable)'
    WHEN ispec.max_compression = 2 THEN 'Page'
    WHEN ispec.max_compression = 1 THEN 'Row'
    WHEN ispec.max_compression = 0 THEN ''
    ELSE '(Unknown)' END AS max_compression,
  ius.system_seeks, ius.system_scans, ius.system_lookups, ius.system_updates,
  ius.last_system_seek, ius.last_system_scan, ius.last_system_lookup, ius.last_system_update,
  GETDATE() AS capture_date
INTO #index_usage
FROM sys.indexes i /*WITH (NOLOCK)*/
INNER JOIN sys.objects o /*WITH (NOLOCK)*/ ON
  o.object_id = i.object_id
CROSS JOIN (
  SELECT create_date AS sql_startup_date FROM sys.databases /*WITH (NOLOCK)*/ WHERE name = 'tempdb'
) AS cj1
OUTER APPLY (
  SELECT CASE WHEN EXISTS(SELECT 1 FROM #index_specs [is] WHERE [is].object_id = i.object_id AND [is].index_id = 1)
    THEN 1 ELSE 0 END AS has_clustered_index
) AS cj2
LEFT OUTER JOIN dbo.#index_specs ispec ON
  ispec.object_id = i.object_id AND
  ispec.index_id = i.index_id
OUTER APPLY (
  SELECT STUFF((
  SELECT
    ', ' + COL_NAME(ic.object_id, ic.column_id)
  FROM sys.index_columns ic /*WITH (NOLOCK)*/
  WHERE
    ic.key_ordinal > 0 AND
    ic.object_id = i.object_id AND
    ic.index_id = i.index_id
  ORDER BY
    ic.key_ordinal
  FOR XML PATH('')
  ), 1, 2, '')
) AS key_cols (key_cols)
OUTER APPLY (
  SELECT STUFF((
  SELECT
    ', ' + COL_NAME(ic.object_id, ic.column_id)
  FROM sys.index_columns ic /*WITH (NOLOCK)*/
  WHERE
    ic.key_ordinal = 0 AND
    ic.object_id = i.object_id AND
    ic.index_id = i.index_id
  ORDER BY
    COL_NAME(ic.object_id, ic.column_id)
  FOR XML PATH('') 
  ), 1, 2, '')
) AS nonkey_cols (nonkey_cols)
LEFT OUTER JOIN sys.dm_db_partition_stats dps /*WITH (NOLOCK)*/ ON
  dps.object_id = i.object_id AND
  dps.index_id = i.index_id
LEFT OUTER JOIN sys.dm_db_index_usage_stats ius /*WITH (NOLOCK)*/ ON
  ius.database_id = DB_ID() AND
  ius.object_id = i.object_id AND
  ius.index_id = i.index_id
LEFT OUTER JOIN (
  SELECT
    database_id, object_id, MAX(user_scans) AS user_scans,
    ROW_NUMBER() OVER (ORDER BY MAX(user_scans) DESC) AS row_num --user_scans|user_seeks+user_scans
  FROM sys.dm_db_index_usage_stats /*WITH (NOLOCK)*/
  WHERE
    database_id = DB_ID()
    --AND index_id > 0
  GROUP BY
    database_id, object_id
) AS ius2 ON
  ius2.database_id = DB_ID() AND
  ius2.object_id = i.object_id
LEFT OUTER JOIN (
  SELECT
    referenced_object_id, COUNT(*) AS Reference_Count
  FROM sys.foreign_keys /*WITH (NOLOCK)*/
  WHERE
    is_disabled = 0
  GROUP BY
    referenced_object_id
) AS fk ON
  fk.referenced_object_id = i.object_id
LEFT OUTER JOIN (
  SELECT *
  FROM sys.dm_db_index_operational_stats ( DB_ID(), NULL, NULL, NULL )
) AS dios ON
  dios.object_id = i.object_id AND
  dios.index_id = i.index_id
OUTER APPLY (
  SELECT OBJECT_NAME(i.object_id/*, DB_ID()*/) AS table_name
    --, CASE WHEN dps.row_count >= 1000000 THEN 'M' WHEN dps.row_count >= 1000 THEN 'K' ELSE '' END AS row_count_suffix
) AS oa1
CROSS APPLY (
  SELECT CASE WHEN dps.row_count >= 1000000 THEN 'M' WHEN dps.row_count >= 1000 THEN 'K' ELSE '' END AS row_count_suffix
) AS ca1

WHERE
  i.object_id > 100 AND
  i.is_hypothetical = 0 AND
  i.type IN (0, 1, 2) AND
  o.type NOT IN ( 'IF', 'IT', 'TF', 'TT' ) AND
  (
   o.name LIKE @table_name_pattern AND
   o.name NOT LIKE 'dtprop%' AND
   o.name NOT LIKE 'filestream[_]' AND
   o.name NOT LIKE 'MSpeer%' AND
   o.name NOT LIKE 'MSpub%' AND
   --o.name NOT LIKE 'queue[_]%' AND 
   o.name NOT LIKE 'sys%' 
  )
ORDER BY
  db_name,
  CASE WHEN @order_by IN (-2, 2) THEN ispec.size_rank * -SIGN(@order_by) ELSE 0 END,
  --ius.user_scans DESC,
  --ius2.row_num, --user_scans&|user_seeks
  table_name, 
  -- list clustered index first, if any, then other index(es)
  CASE WHEN i.index_id IN (0, 1) THEN 1 ELSE 2 END, 
  key_cols


SELECT *
FROM #index_usage
ORDER BY ident

PRINT 'Ended @ ' + CONVERT(varchar(30), GETDATE(), 120)

SET DEADLOCK_PRIORITY NORMAL
