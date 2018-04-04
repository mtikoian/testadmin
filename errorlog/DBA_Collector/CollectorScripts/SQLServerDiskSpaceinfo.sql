
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
		--WHERE drive IN (
		--		'A:'
		--		,'B:'
		--		,'C:'
		--		,'D:'
		--		)
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

	SELECT		drive + '<1>' + 
				ISNULL(CAST(Total_Space AS varchar(15)), '') + '<2>' +
				CAST(Free_Space AS varchar(15)) + '<3>' 
				--ISNULL(DI_Notes, '')
	FROM		#Temp_Mount_Volumes
	ORDER BY Drive
		--SELECT Convert(VARCHAR(25), drive) + CHAR(9) + 
		--	Convert(VARCHAR(15), Total_Space)  + CHAR(9) + 
		--	Convert(VARCHAR(15), Used_Space)  + CHAR(9) + 
		--	Convert(VARCHAR(15), Free_Space)  + CHAR(9) + 
		--	Drive_Status  + CHAR(9) + 
		--	@@servername AS [Server_Name]
		--FROM #Temp_Mount_Volumes
		--ORDER BY Drive;
	END;
END;