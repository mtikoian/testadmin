/*  Script to Rename\Move\Resize TempDB files for Small, Medium and Large SQL Servers

Instructions:
1. Verify available storage for TempDB on the server (20, 40, 150 GB). 
2. Scroll down and modify\execute the appropriate section to rename\move\resize TempDB files.
3. Run sp_helpdb tempdb to verify once complete.

--NOTE: Remember to bounce the SQL Server service between rename\resize. (see below)

Author:		Date:			Comment:
AC33111		11/28/2011		Initial creation
*/


/* Small Server: 20 GB TempDB Drive

		Data       2(files)*6GB(each) = 12GB
		Log         4GB (Single File) */
 

--modify logical\physical name
alter database tempdb modify file (name='tempdev', newname='TempDB_Data01', filename='G:\SQL01\SQLTempDB\TempDB_Data01.mdf')
alter database tempdb modify file (name='templog', newname='TempDB_Log01', filename='G:\SQL01\SQLTempDB\TempDB_Log01.ldf')
----------------------------------------------------------------
--bounce SQL Server for changes to take effect, delete old files
----------------------------------------------------------------
--grow files
alter database tempdb modify file (name='TempDB_Data01', size=6144MB)
alter database tempdb modify file (name='TempDB_Log01', size=4096MB)

--add additional data file
alter database tempdb add file (name='TempDB_Data02', filename='G:\SQL01\SQLTempDB\TempDB_Data02.ndf', size=6144MB, filegrowth=10%)

--verify 
exec sp_helpdb tempdb



/* Medium Server: 40GB TempDB Drive

Data       4(files)*6GB(each) = 24GB 
Log         8GB (Single File)*/

--modify logical\physical name
alter database tempdb modify file (name='tempdev', newname='TempDB_Data01', filename='G:\SQL01\SQLTempDB\TempDB_Data01.mdf')
alter database tempdb modify file (name='templog', newname='TempDB_Log01', filename='G:\SQL01\SQLTempDB\TempDB_Log01.ldf')
----------------------------------------------------------------
--bounce SQL Server for changes to take effect, delete old files
----------------------------------------------------------------
--grow files
alter database tempdb modify file (name='TempDB_Data01', size=6144MB)
alter database tempdb modify file (name='TempDB_Log01', size=8192MB)

--add additional data file
alter database tempdb add file (name='TempDB_Data02', filename='G:\SQL01\SQLTempDB\TempDB_Data02.ndf', size=6144MB, filegrowth=10%)
alter database tempdb add file (name='TempDB_Data03', filename='G:\SQL01\SQLTempDB\TempDB_Data03.ndf', size=6144MB, filegrowth=10%)
alter database tempdb add file (name='TempDB_Data04', filename='G:\SQL01\SQLTempDB\TempDB_Data04.ndf', size=6144MB, filegrowth=10%)

--verify 
exec sp_helpdb tempdb



/* Large Server: 150GB TempDB Drive

Data       8(files)*11GB(each) = 88GB 
Log         30GB (Single File)*/

--modify logical\physical name
alter database tempdb modify file (name='tempdev', newname='TempDB_Data01', filename='G:\SQL01\SQLTempDB\TempDB_Data01.mdf')
alter database tempdb modify file (name='templog', newname='TempDB_Log01', filename='G:\SQL01\SQLTempDB\TempDB_Log01.ldf')
----------------------------------------------------------------
--bounce SQL Server for changes to take effect, delete old files
----------------------------------------------------------------
--grow files
alter database tempdb modify file (name='TempDB_Data01', size=11264MB)
alter database tempdb modify file (name='TempDB_Log01', size=30720MB)

--add additional data file
alter database tempdb add file (name='TempDB_Data02', filename='G:\SQL01\SQLTempDB\TempDB_Data02.ndf', size=11264MB, filegrowth=10%)
alter database tempdb add file (name='TempDB_Data03', filename='G:\SQL01\SQLTempDB\TempDB_Data03.ndf', size=11264MB, filegrowth=10%)
alter database tempdb add file (name='TempDB_Data04', filename='G:\SQL01\SQLTempDB\TempDB_Data04.ndf', size=11264MB, filegrowth=10%)
alter database tempdb add file (name='TempDB_Data05', filename='G:\SQL01\SQLTempDB\TempDB_Data05.ndf', size=11264MB, filegrowth=10%)
alter database tempdb add file (name='TempDB_Data06', filename='G:\SQL01\SQLTempDB\TempDB_Data06.ndf', size=11264MB, filegrowth=10%)
alter database tempdb add file (name='TempDB_Data07', filename='G:\SQL01\SQLTempDB\TempDB_Data07.ndf', size=11264MB, filegrowth=10%)
alter database tempdb add file (name='TempDB_Data08', filename='G:\SQL01\SQLTempDB\TempDB_Data08.ndf', size=11264MB, filegrowth=10%)

--verify 
exec sp_helpdb tempdb