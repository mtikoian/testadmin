/* 
   *******************************************************************************
    ENVIRONMENT:    ALL

	NAME:           TSMBACKUPSCHEDULEINFO_DC.SQL

    DESCRIPTION:    THIS SCRIPT GIVES YOU MULTIPLE INFORMATION.  IF PRESENT, IT 
                    LOOKS FOR THE TSM BACKUP LOG, READS THE INFORMATION AND 
                    REPORTS WHERE THE LOG IS LOCATED, SCHEDULE INFO & START AND
                    THE PATH THAT IT BACKS UP.

    INPUT:          N/A
                        
    OUTPUT:         RETURNS RESULTSET THAT CONSIST OF THE LOGFILE THAT WAS READ,
                    BACKUP SCHEDULE DATE, START, END AND BACKUP PATHS.  THERE WILL 
                    MULTIPLE RECORDS TO SHOW YOU WHAT ALL INFO IS CAPTURED IN THE 
                    LOG FILE IT IS SORTED BY LOGFILE AND BACKUP SCHEDULE DATE.
    
    NOTES:          *** YOU MAY GET ERROR IF ITS UNABLE TO ACCESS THE FILE
                        SOMETHING ON THE OS SOMETIMES HAS IT LOCKED.
                        
    AUTHOR         DATE       VERSION  DESCRIPTION
    -------------- ---------- -------- ------------------------------------------
    AB82086        07/20/2011 1.0      INITIAL CREATION
    AB82086        04/09/2012 2.0      REVISED THE SCRIPT TO RETURN ON RESULTSET
                                       IT WILL GIVE YOU THE LOG FILE LOCATION,
                                       BACKUP SCHEDULE DATE, START, END AND PATHS
   *******************************************************************************
*/
SET NOCOUNT ON

DECLARE @SQL		                varchar(1024)
		,@Key                       varchar(256)
		,@TSMLog                    varchar(256)
		,@BackupPaths               varchar(2048)
		,@BackupScheduleName        varchar(128)
		,@BackupStart               datetime
		,@BackupEnd                 datetime
        ,@ObjectsInspected          int
        ,@ObjectsAssigned           int
        ,@ObjectsBackedUp           int
        ,@ObjectsUpdated            int
        ,@ObjectsRebound            int
        ,@ObjectsDeleted            int
        ,@ObjectsExpired            int
        ,@ObjectsFailed             int
        ,@SubfileObjects            int
        ,@BytesInspected            varchar(25)
        ,@BytesTransferred          varchar(25)
        ,@DataTransferTime          varchar(25)
        ,@DataTransferRate          varchar(25)
        ,@AggDataTransferRate       varchar(25)
        ,@CompressPercentage        varchar(10)
        ,@DataReductionRatio        varchar(10)
        ,@SubfileObjectsReduceBy    varchar(10)
        ,@ElapseProcessingTime      varchar(15)

IF OBJECT_ID('tempdb..#ServicesKeys') IS NOT NULL
    DROP TABLE #ServicesKeys

IF OBJECT_ID('tempdb..#TSMLog') IS NOT NULL
    DROP TABLE #TSMLog

IF OBJECT_ID('tempdb..#RawData') IS NOT NULL
    DROP TABLE #RawData

IF OBJECT_ID('tempdb..#BackupItems') IS NOT NULL
    DROP TABLE #BackupItems

IF OBJECT_ID('tempdb..#Report') IS NOT NULL
    DROP TABLE #Report
    
CREATE TABLE #ServicesKeys
(
	KeyName		varchar(256)
)

CREATE TABLE #TSMLog
(
	Filename		varchar(256)
)

CREATE TABLE #RawData
(
	Value		varchar(2048)
)

CREATE TABLE #BackupItems
(
    Name        varchar(256)
)
        
