-- Cleanup after Demos

-- LABDB01
:CONNECT LABDB01
DROP DATABASE ServerMonitor;
GO

EXEC msdb.dbo.sp_delete_alert @name=N'LABDB01 AdventureWorks Database Automatic Mirroring State Change';
GO
EXEC msdb.dbo.sp_delete_alert @name=N'LABDB01 AdventureWorks Database Manual Mirroring State Change';
GO

:CONNECT LABDB01
-- Delete Agent jobs from principal instance
EXEC msdb.dbo.sp_delete_job @job_name = N'Record Instance Level Metrics', @delete_unused_schedule = 1, @delete_history = 1;
GO
EXEC msdb.dbo.sp_delete_job @job_name = N'Check Mirroring Status of All Databases', @delete_unused_schedule = 1, @delete_history = 1;
GO
EXEC msdb.dbo.sp_delete_job @job_name = N'Synchronize Mirroring Status', @delete_unused_schedule = 1, @delete_history = 1;
GO

-- LABDB04
:CONNECT LABDB04
DROP DATABASE ServerMonitor;
GO

:CONNECT LABDB04
EXEC msdb.dbo.sp_delete_alert @name=N'LABDB04 AdventureWorks Database Automatic Mirroring State Change';
GO
EXEC msdb.dbo.sp_delete_alert @name=N'LABDB04 AdventureWorks Database Manual Mirroring State Change';
GO

-- Delete Agent jobs from mirror instance
:CONNECT LABDB04
EXEC msdb.dbo.sp_delete_job @job_name = N'Record Instance Level Metrics', @delete_unused_schedule = 1, @delete_history = 1;
GO
EXEC msdb.dbo.sp_delete_job @job_name = N'Check Mirroring Status of All Databases', @delete_unused_schedule = 1, @delete_history = 1;
GO
EXEC msdb.dbo.sp_delete_job @job_name = N'Synchronize Mirroring Status', @delete_unused_schedule = 1, @delete_history = 1;
GO