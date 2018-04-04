USE [DBA_DataCollector]
GO
/****** Object:  StoredProcedure [dbo].[CalculateFileHash]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CalculateFileHash]
	@InputFilePath varchar(1000),
	@HashValue varbinary(64) OUTPUT
as
BEGIN

	SET NOCOUNT ON

	DECLARE @RunningVal varchar(8000)
	DECLARE @Command varchar(2048)

	CREATE TABLE #temp (
		Row varchar(4000)
	)

	CREATE TABLE #temp2 (
		ID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
		Row varchar(4000)
	)
	
	SET @Command = 'BULK INSERT #temp FROM ''' + @InputFilePath + ''''
	EXEC(@Command)

	INSERT #temp2 (Row)
	SELECT * FROM #Temp
	WHERE Row Is NOT NULL

	SET @RunningVal = ''

	WHILE EXISTS (SELECT 1 FROM #temp2)
	BEGIN
		SELECT TOP 1 @RunningVal = 
			cast(HASHBYTES('SHA1', @RunningVal + Row) as varchar)
		FROM #temp2
		ORDER BY ID

		DELETE #temp2
		WHERE ID = (SELECT Min(ID) FROM #temp2)
	END


	SET @HashValue = hashbytes('sha1', @RunningVal)

	DROP TABLE #temp
	DROP TABLE #temp2

END



GO
/****** Object:  StoredProcedure [dbo].[CheckFileHash]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CheckFileHash]
	@FilePath varchar(1000)
AS
BEGIN

	DECLARE @CurrentHashValue varbinary(64),
			@ActualHashValue varbinary(64),
			@ErrorMsg varchar(1000)


	SELECT @CurrentHashValue = HashValue
	FROM FileHash
	WHERE FilePath = @FilePath

	EXEC CalculateFileHash @FilePath, @ActualHashValue OUTPUT

	IF @CurrentHashValue IS NULL 
	AND NOT EXISTS (SELECT 1 FROM FileHash WHERE FilePath=@FilePath)
		INSERT FileHash
		VALUES(@FilePath, @ActualHashValue)
	ELSE
	BEGIN
		IF @CurrentHashValue <> @ActualHashValue
		BEGIN
			SET @ErrorMsg = 'The file ' + @FilePath + ' has been modified. Please review changes to the script and update the file hash.'
			RAISERROR (@ErrorMsg, 16, 1)
		END
		
		-- If the hash value matches then no further action is required. Execution may proceed as normal.

	END

END



GO
/****** Object:  StoredProcedure [dbo].[CollectDBMSPingInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[CollectDBMSPingInfo] 
(
    @DBMS_Id    int = NULL
    ,@Verbose   bit = 1
)
AS

SET NOCOUNT ON 

DECLARE @Id                 int
        ,@SQLServer         varchar(128)
        ,@Domain            varchar(128)
        ,@Cmd               varchar(256)
        ,@ByName            bit
        ,@PingInfo          varchar(256)
        ,@SQLServerCount   varchar(15)
		,@UpdateCount	    varchar(15)
		,@Length		    int
		,@Total			    int

IF @Verbose = 1
    BEGIN
        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
        PRINT CONVERT(varchar(30), GETDATE(), 109)
    END


IF OBJECT_ID('tempdb..#Results') IS NOT NULL
    DROP TABLE #Results
    
CREATE TABLE #Results
(
    Info        varchar(512)
)

DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
FOR
    SELECT      Id
                ,Name
                ,Domain
    FROM        dbo.SQLAbleToCollectInfoOn
    WHERE       (
                    @DBMS_Id IS NULL
                        OR Id = @DBMS_Id
                )
    ORDER BY	[SQLServer]     
      
OPEN CURSOR_SERVER

FETCH NEXT FROM CURSOR_SERVER
INTO @Id, @SQLServer, @Domain

SET @SQLServerCount = 0
SET @UpdateCount = 0

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQLServerCount += 1
    
	IF @Verbose = 1
	    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SQL SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@Id AS varchar(15)) + ')'

    SET @ByName = 0
    
    SET @Cmd = 'ping -n 1 ' + @SQLServer + '.' + @Domain + ' | find /I "Pinging "'

	IF @Verbose = 1
	    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     Cmd:    ' + @Cmd

    INSERT INTO #Results
    EXECUTE xp_cmdshell @Cmd
    

    IF NOT EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Pinging %')
        BEGIN
            SET @ByName = 1
            
            SET @Cmd = 'ping -n 1 ' + @SQLServer + ' | find /I "Pinging "'

	        IF @Verbose = 1
	            PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     Cmd:    ' + @Cmd

            INSERT INTO #Results
            EXECUTE xp_cmdshell @Cmd
        END

    SET @PingInfo = NULL
    
    SELECT      @PingInfo = Info 
    FROM        #Results 
    WHERE       Info LIKE 'Pinging %'

    IF @PingInfo IS NOT NULL
        BEGIN
            UPDATE      DBMS 
               SET      PingByName = @ByName
                        ,PingDomainInfo = CASE WHEN LEFT(REPLACE(@PingInfo, 'Pinging ' + @SQLServer + '.', ''), CHARINDEX('[', REPLACE(@PingInfo, 'Pinging ' + @SQLServer + '.', '')) -  2) LIKE '%.%'
                                                THEN LEFT(REPLACE(@PingInfo, 'Pinging ' + @SQLServer + '.', ''), CHARINDEX('[', REPLACE(@PingInfo, 'Pinging ' + @SQLServer + '.', '')) -  2)
                                                ELSE NULL
                                          END
                        ,PingIPInfo = SUBSTRING(@PingInfo, CHARINDEX('[', @PingInfo) + 1, CHARINDEX(']', @PingInfo) - CHARINDEX('[', @PingInfo) - 1)
            WHERE       Id = @Id                        
            
	        IF @Verbose = 1
	            PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     Status: Updated Ping Info'

            SET @UpdateCount += 1
        END
    ELSE
        BEGIN
	        IF @Verbose = 1
	            PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     Status: Ping Info was not updated'
        END
    
    IF @Verbose = 1
        PRINT ''
                            
    TRUNCATE TABLE #Results

    FETCH NEXT FROM CURSOR_SERVER
    INTO @Id, @SQLServer, @Domain
END      

CLOSE CURSOR_SERVER
DEALLOCATE CURSOR_SERVER

SET @Total = CAST(@SQLServerCount AS int) 
SET @Length = LEN(CAST(@Total AS varchar(15)))

IF @Verbose = 1
    BEGIN
        PRINT ''
        PRINT 'SERVER COUNT: ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SQLServerCount)) + @SQLServerCount
        PRINT 'UPDATE COUNT: ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@UpdateCount)) + @UpdateCount
    END            		



GO
/****** Object:  StoredProcedure [dbo].[CollectServerPingInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectServerPingInfo] 
(
    @Server_Id   int = NULL
    ,@Verbose   bit = 1
)
AS

SET NOCOUNT ON 

DECLARE @Id             int
        ,@Server        varchar(128)
        ,@Domain        varchar(128)
        ,@Cmd           varchar(256)
        ,@ByName        bit
        ,@PingInfo      varchar(256)
        ,@ServerCount   varchar(15)
		,@UpdateCount	varchar(15)
		,@Length		int
		,@Total			int

IF @Verbose = 1
    BEGIN
        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@Server_Id:                   ' + ISNULL(CAST(@Server_Id AS varchar(15)), '')
        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
        PRINT CONVERT(varchar(30), GETDATE(), 109)
    END


IF OBJECT_ID('tempdb..#Results') IS NOT NULL
    DROP TABLE #Results
    
CREATE TABLE #Results
(
    Info        varchar(512)
)

DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
FOR
    SELECT      Id
                ,Name
                ,Domain
    FROM        Server
    WHERE       (
                    @Server_Id IS NULL
                        OR Id = @Server_Id
                )
      AND       CollectInfo = 1
      AND       Disable = 0
    ORDER BY    Name      
      
OPEN CURSOR_SERVER

FETCH NEXT FROM CURSOR_SERVER
INTO @Id, @Server, @Domain

SET @ServerCount = 0
SET @UpdateCount = 0

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @ServerCount += 1
    
	IF @Verbose = 1
	    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@Server) + ' (' + CAST(@Id AS varchar(15)) + ')'

    SET @ByName = 0
    
    SET @Cmd = 'ping -n 1 ' + @Server + '.' + @Domain + ' | find /I "Pinging "'

	IF @Verbose = 1
	    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     Cmd:    ' + @Cmd

    INSERT INTO #Results
    EXECUTE xp_cmdshell @Cmd
    

    IF NOT EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Pinging %')
        BEGIN
            SET @ByName = 1
            
            SET @Cmd = 'ping -n 1 ' + @Server + ' | find /I "Pinging "'

	        IF @Verbose = 1
	            PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     Cmd:    ' + @Cmd

            INSERT INTO #Results
            EXECUTE xp_cmdshell @Cmd
        END

    SET @PingInfo = NULL
    
    SELECT      @PingInfo = Info 
    FROM        #Results 
    WHERE       Info LIKE 'Pinging %'

    IF @PingInfo IS NOT NULL
        BEGIN
            UPDATE      Server 
               SET      PingByName = @ByName
                        ,PingDomainInfo = CASE WHEN LEFT(REPLACE(@PingInfo, 'Pinging ' + @Server + '.', ''), CHARINDEX('[', REPLACE(@PingInfo, 'Pinging ' + @Server + '.', '')) -  2) LIKE '%.%'
                                                THEN LEFT(REPLACE(@PingInfo, 'Pinging ' + @Server + '.', ''), CHARINDEX('[', REPLACE(@PingInfo, 'Pinging ' + @Server + '.', '')) -  2)
                                                ELSE NULL
                                          END
                        ,PingIPInfo = SUBSTRING(@PingInfo, CHARINDEX('[', @PingInfo) + 1, CHARINDEX(']', @PingInfo) - CHARINDEX('[', @PingInfo) - 1)
            WHERE       Id = @Id                        
            
	        IF @Verbose = 1
	            PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     Status: Updated Ping Info'

            SET @UpdateCount += 1
        END
    ELSE
        BEGIN
	        IF @Verbose = 1
	            PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     Status: Ping Info was not updated'
        END
    
    IF @Verbose = 1
        PRINT ''
                            
    TRUNCATE TABLE #Results

    FETCH NEXT FROM CURSOR_SERVER
    INTO @Id, @Server, @Domain
END      

CLOSE CURSOR_SERVER
DEALLOCATE CURSOR_SERVER

SET @Total = CAST(@ServerCount AS int) 
SET @Length = LEN(CAST(@Total AS varchar(15)))

IF @Verbose = 1
    BEGIN
        PRINT ''
        PRINT 'SERVER COUNT: ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ServerCount)) + @ServerCount
        PRINT 'UPDATE COUNT: ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@UpdateCount)) + @UpdateCount
    END            		



GO
/****** Object:  StoredProcedure [dbo].[CollectServerScheduleTaskInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectServerScheduleTaskInfo]
(
	@Server_Id  int = NULL
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ServerId				int
		,@SQLServer				varchar(256)
		,@IP					varchar(50)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@FmtFile				varchar(50)

SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'
	
SET @FmtFile = [dbo].[funcGetConfigurationData]('SchTaskFmtFile')

SET @OutputFile = @BuildScriptPath + 'schtaskinfo_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'

SET @SuccessCount = 0
SET @ErrorCount = 0

PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@Server_Id:                 ' + ISNULL(CAST(@Server_Id AS varchar(10)), '')
PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
PRINT CONVERT(varchar(30), GETDATE(), 109)

CREATE TABLE #Output
(
	Value		varchar(2000)
)

CREATE TABLE #Results
(
	[TaskName]						[varchar](50)	NULL
	,[NextRunTime]					[varchar](30)	NULL
	,[Status]						[varchar](30)	NULL
	,[LogonMode]					[varchar](50)	NULL
	,[LastRunTime]					[varchar](30)	NULL
	,[LastResults]					[varchar](20)	NULL
	,[Creator]						[varchar](30)	NULL
	,[TaskToRun]					[varchar](512)	NULL
	,[StartIn]						[varchar](256)	NULL
	,[Comment]						[varchar](256)	NULL
	,[ScheduleTaskState]			[varchar](20)	NULL
	,[IdleTime]						[varchar](30)	NULL
	,[PowerManagement]				[varchar](100)	NULL
	,[RunAsUser]					[varchar](256)	NULL
	,[DeleteTaskIfNotRescheduled]	[varchar](100)	NULL
	,[StopTaskIfRunsXHoursAndXMins]	[varchar](100)	NULL
	,[Schedule]						[varchar](110)	NULL
	,[ScheduleType]					[varchar](40)	NULL
	,[StartTime]					[varchar](20)	NULL
	,[StartDate]					[varchar](25)	NULL
	,[EndDate]						[varchar](25)	NULL
	,[Days]							[varchar](100)	NULL
	,[Months]						[varchar](100)	NULL
	,[RepeatEvery]					[varchar](30)	NULL
	,[RepeatUntilTime]				[varchar](40)	NULL
	,[RepeatUntilDuration]			[varchar](30)	NULL
	,[RepeatStopIfStillRunning]		[varchar](30)	NULL
)


DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
FOR
	SELECT		[Id]									AS [ServerId]
				,[Name]
				,[IPAddress] 
	FROM		[Server]
	WHERE		[Disable] = 0
	  AND		[CollectInfo] = 1
	  AND		(
					[Id] = @Server_Id
						OR @Server_Id IS NULL
				) 
	ORDER BY	[Name]

OPEN CURSOR_SERVER
	
FETCH NEXT FROM CURSOR_SERVER
INTO @ServerId, @SQLServer, @IP

IF @@FETCH_STATUS <> 0
	PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
ELSE
	BEGIN
		WHILE @@FETCH_STATUS = 0
		BEGIN			
			TRUNCATE TABLE #Results
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@ServerId AS varchar(15)) + ')'
			
		    DELETE FROM [dbo].[ScheduledTaskInfo] WHERE Server_Id = @ServerId
			
			SET @Command = 'schtasks /query /fo csv /S ' + @IP + ' /v > ' + @OutputFile
			
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

			EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command, NO_OUTPUT

			IF @ReturnValue = 0 
				BEGIN 
					SET @Command = 'BULK INSERT #Output ' +
								   'FROM ''' + @OutputFile + ''' ' + 
								   'WITH ' +
								   '( ' +
										'BATCHSIZE = 5000 ' +
										',LASTROW = 1 ' +
								   ') '

					PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

					BEGIN TRY 
						EXECUTE master.dbo.sp_executesql @Command

						IF EXISTS(SELECT * FROM #Output WHERE Value LIKE 'INFO:%')
							BEGIN
								SET @SuccessCount = @SuccessCount + 1
								
								INSERT INTO [dbo].[ScheduledTaskInfo]
								(
											[Server_Id]
											,[TaskName]
								)
								VALUES (@ServerId,  'NO SCHEDULED TASK FOR THIS SERVER')

								PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    *** NO SCHEDULED TASK FOR THIS SERVER ***'
							END
						ELSE
							IF EXISTS(SELECT * FROM #Output WHERE Value LIKE 'ERROR:%')
								BEGIN
									SET @ErrorCount = @ErrorCount + 1
									PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	   *** ERROR ***'
								END
							ELSE
								BEGIN 
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE = 5000 ' +
														',FIRSTROW = 2 ' +
														',FORMATFILE=''' + @BuildScriptPath + @FmtFile + '''' +
												   ') '

									PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									BEGIN TRY 
										EXECUTE master.dbo.sp_executesql @Command
										
										PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'																		
										
										INSERT INTO [dbo].[ScheduledTaskInfo]
										(
													[Server_Id]
													,[TaskName]
													,[NextRunTime]
													,[Status]
													,[LogonMode]
													,[LastRunTime]
													,[LastResults]
													,[Creator]
													,[TaskToRun]
													,[StartIn]
													,[Comment]
													,[ScheduleTaskState]
													,[IdleTime]
													,[PowerManagement]
													,[RunAsUser]
													,[DeleteTaskIfNotRescheduled]
													,[StopTaskIfRunsXHoursAndXMins]
													,[Schedule]
													,[ScheduleType]
													,[StartTime]
													,[StartDate]
													,[EndDate]
													,[Days]
													,[Months]
													,[RepeatEvery]
													,[RepeatUntilTime]
													,[RepeatUntilDuration]
													,[RepeatStopIfStillRunning]
										)		
										SELECT		@ServerId
													,[TaskName]
													,[NextRunTime]
													,[Status]
													,[LogonMode]
													,[LastRunTime]
													,[LastResults]
													,[Creator]
													,[TaskToRun]
													,[StartIn]
													,[Comment]
													,[ScheduleTaskState]
													,[IdleTime]
													,[PowerManagement]
													,[RunAsUser]
													,[DeleteTaskIfNotRescheduled]
													,[StopTaskIfRunsXHoursAndXMins]
													,[Schedule]
													,[ScheduleType]
													,[StartTime]
													,[StartDate]
													,[EndDate]
													,[Days]
													,[Months]
													,[RepeatEvery]
													,[RepeatUntilTime]
													,[RepeatUntilDuration]
													,[RepeatStopIfStillRunning]
										FROM		#Results

										PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@@ROWCOUNT AS varchar(15)) + ' RECORD(S) INSERTED'

										SET @SuccessCount = @SuccessCount + 1
									END TRY
									BEGIN CATCH
										SET @ErrorCount = @ErrorCount + 1
										PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -       *** ERROR OCCURRED'
										PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -               Msg ' + CAST(ERROR_NUMBER() AS varchar) + 
									    			  													', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
													  													', State ' + CAST(ERROR_STATE() AS varchar) +
													  													', Line ' + CAST(ERROR_LINE() AS varchar)
										PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -               ' + ERROR_MESSAGE()
									END CATCH
								END
					END TRY
					BEGIN CATCH
						SET @ErrorCount = @ErrorCount + 1
						PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -       *** ERROR OCCURRED'
						PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -               Msg ' + CAST(ERROR_NUMBER() AS varchar) + 
										    			  								', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
														  								', State ' + CAST(ERROR_STATE() AS varchar) +
														  								', Line ' + CAST(ERROR_LINE() AS varchar)
						PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -               ' + ERROR_MESSAGE()
					END CATCH
				END
			ELSE
				BEGIN
					SET @ErrorCount = @ErrorCount + 1
					PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	   *** ERROR ***'
				END

			PRINT CONVERT(varchar(30), GETDATE(), 109) 

			FETCH NEXT FROM CURSOR_SERVER
			INTO @ServerId, @SQLServer, @IP
		END
	END
	
CLOSE CURSOR_SERVER
DEALLOCATE CURSOR_SERVER

DROP TABLE #Results

SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
SET @Length = LEN(CAST(@Total AS varchar(15)))

PRINT ''
PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
PRINT '              ' + REPLICATE('-', @Length + 5)
PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))

SET @Command = 'DEL ' + @OutputFile
		
EXECUTE xp_cmdshell @Command, NO_OUTPUT



GO
/****** Object:  StoredProcedure [dbo].[CollectSQLBackupSummary]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLBackupSummary] 
(
	@DBMS_Id        int = NULL
    ,@Verbose       bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLBackupSummaryScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]


		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
            		SET @OutputFile = @BuildScriptPath + 'sqlbackupsummary_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'
            		
					TRUNCATE TABLE #Results
					
					IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
                                END							        
						END
					ELSE
						BEGIN
                            DELETE FROM [dbo].[BackupSummary] WHERE DBMS_Id = @DBMSId
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											  OR		Info LIKE 'Warning%'																		
											
											INSERT INTO [dbo].[BackupSummary]
											(
														[DBMS_Id]
														,[DbName]
														,[Type]
														,[LastBackupStartDate]
														,[LastBackupFinishDate]
														,[LastBackupSize]
														,[DaysOld]
														,[TodaysBackupCount]
														,[YesterdaysBackupCount]
														,[TwoDaysAgoBackupCount]
														,[ThreeDaysAgoBackupCount]
														,[BackupUser]
														,[BackupSetName]
														,[BackupFilename]
														,[LastCompressedBackupSize]
											)
											SELECT		@DBMSId				
														,LEFT(info, CHARINDEX('<1>', info) - 1)
														,SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3) = 'NULL'
															THEN NULL
															ELSE CAST(SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3) AS numeric(20, 0))
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3) = 'NULL'
															THEN NULL 
															ELSE SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<10>', info) + 4, CHARINDEX('<11>', info) - CHARINDEX('<10>', info) - 4) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<10>', info) + 4, CHARINDEX('<11>', info) - CHARINDEX('<10>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<11>', info) + 4, CHARINDEX('<12>', info) - CHARINDEX('<11>', info) - 4) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<11>', info) + 4, CHARINDEX('<12>', info) - CHARINDEX('<11>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<12>', info) + 4, CHARINDEX('<13>', info) - CHARINDEX('<12>', info) - 4) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<12>', info) + 4, CHARINDEX('<13>', info) - CHARINDEX('<12>', info) - 4)
														 END
														,CASE WHEN CAST(SUBSTRING(info, CHARINDEX('<13>', info) + 4, LEN(info)) AS varchar(25)) = 'NULL'
															THEN NULL
															ELSE  SUBSTRING(info, CHARINDEX('<13>', info) + 4, LEN(info))-- AS numeric(20, 0))
														 END
											FROM		#Results A

                                            SET @Count = @@ROWCOUNT

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
										END
								END

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) 
						END

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT
						
					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        IF @Verbose = 1
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
            END
	END
	


GO
/****** Object:  StoredProcedure [dbo].[CollectSQLDatabaseMirroringInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLDatabaseMirroringInfo] 
(
	@DBMS_Id        int = NULL
    ,@Verbose       bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLDatabaseMirroringInfoScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
              AND		LEFT(SQLVersion, CHARINDEX('.', SQLVersion)-1) <> '8'                         
            ORDER BY	[SQLServer]

		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
    		        SET @OutputFile = @BuildScriptPath + 'sqldbmirrorinfo_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'

					TRUNCATE TABLE #Results
					
					IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
							DELETE FROM [dbo].[DatabaseMirroringInfo] WHERE DBMS_Id = @DBMSId
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											  OR		Info LIKE 'Warning%'																		
											
											INSERT INTO [dbo].[DatabaseMirroringInfo]
											(
														[DBMS_Id]
														,[DatabaseName]
														,[Role]
														,[State]
														,[Sequence]
														,[SafteyLevel]
														,[PartnerName]
														,[PartnerInstance]
														,[PartnerWitness]
														,[WitnessState]
														,[ConnectionTimeout]
														,[RedoQueueType]
											)														
											SELECT		@DBMSId				
														,LEFT(info, CHARINDEX('<1>', info) - 1)
														,CASE WHEN SUBSTRING(info, CHARINDEX('1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<10>', info) + 4, LEN(info)) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<10>', info) + 4, LEN(info))
														 END
											FROM		#Results

                                            SET @Count = @@ROWCOUNT

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
										END
								END
						END

                    IF @Verbose = 1							
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        IF @Verbose = 1
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
            END            
	END




GO
/****** Object:  StoredProcedure [dbo].[CollectSQLDatabaseOptionsInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLDatabaseOptionsInfo] 
(
	@DBMS_Id        int = NULL
    ,@Verbose       bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLDatabaseInfoScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]


		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
    		        SET @OutputFile = @BuildScriptPath + 'sqldbinfo_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'

					TRUNCATE TABLE #Results
					
					IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
							DELETE FROM [dbo].[DatabaseOptionsInfo] WHERE DBMS_Id = @DBMSId
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											  OR		Info LIKE 'Warning%'																		
											
											INSERT INTO [dbo].[DatabaseOptionsInfo]
											(
														[DBMS_Id]
														,[Name]
														,[Owner]
														,[Collation]
														,[CompatibilityLevel]
														,[RecoveryModel]
														,[AutoClose]
														,[AutoCreateStatistics]
														,[AutoShrink]
														,[AutoUpdateStatistics]
														,[CloseCursorOnCommitEnabled]
														,[ANSINullDefault]
														,[ANSINullsEnabled]
														,[ANSIPaddingEnabled]
														,[ANSIWarningsEnabled]
														,[ArithmeticAbortEnabled]
														,[ConcatenateNullYieldsNull]
														,[CrossDbOwnership]
														,[NumericRoundAbort]
														,[QuotedIdentifierEnabled]
														,[RecursiveTriggersEnabled]
														,[FullTextEnabled]
														,[Trustworthy]
														,[BrokerEnabled]
														,[ReadOnly]
														,[RestrictUserAccess]
														,[Status]
														,[DbCreateDate]
											)
											SELECT		@DBMSId				
														,LEFT(info, CHARINDEX('<1>', info) - 1)
														,SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<10>', info) + 4, CHARINDEX('<11>', info) - CHARINDEX('<10>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<11>', info) + 4, CHARINDEX('<12>', info) - CHARINDEX('<11>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<12>', info) + 4, CHARINDEX('<13>', info) - CHARINDEX('<12>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<13>', info) + 4, CHARINDEX('<14>', info) - CHARINDEX('<13>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<14>', info) + 4, CHARINDEX('<15>', info) - CHARINDEX('<14>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<15>', info) + 4, CHARINDEX('<16>', info) - CHARINDEX('<15>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<16>', info) + 4, CHARINDEX('<17>', info) - CHARINDEX('<16>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<17>', info) + 4, CHARINDEX('<18>', info) - CHARINDEX('<17>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<18>', info) + 4, CHARINDEX('<19>', info) - CHARINDEX('<18>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<19>', info) + 4, CHARINDEX('<20>', info) - CHARINDEX('<19>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<20>', info) + 4, CHARINDEX('<21>', info) - CHARINDEX('<20>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<21>', info) + 4, CHARINDEX('<22>', info) - CHARINDEX('<21>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<22>', info) + 4, CHARINDEX('<23>', info) - CHARINDEX('<22>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<23>', info) + 4, CHARINDEX('<24>', info) - CHARINDEX('<23>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<24>', info) + 4, CHARINDEX('<25>', info) - CHARINDEX('<24>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<25>', info) + 4, CHARINDEX('<26>', info) - CHARINDEX('<25>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<26>', info) + 4, LEN(info))
											FROM		#Results

                                            SET @Count = @@ROWCOUNT

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
										END
								END
						END

                    IF @Verbose = 1							
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        IF @Verbose = 1
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
            END            
	END



GO
/****** Object:  StoredProcedure [dbo].[CollectSQLDatabaseSizeInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLDatabaseSizeInfo] 
(
	@DBMS_Id    int = NULL
    ,@Verbose       bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLDatabaseSizeInfoScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END

		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]



		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN			
				WHILE @@FETCH_STATUS = 0
				BEGIN			
            		SET @OutputFile = @BuildScriptPath + 'sqldbsizeinfo_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'

                    TRUNCATE TABLE #Results					
                    
                    IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'

					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
                            DELETE FROM [dbo].[DatabaseSizeInfo] WHERE DBMS_Id = @DBMSId

				
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                            IF @Verbose = 1
                                PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -         EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1
									
									IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -             *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -         EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
						
									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

                                            IF @Verbose = 1 
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -             *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -             SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = ''
											   OR		Info LIKE 'DBCC execution completed%'

											INSERT INTO [dbo].[DatabaseSizeInfo]
											(
														[DBMS_Id]
														,[DbName]
														,[Type]
														,[Filegroup]
														,[LogicalName]
														,[FileSize_MB]
														,[UsedSpace_MB]
														,[UnusedSpace_MB]
														,[MaxSize_MB]
														,[PhysicalName]
														,[Growth]
														,[GrowthType]
											)
											SELECT		@DBMSId				
														,LEFT(info, CHARINDEX('<1>', info) - 1)
														,SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
														 END
														,SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3)
														 END
														,SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3)
														 END
														,SUBSTRING(info, CHARINDEX('<10>', info) + 4, LEN(info))
											FROM		#Results

                                            SET @Count = @@ROWCOUNT


                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -             ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
									    END
								END
						END
						
				    IF @Verbose = 1
				        BEGIN
					        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END WORKING ON SERVER ' + QUOTENAME(@SQLServer)
					        PRINT CONVERT(varchar(30), GETDATE(), 109)					
                        END
                        
			        SET @Command = 'DEL ' + @OutputFile					
			        EXECUTE xp_cmdshell @Command, NO_OUTPUT		
					
					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection
				END				
			END
			
			CLOSE CURSOR_SERVER
			DEALLOCATE CURSOR_SERVER

			DROP TABLE #Results

			SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
			SET @Length = LEN(CAST(@Total AS varchar(15)))

            IF @Verbose = 1
                BEGIN
			        PRINT ''
			        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
			        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
			        PRINT '              ' + REPLICATE('-', @Length + 5)
			        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
                END			 
	END



GO
/****** Object:  StoredProcedure [dbo].[CollectSQLDBMSConfigurationInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLDBMSConfigurationInfo]
(
	@DBMS_Id        int = NULL
    ,@Verbose       bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLDBMSConfigurationInfoScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]



		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
		            SET @OutputFile = @BuildScriptPath + 'sqlconfiginfo_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'
        
					TRUNCATE TABLE #Results

                    IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
							DELETE FROM [dbo].[DBMSConfigurationInfo] WHERE DBMS_Id = @DBMSId
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											  OR		Info LIKE 'Warning%'																		
											  OR		Info LIKE '%Class not registered%'																		
											
											INSERT INTO [dbo].[DBMSConfigurationInfo]
											(
														[DBMS_Id]
														,[ConfigId]
														,[Name]
														,[Description]
														,[Value]
														,[ValueInUse]
											)
											SELECT		@DBMSId				
														,LEFT(info, CHARINDEX('<1>', info) - 1)
														,SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<4>', info) + 3, LEN(info))
											FROM		#Results

                                            SET @Count = @@ROWCOUNT

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
										END
								END
						END

                    IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        IF @Verbose = 1 
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
		    END
	END



GO
/****** Object:  StoredProcedure [dbo].[CollectSQLDBMSInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLDBMSInfo] 
(
    @DBMS_Id        int = NULL
    ,@Verbose       bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLServerInfoScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(2048)
		)

		DECLARE CURSOR_SQLSERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]


		OPEN CURSOR_SQLSERVER
			
		FETCH NEXT FROM CURSOR_SQLSERVER
		INTO @DBMSId, @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN	
            		SET @OutputFile = @BuildScriptPath + 'sqlserverinfo_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(REPLACE(CONVERT(varchar(30), GETDATE(), 121), '-', ''), ':', ''), ' ', '_'), '.', '') +  '.out'
				
					TRUNCATE TABLE #Results
					
					IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '
				
					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
				
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 2048 -l 30 -t 120 > "' + @OutputFile +'"'

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command

									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(info, '')) = ''
											   OR		info LIKE 'RegOpenKeyEx() returned error%'

											UPDATE		dbo.DBMS 
											   SET		[Domain] = CASE WHEN ISNULL(LTRIM([ServerInfo].[DomainInfo]), '') = '' THEN [Domain] ELSE CASE WHEN LTRIM(ISNULL([Domain], '')) <> '' THEN [Domain] ELSE [ServerInfo].[DomainInfo] END END
														,[ServerType] = [ServerInfo].[ServerType]
														,[NamedPipesEnabled] = [ServerInfo].[NamedPipes]
														,[TcpIpEnabled] = [ServerInfo].[TCPIP]
														,[DynamicPort] = CASE WHEN RTRIM([ServerInfo].[DynamicPort]) = '' OR RTRIM([ServerInfo].[DynamicPort]) = '''NULL''' THEN NULL ELSE RTRIM([ServerInfo].[DynamicPort]) END
														,[StaticPort] = CASE WHEN RTRIM([ServerInfo].[StaticPort]) = '' THEN NULL ELSE RTRIM([ServerInfo].[StaticPort]) END
														,[ForceProtocolEncryption] = CASE WHEN [ServerInfo].[ForceProtocol] = '' THEN NULL ELSE [ServerInfo].[ForceProtocol] END
														,[SQLVersion] = [ServerInfo].[ProductVersion]
														,[SQLEdition] = [ServerInfo].[Edition]
														,[SQLCollation] = [ServerInfo].[Collation]
														,[SQLSortOrder]	= CASE WHEN [ServerInfo].[Sort] = ''  OR [ServerInfo].[Sort] = 'NULL' THEN NULL ELSE [ServerInfo].[Sort] END
														,[WindowsVersion] = [ServerInfo].[WindowsVersion]
														,[Platform] = [ServerInfo].[Platform]
														,[PhysicalCPU] = [ServerInfo].[PhysCPU]
														,[LogicalCPU] = [ServerInfo].[LogCPU]
														,[PhysicalMemory] = [ServerInfo].[PhysicalMemory]											
														,[DBMailProfile] = RTRIM([ServerInfo].[DBMail])
														,[AgentMailProfile] = RTRIM([ServerInfo].[AgentMail])
														,[LoginAuditLevel] =	CASE RTRIM([ServerInfo].[LoginAuditLevel])
																					WHEN 0 THEN 'None'
																					WHEN 1 THEN 'Successful'
																					WHEN 2 THEN 'Failed'
																					WHEN 3 THEN 'Both'
																					ELSE NULL
																				END
														,[ApproxStartDate] = [ServerInfo].[ApproxStartDate]
														,[DateInstalled] = CASE WHEN ISDATE([ServerInfo].InstallDate) = 1 THEN [ServerInfo].InstallDate ELSE NULL END
														,[RunningOnServer] = ISNULL(RTRIM([ServerInfo].[RunningOnServer]), 'Unable To Determine')
														,[ServerNameProperty] = RTRIM([ServerInfo].[ServerNameProperty])
														,[LastUpdate] = GETDATE()
														,[HardwareType] = RTRIM([ServerInfo].[HardwareType])
														,[ProgramDirectory] = CASE WHEN RTRIM([ServerInfo].SQLProgramDirectory) = '' THEN NULL ELSE RTRIM([ServerInfo].SQLProgramDirectory) END
														,[Path] = CASE WHEN RTRIM([ServerInfo].SQLPath) = '' THEN NULL ELSE RTRIM([ServerInfo].SQLPath) END
														,[BinaryDirectory] = CASE WHEN RTRIM([ServerInfo].SQLBinaryDirectory) = '' THEN NULL ELSE RTRIM([ServerInfo].SQLBinaryDirectory) END
														,[DefaultDataDirectory] = CASE WHEN RTRIM([ServerInfo].DefaultDataDirectory) = '' THEN NULL ELSE RTRIM([ServerInfo].DefaultDataDirectory) END
														,[DefaultLogDirectory] = CASE WHEN RTRIM([ServerInfo].DefaultLogDirectory) = '' THEN NULL ELSE RTRIM([ServerInfo].DefaultLogDirectory) END
														,[DotNetVersion] = CASE WHEN RTRIM([ServerInfo].DotNetVersion) = '' THEN NULL ELSE RTRIM([ServerInfo].DotNetVersion) END
											FROM		(
															SELECT		@DBMSId									AS [ServerId]
																		,LEFT(info, CHARINDEX('<1>', info) - 1)		AS [DomainInfo]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<1>', info) + 3, 
																					CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3
																				 )									AS [ServerType]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<2>', info) + 3, 
																					CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3
																				 )									AS [NamedPipes]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<3>', info) + 3, 
																					CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3
																				 )									AS [TCPIP]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<4>', info) + 3, 
																					CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3
																				 )									AS [DynamicPort]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<5>', info) + 3, 
																					CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3
																				 )									AS [StaticPort]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<6>', info) + 3, 
																					CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3
																				 )									AS [ForceProtocol]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<7>', info) + 3, 
																					CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3
																				 )									AS [ProductVersion]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<8>', info) + 3, 
																					CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3
																				 )									AS [Edition]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<9>', info) + 3, 
																					CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3
																				 )									AS [Collation]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<10>', info) + 4, 
																					CHARINDEX('<11>', info) - CHARINDEX('<10>', info) - 4
																				 )									AS [Sort]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<11>', info) + 4, 
																					CHARINDEX('<12>', info) - CHARINDEX('<11>', info) - 4
																				 )									AS [WindowsVersion]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<12>', info) + 4, 
																					CHARINDEX('<13>', info) - CHARINDEX('<12>', info) - 4
																				 )									AS [Platform]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<13>', info) + 4, 
																					CHARINDEX('<14>', info) - CHARINDEX('<13>', info) - 4
																				 )									AS [PhysCPU]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<14>', info) + 4, 
																					CHARINDEX('<15>', info) - CHARINDEX('<14>', info) - 4
																				 )									AS [LogCPU]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<15>', info) + 4, 
																					CHARINDEX('<16>', info) - CHARINDEX('<15>', info) - 4
																				 )									AS [PhysicalMemory]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<16>', info) + 4, 
																					CHARINDEX('<17>', info) - CHARINDEX('<16>', info) - 4
																				 )									AS [DBMail]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<17>', info) + 4, 
																					CHARINDEX('<18>', info) - CHARINDEX('<17>', info) - 4
																				 )									AS [AgentMail]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<18>', info) + 4, 
																					CHARINDEX('<19>', info) - CHARINDEX('<18>', info) - 4
																				 )									AS [LoginAuditLevel]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<19>', info) + 4, 
																					CHARINDEX('<20>', info) - CHARINDEX('<19>', info) - 4
																				 )									AS [ApproxStartDate]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<20>', info) + 4, 
																					CHARINDEX('<21>', info) - CHARINDEX('<20>', info) - 4
																				 )									AS [InstallDate]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<21>', info) + 4, 
																					CHARINDEX('<22>', info) - CHARINDEX('<21>', info) - 4
																				 )									AS [RunningOnServer]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<22>', info) + 4, 
																					CHARINDEX('<23>', info) - CHARINDEX('<22>', info) - 4
																				 )									AS [ServerNameProperty]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<23>', info) + 4, 
																					CHARINDEX('<24>', info) - CHARINDEX('<23>', info) - 4
																				 )									AS [HardwareType]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<24>', info) + 4, 
																					CHARINDEX('<25>', info) - CHARINDEX('<24>', info) - 4
																				 )									AS [SQLProgramDirectory]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<25>', info) + 4, 
																					CHARINDEX('<26>', info) - CHARINDEX('<25>', info) - 4
																				 )									AS [SQLPath]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<26>', info) + 4, 
																					CHARINDEX('<27>', info) - CHARINDEX('<26>', info) - 4
																				 )									AS [SQLBinaryDirectory]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<27>', info) + 4, 
																					CHARINDEX('<28>', info) - CHARINDEX('<27>', info) - 4
																				 )									AS [DefaultDataDirectory]
																		,SUBSTRING(
																					info, 
																					CHARINDEX('<28>', info) + 4, 
																					CHARINDEX('<29>', info) - CHARINDEX('<28>', info) - 4
																				 )									AS [DefaultLogDirectory]
																		,SUBSTRING(
																						info, 
																						CHARINDEX('<29>', info) + 4, 
																						LEN(info)
																				   )								AS [DotNetVersion]
															FROM		#Results
														) AS ServerInfo
											WHERE		[Id] = [ServerInfo].[ServerId]

                                            SET @Count = @@ROWCOUNT
    
                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE UPDATED IN DBMS TABLE'
											
											-- UPDATE SERVER TABLE WITH LATEST SERVER RELATED INFO FROM DBMS TABLE
                                            UPDATE      Server
                                               SET      ServerType = C.ServerType
														,Domain = C.Domain
                                                        ,WindowsVersion = C.WindowsVersion
                                                        ,Platform = C.Platform
                                                        ,PhysicalCPU = C.PhysicalCPU
                                                        ,LogicalCPU = C.LogicalCPU
                                                        ,PhysicalMemory = C.PhysicalMemory
                                                        ,HardwareType = C.HardwareType
                                                        ,LastUpdate = GETDATE()
                                            FROM        dbo.Server A
                                                            JOIN dbo.ServerDBMS B ON A.Id = B.Server_Id                                      
                                                            JOIN dbo.DBMS C ON B.DBMS_Id = C.Id
                                                                           AND (
                                                                                    (
                                                                                        A.Name = C.RunningOnServer
                                                                                     )
                                                                                     OR
                                                                                     (
                                                                                        C.RunningOnServer = 'Unable To Determine'                                                                                        
                                                                                     )
                                                                               )
                                            WHERE       C.Id = @DBMSId              											

                                            SET @Count = @@ROWCOUNT

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE UPDATED IN SERVER TABLE'
										END
								END
						END
						
                    IF @Verbose = 1						
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            SET @Command = 'DEL ' + @OutputFile            				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SQLSERVER
					INTO @DBMSId, @SQLServer, @SQLConnection
				END
			END
			
		CLOSE CURSOR_SQLSERVER
		DEALLOCATE CURSOR_SQLSERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        IF @Verbose = 1
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
            END            		
	END


GO
/****** Object:  StoredProcedure [dbo].[CollectSQLDriveInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLDriveInfo]
(
	@DBMS_Id        int = NULL
    ,@Verbose       bit = 1
)

as

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLServerDiskSpaceinfo')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]



		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
		            SET @OutputFile = @BuildScriptPath + 'sqldbinfo_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'
        
					TRUNCATE TABLE #Results

                    IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
							DELETE FROM [dbo].[DriveSpaceInfo] WHERE DBMS_Id = @DBMSId
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											  OR		Info LIKE 'Warning%'																		
											  OR		Info LIKE '%Class not registered%'																		
											
											INSERT INTO [dbo].[DriveSpaceInfo]
											(
														[DBMS_Id]
														,[DriveLetter]
														,[TotalSpace]
														,[FreeSpace]	
														,[Notes]											
											)
											SELECT		@DBMSId				
														,LEFT(info, CHARINDEX('<1>', info) - 1)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
														 END													
														,SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<3>', info) + 3, LEN(info)) = '' 
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<3>', info) + 3, LEN(info))
														 END
											FROM		#Results

                                            SET @Count = @@ROWCOUNT

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
										END
								END
						END

                    IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        IF @Verbose = 1 
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
		    END
	END



GO
/****** Object:  StoredProcedure [dbo].[CollectSQLDriveInfo_bk]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CollectSQLDriveInfo_bk]
(
	@DBMS_Id        int = NULL
    ,@Verbose       bit = 1
)

as

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLDriveInfoScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]



		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
		            SET @OutputFile = @BuildScriptPath + 'sqldbinfo_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'
        
					TRUNCATE TABLE #Results

                    IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
							DELETE FROM [dbo].[DriveSpaceInfo] WHERE DBMS_Id = @DBMSId
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											  OR		Info LIKE 'Warning%'																		
											  OR		Info LIKE '%Class not registered%'																		
											
											INSERT INTO [dbo].[DriveSpaceInfo]
											(
														[DBMS_Id]
														,[DriveLetter]
														,[TotalSpace]
														,[FreeSpace]	
														,[Notes]											
											)
											SELECT		@DBMSId				
														,LEFT(info, CHARINDEX('<1>', info) - 1)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
														 END													
														,SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<3>', info) + 3, LEN(info)) = '' 
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<3>', info) + 3, LEN(info))
														 END
											FROM		#Results

                                            SET @Count = @@ROWCOUNT

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
										END
								END
						END

                    IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        IF @Verbose = 1 
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
		    END
	END




GO
/****** Object:  StoredProcedure [dbo].[CollectSQLDriveSpaceMail]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CollectSQLDriveSpaceMail]

as

SET NOCOUNT ON

DECLARE @SQLServer		varchar(128)
		,@Connection	varchar(512)
		,@Cmd			varchar(2048)
		,@Script		varchar(512)
		,@OutputTo		varchar(512)
		,@ReturnValue	int
		,@SuccessCount	varchar(15)
		,@ErrorCount	varchar(15)
		,@Length		int
		,@Total			int
DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')	

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('Disk_Space')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo	
SET @Script = @ScriptInfo
SET @OutputFile = @BuildScriptPath + 'DiskSpace_' +  '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'

SET @OutputTo = @OutputFile;

CREATE TABLE #ServerInfo
(
	ServerName		varchar(128)
	,SQLConnection	varchar(512)
)
--INSERT INTO #ServerInfo VALUES ('dcssql','dcssql')
--INSERT INTO #ServerInfo VALUES ('dcssql2009','dcssql2009')
--INSERT INTO #ServerInfo VALUES ('pensql11','pensql11')
--INSERT INTO #ServerInfo VALUES ('PenSQL2012i','PenSQL2012i')
--INSERT INTO #ServerInfo VALUES ('Salt07','Salt07')
--INSERT INTO #ServerInfo VALUES ('PenSPSQL1','PenSPSQL1')
--INSERT INTO #ServerInfo VALUES ('QADCSSQL','QADCSSQL')
--INSERT INTO #ServerInfo VALUES ('QADCSSQL2009','QADCSSQL2009')
--INSERT INTO #ServerInfo VALUES ('QAPenSQL2012i','QAPenSQL2012i')
--INSERT INTO #ServerInfo VALUES ('QA2PenSQL11','QA2PenSQL11')
--INSERT INTO #ServerInfo VALUES ('QAPenSQL11','QAPenSQL11')
----INSERT INTO #ServerInfo VALUES ('PenSQLAudit','PenSQLAudit')
--INSERT INTO #ServerInfo VALUES ('DevPenSPSQL1','DevPenSPSQL1')
--INSERT INTO #ServerInfo VALUES ('PenSQL2k8Test','PenSQL2k8Test')
--INSERT INTO #ServerInfo VALUES ('SRTx64Test','SRTx64Test')
--INSERT INTO #ServerInfo VALUES ('PenSQLAudit','PenSQLAudit')
--INSERT INTO #ServerInfo VALUES ('BkBSPWeb2011','BkBSPWeb2011')
--INSERT INTO #ServerInfo VALUES ('BkDCSSQL2011','BkDCSSQL2011')
--INSERT INTO #ServerInfo VALUES ('DRPenSQL2012i','DRPenSQL2012i')
--INSERT INTO #ServerInfo VALUES ('BkSalt2011','BkSalt2011')
--INSERT INTO #ServerInfo VALUES ('BkDCS3','BkDCS3')
--INSERT INTO #ServerInfo VALUES ('DRBisDB1','DRBisDB1')
INSERT INTO #ServerInfo 
select name,name from [dbo].[Server]

PRINT CONVERT(varchar(30), GETDATE(), 109) + ' INPUT VARIABLE INFORMATOIN'
PRINT CONVERT(varchar(30), GETDATE(), 109) + '     @Script:    ' + @Script
PRINT CONVERT(varchar(30), GETDATE(), 109) + '     @OutputTo:  ' + @OutputTo

DECLARE CUSROR_SERVERS CURSOR FAST_FORWARD
FOR
	SELECT		ServerName
				,SQLConnection
	FROM		#ServerInfo
	ORDER BY	ServerName
	
OPEN CUSROR_SERVERS

SET @SuccessCount = 0
SET @ErrorCount = 0

FETCH FROM CUSROR_SERVERS
INTO @SQLServer, @Connection	

-- Reset Output File
SET @Cmd = 'echo.> "' + @OutputTo + '"'
EXECUTE xp_cmdshell  @Cmd, NO_OUTPUT

PRINT CONVERT(varchar(30), GETDATE(), 109) 

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT CONVERT(varchar(30), GETDATE(), 109) + ' GRABBING INFO FROM SQL SERVER ' + @SQLServer
	
	SET @Cmd = 'sqlcmd -S ' + @Connection + ' -d master -E -b -Q "SELECT @@VERSION" -l 10'

	EXECUTE @ReturnValue = xp_cmdshell @Cmd, NO_OUTPUT					

	IF @ReturnValue <> 0
		BEGIN
			SET @ErrorCount = @ErrorCount + 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' *** ERROR UNABLE TO CONNECT TO SQL'			
		END
	ELSE
		BEGIN
		
			SET @Cmd = 'sqlcmd -S ' + @Connection + ' -d master -E -b -i "' + 
					   @Script + '" -h -1 -l 30 -t 300 -W >> "' + @OutputTo  + '"'
					   
			EXECUTE @ReturnValue = xp_cmdshell @Cmd, NO_OUTPUT					

			IF @ReturnValue <> 0
				BEGIN
					SET @ErrorCount = @ErrorCount + 1
					PRINT CONVERT(varchar(30), GETDATE(), 109) + ' *** ERROR RUNNING SCRIPT'			
				END
			ELSE
				BEGIN
					SET @SuccessCount = @SuccessCount + 1

					PRINT CONVERT(varchar(30), GETDATE(), 109) + ' FINISH GRABBING INFO FROM SQL SERVER ' + @SQLServer
				END
		END
		
	PRINT CONVERT(varchar(30), GETDATE(), 109) 
	
	FETCH FROM CUSROR_SERVERS
	INTO @SQLServer, @Connection	
END

CLOSE CUSROR_SERVERS
DEALLOCATE CUSROR_SERVERS

SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
SET @Length = LEN(CAST(@Total AS varchar(15)))

PRINT ''
PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
PRINT '              ' + REPLICATE('-', @Length + 5)
PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))


CREATE TABLE #Mount_Volumes (
	--ID INT IDENTITY(1, 1)
	Drive VARCHAR(100)
	,Total_Space VARCHAR(100)
	,Used_Space VARCHAR(100)
	,Free_Space VARCHAR(100)
	,Drive_Status VARCHAR(20) DEFAULT 'OK'
	,Server_Name VARCHAR(255)
	);

	--BULK INSERT #Mount_Volumes FROM "d:\serverdbschema.out"    WITH    (        BATCHSIZE = 2        ,FIRSTROW = 2    ) 
--CREATE TABLE #tbl_schema 
--(
--	Instance_Nm		sysname
--	,Database_Nm	sysname
--	,Table_Nm		sysname
--	,Column_Nm		sysname
--	,Data_Type		sysname
--	,Length			smallint
--	,Prec			smallint
--	,Scale			int
--	,IsComputed		bit
--	,IsNullable		bit
--)

--BULK INSERT #Mount_Volumes FROM "d:\serverdbschema.out"    WITH    (        BATCHSIZE = 5000        ,FIRSTROW = 3    ) 

SET @Cmd = 'BULK INSERT #Mount_Volumes '
SET @Cmd = @Cmd + 
		   'FROM "' + @OutputTo + '" '
SET @Cmd = @Cmd + 
		   '   WITH '           
SET @Cmd = @Cmd + 
		   '   ( '
SET @Cmd = @Cmd + 
		   '       BATCHSIZE = 100 '                      
SET @Cmd = @Cmd + 
		   '       ,FIRSTROW = 1 '
SET @Cmd = @Cmd + 
		   '   ) '
EXECUTE (@Cmd)

--SELECT * FROM #Mount_Volumes                                     

DECLARE @Drive VARCHAR(100);
DECLARE @CRITICAL INT;
DECLARE @FREE VARCHAR(20);
DECLARE @TOTAL1 VARCHAR(20);
DECLARE @FREE_PER VARCHAR(20);
DECLARE @CHART VARCHAR(2000);
DECLARE @HTML VARCHAR(MAX);
DECLARE @TITLE VARCHAR(100);
DECLARE @HTMLTEMP VARCHAR(MAX)
DECLARE @HEAD VARCHAR(100);
DECLARE @PRIORITY VARCHAR(10);
DECLARE @To VARCHAR(200)
DECLARE @Server_Name VARCHAR(255)

--declare @DRIVE VARCHAR(100);
SET @CRITICAL = 20
SET @TITLE = 'DISK SPACE REPROT : ' + @@SERVERNAME
SET @HTML = '<HTML><TITLE>' + @TITLE + '</TITLE> 
<TABLE BORDER=0 CELLSPACING=0 CELLPADDING=2> 
 <TR BGCOLOR=#0070C0 ALIGN=CENTER STYLE=''FONT-SIZE:8.0PT;FONT-FAMILY:"TAHOMA","SANS-SERIF";COLOR:WHITE''> 
  <TD WIDTH=40><B>Drive</B></TD> 
  <TD WIDTH=250><B>Total Drive Space</B></TD> 
  <TD WIDTH=150><B>Free Drive Space</B></TD> 
  <TD WIDTH=150><B>Server Name</B></TD> 
  <TD WIDTH=150><B>Percentage Free</B></TD> 
</TR>'

DECLARE RECORDS CURSOR
FOR
SELECT CAST([Drive] AS VARCHAR(100)) AS 'Drive'
	,CAST(Total_Space AS VARCHAR(255)) AS 'Total_Space'
	,CAST(Free_Space AS VARCHAR(255)) AS 'Free_Space'
	,CAST(Server_Name AS VARCHAR(255)) AS 'Server_Name'
	,CONVERT(VARCHAR(2000), '<TABLE BORDER=0 ><TR><TD BORDER=0 BGCOLOR=' + CASE 
			WHEN (cast([Free_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0)) * 100.0 < 10
				THEN 'RED'
			WHEN (cast([Free_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0)) * 100.0 > 70
				THEN '66CC00'
			ELSE '0033FF'
			END + '><IMG SRC=''/GIFS/S.GIF'' WIDTH=' + cast(cast([Free_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0) * 100.0 AS CHAR(10))
		--CAST(CAST((cast([Used_Space] as float )/(cast ([Total_Space] as float) *1.0))*100.0*2 AS INT) AS CHAR(10) )
		+ ' HEIGHT=5></TD> 
     <TD><FONT SIZE=1>' + cast(cast([Free_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0) * 100.0 AS CHAR(10)) + '%</FONT></TD></TR></TABLE>') AS 'CHART'
--CAST(CAST(((cast([free_Space] as float )*1.0))*100.0 AS INT) AS CHAR(10) )+'%</FONT></TD></TR></TABLE>') AS 'CHART'   
FROM #Mount_Volumes
ORDER BY server_name ASC

OPEN RECORDS

FETCH NEXT
FROM RECORDS
INTO @DRIVE
	,@TOTAL1
	,@FREE
	,@Server_Name
	,@CHART

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @HTMLTEMP = '<TR BORDER=0 BGCOLOR="#E8E8E8" STYLE=''FONT-SIZE:8.0PT;FONT-FAMILY:"TAHOMA","SANS-SERIF";COLOR:#0F243E''> 
        <TD ALIGN = CENTER>' + @DRIVE + '</TD> 
        <TD ALIGN=CENTER>' + @TOTAL1 + '</TD> 
        <TD ALIGN=CENTER>' + @FREE + '</TD> 
		<TD ALIGN=CENTER>' + @Server_Name + '</TD>
        <TD  VALIGN=MIDDLE>' + @CHART + '</TD> 
        </TR>'
	SET @HTML = @HTML + @HTMLTEMP

	FETCH NEXT
	FROM RECORDS
	INTO @DRIVE
		,@TOTAL1
		,@FREE
		,@Server_Name
		,@CHART
END

CLOSE RECORDS

DEALLOCATE RECORDS

--SET @HTML = @HTML + '</TABLE><BR> 
--<P CLASS=MSONORMAL><SPAN STYLE=''FONT-SIZE:10.0PT;''COLOR:#1F497D''><B>THANKS,</B></SPAN></P> 
--<P CLASS=MSONORMAL><SPAN STYLE=''FONT-SIZE:10.0PT;''COLOR:#1F497D''><B>DBA TEAM</B></SPAN></P> 
--</HTML>' 
--PRINT  
PRINT @HTML

SET @head = 'Disk Space report from All SQL Servers'
-- : ' + @@servername


IF EXISTS (
		SELECT 1
		FROM #Mount_Volumes
		WHERE CAST((cast([Free_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0)) * 100.0 AS INT) <= @CRITICAL
		)
BEGIN
	SET @PRIORITY = 'HIGH'

	PRINT @head
		exec msdb.dbo.sp_send_dbmail     
		@profile_name = 'DBA_Mail_Profile',     
		@recipients = 'IT_Infra@pentegra.com',    
		@subject = @head, 
		@importance =  @Priority,   
		@body = @HTML,     
		@body_format = 'HTML' 
END
ELSE
BEGIN
	PRINT ''
END


DROP TABLE #ServerInfo
DROP TABLE #Mount_Volumes

GO
/****** Object:  StoredProcedure [dbo].[CollectSQLGuardiumAuditReport]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[CollectSQLGuardiumAuditReport]
(
	@DBMS_Id    int = NULL
	,@TestId    varchar(10) = ''
	,@Verbose   bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@SQLVersion			varchar(5)
		,@DelCount				int
		,@Count                 int

SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('GuardiumAuditReport_2000')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @ScriptFilename = [dbo].[funcGetConfigurationData]('GuardiumAuditReport_2005')
		SET @ScriptInfo = @BuildScriptPath + @ScriptFilename
		EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo
	END

IF @ReturnValue = 0
	BEGIN		
		SET @TestId = LTRIM(RTRIM(ISNULL(@TestId, '')))
		SET @SuccessCount = 0
		SET @ErrorCount = 0
		
		IF @Verbose = 1
		    BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@TestId:                    ' + @TestId
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
                        ,LEFT(SQLVersion, CHARINDEX('.', SQLVersion)-1) 
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]
            
		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection, @SQLVersion

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN		
            		SET @OutputFile = @BuildScriptPath + 'guardiumauditreport_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'

					TRUNCATE TABLE #Results
					
					IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
					                PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
							IF @TestId = '' 
								DELETE FROM [dbo].[GuardiumAuditReport] WHERE DBMS_Id = @DBMS_Id
							ELSE
							    BEGIN
							        IF @DBMS_Id IS NULL AND @TestId <> ''
    							        DELETE FROM [dbo].[GuardiumAuditReport] WHERE TestId = @TestId
							        ELSE
								        DELETE FROM [dbo].[GuardiumAuditReport] WHERE DBMS_Id = @DBMS_Id AND TestId = @TestId
                                END
                                							
							IF @SQLVersion = '8'
								SET @ScriptFilename = [dbo].[funcGetConfigurationData]('GuardiumAuditReport_2000')
							ELSE
								SET @ScriptFilename = [dbo].[funcGetConfigurationData]('GuardiumAuditReport_2005')

							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 2048 -l 30 -t 300 -W -v TestId="' + @TestId + '" > "' + @OutputFile + '"'

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											  OR		Info LIKE 'Warning%'																		
											  OR		Info LIKE 'Changed database context to%'
											
											INSERT INTO [dbo].[GuardiumAuditReport]
											(
														[DBMS_Id]
														,[TestId]
														,[TestDescription]
														,[DbName]
														,[Description]
														,[FixScript]
														,[RollbackScript]
											)
											SELECT		@DBMSId				
														,LEFT(info, CHARINDEX('<1>', info) - 1)
														,SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<5>', info) + 3, LEN(info))
											FROM		#Results

                                            SET @Count = @@ROWCOUNT

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
										END
								END
						END
						
					IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT
													
					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection, @SQLVersion
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        IF @Verbose = 1
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
		    END
	END



GO
/****** Object:  StoredProcedure [dbo].[CollectSQLJobScheduleInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLJobScheduleInfo]
(
	@DBMS_Id        int = NULL
    ,@Verbose       bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@SQLVersion			varchar(10)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLJobScheduleInfoScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLJobScheduleInfoScript_v8')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
                        ,LEFT(SQLVersion, CHARINDEX('.', SQLVersion)-1) 
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]

		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection, @SQLVersion

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
            		SET @OutputFile = @BuildScriptPath + 'sqljobschinfo_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'

					IF @SQLVersion = '8'
						SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLJobScheduleInfoScript_v8')
					ELSE 
						SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLJobScheduleInfoScript')
						
					SET @ScriptInfo = @BuildScriptPath + @ScriptFilename					
				
					TRUNCATE TABLE #Results
					
					IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN							    
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
                                END							        
						END
					ELSE
						BEGIN
                            DELETE FROM [dbo].[JobScheduleInfo] WHERE DBMS_Id = @DBMSId
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											
											INSERT INTO [dbo].[JobScheduleInfo]
											(
														[DBMS_Id]
														,[JobName]
														,[ScheduleName]
														,[ScheduleInfo]
														,[ScheduleType]
														,[StartDate]
														,[StartTime]
														,[EndDate]
														,[EndTime]
														,[Frequency]
														,[Day]
														,[DayOfMonth]
														,[Every]
														,[DailyInterval]
														,[DailyIntervalType]
														,[Sunday]
														,[Monday]
														,[Tuesday]
														,[Wednesday]
														,[Thursday]
														,[Friday]
														,[Saturday]
														,[JobOwner]
											)
											SELECT		@DBMSId				
														,LEFT(info, CHARINDEX('<1>', info) - 1)
														,SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3)
														 END
														,SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<10>', info) + 4, CHARINDEX('<11>', info) - CHARINDEX('<10>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<11>', info) + 4, CHARINDEX('<12>', info) - CHARINDEX('<11>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<12>', info) + 4, CHARINDEX('<13>', info) - CHARINDEX('<12>', info) - 4)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<13>', info) + 4, CHARINDEX('<14>', info) - CHARINDEX('<13>', info) - 4) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<13>', info) + 4, CHARINDEX('<14>', info) - CHARINDEX('<13>', info) - 4)
														 END
														,SUBSTRING(info, CHARINDEX('<14>', info) + 4, CHARINDEX('<15>', info) - CHARINDEX('<14>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<15>', info) + 4, CHARINDEX('<16>', info) - CHARINDEX('<15>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<16>', info) + 4, CHARINDEX('<17>', info) - CHARINDEX('<16>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<17>', info) + 4, CHARINDEX('<18>', info) - CHARINDEX('<17>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<18>', info) + 4, CHARINDEX('<19>', info) - CHARINDEX('<18>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<19>', info) + 4, CHARINDEX('<20>', info) - CHARINDEX('<19>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<20>', info) + 4, CHARINDEX('<21>', info) - CHARINDEX('<20>', info) - 4)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<21>', info) + 4, LEN(info)) = 'NULL' 
															THEN NULL 
															ELSE SUBSTRING(info, CHARINDEX('<21>', info) + 4, LEN(info)) 
														 END
											FROM		#Results

                                            SET @Count = @@ROWCOUNT

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
										END
								END
						END

                    IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection, @SQLVersion
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        IF @Verbose = 1
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
            END		        
	END



GO
/****** Object:  StoredProcedure [dbo].[CollectSQLJobSummary]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLJobSummary]
(
	@DBMS_Id    int = NULL
    ,@Verbose   bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLJobSummaryScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
        
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]


		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
            		SET @OutputFile = @BuildScriptPath + 'sqljobsummary_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'

					TRUNCATE TABLE #Results
					
					IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
						    DELETE FROM [dbo].[JobSummary] WHERE DBMS_Id = @DBMSId
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											    
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											  OR		Info LIKE 'Warning%'																		
											
											INSERT INTO [dbo].[JobSummary]
											(
														[DBMS_Id]
													   ,[Name]
													   ,[Enabled]
													   ,[LastFailureDate]
													   ,[LastFailureDuration_Sec]
													   ,[LastSuccessDate]
													   ,[LastSuccessDuration_Sec]
													   ,[NextRunDate]
													   ,[Running]
													   ,[RunningDuration_Sec]
													   ,[TodayErrorCount]
													   ,[TodaySuccessCount]
													   ,[YesterdayErrorCount]
													   ,[YesterdaySuccessCount]
													   ,[TwoDaysAgoErrorCount]
													   ,[TwoDaysAgoSuccessCount]
													   ,[ThreeDaysAgoErrorCount]
													   ,[ThreeDaysAgoSuccessCount]
											)
											SELECT		@DBMSId				
														,LEFT(info, CHARINDEX('<1>', info) - 1)
														,SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
														,CASE WHEN RTRIM(SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
														 END
														,CASE WHEN RTRIM(SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3)) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3)
														 END
														,CASE WHEN RTRIM(SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3)) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3)
														 END
														,CASE WHEN RTRIM(SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3)) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3)
														 END
														,CASE WHEN RTRIM(SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3)) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3)
														 END
														,SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<10>', info) + 4, CHARINDEX('<11>', info) - CHARINDEX('<10>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<11>', info) + 4, CHARINDEX('<12>', info) - CHARINDEX('<11>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<12>', info) + 4, CHARINDEX('<13>', info) - CHARINDEX('<12>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<13>', info) + 4, CHARINDEX('<14>', info) - CHARINDEX('<13>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<14>', info) + 4, CHARINDEX('<15>', info) - CHARINDEX('<14>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<15>', info) + 4, CHARINDEX('<16>', info) - CHARINDEX('<15>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<16>', info) + 4, LEN(info))
											FROM		#Results

                                            SET @Count = @@ROWCOUNT
                                            
                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
										END
								END
						END

                    IF @Verbose = 1						
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        IF @Verbose = 1
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
            END
	END



GO
/****** Object:  StoredProcedure [dbo].[CollectSQLLinkedServerInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLLinkedServerInfo]
(
	@DBMS_Id        int = NULL
    ,@Verbose       bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLLinkedServerInfoScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]

		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
            		SET @OutputFile = @BuildScriptPath + 'sqllinkedserverinfo_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'

					TRUNCATE TABLE #Results
					
					IF @Verbose = 1
					PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
							DELETE FROM [dbo].[LinkedServers] WHERE DBMS_Id = @DBMSId
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 1024 -l 30 -t 120 > "' + @OutputFile + '"'

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command

									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											
											INSERT INTO [dbo].[LinkedServers]
											(
														[DBMS_Id]
														,[LinkedServer]
														,[LocalLogin]
														,[LoginType]
														,[Impersonate]
														,[RemoteUser]
														,[LoginNotDefine]
														,[Provider]
														,[DataSource]
														,[Location]
														,[ProviderString]
														,[Catalog]
														,[CollationCompatible]
														,[DataAccess]
														,[Rpc]
														,[RpcOut]
														,[UseRemoteCollation]
														,[CollationName]
														,[ConnectionTimeout]
														,[QueryTimeout]
											)							
											SELECT		@DBMSId				
														,LEFT(info, CHARINDEX('<1>', info) - 1)
														,SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<10>', info) + 4, CHARINDEX('<11>', info) - CHARINDEX('<10>', info) - 4) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<10>', info) + 4, CHARINDEX('<11>', info) - CHARINDEX('<10>', info) - 4)
														 END
														,SUBSTRING(info, CHARINDEX('<11>', info) + 4, CHARINDEX('<12>', info) - CHARINDEX('<11>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<12>', info) + 4, CHARINDEX('<13>', info) - CHARINDEX('<12>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<13>', info) + 4, CHARINDEX('<14>', info) - CHARINDEX('<13>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<14>', info) + 4, CHARINDEX('<15>', info) - CHARINDEX('<14>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<15>', info) + 4, CHARINDEX('<16>', info) - CHARINDEX('<15>', info) - 4)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<16>', info) + 4, CHARINDEX('<17>', info) - CHARINDEX('<16>', info) - 4) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<16>', info) + 4, CHARINDEX('<17>', info) - CHARINDEX('<16>', info) - 4)
														 END
														,SUBSTRING(info, CHARINDEX('<17>', info) + 4, CHARINDEX('<18>', info) - CHARINDEX('<17>', info) - 4)
														,SUBSTRING(info, CHARINDEX('<18>', info) + 4, LEN(info))
											FROM		#Results											
											
											SET @Count = @@ROWCOUNT

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
										END
								END
						END

                    IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        IF @Verbose = 1
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
            END
	END



GO
/****** Object:  StoredProcedure [dbo].[CollectSQLLogShippingInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLLogShippingInfo] 
(
	@DBMS_Id        int = NULL
    ,@Verbose       bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLLogShippingInfoScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]

		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
    		        SET @OutputFile = @BuildScriptPath + 'sqllogshipinfo_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'

					TRUNCATE TABLE #Results
					
					IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
							DELETE FROM [dbo].[LogShippingInfo] WHERE DBMS_Id = @DBMSId
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											  OR		Info LIKE 'Warning%'																		
											
											INSERT INTO [dbo].[LogShippingInfo]
											(
														[DBMS_Id]
														,[Source]
														,[SourceDBExist]
														,[PrimaryServer]
														,[PrimaryDatabase]
														,[SecondaryServer]
														,[SecondaryDatabase]
														,[MonitorServer]
														,[BackupDirectory]
														,[BackupShare]
														,[LastBackupFile]
														,[LastBackupDate]
														,[LastCopiedFile]
														,[LastCopiedDate]
														,[LastRestoredFile]
														,[LastRestoredDate]
														,[BackupRetentionPeriod]
														,[SQLTransBackupJob]
														,[SQLCopyJob]
														,[SQLRestoreJob]
											)														
											SELECT		@DBMSId				
														,LEFT(info, CHARINDEX('<1>', info) - 1)
														,SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<10>', info) + 4, CHARINDEX('<11>', info) - CHARINDEX('<10>', info) - 4) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<10>', info) + 4, CHARINDEX('<11>', info) - CHARINDEX('<10>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<11>', info) + 4, CHARINDEX('<12>', info) - CHARINDEX('<11>', info) - 4) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<11>', info) + 4, CHARINDEX('<12>', info) - CHARINDEX('<11>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<12>', info) + 4, CHARINDEX('<13>', info) - CHARINDEX('<12>', info) - 4) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<12>', info) + 4, CHARINDEX('<13>', info) - CHARINDEX('<12>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<13>', info) + 4, CHARINDEX('<14>', info) - CHARINDEX('<13>', info) - 4) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<13>', info) + 4, CHARINDEX('<14>', info) - CHARINDEX('<13>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<14>', info) + 4, CHARINDEX('<15>', info) - CHARINDEX('<14>', info) - 4) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<14>', info) + 4, CHARINDEX('<15>', info) - CHARINDEX('<14>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<15>', info) + 4, CHARINDEX('<16>', info) - CHARINDEX('<15>', info) - 4) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<15>', info) + 4, CHARINDEX('<16>', info) - CHARINDEX('<15>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<16>', info) + 4, CHARINDEX('<17>', info) - CHARINDEX('<16>', info) - 4) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<16>', info) + 4, CHARINDEX('<17>', info) - CHARINDEX('<16>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<17>', info) + 4, CHARINDEX('<18>', info) - CHARINDEX('<17>', info) - 4) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<17>', info) + 4, CHARINDEX('<18>', info) - CHARINDEX('<17>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<18>', info) + 4, LEN(info)) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<18>', info) + 4, LEN(info))
														 END
											FROM		#Results

                                            SET @Count = @@ROWCOUNT

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
										END
								END
						END

                    IF @Verbose = 1							
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        IF @Verbose = 1
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
            END            
	END




GO
/****** Object:  StoredProcedure [dbo].[CollectSQLReplicationInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLReplicationInfo] 
(
	@DBMS_Id        int = NULL
    ,@Verbose       bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLReplicationInfoScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]

		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
    		        SET @OutputFile = @BuildScriptPath + 'sqlreplinfo_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'

					TRUNCATE TABLE #Results
					
					IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
							DELETE FROM [dbo].[ReplicationInfo] WHERE DBMS_Id = @DBMSId
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											  OR		Info LIKE 'Warning%'																		
											
											INSERT INTO [dbo].[ReplicationInfo]
											(
                                                        [DBMS_Id]
                                                        ,[PublicationServer]
                                                        ,[PublicationDb]
                                                        ,[Publication]
                                                        ,[PublicationArticle]
                                                        ,[DestinationObject]
                                                        ,[SubscriptionServer]
                                                        ,[SubscriberDb]
                                                        ,[SubscriptionType]
                                                        ,[SubscriberLogin]
                                                        ,[SubscriberSecurityMode]
                                                        ,[DistributionAgentSQLJob]											
											)
											SELECT		@DBMSId				
														,LEFT(info, CHARINDEX('<1>', info) - 1)
														,SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3)
														,SUBSTRING(info, CHARINDEX('<10>', info) + 4, LEN(info))
											FROM		#Results

                                            SET @Count = @@ROWCOUNT

                                            IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
										END
								END
						END

                    IF @Verbose = 1							
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        IF @Verbose = 1
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
            END            
	END




GO
/****** Object:  StoredProcedure [dbo].[CollectSQLSecuritySummary]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLSecuritySummary]
(
	@DBMS_Id int = NULL
    ,@Verbose       bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@SQLVersion			varchar(10)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLSecuritySummaryScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLSecuritySummaryScript_v8')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
                        ,LEFT(SQLVersion, CHARINDEX('.', SQLVersion)-1) 
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]


		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection, @SQLVersion

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
            		SET @OutputFile = @BuildScriptPath + 'sqlsecsummary_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'
            		
					IF @SQLVersion = '8'
						SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLSecuritySummaryScript_v8')
					ELSE 
						SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLSecuritySummaryScript')
				
					TRUNCATE TABLE #Results
					
					IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
                                END
						END
					ELSE
						BEGIN
					        DELETE FROM [dbo].[SecuritySummary] WHERE DBMS_Id = @DBMSId
        					
					        SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
							           @BuildScriptPath + @ScriptFilename + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                            IF @Verbose = 1
					            PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

					        INSERT INTO #Results
					        EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

					        IF @ReturnValue <> 0 
						        BEGIN
							        SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
							            PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
						        END
					        ELSE
						        BEGIN
							        SET @Command = 'BULK INSERT #Results ' +
										           'FROM ''' + @OutputFile + ''' ' + 
										           'WITH ' +
										           '( ' +
												        'BATCHSIZE  = 5000 ' +
										           ') '

							        IF @Verbose = 1
							            PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							        EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
        							
							        IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
								        BEGIN
									        SET @ErrorCount = @ErrorCount + 1

									        IF @Verbose = 1
									            PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								        END
							        ELSE
								        BEGIN 
									        SET @SuccessCount = @SuccessCount + 1
									        
									        IF @Verbose = 1
									            PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

									        DELETE 
									        FROM		#Results 
									        WHERE		LTRIM(ISNULL(Info, '')) = '' 
									          OR		Info LIKE 'Warning%'																		
        									
									        INSERT INTO [dbo].[SecuritySummary]
									        (
												        [DBMS_Id]
												        ,[SecurityInfo]
												        ,[SecurityType]
												        ,[DatabaseName]
												        ,[ClassName]
												        ,[ObjectName]
												        ,[ObjectType]
												        ,[ColumnName]
												        ,[Permission]
												        ,[State]
									        )
									        SELECT		@DBMSId				
												        ,CASE WHEN LEFT(info, CHARINDEX('<1>', info) - 1) = 'NULL'
													        THEN NULL
													        ELSE LEFT(info, CHARINDEX('<1>', info) - 1)
												         END
												        ,CASE WHEN SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3) = 'NULL'
													        THEN NULL
													        ELSE SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
												         END
												        ,CASE WHEN SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3) = 'NULL'
													        THEN NULL
													        ELSE SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
												         END
												        ,CASE WHEN SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3) = 'NULL'
													        THEN NULL
													        ELSE SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3)
												         END
												        ,CASE WHEN SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3) = 'NULL'
													        THEN NULL
													        ELSE SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3)
												         END
												        ,SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3)
												        ,CASE WHEN SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3) = 'NULL'
													        THEN NULL
													        ELSE SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3)
												         END
												        ,CASE WHEN SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3) = 'NULL'
													        THEN NULL
													        ELSE SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3)
												         END
												        ,CASE WHEN SUBSTRING(info, CHARINDEX('<8>', info) + 3, LEN(info)) = 'NULL'
													        THEN NULL
													        ELSE SUBSTRING(info, CHARINDEX('<8>', info) + 3, LEN(info))
												         END
									        FROM		#Results
									        
									        SET @Count = @@ROWCOUNT

									        IF @Verbose = 1
									            PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
								        END
						        END

							IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) 
						END

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection, @SQLVersion
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

		IF @Verbose = 1
		    BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
		    END
	END
	


GO
/****** Object:  StoredProcedure [dbo].[CollectSQLServicesInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLServicesInfo] 
(
	@DBMS_Id        int = NULL
    ,@Verbose       bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count					int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('SQLServiceInfoScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]

		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN	
		            SET @OutputFile = @BuildScriptPath + 'sqlservicesinfo_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'

					TRUNCATE TABLE #Results
					
					IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'

					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
                                END
						END
					ELSE
						BEGIN
                            DELETE FROM [dbo].[Services] WHERE DBMS_Id = @DBMSId
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 1024 -l 30 -t 120 > "' + @OutputFile  + '"'

                            IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                    IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

									IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command

									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN 
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											   OR		Info LIKE 'RegQueryValueEx() returned error 2%'
											   OR		Info LIKE 'RegOpenKeyEx() returned error 2%'
											
											INSERT INTO dbo.Services
											(
													DBMS_Id
													,Name
													,DisplayName
													,ServiceAccount
													,StartupType
													,BinaryPath
													,Status
											)							
											SELECT		@DBMSId									AS [ServerId]
														,LEFT(Info, CHARINDEX('<1>', Info) - 1)		AS [Services]
														,SUBSTRING(
																	Info, 
																	CHARINDEX('<1>', Info) + 3, 
																	CHARINDEX('<2>', Info) - CHARINDEX('<1>', Info) - 3
																 )									AS [DisplayName]
														,SUBSTRING(
																	Info, 
																	CHARINDEX('<2>', Info) + 3, 
																	CHARINDEX('<3>', Info) - CHARINDEX('<2>', Info) - 3
																 )									AS [ServiceAccount]
														,SUBSTRING(
																	Info, 
																	CHARINDEX('<3>', Info) + 3, 
																	CHARINDEX('<4>', Info) - CHARINDEX('<3>', Info) - 3
																 )									AS [StartupType]
														,SUBSTRING(
																	Info, 
																	CHARINDEX('<4>', Info) + 3, 
																	CHARINDEX('<5>', Info) - CHARINDEX('<4>', Info) - 3
																 )									AS [BinaryPath]
														,SUBSTRING(
																		Info, 
																		CHARINDEX('<5>', Info) + 3, 
																		LEN(info)
																   )								AS [Status]
											FROM		#Results
											
											SET @Count = @@ROWCOUNT
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
										END
								END
						END
						
					IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

		IF @Verbose = 1
		    BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
            END
	END



GO
/****** Object:  StoredProcedure [dbo].[CollectSQLTSMBackupSummary]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CollectSQLTSMBackupSummary]
(
	@DBMS_Id    int = NULL
    ,@Verbose       bit = 1
) AS

SET NOCOUNT ON 

DECLARE	@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Filename				varchar(256)
		,@Count                 int


SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('TSMBackupSummaryScript')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

IF @ReturnValue = 0
	BEGIN
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      Id              AS [DBMS_Id]
                        ,SQLServer
                        ,DataCollectorConnectString
            FROM        dbo.SQLAbleToCollectInfoOn
            WHERE       (
                            @DBMS_Id IS NULL
                                OR Id = @DBMS_Id
                        )
            ORDER BY	[SQLServer]
            
		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO @DBMSId, @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 AND @Verbose = 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
            		SET @OutputFile = @BuildScriptPath + 'tsmbackupsummary_' + CAST(@DBMSId AS varchar(10)) + '_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'
            		
					TRUNCATE TABLE #Results
					
					IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '

					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							IF @Verbose = 1
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
                                END
						END
					ELSE
						BEGIN
							DELETE FROM [dbo].[TSMBackupSummary] WHERE DBMS_Id = @DBMSId
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -i "' + 
									   @BuildScriptPath + @ScriptFilename + '" -h -1 -w 4096 -l 30 -t 300 > "' + @OutputFile + '"'

							IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

									IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							ELSE
								BEGIN
									SET @Command = 'BULK INSERT #Results ' +
												   'FROM ''' + @OutputFile + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

									IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

									EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
									IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
										BEGIN
											SET @ErrorCount = @ErrorCount + 1

											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
										END
									ELSE
										BEGIN
											SET @SuccessCount = @SuccessCount + 1
											
											IF @Verbose = 1
											    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

											DELETE 
											FROM		#Results 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											  OR		Info LIKE 'Warning%'																		
											  OR        Info LIKE 'Msg 4861%'
											  OR        Info LIKE 'Msg 4860%'
											  OR		Info LIKE 'Could not bulk insert%'
											  OR        Info LIKE 'Cannot bulk%'
											  OR		Info LIKE 'RegQueryValueEx() returned error%'
											  
											INSERT INTO [dbo].[TSMBackupSummary]
											(
													[DBMS_Id]
													,[LogFile]
													,[ScheduleName]
													,[ScheduleDate]
													,[StartDate]
													,[EndDate]
													,[BackupPaths]
													,[ObjectsInspected]
													,[ObjectsAssigned]
													,[ObjectsBackedUp]
													,[ObjectsUpdated]
													,[ObjectsRebound]
													,[ObjectsDeleted]
													,[ObjectsExpired]
													,[ObjectsFailed]
													,[SubfileObjects]
													,[BytesInspected]
													,[BytesTransferred]
													,[DataTransferTime]
													,[DataTransferRate]
													,[AggDataTransferRate]
													,[CompressPercentage]
													,[DataReductionRatio]
													,[SubfileObjectsReduceBy]
													,[ElapseProcessingTime]
											)
											SELECT		@DBMSId				
														,LEFT(info, CHARINDEX('<1>', info) - 1)
														,CASE WHEN SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<1>', info) + 3, CHARINDEX('<2>', info) - CHARINDEX('<1>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<2>', info) + 3, CHARINDEX('<3>', info) - CHARINDEX('<2>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<3>', info) + 3, CHARINDEX('<4>', info) - CHARINDEX('<3>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<4>', info) + 3, CHARINDEX('<5>', info) - CHARINDEX('<4>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<5>', info) + 3, CHARINDEX('<6>', info) - CHARINDEX('<5>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<6>', info) + 3, CHARINDEX('<7>', info) - CHARINDEX('<6>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3) = ''
															THEN NULL 
															ELSE SUBSTRING(info, CHARINDEX('<7>', info) + 3, CHARINDEX('<8>', info) - CHARINDEX('<7>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<8>', info) + 3, CHARINDEX('<9>', info) - CHARINDEX('<8>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<9>', info) + 3, CHARINDEX('<10>', info) - CHARINDEX('<9>', info) - 3)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<10>', info) + 4, CHARINDEX('<11>', info) - CHARINDEX('<10>', info) - 4) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<10>', info) + 4, CHARINDEX('<11>', info) - CHARINDEX('<10>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<11>', info) + 4, CHARINDEX('<12>', info) - CHARINDEX('<11>', info) - 4) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<11>', info) + 4, CHARINDEX('<12>', info) - CHARINDEX('<11>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<12>', info) + 4, CHARINDEX('<13>', info) - CHARINDEX('<12>', info) - 4) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<12>', info) + 4, CHARINDEX('<13>', info) - CHARINDEX('<12>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<13>', info) + 4, CHARINDEX('<14>', info) - CHARINDEX('<13>', info) - 4) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<13>', info) + 4, CHARINDEX('<14>', info) - CHARINDEX('<13>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<14>', info) + 4, CHARINDEX('<15>', info) - CHARINDEX('<14>', info) - 4) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<14>', info) + 4, CHARINDEX('<15>', info) - CHARINDEX('<14>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<15>', info) + 4, CHARINDEX('<16>', info) - CHARINDEX('<15>', info) - 4) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<15>', info) + 4, CHARINDEX('<16>', info) - CHARINDEX('<15>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<16>', info) + 4, CHARINDEX('<17>', info) - CHARINDEX('<16>', info) - 4) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<16>', info) + 4, CHARINDEX('<17>', info) - CHARINDEX('<16>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<17>', info) + 4, CHARINDEX('<18>', info) - CHARINDEX('<17>', info) - 4) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<17>', info) + 4, CHARINDEX('<18>', info) - CHARINDEX('<17>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<18>', info) + 4, CHARINDEX('<19>', info) - CHARINDEX('<18>', info) - 4) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<18>', info) + 4, CHARINDEX('<19>', info) - CHARINDEX('<18>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<19>', info) + 4, CHARINDEX('<20>', info) - CHARINDEX('<19>', info) - 4) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<19>', info) + 4, CHARINDEX('<20>', info) - CHARINDEX('<19>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<20>', info) + 4, CHARINDEX('<21>', info) - CHARINDEX('<20>', info) - 4) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<20>', info) + 4, CHARINDEX('<21>', info) - CHARINDEX('<20>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<21>', info) + 4, CHARINDEX('<22>', info) - CHARINDEX('<21>', info) - 4) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<21>', info) + 4, CHARINDEX('<22>', info) - CHARINDEX('<21>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<22>', info) + 4, CHARINDEX('<23>', info) - CHARINDEX('<22>', info) - 4) = ''
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<22>', info) + 4, CHARINDEX('<23>', info) - CHARINDEX('<22>', info) - 4)
														 END
														,CASE WHEN SUBSTRING(info, CHARINDEX('<23>', info) + 4, LEN(info)) = 'NULL'
															THEN NULL
															ELSE SUBSTRING(info, CHARINDEX('<23>', info) + 4, LEN(info))
														 END
											FROM		#Results A
										END
										
								    SET @Count = @@ROWCOUNT
								    
									IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
								END

							IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) 
						END

		            SET @Command = 'DEL ' + @OutputFile				
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT
						
					FETCH NEXT FROM CURSOR_SERVER
					INTO @DBMSId, @SQLServer, @SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

		IF @Verbose = 1
		    BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
            END
	END



GO
/****** Object:  StoredProcedure [dbo].[Generate_InstanceConfiguration_Report]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Generate_InstanceConfiguration_Report]
(
	@BuildPath      varchar(256) 
   
) AS

SET NOCOUNT ON;
DECLARE	
@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('GenerateInstanceConfiguration')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

set @BuildScriptPath = @ScriptInfo;
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        --IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		      --  PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      name,ipaddress
            FROM       [DBA_DataCollector].[dbo].[DBMS]

		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO  @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
		            SET @OutputFile = @BuildPath + '\' +ltrim(rtrim(@SQLServer)) +'_DR_Report_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'
      
					TRUNCATE TABLE #Results

               
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '
			
					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath  + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                          --  IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                   -- IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							--ELSE
								--BEGIN
								--	SET @Command = 'BULK INSERT #Results ' +
								--				   'FROM ''' + @OutputFile + ''' ' + 
								--				   'WITH ' +
								--				   '( ' +
								--						'BATCHSIZE  = 5000 ' +
								--				   ') '

        --                           -- IF @Verbose = 1
								--	    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

								--	EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
								--	IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
								--		BEGIN
								--			SET @ErrorCount = @ErrorCount + 1

        --                                --    IF @Verbose = 1
								--			    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								--		END
								--	ELSE
								--		BEGIN 
								--			SET @SuccessCount = @SuccessCount + 1
											
								--		--	IF @Verbose = 1
								--			    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

								--			DELETE 
								--			FROM		#Results 
								--			WHERE		LTRIM(ISNULL(Info, '')) = '' 
								--			  OR		Info LIKE 'Warning%'																		
								--			  OR		Info LIKE '%Class not registered%'																		
											


        --                                    SET @Count = @@ROWCOUNT

        --                                   -- IF @Verbose = 1
								--			    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
								--		END
								--END
						END

                   -- IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            --SET @Command = 'DEL ' + @OutputFile				
		            --EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @SQLServer,@SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        --IF @Verbose = 1 
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
		    END




GO
/****** Object:  StoredProcedure [dbo].[GenerateDRReport]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GenerateDRReport]
(
	@BuildPath      varchar(256) 
   
) AS

SET NOCOUNT ON;
DECLARE	
@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('GenerateDRReport')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

set @BuildScriptPath = @ScriptInfo;
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        --IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		      --  PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      name,ipaddress
            FROM       [DBA_DataCollector].[dbo].[DBMS]

		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO  @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
		            SET @OutputFile = @BuildPath + '\' +ltrim(rtrim(@SQLServer)) +'_DR_Report_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'
      
					TRUNCATE TABLE #Results

               
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '
			
					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath  + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                          --  IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                   -- IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							--ELSE
								--BEGIN
								--	SET @Command = 'BULK INSERT #Results ' +
								--				   'FROM ''' + @OutputFile + ''' ' + 
								--				   'WITH ' +
								--				   '( ' +
								--						'BATCHSIZE  = 5000 ' +
								--				   ') '

        --                           -- IF @Verbose = 1
								--	    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

								--	EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
								--	IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
								--		BEGIN
								--			SET @ErrorCount = @ErrorCount + 1

        --                                --    IF @Verbose = 1
								--			    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								--		END
								--	ELSE
								--		BEGIN 
								--			SET @SuccessCount = @SuccessCount + 1
											
								--		--	IF @Verbose = 1
								--			    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

								--			DELETE 
								--			FROM		#Results 
								--			WHERE		LTRIM(ISNULL(Info, '')) = '' 
								--			  OR		Info LIKE 'Warning%'																		
								--			  OR		Info LIKE '%Class not registered%'																		
											


        --                                    SET @Count = @@ROWCOUNT

        --                                   -- IF @Verbose = 1
								--			    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
								--		END
								--END
						END

                   -- IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            --SET @Command = 'DEL ' + @OutputFile				
		            --EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @SQLServer,@SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        --IF @Verbose = 1 
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
		    END




GO
/****** Object:  StoredProcedure [dbo].[GenerateMailProfilesReport]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GenerateMailProfilesReport]
(
	@BuildPath      varchar(256) 
   
) AS

SET NOCOUNT ON;
DECLARE	
@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('GenerateMailProfilesReport')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

set @BuildScriptPath = @ScriptInfo;
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        --IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		      --  PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      name,ipaddress
            FROM       [DBA_DataCollector].[dbo].[DBMS]

		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO  @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
		            SET @OutputFile = @BuildPath + '\' +ltrim(rtrim(@SQLServer)) +'_Mail_profile_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'
      
					TRUNCATE TABLE #Results

               
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '
			
					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath  + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                          --  IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                   -- IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							--ELSE
								--BEGIN
								--	SET @Command = 'BULK INSERT #Results ' +
								--				   'FROM ''' + @OutputFile + ''' ' + 
								--				   'WITH ' +
								--				   '( ' +
								--						'BATCHSIZE  = 5000 ' +
								--				   ') '

        --                           -- IF @Verbose = 1
								--	    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

								--	EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
								--	IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
								--		BEGIN
								--			SET @ErrorCount = @ErrorCount + 1

        --                                --    IF @Verbose = 1
								--			    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								--		END
								--	ELSE
								--		BEGIN 
								--			SET @SuccessCount = @SuccessCount + 1
											
								--		--	IF @Verbose = 1
								--			    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

								--			DELETE 
								--			FROM		#Results 
								--			WHERE		LTRIM(ISNULL(Info, '')) = '' 
								--			  OR		Info LIKE 'Warning%'																		
								--			  OR		Info LIKE '%Class not registered%'																		
											


        --                                    SET @Count = @@ROWCOUNT

        --                                   -- IF @Verbose = 1
								--			    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
								--		END
								--END
						END

                   -- IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            --SET @Command = 'DEL ' + @OutputFile				
		            --EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @SQLServer,@SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        --IF @Verbose = 1 
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
		    END




GO
/****** Object:  StoredProcedure [dbo].[GenerateSQLjobinfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GenerateSQLjobinfo]
(
	@BuildPath      varchar(256)
   
) AS
DECLARE	
@BuildScriptPath		varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('GenerateSQLjobinfo')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

set @BuildScriptPath = @ScriptInfo;
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        --IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		      --  PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)

		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      name,ipaddress
            FROM       [DBA_DataCollector].[dbo].[DBMS]

		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO  @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
		            SET @OutputFile = @BuildPath + '\' +ltrim(rtrim(@SQLServer)) +'_SQLjob_' + REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'
      
					TRUNCATE TABLE #Results

               
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '
			
					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN
							
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -E -b -i "' + 
									   @BuildScriptPath  + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                          --  IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                   -- IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							--ELSE
								--BEGIN
								--	SET @Command = 'BULK INSERT #Results ' +
								--				   'FROM ''' + @OutputFile + ''' ' + 
								--				   'WITH ' +
								--				   '( ' +
								--						'BATCHSIZE  = 5000 ' +
								--				   ') '

        --                           -- IF @Verbose = 1
								--	    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

								--	EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
								--	IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
								--		BEGIN
								--			SET @ErrorCount = @ErrorCount + 1

        --                                --    IF @Verbose = 1
								--			    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								--		END
								--	ELSE
								--		BEGIN 
								--			SET @SuccessCount = @SuccessCount + 1
											
								--		--	IF @Verbose = 1
								--			    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

								--			DELETE 
								--			FROM		#Results 
								--			WHERE		LTRIM(ISNULL(Info, '')) = '' 
								--			  OR		Info LIKE 'Warning%'																		
								--			  OR		Info LIKE '%Class not registered%'																		
											


        --                                    SET @Count = @@ROWCOUNT

        --                                   -- IF @Verbose = 1
								--			    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
								--		END
								--END
						END

                   -- IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            --SET @Command = 'DEL ' + @OutputFile				
		            --EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @SQLServer,@SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

		DROP TABLE #Results

		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        --IF @Verbose = 1 
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
		    END




GO
/****** Object:  StoredProcedure [dbo].[GenerateUserpermissionsinfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GenerateUserpermissionsinfo]
(
	@BuildPath      varchar(256)
   
) AS

DECLARE	@BuildScriptPath  varchar(256)
		,@ScriptFilename		varchar(256)
		,@DBMSId				int
		,@SQLServer				varchar(256)
		,@SQLConnection			varchar(256)
		,@Command				nvarchar(4000)
		,@ReturnValue			int
		,@SuccessCount			varchar(15)
		,@ErrorCount			varchar(15)
		,@Length				int
		,@Total					int
		,@ScriptInfo			varchar(128)
		,@OutputFile			varchar(256)
		,@Count                 int
		,@DBName				varchar(510)
SET @BuildScriptPath = [dbo].[funcGetConfigurationData]('ScriptPath')

IF RIGHT(@BuildScriptPath, 1) <> '\'
	SET @BuildScriptPath = @BuildScriptPath + '\'

SET @ScriptFilename = [dbo].[funcGetConfigurationData]('GenerateUserpermissionsinfo')
SET @ScriptInfo = @BuildScriptPath + @ScriptFilename

EXECUTE @ReturnValue =  CheckFileHash @ScriptInfo

set @BuildScriptPath = @ScriptInfo;

IF OBJECT_ID('TEMPDB..#Results') IS NOT NULL DROP TABLE #Results;
IF OBJECT_ID('TEMPDB..#DBList') IS NOT NULL DROP TABLE #DBList;
		SET @SuccessCount = 0
		SET @ErrorCount = 0

        --IF @Verbose = 1
            BEGIN
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - BEGIN INPUT VALUES' 
		      --  PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@DBMS_Id:                   ' + ISNULL(CAST(@DBMS_Id AS varchar(15)), '')
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@BuildScriptPath:           ' + @BuildScriptPath
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -	@ScriptFilename:            ' + @ScriptFilename
		        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - END INPUT VALUES' 
		        PRINT CONVERT(varchar(30), GETDATE(), 109)
            END
            
		CREATE TABLE #Results
		(
			Info		varchar(4000)
		)
			Create table #DBList(DBName varchar(510) )
		DECLARE CURSOR_SERVER CURSOR FAST_FORWARD
		FOR
            SELECT      name,ipaddress
            FROM       [DBA_DataCollector].[dbo].[DBMS]

		OPEN CURSOR_SERVER
			
		FETCH NEXT FROM CURSOR_SERVER
		INTO  @SQLServer, @SQLConnection

		IF @@FETCH_STATUS <> 0 
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO SERVERS TO PROCCESS, PLEASE VERIFY DATA IN SERVER TABLE AND COLLECT INFO FLAG IS SET TO 1'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN			
      
					TRUNCATE TABLE #Results

               
					    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - WORKING ON SERVER ' + QUOTENAME(@SQLServer) + ' (' + CAST(@DBMSId AS varchar(15)) + ')'
					
					SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON IF IS_SRVROLEMEMBER(''sysadmin'') = 0 RAISERROR(''Not sysadmin'', 11, 1)" -l 30 -t 15 '
			
					EXECUTE @ReturnValue = xp_cmdshell @Command, NO_OUTPUT					
					
					IF @ReturnValue = 1
						BEGIN
							SET @ErrorCount = @ErrorCount + 1
							
							
							    BEGIN
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -     *** ERROR - SQL SERVICE ACCOUNT DOES NOT HAVE SYSADMIN ACCESS OR UNABLE TO CONNECT TO SQL SERVER'
							        PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -'
							    END
						END
					ELSE
						BEGIN

					
						TRUNCATE TABLE #DBList

							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d master -q ' + ' "SET NOCOUNT ON; select name from sysdatabases  where dbid <> 2"'
						
							INSERT INTO #DBList
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command		   
							delete  from #DBList

							where dbname like '--%'
							or dbname like 'name'
							or dbname is null

				DECLARE CURSOR_DBName CURSOR FAST_FORWARD
					FOR
					SELECT      DBname 
					FROM       #DBList

		OPEN CURSOR_DBName
			
		FETCH NEXT FROM CURSOR_DBName
		INTO  @DBName

		IF @@FETCH_STATUS <> 0 
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' - *** THERE ARE NO DATABASES TO PROCCESS, PLEASE VERIFY WHETHER SERVER HAVE ANY DATABASES'
		ELSE
			BEGIN
				WHILE @@FETCH_STATUS = 0
				BEGIN	
				
				SET @OutputFile = @BuildPath + '\' + ltrim(rtrim(@SQLServer)) +'_SQLpermissions_'+ rtrim(ltrim(@DBName))+'_'+ REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') +  '.out'
		
							SET @Command = 'sqlcmd -S ' + @SQLConnection + ' -d '+ @DBName + '-E -b -i "' + 
									   @BuildScriptPath  + '" -h -1 -w 1024 -l 30 -t 300 > "' + @OutputFile + '"'

                          --  IF @Verbose = 1
							    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')
							INSERT INTO #Results
							EXECUTE @ReturnValue = master.dbo.xp_cmdshell @Command

							IF @ReturnValue <> 0 
								BEGIN
									SET @ErrorCount = @ErrorCount + 1

                                   -- IF @Verbose = 1
									    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
								END
							--ELSE
							--	BEGIN
							--		SET @Command = 'BULK INSERT #Results ' +
							--					   'FROM ''' + @OutputFile + ''' ' + 
							--					   'WITH ' +
							--					   '( ' +
							--							'BATCHSIZE  = 5000 ' +
							--					   ') '

       --                            -- IF @Verbose = 1
							--		    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    EXECUTE COMMAND:  ' + ISNULL(@Command, 'NULL')

							--		EXECUTE @ReturnValue = master.dbo.sp_executesql @Command
									
							--		IF @ReturnValue <> 0 OR EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout expired%')
							--			BEGIN
							--				SET @ErrorCount = @ErrorCount + 1

       --                                 --    IF @Verbose = 1
							--				    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -            *** ERROR ***'
							--			END
							--		ELSE
							--			BEGIN 
							--				SET @SuccessCount = @SuccessCount + 1
											
							--			--	IF @Verbose = 1
							--				    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    SUCCESSFUL'

							--				DELETE 
							--				FROM		#Results 
							--				WHERE		LTRIM(ISNULL(Info, '')) = '' 
							--				  OR		Info LIKE 'Warning%'																		
							--				  OR		Info LIKE '%Class not registered%'																		
											


       --                                     SET @Count = @@ROWCOUNT

       --                                    -- IF @Verbose = 1
							--				    PRINT CONVERT(varchar(30), GETDATE(), 109) + ' -    ' + CAST(@Count AS varchar(25)) + ' RECORDS WERE INSERTED'
										--END
						--		END
						
					FETCH NEXT FROM 	CURSOR_DBName
					INTO @dbname
					END
			end
				CLOSE CURSOR_DBName
		DEALLOCATE CURSOR_DBName
			end
                   -- IF @Verbose = 1
					    PRINT CONVERT(varchar(30), GETDATE(), 109) 

		            --SET @Command = 'DEL ' + @OutputFile				
		            --EXECUTE xp_cmdshell @Command, NO_OUTPUT

					FETCH NEXT FROM CURSOR_SERVER
					INTO @SQLServer,@SQLConnection
				END
			END
			
		CLOSE CURSOR_SERVER
		DEALLOCATE CURSOR_SERVER

IF OBJECT_ID('TEMPDB..#Results') IS NOT NULL DROP TABLE #Results;
IF OBJECT_ID('TEMPDB..#DBList') IS NOT NULL DROP TABLE #DBList;
		SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
		SET @Length = LEN(CAST(@Total AS varchar(15)))

        --IF @Verbose = 1 
            BEGIN
		        PRINT ''
		        PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
		        PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
		        PRINT '              ' + REPLICATE('-', @Length + 5)
		        PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))
		    END




GO
/****** Object:  StoredProcedure [dbo].[Monitor_DBMSSQLAgentRunning]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Monitor_DBMSSQLAgentRunning]
(
    @DBMS_Id    int = NULL
)
AS

SET NOCOUNT ON

DECLARE  @Id                int  
        ,@SQLServer         varchar(128)
        ,@Instance          varchar(128)
        ,@SQLConnection     varchar(256)
        ,@LastFailure       datetime
        ,@ThresholdDate     datetime
        ,@RaiseAlert        tinyint
        ,@AlertThreshold    smallint
        ,@ThresholdCount    tinyint
        ,@Delay             smallint
        ,@ReturnCode        int
        ,@Cmd               varchar(1024)
        ,@MonitorId         int
        ,@EmailTo           varchar(1024)
        ,@EmailCC           varchar(1024)
        ,@EmailBCC          varchar(1024)
        ,@Msg               varchar(1024)
        ,@Status            varchar(50) -- Information, Warning, Alert, Threshold Alert
        ,@EmailBody         varchar(1024)
        ,@EmailSubject      varchar(1024)
        ,@RunDate           datetime
        ,@SendEmail         bit
        ,@Service           varchar(128)
        ,@JobCount          int
        
SET @MonitorId = 4 -- SQL Agent Running

SET @EmailTo = dbo.funcGetConfigurationData('EmailMonitorAlertsTo')
SET @EmailCC = ISNULL(RTRIM(dbo.funcGetConfigurationData('EmailMonitorAlertsCC')), '')
SET @EmailBCC = ISNULL(RTRIM(dbo.funcGetConfigurationData('EmailMonitorAlertsBCC')), '')

DECLARE CURSOR_PING CURSOR FAST_FORWARD
FOR            
    SELECT      B.Id
                ,A.SQLServer
				,A.Instance
			    ,A.DataCollectorConnectString
                ,B.LastFailure
                ,B.ThresholdDate
                ,B.RaiseAlert     
                ,B.ThresholdCount
                ,C.AlertThreshold  
                ,C.AlertThresholdDelay   
    FROM        dbo.SQLAbleToCollectInfoOn A
                    JOIN dbo.MonitorDBMSLog B ON A.Id = B.DBMS_Id
                    JOIN dbo.Monitor C ON B.Monitor_Id = C.Id
    WHERE       B.Monitor_Id = @MonitorId
      AND       B.Disable = 0
      AND       (
                        A.Id = @DBMS_Id
                            OR @DBMS_Id IS NULL
                )
      AND       (
                    -- GRAB SERVES THAT HAVEN'T BEEN MONITORED
                    (B.LastSuccess IS NULL AND B.LastFailure IS NULL)
                        -- CHECK WHICH DATE TO USE TO DETERMINE IF SERVER NEEDS TO BE MONITORED                        
                        OR DATEDIFF(
                                        mi
                                        ,ISNULL(
                                                    CASE 
                                                        WHEN B.LastSuccess > B.LastFailure OR B.LastFailure IS NULL  
                                                        THEN B.LastSuccess 
                                                        ELSE B.LastFailure 
                                                    END
                                                    , GETDATE()
                                                )
                                        ,GETDATE()
                                    ) >= C.Duration 
                )
      AND       (
                    B.IgnoreAlertUntil IS NULL OR GETDATE() >= B.IgnoreAlertUntil
                )
    ORDER BY    B.LastFailure DESC

OPEN CURSOR_PING

FETCH NEXT FROM CURSOR_PING
INTO @Id, @SQLServer, @Instance, @SQLConnection, @LastFailure, @ThresholdDate, @RaiseAlert, @ThresholdCount, @AlertThreshold, @Delay

CREATE TABLE #Results
(
    Info varchar(2048)
)

WHILE @@FETCH_STATUS = 0
BEGIN
    -- CHECK SQL CONNECTION
	SET @Cmd = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON;SELECT ''TESTING CONNECTION....''" -l 30 -t 30 -b'

	EXECUTE @ReturnCode = xp_cmdshell @Cmd, NO_OUTPUT					

    IF @ReturnCode <> 0 
        BEGIN
            -- No need to setup an alert because SQL Connection monitoring should be doing this
            SET @Status = 'Error'
            SET @Msg  = 'Unable to check if SQL Agent is running, the connection to SQL Server ' + @SQLServer + ' (' + @SQLConnection + ') was unsuccessful.'    
        END
    ELSE
        BEGIN 
            TRUNCATE TABLE #Results

            IF RTRIM(LTRIM(@Instance)) = ''  OR UPPER(RTRIM(LTRIM(@Instance))) = 'DEFAULT'
                SET @Service = 'SQLSERVERAGENT'
            ELSE
                SET @Service = 'SQLAgent$' + RTRIM(LTRIM(@Instance))
                
            SET @Cmd = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON;EXECUTE xp_servicecontrol ''querystate'', ''' + @Service + '''" -l 30 -t 30 -b -h -1'

            INSERT INTO #Results
            EXECUTE @ReturnCode = xp_cmdshell @Cmd
            
            SET @RunDate = GETDATE()            
            
            IF @ReturnCode <> 0
                BEGIN                
                    SET @Status = 'Error'
                    SET @Msg  = 'Unable to check if SQL Agent is running, there was an error querying the service ' + @Service + ' for SQL Server ' + @SQLServer + ' (' + @SQLConnection + ').'    

                    SET @EmailBody = @Msg
                    SET @EmailSubject = 'SQL Monitor - SQL Server Agent - ' + @SQLServer + ' (' + @SQLConnection + ')';

                    -- EXECUTE msdb.dbo.sp_send_dbmail @recipients = @EmailTo, @copy_recipients = @EmailCC, @blind_copy_recipients = EmailBCC, @body = @EmailBody, @subject = @EmailSubject, @importance = 'High'
                END            
            ELSE
                BEGIN
                    SET @JobCount = NULL

                    SET @Cmd = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON;SELECT ''Job Count:  '' + CAST(COUNT(*) AS varchar(20)) FROM msdb.dbo.sysjobs WHERE enabled = 1" -l 30 -t 30 -b -h -1'

                    INSERT INTO #Results
                    EXECUTE @ReturnCode = xp_cmdshell @Cmd
            
                    SELECT      @JobCount = REPLACE(Info, 'Job Count:  ', '')
                    FROM        #Results
                    WHERE       Info LIKE 'Job Count:  %'
                    
                    SET @JobCount = ISNULL(@JobCount, 0)
            
                    IF EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Running.%')
                        BEGIN 
                            -- PING WAS SUCCESSFUL
                            UPDATE      dbo.MonitorDBMSLog
                               SET      LastSuccess = @RunDate
                                        ,RaiseAlert = 0
                                        ,ThresholdDate = NULL
                                        ,ThresholdCount = 0
                            WHERE       Id = @Id
                    
                            SET @Status = 'Information'
                            SET @Msg  = 'SQL Agent service ' + @Service + ' is running on SQL Server ' + @SQLServer + ' (' + @SQLConnection + ').'
                        END
                    ELSE
                        IF EXISTS(SELECT * FROM #Results WHERE Info LIKE 'Timeout%')
                            BEGIN
                                -- Don't want to email if timeout occurred.  May need to look into this further on why this occurring.
                                SET @Status = 'Error'
                                SET @Msg  = 'Unable to check if SQL Agent is running for SQL Server ' + @SQLServer + ' (' + @SQLConnection + ').  The query timed out'                                
                            END
                        ELSE
                            BEGIN
                                IF (@JobCount = 0)
                                    BEGIN
                                        SET @Status = 'Warning'                   
                                        SET @Msg = 'SQL Agent service ' + @Service + ' is not running on SQL Server ' + @SQLServer + ' (' + @SQLConnection + ').  But, there are no jobs setup.'                    
                                    END
                                ELSE
                                    BEGIN                                    
                                        IF @RaiseAlert = 0            
                                            BEGIN 
                                                -- IF THIS IS THE FIRST FAILURE, SET THE RAISE ALERT FLAG TO 1
                                                -- AN EMAIL ALERT DOESN'T OCCUR, IT WILL HAPPEN THE NEXT TIME AROUND
                                                -- IF IT FAILS
                                                UPDATE      dbo.MonitorDBMSLog
                                                   SET      LastFailure = @RunDate
                                                            ,RaiseAlert = 1 -- RAISE ALERT ON NEXT FAILURE
                                                            ,ThresholdDate = @RunDate
                                                WHERE       Id = @Id

                                                SET @Status = 'Warning'                   
                                                SET @Msg = 'SQL Agent service ' + @Service + ' is not running on SQL Server ' + @SQLServer + ' (' + @SQLConnection + ').  Alert will be raised on next faiilure.  It has ' + CAST(@JobCount AS varchar(20)) + ' SQL Sever Jobs.'
                                            END
                                         ELSE
                                            BEGIN 
                                                IF @RaiseAlert = 1
                                                    BEGIN
                                                        -- EMAIL ALERT OUT SINCE THIS IS THE SECOND FAILURE IN A ROW                            
                                                        SET @Status = 'Alert'
                                                        SET @Msg = 'SQL Agent service ' + @Service + ' is not running on SQL Server ' + @SQLServer + ' (' + @SQLConnection + ').  Alert has been raised.'                    

                                                        SET @EmailBody = 'SQL Agent service ' + @Service + ' is not running on SQL Server ' + @SQLServer + ' (' + @SQLConnection + ').  Please make sure the SQL Agent is running for this instance.  It has ' + CAST(@JobCount AS varchar(20)) + ' SQL Sever Jobs.'                    
                                                        SET @EmailSubject = 'SQL Monitor - SQL Server Agent - ' + @SQLServer + ' (' + @SQLConnection + ')';

                                                        EXECUTE msdb.dbo.sp_send_dbmail @recipients = @EmailTo, @copy_recipients = @EmailCC, @blind_copy_recipients = EmailBCC, @body = @EmailBody, @subject = @EmailSubject, @importance = 'High'

                                                        -- NEED TO RESET LAST FAILURE TO RESET THRESHOLD CHECK
                                                        UPDATE      dbo.MonitorDBMSLog
                                                           SET      LastFailure = @RunDate
                                                                    ,RaiseAlert = 2 -- ALERT ALREADY BEEN MADE, ONLY ALERT ON NEXT THRESHOLD
                                                                    ,ThresholdDate = @RunDate
                                                        WHERE       Id = @Id                                
                                                    END
                                                 ELSE
                                                    BEGIN 
                                                        -- SINCE ALERT BEEN SENT OUT, INSETAD OF SENDING ALERT MULTIPLE TIMES
                                                        -- CHECK IF IT MEETS THE THRESHOLD TO SEND ALERT AGAIN.  FOR EXAMPLE
                                                        -- FIRST ALERT OCCURS BECAUSE IT FAILED THE CHECK THAT RUNS EVERY 5 MINUTES
                                                        -- INSTEAD OF EMAILING EVERY 5 MINUTES, EMAIL BASED ON THE ALERT THRESHOLD WHICH
                                                        -- COULD BE 15 MINUTES, SO IT WILL EMAIL YOU EVERY 15 MINUTES IF IT STILL FAILING
                                                        IF DATEDIFF(MI, @ThresholdDate, GETDATE()) >= @AlertThreshold
                                                            BEGIN
                                                                SET @SendEmail = 0 
                                                                
                                                                IF (@ThresholdCount + 1) <= 4 -- AFTER 4 EMAILS, DO DELAY
                                                                    BEGIN 
                                                                        SET @Status = 'Alert'                            
                                                                        SET @Msg = 'SQL Agent service ' + @Service + ' is not running on SQL Server ' + @SQLServer + ' (' + @SQLConnection + ').  Alert has been raised.  Threshold has been met.  It has ' + CAST(@JobCount AS varchar(20)) + ' SQL Sever Jobs.'
                                                                        
                                                                        UPDATE      dbo.MonitorDBMSLog
                                                                           SET      LastFailure = @RunDate
                                                                                    ,ThresholdDate = @RunDate
                                                                                    ,ThresholdCount = @ThresholdCount + 1
                                                                        WHERE       Id = @Id

                                                                        SET @SendEmail = 1
                                                                    END
                                                                ELSE
                                                                    BEGIN
                                                                        -- CHECKS IF DELAY IS OVER, IF SO EMAIL
                                                                        IF DATEDIFF(mi, @ThresholdDate, GETDATE()) >= @Delay    
                                                                            BEGIN
                                                                                SET @Status = 'Alert'                            
                                                                                SET @Msg = 'SQL Agent service ' + @Service + ' is not running on SQL Server ' + @SQLServer + ' (' + @SQLConnection + ').  Alert has been raised.  Threshold delay has been met.  It has ' + CAST(@JobCount AS varchar(20)) + ' SQL Sever Jobs.'
                                                                            
                                                                                UPDATE      dbo.MonitorDBMSLog
                                                                                   SET      LastFailure = @RunDate
                                                                                            ,ThresholdDate = @RunDate
                                                                                            ,ThresholdCount = 0
                                                                                WHERE       Id = @Id

                                                                                SET @SendEmail = 1                                            
                                                                            END
                                                                        ELSE
                                                                            BEGIN 
                                                                                SET @Status = 'Warning'                            
                                                                                SET @Msg = 'SQL Agent service ' + @Service + ' is not running on SQL Server ' + @SQLServer + ' (' + @SQLConnection + ').  Alert has been delayed.  It has ' + CAST(@JobCount AS varchar(20)) + ' SQL Sever Jobs.'
                                                                                
                                                                                UPDATE      dbo.MonitorDBMSLog
                                                                                   SET      LastFailure = @RunDate
                                                                                WHERE       Id = @Id
                                                                            END
                                                                    END
                                                                    
                                                                IF @SendEmail = 1
                                                                    BEGIN                                                
                                                                        SET @EmailBody = 'SQL Agent service ' + @Service + ' is not running on SQL Server ' + @SQLServer + ' (' + @SQLConnection + ').  Please make sure the SQL Agent is running for this instance.  It has ' + CAST(@JobCount AS varchar(20)) + ' SQL Sever Jobs.'                    
                                                                        SET @EmailSubject = 'SQL Monitor - SQL Server Agent - ' + @SQLServer + ' (' + @SQLConnection + ') - Alert';

                                                                        EXECUTE msdb.dbo.sp_send_dbmail @recipients = @EmailTo, @copy_recipients = @EmailCC, @blind_copy_recipients = EmailBCC, @body = @EmailBody, @subject = @EmailSubject, @importance = 'High'
                                                                    END
                                                            END
                                                        ELSE
                                                            BEGIN 
                                                                UPDATE      dbo.MonitorDBMSLog
                                                                   SET      LastFailure = @RunDate                                                
                                                                WHERE       Id = @Id

                                                                SET @Status = 'Warning'                            
                                                                SET @Msg = 'SQL Agent service ' + @Service + ' is not running on SQL Server ' + @SQLServer + ' (' + @SQLConnection + ').  Alert has already been raised.  Waiting to alert again on next Threshold.  It has ' + CAST(@JobCount AS varchar(20)) + ' SQL Sever Jobs.'                    
                                                            END 
                                                    END                                               
                                            END   
                                    END  
                            END                                        
                END
        END
        
    -- INSERT DETAIL INFORMATION THAT ARE NOT INFORMATIONAL
    IF @Status <> 'Information'
        INSERT INTO dbo.MonitorDBMSLogDetail
        (
                MonitorDBMSLog_Id
                ,Status
                ,Description
        )
        VALUES
        (
                @Id
                ,@Status
                ,@Msg
        )

    FETCH NEXT FROM CURSOR_PING
    INTO @Id, @SQLServer, @Instance, @SQLConnection, @LastFailure, @ThresholdDate, @RaiseAlert, @ThresholdCount, @AlertThreshold, @Delay
END

CLOSE CURSOR_PING
DEALLOCATE CURSOR_PING





GO
/****** Object:  StoredProcedure [dbo].[Monitor_DBMSSQLConnection]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Monitor_DBMSSQLConnection]
(
    @DBMS_Id    int = NULL
)
AS

SET NOCOUNT ON

DECLARE  @Id                int  
        ,@SQLServer         varchar(128)
        ,@SQLConnection     varchar(256)
        ,@LastFailure       datetime
        ,@ThresholdDate     datetime
        ,@RaiseAlert        tinyint
        ,@AlertThreshold    smallint
        ,@ThresholdCount    tinyint
        ,@Delay             smallint
        ,@ReturnCode        int
        ,@Cmd               varchar(1024)
        ,@MonitorId         int
        ,@EmailTo           varchar(1024)
        ,@EmailCC           varchar(1024)
        ,@EmailBCC          varchar(1024)
        ,@Msg               varchar(1024)
        ,@Status            varchar(50) -- Information, Warning, Alert, Threshold Alert
        ,@EmailBody         varchar(1024)
        ,@EmailSubject      varchar(1024)
        ,@RunDate           datetime
        ,@SendEmail         bit
        
SET @MonitorId = 3 -- SQL Connection

SET @EmailTo = dbo.funcGetConfigurationData('EmailMonitorAlertsTo')
SET @EmailCC = ISNULL(RTRIM(dbo.funcGetConfigurationData('EmailMonitorAlertsCC')), '')
SET @EmailBCC = ISNULL(RTRIM(dbo.funcGetConfigurationData('EmailMonitorAlertsBCC')), '')

DECLARE CURSOR_PING CURSOR FAST_FORWARD
FOR
    SELECT      B.Id
                ,A.SQLServer
			    ,A.DataCollectorConnectString
                ,B.LastFailure
                ,B.ThresholdDate
                ,B.RaiseAlert     
                ,B.ThresholdCount
                ,C.AlertThreshold  
                ,C.AlertThresholdDelay   
    FROM        dbo.SQLAbleToCollectInfoOn A
                    JOIN dbo.MonitorDBMSLog B ON A.Id = B.DBMS_Id
                    JOIN dbo.Monitor C ON B.Monitor_Id = C.Id
    WHERE       B.Monitor_Id = @MonitorId
      AND       B.Disable = 0
      AND       (
                        A.Id = @DBMS_Id
                            OR @DBMS_Id IS NULL
                )
      AND       (
                    -- GRAB SERVES THAT HAVEN'T BEEN MONITORED
                    (B.LastSuccess IS NULL AND B.LastFailure IS NULL)
                        -- CHECK WHICH DATE TO USE TO DETERMINE IF SERVER NEEDS TO BE MONITORED                        
                        OR DATEDIFF(
                                        mi
                                        ,ISNULL(
                                                    CASE 
                                                        WHEN B.LastSuccess > B.LastFailure OR B.LastFailure IS NULL  
                                                        THEN B.LastSuccess 
                                                        ELSE B.LastFailure 
                                                    END
                                                    , GETDATE()
                                                )
                                        ,GETDATE()
                                    ) >= C.Duration 
                )
      AND       (
                    B.IgnoreAlertUntil IS NULL OR GETDATE() >= B.IgnoreAlertUntil
                )
    ORDER BY    B.LastFailure DESC

OPEN CURSOR_PING

FETCH NEXT FROM CURSOR_PING
INTO @Id, @SQLServer, @SQLConnection, @LastFailure, @ThresholdDate, @RaiseAlert, @ThresholdCount, @AlertThreshold, @Delay

WHILE @@FETCH_STATUS = 0
BEGIN
    -- CHECK SQL CONNECTION
	SET @Cmd = 'sqlcmd -S ' + @SQLConnection + ' -d "master" -E -b -Q "SET NOCOUNT ON;SELECT ''TESTING CONNECTION....''" -l 30 -t 30 -b'

	EXECUTE @ReturnCode = xp_cmdshell @Cmd, NO_OUTPUT					

    SET @RunDate = GETDATE()
    
    IF @ReturnCode = 0
        BEGIN
            -- PING WAS SUCCESSFUL
            UPDATE      dbo.MonitorDBMSLog
               SET      LastSuccess = @RunDate
                        ,RaiseAlert = 0
                        ,ThresholdDate = NULL
                        ,ThresholdCount = 0
            WHERE       Id = @Id
    
            SET @Status = 'Information'
            SET @Msg  = 'Connection to SQL Server ' + @SQLServer + ' (' + @SQLConnection + ') was successful.'
        END
    ELSE
        BEGIN
            IF @RaiseAlert = 0            
                BEGIN 
                    -- IF THIS IS THE FIRST FAILURE, SET THE RAISE ALERT FLAG TO 1
                    -- AN EMAIL ALERT DOESN'T OCCUR, IT WILL HAPPEN THE NEXT TIME AROUND
                    -- IF IT FAILS
                    UPDATE      dbo.MonitorDBMSLog
                       SET      LastFailure = @RunDate
                                ,RaiseAlert = 1 -- RAISE ALERT ON NEXT FAILURE
                                ,ThresholdDate = @RunDate
                    WHERE       Id = @Id

                    SET @Status = 'Warning'                   
                    SET @Msg = 'Failed to connect to SQL Server ' + @SQLServer + ' (' + @SQLConnection + '), Alert will be raised on next failure'                    
                END
             ELSE
                BEGIN 
                    IF @RaiseAlert = 1
                        BEGIN
                            -- EMAIL ALERT OUT SINCE THIS IS THE SECOND FAILURE IN A ROW                            
                            SET @Status = 'Alert'
                            SET @Msg = 'Failed to connect to SQL Server ' + @SQLServer + ' (' + @SQLConnection + '), Alert has been raised'                    

                            SET @EmailBody = 'Failed to connect to SQL Server ' + @SQLServer + ' (' + @SQLConnection + '), please verify Server is up and running!'
                            SET @EmailSubject = 'SQL Monitor - SQL Server Connection - ' + @SQLServer + ' (' + @SQLConnection + ')';

                            EXECUTE msdb.dbo.sp_send_dbmail @recipients = @EmailTo, @copy_recipients = @EmailCC, @blind_copy_recipients = EmailBCC, @body = @EmailBody, @subject = @EmailSubject, @importance = 'High'

                            -- NEED TO RESET LAST FAILURE TO RESET THRESHOLD CHECK
                            UPDATE      dbo.MonitorDBMSLog
                               SET      LastFailure = @RunDate
                                        ,RaiseAlert = 2 -- ALERT ALREADY BEEN MADE, ONLY ALERT ON NEXT THRESHOLD
                                        ,ThresholdDate = @RunDate
                            WHERE       Id = @Id                                
                        END
                     ELSE
                        BEGIN 
                            -- SINCE ALERT BEEN SENT OUT, INSETAD OF SENDING ALERT MULTIPLE TIMES
                            -- CHECK IF IT MEETS THE THRESHOLD TO SEND ALERT AGAIN.  FOR EXAMPLE
                            -- FIRST ALERT OCCURS BECAUSE IT FAILED THE CHECK THAT RUNS EVERY 5 MINUTES
                            -- INSTEAD OF EMAILING EVERY 5 MINUTES, EMAIL BASED ON THE ALERT THRESHOLD WHICH
                            -- COULD BE 15 MINUTES, SO IT WILL EMAIL YOU EVERY 15 MINUTES IF IT STILL FAILING
                            IF DATEDIFF(MI, @ThresholdDate, GETDATE()) >= @AlertThreshold
                                BEGIN
                                    SET @SendEmail = 0 
                                    
                                    IF (@ThresholdCount + 1) <= 4 -- AFTER 4 EMAILS, DO DELAY
                                        BEGIN 
                                            SET @Status = 'Alert'                            
                                            SET @Msg = 'Failed to connect to SQL Server ' + @SQLServer + ' (' + @SQLConnection + '), Alert has been raised.  Threshold has been met.'                    
                                            
                                            UPDATE      dbo.MonitorDBMSLog
                                               SET      LastFailure = @RunDate
                                                        ,ThresholdDate = @RunDate
                                                        ,ThresholdCount = @ThresholdCount + 1
                                            WHERE       Id = @Id

                                            SET @SendEmail = 1
                                        END
                                    ELSE
                                        BEGIN
                                            -- CHECKS IF DELAY IS OVER, IF SO EMAIL
                                            IF DATEDIFF(mi, @ThresholdDate, GETDATE()) >= @Delay    
                                                BEGIN
                                                    SET @Status = 'Alert'                            
                                                    SET @Msg = 'Failed to connect to SQL Server ' + @SQLServer + ' (' + @SQLConnection + '), Alert has been raised.  Threshold delay has been met.'                    
                                                
                                                    UPDATE      dbo.MonitorDBMSLog
                                                       SET      LastFailure = @RunDate
                                                                ,ThresholdDate = @RunDate
                                                                ,ThresholdCount = 0
                                                    WHERE       Id = @Id

                                                    SET @SendEmail = 1                                            
                                                END
                                            ELSE
                                                BEGIN 
                                                    SET @Status = 'Warning'                            
                                                    SET @Msg = 'Failed to connect to SQL Server ' + @SQLServer + ' (' + @SQLConnection + '), Alert has been delayed.'                    
                                                    
                                                    UPDATE      dbo.MonitorDBMSLog
                                                       SET      LastFailure = @RunDate
                                                    WHERE       Id = @Id
                                                END
                                        END
                                        
                                    IF @SendEmail = 1
                                        BEGIN                                                
                                            SET @EmailBody = 'Failed to connect to SQL Server ' + @SQLServer + ' (' + @SQLConnection + '), please verify Server is up and running!'
                                            SET @EmailSubject = 'SQL Monitor - SQL Server Connection - ' + @SQLServer + ' (' + @SQLConnection + ') - Alert';

                                            EXECUTE msdb.dbo.sp_send_dbmail @recipients = @EmailTo, @copy_recipients = @EmailCC, @blind_copy_recipients = EmailBCC, @body = @EmailBody, @subject = @EmailSubject, @importance = 'High'
                                        END
                                END
                            ELSE
                                BEGIN 
                                    UPDATE      dbo.MonitorDBMSLog
                                       SET      LastFailure = @RunDate                                                
                                    WHERE       Id = @Id

                                    SET @Status = 'Warning'                            
                                    SET @Msg = 'Failed to connect to SQL Server ' + @SQLServer + ' (' + @SQLConnection + '), Alert has already been raised.  Waiting to alert again on next Threshold'                    
                                END 
                        END                                               
                END             
        END

    -- INSERT DETAIL INFORMATION THAT ARE NOT INFORMATIONAL
    IF @Status <> 'Information'
        INSERT INTO dbo.MonitorDBMSLogDetail
        (
                MonitorDBMSLog_Id
                ,Status
                ,Description
        )
        VALUES
        (
                @Id
                ,@Status
                ,@Msg
        )

    FETCH NEXT FROM CURSOR_PING
    INTO @Id, @SQLServer, @SQLConnection, @LastFailure, @ThresholdDate, @RaiseAlert, @ThresholdCount, @AlertThreshold, @Delay
END

CLOSE CURSOR_PING
DEALLOCATE CURSOR_PING





GO
/****** Object:  StoredProcedure [dbo].[Monitor_ServerPing]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Monitor_ServerPing]
(
    @Server_Id      int = NULL
)
AS

SET NOCOUNT ON

DECLARE  @Id                int  
        ,@Server            varchar(128)
        ,@IP                varchar(25)
        ,@LastFailure       datetime
        ,@ThresholdDate     datetime
        ,@RaiseAlert        tinyint
        ,@AlertThreshold    smallint
        ,@ThresholdCount    tinyint
        ,@Delay             smallint
        ,@ReturnCode        int
        ,@Cmd               varchar(1024)
        ,@MonitorId         int
        ,@EmailTo           varchar(1024)
        ,@EmailCC           varchar(1024)
        ,@EmailBCC          varchar(1024)
        ,@Msg               varchar(1024)
        ,@Status            varchar(50) -- Information, Warning, Alert, Threshold Alert
        ,@EmailBody         varchar(1024)
        ,@EmailSubject      varchar(1024)
        ,@RunDate           datetime
        ,@SendEmail         bit
        
--SET @MonitorId = 1 -- Physical Ping

SET @EmailTo = dbo.funcGetConfigurationData('EmailMonitorAlertsTo')
SET @EmailCC = ISNULL(RTRIM(dbo.funcGetConfigurationData('EmailMonitorAlertsCC')), '')
SET @EmailBCC = ISNULL(RTRIM(dbo.funcGetConfigurationData('EmailMonitorAlertsBCC')), '')

DECLARE CURSOR_PING CURSOR FAST_FORWARD
FOR
    SELECT      B.Id
                ,UPPER(A.Name)
                ,A.IPAddress
                ,B.LastFailure
                ,B.ThresholdDate
                ,B.RaiseAlert     
                ,B.ThresholdCount
                ,C.AlertThreshold  
                ,C.AlertThresholdDelay                         
    FROM        dbo.Server A
                    JOIN dbo.MonitorServerLog B ON A.Id = B.Server_Id
                    JOIN dbo.Monitor C ON B.Monitor_Id = C.Id
    WHERE       A.CollectInfo = 1
      AND       A.Disable = 0
     -- AND       B.Monitor_Id = @MonitorId
      AND       B.Disable = 0
      AND       (
                    A.Id = @Server_Id
                        OR @Server_Id IS NULL
                )
      AND       (
                    -- GRAB SERVES THAT HAVEN'T BEEN MONITORED
                    (B.LastSuccess IS NULL AND B.LastFailure IS NULL)
                        -- CHECK WHICH DATE TO USE TO DETERMINE IF SERVER NEEDS TO BE MONITORED                        
                        OR DATEDIFF(
                                        mi
                                        ,ISNULL(
                                                    CASE 
                                                        WHEN B.LastSuccess > B.LastFailure OR B.LastFailure IS NULL  
                                                        THEN B.LastSuccess 
                                                        ELSE B.LastFailure 
                                                    END
                                                    , GETDATE()
                                                )
                                        ,GETDATE()
                                    ) >= C.Duration 
                )
      AND       (
                    B.IgnoreAlertUntil IS NULL OR GETDATE() >= B.IgnoreAlertUntil
                )
    ORDER BY    B.LastFailure DESC

OPEN CURSOR_PING

FETCH NEXT FROM CURSOR_PING
INTO @Id, @Server, @IP, @LastFailure, @ThresholdDate, @RaiseAlert, @ThresholdCount, @AlertThreshold, @Delay

WHILE @@FETCH_STATUS = 0
BEGIN
    -- PING BY IP ONLY TRY ONCE
    SET @Cmd = 'ping -n 2 ' + @IP + ' | find /I "Reply from "'

    EXECUTE @ReturnCode = xp_cmdshell @Cmd, NO_OUTPUT
    SET @RunDate = GETDATE()
    
    IF @ReturnCode = 0
        BEGIN
            -- PING WAS SUCCESSFUL
            UPDATE      dbo.MonitorServerLog
               SET      LastSuccess = @RunDate
                        ,RaiseAlert = 0
                        ,ThresholdDate = NULL
                        ,ThresholdCount = 0
            WHERE       Id = @Id
    
            SET @Status = 'Information'
            SET @Msg  = 'Server ' + @Server + ' (' + @IP + ') is pingable.'
        END
    ELSE
        BEGIN
            IF @RaiseAlert = 0            
                BEGIN 
                    -- IF THIS IS THE FIRST FAILURE, SET THE RAISE ALERT FLAG TO 1
                    -- AN EMAIL ALERT DOESN'T OCCUR, IT WILL HAPPEN THE NEXT TIME AROUND
                    -- IF IT FAILS
                    UPDATE      dbo.MonitorServerLog
                       SET      LastFailure = @RunDate
                                ,RaiseAlert = 1 -- RAISE ALERT ON NEXT FAILURE
                                ,ThresholdDate = @RunDate
                    WHERE       Id = @Id

                    SET @Status = 'Warning'                   
                    SET @Msg = 'Failed to ping ' + @Server + ' (' + @IP + '), Alert will be raised on next failure'                    
                END
             ELSE
                BEGIN 
                    IF @RaiseAlert = 1
                        BEGIN
                            -- EMAIL ALERT OUT SINCE THIS IS THE SECOND FAILURE IN A ROW                            
                            SET @Status = 'Alert'
                            SET @Msg = 'Failed to ping ' + @Server + ' (' + @IP + '), Alert has been raised'                    

                            SET @EmailBody = 'Failed to ping ' + @Server + ' (' + @IP + '), please verify Server is up and running!'
                            SET @EmailSubject = 'SQL Monitor - Ping Failure - ' + @Server + ' (' + @IP + ')';

                            EXECUTE msdb.dbo.sp_send_dbmail @recipients = @EmailTo, @copy_recipients = @EmailCC, @blind_copy_recipients = EmailBCC, @body = @EmailBody, @subject = @EmailSubject, @importance = 'High'

                            -- NEED TO RESET LAST FAILURE TO RESET THRESHOLD CHECK
                            UPDATE      dbo.MonitorServerLog
                               SET      LastFailure = @RunDate
                                        ,RaiseAlert = 2 -- ALERT ALREADY BEEN MADE, ONLY ALERT ON NEXT THRESHOLD
                                        ,ThresholdDate = @RunDate
                            WHERE       Id = @Id                                
                        END
                     ELSE
                        BEGIN 
                            -- SINCE ALERT BEEN SENT OUT, INSETAD OF SENDING ALERT MULTIPLE TIMES
                            -- CHECK IF IT MEETS THE THRESHOLD TO SEND ALERT AGAIN.  FOR EXAMPLE
                            -- FIRST ALERT OCCURS BECAUSE IT FAILED THE CHECK THAT RUNS EVERY 5 MINUTES
                            -- INSTEAD OF EMAILING EVERY 5 MINUTES, EMAIL BASED ON THE ALERT THRESHOLD WHICH
                            -- COULD BE 15 MINUTES, SO IT WILL EMAIL YOU EVERY 15 MINUTES IF IT STILL FAILING
                            IF DATEDIFF(MI, @ThresholdDate, GETDATE()) >= @AlertThreshold
                                BEGIN
                                    SET @SendEmail = 0 
                                    
                                    IF (@ThresholdCount + 1) <= 4 -- AFTER 4 EMAILS, DO DELAY
                                        BEGIN 
                                            SET @Status = 'Alert'                            
                                            SET @Msg = 'Failed to ping ' + @Server + ' (' + @IP + '), Alert has been raised.  Threshold has been met.'                    
                                            
                                            UPDATE      dbo.MonitorServerLog
                                               SET      LastFailure = @RunDate
                                                        ,ThresholdDate = @RunDate
                                                        ,ThresholdCount = @ThresholdCount + 1
                                            WHERE       Id = @Id

                                            SET @SendEmail = 1
                                        END
                                    ELSE
                                        BEGIN
                                            -- CHECKS IF DELAY IS OVER, IF SO EMAIL
                                            IF DATEDIFF(mi, @ThresholdDate, GETDATE()) >= @Delay    
                                                BEGIN
                                                    SET @Status = 'Alert'                            
                                                    SET @Msg = 'Failed to ping ' + @Server + ' (' + @IP + '), Alert has been raised.  Threshold delay has been met.'                    
                                                
                                                    UPDATE      dbo.MonitorServerLog
                                                       SET      LastFailure = @RunDate
                                                                ,ThresholdDate = @RunDate
                                                                ,ThresholdCount = 0
                                                    WHERE       Id = @Id

                                                    SET @SendEmail = 1                                            
                                                END
                                            ELSE
                                                BEGIN 
                                                    SET @Status = 'Warning'                            
                                                    SET @Msg = 'Failed to ping ' + @Server + ' (' + @IP + '), Alert has been delayed.'                    
                                                    
                                                    UPDATE      dbo.MonitorServerLog
                                                       SET      LastFailure = @RunDate
                                                    WHERE       Id = @Id
                                                END
                                        END
                                        
                                    IF @SendEmail = 1
                                        BEGIN                                                
                                            SET @EmailBody = 'Failed to ping ' + @Server + ' (' + @IP + '), please verify Server is up and running!'
                                            SET @EmailSubject = 'SQL Monitor - Ping Failure - ' + @Server + ' (' + @IP + ')';

                                            EXECUTE msdb.dbo.sp_send_dbmail @recipients = @EmailTo, @copy_recipients = @EmailCC, @blind_copy_recipients = EmailBCC, @body = @EmailBody, @subject = @EmailSubject, @importance = 'High'
                                        END
                                END
                            ELSE
                                BEGIN 
                                    UPDATE      dbo.MonitorServerLog
                                       SET      LastFailure = @RunDate                                                
                                    WHERE       Id = @Id

                                    SET @Status = 'Warning'                            
                                    SET @Msg = 'Failed to ping ' + @Server + ' (' + @IP + '), Alert has already been raised.  Waiting to alert again on next Threshold'                    
                                END 
                        END                                               
                END             
        END

    -- INSERT DETAIL INFORMATION THAT ARE NOT INFORMATIONAL
    IF @Status <> 'Information'
        INSERT INTO dbo.MonitorServerLogDetail
        (
                MonitorServerLog_Id
                ,Status
                ,Description
        )
        VALUES
        (
                @Id
                ,@Status
                ,@Msg
        )

    FETCH NEXT FROM CURSOR_PING
    INTO @Id, @Server, @IP, @LastFailure, @ThresholdDate, @RaiseAlert, @ThresholdCount, @AlertThreshold, @Delay
END

CLOSE CURSOR_PING
DEALLOCATE CURSOR_PING





GO
/****** Object:  StoredProcedure [dbo].[p_admin_Generate_DR_Report_Wrapper]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[p_admin_Generate_DR_Report_Wrapper]
as


SET NOCOUNT ON;
declare @chkdirectory as nvarchar(4000)
declare @folder_exists as int
declare @BuildScriptPath varchar(510)
declare @OutputFile varchar(510)
set @BuildScriptPath = 'C:\DR\SQL'
SET @OutputFile = @BuildScriptPath+'_'+ REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE(), 120), '-', ''), ':', ''), ' ', '_') 
set @chkdirectory = @OutputFile
 
    declare @file_results table
    (file_exists int,
    file_is_a_directory int,
    parent_directory_exists int
    )


	declare @Deldirectory varchar(510)
	declare @Command varchar(2000)
	set @Deldirectory = @BuildScriptPath+'_'+ REPLACE(REPLACE(REPLACE(CONVERT(varchar(25), GETDATE()-7, 121), '-', ''), ':', ''), ' ', '_') 
	select @Deldirectory

	select @Deldirectory = SUBSTRING(@Deldirectory, LEN(@Deldirectory)-28,18)
	 SET @Command = 'RMDIR ' + @Deldirectory+  '/S /Q' 	
		            EXECUTE xp_cmdshell @Command, NO_OUTPUT
 
-- declare
-- @SQL varchar(255),
-- @RESULT int

--set @CFOLDER='C:\Test\'

--SET @SQL='IF NOT EXIST '+@CFOLDER+' (ECHO 0) else ( rd '+@CFOLDER+' /Q/S)' -- I removed the nul that was present to test on my machine...

--exec @RESULT= MASTER.DBO.xp_cmdshell @SQL

--go



    insert into @file_results
    (file_exists, file_is_a_directory, parent_directory_exists)
    exec master.dbo.xp_fileexist @chkdirectory
     
    select @folder_exists = file_is_a_directory
    from @file_results
     
    --script to create directory        
    if @folder_exists = 0
     begin
        print 'Directory is not exists, creating new one'
        EXECUTE master.dbo.xp_create_subdir @chkdirectory
        print @chkdirectory +  'created on' + @@servername
     end       
    else
    print 'Directory already exists'
declare @ReturnCode int
set @ReturnCode = 0
declare @sqldirectory  nvarchar(4000) 
set @sqldirectory = @chkdirectory 

--select @sqldirectory
-- exec @ReturnCode =   [dbo].[GenerateUserpermissionsinfo]    
--	@BuildPath = @sqldirectory
--	IF (@ReturnCode <> 0)
--         BEGIN
           
--           RAISERROR ('Failed to generate permission at DB level', 16, 1);
--         END;

--set @sqldirectory = null

--set @sqldirectory= @chkdirectory  
--exec @ReturnCode = dbo.[GenerateSQLjobinfo]

--@BuildPath = @sqldirectory
--IF (@ReturnCode <> 0)
--         BEGIN
           
--           RAISERROR ('Failed to generate SQL job info', 16, 1);
--         END;
--set @sqldirectory= @chkdirectory  
--exec @ReturnCode = dbo.GenerateDRReport

--@BuildPath = @sqldirectory
--IF (@ReturnCode <> 0)
--         BEGIN
           
--           RAISERROR ('Failed to generate DR Report info', 16, 1);
--         END;

set @sqldirectory= @chkdirectory  
exec @ReturnCode = [GenerateMailProfilesReport]

@BuildPath = @sqldirectory
IF (@ReturnCode <> 0)
         BEGIN
           
           RAISERROR ('Failed to generate SQL mail profile info', 16, 1);
         END;

GO
/****** Object:  StoredProcedure [dbo].[p_Generate_DR_Wrapper]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_Generate_DR_Wrapper]
AS
--linked servers,server logins and configuration settings
--
SET NOCOUNT ON
BEGIN
	DECLARE @return_value INT;
	DECLARE @DR_Dir VARCHAR(100);
	DECLARE @Today_DR_Dir VARCHAR(100);
	DECLARE @DR_MailProfile_Dir VARCHAR(100);
	DECLARE @DR_Permissions_Dir VARCHAR(100);
	DECLARE @DR_SQLJobs_Dir VARCHAR(100);
	DECLARE @DR_Report_Dir VARCHAR(100);
	DECLARE @folder_exists INT;
	-- Error message vars
	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorNumber INT;
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;
	DECLARE @ErrorLine INT;
	DECLARE @ErrorProcedure NVARCHAR(200);
	DECLARE @file_results TABLE (
		file_exists INT
		,file_is_a_directory INT
		,parent_directory_exists INT
		);

	SET @return_value = 0;
	SET @folder_exists = 0;
	SET @DR_Dir = '\\fs1\technology\SQLDR\'
	SET @Today_DR_Dir = @DR_Dir + convert(VARCHAR, getdate(), 112) + '\';
	SET @DR_MailProfile_Dir = @Today_DR_Dir + 'SQLMailProfiles'
	SET @DR_Permissions_Dir = @Today_DR_Dir + 'DatabasePermissions'
	SET @DR_SQLJobs_Dir = @Today_DR_Dir + 'SQLJobs'
	SET @DR_Report_Dir = @Today_DR_Dir + 'DRReport'

	--SELECT @Today_DR_Dir ,substring(@Today_DR_Dir,0,len(@Today_DR_Dir))
	BEGIN TRY
		--DIR 1 
		INSERT INTO @file_results (
			file_exists
			,file_is_a_directory
			,parent_directory_exists
			)
		EXEC master.dbo.xp_fileexist @Today_DR_Dir

		SELECT @folder_exists = file_is_a_directory
		FROM @file_results

		--script to create directory		
		IF @folder_exists = 0
		BEGIN
			--PRINT 'Directory is not exists, creating new one'

			EXECUTE master.dbo.xp_create_subdir @Today_DR_Dir

			--PRINT @Today_DR_Dir + 'created on' + substring(@Today_DR_Dir, 0, len(@Today_DR_Dir))
		END
		ELSE
			--PRINT 'Directory already exists'

		--DIR 2
		DELETE
		FROM @file_results

		SET @folder_exists = 0

		INSERT INTO @file_results (
			file_exists
			,file_is_a_directory
			,parent_directory_exists
			)
		EXEC master.dbo.xp_fileexist @DR_MailProfile_Dir

		SELECT @folder_exists = file_is_a_directory
		FROM @file_results

		--script to create directory		
		IF @folder_exists = 0
		BEGIN
			--PRINT 'Directory is not exists, creating new one'

			EXECUTE master.dbo.xp_create_subdir @DR_MailProfile_Dir

			--PRINT @DR_MailProfile_Dir + 'created on' + substring(@Today_DR_Dir, 0, len(@Today_DR_Dir))
		END
		ELSE
			--PRINT 'Directory already exists'

		--DIR 3	
		DELETE
		FROM @file_results

		SET @folder_exists = 0

		INSERT INTO @file_results (
			file_exists
			,file_is_a_directory
			,parent_directory_exists
			)
		EXEC master.dbo.xp_fileexist @DR_Permissions_Dir

		SELECT @folder_exists = file_is_a_directory
		FROM @file_results

		--script to create directory		
		IF @folder_exists = 0
		BEGIN
			--PRINT 'Directory is not exists, creating new one'

			EXECUTE master.dbo.xp_create_subdir @DR_Permissions_Dir

			--PRINT @DR_Permissions_Dir + 'created on' + substring(@Today_DR_Dir, 0, len(@Today_DR_Dir))
		END
		ELSE
			--PRINT 'Directory already exists'

		--DIR 4
		DELETE
		FROM @file_results

		SET @folder_exists = 0

		INSERT INTO @file_results (
			file_exists
			,file_is_a_directory
			,parent_directory_exists
			)
		EXEC master.dbo.xp_fileexist @DR_SQLJobs_Dir

		SELECT @folder_exists = file_is_a_directory
		FROM @file_results

		--script to create directory		
		IF @folder_exists = 0
		BEGIN
			--PRINT 'Directory is not exists, creating new one'

			EXECUTE master.dbo.xp_create_subdir @DR_SQLJobs_Dir

			--PRINT @DR_SQLJobs_Dir + 'created on' + substring(@Today_DR_Dir, 0, len(@Today_DR_Dir))
		END
		ELSE
			--PRINT 'Directory already exists'

		--DIR 4
		DELETE
		FROM @file_results

		SET @folder_exists = 0

		INSERT INTO @file_results (
			file_exists
			,file_is_a_directory
			,parent_directory_exists
			)
		EXEC master.dbo.xp_fileexist @DR_Report_Dir

		SELECT @folder_exists = file_is_a_directory
		FROM @file_results

		--script to create directory		
		IF @folder_exists = 0
		BEGIN
			--PRINT 'Directory is not exists, creating new one'

			EXECUTE master.dbo.xp_create_subdir @DR_Report_Dir

			--PRINT @DR_Report_Dir + 'created on' + substring(@Today_DR_Dir, 0, len(@Today_DR_Dir))
		END
		ELSE
			--PRINT 'Directory already exists'

		EXEC @return_value = dbo.GenerateMailProfilesReport @BuildPath = @DR_MailProfile_Dir

		IF @return_value <> 0
		BEGIN
			RAISERROR (
					'Failed while generating MailProfiles '
					,16
					,1
					)

			RETURN
		END

		EXEC @return_value = dbo.GenerateSQLjobinfo @BuildPath = @DR_SQLJobs_Dir

		IF @return_value <> 0
		BEGIN
			RAISERROR (
					'Failed while generating SQLjobinfo '
					,16
					,1
					)

			RETURN
		END

		EXEC @return_value = dbo.GenerateUserpermissionsinfo @BuildPath = @DR_Permissions_Dir

		IF @return_value <> 0
		BEGIN
			RAISERROR (
					'Failed while generating Userpermissionsinfo '
					,16
					,1
					)

			RETURN
		END

		EXEC @return_value = dbo.GenerateDRReport @BuildPath = @DR_Report_Dir

		IF @return_value <> 0
		BEGIN
			RAISERROR (
					'Failed while generating DRReport '
					,16
					,1
					)

			RETURN
		END
	END TRY

	BEGIN CATCH
		SELECT @ErrorNumber = ERROR_NUMBER()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = ERROR_STATE()
			,@ErrorLine = ERROR_LINE()
			,@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

		RAISERROR (
				@ErrorMessage
				,@ErrorSeverity
				,1
				,@ErrorNumber
				,-- parameter: original error number.
				@ErrorSeverity
				,-- parameter: original error severity.
				@ErrorState
				,-- parameter: original error state.
				@ErrorProcedure
				,-- parameter: original error procedure name.
				@ErrorLine -- parameter: original error line number.
				);
	END CATCH;
END;



GO
/****** Object:  StoredProcedure [dbo].[p_Inititator_queue_activated_procedure_SQLDriveInfoQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[p_Inititator_queue_activated_procedure_SQLDriveInfoQueue]

AS

DECLARE @dh UNIQUEIDENTIFIER;

DECLARE @message_type SYSNAME;

DECLARE @message_body NVARCHAR(4000);

BEGIN TRANSACTION;

WAITFOR (

      RECEIVE @dh = [conversation_handle],

            @message_type = [message_type_name],

            @message_body = CAST([message_body] AS NVARCHAR(4000)) 

      FROM [PentegraDataCollectorInitiatorSQLDriveInfoQueue]), TIMEOUT 1000;

WHILE @dh IS NOT NULL

BEGIN

      IF @message_type = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error'

      BEGIN

            RAISERROR (N'Received error %s from service [Target]', 10, 1, @message_body) WITH LOG;

      END

      END CONVERSATION @dh;

      COMMIT;

      SELECT @dh = NULL;

      BEGIN TRANSACTION;

      WAITFOR (

            RECEIVE @dh = [conversation_handle],

                  @message_type = [message_type_name],

                  @message_body = CAST([message_body] AS NVARCHAR(4000)) 

            FROM [PentegraDataCollectorInitiatorSQLDriveInfoQueue]), TIMEOUT 1000;

END

COMMIT;



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLBackupSummary]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLBackupSummary]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLBackupSummaryQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLBackupSummaryRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLBackupSummary @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLBackupSummary ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLDatabaseMirroringInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLDatabaseMirroringInfo]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLDatabaseMirroringInfoQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLDatabaseMirroringInfoRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLDatabaseMirroringInfo @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLDatabaseMirroringInfo ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLDatabaseOptionsInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLDatabaseOptionsInfo]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLDatabaseOptionsInfoQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLDatabaseOptionsInfoRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLDatabaseOptionsInfo @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLDatabaseOptionsInfo ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLDatabaseSizeInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLDatabaseSizeInfo]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLDatabaseSizeInfoQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLDatabaseSizeInfoRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLDatabaseSizeInfo @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLDatabaseSizeInfo ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLDBMSConfigurationInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLDBMSConfigurationInfo]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLDBMSConfigurationInfoQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLDBMSConfigurationInfoRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLDBMSConfigurationInfo @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLDBMSConfigurationInfo ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLDBMSInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLDBMSInfo]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLDBMSInfoQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLDBMSInfoRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLDBMSInfo @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLDBMSInfo ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLDriveInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLDriveInfo]

AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLDriveInfoQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLDriveInfoRequest'
		            BEGIN
		                BEGIN TRY
						
			                EXECUTE dbo.CollectSQLDriveInfo @RecvReqMsg, 0
							
			            END TRY
			            BEGIN CATCH
						INSERT INTO [MyTempTable] SELECT CURRENT_USER
						INSERT INTO [MyTempTable] SELECT SUSER_NAME()

	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLDriveInfo ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLGuardiumAuditReport]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLGuardiumAuditReport]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLGuardiumAuditReportQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLGuardiumAuditReportRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLGuardiumAuditReport @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLGuardiumAuditReport ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLJobScheduleInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLJobScheduleInfo]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLJobScheduleInfoQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLJobScheduleInfoRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLJobScheduleInfo @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLJobScheduleInfo ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLJobSummary]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLJobSummary]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLJobSummaryQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLJobSummaryRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLJobSummary @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLJobSummary ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLLinkedServerInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLLinkedServerInfo]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLLinkedServerInfoQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLLinkedServerInfoRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLLinkedServerInfo @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLLinkedServerInfo ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLLogShippingInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLLogShippingInfo]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLLogShippingInfoQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLLogShippingInfoRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLLogShippingInfo @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLLogShippingInfo ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLReplicationInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLReplicationInfo]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLReplicationInfoQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLReplicationInfoRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLReplicationInfo @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLReplicationInfo ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLSecuritySummary]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLSecuritySummary]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLSecuritySummaryQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLSecuritySummaryRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLSecuritySummary @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLSecuritySummary ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLServicesInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLServicesInfo]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLServicesInfoQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLServicesInfoRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLServicesInfo @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLServicesInfo ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_CollectSQLTSMBackupSummary]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_CollectSQLTSMBackupSummary]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetSQLTSMBackupSummaryQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/SQLTSMBackupSummaryRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.CollectSQLTSMBackupSummary @RecvReqMsg, 0
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.CollectSQLTSMBackupSummary ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadMonitorDBMSSQLConnectionQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadMonitorDBMSSQLConnectionQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorMonitorDBMSSQLConnectionService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetMonitorDBMSSQLConnectionService'
         ON CONTRACT  [//Pentegra/DataCollector/MonitorDBMSSQLConnectionContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/MonitorDBMSSQLConnectionRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadMonitorServerPingQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadMonitorServerPingQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.Server
    WHERE       CollectInfo = 1
      AND       Disable = 0

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorMonitorServerPingService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetMonitorServerPingService'
         ON CONTRACT  [//Pentegra/DataCollector/MonitorServerPingContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/MonitorServerPingRequest] (@RequestMsg);

    -- Diplay sent request.
    SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadMonitorSQLAgentRunningQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadMonitorSQLAgentRunningQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorMonitorDBMSSQLAgentRunningService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetMonitorDBMSSQLAgentRunningService'
         ON CONTRACT  [//Pentegra/DataCollector/MonitorDBMSSQLAgentRunningContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/MonitorDBMSSQLAgentRunningRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLBackupSummaryQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLBackupSummaryQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLBackupSummaryService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLBackupSummaryService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLBackupSummaryContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLBackupSummaryRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLDatabaseMirroringInfoQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLDatabaseMirroringInfoQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		LEFT(SQLVersion, CHARINDEX('.', SQLVersion) - 1) <> '8'
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLDatabaseMirroringInfoService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLDatabaseMirroringInfoService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLDatabaseMirroringInfoContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLDatabaseMirroringInfoRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLDatabaseOptionsInfoQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLDatabaseOptionsInfoQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLDatabaseOptionsInfoService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLDatabaseOptionsInfoService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLDatabaseOptionsInfoContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLDatabaseOptionsInfoRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLDatabaseSizeInfoQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLDatabaseSizeInfoQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLDatabaseSizeInfoService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLDatabaseSizeInfoService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLDatabaseSizeInfoContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLDatabaseSizeInfoRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLDBMSConfigurationInfoQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLDBMSConfigurationInfoQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLDBMSConfigurationInfoService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLDBMSConfigurationInfoService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLDBMSConfigurationInfoContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLDBMSConfigurationInfoRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLDBMSInfoQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLDBMSInfoQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLDBMSInfoService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLDBMSInfoService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLDBMSInfoContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLDBMSInfoRequest] (@RequestMsg);

    -- Diplay sent request.
     --SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLDriveInfoQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLDriveInfoQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLDriveInfoService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLDriveInfoService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLDriveInfoContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLDriveInfoRequest] (@RequestMsg);

    -- Diplay sent request.
   -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLGuardiumAuditReportQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLGuardiumAuditReportQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLGuardiumAuditReportService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLGuardiumAuditReportService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLGuardiumAuditReportContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLGuardiumAuditReportRequest] (@RequestMsg);

    -- Diplay sent request.
  SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLJobScheduleInfoQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLJobScheduleInfoQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLJobScheduleInfoService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLJobScheduleInfoService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLJobScheduleInfoContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLJobScheduleInfoRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLJobSummaryQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLJobSummaryQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLJobSummaryService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLJobSummaryService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLJobSummaryContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLJobSummaryRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLLinkedServerInfoQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLLinkedServerInfoQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLLinkedServerInfoService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLLinkedServerInfoService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLLinkedServerInfoContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLLinkedServerInfoRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLLogShippingInfoQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLLogShippingInfoQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLLogShippingInfoService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLLogShippingInfoService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLLogShippingInfoContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLLogShippingInfoRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLReplicationInfoQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLReplicationInfoQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLReplicationInfoService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLReplicationInfoService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLReplicationInfoContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLReplicationInfoRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLSecuritySummaryQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLSecuritySummaryQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLSecuritySummaryService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLSecuritySummaryService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLSecuritySummaryContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLSecuritySummaryRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLServicesInfoQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLServicesInfoQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLServicesInfoService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLServicesInfoService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLServicesInfoContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLServicesInfoRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_LoadSQLTSMBackupSummaryQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_LoadSQLTSMBackupSummaryQueue]
AS

SET NOCOUNT ON

DECLARE @InitDlgHandle  UNIQUEIDENTIFIER
        ,@RequestMsg    NVARCHAR(100)
        ,@DBMS_Id       int

DECLARE CURSOR_DBMS CURSOR FAST_FORWARD
FOR
    SELECT      Id
    FROM        dbo.DBMS
    WHERE       CollectInfo = 1
      AND       Disable = 0
      AND		Type = 'SQL Server'      

OPEN CURSOR_DBMS

FETCH NEXT FROM CURSOR_DBMS
INTO @DBMS_Id

WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN DIALOG @InitDlgHandle
         FROM SERVICE [//Pentegra/DataCollector/InitatorSQLTSMBackupSummaryService]
         TO SERVICE  N'//Pentegra/DataCollector/TargetSQLTSMBackupSummaryService'
         ON CONTRACT  [//Pentegra/DataCollector/SQLTSMBackupSummaryContract]
         WITH  ENCRYPTION = OFF;

    -- Send a message on the conversation
    SELECT @RequestMsg = CAST(@DBMS_Id AS varchar(10));

    SEND ON CONVERSATION @InitDlgHandle
         MESSAGE TYPE  [//Pentegra/DataCollector/SQLTSMBackupSummaryRequest] (@RequestMsg);

    -- Diplay sent request.
    -- SELECT @RequestMsg AS SentRequestMsg;

    FETCH NEXT FROM CURSOR_DBMS
    INTO @DBMS_Id
END    

CLOSE CURSOR_DBMS
DEALLOCATE CURSOR_DBMS



GO
/****** Object:  StoredProcedure [dbo].[SB_MonitorDBMSSQLAgentRunning]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_MonitorDBMSSQLAgentRunning]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetMonitorDBMSSQLAgentRunningQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/MonitorDBMSSQLAgentRunningRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.Monitor_DBMSSQLAgentRunning @RecvReqMsg
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.Monitor_DBMSSQLAgentRunning ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_MonitorDBMSSQLConnection]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SB_MonitorDBMSSQLConnection]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetMonitorDBMSSQLConnectionQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/MonitorDBMSSQLConnectionRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.Monitor_DBMSSQLConnection @RecvReqMsg
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.Monitor_DBMSSQLConnection ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[SB_MonitorServerPing]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SB_MonitorServerPing]
AS
	
	DECLARE @RecvReqDlgHandle		uniqueidentifier
			,@RecvReqMsg			nvarchar(100)
			,@RecvReqMsgName		sysname
			
	SET NOCOUNT ON	

    WHILE (1 = 1)
    BEGIN
	    WAITFOR
	    (
		    RECEIVE TOP(1)
			    @RecvReqDlgHandle = conversation_handle
			    ,@RecvReqMsg = message_body
			    ,@RecvReqMsgName = message_type_name
            FROM PentegraDataCollectorTargetMonitorServerPingQueue
	    ), TIMEOUT 5000

        IF( @@ROWCOUNT = 0 ) 
            BREAK
		ELSE
		    BEGIN
	            IF @RecvReqMsgName = N'//Pentegra/DataCollector/MonitorServerPingRequest'
		            BEGIN
		                BEGIN TRY
			                EXECUTE dbo.Monitor_ServerPing @RecvReqMsg
			            END TRY
			            BEGIN CATCH
	                        PRINT '*** ERROR OCCURRED DURING EXECUTION'
	                        PRINT '    EXECUTE dbo.Monitor_ServerPing ' + @RecvReqMsg 
	                        PRINT '        Msg ' + CAST(ERROR_NUMBER() AS varchar) +
	    							', Level ' + CAST(ERROR_SEVERITY() AS varchar) + 
									', State ' + CAST(ERROR_STATE() AS varchar) +
									', Line ' + CAST(ERROR_LINE() AS varchar)
	                        PRINT '        ' + ERROR_MESSAGE()    			            
			            END CATCH
                        
                        END CONVERSATION @RecvReqDlgHandle
		            END
	            ELSE
	                BEGIN
		                IF @RecvReqMsgName = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog'
			                END CONVERSATION @RecvReqDlgHandle
		                ELSE
			                IF @RecvReqMsgName = 'http://schemas.microsoft.com/SQL/ServiceBroker/Error'
				                END CONVERSATION @RecvReqDlgHandle
                    END
            END	            
    END



GO
/****** Object:  StoredProcedure [dbo].[UpdateConfigurationValue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateConfigurationValue]
(
	@Name		varchar(255)
	,@Data		varchar(2500)
)
AS

SET NOCOUNT ON

UPDATE		dbo.Configuration
   SET		Data = @Data
WHERE		Name = @Name


GO
/****** Object:  StoredProcedure [dbo].[UpdateFileHash]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateFileHash]
	@FilePath varchar(1000)
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM FileHash
	WHERE FilePath = @FilePath

	EXECUTE CheckFileHash @FilePath
END



GO
/****** Object:  UserDefinedFunction [dbo].[fn_SQLSigTSQL]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_SQLSigTSQL] 
  (@p1 NTEXT, @parselength INT = 4000)
RETURNS NVARCHAR(4000)

--
-- This function is provided "AS IS" with no warranties,
-- and confers no rights. 
-- Use of included script samples are subject to the terms specified at
-- http://www.microsoft.com/info/cpyright.htm
-- 
-- Strips query strings
AS
BEGIN 
  DECLARE @pos AS INT;
  DECLARE @mode AS CHAR(10);
  DECLARE @maxlength AS INT;
  DECLARE @p2 AS NCHAR(4000);
  DECLARE @currchar AS CHAR(1), @nextchar AS CHAR(1);
  DECLARE @p2len AS INT;

  SET @maxlength = LEN(RTRIM(SUBSTRING(@p1,1,4000)));
  SET @maxlength = CASE WHEN @maxlength > @parselength 
                     THEN @parselength ELSE @maxlength END;
  SET @pos = 1;
  SET @p2 = '';
  SET @p2len = 0;
  SET @currchar = '';
  set @nextchar = '';
  SET @mode = 'command';

  WHILE (@pos <= @maxlength)
  BEGIN
    SET @currchar = SUBSTRING(@p1,@pos,1);
    SET @nextchar = SUBSTRING(@p1,@pos+1,1);
    IF @mode = 'command'
    BEGIN
      SET @p2 = LEFT(@p2,@p2len) + @currchar;
      SET @p2len = @p2len + 1 ;
      IF @currchar IN (',','(',' ','=','<','>','!')
        AND @nextchar BETWEEN '0' AND '9'
      BEGIN
        SET @mode = 'number';
        SET @p2 = LEFT(@p2,@p2len) + '#';
        SET @p2len = @p2len + 1;
      END 
      IF @currchar = ''''
      BEGIN
        SET @mode = 'literal';
        SET @p2 = LEFT(@p2,@p2len) + '#''';
        SET @p2len = @p2len + 2;
      END
    END
    ELSE IF @mode = 'number' AND @nextchar IN (',',')',' ','=','<','>','!')
      SET @mode= 'command';
    ELSE IF @mode = 'literal' AND @currchar = ''''
      SET @mode= 'command';

    SET @pos = @pos + 1;
  END
  RETURN @p2;
END



GO
/****** Object:  UserDefinedFunction [dbo].[FullBackupExist]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FullBackupExist]
(
		@Database		varchar(128)
		,@BackupPath	varchar(128)
)
RETURNS int
AS
BEGIN 
	DECLARE @BackupFile		varchar(1024)
			,@Return		int
			,@Cmd			varchar(2000)

	IF RIGHT(@BackupPath, 1) <> '\'
		SET @BackupPath = @BackupPath + '\'

	SELECT		@BackupFile = Z.physical_device_name
	FROM		msdb.dbo.backupset X
					JOIN 
						(
							SELECT		S.database_name
										,MAX(S.backup_set_id) AS backup_set_id 
							FROM		master.dbo.sysdatabases				D
											JOIN msdb.dbo.backupset			S ON D.name				= S.database_name
											JOIN msdb.dbo.backupmediafamily	F ON S.media_set_id		= F.media_set_id
							WHERE		S.Type = 'D'
							  AND		D.name = @Database
							  AND		S.is_copy_only = 0
							  AND		S.backup_start_date IS NOT NULL							
							  AND		S.backup_finish_date IS NOT NULL
							GROUP BY	S.database_name
						) Y ON X.backup_set_id = Y.backup_set_id 
					JOIN msdb.dbo.backupmediafamily	Z ON X.media_set_id		= Z.media_set_id
	WHERE		Z.physical_device_name IS NOT NULL
	  AND		Z.physical_device_name <> 'NUL'

	IF LTRIM(ISNULL(@BackupFile, '')) = '' OR @BackupFile NOT LIKE @BackupPath + '%'
		SET @Return = 1
	ELSE
		BEGIN
			SET @Cmd = 'dir /b "' + @BackupFile + '"'
			EXECUTE @Return = xp_cmdshell @Cmd
		END

	RETURN (@Return)
END



GO
/****** Object:  UserDefinedFunction [dbo].[funcGetConfigurationData]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[funcGetConfigurationData]
(
	@Name varchar(128)
)
RETURNS varchar(2500) AS  
BEGIN
	DECLARE @Data varchar(2500)

	SELECT 		@Data = [Data]
	FROM 		[dbo].[Configuration ]
	WHERE 		[Name] = @Name

	RETURN (@Data)
END



GO
/****** Object:  Table [dbo].[Configuration]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Configuration](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[Data] [varchar](2500) NOT NULL,
	[Notes] [varchar](500) NULL
) ON [Index]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DBMS]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DBMS](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [varchar](25) NOT NULL,
	[Name] [varchar](128) NOT NULL,
	[Instance] [varchar](128) NOT NULL,
	[IPAddress] [varchar](25) NOT NULL,
	[Port] [varchar](15) NULL,
	[Domain] [varchar](50) NULL,
	[Environment] [char](1) NULL,
	[HardwareType] [char](1) NOT NULL,
	[ServerType] [char](1) NOT NULL,
	[NamedPipesEnabled] [bit] NULL,
	[TcpIpEnabled] [bit] NULL,
	[DynamicPort] [varchar](15) NULL,
	[StaticPort] [varchar](15) NULL,
	[ForceProtocolEncryption] [bit] NULL,
	[SQLVersion] [varchar](25) NULL,
	[SQLEdition] [varchar](50) NULL,
	[SQLCollation] [varchar](50) NULL,
	[SQLSortOrder] [varchar](50) NULL,
	[RunningOnServer] [varchar](128) NULL,
	[WindowsVersion] [varchar](25) NULL,
	[Platform] [varchar](25) NULL,
	[PhysicalCPU] [tinyint] NULL,
	[LogicalCPU] [smallint] NULL,
	[PhysicalMemory] [int] NULL,
	[DotNetVersion] [varchar](25) NULL,
	[DBMailProfile] [varchar](128) NULL,
	[AgentMailProfile] [varchar](128) NULL,
	[LoginAuditLevel] [varchar](25) NULL,
	[ServerNameProperty] [varchar](128) NULL,
	[DateInstalled] [datetime] NULL,
	[DateRemoved] [datetime] NULL,
	[ApproxStartDate] [datetime] NULL,
	[ProgramDirectory] [varchar](256) NULL,
	[Path] [varchar](256) NULL,
	[BinaryDirectory] [varchar](256) NULL,
	[DefaultDataDirectory] [varchar](256) NULL,
	[DefaultLogDirectory] [varchar](256) NULL,
	[AbleToEmail] [bit] NOT NULL,
	[SupportedBy] [varchar](25) NULL,
	[TopologyActive] [bit] NULL,
	[TopologyKey] [int] NULL,
	[CollectInfo] [bit] NOT NULL,
	[PingByName] [bit] NULL,
	[PingDomainInfo] [varchar](128) NULL,
	[PingIPInfo] [varchar](25) NULL,
	[Disable] [bit] NOT NULL,
	[Notes] [varchar](500) NULL,
	[CreatedBy] [varchar](128) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastUpdate] [datetime] NULL,
 CONSTRAINT [PK_DBMS] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = ON, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DBMSConfigurationInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DBMSConfigurationInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[ConfigId] [varchar](50) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](256) NOT NULL,
	[Value] [varchar](256) NOT NULL,
	[ValueInUse] [varchar](256) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DBMSConfigurationInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FileHash]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FileHash](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FilePath] [varchar](1000) NOT NULL,
	[HashValue] [varbinary](64) NULL,
 CONSTRAINT [PK_FileHash] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Monitor]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Monitor](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](128) NOT NULL,
	[Description] [varchar](1024) NULL,
	[Duration] [tinyint] NOT NULL,
	[AlertThreshold] [smallint] NOT NULL,
	[AlertThresholdDelay] [smallint] NOT NULL,
	[CreateDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitorDBMSLog]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitorDBMSLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[Monitor_Id] [int] NOT NULL,
	[LastSuccess] [datetime] NULL,
	[LastFailure] [datetime] NULL,
	[RaiseAlert] [tinyint] NOT NULL,
	[ThresholdDate] [datetime] NULL,
	[ThresholdCount] [int] NOT NULL,
	[IgnoreAlertUntil] [datetime] NULL,
	[Disable] [bit] NOT NULL,
	[Notes] [varchar](1024) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MonitorDBMSLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitorDBMSLogDetail]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitorDBMSLogDetail](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[MonitorDBMSLog_Id] [int] NOT NULL,
	[Status] [varchar](50) NOT NULL,
	[Description] [varchar](1024) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MonitorDBMSLogDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitorServerLog]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitorServerLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Server_Id] [int] NOT NULL,
	[Monitor_Id] [int] NOT NULL,
	[LastSuccess] [datetime] NULL,
	[LastFailure] [datetime] NULL,
	[RaiseAlert] [tinyint] NOT NULL,
	[ThresholdDate] [datetime] NULL,
	[ThresholdCount] [int] NOT NULL,
	[IgnoreAlertUntil] [datetime] NULL,
	[Disable] [bit] NOT NULL,
	[Notes] [varchar](1024) NULL,
	[CreateDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MonitorServerLogDetail]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MonitorServerLogDetail](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[MonitorServerLog_Id] [int] NOT NULL,
	[Status] [varchar](50) NOT NULL,
	[Description] [varchar](1024) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MonitorServerLogDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Server]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Server](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](128) NOT NULL,
	[IPAddress] [varchar](25) NOT NULL,
	[Domain] [varchar](50) NULL,
	[Location] [varchar](128) NULL,
	[Address] [varchar](128) NULL,
	[City] [varchar](128) NULL,
	[State] [char](2) NULL,
	[Floor] [varchar](50) NULL,
	[Grid] [varchar](50) NULL,
	[HardwareType] [char](1) NULL,
	[ServerType] [char](1) NULL,
	[Manufactured] [varchar](25) NULL,
	[Model] [varchar](25) NULL,
	[WindowsVersion] [varchar](25) NULL,
	[Platform] [varchar](25) NULL,
	[PhysicalCPU] [tinyint] NULL,
	[LogicalCPU] [smallint] NULL,
	[PhysicalMemory] [int] NULL,
	[DateInstalled] [datetime] NULL,
	[DateRemoved] [datetime] NULL,
	[CollectInfo] [bit] NOT NULL,
	[TopologyActive] [bit] NULL,
	[SupportedBy] [varchar](25) NULL,
	[PingByName] [bit] NULL,
	[PingDomainInfo] [varchar](128) NULL,
	[PingIPInfo] [varchar](25) NULL,
	[Disable] [bit] NOT NULL,
	[Notes] [varchar](500) NULL,
	[CreatedBy] [varchar](128) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastUpdate] [datetime] NULL,
 CONSTRAINT [PK_Server] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerDBMS]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerDBMS](
	[Server_Id] [int] NOT NULL,
	[DBMS_Id] [int] NOT NULL,
 CONSTRAINT [PK_ServerDBMS] PRIMARY KEY CLUSTERED 
(
	[Server_Id] ASC,
	[DBMS_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  UserDefinedFunction [dbo].[f_DelimitedSplit8K]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create function [dbo].[f_DelimitedSplit8K]
        (
            @pString varchar(8000),
            @pDelimiter char(1)
        )
returns table with SCHEMABINDING
as
/*

Filename: f_DelimitedSplit8K.sql
Author: Jeff Moden

Object: f_DelimitedSplit8K
ObjectType: table-valued function

Description:    Yet another approach for taking a single string value
                that has a series of characters separated by a delimiter. The function
                splits the string using the delimiter character into a table of elements.
                The approach here is to create a table of integers that has as many rows
                as the string to be split. This guarantees that there will be enough
                elements in the table. This is the fastest split method we have tested.

Param1: @pString - the string to be split.
Param2: @pDelimiter - the character used as the delimiter.

OutputType: table

Output1: Item number - This is a ordinal value that is the row order.
Output2: Item_Value - This is the element that is the result of the split.

Revisions
Ini |    Date     | Description
---------------------------------

*/

 RETURN
