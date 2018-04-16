/* 
   *******************************************************************************
    ENVIRONMENT:    SQL 2000

	NAME:           BACKUPINFORMATION.sql

    DESCRIPTION:    THIS SCRIPT GIVES YOU THE LATEST DATABASE BACKUP INFORMATION
                    FOR ALL OR A GIVEN DATABASE.  

    INPUT:          @DBNAME
                        LEAVE BLANK TO LIST ALL DATABASES OR A SPECIFIC DATABASE
                        
                    @PRIORTO
                        THE DATE/TIME TO CHECK WHAT WAS THE LATEST BACKUP 
                        THAT OCCURRED PRIOR TO THAT.
                        
    OUTPUT:         RETURNS 5 RESULTS WHEN LISTING ALL DATABASES
    
                    RETURNS 3 RESULTS WHEN LISTING A SPECIFIC DATABASE
                    
                        * RESULT 1 
                              LIST ALL BACKUP INFORMATION FOR A GIVEN DATABASE
                        
                        * RESULT 2
                              LOG & DIFF COUNTS FOR EACH DATABASE, THIS BASICALLY
                              TAKE A QUICK GLANCE OF HOW MANY TIMES THESE TYPE
                              OF BACKUPS OCCUR.  A LOW NUMBER MAY INDICATE LOG
                              BACKUPS THAT MAY FAILED OR WAS MISSED FOR SOME
                              REASON.  REASON COULD BE A NEW DB OR A RECENT
                              FULL BACKUP OCCURRED.
                              
                        * RESULT 3
                              LIST THE AVERAGE LOG BACKUP BY HOUR.  GIVES YOU A
                              GENERAL IDEA HOW OFTEN A LOG BACKUP OCCURS PER HOUR.
                        
                        * RESULT 4
                              LIST ANY DATABASES THAT DO NOT HAVE A FULL BACKUP
                              
                        * RESULT 5
                              LIST ANY DATABASES THAT ARE NOT IN SIMPLE RECOVERY 
                              MODE THAT SHOULD HAVE A TRANSACTION LOG BACKUP.

    AUTHOR         DATE       VERSION  DESCRIPTION
    -------------- ---------- -------- ------------------------------------------
    AB82086        04/25/2011 1.0      INITIAL CREATION
    AB82086        07/20/2011 1.1      ADDED CODE TO SCRIPT RESTORE 
   *******************************************************************************
*/
SET NOCOUNT ON

DECLARE		@DbName			sysname
			,@PriorTo		datetime
			,@Type			char(1)
			,@BackupFile	varchar(1024)
			,@PrevDbName	varchar(128)
			,@PrevType		varchar(15)
			,@SQL			varchar(2048)
			,@Move			varchar(1024)
			,@CrLF			char(2)
			,@BackupSetId	int
			
SET @DbName = '' -- LEAVE BLANK FOR ALL OR SPECIFY A DB
SET @PriorTo = GETDATE()

SET @CrLf = CHAR(13) + CHAR(10)

/*
	GET THE LATEST FULL BACKUP PRIOR TO CERTAIN DATE
*/

SELECT		A.name AS [database_name]
			,A.crdate
			,DATABASEPROPERTYEX(A.name, 'Recovery') AS recovery_model_desc
			,B.physical_device_name			
			,B.type AS [backup_type]
			,B.first_lsn
			,B.last_lsn
			,B.checkpoint_lsn
			,B.database_backup_lsn
			,B.backup_start_date
			,B.backup_finish_date
			,B.backup_size/1024.0/1024.0 AS [backup_size_MB]
			,DATEDIFF(ss, B.backup_start_date, B.backup_finish_date) AS [backup_duration_seconds]
			,DATEDIFF(ss, B.backup_start_date, B.backup_finish_date)/60.0 AS [backup_duration_minutes]
			,CAST(B.backup_size / CASE WHEN DATEDIFF(ss, B.backup_start_date, B.backup_finish_date) = 0 
										THEN 1
										ELSE  DATEDIFF(ss, B.backup_start_date, B.backup_finish_date)
								  END / (1024 * 1024.0) AS NUMERIC(10, 5)) AS [backup_speed_MB_per_sec]
			,B.backup_set_id
