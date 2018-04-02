USE [PerfDB]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MonitorEnableReplicationAgents]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[MonitorEnableReplicationAgents];
GO

  
CREATE PROCEDURE MonitorEnableReplicationAgents  
(  
  @CategoryId int  
)  
/*
	20080911 Yaniv Etrogi  
	http://www.sqlserverutilities.com	

	Enable jobs by Category.  

	SELECT category_id, name FROM msdb..syscategories ORDER BY 1
	SELECT job_id, name, enabled FROM msdb..sysjobs WHERE category_id = 14  

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

  
-- EXEC PerfDB.dbo.MonitorEnableReplicationAgents @CategoryId = 14;
  
  
DECLARE @MaxJobLen int;   
  
-- Get the job name just for the sake of identitation of the print.  
SELECT @MaxJobLen = LEN(MAX(DISTINCT [name])) FROM msdb.dbo.sysjobs WHERE category_id = @CategoryId AND [enabled] = 0;  
--SELECT @MaxJobLen  
  
DECLARE cur CURSOR LOCAL READ_ONLY FAST_FORWARD FOR 
	SELECT DISTINCT job_id, [name] FROM msdb.dbo.sysjobs WHERE category_id = @CategoryId AND [enabled] = 0;  
   
SET NOCOUNT ON;  
OPEN cur;  
DECLARE @JobId uniqueidentifier, @Name sysname;   
  
 FETCH NEXT FROM cur INTO @JobId, @Name;  
 WHILE (@@FETCH_STATUS <> -1)  
 BEGIN;    
 
		PRINT 'Enabling JobName: ' + @Name + REPLICATE(' ', (@MaxJobLen + 2) - LEN(@Name))  + 'JobId: ' + CAST(@JobId AS sysname);  
		EXEC msdb.dbo.sp_update_job @job_id = @JobId, @enabled = 1;  
		
 FETCH NEXT FROM cur INTO @JobId, @Name;  
 END;  
CLOSE cur; DEALLOCATE cur;  
GO