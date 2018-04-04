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
		
SET @Script = 'c:\SQLScripts\Insert_Metadata.sql'
SET @OutputTo = 'c:\SQLScripts\serverdbschema.out'

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
--INSERT INTO #ServerInfo VALUES ('PenSQLAudit','PenSQLAudit')
INSERT INTO #ServerInfo VALUES ('DevPenSPSQL1','DevPenSPSQL1')
INSERT INTO #ServerInfo VALUES ('PenSQL2k8Test','PenSQL2k8Test')
INSERT INTO #ServerInfo VALUES ('SRTx64Test','SRTx64Test')
--INSERT INTO #ServerInfo VALUES ('PenSQLAudit','PenSQLAudit')
--INSERT INTO #ServerInfo VALUES ('BkBSPWeb2011','BkBSPWeb2011')
--INSERT INTO #ServerInfo VALUES ('BkDCSSQL2011','BkDCSSQL2011')
--INSERT INTO #ServerInfo VALUES ('DRPenSQL2012i','DRPenSQL2012i')
--INSERT INTO #ServerInfo VALUES ('BkSalt2011','BkSalt2011')
--INSERT INTO #ServerInfo VALUES ('BkDCS3','BkDCS3')
--INSERT INTO #ServerInfo VALUES ('DRBisDB1','DRBisDB1')

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

create table #Results
( [Name]    varchar(128)
   ,[Instance] varchar(128)
   ,[IPAddress] varchar(25)
   )
--CREATE TABLE #Mount_Volumes (
	--ID INT IDENTITY(1, 1)
	--Drive VARCHAR(100)
	--,Total_Space VARCHAR(100)
	--,Used_Space VARCHAR(100)
	--,Free_Space VARCHAR(100)
	--,Drive_Status VARCHAR(20) DEFAULT 'OK'
	--,Server_Name VARCHAR(255)
	--);

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

SET @Cmd = 'BULK INSERT #Results '
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


		   SELECT @CMD
EXECUTE (@Cmd)

SELECT * FROM #Results                                     
insert into [dbo].[DBMS] ([Name]     
   ,[Instance]  
   ,[IPAddress])
select  [Name]     
   ,[Instance]  
   ,[IPAddress]  
   from
   #results

   where name not in (select name from dbms)
--DECLARE @Drive VARCHAR(100);
--DECLARE @CRITICAL INT;
--DECLARE @FREE VARCHAR(20);
--DECLARE @TOTAL1 VARCHAR(20);
--DECLARE @FREE_PER VARCHAR(20);
--DECLARE @CHART VARCHAR(2000);
--DECLARE @HTML VARCHAR(MAX);
--DECLARE @TITLE VARCHAR(100);
--DECLARE @HTMLTEMP VARCHAR(MAX)
--DECLARE @HEAD VARCHAR(100);
--DECLARE @PRIORITY VARCHAR(10);
--DECLARE @To VARCHAR(200)
--DECLARE @Server_Name VARCHAR(255)

----declare @DRIVE VARCHAR(100);
--SET @CRITICAL = 20
--SET @TITLE = 'DISK SPACE REPROT : ' + @@SERVERNAME
--SET @HTML = '<HTML><TITLE>' + @TITLE + '</TITLE> 
--<TABLE BORDER=0 CELLSPACING=0 CELLPADDING=2> 
-- <TR BGCOLOR=#0070C0 ALIGN=CENTER STYLE=''FONT-SIZE:8.0PT;FONT-FAMILY:"TAHOMA","SANS-SERIF";COLOR:WHITE''> 
--  <TD WIDTH=40><B>Drive</B></TD> 
--  <TD WIDTH=250><B>Total Drive Space</B></TD> 
--  <TD WIDTH=150><B>Free Drive Space</B></TD> 
--  <TD WIDTH=150><B>Server Name</B></TD> 
--  <TD WIDTH=150><B>Percentage Free</B></TD> 
--</TR>'

