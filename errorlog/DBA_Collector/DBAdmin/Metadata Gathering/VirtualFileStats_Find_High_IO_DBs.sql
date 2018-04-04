select	mf.name,
		mf.physical_name,
		vfs.num_of_bytes_read/1024/1024 MBRead,
		vfs.num_of_bytes_written/1024/1024 MBWritten
from	sys.dm_io_virtual_file_stats(null,null) vfs
			join master.sys.master_files mf
				on vfs.database_id = mf.database_id
				and vfs.file_id = mf.file_id
order by 3 desc