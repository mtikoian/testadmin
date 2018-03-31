EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'priority boost', N'1'
GO
EXEC sys.sp_configure N'network packet size (B)', N'1500'
GO
EXEC sys.sp_configure N'min server memory (MB)', N'512'
GO
EXEC sys.sp_configure N'max server memory (MB)', N'2048'
GO
RECONFIGURE
GO
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
GO