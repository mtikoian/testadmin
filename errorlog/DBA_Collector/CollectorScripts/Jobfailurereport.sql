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
		
SET @Script = 'd:\SQLJobFailures.sql'
SET @OutputTo = 'd:\serverjobsa.out'

CREATE TABLE #ServerInfo
(
	ServerName		varchar(128)
	,SQLConnection	varchar(512)
)
INSERT INTO #ServerInfo VALUES ('dcssql','dcssql')
INSERT INTO #ServerInfo VALUES ('dcssql2009','dcssql2009')
INSERT INTO #ServerInfo VALUES ('pensql11','pensql11')
INSERT INTO #ServerInfo VALUES ('PenSQL2012i','PenSQL2012i')
INSERT INTO #ServerInfo VALUES ('Salt07','Salt07')
INSERT INTO #ServerInfo VALUES ('PenSPSQL1','PenSPSQL1')
INSERT INTO #ServerInfo VALUES ('QADCSSQL','QADCSSQL')
INSERT INTO #ServerInfo VALUES ('QADCSSQL2009','QADCSSQL2009')
INSERT INTO #ServerInfo VALUES ('QAPenSQL2012i','QAPenSQL2012i')
INSERT INTO #ServerInfo VALUES ('QA2PenSQL11','QA2PenSQL11')
INSERT INTO #ServerInfo VALUES ('QAPenSQL11','QAPenSQL11')
INSERT INTO #ServerInfo VALUES ('PenSQLAudit','PenSQLAudit')
INSERT INTO #ServerInfo VALUES ('DevPenSPSQL1','DevPenSPSQL1')
INSERT INTO #ServerInfo VALUES ('PenSQL2k8Test','PenSQL2k8Test')
INSERT INTO #ServerInfo VALUES ('SRTx64Test','SRTx64Test')
INSERT INTO #ServerInfo VALUES ('PenSQLAudit','PenSQLAudit')
--INSERT INTO #ServerInfo VALUES ('BkBSPWeb2011','BkBSPWeb2011')
INSERT INTO #ServerInfo VALUES ('BkDCSSQL2011','BkDCSSQL2011')
INSERT INTO #ServerInfo VALUES ('DRPenSQL2012i','DRPenSQL2012i')
INSERT INTO #ServerInfo VALUES ('BkSalt2011','BkSalt2011')
INSERT INTO #ServerInfo VALUES ('BkDCS3','BkDCS3')
INSERT INTO #ServerInfo VALUES ('DRBisDB1','DRBisDB1')
INSERT INTO #ServerInfo VALUES ('devpensql2015i','devpensql2015i')
INSERT INTO #ServerInfo VALUES ('bkbsp1','bkbsp1')
INSERT INTO #ServerInfo VALUES ('drpensql2012i','drpensql2012i')

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

	CREATE TABLE #jobfailure
		(
			Info		varchar(8000)
		)


SET @Cmd  = 'BULK INSERT #jobfailure ' +
												   'FROM ''' + @OutputTo + ''' ' + 
												   'WITH ' +
												   '( ' +
														'BATCHSIZE  = 5000 ' +
												   ') '

EXECUTE (@Cmd)
											DELETE 
											FROM		#jobfailure 
											WHERE		LTRIM(ISNULL(Info, '')) = '' 
											   OR		Info LIKE 'RegQueryValueEx() returned error 2%'
											   OR		Info LIKE 'RegOpenKeyEx() returned error 2%'
                              

SELECT		 LEFT(Info, CHARINDEX('<1>', Info) - 1)		AS Servername
														,SUBSTRING(
																	Info, 
																	CHARINDEX('<1>', Info) + 3, 
																	CHARINDEX('<2>', Info) - CHARINDEX('<1>', Info) - 3
																 )									AS SQLjobName
														,SUBSTRING(
																	Info, 
																	CHARINDEX('<2>', Info) + 3, 
																	CHARINDEX('<3>', Info) - CHARINDEX('<2>', Info) - 3
																 )		AS Rundate
														,SUBSTRING(
																		Info, 
																		CHARINDEX('<3>', Info) + 3, 
																		LEN(info)
																   )								AS [Message]							
														--,SUBSTRING(
														--			Info, 
														--			CHARINDEX('<3>', Info) + 3, 
														--			CHARINDEX('<4>', Info) - CHARINDEX('<3>', Info) - 3
														--		 )									AS [Message]
														--,SUBSTRING(
														--			Info, 
														--			CHARINDEX('<4>', Info) + 3, 
														--			CHARINDEX('<5>', Info) - CHARINDEX('<4>', Info) - 3
														--		 )						
														--		 			AS [BinaryPath]
														--,SUBSTRING(
														--			Info, 
														--			CHARINDEX('<5>', Info) + 3, 
														--			CHARINDEX('<6>', Info) - CHARINDEX('<5>', Info) - 3
														--		 )		
														--		 							AS servername
														--,SUBSTRING(
														--				Info, 
														--				CHARINDEX('<6>', Info) + 3, 
														--				LEN(info)
														--		   )								AS [Status]
											FROM		#jobfailure      

DROP TABLE #ServerInfo
DROP TABLE #jobfailure