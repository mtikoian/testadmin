DECLARE @FullBackupThreshold TINYINT,
		@DiffBackupThreshold TINYINT,
		@LogBackupThreshold TINYINT,
		@SQL NVARCHAR(MAX);
		
SET @FullBackupThreshold = 7;
SET @DiffBackupThreshold = 1;
SET @LogBackupThreshold = 6;

DECLARE @LastBackups TABLE
(
	database_name SYSNAME,
	recovery_model VARCHAR(100),
	days_since_full INT,
	needs_full BIT,
	full_command NVARCHAR(4000),
	days_since_diff INT,
	needs_diff BIT,
	diff_command NVARCHAR(4000),
	hours_since_log INT,
	needs_log BIT,
	log_command NVARCHAR(4000)
);

WITH BackupHistory AS
(
	SELECT	ROW_NUMBER() OVER (PARTITION BY database_name, type ORDER BY backup_finish_date DESC) row_id,
			bs.database_name,
			CASE bs.type
				WHEN 'I' THEN 'Differential'
				WHEN 'D' THEN 'Full'
				WHEN 'L' THEN 'Log'
			END backup_type,
			bs.backup_finish_date
	FROM	msdb.dbo.backupset bs
), LastFullBackup AS
(
	SELECT	database_name,
			backup_finish_date
	FROM	BackupHistory
	WHERE	backup_type = 'Full'
			AND row_id = 1
),LastDiffBackup AS
(
	SELECT	database_name,
			backup_finish_date
	FROM	BackupHistory
	WHERE	backup_type = 'Differential'
			AND row_id = 1
),LastLogBackup AS
(
	SELECT	database_name,
			backup_finish_date
	FROM	BackupHistory
	WHERE	backup_type = 'Log'
			AND row_id = 1
),LastBackups AS
(
	SELECT	db.name,
			db.recovery_model_desc,
			ISNULL(LastFull.backup_finish_date,'1/1/1900') last_full_date,
			ISNULL(LastDiff.backup_finish_date, '1/1/1900') last_diff_date,
			ISNULL(LastLog.backup_finish_date, '1/1/1900') last_log_date
	FROM	master.sys.databases db
				LEFT JOIN LastFullBackup LastFull
					ON LastFull.database_name = db.name
				LEFT JOIN LastDiffBackup LastDiff
					ON LastFull.database_name = LastDiff.database_name
				LEFT JOIN LastLogBackup LastLog
					ON LastFull.database_name = LastLog.database_name
	WHERE	db.name <> 'tempdb'
)
INSERT	@LastBackups
(
	database_name,
	recovery_model,
	days_since_full,
	needs_full,
	full_command,
	days_since_diff,
	needs_diff,
	diff_command,
	hours_since_log,
	needs_log,
	log_command
)
SELECT	name database_name,
		recovery_model_desc,
		ABS(DATEDIFF(DAY,GETDATE(),last_full_date)) days_since_full,
		CASE 
			WHEN ABS(DATEDIFF(DAY,GETDATE(),last_full_date)) > @FullBackupThreshold THEN 1
			ELSE 0
		END needs_full,
		'EXEC master.dbo.DatabaseBackup @databases=' + QUOTENAME(name,'''') + ', @backupType=''FULL'', @CleanupTime=336, @Verify=''Y'', @backupSoftware=''Litespeed''' full_command,
		ABS(DATEDIFF(DAY,GETDATE(),last_diff_date)) days_since_diff,
		CASE 
			WHEN (ABS(DATEDIFF(DAY,GETDATE(),last_diff_date)) > @DiffBackupThreshold) AND name <> 'master' THEN 1
			ELSE 0
		END needs_diff,
		'EXEC master.dbo.DatabaseBackup @databases=' + QUOTENAME(name,'''') + ', @backupType=''DIFF'', @CleanupTime=336, @Verify=''Y'', @backupSoftware=''Litespeed''' diff_command,
		ABS(DATEDIFF(HOUR,GETDATE(),last_log_date)) hours_since_log,
		CASE 
			WHEN (ABS(DATEDIFF(HOUR,GETDATE(),last_log_date)) > @LogBackupThreshold) AND recovery_model_desc = 'FULL' THEN 1
			ELSE 0
		END needs_log,
		'EXEC master.dbo.DatabaseBackup @databases=' + QUOTENAME(name,'''') + ', @backupType=''LOG'', @CleanupTime=48, @Verify=''Y'', @backupSoftware=''Litespeed''' log_command
FROM	LastBackups
WHERE	ABS(DATEDIFF(DAY,GETDATE(),last_full_date)) > @FullBackupThreshold
		OR (ABS(DATEDIFF(DAY,GETDATE(),last_diff_date)) > @DiffBackupThreshold AND name <> 'master')
		OR (ABS(DATEDIFF(HOUR,GETDATE(),last_log_date)) > @LogBackupThreshold AND recovery_model_desc = 'FULL');

-- Process full backups --
SELECT @SQL = (SELECT full_command + ';' + CHAR(10)
			   FROM	  @LastBackups
			   WHERE  needs_full = 1
			   FOR XML PATH(''));
EXEC(@SQL);

-- Process DIFF backups
SELECT @SQL = (SELECT diff_command + ';' + CHAR(10)
			   FROM	  @LastBackups
			   WHERE  needs_diff = 1
			   FOR XML PATH(''));
EXEC(@SQL);

-- Process LOG backups
SELECT @SQL = (SELECT log_command + ';' + CHAR(10)
			   FROM	  @LastBackups
			   WHERE  needs_log = 1
			   FOR XML PATH(''));
EXEC(@SQL);