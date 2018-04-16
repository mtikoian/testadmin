DECLARE @tmpVFS TABLE
(
  database_id INT,
  file_id INT,
  first_io_read_ms DECIMAL(20,2),
  second_io_read_ms DECIMAL(20,2),
  first_io_write_ms DECIMAL(20,2),
  second_io_write_ms DECIMAL(20,2),
  first_io_reads BIGINT,
  second_io_reads BIGINT,
  first_io_writes BIGINT,
  second_io_writes BIGINT
);

INSERT  @tmpVFS
(
  database_id,
  file_id,
  first_io_read_ms,
  first_io_write_ms,
  first_io_reads,
  first_io_writes
)
SELECT  d.database_id,
        vfs.file_id,
        vfs.io_stall_read_ms first_io_read_ms,
        vfs.io_stall_write_ms first_io_write_ms,
        vfs.num_of_reads first_io_reads,
        vfs.num_of_writes first_io_writes
FROM    sys.dm_io_virtual_file_stats(NULL,NULL) vfs
          JOIN sys.databases d
            ON d.database_id = vfs.database_id;
            
WAITFOR DELAY '00:01:00';

UPDATE  tvfs
SET     second_io_read_ms = vfs.io_stall_read_ms,
        second_io_write_ms = vfs.io_stall_write_ms,
        second_io_reads = vfs.num_of_reads,
        second_io_writes = vfs.num_of_writes        
FROM    @tmpVFS tvfs
          JOIN sys.dm_io_virtual_file_stats(NULL,NULL) vfs
            ON tvfs.database_id = vfs.database_id
            AND tvfs.file_id = vfs.file_id;
            
SELECT  d.name + ':' + mf.name + ':reads' metric_name,
        CASE (second_io_reads - first_io_reads) WHEN 0 THEN 0 ELSE (second_io_read_ms - first_io_read_ms)/(second_io_reads - first_io_reads) END metric_value
FROM    @tmpVFS tvfs
          JOIN sys.databases d
            ON tvfs.database_id = d.database_id
          JOIN sys.master_files mf
            ON tvfs.database_id = mf.database_id
            AND tvfs.file_id = mf.file_id
UNION
SELECT  d.name + ':' + mf.name + ':writes' metric_name,
        CASE (second_io_writes - first_io_writes) WHEN 0 THEN 0 ELSE (second_io_write_ms - first_io_write_ms)/(second_io_writes - first_io_writes) END metric_value
FROM    @tmpVFS tvfs
          JOIN sys.databases d
            ON tvfs.database_id = d.database_id
          JOIN sys.master_files mf
            ON tvfs.database_id = mf.database_id
            AND tvfs.file_id = mf.file_id   
ORDER BY metric_name;
