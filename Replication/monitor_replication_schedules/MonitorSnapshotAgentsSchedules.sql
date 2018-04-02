USE [PerfDB];
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MonitorSnapshotAgentsSchedules]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].MonitorSnapshotAgentsSchedules;
GO

  
  
CREATE PROCEDURE MonitorSnapshotAgentsSchedules  
AS  
/*
	20080911 Yaniv Etrogi  
	http://www.sqlserverutilities.com	
  Check that Snapshot agents do not have a schedule and delete the sched if exists.  
*/
SET NOCOUNT ON;  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
  
  
/*  
EXEC PerfDB.dbo.MonitorSnapshotAgentsSchedules  
*/  
  
  
-- Disable the Snapshot schedule.  
UPDATE msdb..sysjobs SET [enabled] = 0 WHERE category_id = 15 ;  
  
  
-- Delete the Snapshot schedule.  
DECLARE cur CURSOR LOCAL FAST_FORWARD FOR   
 SELECT sc.schedule_id, sc.name FROM msdb..sysjobs j  
  INNER JOIN msdb..sysjobschedules s ON s.job_id = j.job_id  
   INNER JOIN msdb..sysschedules sc ON sc.schedule_id = s.schedule_id  
    WHERE j.category_id = 15 ;  
  
SET NOCOUNT ON;  
OPEN cur  
DECLARE @ScheduleId int, @Name sysname;   
 FETCH NEXT FROM cur INTO @ScheduleId, @Name;  
 WHILE (@@FETCH_STATUS <> -1)  
 BEGIN    
  BEGIN  
   PRINT 'JobName: ' + @Name + '    JobId: ' + CAST(@ScheduleId AS sysname);  
   EXEC msdb.dbo.sp_delete_schedule @schedule_id = @ScheduleId, @force_delete = 1 ;  
  END --ELSE  
  --PRINT 'JobName: ' + @Name + '    JobId: ' + CAST(@ScheduleId AS sysname) + ' Schedule does not exists.';  
 FETCH NEXT FROM cur INTO @ScheduleId, @Name;  
 END;  
CLOSE cur; DEALLOCATE cur;  