--===== "Inline" CTE Driven "Tally Table" produces values from 0 up to 10,000...
     -- enough to cover VARCHAR(8000)
  WITH E1(N) AS (
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL 
                 SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
                ),                          --10E+1 or 10 rows
       E2(N) AS (SELECT 1 FROM E1 a cross join E1 b), --10E+2 or 100 rows
       E4(N) AS (SELECT 1 FROM E2 a cross join E2 b), --10E+4 or 10,000 rows max
 cteTally(N) AS (--==== This provides the "base" CTE and limits the number of rows right up front
                     -- for both a performance gain and prevention of accidental "overruns"
                 SELECT TOP (ISNULL(DATALENGTH(@pString),0)) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E4
                ),
cteStart(N1) AS (--==== This returns N+1 (starting position of each "element" just once for each delimiter)
                 SELECT 1 UNION ALL
                 SELECT t.N+1 FROM cteTally t WHERE SUBSTRING(@pString,t.N,1) = @pDelimiter
                ),
cteLen(N1,L1) AS(--==== Return start and length (for use in substring)
                 SELECT s.N1,
                        ISNULL(NULLIF(CHARINDEX(@pDelimiter,@pString,s.N1),0)-s.N1,8000)
                   FROM cteStart s
                )
--===== Do the actual split. The ISNULL/NULLIF combo handles the length for the final element when no delimiter is found.
 SELECT ItemNumber = ROW_NUMBER() OVER(ORDER BY l.N1),
        Item       = SUBSTRING(@pString, l.N1, l.L1)
   FROM cteLen l