CREATE TABLE #Report
(
    LogFile                 varchar(256)
    ,BackupScheduleName     varchar(128)
    ,BackupScheduleDate     datetime
    ,BackupStart            datetime
    ,BackupEnd              datetime
    ,BackupPaths            varchar(2048)
    ,ObjectsInspected       int
    ,ObjectsAssigned        int
    ,ObjectsBackedUp        int
    ,ObjectsUpdated         int
    ,ObjectsRebound         int
    ,ObjectsDeleted         int
    ,ObjectsExpired         int
    ,ObjectsFailed          int
    ,SubfileObjects         int
    ,BytesInspected         varchar(25)
    ,BytesTransferred       varchar(25)
    ,DataTransferTime       varchar(25)
    ,DataTransferRate       varchar(25)
    ,AggDataTransferRate    varchar(25)
    ,CompressPercentage     varchar(10)
    ,DataReductionRatio     varchar(10)
    ,SubfileObjectsReduceBy varchar(10)
    ,ElapseProcessingTime   varchar(15)
)
      
      
INSERT INTO #ServicesKeys
EXECUTE xp_instance_regenumkeys N'HKEY_LOCAL_MACHINE', 'SYSTEM\CurrentControlSet\Services\'

DECLARE CUSROR_TSM_KEYS CURSOR FAST_FORWARD
FOR
    SELECT      KeyName
    FROM        #ServicesKeys
    WHERE       UPPER(KeyName) LIKE 'TSM SCHEDULER SERVICE%'
    UNION
    SELECT      KeyName
    FROM        #ServicesKeys
    WHERE       UPPER(KeyName) LIKE 'TSM CLIENT SCHEDULER%'
    
OPEN CUSROR_TSM_KEYS

FETCH NEXT FROM CUSROR_TSM_KEYS
INTO @Key

