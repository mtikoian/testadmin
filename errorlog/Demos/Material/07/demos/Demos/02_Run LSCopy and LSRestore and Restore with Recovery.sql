-- Run LSCopy and LSRestore and Restore with Recovery
-- Run on LS Secondary

-- Get LSCopy jobs
SELECT [name] 
FROM msdb.dbo.sysjobs 
WHERE category_id = 6
AND LEFT([name], 6) = N'LSCopy'
ORDER BY [name];


-- Run all LSCopy jobs
EXEC msdb.dbo.sp_start_job N'LSCopy_LABDB03_AdventureWorksLT2008R2';



-- Get information about most recent executions of LS jobs
SELECT TOP(10) jh.server, sj.name AS [JobName], sj.[description] AS [JobDescription], 
msdb.dbo.agent_datetime(jh.run_date, jh.run_time) AS [RunDateTime],
STUFF(STUFF(REPLACE(STR(run_duration,6,0),' ','0'),3,0,':'),6,0,':') AS [RunDuration]
FROM msdb.dbo.sysjobs AS sj WITH (NOLOCK)
INNER JOIN msdb.dbo.sysjobhistory AS jh WITH (NOLOCK)
ON sj.job_id = jh.job_id
WHERE sj.category_id = 6
AND jh.run_status = 1
AND jh.step_id = 0
AND sj.enabled = 1
AND sj.name IN (SELECT [name] 
			    FROM msdb.dbo.sysjobs 
				WHERE category_id = 6
				AND LEFT([name], 6) = N'LSCopy')
ORDER BY RunDateTime DESC, sj.name DESC OPTION (RECOMPILE);

-- Get LSRestore jobs
SELECT [name] 
FROM msdb.dbo.sysjobs 
WHERE category_id = 6
AND LEFT([name], 9) = N'LSRestore'
ORDER BY [name];

-- Run all LSRestore jobs
EXEC msdb.dbo.sp_start_job N'LSRestore_LABDB03_AdventureWorksLT2008R2';



-- Get information about most recent executions of LS jobs
SELECT TOP(10) jh.server, sj.name AS [JobName], sj.[description] AS [JobDescription], 
msdb.dbo.agent_datetime(jh.run_date, jh.run_time) AS [RunDateTime],
STUFF(STUFF(REPLACE(STR(run_duration,6,0),' ','0'),3,0,':'),6,0,':') AS [RunDuration]
FROM msdb.dbo.sysjobs AS sj WITH (NOLOCK)
INNER JOIN msdb.dbo.sysjobhistory AS jh WITH (NOLOCK)
ON sj.job_id = jh.job_id
WHERE sj.category_id = 6
AND jh.run_status = 1
AND jh.step_id = 0
AND sj.enabled = 1
AND sj.name IN (SELECT [name] 
			    FROM msdb.dbo.sysjobs 
				WHERE category_id = 6
				AND LEFT([name], 9) = N'LSRestore')
ORDER BY RunDateTime DESC, sj.name DESC OPTION (RECOMPILE);


-- Get last restore date for log shipped secondary databases (run on secondary instance)
SELECT secondary_database, last_restored_date
FROM msdb.dbo.log_shipping_secondary_databases
ORDER BY last_restored_date;

-- Restore all databases with recovery
-- RESTORE DATABASE AdventureWorksLT2008R2 WITH RECOVERY;
