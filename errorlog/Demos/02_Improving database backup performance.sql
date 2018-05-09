-- Improving backup performance


-- Roughly 7GB database
USE AdventureWorks2014;
GO


-- Individual File Sizes and space available for current database  
SELECT f.name AS [File Name] , f.physical_name AS [Physical Name], 
CAST((f.size/128.0) AS DECIMAL(15,2)) AS [Total Size in MB],
CAST(f.size/128.0 - CAST(FILEPROPERTY(f.name, 'SpaceUsed') AS int)/128.0 AS DECIMAL(15,2)) 
AS [Available Space In MB], f.[file_id], fg.name AS [Filegroup Name],
f.is_percent_growth, f.growth, fg.is_default, fg.is_read_only
FROM sys.database_files AS f WITH (NOLOCK) 
LEFT OUTER JOIN sys.filegroups AS fg WITH (NOLOCK)
ON f.data_space_id = fg.data_space_id
ORDER BY f.[file_id] OPTION (RECOMPILE);


-- Backup to NUL to measure how fast you can actually read from the data file(s) and log file  


-- Backup to NUL device without backup compression
BACKUP DATABASE AdventureWorks2014 
TO  DISK = N'NUL' WITH NOFORMAT, INIT,  
NAME = N'AdventureWorks2014-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD, NO_COMPRESSION,  STATS = 1;
GO
-- BACKUP DATABASE successfully processed 949157 pages in 3.308 seconds (2241.623 MB/sec)



-- Try backup up to a single file destination  ********************************************


-- Backup  to L:\SQLBackups with backup compression
BACKUP DATABASE AdventureWorks2014 
TO  DISK = N'L:\SQL2017Backups\AdventureWorks2014Compressed.bak' WITH NOFORMAT, INIT,  
NAME = N'AdventureWorks2014-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 1;
GO
-- BACKUP DATABASE successfully processed 949154 pages in 14.911 seconds (497.301 MB/sec)







-- Try striped backup up to two different drives  ********************************************


-- Striped backup to two files on two different drives with backup compression
BACKUP DATABASE AdventureWorks2014 
TO  DISK = N'R:\SQL2017Backups\AdventureWorks2014CompressedA.bak',  
    DISK = N'V:\SQL2017Backups\AdventureWorks2014CompressedB.bak' 
WITH NOFORMAT, INIT,  NAME = N'AdventureWorks2014-Full Striped Database Backup', 
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 1;
GO
-- BACKUP DATABASE successfully processed 949154 pages in 11.628 seconds (637.707 MB/sec)





-- Try striped backup up to two different drives using parameter options  ********************************************


-- Striped backup to two files on two different drives with backup compression, using parameter options
BACKUP DATABASE AdventureWorks2014 
TO  DISK = N'R:\SQL2017Backups\AdventureWorks2014CompressedA1.bak',  
    DISK = N'V:\SQL2017Backups\AdventureWorks2014CompressedB1.bak' 
WITH NOFORMAT, INIT,  NAME = N'AdventureWorks2014-Full Striped Database Backup', 
SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 1,
BUFFERCOUNT = 2200, BLOCKSIZE = 65536, MAXTRANSFERSIZE = 2097152;
GO
-- BACKUP DATABASE successfully processed 949154 pages in 6.303 seconds (1176.464 MB/sec)




-- BUFFERCOUNT - Specifies the total number of I/O buffers to be used for 
--               the backup or restore operation

-- BLOCKSIZE - Specifies the physical block size, in bytes. The supported sizes 
--             are 512, 1024, 2048, 4096, 8192, 16384, 32768, and 65536 (64 KB) bytes. 
--             The default is 65536 for tape devices and 512 otherwise

-- MAXTRANSFERSIZE - Specifies the largest unit of transfer in bytes to be used 
--                   between the backup media and SQL Server. The possible values 
--                   are multiples of 65536 bytes (64 KB) ranging up to 4194304 bytes (4 MB)


-- Look at recent Full backups for the current database 
SELECT TOP (30)  bs.database_name AS [Database Name], 
CONVERT (BIGINT, bs.backup_size / 1048576 ) AS [Uncompressed Backup Size (MB)],
CONVERT (BIGINT, bs.compressed_backup_size / 1048576 ) AS [Compressed Backup Size (MB)],
CONVERT (NUMERIC (20,2), (CONVERT (FLOAT, bs.backup_size) /
CONVERT (FLOAT, bs.compressed_backup_size))) AS [Compression Ratio], 
DATEDIFF (SECOND, bs.backup_start_date, bs.backup_finish_date) AS [Backup Elapsed Time (sec)],
bs.backup_finish_date AS [Backup Finish Date], 
bmf.physical_device_name AS [Backup Location], bmf.physical_block_size
FROM msdb.dbo.backupset AS bs WITH (NOLOCK)
INNER JOIN msdb.dbo.backupmediafamily AS bmf WITH (NOLOCK)
ON bs.media_set_id = bmf.media_set_id  
WHERE bs.database_name = DB_NAME(DB_ID())
AND bs.[type] = 'D' 
ORDER BY bs.backup_finish_date DESC OPTION (RECOMPILE);


-- Optimizing Backup and Restore Performance in SQL Server
-- https://technet.microsoft.com/en-us/library/ms190954(v=sql.105).aspx