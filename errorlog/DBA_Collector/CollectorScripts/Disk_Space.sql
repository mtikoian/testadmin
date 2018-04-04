
--EXEC sp_configure 'xp_cmdshell', 1
----EXEC sp_configure 'show advanced options', 1
--reconfigure 
--GO
SET NOCOUNT ON;
GO

-- 	1.0 Insert Drive Info
IF OBJECT_ID('#Temp_Mount_Volumes') IS NOT NULL
BEGIN
	DROP TABLE #Temp_Mount_Volumes;
END;

--Create Temp Table to hold drive and Mount Point info
CREATE TABLE #Temp_Mount_Volumes (
	ID INT IDENTITY(1, 1)
	,Drive VARCHAR(100)
	,Total_Space VARCHAR(100)
	,Used_Space VARCHAR(100)
	,Free_Space VARCHAR(100)
	,Drive_Status VARCHAR(20) DEFAULT 'OK'
	,Server_Name VARCHAR(255)
	);

--Insert Drive and Mount Point Info
INSERT INTO #Temp_Mount_Volumes (Drive)
EXEC xp_cmdshell 'MOUNTVOL /L';
	--View it
	--SELECT * FROM #Temp_Mount_Volumes
	--	2.0 Clean up #Temp_Mount_Volumes table
GO

--Delete all rows that are drive info
DELETE
FROM [#Temp_Mount_Volumes]
WHERE [ID] <= '26'
	OR Drive LIKE '%\\?\%'
	OR Drive LIKE 'New volumes%'
	OR Drive LIKE 'volume,%'
	OR Drive LIKE '%***%'
	OR Drive IS NULL;
GO

--Remove blank Space from Drive
UPDATE #Temp_Mount_Volumes
SET Drive = LTRIM(RTRIM(Drive));

--Remove last '\' character
UPDATE #Temp_Mount_Volumes
SET Drive = Substring(Drive, 1, (LEN(Drive) - 1));

--Reset the ID Column
ALTER TABLE #Temp_Mount_Volumes

DROP COLUMN ID;

ALTER TABLE #Temp_Mount_Volumes ADD ID INT IDENTITY (
	1
	,1
	);
	--View it
	--SELECT * FROM #Temp_Mount_Volumes
	--	3.0 Insert Space info
GO

DECLARE @X INT;
DECLARE @Row_Count INT;
DECLARE @Drive VARCHAR(100);
DECLARE @cmd VARCHAR(1000);
DECLARE @Length VARCHAR(1000);
DECLARE @Total_Size VARCHAR(1000);
DECLARE @Free_Space VARCHAR(1000);
DECLARE @Version VARCHAR(100);
DECLARE @Server_Version VARCHAR(2000);

--Set counters
SET @X = 1;

SELECT @Row_Count = count(*)
FROM #Temp_Mount_Volumes;