INTO		#BackupInfo								  
FROM		master.dbo.sysdatabases A
				LEFT JOIN (
							SELECT		D.name
										,F.physical_device_name 
										,S.type
										,S.first_lsn
										,S.last_lsn
										,S.checkpoint_lsn
										,S.database_backup_lsn
										,S.backup_start_date
										,S.backup_finish_date
										,S.backup_size
										,S.backup_set_id
							FROM		master.dbo.sysdatabases				D
											JOIN msdb.dbo.backupset			S ON D.name				= S.database_name
											JOIN msdb.dbo.backupmediafamily	F ON S.media_set_id		= F.media_set_id
											JOIN (
													SELECT		D.name AS DbName
																,MAX(S.backup_start_date) AS backup_start_date
													FROM		master.dbo.sysdatabases				D
																	JOIN msdb.dbo.backupset			S ON D.name				= S.database_name
													WHERE		S.backup_finish_date IS NOT NULL
													  AND		S.type = 'D'
													  AND		s.backup_start_date < @PriorTo
													GROUP BY	D.name
												) LastFullBackup			ON S.database_name		= LastFullBackup.DbName
																		   AND S.backup_start_date	= LastFullBackup.backup_start_date
				          ) B ON A.name = B.name
WHERE		A.name <> 'tempdb'
  AND		(
				A.name = @DbName
					OR
				@DbName = ''
			)
ORDER BY	1

/*
	GET THE LATEST LOG AND/OR DIFFERENTIAL BACKUPS FOR THE LATEST FULL BACKUP WE HAVE
	
*/
INSERT INTO #BackupInfo
SELECT		A.database_name
			,A.crdate
			,A.recovery_model_desc
			,C.physical_device_name
			,B.type AS [backup_type]
			,B.first_lsn
			,B.last_lsn
			,B.checkpoint_lsn
			,B.database_backup_lsn
			,B.backup_start_date
			,B.backup_finish_date
			,B.backup_size/1024.0/1024.0 AS [backup_size_MB]
			,DATEDIFF(ss, B.backup_start_date, B.backup_finish_date) AS [backup_duration_seconds]
			,DATEDIFF(ss, B.backup_start_date, B.backup_finish_date)/60.0 AS [backup_duration_minutes]
			,CAST(B.backup_size / CASE WHEN DATEDIFF(ss, B.backup_start_date, B.backup_finish_date) = 0 
										THEN 1
										ELSE  DATEDIFF(ss, B.backup_start_date, B.backup_finish_date)
								  END / (1024 * 1024.0) AS NUMERIC(10, 5)) AS [backup_speed_MB_per_sec]
			,B.backup_set_id
FROM		#BackupInfo							A
				JOIN msdb.dbo.backupset			B ON A.database_name		= B.database_name
				                                 AND A.checkpoint_lsn		= B.database_backup_lsn
				                                 AND B.backup_start_date   >= A.backup_start_date
				JOIN msdb.dbo.backupmediafamily	C ON B.media_set_id			= C.media_set_id
WHERE		B.backup_start_date	>= A.backup_start_date
  AND		B.type <> 'D'
ORDER BY	A.database_name
			,B.backup_start_date

/*
	SUMMARY OF THE LATEST BACKUPS WE CURRENTLY HAVE 
*/
SELECT		database_name AS RS1_database_name
			,crdate
			,recovery_model_desc
			,backup_type
			,physical_device_name
			,backup_start_date
			,backup_finish_date
			,backup_size_MB
			,backup_duration_seconds
			,backup_duration_minutes
			,backup_speed_MB_per_sec
			,first_lsn
			,last_lsn
			,checkpoint_lsn
			,database_backup_lsn
FROM		#BackupInfo
ORDER BY	database_name
			,backup_start_date

/* 

	A SUMMARY OF HOW MANY LOG & DIFFERENTIAL OCCURS FOR A DATABASE
	
	** IF THE LOG OR DIFFERENTIAL COUNTS SEEMS LOW, THERE COULD BE AN 
	   ISSUE WITH THE BACKUP JOB
*/
SELECT		database_name  AS RS2_database_name
			,crdate
			,recovery_model_desc
			,backup_type
			,COUNT(*) AS [count]
FROM		#BackupInfo
WHERE		recovery_model_desc <> 'SIMPLE'
GROUP BY	database_name 
			,crdate
			,recovery_model_desc
			,backup_type 	
ORDER BY	database_name
			,backup_type			

/*
	DETERMINES AVG LOG BACKUP TIMES PER HOUR
*/
SELECT		A.database_name  AS RS3_database_name
			,AVG(DATEDIFF(Hh, A.backup_start_date, B.backup_start_date) * 1.0) AS avg_log_backup_per_hour
