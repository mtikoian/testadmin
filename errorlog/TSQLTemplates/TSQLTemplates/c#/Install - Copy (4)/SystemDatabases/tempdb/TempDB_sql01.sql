USE [master]
GO
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'tempdev', SIZE = 8388608KB )
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdev1', FILENAME = N'J:\SQLTempDB\SQL01\tempdev1.ndf' , SIZE = 8388608KB , FILEGROWTH = 10%)
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdev2', FILENAME = N'J:\SQLTempDB\SQL01\tempdev2.ndf' , SIZE = 8388608KB , FILEGROWTH = 10%)
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdev3', FILENAME = N'J:\SQLTempDB\SQL01\tempdev3.ndf' , SIZE = 8388608KB , FILEGROWTH = 10%)
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdev4', FILENAME = N'J:\SQLTempDB\SQL01\tempdev4.ndf' , SIZE = 8388608KB , FILEGROWTH = 10%)
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdev5', FILENAME = N'J:\SQLTempDB\SQL01\tempdev5.ndf' , SIZE = 8388608KB , FILEGROWTH = 10%)
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdev6', FILENAME = N'J:\SQLTempDB\SQL01\tempdev6.ndf' , SIZE = 8388608KB , FILEGROWTH = 10%)
GO
ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdev7', FILENAME = N'J:\SQLTempDB\SQL01\tempdev7.ndf' , SIZE = 8388608KB , FILEGROWTH = 10%)
GO
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'templog', SIZE = 8388608KB )
GO


------------
--Move temp db files to tempdb drive
USE master;
GO
ALTER DATABASE tempdb 
MODIFY FILE (NAME = tempdev, FILENAME = 'J:\SQLTempDB\SQL01\tempdb.mdf');
GO
ALTER DATABASE  tempdb 
MODIFY FILE (NAME = templog, FILENAME = 'J:\SQLTempDB\SQL01\templog.ldf');
GO
------------------