--Add space info
WHILE @X <= @Row_Count
BEGIN
	IF OBJECT_ID('#Temp_Drive_info') IS NOT NULL
	BEGIN
		DROP TABLE #Temp_Drive_info;
	END;

	--Create Temp Table to hold drive and Mount Point info
	CREATE TABLE #Temp_Drive_info (
		ID INT IDENTITY(1, 1)
		,info VARCHAR(7000)
		);

	--Get Current Drive
	SELECT @Drive = Drive
	FROM [#Temp_Mount_Volumes]
	WHERE ID = @x;

	--PRINT @Drive
	SET @cmd = 'FSUTIL volume diskfree ' + @Drive;

	--Execute command to get drive info
	INSERT INTO #Temp_Drive_info (info)
	EXEC xp_cmdshell @cmd;

	--PRINT @cmd
	--Clean up rows
	UPDATE #Temp_Drive_info
	SET info = Substring(info, (CHARINDEX(':', info) + 1), LEN(info));

	--SELECT * FROM #Temp_Drive_info
	--Convert numbers to Giga Bytes
	UPDATE #Temp_Drive_info
	SET info = Round((CAST(info AS FLOAT) / 1073741824), 2)
	WHERE info LIKE '%[0-9]%';

	/*
	--Convert numbers to megabytes
	Update #Temp_Drive_info
	SET info = (CAST(info as float)/1048576)
	WHERE info Like '%[0-9]%'
	*/
	SELECT @Total_Size = info
	FROM #Temp_Drive_info
	WHERE ID = 2;

	SELECT @Free_Space = info
	FROM #Temp_Drive_info
	WHERE ID = 1;

	IF @Total_Size IS NOT NULL
	BEGIN
		--Update #Temp_Mount_Volumes with volume space info
		UPDATE [#Temp_Mount_Volumes]
		SET
			--Total_Size = CAST((SELECT info FROM #Temp_Drive_info WHERE ID = 2) AS float),
			--Free_Space = CAST((SELECT info FROM #Temp_Drive_info WHERE ID = 1) AS Float)
			Total_Space = @Total_Size
			,Free_Space = @Free_Space
		WHERE ID = @X;
	END;

	--SELECT * FROM #Temp_Drive_info
	DROP TABLE #Temp_Drive_info;

	--Increment Counter
	SET @X = @X + 1;
END;

--Delete all dives that aren't part of this server
--Delete all rows that are drive info
DELETE
FROM #Temp_Mount_Volumes
WHERE Total_Space IS NULL;

--Update #Temp_Mount_Volumes Mark drives that need checked
UPDATE #Temp_Mount_Volumes
SET Drive_Status = 'LOW ON SPACE'
WHERE convert(FLOAT, Free_Space) <= 30;

UPDATE #Temp_Mount_Volumes
SET Server_Name = @@servername

UPDATE #Temp_Mount_Volumes
SET Used_Space = cast(Total_Space AS FLOAT) - cast(Free_Space AS FLOAT)

SELECT @Version = 'Microsoft SQL Server  2000%';

SELECT @Server_Version = @@Version;

--Check for SQL Version
IF @Server_Version LIKE @Version
BEGIN
	SELECT Convert(VARCHAR(25), drive)  + CHAR(9) + 
		Convert(VARCHAR(15), Total_Space)  + CHAR(9) + 
		Convert(VARCHAR(15), Used_Space)  + CHAR(9) + 
		Convert(VARCHAR(15), Free_Space)  + CHAR(9) + 
		Drive_Status  + CHAR(9) + 
		@@servername AS [Server_Name]
	FROM #Temp_Mount_Volumes
	ORDER BY Drive;
END;
ELSE
BEGIN
	--Display for clustered instances
	IF (
			SELECT count(*)
			FROM sys.dm_io_cluster_shared_drives
			) > 0
	BEGIN
		SELECT Convert(VARCHAR(25), drive)  + CHAR(9) + 
			Convert(VARCHAR(15), Total_Space) + CHAR(9) + 
			Convert(VARCHAR(15), Used_Space)  + CHAR(9) + 
			Convert(VARCHAR(15), Free_Space)  + CHAR(9) + 
			Drive_Status  + CHAR(9) + 
			@@servername AS [Server_Name]
		FROM #Temp_Mount_Volumes
		WHERE drive IN (
				'A:'
				,'B:'
				,'C:'
				,'D:'
				)
		ORDER BY Drive

		SELECT Convert(VARCHAR(25), drive)  + CHAR(9) + 
			Convert(VARCHAR(15), Total_Space)  + CHAR(9) + 
			Convert(VARCHAR(15), Used_Space)  + CHAR(9) + 
			Convert(VARCHAR(15), Free_Space)  + CHAR(9) + 
			Drive_Status  + CHAR(9) + 
			@@servername AS [Server_Name]
		FROM #Temp_Mount_Volumes
			,sys.dm_io_cluster_shared_drives sys
		WHERE sys.DriveName = SUBSTRING(Convert(VARCHAR(25), drive), 1, 1)
		ORDER BY Drive;
	END;
	ELSE
		--Display for Stand Alones
	BEGIN
		SELECT Convert(VARCHAR(25), drive) + CHAR(9) + 
			Convert(VARCHAR(15), Total_Space)  + CHAR(9) + 
			Convert(VARCHAR(15), Used_Space)  + CHAR(9) + 
			Convert(VARCHAR(15), Free_Space)  + CHAR(9) + 
			Drive_Status  + CHAR(9) + 
			@@servername AS [Server_Name]
		FROM #Temp_Mount_Volumes
		ORDER BY Drive;
	END;
END;

--select * from #Temp_Mount_Volumes
--SELECT (cast([Free_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0)) * 100.0
--	,Convert(VARCHAR(50), 100 * round(cast([Free_Space] AS FLOAT), 2) / round(cast([Total_Space] AS FLOAT), 2)) AS er
--	,(cast([Used_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0)) * 100.0
--	,cast([Free_Space] AS FLOAT)
--	,cast(Total_Space AS FLOAT)
--	,(cast([Free_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0))
--	,(cast([Free_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0)) * 100.0
--	,Free_Space
--FROM #Temp_Mount_Volumes
--ORDER BY Drive;
--DROP TABLE #Temp_Mount_Volumes;
--DECLARE @CRITICAL INT;
--DECLARE @FREE VARCHAR(20);
--DECLARE @TOTAL VARCHAR(20);
--DECLARE @FREE_PER VARCHAR(20);
--DECLARE @CHART VARCHAR(2000);
--DECLARE @HTML VARCHAR(MAX);
--DECLARE @TITLE VARCHAR(100);
--DECLARE @HTMLTEMP VARCHAR(MAX)
--DECLARE @HEAD VARCHAR(100);
--DECLARE @PRIORITY VARCHAR(10);
--DECLARE @To VARCHAR(200)
--DECLARE @Server_Name VARCHAR(255)
--
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
--
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
--FROM #Temp_Mount_Volumes
--ORDER BY drive ASC
--
--OPEN RECORDS
--
--FETCH NEXT
--FROM RECORDS
--INTO @DRIVE
--	,@TOTAL
--	,@FREE
--	,@Server_Name
--	,@CHART
--
--WHILE @@FETCH_STATUS = 0
--BEGIN
--	SET @HTMLTEMP = '<TR BORDER=0 BGCOLOR="#E8E8E8" STYLE=''FONT-SIZE:8.0PT;FONT-FAMILY:"TAHOMA","SANS-SERIF";COLOR:#0F243E''> 
--        <TD ALIGN = CENTER>' + @DRIVE + '</TD> 
--        <TD ALIGN=CENTER>' + @TOTAL + '</TD> 
--        <TD ALIGN=CENTER>' + @FREE + '</TD> 
--		<TD ALIGN=CENTER>' + @Server_Name + '</TD>
--        <TD  VALIGN=MIDDLE>' + @CHART + '</TD> 
--        </TR>'
--	SET @HTML = @HTML + @HTMLTEMP
--
--	FETCH NEXT
--	FROM RECORDS
--	INTO @DRIVE
--		,@TOTAL
--		,@FREE
--		,@Server_Name
--		,@CHART
--END
--
--CLOSE RECORDS
--
--DEALLOCATE RECORDS
--
----SET @HTML = @HTML + '</TABLE><BR> 
----<P CLASS=MSONORMAL><SPAN STYLE=''FONT-SIZE:10.0PT;''COLOR:#1F497D''><B>THANKS,</B></SPAN></P> 
----<P CLASS=MSONORMAL><SPAN STYLE=''FONT-SIZE:10.0PT;''COLOR:#1F497D''><B>DBA TEAM</B></SPAN></P> 
----</HTML>' 
----PRINT  
--PRINT @HTML
--
--SET @head = 'Disk Space report from All SQL Servers'
---- : ' + @@servername
--
--
--IF EXISTS (
--		SELECT 1
--		FROM #Temp_Mount_Volumes
--		WHERE CAST((cast([Free_Space] AS FLOAT) / (cast([Total_Space] AS FLOAT) * 1.0)) * 100.0 AS INT) <= @CRITICAL
--		)
--BEGIN
--	SET @PRIORITY = 'HIGH'
--
--	PRINT @head
--		exec msdb.dbo.sp_send_dbmail     
--		@profile_name = 'DBA_Mail_Profile',     
--		@recipients = 'vbandi@pentegra.com',    
--		@subject = @head, 
--		@importance =  @Priority,   
--		@body = @HTML,     
--		@body_format = 'HTML' 
--END
--ELSE
--BEGIN
--	PRINT ''
--END

DROP TABLE #Temp_Mount_Volumes;