FROM		#BackupInfo A
				JOIN #BackupInfo B ON A.database_name = B.database_name
				                  AND B.backup_start_date = (SELECT TOP 1 backup_start_date FROM #BackupInfo C WHERE A.database_name = C.database_name AND C.backup_start_date > A.backup_start_date)
WHERE		A.backup_type = 'L'
GROUP BY	A.database_name 

/* 

	LIST ANY DATABASE THAT IS MISSING A FULL DATABASE BACKUP 
*/
IF ISNULL(@DbName, '') = ''
	SELECT		A.name AS [RS4_database_with_no_full_backup]
				,A.crdate
				,DATABASEPROPERTYEX(A.name, 'Recovery') AS recovery_model_desc
	FROM		master.dbo.sysdatabases A
					LEFT JOIN #BackupInfo B ON A.name = B.database_name
	WHERE		DATABASEPROPERTYEX(A.name, 'Status') = 'ONLINE'
	  AND		A.name <> 'tempdb'
	  AND		B.database_name IS NULL
  
/*
	LIST ANY DATABASES THAT SHOULD HAVE LOG BACKUPS
	
	** SOME OF THESE DATABASES COULD BE IGNORE OR THERE IS AN ISSUE
	   WITH THE LOG BACKUP JOB
	   
	** IF A LOG BACKUP DOESN'T OCCUR BECAUSE "BACKUP LOG cannot be 
	   performed because there is no current database backup." THIS
	   COULD OCCUR IF SOMEONE ISSUE "BACKUP LOG WITH TRUNCATE_ONLY or 
	   WITH NO_LOG" STATEMENT.  WHEN RUNNING EITHER OF THOSE STATEMENTS
	   IT WILL BREAK THE DATABASE BACKUP CHAIN.
*/
IF ISNULL(@DbName, '') = ''
	SELECT		A.database_name  AS [RS5_database_with_no_log_backup]
				,A.crdate
				,A.recovery_model_desc
	FROM		#BackupInfo A
					LEFT JOIN (
								SELECT		database_name
								FROM		#BackupInfo
								WHERE		backup_type = 'L'
							  ) B ON A.database_name = B.database_name
	WHERE		A.recovery_model_desc <> 'SIMPLE'
	  AND		B.database_name IS NULL


DECLARE CURSOR_RESTOREINFO CURSOR FAST_FORWARD
FOR
	SELECT		database_name
				,backup_type
				,physical_device_name
				,backup_set_id
	FROM		#BackupInfo
	ORDER BY	database_name
				,backup_start_date
				
OPEN CURSOR_RESTOREINFO

FETCH NEXT FROM CURSOR_RESTOREINFO
INTO @DbName, @Type, @BackupFile, @BackupSetId

SET @PrevDbName = @DbName
SET @PrevType = @Type

IF @@FETCH_STATUS <> 0
	PRINT CONVERT(varchar(30), GETDATE(), 109)+ '     *** NO FILES TO RESTORE'
ELSE
	BEGIN 
		WHILE @@FETCH_STATUS = 0
		BEGIN			
			SET @Move = ''
			
			IF @Type = 'D'
				BEGIN 
					PRINT ' -- FULL BEING RESTORED FOR DATABASE ' + UPPER(@DbName)
					
					SELECT		@Move = @Move + '        MOVE N''' + logical_name + ''' TO N''' + physical_name + ''',' + @CrLf
					FROM		msdb.dbo.backupfile
					WHERE		backup_set_id = @BackupSetId
					
					PRINT 'RESTORE DATABASE ' + QUOTENAME(@DbName) 
					PRINT 'FROM DISK = N''' + @BackupFile + ''''
					PRINT 'WITH'
					PRINT @Move
					PRINT '        STATS = 10,'
				END
			ELSE
				BEGIN
					IF @Type = 'I'
						BEGIN
							PRINT 'RESTORE DATABASE ' + QUOTENAME(@DbName) 
							PRINT 'FROM DISK = N''' + @BackupFile + ''''
							PRINT 'WITH'
							PRINT '        STATS = 10,'				
						END
					ELSE
						BEGIN				
							PRINT 'RESTORE LOG ' + QUOTENAME(@DbName) 
							PRINT 'FROM DISK = N''' + @BackupFile + ''''
							PRINT 'WITH'
							PRINT '        STATS = 10,'									
						END
				END
																	
			FETCH NEXT FROM CURSOR_RESTOREINFO
			INTO @DbName, @Type, @BackupFile, @BackupSetId

			IF @PrevDbName <> ISNULL(@DbName, '') OR @Type = 'D' OR @@FETCH_STATUS <> 0
				BEGIN
					PRINT '        RECOVERY'	
					PRINT ''
					
					SET @PrevDbName = @DbName
				END
			ELSE
				BEGIN
					PRINT '        NORECOVERY'	
					PRINT ''
				END
		END
	END
	
CLOSE CURSOR_RESTOREINFO
DEALLOCATE CURSOR_RESTOREINFO

DROP TABLE #BackupInfo

