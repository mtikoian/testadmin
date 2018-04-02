USE PerfDB;
SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MonitorReplicationAgentsSchedules]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[MonitorReplicationAgentsSchedules];
GO


CREATE PROCEDURE MonitorReplicationAgentsSchedules
(
	@CategoryId int
)
/*

	20080911 Yaniv Etrogi  
	http://www.sqlserverutilities.com	

	Check that replication agents have an additional schedule as required and create the schedule if missing.


	SELECT category_id, name FROM msdb.dbo.syscategories ORDER BY 1

	10	REPL-Distribution
	11	REPL-Distribution Cleanup
	12	REPL-History Cleanup
	13	REPL-LogReader
	14	REPL-Merge
	15	REPL-Snapshot

*/
AS
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  


--EXEC PerfDB.dbo.MonitorReplicationAgentsSchedules @CategoryId = 13;


-- Add a second schedule that runs every 1 minutes
DECLARE cur CURSOR LOCAL READ_ONLY FAST_FORWARD FOR 
	SELECT job_id, name FROM msdb.dbo.sysjobs WHERE category_id = @CategoryId;

SET NOCOUNT ON;
OPEN cur
DECLARE @JobID uniqueidentifier, @Name sysname; 

	FETCH NEXT FROM cur INTO @JobID, @Name;
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN;		
	
	-- If thete is no such schedule yet
	IF NOT EXISTS (SELECT j.job_id, j.name FROM msdb.dbo.sysjobs j
					LEFT JOIN msdb.dbo.sysjobschedules s ON s.job_id = j.job_id
						LEFT JOIN msdb.dbo.sysschedules sc ON sc.schedule_id = s.schedule_id
							WHERE j.category_id = @CategoryId AND j.job_id = @JobID AND sc.name = N'1_Minute' )
	
	BEGIN;
		PRINT 'JobName: ' + @Name + '    JobId: ' + CAST(@JobID AS sysname);

		EXEC msdb.dbo.sp_add_jobschedule 
				@job_id										= @JobID
				,@name										= N'1_Minute'
				,@enabled									= 1
				,@freq_type								= 4
				,@active_start_date				= 20080311
				,@active_start_time				= 0
				,@freq_interval						= 1 
				,@freq_subday_type				= 4
				,@freq_subday_interval		= 1
				,@freq_relative_interval	= 0
				,@freq_recurrence_factor	= 1
				,@active_end_date					= 99991231
				,@active_end_time					= 235959;
	END	ELSE
		--PRINT 'JobName: ' + @Name + '    JobId: ' + CAST(@JobID AS sysname) + ' Schedule already exists.';
		
	FETCH NEXT FROM cur INTO @JobID, @Name;
	END;
CLOSE cur; DEALLOCATE cur;
GO
