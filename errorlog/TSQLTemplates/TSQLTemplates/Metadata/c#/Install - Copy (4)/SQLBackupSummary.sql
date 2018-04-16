SET NOCOUNT ON

DECLARE @Today				datetime
		,@Yesterday			datetime
		,@TwoDaysAgo		datetime
		,@ThreeDaysAgo		datetime
		,@SQL				varchar(4000)

SET @Today = CONVERT(char(10), GETDATE(), 112) -- Today's Date @ Midnight
SET @Yesterday = DATEADD(dd, -1, @Today)
SET @TwoDaysAgo = DATEADD(dd, -2, @Today)
SET @ThreeDaysAgo = DATEADD(dd, -3, @Today)
SET @SQL = ''

CREATE TABLE #LastBackupInfo
(
	DbName				varchar(128)
	,BackupType			char(1)
	,BackupStartDate	datetime
	,BackupFinishDate	datetime
	,BackupSize			numeric(20,0) 
	,BackupUser			varchar(128)
	,BackupSetName		varchar(256)
	,BackupFileName		varchar(512)
)
/* GET LAST BACKUP INFO */
SET @SQL = 'SELECT		B.DbName '
SET @SQL = @SQL +     ',B.BackupType '
SET @SQL = @SQL +     ',S.backup_start_date '
SET @SQL = @SQL +     ',S.backup_finish_date '
SET @SQL = @SQL +     ',S.backup_size ' 
SET @SQL = @SQL +     ',S.user_name ' 
SET @SQL = @SQL +     ',S.name ' 
SET @SQL = @SQL +     ',F.physical_device_name ' 
SET @SQL = @SQL +     
		   'FROM		msdb.dbo.backupset	S '
SET @SQL = @SQL +          'JOIN msdb.dbo.backupmediafamily F ON S.media_set_id = F.media_set_id '
SET @SQL = @SQL +          'JOIN	( '
SET @SQL = @SQL +                        'SELECT	X.name	AS DbName '
SET @SQL = @SQL +                                  ',Z.type	AS BackupType '
SET @SQL = @SQL +                                  ',MAX(Z.backup_set_id) AS LastBackupSetId '
SET @SQL = @SQL +                        'FROM		master.dbo.sysdatabases				X '
SET @SQL = @SQL +										'JOIN msdb.dbo.backupset		Z ON X.name	= Z.database_name COLLATE DATABASE_DEFAULT '
SET @SQL = @SQL +                        'WHERE		Z.type IN (''D'', ''I'', ''L'') '

IF LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), 1) <> '8'
	SET @SQL = @SQL +                      'AND		Z.is_copy_only = 0 '

SET @SQL = @SQL +                        'GROUP BY	X.name '
SET @SQL = @SQL +                                  ',Z.type '
SET @SQL = @SQL +                   ')	B	ON S.backup_set_id = B.LastBackupSetId '

INSERT INTO #LastBackupInfo
EXECUTE (@SQL)

SELECT		D.name + '<1>' +
				'Full' + '<2>' +
				ISNULL(CONVERT(varchar(19), MAX(L.BackupStartDate), 120), 'NULL') + '<3>' +
				ISNULL(CONVERT(varchar(19), MAX(L.BackupFinishDate), 120), 'NULL') + '<4>' +
				ISNULL(CAST(L.BackupSize AS varchar(25)), 'NULL') + '<5>' +
				ISNULL(CAST(DATEDIFF(d, MAX(L.BackupFinishDate), GETDATE()) AS varchar(10)), 'NULL') + '<6>' +
				ISNULL(CAST(SUM(
						CASE WHEN S.backup_finish_date >= @Today
							THEN 1
							ELSE 0
						END
				   ) AS varchar(5)), 'NULL') + '<7>' +
				ISNULL(CAST(SUM(
						CASE WHEN S.backup_finish_date BETWEEN @Yesterday AND DATEADD(ss, -1, @Today)
							THEN 1
							ELSE 0
						END
				   ) AS varchar(5)), 'NULL') + '<8>' +
				ISNULL(CAST(SUM(
						CASE WHEN S.backup_finish_date BETWEEN @TwoDaysAgo AND DATEADD(ss, -1, @Yesterday)
							THEN 1
							ELSE 0
						END
				   ) AS varchar(5)), 'NULL') + '<9>' +
				ISNULL(CAST(SUM(
						CASE WHEN S.backup_finish_date BETWEEN @ThreeDaysAgo AND DATEADD(ss, -1, @TwoDaysAgo)
							THEN 1
							ELSE 0
						END
				   ) AS varchar(5)), 'NULL') + '<10>' +
				ISNULL(L.BackupUser, 'NULL') + '<11>' + 
				ISNULL(L.BackupSetName, 'NULL') + '<12>' + 
				ISNULL(L.BackupFileName, 'NULL')
FROM		master.dbo.sysdatabases				D
				LEFT JOIN msdb.dbo.backupset	S ON D.name				= S.database_name COLLATE DATABASE_DEFAULT 
												 AND UPPER(S.type)		= 'D' -- DATABASE BACKUP
												 AND DATEDIFF(d, S.backup_finish_date, GETDATE()) <= 3
				LEFT JOIN #LastBackupInfo		L ON D.name				= L.DbName COLLATE DATABASE_DEFAULT 
												 AND L.BackupType		= 'D'
WHERE		D.name NOT IN ('tempdb')
GROUP BY	D.name
			,L.BackupSize
			,L.BackupUser
			,L.BackupSetName
			,L.BackupFileName						
