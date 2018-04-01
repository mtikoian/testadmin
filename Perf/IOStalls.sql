SELECT 
    --virtual file latency

	GETDATE(),
	CASE 
		WHEN [num_of_reads] = 0 
			THEN 0 
		ELSE ([io_stall_read_ms]/[num_of_reads]) 
	END [ReadLatency],
	CASE 
		WHEN [io_stall_write_ms] = 0 
			THEN 0 
		ELSE ([io_stall_write_ms]/[num_of_writes]) 
	END [WriteLatency],
	CASE 
		WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0)
             THEN 0 
		ELSE ([io_stall]/([num_of_reads] + [num_of_writes])) 
	END [Latency],
	--avg bytes per IOP
	CASE 
		WHEN [num_of_reads] = 0 
			THEN 0 
		ELSE ([num_of_bytes_read]/[num_of_reads]) 
	END [AvgBPerRead],
	CASE 
		WHEN [io_stall_write_ms] = 0 
			THEN 0 
		ELSE ([num_of_bytes_written]/[num_of_writes]) 
	END [AvgBPerWrite],
	CASE 
		WHEN ([num_of_reads] = 0 AND [num_of_writes] = 0)
			THEN 0 
		ELSE (([num_of_bytes_read] + [num_of_bytes_written])/([num_of_reads] + [num_of_writes])) 
	END [AvgBPerTransfer],
	LEFT([mf].[physical_name],2) [Drive],
	DB_NAME([vfs].[database_id]) [DB],
	[vfs].[database_id],
	[vfs].[file_id],
	[vfs].[sample_ms],
	[vfs].[num_of_reads],
	[vfs].[num_of_bytes_read],
	[vfs].[io_stall_read_ms],
	[vfs].[num_of_writes],
	[vfs].[num_of_bytes_written],
	[vfs].[io_stall_write_ms],
	[vfs].[io_stall],
	[vfs].[size_on_disk_bytes]/1024/1024. [size_on_disk_MB],
	[vfs].[file_handle],
	[mf].[physical_name]
FROM [sys].[dm_io_virtual_file_stats](NULL,NULL) AS vfs
JOIN [sys].[master_files] [mf] 
    ON [vfs].[database_id] = [mf].[database_id] 
    AND [vfs].[file_id] = [mf].[file_id]
ORDER BY [Latency] DESC;

/*
SQL Server has to read too much data as a result of inefficient query plans or missing indexes
Too little memory is allocated to the instance and the same data is read from disk over and over because it cannot stay in memory
Implicit conversions cause index or table scans
Queries perform SELECT * when not all columns are required
Forwarded record problems in heaps cause additional I/O
Low page densities from index fragmentation, page splits, or incorrect fill factor settings cause additional I/O
*/