;


GO
/****** Object:  View [dbo].[Monitor_DBMSSQLLogDetails]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[Monitor_DBMSSQLLogDetails]
AS

SELECT		A.Id AS [DBMS_Id]
			,A.Name AS [SQLServer]
			,A.Instance
			,A.IPAddress
			,A.Port
			,A.Name +			
					CASE 
						WHEN [Instance] IS NULL THEN '' 
						WHEN [Instance] = 'Default' THEN ''
						WHEN [Instance] = 'MSSQLServer' THEN ''
						ELSE '\' + [Instance] 
					END + CASE WHEN LTRIM(ISNULL(A.Port, '')) = '' 
							THEN ''
							ELSE ',' + A.Port
						 END AS [SQLServerConnection]
			,A.IPAddress +
					CASE 
						WHEN [Instance] IS NULL THEN '' 
						WHEN [Instance] = 'Default' THEN ''
						WHEN [Instance] = 'MSSQLServer' THEN ''
						ELSE '\' + [Instance] 
					END + CASE WHEN LTRIM(ISNULL(A.Port, '')) = '' 
							THEN ''
							ELSE ',' + A.Port
						 END AS [SQLServerConnectionByIP] 			
			,A.SQLVersion
			,A.SQLEdition
			,A.Environment
			,D.Name
			,C.Status       AS [Status]
			,C.Description  AS [Description]
			,C.CreateDate   AS [DetailDate]
FROM        dbo.DBMS A
                JOIN dbo.MonitorDBMSLog B ON A.Id = B.DBMS_Id
                JOIN dbo.MonitorDBMSLogDetail C ON B.Id = C.MonitorDBMSLog_Id
                JOIN dbo.Monitor D ON B.Monitor_Id = D.Id
WHERE       A.Type = 'SQL Server'
  AND       A.CollectInfo = 1
  AND       A.Disable = 0



GO
/****** Object:  View [dbo].[Monitor_DBMSSQLLogInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[Monitor_DBMSSQLLogInfo]
AS

SELECT		A.Id AS [DBMS_Id]
			,A.Name AS [SQLServer]
			,A.Instance
			,A.IPAddress
			,A.Port
			,A.Name +			
					CASE 
						WHEN [Instance] IS NULL THEN '' 
						WHEN [Instance] = 'Default' THEN ''
						WHEN [Instance] = 'MSSQLServer' THEN ''
						ELSE '\' + [Instance] 
					END + CASE WHEN LTRIM(ISNULL(A.Port, '')) = '' 
							THEN ''
							ELSE ',' + A.Port
						 END AS [SQLServerConnection]
			,A.IPAddress +
					CASE 
						WHEN [Instance] IS NULL THEN '' 
						WHEN [Instance] = 'Default' THEN ''
						WHEN [Instance] = 'MSSQLServer' THEN ''
						ELSE '\' + [Instance] 
					END + CASE WHEN LTRIM(ISNULL(A.Port, '')) = '' 
							THEN ''
							ELSE ',' + A.Port
						 END AS [SQLServerConnectionByIP] 			
			,A.SQLVersion
			,A.SQLEdition
			,A.Environment
			,D.Name
			,D.Duration
			,D.AlertThreshold
			,D.AlertThresholdDelay
			,B.LastSuccess
			,B.LastFailure
			,B.ThresholdDate
			,B.ThresholdCount
			,B.IgnoreAlertUntil
			,B.RaiseAlert
FROM        dbo.DBMS A
                JOIN dbo.MonitorDBMSLog B ON A.Id = B.DBMS_Id
                JOIN dbo.Monitor D ON B.Monitor_Id = D.Id
WHERE       A.Type = 'SQL Server'
  AND       A.CollectInfo = 1
  AND       A.Disable = 0








GO
/****** Object:  View [dbo].[Monitor_ServerLogDetails]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[Monitor_ServerLogDetails]
AS

SELECT		A.Id AS [Server_Id]
			,A.Name AS [SQLServer]
			,A.IPAddress
			,D.Name
			,C.Status       AS [Status]
			,C.Description  AS [Description]
			,C.CreateDate   AS [DetailDate]
FROM        dbo.Server A
                JOIN dbo.MonitorServerLog B ON A.Id = B.Server_Id
                JOIN dbo.MonitorServerLogDetail C ON B.Id = C.MonitorServerLog_Id
                JOIN dbo.Monitor D ON B.Monitor_Id = D.Id
WHERE       A.CollectInfo = 1
  AND       A.Disable = 0




GO
/****** Object:  View [dbo].[Monitor_ServerLogInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[Monitor_ServerLogInfo]
AS

SELECT		A.Id AS [Server_Id]
			,A.Name AS [SQLServer]
			,A.IPAddress
			,D.Name
			,D.Duration
			,D.AlertThreshold
			,D.AlertThresholdDelay
			,B.LastSuccess
			,B.LastFailure
			,B.ThresholdDate
			,B.ThresholdCount
			,B.IgnoreAlertUntil
			,B.RaiseAlert
FROM        dbo.Server A
                JOIN dbo.MonitorServerLog B ON A.Id = B.Server_Id
                JOIN dbo.Monitor D ON B.Monitor_Id = D.Id
WHERE       A.CollectInfo = 1
  AND       A.Disable = 0



GO
/****** Object:  View [dbo].[Servers_WithDBMSNotIdentified]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[Servers_WithDBMSNotIdentified]
AS

SELECT		A.Id AS [Server_Id]
			,A.Name AS [Server]
			,A.HardwareType
			,A.PhysicalCPU
			,A.PhysicalMemory
			,A.WindowsVersion
			,A.Platform
			,A.CollectInfo 
			,A.Disable
FROM		dbo.Server A
				LEFT JOIN dbo.ServerDBMS B ON A.Id = B.Server_Id
WHERE       B.DBMS_Id IS NULL



GO
/****** Object:  View [dbo].[ServerScheduleTaskInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[ServerScheduleTaskInfo]
AS

SELECT		S.Id AS [Server_Id]
            ,S.Name AS [Server]
            ,S.IPAddress
			,S.[Domain]
			,T.[TaskName]			
			,CASE 
				WHEN ISDATE(T.NextRunTime) = 0 THEN NULL
				ELSE CAST(T.NextRunTime AS datetime)
			END AS [NextRunDate]			
			,T.[Status]
			,T.[LogonMode]
			,CASE 
				WHEN ISDATE(T.LastRunTime) = 0 THEN NULL
				ELSE CAST(T.LastRunTime AS datetime)
			END AS [LastRunDate]			
			,T.[LastResults]
			,T.[Creator]
			,T.[TaskToRun]
			,T.[StartIn]
			,T.[Comment]
			,T.[ScheduleTaskState]
			,T.[IdleTime]
			,T.[PowerManagement]
			,T.[RunAsUser]
			,T.[DeleteTaskIfNotRescheduled]
			,T.[StopTaskIfRunsXHoursAndXMins]
			,T.[Schedule]
			,T.[ScheduleType]
			,T.[StartTime]
			,T.[StartDate]
			,T.[EndDate]
			,T.[Days]
			,T.[Months]
			,T.[RepeatEvery]
			,T.[RepeatUntilTime]
			,T.[RepeatUntilDuration]
			,T.[RepeatStopIfStillRunning]
			,T.[CreateDate]
FROM		[dbo].[Server]					S WITH (NOLOCK)                
				JOIN [ScheduledTaskInfo]	T WITH (NOLOCK)	ON S.Id = T.Server_Id
WHERE		S.[Disable] = 0




GO
/****** Object:  View [dbo].[SQLAbleToCollectInfoOn]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[SQLAbleToCollectInfoOn]
AS

SELECT		[Id]
			,[Name]
			,[Instance]
            ,[Name] + 
                CASE 
                    WHEN [Instance] IS NULL THEN '' 
                    WHEN [Instance] = 'Default' THEN ''
                    WHEN [Instance] = 'MSSQLServer' THEN ''
                    ELSE '\' + [Instance] 
                END										AS [SQLServer]			
			,[IPAddress]
			,[Port]
			,[Domain]
			,[HardwareType]
			,[Environment]
			,[ServerType]
			,[SQLVersion]
			,[SQLEdition]
            ,[Name] + 
                CASE 					
                    WHEN [Instance] IS NULL THEN '' 
                    WHEN [Instance] = 'Default' THEN ''
                    WHEN [Instance] = 'MSSQLServer' THEN ''
                    ELSE '\' + [Instance] 
                 END +
	                    CASE WHEN [Port] IS NULL
		                    THEN ''
		                    ELSE ',' + CAST([Port] AS varchar(10))
	                    END	 AS [SQLConnection]			            
            ,[IPAddress] + 
                    CASE 					
                        WHEN [Instance] IS NULL THEN '' 
                        WHEN [Instance] = 'Default' THEN ''
                        WHEN [Instance] = 'MSSQLServer' THEN ''
                        ELSE '\' + [Instance] 
                     END +
	                        CASE WHEN [Port] IS NULL
		                        THEN ''
		                        ELSE ',' + CAST([Port] AS varchar(10))
	                        END	 AS [SQLConnectionViaIP]			
            ,[IPAddress] + 
                    CASE 					
                        WHEN [Instance] IS NULL THEN '' 
                        WHEN [Instance] = 'Default' THEN ''
                        WHEN [Instance] = 'MSSQLServer' THEN ''
                        ELSE '\' + [Instance] 
                     END +
	                        CASE WHEN [Port] IS NULL
		                        THEN ''
		                        ELSE ',' + CAST([Port] AS varchar(10))
	                        END	 AS [DataCollectorConnectString]			
FROM		DBMS
WHERE		CollectInfo = 1
  AND		Disable = 0
  AND		Type = 'SQL Server'





GO
/****** Object:  View [dbo].[SQLDatabaseMirroringInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view  [dbo].[SQLDatabaseMirroringInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,B.[DatabaseName]
			,B.[Role]
			,B.[State]
			,B.[Sequence]
			,B.[SafteyLevel]
			,B.[PartnerName]
			,B.[PartnerInstance]
			,B.[PartnerWitness]
			,B.[WitnessState]
			,B.[ConnectionTimeout]
			,B.[RedoQueueType]
			,B.[CreateDate]			
			,DATEDIFF(d, B.CreateDate, GETDATE()) AS [Info_DaysOld]
FROM		[dbo].[DBMS]					            S WITH (NOLOCK)
				JOIN [dbo].[DatabaseMirroringInfo]	B WITH (NOLOCK)	ON S.Id = B.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'





GO
/****** Object:  View [dbo].[SQLDatabaseOptionsInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[SQLDatabaseOptionsInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,D.[Name] AS [DbName]
			,D.[DbCreateDate]
			,D.[Owner]
			,D.[Collation]
			,D.[CompatibilityLevel]
			,D.[RecoveryModel]
			,D.[AutoClose]
			,D.[AutoCreateStatistics]
			,D.[AutoShrink]
			,D.[AutoUpdateStatistics]
			,D.[CloseCursorOnCommitEnabled]
			,D.[ANSINullDefault]
			,D.[ANSINullsEnabled]
			,D.[ANSIPaddingEnabled]
			,D.[ANSIWarningsEnabled]
			,D.[ArithmeticAbortEnabled]
			,D.[ConcatenateNullYieldsNull]
			,D.[CrossDbOwnership]
			,D.[NumericRoundAbort]
			,D.[QuotedIdentifierEnabled]
			,D.[RecursiveTriggersEnabled]
			,D.[FullTextEnabled]
			,D.[Trustworthy]
			,D.[BrokerEnabled]
			,D.[ReadOnly]
			,D.[RestrictUserAccess]
			,D.[Status]
			,D.[CreateDate]
			,DATEDIFF(d, D.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN D.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]		                        S WITH (NOLOCK)
				LEFT JOIN [dbo].[DatabaseOptionsInfo]	D WITH (NOLOCK)	ON S.Id = D.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'








GO
/****** Object:  View [dbo].[SQLDatabaseSizeInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[SQLDatabaseSizeInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
            ,D.DbName
            ,D.Type
            ,D.Filegroup
            ,D.LogicalName
            ,D.FileSize_MB
            ,D.UsedSpace_MB
            ,D.UnusedSpace_MB
            ,D.MaxSize_MB
            ,D.Growth
            ,D.GrowthType
            ,D.PhysicalName
            ,D.CreateDate
			,DATEDIFF(d, D.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN D.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM        dbo.DBMS                            AS S WITH (NOLOCK)
                LEFT JOIN dbo.DatabaseSizeInfo  AS D WITH (NOLOCK) ON S.Id = D.DBMS_Id
WHERE     (S.Disable = 0)
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'










GO
/****** Object:  View [dbo].[SQLDatabaseSpaceSummary]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[SQLDatabaseSpaceSummary] 
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,D.[DbName]
			,D.[Type]
			,(SUM(D.[FileSize_MB])/1024) AS TotalDBFileSize_GB
			,(SUM(D.[UsedSpace_MB])/1024) AS TotalDBUsedSpace_GB
			,(SUM(D.[UnusedSpace_MB])/1024) AS TotalDBUnusedSpace_GB
			,CASE WHEN D.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]				        S WITH (NOLOCK)
				LEFT JOIN [DatabaseSizeInfo]	D WITH (NOLOCK)	ON S.Id = D.DBMS_Id
WHERE		S.Disable = 0
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'
GROUP BY	S.Id 
            ,S.Name
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,D.[DbName]
			,D.[Type]
			,CASE WHEN D.DBMS_Id IS NULL THEN 0 ELSE 1 END 









GO
/****** Object:  View [dbo].[SQLDBMSConfigurationInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[SQLDBMSConfigurationInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,S.[PhysicalCPU]
			,S.[LogicalCPU]
			,S.[PhysicalMemory]
			,D.[ConfigId]
			,D.[Name] AS [ConfigName]
			,D.[Description] 
			,D.Value
			,D.ValueInUse
			,D.[CreateDate]
			,DATEDIFF(d, D.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN D.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]		                        S WITH (NOLOCK)
				LEFT JOIN [dbo].[DBMSConfigurationInfo]	D WITH (NOLOCK)	ON S.Id = D.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'










GO
/****** Object:  View [dbo].[SQLDriveSpaceInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [dbo].[SQLDriveSpaceInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,D.[DriveLetter]
			,D.[TotalSpace]
			,D.[FreeSpace]
			,D.[Notes]
			,D.[CreateDate]
			,DATEDIFF(d, D.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN D.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]					    S WITH (NOLOCK)	
				LEFT JOIN [DriveSpaceInfo]		D WITH (NOLOCK)	ON S.Id = D.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.[CollectInfo] = 1
  AND       S.[Type] = 'SQL Server'













GO
/****** Object:  View [dbo].[SQLGuardiumAuditReport]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[SQLGuardiumAuditReport]
AS

SELECT		A.Id AS [DBMS_Id]
            ,A.Name AS SQLServer
			,A.IPAddress
            ,A.Instance
            ,A.Port
            ,A.SQLVersion
			,A.SQLEdition
			,A.[Domain]
			,A.[Environment]
			,B.TestId
			,B.TestDescription
			,B.DbName
			,B.Description
			,B.FixScript
			,B.RollbackScript
			,B.CreateDate
			,DATEDIFF(d, B.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN B.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		dbo.DBMS	                            A WITH (NOLOCK)
				LEFT JOIN dbo.GuardiumAuditReport   B WITH (NOLOCK) ON A.Id = B.DBMS_Id
WHERE		A.[Disable] = 0
  AND       A.[CollectInfo] = 1
  AND       A.[Type] = 'SQL Server'












GO
/****** Object:  View [dbo].[SQLJobScheduleInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[SQLJobScheduleInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
            ,J.JobName
            ,J.JobOwner
            ,J.ScheduleName
            ,J.ScheduleInfo
            ,J.ScheduleType
            ,J.StartDate
            ,J.StartTime
            ,J.EndDate
            ,J.EndTime
            ,J.Frequency
            ,J.Day
            ,J.DayOfMonth
            ,J.Every
            ,J.DailyInterval
            ,J.DailyIntervalType
            ,J.Sunday
            ,J.Monday
            ,J.Tuesday
            ,J.Wednesday
            ,J.Thursday
            ,J.Friday
            ,J.Saturday
            ,J.CreateDate
			,DATEDIFF(d, J.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN J.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM        dbo.DBMS                            AS S WITH (NOLOCK) 
                LEFT JOIN dbo.JobScheduleInfo   AS J WITH (NOLOCK) ON S.Id = J.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.[CollectInfo] = 1
  AND       S.[Type] = 'SQL Server'











GO
/****** Object:  View [dbo].[SQLJobSummary]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[SQLJobSummary]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,J.[Name]
			,J.[Enabled]
			,J.[Running]
			,J.[RunningDuration_Sec]
			,J.[LastFailureDate]
			,J.[LastFailureDuration_Sec]
			,J.[LastSuccessDate]
			,J.[LastSuccessDuration_Sec]
			,J.[NextRunDate]
			,J.[TodayErrorCount]
			,J.[TodaySuccessCount]
			,J.[YesterdayErrorCount]
			,J.[YesterdaySuccessCount]
			,J.[TwoDaysAgoErrorCount]
			,J.[TwoDaysAgoSuccessCount]
			,J.[ThreeDaysAgoErrorCount]
			,J.[ThreeDaysAgoSuccessCount]	
			,J.[CreateDate]	 
			,DATEDIFF(d, J.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN J.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]			    S WITH (NOLOCK)
				LEFT JOIN [JobSummary]	J WITH (NOLOCK)	ON S.Id = J.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.[CollectInfo] = 1
  AND       S.[Type] = 'SQL Server'







GO
/****** Object:  View [dbo].[SQLLinkedServerInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[SQLLinkedServerInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
            ,L.LinkedServer
            ,L.LocalLogin
            ,L.LoginType
            ,L.Impersonate
            ,L.RemoteUser
            ,L.LoginNotDefine
            ,L.Provider
            ,L.DataSource
            ,L.Location
            ,L.ProviderString
            ,L.Catalog
            ,L.CollationCompatible
            ,L.DataAccess
            ,L.Rpc
            ,L.RpcOut
            ,L.UseRemoteCollation
            ,L.CollationName
            ,L.ConnectionTimeout
            ,L.QueryTimeout 
            ,L.CreateDate
			,DATEDIFF(d, L.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN L.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM        dbo.DBMS                        AS S WITH (NOLOCK) 
                LEFT JOIN dbo.LinkedServers AS L WITH (NOLOCK) ON S.Id = L.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.[CollectInfo] = 1
  AND       S.[Type] = 'SQL Server'












GO
/****** Object:  View [dbo].[SQLLogShippingInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view  [dbo].[SQLLogShippingInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,B.[Source]
			,B.[SourceDBExist]
			,B.[PrimaryServer]
			,B.[PrimaryDatabase]
			,B.[SecondaryServer]
			,B.[SecondaryDatabase]
			,B.[MonitorServer]
			,B.[BackupDirectory]
			,B.[BackupShare]
			,B.[LastBackupFile]
			,B.[LastBackupDate]
			,B.[LastCopiedFile]
			,B.[LastCopiedDate]
			,B.[LastRestoredFile]
			,B.[LastRestoredDate]
			,B.[BackupRetentionPeriod]
			,B.[SQLTransBackupJob]
			,B.[SQLCopyJob]
			,B.[SQLRestoreJob]
			,B.[CreateDate]
			,DATEDIFF(d, B.CreateDate, GETDATE()) AS [Info_DaysOld]
FROM		[dbo].[DBMS]					        S WITH (NOLOCK)
				JOIN [dbo].[LogShippingInfo]	B WITH (NOLOCK)	ON S.Id = B.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'





GO
/****** Object:  View [dbo].[SQLReplicationInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view  [dbo].[SQLReplicationInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,B.[PublicationServer]
			,B.[PublicationDb]
			,B.[Publication]
			,B.[PublicationArticle]
			,B.[DestinationObject]
			,B.[SubscriptionServer]
			,B.[SubscriberDb]
			,B.[SubscriptionType]
			,B.[SubscriberLogin]
			,B.[SubscriberSecurityMode]
			,B.[DistributionAgentSQLJob]
			,B.[CreateDate]			
			,DATEDIFF(d, B.CreateDate, GETDATE()) AS [Info_DaysOld]
FROM		[dbo].[DBMS]					        S WITH (NOLOCK)
				JOIN [dbo].[ReplicationInfo]	B WITH (NOLOCK)	ON S.Id = B.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'














GO
/****** Object:  View [dbo].[SQLSecuritySummary]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[SQLSecuritySummary]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,T.[SecurityInfo]	AS [SecurityPrincipal]
			,T.[SecurityType]	AS [Type]
			,T.[DatabaseName]	
			,T.[ClassName]
			,T.[ObjectName]
			,T.[ObjectType]
			,T.[ColumnName]
			,T.[Permission]
			,T.[State]
			,T.[CreateDate]			
			,DATEDIFF(d, T.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN T.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]				    S WITH (NOLOCK)
				LEFT JOIN [SecuritySummary]	T WITH (NOLOCK)	ON S.Id = T.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.[CollectInfo] = 1
  AND       S.[Type] = 'SQL Server'











GO
/****** Object:  View [dbo].[SQLServerDBMSInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE view [dbo].[SQLServerDBMSInfo]
AS

SELECT      [Id]
            ,[Name]
            ,[Instance]
            ,[IPAddress]
            ,[Port]
			,[Name] +			
					CASE 
						WHEN [Instance] IS NULL THEN '' 
						WHEN [Instance] = 'Default' THEN ''
						WHEN [Instance] = 'MSSQLServer' THEN ''
						ELSE '\' + [Instance] 
					END + CASE WHEN LTRIM(ISNULL(Port, '')) = '' 
							THEN ''
							ELSE ',' + Port
						 END AS [SQLServerConnection]
			,[IPAddress] +
					CASE 
						WHEN [Instance] IS NULL THEN '' 
						WHEN [Instance] = 'Default' THEN ''
						WHEN [Instance] = 'MSSQLServer' THEN ''
						ELSE '\' + [Instance] 
					END + CASE WHEN LTRIM(ISNULL(Port, '')) = '' 
							THEN ''
							ELSE ',' + Port
						 END AS [SQLServerConnectionByIP] 			
            ,[Domain]
            ,[Environment]
            ,[HardwareType]
            ,[ServerType]
            ,[NamedPipesEnabled]
            ,[TcpIpEnabled]
            ,[DynamicPort]
            ,[StaticPort]
            ,[ForceProtocolEncryption]
            ,[SQLVersion]
            ,[SQLEdition]
            ,[SQLCollation]
            ,[SQLSortOrder]
            ,[RunningOnServer]
            ,[WindowsVersion]
            ,[Platform]
            ,[PhysicalCPU]
            ,[LogicalCPU]
            ,[PhysicalMemory]
            ,[DotNetVersion]
            ,[DBMailProfile]
            ,[AgentMailProfile]
            ,[LoginAuditLevel]
            ,[ServerNameProperty]
            ,[DateInstalled]
            ,[DateRemoved]
            ,[ApproxStartDate]
            ,[ProgramDirectory]
            ,[Path]
            ,[BinaryDirectory]
            ,[DefaultDataDirectory]
            ,[DefaultLogDirectory]
            ,[AbleToEmail]
            ,[SupportedBy]
            ,[TopologyActive]
            ,[TopologyKey]
            ,[CollectInfo]
            ,[Disable]
            ,[Notes]
            ,[CreatedBy]
            ,[CreateDate]
            ,[LastUpdate]           
			,DATEDIFF(d, [LastUpdate], GETDATE()) AS [Info_DaysOld]
FROM        [dbo].[DBMS]
WHERE       [Type] = 'SQL Server'










GO
/****** Object:  View [dbo].[SQLServerServers]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[SQLServerServers]
AS

SELECT		A.Id AS [DBMS_Id]
			,A.Name AS [SQLServer]
			,A.Instance
			,A.IPAddress 
			,A.Port
			,A.SQLVersion
			,A.SQLEdition
			,A.Domain
			,A.Environment
			,A.HardwareType			
			,A.ServerType
			,A.CollectInfo AS [SQLCollectInfo]
			,A.Disable AS [SQLDisable]
			,C.Id AS [Server_Id]
			,C.Name AS [Server]
			,C.IPAddress AS [ServerIP]
			,C.Location
			,C.Address
			,C.City
			,C.State
			,C.Floor
			,C.Grid
			,C.Manufactured
			,C.Model
			,C.PhysicalCPU
			,C.LogicalCPU
			,C.PhysicalMemory
			,C.WindowsVersion
			,C.Platform
			,C.CollectInfo AS [ServerCollectInfo]
			,C.Disable AS ServerDisable
FROM		dbo.DBMS A
				LEFT JOIN dbo.ServerDBMS B ON A.Id = B.DBMS_Id
				LEFT JOIN dbo.Server C ON B.Server_Id = C.Id
WHERE       A.Type = 'SQL Server'



GO
/****** Object:  View [dbo].[SQLServiceBrokerServicesInQueue]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SQLServiceBrokerServicesInQueue]
AS

-- SQL AGENT 
SELECT      'SQL Agent Running' AS [Service]
            ,COUNT(*)           AS [InQueue]
FROM        PentegraDataCollectorTargetMonitorDBMSSQLAgentRunningQueue
UNION ALL
-- SQL CONNECTION
SELECT      'SQL Connection'
            ,COUNT(*)
FROM        PentegraDataCollectorTargetMonitorDBMSSQLConnectionQueue
UNION ALL
-- SERVER PINGS
SELECT      'Server Pings'
            ,COUNT(*)
FROM        PentegraDataCollectorTargetMonitorServerPingQueue
UNION ALL                     
-- BACKUP SUMMARY
SELECT      'Backup Summary'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLBackupSummaryQueue
UNION ALL
-- DATABASE MIRRORING
SELECT      'Database Mirroring'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLDatabaseMirroringInfoQueue
UNION ALL
-- DATABASE OPTIONS
SELECT      'Database Options'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLDatabaseOptionsInfoQueue
UNION ALL
-- DATABASE SIZE
SELECT      'Database Size'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLDatabaseSizeInfoQueue
UNION ALL
-- DBMS
SELECT      'DBMS'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLDBMSInfoQueue
UNION ALL
-- DBMS CONFIGURATION
SELECT      'DBMS Configuration'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLDBMSConfigurationInfoQueue
UNION ALL
-- DRIVE SPACE
SELECT      'Drive Space'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLDriveInfoQueue
UNION ALL
-- GUARDIUM AUDIT REPORT
SELECT      'Guardium Audit Report'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLGuardiumAuditReportQueue
UNION ALL
-- JOB SCHEDULE INFO
SELECT      'Job Schedule'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLJobScheduleInfoQueue
UNION ALL
-- JOB SUMMARY
SELECT      'Job Summary'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLJobSummaryQueue
UNION ALL
-- LINKED SERVERS
SELECT      'Linked Servers'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLLinkedServerInfoQueue
UNION ALL
-- LOG SHIPPING
SELECT      'Log Shipping'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLLogShippingInfoQueue
UNION ALL
-- REPLICATION INFO
SELECT      'Replication Info'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLReplicationInfoQueue
UNION ALL
-- SECURITY SUMMARY
SELECT      'Security Summary'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLSecuritySummaryQueue
UNION ALL
-- SERVICES
SELECT      'Services'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLServicesInfoQueue
UNION ALL
-- TSM BACKUP SUMMARY
SELECT      'TSM Backup'
            ,COUNT(*) 
FROM        PentegraDataCollectorTargetSQLTSMBackupSummaryQueue



GO
/****** Object:  View [dbo].[SQLServicesInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[SQLServicesInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,B.[Name]				AS [ServiceName]
			,B.[DisplayName]		AS [DisplayName]
			,B.[BinaryPath]
			,B.[ServiceAccount]
			,B.[StartupType]
			,B.[Status]
			,B.[CreateDate]
			,DATEDIFF(d, B.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN B.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]					    S WITH (NOLOCK)
				LEFT JOIN [dbo].[Services]		B WITH (NOLOCK)	ON S.Id = B.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.[CollectInfo] = 1
  AND       S.[Type] = 'SQL Server'








GO
/****** Object:  View [dbo].[SQLTSMBackupSummaryInfo]    Script Date: 6/27/2015 4:22:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW  [dbo].[SQLTSMBackupSummaryInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,B.[LogFile]
			,B.[ScheduleName]
			,B.[ScheduleDate]
			,B.[StartDate]
			,B.[EndDate]
			,B.[BackupPaths]
			,B.[ObjectsInspected]
			,B.[ObjectsAssigned]
			,B.[ObjectsBackedUp]
			,B.[ObjectsUpdated]
			,B.[ObjectsRebound]
			,B.[ObjectsDeleted]
			,B.[ObjectsExpired]
			,B.[ObjectsFailed]
			,B.[SubfileObjects]
			,B.[BytesInspected]
			,B.[BytesTransferred]
			,B.[DataTransferTime]
			,B.[DataTransferRate]
			,B.[AggDataTransferRate]
			,B.[CompressPercentage]
			,B.[DataReductionRatio]
			,B.[SubfileObjectsReduceBy]
			,B.[ElapseProcessingTime]
			,B.[CreateDate]
			,DATEDIFF(d, B.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN B.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]				        S WITH (NOLOCK)
				LEFT JOIN [TSMBackupSummary]	B WITH (NOLOCK)	ON S.Id = B.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.[CollectInfo] = 1
  AND       S.[Type] = 'SQL Server'








GO
SET IDENTITY_INSERT [dbo].[Configuration] ON 

GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (28, N'AddServerInstanceInfo_Running', N'0', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (25, N'CollectBackupSummary_Running', N'0', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (24, N'CollectDatabaseInfo_Running', N'0', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (23, N'CollectDatabaseSizeInfo_Running', N'0', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (22, N'CollectDriveInfo_Running', N'0', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (33, N'CollectGuardiumAuditReport_Running', N'0', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (21, N'CollectJobScheduleInfo_Running', N'0', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (20, N'CollectJobSummary_Running', N'0', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (19, N'CollectLinkedServerInfo_Running', N'0', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (18, N'CollectScheduleTaskInfo_Running', N'0', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (17, N'CollectSecuritySummary_Running', N'0', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (16, N'CollectServericesInfo_Running', N'1', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (27, N'CollectServerInfo_Running', N'0', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (34, N'EmailMonitorAlertsTo', N'it_infra@pentegra.com', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (30, N'Name', N'Data', N'Notes')
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (11, N'SchTaskFmtFile', N'schtaskdatainfo.fmt', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (1, N'ScriptPath', N'E:\Data_Collector\SQLScripts', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (5, N'SQLBackupSummaryScript', N'SQLBackupSummary.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (12, N'SQLDatabaseInfoScript', N'SQLDatabaseInfo.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (9, N'SQLDatabaseSizeInfoScript', N'SQLDatabaseSizeInfo.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (10, N'SQLDatabaseSizeInfoScript_v7', N'SQLDatabaseSizeInfo_v7.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (14, N'SQLDriveInfoScript', N'SQLDriveInfo.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (7, N'SQLJobScheduleInfoScript', N'SQLJobScheduleSummary.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (8, N'SQLJobScheduleInfoScript_v8', N'SQLJobScheduleSummary_v8.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (6, N'SQLJobSummaryScript', N'SQLJobSummary.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (4, N'SQLLinkedServerInfoScript', N'SQLLinkedServerInfo.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (13, N'SQLSecuritySummaryScript', N'SQLSecuritySummary.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (15, N'SQLSecuritySummaryScript_v8', N'SQLSecuritySummary_v8.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (2, N'SQLServerInfoScript', N'SQLServerInfo.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (29, N'SQLServerInstanceInfoScript', N'SQLServerInstanceInfo.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (3, N'SQLServiceInfoScript', N'SQLServicesInfo.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (35, N'GenerateSQLjobinfo', N'Script_all_jobs.sql', N'0xFDAB4568C4FC7BF3606C877AB313009C80F389E4')
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (36, N'GenerateUserpermissionsinfo', N'Databasepermissions.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (37, N'GenerateDRReport', N'DR_Report.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (38, N'GenerateMailProfilesReport', N'Scriptout_Mail_Profiles.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (39, N'Disk_Space', N'Disk_Space.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (40, N'GenerateInstanceConfiguration', N'InstanceConfigurationoptions.sql', NULL)
GO
INSERT [dbo].[Configuration] ([Id], [Name], [Data], [Notes]) VALUES (41, N'SQLServerDiskSpaceinfo', N'SQLServerDiskSpaceinfo.sql', NULL)
GO
SET IDENTITY_INSERT [dbo].[Configuration] OFF
GO
SET IDENTITY_INSERT [dbo].[DBMS] ON 

GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (3, N'SQL Server', N'qadcssql', N'default', N'10.7.8.204', NULL, N'pentegra.nt', NULL, N'V', N'S', 0, 1, NULL, N'1433', 0, N'9.00.5000.00', N'Standard Edition', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'QADCSSQL', N'6.1 (7601)', N'NT INTEL X86', 2, 4, 8192, N'4.0.0.0', N'Administrator', N'DBA_Mail_Profile', N'Failed', N'QADCSSQL', CAST(0x0000A35400000000 AS DateTime), NULL, CAST(0x0000A49E017773EE AS DateTime), N'd:\Program Files (x86)\Microsoft SQL Server\', N'd:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\', N'd:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\Binn', N'd:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', N'd:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, 1, N'pentegra.nt', N'10.7.8.204', 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46C008A2B66 AS DateTime), CAST(0x0000A4A30062E568 AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (4, N'SQL Server', N'dcssql', N'default', N'10.7.7.33', NULL, N'pentegra.nt', NULL, N'P', N'S', 0, 1, NULL, N'1433', 0, N'9.00.3068.00', N'Standard Edition', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'DCSSQL', N'5.2 (3790)', N'NT INTEL X86', 2, 8, 4095, N'4.0.30319', N'DCSSQL', N'DCSSQL', N'Failed', N'DCSSQL', CAST(0x00009AE600000000 AS DateTime), NULL, CAST(0x0000A48F00BFF8E2 AS DateTime), N'C:\Program Files\Microsoft SQL Server\', N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\', N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Binn', N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, 1, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46C00A7B7D9 AS DateTime), CAST(0x0000A4A30062FA78 AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (5, N'SQL Server', N'DCSSQL2009', N'default', N'10.7.7.28', NULL, N'pentegra.nt', NULL, N'P', N'S', 0, 1, NULL, N'1433', 0, N'9.00.3042.00', N'Enterprise Edition (64-bit)', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'DCSSQL2009', N'6.0 (6002)', N'NT AMD64', 2, 16, 32757, N'4.0.0.0', N'Activity Tracking', N'', N'Failed', N'DCSSQL2009', CAST(0x00009C7800000000 AS DateTime), NULL, CAST(0x0000A3D7015A8B61 AS DateTime), N'C:\Program Files\Microsoft SQL Server\', N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\', N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Binn', N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, 1, N'pentegra.nt', N'10.7.7.169', 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46C00A7B7D9 AS DateTime), CAST(0x0000A4A30062E932 AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (6, N'SQL Server', N'DEVPENSPSQL1', N'default', N'10.7.8.163', NULL, N'pentegra.nt', NULL, N'V', N'S', 0, 1, NULL, N'1433', 0, N'11.0.2100.60', N'Standard Edition (64-bit)', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'DEVPENSPSQL1', N'6.2 (9200)', N'NT x64', 4, 4, 16384, N'4.0.0.0', N'', N'DBA_Mail_Profile', N'Failed', N'PENSPSQL2015', CAST(0x0000A3FF00000000 AS DateTime), NULL, CAST(0x0000A480007860B4 AS DateTime), N'E:\SPDev\', N'E:\SPDev\MSSQL11.MSSQLSERVER\MSSQL\', N'E:\SPDev\MSSQL11.MSSQLSERVER\MSSQL\Binn', N'E:\SPDev\MSSQL11.MSSQLSERVER\MSSQL\DATA\', N'E:\SPDev\MSSQL11.MSSQLSERVER\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, 1, N'pentegra.nt', N'10.7.8.163', 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46C00A7B7D9 AS DateTime), CAST(0x0000A4A30062EF2C AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (7, N'SQL Server', N'PENSPSQL1', N'default', N'10.7.7.105', NULL, N'pentegra.nt', NULL, N'V', N'S', 0, 1, NULL, N'1433', 0, N'11.0.2100.60', N'Standard Edition (64-bit)', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'PENSPSQL1', N'6.2 (9200)', N'NT x64', 4, 4, 16384, N'4.0.0.0', N'', N'', N'Failed', N'PENSPSQL1', CAST(0x0000A41100000000 AS DateTime), NULL, CAST(0x0000A43900A72620 AS DateTime), N'E:\Program Files\Microsoft SQL Server\', N'E:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\', N'E:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Binn', N'E:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\', N'E:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, 1, N'pentegra.nt', N'10.7.7.105', 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46C00A7B7D9 AS DateTime), CAST(0x0000A4A30062F4AB AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (8, N'SQL Server', N'PENSQL11', N'default', N'10.7.7.253', NULL, N'pentegra.nt', NULL, N'P', N'S', 0, 1, NULL, N'1433', 0, N'10.50.4000.0', N'Enterprise Edition (64-bit)', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'PENSQL11', N'6.1 (7601)', N'NT x64', 2, 24, 45046, N'4.0.0.0', N'ActivityTracking', N'ActivityTracking', N'Failed', N'PENSQL11', CAST(0x0000A29C00000000 AS DateTime), NULL, CAST(0x0000A48C00978C18 AS DateTime), N'C:\Program Files\Microsoft SQL Server\', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\Binn', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, 1, N'pentegra.nt', N'10.7.7.253', 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46C00A7B7D9 AS DateTime), CAST(0x0000A4A30062EFAE AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (9, N'SQL Server', N'PENSQL2012I', N'default', N'10.7.7.43', NULL, N'pentegra.nt', NULL, N'P', N'S', 0, 1, NULL, N'1433', 0, N'11.0.3000.0', N'Standard Edition (64-bit)', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'PENSQL2012I', N'6.2 (9200)', N'NT x64', 2, 32, 32733, N'4.0.0.0', N'', N'DBA_Mail_Profile', N'Failed', N'PENSQL2012I', CAST(0x0000A2D100000000 AS DateTime), NULL, CAST(0x0000A48A006D4571 AS DateTime), N'e:\Program Files\Microsoft SQL Server\', N'e:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\', N'e:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Binn', N'e:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\', N'e:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, 1, N'pentegra.nt', N'10.7.7.43', 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46C00A7B7D9 AS DateTime), CAST(0x0000A4A30062F037 AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (10, N'SQL Server', N'PENSQL2K8TEST', N'default', N'10.7.7.21', NULL, N'pentegra.nt', NULL, N'P', N'S', 0, 1, NULL, N'1433', 0, N'10.50.4000.0', N'Enterprise Edition (64-bit)', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'PENSQL2K8TEST', N'6.1 (7601)', N'NT x64', 2, 4, 8191, N'4.0.30319', N'', N'', N'Failed', N'PENSQL2K8TEST', CAST(0x0000A29B00000000 AS DateTime), NULL, CAST(0x0000A48C00A64B10 AS DateTime), N'C:\Program Files\Microsoft SQL Server\', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\Binn', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, 1, N'pentegra.nt', N'10.7.7.21', 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46C00A7B7D9 AS DateTime), CAST(0x0000A4A30062F126 AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (11, N'SQL Server', N'QA2PENSQL11', N'default', N'10.7.8.215', NULL, N'pentegra.nt', NULL, N'V', N'S', 0, 1, NULL, N'1433', 0, N'10.50.4000.0', N'Enterprise Edition (64-bit)', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'QA2PENSQL11', N'6.1 (7601)', N'NT x64', 2, 4, 16384, N'4.0.0.0', N'Activity Tracking', N'DBA_Mail_Profile', N'Failed', N'QAPENSQL11', CAST(0x0000A33400000000 AS DateTime), NULL, CAST(0x0000A49E017E5149 AS DateTime), N'C:\Program Files\Microsoft SQL Server\', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\Binn', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, 1, N'pentegra.nt', N'10.7.8.215', 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46C00A7B7D9 AS DateTime), CAST(0x0000A4A30062F201 AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (13, N'SQL Server', N'QADCSSQL2009', N'default', N'10.7.8.205', NULL, N'pentegra.nt', NULL, N'V', N'S', 0, 1, NULL, N'1433', 0, N'9.00.5000.00', N'Standard Edition', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'QADCSSQL2009', N'6.1 (7601)', N'NT INTEL X86', 2, 4, 8192, N'4.0.0.0', N'', N'DBA_Mail_Profile', N'Failed', N'QADCSSQL2009', CAST(0x0000A33400000000 AS DateTime), NULL, CAST(0x0000A49E01775C6E AS DateTime), N'C:\Program Files (x86)\Microsoft SQL Server\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\Binn', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, 1, N'pentegra.nt', N'10.7.8.205', 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46C00A7B7D9 AS DateTime), CAST(0x0000A4A30062F28E AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (14, N'SQL Server', N'QAPENSQL11', N'default', N'10.7.8.222', NULL, N'pentegra.nt', NULL, N'V', N'S', 0, 1, NULL, N'1433', 0, N'10.50.4000.0', N'Enterprise Edition (64-bit)', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'QAPENSQL11', N'6.1 (7601)', N'NT x64', 2, 4, 16384, N'4.0.0.0', N'Activity Tracking', N'', N'Failed', N'QAPENSQL11', CAST(0x0000A33400000000 AS DateTime), NULL, CAST(0x0000A49E017F9DF9 AS DateTime), N'C:\Program Files\Microsoft SQL Server\', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\Binn', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\', N'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, 1, N'pentegra.nt', N'10.7.8.222', 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46C00A7B7D9 AS DateTime), CAST(0x0000A4A30062F3A9 AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (15, N'SQL Server', N'QAPENSQL2012I', N'default', N'10.7.8.208', NULL, N'pentegra.nt', NULL, N'V', N'S', 0, 1, NULL, N'1433', 0, N'11.0.3128.0', N'Enterprise Edition (64-bit)', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'QAPENSQL2012I', N'6.2 (9200)', N'NT x64', 2, 4, 16384, N'4.0.0.0', N'Communicator', N'', N'Failed', N'QAPENSQL2012I', CAST(0x0000A34100000000 AS DateTime), NULL, CAST(0x0000A49E017A02AC AS DateTime), N'E:\SQL\', N'E:\SQL\MSSQL11.MSSQLSERVER\MSSQL\', N'E:\SQL\MSSQL11.MSSQLSERVER\MSSQL\Binn', N'E:\SQL\MSSQL11.MSSQLSERVER\MSSQL\DATA\', N'E:\SQL\MSSQL11.MSSQLSERVER\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, 1, N'pentegra.nt', N'10.7.8.208', 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46C00A7B7D9 AS DateTime), CAST(0x0000A4A30062F439 AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (16, N'SQL Server', N'SALT07', N'default', N'10.7.7.218', NULL, N'pentegra.nt', NULL, N'P', N'S', 0, 1, NULL, N'1433', 0, N'9.00.3073.00', N'Standard Edition', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'SALT07', N'5.2 (3790)', N'NT INTEL X86', 2, 4, 4095, N'3.5.30729.01', N'Salt07dbMailProfile', N'Salt07dbMailProfile', N'Failed', N'SALT07', CAST(0x00009B9400000000 AS DateTime), NULL, CAST(0x0000A48E0124A8C0 AS DateTime), N'C:\Program Files\Microsoft SQL Server\', N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\', N'C:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Binn', N'D:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\DATA', N'E:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\LOG', 0, NULL, NULL, NULL, 1, 1, N'pentegra.nt', N'10.7.7.218', 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46C00A7B7D9 AS DateTime), CAST(0x0000A4A30062F46E AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (17, N'SQL Server', N'SRTX64TEST', N'default', N'10.7.8.177', NULL, N'pentegra.nt', NULL, N'V', N'S', 0, 1, NULL, N'1433', 0, N'9.00.5000.00', N'Standard Edition', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'SRTX64TEST', N'6.1 (7601)', N'NT INTEL X86', 2, 4, 8192, N'4.0.0.0', N'IT_Operations', N'', N'Failed', N'SRTX64TEST', CAST(0x0000A30100000000 AS DateTime), NULL, CAST(0x0000A49B0036A5EE AS DateTime), N'C:\Program Files (x86)\Microsoft SQL Server\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\Binn', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, 1, N'pentegra.nt', N'10.7.8.177', 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46C00A7B7D9 AS DateTime), CAST(0x0000A4A30062F52B AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (21, N'SQL Server', N'DEVPENSQL2015I', N'default', N'10.7.8.179', NULL, N'pentegra.nt', NULL, N'V', N'S', 0, 1, NULL, N'1433', 0, N'12.0.2000.8', N'Enterprise Edition: Core-based Licensing (64-bit)', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'DEVPENSQL2015I', N'6.3 (9600)', N'NT x64', 1, 1, 12288, N'4.0.0.0', N'', N'', N'Failed', N'DEVPENSQL2015I', CAST(0x0000A48200000000 AS DateTime), NULL, CAST(0x0000A498013F6A6C AS DateTime), N'E:\SystemDatabases\Program Files\Microsoft SQL Server\', N'E:\SystemDatabases\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\', N'E:\SystemDatabases\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Binn', N'H:\DBASEDATA1\Data', N'I:\DBASELOG1\Log', 0, NULL, NULL, NULL, 1, 1, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A47900BC819A AS DateTime), CAST(0x0000A4A30062F519 AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (22, N'SQL Server', N'bkdcs3', N'default', N'10.4.0.39', NULL, N'pentegra.nt', NULL, N'P', N'S', 0, 1, NULL, N'1433', 0, N'9.00.5000.00', N'Standard Edition', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'DRBISDB1', N'6.1 (7601)', N'NT INTEL X86', 2, 4, 4095, N'4.0.0.0', N'', N'', N'Failed', N'DRBISDB1', CAST(0x0000A33F00000000 AS DateTime), NULL, CAST(0x0000A49B0115208D AS DateTime), N'C:\Program Files (x86)\Microsoft SQL Server\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\Binn', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, 1, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A484008C1A45 AS DateTime), CAST(0x0000A49C0062F05F AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (26, N'SQL Server', N'BkSalt2011', N'default', N'10.4.0.175', NULL, N'pentegra.nt', NULL, N'V', N'S', 0, 1, NULL, N'1433', 0, N'9.00.5000.00', N'Standard Edition', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'BKSALT2011', N'6.1 (7601)', N'NT INTEL X86', 2, 2, 8192, N'4.0.0.0', N'', N'', N'Failed', N'BKSALT2011', CAST(0x00009EB800000000 AS DateTime), NULL, CAST(0x0000A49B0124C2DC AS DateTime), N'C:\Program Files (x86)\Microsoft SQL Server\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\Binn', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A495010507FD AS DateTime), CAST(0x0000A4A30062F5ED AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (27, N'SQL Server', N'BkDCSSQL2011', N'default', N'10.4.0.171', NULL, N'pentegra.nt', NULL, N'V', N'S', 0, 1, NULL, N'1433', 0, N'9.00.5000.00', N'Standard Edition', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'BKDCSSQL2011', N'6.1 (7601)', N'NT INTEL X86', 3, 3, 12288, N'4.0.0.0', N'', N'', N'Failed', N'BKDCSSQL2011', CAST(0x00009EAA00000000 AS DateTime), NULL, CAST(0x0000A49B01267CAE AS DateTime), N'C:\Program Files (x86)\Microsoft SQL Server\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\Binn', N'D:\SQL', N'D:\SQL', 0, NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A4950105470A AS DateTime), CAST(0x0000A4A30062F5CB AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (28, N'SQL Server', N'DRPenSQL2012i', N'default', N'10.4.0.113', NULL, N'pentegra.nt', NULL, N'V', N'S', 0, 1, NULL, N'1433', 0, N'11.0.3153.0', N'Standard Edition (64-bit)', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'DRPENSQL2012I', N'6.2 (9200)', N'NT x64', 2, 2, 16384, N'4.0.0.0', N'', N'', N'Failed', N'DRPENSQL2012I', CAST(0x0000A39F00000000 AS DateTime), NULL, CAST(0x0000A49C00F96077 AS DateTime), N'C:\Program Files\Microsoft SQL Server\', N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\', N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Binn', N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\', N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A495010587F8 AS DateTime), CAST(0x0000A4A30062F662 AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (29, N'SQL Server', N'DRBisDB1', N'default', N'10.4.0.204', NULL, N'pentegra.nt', NULL, N'P', N'S', 0, 1, NULL, N'1433', 0, N'9.00.5000.00', N'Standard Edition', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'DRBISDB1', N'6.1 (7601)', N'NT INTEL X86', 2, 4, 4095, N'4.0.0.0', N'', N'', N'Failed', N'DRBISDB1', CAST(0x0000A33F00000000 AS DateTime), NULL, CAST(0x0000A49B0115208D AS DateTime), N'C:\Program Files (x86)\Microsoft SQL Server\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\Binn', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A4950105C953 AS DateTime), CAST(0x0000A4A30062F73D AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (30, N'SQL Server', N'bkbsp1', N'default', N'10.4.0.204', NULL, N'pentegra.nt', NULL, N'P', N'S', 0, 1, NULL, N'1433', 0, N'9.00.5000.00', N'Standard Edition', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'DRBISDB1', N'6.1 (7601)', N'NT INTEL X86', 2, 4, 4095, N'4.0.0.0', N'', N'', N'Failed', N'DRBISDB1', CAST(0x0000A33F00000000 AS DateTime), NULL, CAST(0x0000A49B0115208D AS DateTime), N'C:\Program Files (x86)\Microsoft SQL Server\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\Binn', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL.1\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A49501062470 AS DateTime), CAST(0x0000A4A30062F73D AS DateTime))
GO
INSERT [dbo].[DBMS] ([Id], [Type], [Name], [Instance], [IPAddress], [Port], [Domain], [Environment], [HardwareType], [ServerType], [NamedPipesEnabled], [TcpIpEnabled], [DynamicPort], [StaticPort], [ForceProtocolEncryption], [SQLVersion], [SQLEdition], [SQLCollation], [SQLSortOrder], [RunningOnServer], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DotNetVersion], [DBMailProfile], [AgentMailProfile], [LoginAuditLevel], [ServerNameProperty], [DateInstalled], [DateRemoved], [ApproxStartDate], [ProgramDirectory], [Path], [BinaryDirectory], [DefaultDataDirectory], [DefaultLogDirectory], [AbleToEmail], [SupportedBy], [TopologyActive], [TopologyKey], [CollectInfo], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (32, N'SQL Server', N'drpensql2012i', N'default', N'10.4.0.113', NULL, N'pentegra.nt', NULL, N'V', N'S', 0, 1, NULL, N'1433', 0, N'11.0.3153.0', N'Standard Edition (64-bit)', N'SQL_Latin1_General_CP1_CI_AS', N'nocase_iso', N'DRPENSQL2012I', N'6.2 (9200)', N'NT x64', 2, 2, 16384, N'4.0.0.0', N'', N'', N'Failed', N'DRPENSQL2012I', CAST(0x0000A39F00000000 AS DateTime), NULL, CAST(0x0000A49C00F96077 AS DateTime), N'C:\Program Files\Microsoft SQL Server\', N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\', N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Binn', N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\', N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\', 0, NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A4950106B6E8 AS DateTime), CAST(0x0000A4A30062F7EC AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[DBMS] OFF
GO
SET IDENTITY_INSERT [dbo].[FileHash] ON 

GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2056, N'E:\Data_Collector\SQLScripts\SQLServicesInfo.sql', 0x91A980612C2C9887581DC9FABCAF1F6B2925C136)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2057, N'E:\Data_Collector\SQLScripts\Databasepermissions.sql', 0xD7BA5A3BC02A401EA5305553676D783D6C519C16)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2058, N'E:\Data_Collector\SQLScripts\Script_all_jobs.sql', 0xFDAB4568C4FC7BF3606C877AB313009C80F389E4)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2059, N'E:\Data_Collector\SQLScripts\DR_Report.sql', 0x1998348DE149E0F3CF4919961D7EE09C76616B37)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2060, N'E:\Data_Collector\SQLScripts\DR_Report', 0xDA39A3EE5E6B4B0D3255BFEF95601890AFD80709)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2061, N'E:\Data_Collector\SQLScripts\Scriptout_Mail_Profiles.sql', 0x6DE0B9C2AAFC773A1FAACD1E6CE7463930365F8E)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2062, N'E:\Data_Collector\SQLScripts\Disk_Space.sql', 0x85CF75C5146E61774071BECE2659C049113725E3)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2063, N'E:\Data_Collector\SQLScripts\2000_GuardiumAudit.sql', 0xDA39A3EE5E6B4B0D3255BFEF95601890AFD80709)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2064, N'E:\Data_Collector\SQLScripts\2005_2008_GuardiumAudit.sql', 0xDA39A3EE5E6B4B0D3255BFEF95601890AFD80709)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2065, N'E:\Data_Collector\SQLScripts\InstanceConfigurationoptions.sql', 0xAD3DD00672CA228C8935E353C59E08DBBFADC587)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2066, N'E:\Data_Collector\SQLScripts\SQLServerDiskSpaceinfo.sql', 0x94614A0852FBE1C2D916A6D57321FE847F9A6E7A)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2067, N'E:\Data_Collector\SQLScripts\SQLServerInfo.sql', 0xB5BCC358F3ECAFC170813F0C428F128C1F3D2493)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2068, N'E:\Data_Collector\SQLScripts\SQLDriveInfo.sql', 0x966412989F9C1D3514243AEE2E0D203536F9EB78)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2069, N'E:\Data_Collector\SQLScripts\SQLDatabaseSizeInfo.sql', 0x65856B59398B1AFFC752ACFB6EF4558C50F3BB41)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2070, N'E:\Data_Collector\SQLScripts\SQLDatabaseSizeInfo_v7.sql', 0xDA39A3EE5E6B4B0D3255BFEF95601890AFD80709)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2071, N'E:\Data_Collector\SQLScripts\SQLLinkedServerInfo.sql', 0xE411E7E4B0DFE6EF732EE634B85BD8667E7ACB33)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2072, N'E:\Data_Collector\SQLScripts\SQLJobScheduleSummary_v8.sql', 0x962AB843970B70F8781245C253E904C7FA29B33C)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2073, N'E:\Data_Collector\SQLScripts\SQLBackupSummary.sql', 0xD2E58D5F96F27B4AA1DA3EDCC171D0A27412E84B)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2074, N'E:\Data_Collector\SQLScripts\SQLDatabaseInfo.sql', 0x0FEDDB3105918B64A60508DCCF8653BF5DBBC6AE)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2075, N'E:\Data_Collector\SQLScripts\SQLServerInstanceInfo.sql', 0xB6ED86DAAD5FCD26B80ADE70E2BCE845AC354B96)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2076, N'E:\Data_Collector\SQLScripts\SQLJobSummary.sql', 0x8AE928B06E055C27D12535C75EEE81B1F3161685)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2077, N'E:\Data_Collector\SQLScripts\SQLDatabaseInfo_v7.sql', 0xDA39A3EE5E6B4B0D3255BFEF95601890AFD80709)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2078, N'E:\Data_Collector\SQLScripts\SQLSecuritySummary_v8.sq', 0xDA39A3EE5E6B4B0D3255BFEF95601890AFD80709)
GO
INSERT [dbo].[FileHash] ([ID], [FilePath], [HashValue]) VALUES (2079, N'E:\Data_Collector\SQLScripts\SQLSecuritySummary_v8.sql', 0xFC118928324DAD2360C6B4B327D805E910C0EF60)
GO
SET IDENTITY_INSERT [dbo].[FileHash] OFF
GO
SET IDENTITY_INSERT [dbo].[Monitor] ON 

GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (1, N'qadcssql', NULL, 5, 60, 60, CAST(0x0000A476010D4EF8 AS DateTime))
GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (2, N'dcssql', NULL, 5, 60, 60, CAST(0x0000A476010D4EF8 AS DateTime))
GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (3, N'DCSSQL2009', NULL, 5, 60, 60, CAST(0x0000A476010D4EF8 AS DateTime))
GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (4, N'DEVPENSPSQL1', NULL, 5, 60, 60, CAST(0x0000A476010D4EF8 AS DateTime))
GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (5, N'PENSPSQL1', NULL, 5, 60, 60, CAST(0x0000A476010D4EF8 AS DateTime))
GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (6, N'PENSQL11', NULL, 5, 60, 60, CAST(0x0000A476010D4EF8 AS DateTime))
GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (7, N'PENSQL2012I', NULL, 5, 60, 60, CAST(0x0000A476010D4EF8 AS DateTime))
GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (8, N'PENSQL2K8TEST', NULL, 5, 60, 60, CAST(0x0000A476010D4EF8 AS DateTime))
GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (9, N'QA2PENSQL11', NULL, 5, 60, 60, CAST(0x0000A476010D4EF8 AS DateTime))
GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (10, N'QADCSSQL2009', NULL, 5, 60, 60, CAST(0x0000A476010D4EF8 AS DateTime))
GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (11, N'QAPENSQL11', NULL, 5, 60, 60, CAST(0x0000A476010D4EF8 AS DateTime))
GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (12, N'QAPENSQL2012I', NULL, 5, 60, 60, CAST(0x0000A476010D4EF8 AS DateTime))
GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (13, N'SALT07', NULL, 5, 60, 60, CAST(0x0000A476010D4EF8 AS DateTime))
GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (14, N'SRTX64TEST', NULL, 5, 60, 60, CAST(0x0000A476010D4EF8 AS DateTime))
GO
INSERT [dbo].[Monitor] ([Id], [Name], [Description], [Duration], [AlertThreshold], [AlertThresholdDelay], [CreateDate]) VALUES (15, N'bkdcs3', NULL, 5, 60, 60, CAST(0x0000A484008D4A46 AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Monitor] OFF
GO
SET IDENTITY_INSERT [dbo].[MonitorDBMSLog] ON 

GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (1, 3, 1, NULL, NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (2, 4, 2, NULL, NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (3, 5, 3, CAST(0x0000A4A60098FD37 AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (4, 6, 4, CAST(0x0000A4A600994358 AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (5, 7, 5, NULL, NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (6, 8, 6, NULL, NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (7, 9, 7, NULL, NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (8, 10, 8, NULL, NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (9, 11, 9, NULL, NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (10, 13, 10, NULL, NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (11, 14, 11, NULL, NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (12, 15, 12, NULL, NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (13, 16, 13, NULL, NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (14, 17, 14, NULL, NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
INSERT [dbo].[MonitorDBMSLog] ([Id], [DBMS_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (15, 22, 15, NULL, NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E42CB AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[MonitorDBMSLog] OFF
GO
SET IDENTITY_INSERT [dbo].[MonitorServerLog] ON 

GO
INSERT [dbo].[MonitorServerLog] ([Id], [Server_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (1, 1, 1, CAST(0x0000A4A600987129 AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E610A AS DateTime))
GO
INSERT [dbo].[MonitorServerLog] ([Id], [Server_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (3, 3, 3, CAST(0x0000A4A6009873B5 AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E610A AS DateTime))
GO
INSERT [dbo].[MonitorServerLog] ([Id], [Server_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (4, 4, 4, CAST(0x0000A4A6009874F7 AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E610A AS DateTime))
GO
INSERT [dbo].[MonitorServerLog] ([Id], [Server_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (5, 5, 5, CAST(0x0000A4A600987662 AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E610A AS DateTime))
GO
INSERT [dbo].[MonitorServerLog] ([Id], [Server_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (6, 6, 6, CAST(0x0000A4A600987663 AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E610A AS DateTime))
GO
INSERT [dbo].[MonitorServerLog] ([Id], [Server_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (7, 7, 7, CAST(0x0000A4A60098779D AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E610A AS DateTime))
GO
INSERT [dbo].[MonitorServerLog] ([Id], [Server_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (8, 8, 8, CAST(0x0000A4A6009877A0 AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E610A AS DateTime))
GO
INSERT [dbo].[MonitorServerLog] ([Id], [Server_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (9, 9, 9, CAST(0x0000A4A6009878DA AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E610A AS DateTime))
GO
INSERT [dbo].[MonitorServerLog] ([Id], [Server_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (10, 10, 10, CAST(0x0000A4A6009878DE AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E610A AS DateTime))
GO
INSERT [dbo].[MonitorServerLog] ([Id], [Server_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (11, 11, 11, CAST(0x0000A4A600987A23 AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E610A AS DateTime))
GO
INSERT [dbo].[MonitorServerLog] ([Id], [Server_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (12, 12, 12, CAST(0x0000A4A600987A23 AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E610A AS DateTime))
GO
INSERT [dbo].[MonitorServerLog] ([Id], [Server_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (13, 13, 13, CAST(0x0000A4A600987A2C AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E610A AS DateTime))
GO
INSERT [dbo].[MonitorServerLog] ([Id], [Server_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (14, 14, 14, CAST(0x0000A4A600987B5E AS DateTime), NULL, 0, NULL, 0, NULL, 0, NULL, CAST(0x0000A49D008E610A AS DateTime))
GO
INSERT [dbo].[MonitorServerLog] ([Id], [Server_Id], [Monitor_Id], [LastSuccess], [LastFailure], [RaiseAlert], [ThresholdDate], [ThresholdCount], [IgnoreAlertUntil], [Disable], [Notes], [CreateDate]) VALUES (15, 30, 15, CAST(0x0000A49D00EAE13A AS DateTime), CAST(0x0000A4A6009884BC AS DateTime), 2, CAST(0x0000A4A6009466B1 AS DateTime), 2, NULL, 0, NULL, CAST(0x0000A49D008E610A AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[MonitorServerLog] OFF
GO
SET IDENTITY_INSERT [dbo].[MonitorServerLogDetail] ON 

GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (1, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert will be raised on next failure', CAST(0x0000A49D00B1BFA3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (2, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised', CAST(0x0000A49D00B55B4A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (3, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D00B97A3C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (4, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D00BD984B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (5, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert will be raised on next failure', CAST(0x0000A49D00EF09FA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (6, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised', CAST(0x0000A49D00F32822 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (7, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D00F745B1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (8, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D00FB6597 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (9, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D00FF8326 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (10, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49D0103A1E4 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (11, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D0107C1CA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (12, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D010BE085 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (13, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D010FFE16 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (14, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49D01141D67 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (15, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D01183BEE AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (16, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D011C5C09 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (17, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D01207903 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (18, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49D01249860 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (19, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D0128B83C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (20, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D012CD5CC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (21, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D0130F487 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (22, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49D01351218 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (23, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D013931FE AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (24, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D013D50BA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (25, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D01416EDF AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (26, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A49D01458D06 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (27, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D0149AEB5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (28, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D014DCBB9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (29, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D0151ECBC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (30, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49D01560C5E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (31, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D015A2F32 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (32, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D015E456A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (33, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D016264BB AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (34, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49D01668309 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (35, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D016AA2CA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (36, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D016EC188 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (37, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D0172DF14 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (38, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49D017700B6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (39, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D017B2022 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (40, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D017F4001 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (41, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49D01835D75 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (42, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49D018778A1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (43, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E000015E6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (44, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00043381 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (45, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0008528F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (46, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A49E000C7221 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (47, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0010903E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (48, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0014B13C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (49, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0018CE4E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (50, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E001CF252 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (51, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00210B2B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (52, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00252CD5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (53, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0029480C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (54, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E002D66CA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (55, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00318588 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (56, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0035A3A9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (57, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0039C2FB AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (58, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E003DE123 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (59, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00420072 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (60, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00461F2E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (61, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E004A3D5C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (62, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E004E5B7A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (63, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00527A34 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (64, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00569A1C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (65, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E005AB841 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (66, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A49E005ED671 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (67, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0062F524 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (68, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00671474 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (69, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E006B3330 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (70, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E006F515F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (71, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00737011 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (72, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00778ECC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (73, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E007BAE1E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (74, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E007FCC45 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (75, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0083EB0B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (76, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0088099D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (77, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E008C283D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (78, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E0090477C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (79, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0094657E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (80, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0098841F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (81, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E009CA356 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (82, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E00A0C162 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (83, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00A4E097 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (84, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00A8FFCD AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (85, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00AD1E6E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (86, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A49E00B13C7A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (87, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00B55A83 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (88, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00B97A4F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (89, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00BD9986 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (90, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E00C1B95C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (91, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00C5D6CB AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (92, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00C9F4D1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (93, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00CE1408 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (94, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E00D232AA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (95, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00D651DF AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (96, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00DA6FE9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (97, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00DE8E8A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (98, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E00E2AD33 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (99, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00E6CD8D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (100, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00EAEA6D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (101, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00EF0877 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (102, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E00F327B6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (103, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00F745B8 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (104, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00FB6458 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (105, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E00FF8426 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (106, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A49E0103A271 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (107, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0107C0CF AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (108, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E010BE007 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (109, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E010FFE11 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (110, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E01141CC7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (111, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E01183C87 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (112, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E011C5A0C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (113, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0120795D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (114, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E0124978C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (115, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0128B63E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (116, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E012CD4FA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (117, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0130F3B6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (118, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E0135130D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (119, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0139312D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (120, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E013D4FE8 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (121, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E01416EA3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (122, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E01458D66 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (123, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0149AF9D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (124, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E014DCB6C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (125, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0151EABE AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (126, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A49E01560998 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (127, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E015A31C1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (128, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E015E4786 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (129, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E01626644 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (130, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E01668469 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (131, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E016AA6CF AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (132, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E016EC4E4 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (133, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E0172E698 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (134, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49E018360B3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (135, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49E018778D3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (136, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F000016A1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (137, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F0004339B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (138, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F00085653 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (139, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F000C7410 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (140, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F001095AB AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (141, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F0014B043 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (142, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F0018CD28 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (143, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F001CEBCF AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (144, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00210A7E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (145, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00252939 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (146, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A49F00294800 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (147, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F002D66AA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (148, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00318544 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (149, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F0035A515 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (150, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F0039C2AF AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (151, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F003DE162 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (152, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F0042000E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (153, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00461FE9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (154, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F004A3D7B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (155, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F004E5CCB AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (156, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00527AF0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (157, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00569AD8 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (158, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F005AB7D3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (159, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F005ED78A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (160, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F0062F6C0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (161, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00671434 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (162, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F006B3370 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (163, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F006F518F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (164, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00737063 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (165, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F0077905D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (166, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A49F007BAE72 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (167, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F007FCC96 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (168, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F0083EC28 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (169, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00880A7F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (170, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F008C28A6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (171, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00904760 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (172, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00946580 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (173, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F009884B3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (174, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F009CA372 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (175, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00A0C22B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (176, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00A4E051 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (177, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00A8FF8A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (178, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F00AD1E3B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (179, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00B13CFC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (180, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00B55BB0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (181, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00B97A6C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (182, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F00BD9992 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (183, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00C1B7A4 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (184, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00C5D660 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (185, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00C9F485 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (186, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A49F00CE12AD AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (187, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00D2316E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (188, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00D65021 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (189, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00DA6EDD AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (190, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F00DE8F62 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (191, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00E2AD3B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (192, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00E6CF5F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (193, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00EAEA95 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (194, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F00EF0829 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (195, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00F326E0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (196, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00F746C7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (197, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F00FB64ED AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (198, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F00FF8629 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (199, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F0103A2FA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (200, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F0107C04F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (201, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F010BE190 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (202, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F010FFE46 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (203, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F01141CFF AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (204, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F01183B24 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (205, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F011C5B0C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (206, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A49F01207933 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (207, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F012497ED AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (208, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F0128B86B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (209, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F012CD5C4 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (210, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F0130F4F4 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (211, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F01351324 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (212, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F013930B0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (213, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F013D5097 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (214, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F01417086 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (215, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F01458D79 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (216, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F0149ADFA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (217, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F014DCAF0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (218, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F0151EB43 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (219, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F01560D6E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (220, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F015A2C36 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (221, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F015E4A3E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (222, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F016266E2 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (223, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F01668431 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (224, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F016AAB86 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (225, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F016EC6CC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (226, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A49F0172E33A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (227, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F01770289 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (228, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F017B1FE6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (229, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F017F3CDA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (230, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A49F01835B3C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (231, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A49F0187788F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (232, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A00000170E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (233, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000043407 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (234, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A00008540B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (235, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0000C717D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (236, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0001090A0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (237, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A00014AEA3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (238, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A00018CDEB AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (239, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0001CEB73 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (240, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000210B72 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (241, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000252981 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (242, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A0002947B0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (243, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0002D678D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (244, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A00031851D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (245, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A00035A3D8 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (246, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A00039C295 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (247, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0003DE150 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (248, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A00042000B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (249, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000461FF3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (250, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A0004A3D84 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (251, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0004E5C3D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (252, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000527AF9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (253, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000569A67 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (254, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A0005AB841 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (255, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0005ED859 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (256, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A00062F704 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (257, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0006713DC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (258, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A0006B3310 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (259, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0006F5119 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (260, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A00073717B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (261, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000778E5A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (262, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A0007BAE29 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (263, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0007FCB9C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (264, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A00083EBFE AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (265, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000880972 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (266, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A0008C2815 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (267, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A00090474A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (268, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0009465EA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (269, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A00098848B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (270, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A0009CA335 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (271, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000A0C1CC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (272, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000A4E15D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (273, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000A8FF06 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (274, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A000AD1DCF AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (275, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000B13DB5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (276, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000B55B45 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (277, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000B97A96 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (278, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A000BD982D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (279, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000C1B80D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (280, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000C5D633 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (281, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000C9F458 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (282, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A000CE1316 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (283, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000D231D0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (284, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000D65121 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (285, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000DA6FDC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (286, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A000DE8E06 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (287, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000E2ACBE AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (288, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000E6CC0F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (289, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000EAEACB AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (290, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A000EF098D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (291, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000F327BF AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (292, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000F74659 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (293, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A000FB65A4 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (294, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A000FF83D0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (295, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A00103A285 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (296, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A00107C1D7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (297, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0010BE092 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (298, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A0010FFFE4 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (299, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A001141D73 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (300, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A001183BA5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (301, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0011C5AEA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (302, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A001207917 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (303, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A001249862 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (304, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A00128B71C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (305, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0012CD543 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (306, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A00130F400 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (307, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A001351350 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (308, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A001393176 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (309, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0013D5054 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (310, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A001416F7B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (311, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A001458EAF AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (312, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A00149AD50 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (313, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0014DCBF1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (314, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A00151EB31 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (315, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A001560948 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (316, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0015A2EC5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (317, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0015E49F7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (318, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A001627F77 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (319, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A001668335 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (320, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0016AA1BF AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (321, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0016EC5B8 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (322, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A00172EB3D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (323, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A001770503 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (324, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0017B22F7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (325, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0017F3F0D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (326, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A001835B58 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (327, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A0018778EB AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (328, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A300001BA4 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (329, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300043639 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (330, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300085311 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (331, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3000C7373 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (332, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A30010918A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (333, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A30014AF88 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (334, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A30018CE28 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (335, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3001CEE65 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (336, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A300210C0B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (337, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300252ACA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (338, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300294985 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (339, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3002D6841 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (340, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A3003185E7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (341, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A30035A3F8 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (342, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A30039C348 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (343, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3003DE203 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (344, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A300420042 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (345, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300461F7A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (346, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3004A3F62 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (347, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3004E5FED AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (348, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A300527BB3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (349, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300569AB6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (350, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3005AB924 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (351, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3005ED7E0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (352, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A30062F7E9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (353, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3006714C1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (354, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3006B337C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (355, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3006F5238 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (356, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A3007372C2 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (357, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300779045 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (358, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3007BAF00 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (359, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3007FCDBC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (360, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A30083EC81 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (361, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300880AF1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (362, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3008C282D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (363, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3009046E8 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (364, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A3009465AC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (365, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300988465 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (366, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3009CA3B0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (367, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300A0C2DA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (368, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A300A4E09B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (369, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300A8FFE4 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (370, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300AD1E09 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (371, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300B13CC4 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (372, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A300B55C32 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (373, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300B97A98 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (374, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300BD98C4 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (375, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300C1B816 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (376, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A300C5D89C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (377, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300C9F594 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (378, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300CE1468 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (379, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300D2339A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (380, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A300D651C1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (381, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300DA6FE5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (382, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300DE8FCD AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (383, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300E2ACC6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (384, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A300E6CC1F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (385, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300EAEC95 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (386, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300EF0A25 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (387, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300F3271E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (388, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A300F7470C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (389, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300FB66EE AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (390, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A300FF85A9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (391, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A30103A2A3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (392, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A30107C1F9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (393, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3010BE026 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (394, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3010FFED5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (395, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A301141D91 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (396, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A301183C4E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (397, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3011C5B08 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (398, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3012079C3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (399, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A301249A41 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (400, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A30128B7D9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (401, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3012CD560 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (402, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A30130F385 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (403, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3013512D6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (404, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A301393404 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (405, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3013D5056 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (406, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A301416F0A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (407, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A301458DC5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (408, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A30149ADA0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (409, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3014DCCF2 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (410, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A30151ED53 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (411, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A301560DC2 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (412, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A3015A2ED7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (413, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3015E4648 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (414, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A301626528 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (415, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A30166841F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (416, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A3016AA70E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (417, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3016EC32F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (418, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A30172E39A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (419, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A30177024A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (420, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A3017B2332 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (421, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A3017F3C88 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (422, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A301835A83 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (423, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A301877923 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (424, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A400001539 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (425, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400043464 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (426, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A40008539B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (427, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4000C71A6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (428, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A4001090E3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (429, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A40014AF7C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (430, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A40018CE1D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (431, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4001CECBD AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (432, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A400210C90 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (433, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400252B2B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (434, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400294809 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (435, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4002D66AA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (436, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A4003185E7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (437, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A40035A3EB AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (438, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A40039C28B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (439, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4003DE12C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (440, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A40041FFDF AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (441, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4004620C5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (442, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4004A3D0E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (443, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4004E5BAE AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (444, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A400527A5A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (445, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400569A73 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (446, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4005AB8C7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (447, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4005ED66F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (448, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A40062F8EA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (449, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400671512 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (450, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4006B32A1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (451, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4006F51F3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (452, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A40073727C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (453, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400778F6F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (454, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4007BAD8F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (455, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4007FCCE1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (456, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A40083EB09 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (457, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400880A58 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (458, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4008C28DA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (459, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400904739 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (460, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A4009465FE AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (461, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4009884B0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (462, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4009CA36C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (463, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400A0C2BD AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (464, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A400A4E17B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (465, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400A90035 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (466, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400AD1E5A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (467, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400B13ED8 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (468, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A400B55BD9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (469, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400B97B23 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (470, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400BD98BB AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (471, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400C1B804 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (472, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A400C5D62B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (473, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400C9F4E5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (474, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400CE1309 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (475, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400D2325C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (476, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A400D6511F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (477, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400DA7083 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (478, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400DE8FBA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (479, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400E2ADE3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (480, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A400E6CC09 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (481, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400EAE9E1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (482, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400EF08DE AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (483, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400F32782 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (484, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A400F7474D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (485, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400FB658F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (486, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A400FF844A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (487, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A40103A3D5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (488, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A40107C12D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (489, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4010BE1A9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (490, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4010FFEA2 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (491, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A401141D5E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (492, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A401183CB1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (493, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4011C5D2D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (494, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A401207991 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (495, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4012498E2 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (496, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A40128B674 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (497, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4012CD659 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (498, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A40130F3E9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (499, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4013512A5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (500, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A401393163 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (501, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4013D5021 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (502, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A401416ED7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (503, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A401458E29 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (504, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A40149AFD5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (505, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4014DCB0A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (506, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A40151EBB3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (507, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A401560917 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (508, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A4015A30DC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (509, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4015E472A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (510, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4016265DF AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (511, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A401668405 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (512, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A4016AA950 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (513, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4016EC67F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (514, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A40172E45D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (515, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4017704A1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (516, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A4017B2530 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (517, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A4017F4920 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (518, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A401835FEA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (519, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A40187788B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (520, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A500001690 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (521, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5000433CC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (522, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A50008539D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (523, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5000C71A3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (524, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A5001090FE AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (525, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A50014B13C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (526, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A50018D237 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (527, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5001CED5B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (528, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A500210B5F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (529, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500252967 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (530, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A50029480A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (531, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5002D66A7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (532, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A5003185E4 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (533, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A50035A6D7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (534, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A50039C40F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (535, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5003DE382 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (536, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A50042006E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (537, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500461E6B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (538, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5004A3D0B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (539, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5004E5C42 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (540, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A500527B87 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (541, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500569A19 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (542, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5005AB8B9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (543, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5005ED7F0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (544, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A50062F56C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (545, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A50067149B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (546, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5006B333C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (547, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5006F51E1 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (548, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A500737172 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (549, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500779175 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (550, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5007BAE72 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (551, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5007FCC5F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (552, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A50083EA77 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (553, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500880B62 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (554, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5008C2894 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (555, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5009047A3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (556, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A500946665 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (557, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A50098851A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (558, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5009CA3D6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (559, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500A0C2BA AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (560, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A500A4E0BD AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (561, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500A8FEDC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (562, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500AD1D98 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (563, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500B13C54 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (564, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A500B55B16 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (565, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500B979CB AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (566, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500BD988F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (567, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500C1B87F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (568, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A500C5D5FF AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (569, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500C9F4B9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (570, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500CE1378 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (571, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500D2351F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (572, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A500D650F3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (573, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500DA6FA6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (574, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500DE8E63 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (575, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500E2ADB4 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (576, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A500E6D0A2 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (577, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500EAEA96 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (578, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500EF0A7D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (579, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500F3280C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (580, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A500F746D6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (581, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500FB64EE AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (582, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A500FF843F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (583, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A50103A2FB AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (584, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A50107C255 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (585, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5010BDFDC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (586, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5010FFE01 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (587, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A501141DE9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (588, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A501183C16 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (589, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5011C5A34 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (590, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A501207998 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (591, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5012498CC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (592, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A50128B64B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (593, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5012CD58E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (594, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A50130F3B4 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (595, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A501351305 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (596, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A5013931D0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (597, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5013D4FE7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (598, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A501416FCE AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (599, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A501458DF3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (600, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A50149AE8F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (601, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5014DCAD5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (602, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A50151EC86 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (603, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A501560D13 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (604, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A5015A2F36 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (605, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5015E46F3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (606, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A501626641 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (607, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5016684FC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (608, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A5016AA3F3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (609, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5016EC3F6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (610, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A50172E140 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (611, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A50177013C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (612, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A5017B1D91 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (613, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5017F49DD AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (614, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A5018360E5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (615, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A501877DF6 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (616, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A6000015F8 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (617, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A60004348E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (618, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6000853CE AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (619, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6000C7173 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (620, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A600108FEC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (621, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A60014AE50 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (622, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A60018D25B AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (623, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6001CED89 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (624, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A600210BDC AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (625, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A600252B00 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (626, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A600294926 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (627, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6002D67EB AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (628, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A6003187C5 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (629, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A60035A3F0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (630, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A60039C457 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (631, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6003DE12E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (632, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A60042006A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (633, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6004620C7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (634, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6004A3D18 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (635, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6004E5BC0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (636, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A600527B86 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (637, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A600569A1D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (638, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6005AB828 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (639, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6005ED75E AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (640, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A60062F69D AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (641, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A60067149F AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (642, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6006B343A AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (643, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6006F530C AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (644, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold delay has been met.', CAST(0x0000A4A600737085 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (645, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A600778F22 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (646, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6007BADC7 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (647, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6007FCC68 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (648, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A60083ECD0 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (649, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6008809A8 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (650, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6008C2BC9 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (651, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A600904652 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (652, 15, N'Alert', N'Failed to ping BKDCS3 (10.4.0.39), Alert has been raised.  Threshold has been met.', CAST(0x0000A4A6009466C3 AS DateTime))
GO
INSERT [dbo].[MonitorServerLogDetail] ([Id], [MonitorServerLog_Id], [Status], [Description], [CreateDate]) VALUES (653, 15, N'Warning', N'Failed to ping BKDCS3 (10.4.0.39), Alert has already been raised.  Waiting to alert again on next Threshold', CAST(0x0000A4A6009884BC AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[MonitorServerLogDetail] OFF
GO
SET IDENTITY_INSERT [dbo].[Server] ON 

GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (1, N'QADCSSQL', N'10.7.8.204', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'V', N'S', NULL, NULL, N'6.1 (7601)', N'NT INTEL X86', 2, 4, 8192, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A46800DF4582 AS DateTime), CAST(0x0000A4A30062E569 AS DateTime))
GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (3, N'DCSSQL2009', N'10.7.7.28', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'P', N'S', NULL, NULL, N'6.0 (6002)', N'NT AMD64', 2, 16, 32757, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, N'prod', N'PENTEGRA\VijahB1', CAST(0x0000A47600FF0E22 AS DateTime), CAST(0x0000A4A30062E933 AS DateTime))
GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (4, N'DEVPENSPSQL1', N'10.7.8.163', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'V', N'S', NULL, NULL, N'6.2 (9200)', N'NT x64', 4, 4, 16384, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A47600FF0E22 AS DateTime), CAST(0x0000A4A30062EF2C AS DateTime))
GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (5, N'PENSPSQL1', N'10.7.7.105', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'V', N'S', NULL, NULL, N'6.2 (9200)', N'NT x64', 4, 4, 16384, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, N'prod', N'PENTEGRA\VijahB1', CAST(0x0000A47600FF0E22 AS DateTime), CAST(0x0000A4A30062F4AB AS DateTime))
GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (6, N'penwpppsql01', N'10.7.7.253', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'P', N'S', NULL, NULL, N'6.1 (7601)', N'NT x64', 2, 24, 45046, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, N'prod', N'PENTEGRA\VijahB1', CAST(0x0000A47600FF0E22 AS DateTime), CAST(0x0000A4A30062EFAF AS DateTime))
GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (7, N'PENSQL2012I', N'10.7.7.43', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'P', N'S', NULL, NULL, N'6.2 (9200)', N'NT x64', 2, 32, 32733, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, N'prod', N'PENTEGRA\VijahB1', CAST(0x0000A47600FF0E22 AS DateTime), CAST(0x0000A4A30062F037 AS DateTime))
GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (8, N'PENSQL2K8TEST', N'10.7.7.21', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'P', N'S', NULL, NULL, N'6.1 (7601)', N'NT x64', 2, 4, 8191, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A47600FF0E22 AS DateTime), CAST(0x0000A4A30062F127 AS DateTime))
GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (9, N'QA2PENSQL11', N'10.7.8.215', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'V', N'S', NULL, NULL, N'6.1 (7601)', N'NT x64', 2, 4, 16384, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A47600FF0E22 AS DateTime), CAST(0x0000A4A30062F201 AS DateTime))
GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (10, N'QADCSSQL2009', N'10.7.8.205', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'V', N'S', NULL, NULL, N'6.1 (7601)', N'NT INTEL X86', 2, 4, 8192, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A47600FF0E22 AS DateTime), CAST(0x0000A4A30062F28E AS DateTime))
GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (11, N'QAPENSQL11', N'10.7.8.222', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'V', N'S', NULL, NULL, N'6.1 (7601)', N'NT x64', 2, 4, 16384, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A47600FF0E22 AS DateTime), CAST(0x0000A4A30062F3AA AS DateTime))
GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (12, N'QAPENSQL2012I', N'10.7.8.208', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'V', N'S', NULL, NULL, N'6.2 (9200)', N'NT x64', 2, 4, 16384, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A47600FF0E22 AS DateTime), CAST(0x0000A4A30062F43A AS DateTime))
GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (13, N'SALT07', N'10.7.7.218', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'P', N'S', NULL, NULL, N'5.2 (3790)', N'NT INTEL X86', 2, 4, 4095, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, N'prod', N'PENTEGRA\VijahB1', CAST(0x0000A47600FF0E22 AS DateTime), CAST(0x0000A4A30062F49D AS DateTime))
GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (14, N'SRTX64TEST', N'10.7.8.177', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'V', N'S', NULL, NULL, N'6.1 (7601)', N'NT INTEL X86', 2, 4, 8192, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A47600FF0E22 AS DateTime), CAST(0x0000A4A30062F52B AS DateTime))
GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (29, N'DEVPENSQL2015I', N'10.7.8.179', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'V', N'S', NULL, NULL, N'6.3 (9600)', N'NT x64', 1, 1, 12288, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A47900BE5990 AS DateTime), CAST(0x0000A4A30062F51A AS DateTime))
GO
INSERT [dbo].[Server] ([Id], [Name], [IPAddress], [Domain], [Location], [Address], [City], [State], [Floor], [Grid], [HardwareType], [ServerType], [Manufactured], [Model], [WindowsVersion], [Platform], [PhysicalCPU], [LogicalCPU], [PhysicalMemory], [DateInstalled], [DateRemoved], [CollectInfo], [TopologyActive], [SupportedBy], [PingByName], [PingDomainInfo], [PingIPInfo], [Disable], [Notes], [CreatedBy], [CreateDate], [LastUpdate]) VALUES (30, N'bkdcs3', N'10.4.0.39', N'pentegra.nt', NULL, NULL, NULL, NULL, NULL, NULL, N'P', N'S', NULL, NULL, N'6.1 (7601)', N'NT x64', 2, 4, 4095, NULL, NULL, 1, NULL, NULL, 1, NULL, NULL, 0, NULL, N'PENTEGRA\VijahB1', CAST(0x0000A484008C5B2D AS DateTime), CAST(0x0000A495009C08AA AS DateTime))
GO
SET IDENTITY_INSERT [dbo].[Server] OFF
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (1, 3)
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (3, 5)
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (4, 6)
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (5, 7)
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (6, 8)
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (7, 9)
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (8, 10)
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (9, 11)
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (10, 13)
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (11, 14)
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (12, 15)
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (13, 16)
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (14, 17)
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (29, 21)
GO
INSERT [dbo].[ServerDBMS] ([Server_Id], [DBMS_Id]) VALUES (30, 22)
GO
/****** Object:  Index [PK_Configuration]    Script Date: 6/27/2015 4:22:20 PM ******/
ALTER TABLE [dbo].[Configuration] ADD  CONSTRAINT [PK_Configuration] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [Index]
GO
/****** Object:  Index [PK_Monitor]    Script Date: 6/27/2015 4:22:20 PM ******/
ALTER TABLE [dbo].[Monitor] ADD  CONSTRAINT [PK_Monitor] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_MonitorServerLog]    Script Date: 6/27/2015 4:22:20 PM ******/
ALTER TABLE [dbo].[MonitorServerLog] ADD  CONSTRAINT [PK_MonitorServerLog] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_Type]  DEFAULT ('SQL Server') FOR [Type]
GO
ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_Instance]  DEFAULT ('Default') FOR [Instance]
GO
ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_HardwareType]  DEFAULT ('P') FOR [HardwareType]
GO
ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_ServerType]  DEFAULT ('S') FOR [ServerType]
GO
ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_AbleToEmail]  DEFAULT ((0)) FOR [AbleToEmail]
GO
ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_CollectInfo]  DEFAULT ((1)) FOR [CollectInfo]
GO
ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_Disable]  DEFAULT ((0)) FOR [Disable]
GO
ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_CreatedBy]  DEFAULT (suser_name()) FOR [CreatedBy]
GO
ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[DBMSConfigurationInfo] ADD  CONSTRAINT [DF_DBMSConfigurationInfo_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[Monitor] ADD  CONSTRAINT [DF_Monitor_Duration]  DEFAULT ((5)) FOR [Duration]
GO
ALTER TABLE [dbo].[Monitor] ADD  CONSTRAINT [DF_Monitor_AlertThreshold]  DEFAULT ((15)) FOR [AlertThreshold]
GO
ALTER TABLE [dbo].[Monitor] ADD  CONSTRAINT [DF_Monitor_AlertThresholdDelay]  DEFAULT ((180)) FOR [AlertThresholdDelay]
GO
ALTER TABLE [dbo].[Monitor] ADD  CONSTRAINT [DF_Monitor_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[MonitorDBMSLog] ADD  CONSTRAINT [DF_MonitorDBMSLog_RaiseAlert]  DEFAULT ((0)) FOR [RaiseAlert]
GO
ALTER TABLE [dbo].[MonitorDBMSLog] ADD  CONSTRAINT [DF_MonitorDBMSLog_ThresholdCount]  DEFAULT ((0)) FOR [ThresholdCount]
GO
ALTER TABLE [dbo].[MonitorDBMSLog] ADD  CONSTRAINT [DF_MonitorDBMSLog_Disable]  DEFAULT ((0)) FOR [Disable]
GO
ALTER TABLE [dbo].[MonitorDBMSLog] ADD  CONSTRAINT [DF_MonitorDBMSLog_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[MonitorDBMSLogDetail] ADD  CONSTRAINT [DF_MonitorDBMSLogDetail_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[MonitorServerLog] ADD  CONSTRAINT [DF_MonitorServerLog_RaiseAlert]  DEFAULT ((0)) FOR [RaiseAlert]
GO
ALTER TABLE [dbo].[MonitorServerLog] ADD  CONSTRAINT [DF_MonitorServerLog_ThresholdCount]  DEFAULT ((0)) FOR [ThresholdCount]
GO
ALTER TABLE [dbo].[MonitorServerLog] ADD  CONSTRAINT [DF_MonitorServerLog_Disable]  DEFAULT ((0)) FOR [Disable]
GO
ALTER TABLE [dbo].[MonitorServerLog] ADD  CONSTRAINT [DF_MonitorServerLog_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[MonitorServerLogDetail] ADD  CONSTRAINT [DF_MonitorServerLogDetail_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[Server] ADD  CONSTRAINT [DF_Server_HarwareType]  DEFAULT ('P') FOR [HardwareType]
GO
ALTER TABLE [dbo].[Server] ADD  CONSTRAINT [DF_Server_ServerType]  DEFAULT ('S') FOR [ServerType]
GO
ALTER TABLE [dbo].[Server] ADD  CONSTRAINT [DF_Server_CollectInfo]  DEFAULT ((1)) FOR [CollectInfo]
GO
ALTER TABLE [dbo].[Server] ADD  CONSTRAINT [DF_Server_Disable]  DEFAULT ((0)) FOR [Disable]
GO
ALTER TABLE [dbo].[Server] ADD  CONSTRAINT [DF_Server_CreatedBy]  DEFAULT (suser_name()) FOR [CreatedBy]
GO
ALTER TABLE [dbo].[Server] ADD  CONSTRAINT [DF_Server_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[DBMSConfigurationInfo]  WITH CHECK ADD  CONSTRAINT [FK_DBMSConfigurationInfo_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO
ALTER TABLE [dbo].[DBMSConfigurationInfo] CHECK CONSTRAINT [FK_DBMSConfigurationInfo_DBMS]
GO
ALTER TABLE [dbo].[MonitorDBMSLog]  WITH CHECK ADD  CONSTRAINT [FK_MonitorDBMSLog_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO
ALTER TABLE [dbo].[MonitorDBMSLog] CHECK CONSTRAINT [FK_MonitorDBMSLog_DBMS]
GO
ALTER TABLE [dbo].[MonitorDBMSLog]  WITH CHECK ADD  CONSTRAINT [FK_MonitorDBMSLog_Monitor] FOREIGN KEY([Monitor_Id])
REFERENCES [dbo].[Monitor] ([Id])
GO
ALTER TABLE [dbo].[MonitorDBMSLog] CHECK CONSTRAINT [FK_MonitorDBMSLog_Monitor]
GO
ALTER TABLE [dbo].[MonitorDBMSLogDetail]  WITH CHECK ADD  CONSTRAINT [FK_MonitorDBMSLogDetail_MonitorLog] FOREIGN KEY([MonitorDBMSLog_Id])
REFERENCES [dbo].[MonitorDBMSLog] ([Id])
GO
ALTER TABLE [dbo].[MonitorDBMSLogDetail] CHECK CONSTRAINT [FK_MonitorDBMSLogDetail_MonitorLog]
GO
ALTER TABLE [dbo].[MonitorServerLog]  WITH CHECK ADD  CONSTRAINT [FK_MonitorServerLog_Monitor] FOREIGN KEY([Monitor_Id])
REFERENCES [dbo].[Monitor] ([Id])
GO
ALTER TABLE [dbo].[MonitorServerLog] CHECK CONSTRAINT [FK_MonitorServerLog_Monitor]
GO
ALTER TABLE [dbo].[MonitorServerLog]  WITH CHECK ADD  CONSTRAINT [FK_MonitorServerLog_Server] FOREIGN KEY([Server_Id])
REFERENCES [dbo].[Server] ([Id])
GO
ALTER TABLE [dbo].[MonitorServerLog] CHECK CONSTRAINT [FK_MonitorServerLog_Server]
GO
ALTER TABLE [dbo].[MonitorServerLogDetail]  WITH CHECK ADD  CONSTRAINT [FK_MonitorServerLogDetail_MonitorLog] FOREIGN KEY([MonitorServerLog_Id])
REFERENCES [dbo].[MonitorServerLog] ([Id])
GO
ALTER TABLE [dbo].[MonitorServerLogDetail] CHECK CONSTRAINT [FK_MonitorServerLogDetail_MonitorLog]
GO
ALTER TABLE [dbo].[ServerDBMS]  WITH CHECK ADD  CONSTRAINT [FK_ServerDBMS_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO
ALTER TABLE [dbo].[ServerDBMS] CHECK CONSTRAINT [FK_ServerDBMS_DBMS]
GO
ALTER TABLE [dbo].[ServerDBMS]  WITH CHECK ADD  CONSTRAINT [FK_ServerDBMS_Server] FOREIGN KEY([Server_Id])
REFERENCES [dbo].[Server] ([Id])
GO
ALTER TABLE [dbo].[ServerDBMS] CHECK CONSTRAINT [FK_ServerDBMS_Server]
GO
ALTER TABLE [dbo].[DBMS]  WITH CHECK ADD  CONSTRAINT [CK_DBMS_Type] CHECK  (([Type]='SQL Server'))
GO
ALTER TABLE [dbo].[DBMS] CHECK CONSTRAINT [CK_DBMS_Type]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "S"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 20
         End
         Begin Table = "D"
            Begin Extent = 
               Top = 6
               Left = 282
               Bottom = 121
               Right = 448
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SQLDatabaseSizeInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SQLDatabaseSizeInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[35] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "S"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "J"
            Begin Extent = 
               Top = 6
               Left = 282
               Bottom = 121
               Right = 448
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SQLJobScheduleInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SQLJobScheduleInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "S"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "L"
            Begin Extent = 
               Top = 6
               Left = 282
               Bottom = 121
               Right = 459
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SQLLinkedServerInfo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SQLLinkedServerInfo'
GO
