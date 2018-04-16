select	mf.name,
		mf.physical_name,
		vfs.io_stall_read_ms / CASE vfs.num_of_reads WHEN 0 THEN 1 ELSE vfs.num_of_reads END AvgReadIOStall,
		vfs.io_stall_write_ms / CASE vfs.num_of_writes WHEN 0 THEN 1 ELSE vfs.num_of_writes END AvgWriteIOStall
from	sys.dm_io_virtual_file_stats(null,null) vfs
			join master.sys.master_files mf
				on vfs.database_id = mf.database_id
				and vfs.file_id = mf.file_id
order by 2 desc