--DECLARE RECORDS CURSOR
--FOR
--SELECT CAST([Drive] AS VARCHAR(100)) AS 'Drive'
--	,CAST(Total_Space AS VARCHAR(255)) AS 'Total_Space'
--	,CAST(Free_Space AS VARCHAR(255)) AS 'Free_Space'
--	,CAST(Server_Name AS VARCHAR(255)) AS 'Server_Name'
--	,CONVERT(VARCHAR(2000), '<TABLE BORDER=0 ><TR><TD BORDER=0 BGCOLOR=' + CASE 
--			WHEN (cast([Free_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0)) * 100.0 < 10
--				THEN 'RED'
--			WHEN (cast([Free_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0)) * 100.0 > 70
--				THEN '66CC00'
--			ELSE '0033FF'
--			END + '><IMG SRC=''/GIFS/S.GIF'' WIDTH=' + cast(cast([Free_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0) * 100.0 AS CHAR(10))
--		--CAST(CAST((cast([Used_Space] as float )/(cast ([Total_Space] as float) *1.0))*100.0*2 AS INT) AS CHAR(10) )
--		+ ' HEIGHT=5></TD> 
--     <TD><FONT SIZE=1>' + cast(cast([Free_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0) * 100.0 AS CHAR(10)) + '%</FONT></TD></TR></TABLE>') AS 'CHART'
----CAST(CAST(((cast([free_Space] as float )*1.0))*100.0 AS INT) AS CHAR(10) )+'%</FONT></TD></TR></TABLE>') AS 'CHART'   
--FROM #Mount_Volumes
--ORDER BY server_name ASC

--OPEN RECORDS

--FETCH NEXT
--FROM RECORDS
--INTO @DRIVE
--	,@TOTAL1
--	,@FREE
--	,@Server_Name
--	,@CHART

--WHILE @@FETCH_STATUS = 0
--BEGIN
--	SET @HTMLTEMP = '<TR BORDER=0 BGCOLOR="#E8E8E8" STYLE=''FONT-SIZE:8.0PT;FONT-FAMILY:"TAHOMA","SANS-SERIF";COLOR:#0F243E''> 
--        <TD ALIGN = CENTER>' + @DRIVE + '</TD> 
--        <TD ALIGN=CENTER>' + @TOTAL1 + '</TD> 
--        <TD ALIGN=CENTER>' + @FREE + '</TD> 
--		<TD ALIGN=CENTER>' + @Server_Name + '</TD>
--        <TD  VALIGN=MIDDLE>' + @CHART + '</TD> 
--        </TR>'
--	SET @HTML = @HTML + @HTMLTEMP

--	FETCH NEXT
--	FROM RECORDS
--	INTO @DRIVE
--		,@TOTAL1
--		,@FREE
--		,@Server_Name
--		,@CHART
--END

--CLOSE RECORDS

--DEALLOCATE RECORDS

----SET @HTML = @HTML + '</TABLE><BR> 
----<P CLASS=MSONORMAL><SPAN STYLE=''FONT-SIZE:10.0PT;''COLOR:#1F497D''><B>THANKS,</B></SPAN></P> 
----<P CLASS=MSONORMAL><SPAN STYLE=''FONT-SIZE:10.0PT;''COLOR:#1F497D''><B>DBA TEAM</B></SPAN></P> 
----</HTML>' 
----PRINT  
--PRINT @HTML

--SET @head = 'Disk Space report from All SQL Servers'
---- : ' + @@servername


--IF EXISTS (
--		SELECT 1
--		FROM #Mount_Volumes
--		WHERE CAST((cast([Free_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0)) * 100.0 AS INT) <= @CRITICAL
--		)
--BEGIN
--	SET @PRIORITY = 'HIGH'

--	PRINT @head
--		exec msdb.dbo.sp_send_dbmail     
--		@profile_name = 'DBA_Mail_Profile',     
--		@recipients = 'IT_Infra@pentegra.com',    
--		@subject = @head, 
--		@importance =  @Priority,   
--		@body = @HTML,     
--		@body_format = 'HTML' 
--END
--ELSE
--BEGIN
--	PRINT ''
--END


DROP TABLE #ServerInfo
DROP TABLE #Results

--BULK INSERT #Results FROM "c:\SQLScripts\serverdbschema.out"    WITH    (        BATCHSIZE = 100        ,FIRSTROW = 1    ) 