UNION ALL
SELECT		D.name + '<1>' +
				'Log' + '<2>' +
				ISNULL(CONVERT(varchar(19), MAX(L.BackupStartDate), 120), 'NULL') + '<3>' +
				ISNULL(CONVERT(varchar(19), MAX(L.BackupFinishDate), 120), 'NULL') + '<4>' +
				ISNULL(CAST(L.BackupSize AS varchar(25)), 'NULL') + '<5>' +
				ISNULL(CAST(DATEDIFF(d, MAX(L.BackupFinishDate), GETDATE()) AS varchar(10)), 'NULL') + '<6>' +
				ISNULL(CAST(SUM(
						CASE WHEN S.backup_finish_date >= @Today
							THEN 1
							ELSE 0
						END
				   ) AS varchar(5)), 'NULL') + '<7>' +
				ISNULL(CAST(SUM(
						CASE WHEN S.backup_finish_date BETWEEN @Yesterday AND DATEADD(ss, -1, @Today)
							THEN 1
							ELSE 0
						END
				   ) AS varchar(5)), 'NULL') + '<8>' +
				ISNULL(CAST(SUM(
						CASE WHEN S.backup_finish_date BETWEEN @TwoDaysAgo AND DATEADD(ss, -1, @Yesterday)
							THEN 1
							ELSE 0
						END
				   ) AS varchar(5)), 'NULL') + '<9>' +
				ISNULL(CAST(SUM(
						CASE WHEN S.backup_finish_date BETWEEN @ThreeDaysAgo AND DATEADD(ss, -1, @TwoDaysAgo)
							THEN 1
							ELSE 0
						END
				   ) AS varchar(5)), 'NULL') + '<10>' +
				ISNULL(L.BackupUser, 'NULL') + '<11>' + 
				ISNULL(L.BackupSetName, 'NULL') + '<12>' + 
				ISNULL(L.BackupFileName, 'NULL')
FROM		master.dbo.sysdatabases				D
				LEFT JOIN msdb.dbo.backupset	S ON D.name				= S.database_name COLLATE DATABASE_DEFAULT 
												 AND UPPER(S.type)		= 'L' -- LOG BACKUP
												 AND DATEDIFF(d, S.backup_finish_date, GETDATE()) <= 3
				LEFT JOIN #LastBackupInfo		L ON D.name				= L.DbName COLLATE DATABASE_DEFAULT 
												 AND L.BackupType		= 'L'
WHERE		DATABASEPROPERTYEX(D.name, 'Recovery') IN ('FULL', 'BULK_LOGGED')
GROUP BY	D.name
			,L.BackupSize
			,L.BackupUser
			,L.BackupSetName
			,L.BackupFileName
UNION ALL
SELECT		D.name + '<1>' +
				'Differential' + '<2>' +
				ISNULL(CONVERT(varchar(19), MAX(L.BackupStartDate), 120), 'NULL') + '<3>' +
				ISNULL(CONVERT(varchar(19), MAX(L.BackupFinishDate), 120), 'NULL') + '<4>' +
				ISNULL(CAST(L.BackupSize AS varchar(25)), 'NULL') + '<5>' +
				ISNULL(CAST(DATEDIFF(d, MAX(L.BackupFinishDate), GETDATE()) AS varchar(10)), 'NULL') + '<6>' +
				ISNULL(CAST(SUM(
						CASE WHEN S.backup_finish_date >= @Today
							THEN 1
							ELSE 0
						END
				   ) AS varchar(5)), 'NULL') + '<7>' +
				ISNULL(CAST(SUM(
						CASE WHEN S.backup_finish_date BETWEEN @Yesterday AND DATEADD(ss, -1, @Today)
							THEN 1
							ELSE 0
						END
				   ) AS varchar(5)), 'NULL') + '<8>' +
				ISNULL(CAST(SUM(
						CASE WHEN S.backup_finish_date BETWEEN @TwoDaysAgo AND DATEADD(ss, -1, @Yesterday)
							THEN 1
							ELSE 0
						END
				   ) AS varchar(5)), 'NULL') + '<9>' +
				ISNULL(CAST(SUM(
						CASE WHEN S.backup_finish_date BETWEEN @ThreeDaysAgo AND DATEADD(ss, -1, @TwoDaysAgo)
							THEN 1
							ELSE 0
						END
				   ) AS varchar(5)), 'NULL') + '<10>' +
				ISNULL(L.BackupUser, 'NULL') + '<11>' + 
				ISNULL(L.BackupSetName, 'NULL') + '<12>' + 
				ISNULL(L.BackupFileName, 'NULL')
FROM		master.dbo.sysdatabases				D
				LEFT JOIN msdb.dbo.backupset	S ON D.name				= S.database_name COLLATE DATABASE_DEFAULT 
												 AND UPPER(S.type)		= 'I' -- DIFFERENTIAL BACKUP
												 AND DATEDIFF(d, S.backup_finish_date, GETDATE()) <= 3
				LEFT JOIN #LastBackupInfo		L ON D.name				= L.DbName COLLATE DATABASE_DEFAULT 
												 AND L.BackupType		= 'I'
WHERE		D.name NOT IN ('master', 'tempdb')
GROUP BY	D.name
			,L.BackupSize
			,L.BackupUser
			,L.BackupSetName
			,L.BackupFileName
ORDER BY	1

DROP TABLE #LastBackupInfo