WHILE @@FETCH_STATUS = 0
BEGIN 
    SET @TSMLog= NULL        
    SET @Key = 'SYSTEM\CurrentControlSet\Services\' + @Key + '\Parameters'
       
    EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE'
							    ,@Key
							    ,'ScheduleLog'
							    ,@TSMLog OUTPUT

    IF @TSMLog IS NOT NULL
        BEGIN            
            IF NOT EXISTS(SELECT * FROM #TSMLog WHERE Filename = @TSMLog)
                INSERT INTO #TSMLog VALUES (@TSMLog)
        END
    ELSE
        BEGIN
            EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE'
					                    ,@Key
					                    ,'OptionsFile'
					                    ,@TSMLog OUTPUT
					                    
            IF @TSMLog IS NOT NULL
                BEGIN
                                    
                    SET @TSMLog =  LEFT(@TSMLog, LEN(@TSMLog) - CHARINDEX('\', REVERSE(@TSMLog))) + '\' + 'dsmsched.log'
                    
                    IF NOT EXISTS(SELECT * FROM #TSMLog WHERE Filename = @TSMLog)
                        INSERT INTO #TSMLog VALUES (@TSMLog)
                END
        END
        
    FETCH NEXT FROM CUSROR_TSM_KEYS
    INTO @Key
END

CLOSE CUSROR_TSM_KEYS
DEALLOCATE CUSROR_TSM_KEYS

DECLARE CURSOR_LOG_PATH CURSOR FAST_FORWARD
FOR
       SELECT       Filename
       FROM         #TSMLog

OPEN CURSOR_LOG_PATH

FETCH NEXT FROM CURSOR_LOG_PATH 
INTO @TSMLog

IF @@FETCH_STATUS <> 0
    INSERT INTO #Report VALUES ('TSM Backups Job Missing', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)    
ELSE
    BEGIN
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @SQL = 'BULK INSERT #RawData FROM ''' + @TSMLog + ''' '
            EXECUTE (@SQL)            

            IF @@ERROR > 0
                INSERT INTO #Report VALUES (@TSMLog, 'Unable to access log file.', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)    
            ELSE
                BEGIN 
                    DELETE FROM #RawData WHERE ISDATE(LEFT(Value, 19)) = 0
                
                    DECLARE CURSOR_BACKUP_RANGE CURSOR FAST_FORWARD    
                    FOR
                        SELECT		TOP 5 REPLACE(REPLACE(REPLACE(SUBSTRING(Value, 25, LEN(Value)), 'BEGIN', ''), 'END', ''), 'SCHEDULEREC OBJECT  ', '')
                                    ,MIN(CAST(LEFT(Value, 19) AS datetime))
                                    ,MAX(CAST(LEFT(Value, 19) AS datetime))
                        FROM		#RawData 
                        WHERE		Value LIKE '%SCHEDULEREC OBJECT%'
                        GROUP BY    REPLACE(REPLACE(REPLACE(SUBSTRING(Value, 25, LEN(Value)), 'BEGIN', ''), 'END', ''), 'SCHEDULEREC OBJECT  ', '')
                        ORDER BY    2 DESC

                    OPEN CURSOR_BACKUP_RANGE
                    
                    FETCH NEXT FROM CURSOR_BACKUP_RANGE
                    INTO @BackupScheduleName, @BackupStart, @BackupEnd    

                    WHILE @@FETCH_STATUS = 0 
                    BEGIN
                        SET @BackupPaths = ''

                        INSERT INTO #BackupItems
                        SELECT		DISTINCT REPLACE(RIGHT(Value, LEN(Value) - CHARINDEX('Incremental backup of volume ', Value) - 29) , '''', '')
                        FROM		#RawData
                        WHERE		Value LIKE '%Incremental backup of volume %'
                          AND       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                        ORDER BY	1

                        SELECT      @BackupPaths = @BackupPaths + QUOTENAME(Name) + ', '
                        FROM        #BackupItems

                        IF LEN(@BackupPaths) > 1
                            SET @BackupPaths = LEFT(@BackupPaths, LEN(@BackupPaths) - 1)    

                        SELECT      @ObjectsInspected = CAST(REPLACE(LTRIM(SUBSTRING(Value, 55, LEN(Value))), ',', '') AS int)
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Total number of objects inspected:   %'

                        SELECT      @ObjectsAssigned = CAST(REPLACE(LTRIM(SUBSTRING(Value, 54, LEN(Value))), ',', '') AS int)
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Total number of objects assigned:%'

                        SELECT      @ObjectsBackedUp = CAST(REPLACE(LTRIM(SUBSTRING(Value, 55, LEN(Value))), ',', '') AS int)
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Total number of objects backed up:%'

                        SELECT      @ObjectsUpdated = CAST(REPLACE(LTRIM(SUBSTRING(Value, 53, LEN(Value))), ',', '') AS int)
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Total number of objects updated:%'

                        SELECT      @ObjectsRebound = CAST(REPLACE(LTRIM(SUBSTRING(Value, 53, LEN(Value))), ',', '') AS int)
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Total number of objects rebound:%'

                        SELECT      @ObjectsDeleted = CAST(REPLACE(LTRIM(SUBSTRING(Value, 53, LEN(Value))), ',', '') AS int)
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Total number of objects deleted:%'
                          
                        SELECT      @ObjectsExpired = CAST(REPLACE(LTRIM(SUBSTRING(Value, 53, LEN(Value))), ',', '') AS int)
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Total number of objects expired:%'

                        SELECT      @ObjectsFailed = CAST(REPLACE(LTRIM(SUBSTRING(Value, 52, LEN(Value))), ',', '') AS int)
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Total number of objects failed:%'

                        SELECT      @SubfileObjects = CAST(REPLACE(LTRIM(SUBSTRING(Value, 53, LEN(Value))), ',', '') AS int)
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Total number of subfile objects:%'

                        SELECT      @BytesInspected = LTRIM(SUBSTRING(Value, 53, LEN(Value))) 
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Total number of bytes inspected:%'
                              
                        SELECT      @BytesTransferred = LTRIM(SUBSTRING(Value, 55, LEN(Value)))
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Total number of bytes transferred:%'

                        SELECT     @DataTransferTime = LTRIM(SUBSTRING(Value, 40, LEN(Value)))
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Data transfer time:%'

                        SELECT      @DataTransferRate = LTRIM(SUBSTRING(Value, 48, LEN(Value)))
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Network data transfer rate:%'

                        SELECT      @AggDataTransferRate = LTRIM(SUBSTRING(Value, 50, LEN(Value)))
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Aggregate data transfer rate:%'

                        SELECT      @CompressPercentage = LTRIM(SUBSTRING(Value, 43, LEN(Value)))
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Objects compressed by:%'

                        SELECT      @DataReductionRatio = LTRIM(SUBSTRING(Value, 48, LEN(Value)))
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Total data reduction ratio:%'

                        SELECT      @SubfileObjectsReduceBy = LTRIM(SUBSTRING(Value, 48, LEN(Value)))
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Subfile objects reduced by:%'

                        SELECT      @ElapseProcessingTime = LTRIM(SUBSTRING(Value, 45, LEN(Value)))
                        FROM        #RawData 
                        WHERE       CAST(LEFT(Value, 19) AS datetime) BETWEEN @BackupStart AND @BackupEnd
                          AND       Value LIKE '%Elapsed processing time:%'


                        INSERT INTO #Report 
                        VALUES  (@TSMLog, @BackupScheduleName, CAST(RIGHT(@BackupScheduleName, 19) AS datetime), @BackupStart, @BackupEnd, @BackupPaths,
                                 @ObjectsInspected, @ObjectsAssigned, @ObjectsBackedUp, @ObjectsUpdated, @ObjectsRebound, @ObjectsDeleted, @ObjectsExpired,
                                 @ObjectsFailed, @SubfileObjects, @BytesInspected, @BytesTransferred, @DataTransferTime, @DataTransferRate, @AggDataTransferRate,
                                 @CompressPercentage, @DataReductionRatio, @SubfileObjectsReduceBy, @ElapseProcessingTime)

                        TRUNCATE TABLE #BackupItems
                        
                        FETCH NEXT FROM CURSOR_BACKUP_RANGE
                        INTO @BackupScheduleName, @BackupStart, @BackupEnd    
                    END
                    
                    CLOSE CURSOR_BACKUP_RANGE
                    DEALLOCATE CURSOR_BACKUP_RANGE
                END
                
            TRUNCATE TABLE #RawData

            FETCH NEXT FROM CURSOR_LOG_PATH 
            INTO @TSMLog
        END
    END
    
CLOSE CURSOR_LOG_PATH 
DEALLOCATE CURSOR_LOG_PATH 

IF EXISTS(SELECT * FROM #Report)
    SELECT      LogFile + '<1>' + 
                    ISNULL(BackupScheduleName, '') + '<2>' +
                    ISNULL(CONVERT(varchar(30), BackupScheduleDate, 109), '') + '<3>' + 
                    ISNULL(CONVERT(varchar(30), BackupStart, 109), '') + '<4>' + 
                    ISNULL(CONVERT(varchar(30), BackupEnd, 109), '') + '<5>' +
                    ISNULL(BackupPaths, '') + '<6>' + 
                    ISNULL(CAST(ObjectsInspected AS varchar(25)), '0') + '<7>' +
                    ISNULL(CAST(ObjectsAssigned AS varchar(25)), '0') + '<8>' +
                    ISNULL(CAST(ObjectsBackedUp AS varchar(25)), '0') + '<9>' +
                    ISNULL(CAST(ObjectsUpdated AS varchar(25)), '0') + '<10>' +
                    ISNULL(CAST(ObjectsRebound AS varchar(25)), '0') + '<11>' +
                    ISNULL(CAST(ObjectsDeleted AS varchar(25)), '0') + '<12>' +
                    ISNULL(CAST(ObjectsExpired AS varchar(25)), '0') + '<13>' +
                    ISNULL(CAST(ObjectsFailed AS varchar(25)), '0') + '<14>' +
                    ISNULL(CAST(SubfileObjects AS varchar(25)), '0') + '<15>' +
                    ISNULL(BytesInspected, '') + '<16>' +
                    ISNULL(BytesTransferred, '') + '<17>' +
                    ISNULL(DataTransferTime, '') + '<18>' +
                    ISNULL(DataTransferRate, '') + '<19>' +
                    ISNULL(AggDataTransferRate, '') + '<20>' +
                    ISNULL(CompressPercentage, '') + '<21>' +
                    ISNULL(DataReductionRatio, '') + '<22>' +
                    ISNULL(SubfileObjectsReduceBy, '') + '<23>' +
                    ISNULL(ElapseProcessingTime, '') 
    FROM        #Report
ELSE
    SELECT      'TSM Jobs are not schedule to run.' + '<1>' + 
                 '' + '<2>' + 
                 '' + '<3>' + 
                 '' + '<4>' + 
                 '' + '<5>' + 
                 '' + '<6>' + 
                 '0' + '<7>' + 
                 '0' + '<8>' + 
                 '0' + '<9>' + 
                 '0' + '<10>' + 
                 '0' + '<11>' + 
                 '0' + '<12>' + 
                 '0' + '<13>' + 
                 '0' + '<14>' + 
                 '0' + '<15>' + 
                 '' + '<16>' + 
                 '' + '<17>' + 
                 '' + '<18>' + 
                 '' + '<19>' + 
                 '' + '<20>' + 
                 '' + '<21>' + 
                 '' + '<22>' + 
                 '' + '<23>' + 
                 '' 

DROP TABLE #ServicesKeys
DROP TABLE #TSMLog
DROP TABLE #RawData
DROP TABLE #BackupItems
DROP TABLE #Report
