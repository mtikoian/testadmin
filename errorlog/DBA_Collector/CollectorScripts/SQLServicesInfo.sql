SET NOCOUNT ON

DECLARE @Instance						varchar(128)
		,@SQLVersion					varchar(20)
		,@ServiceName					varchar(128)
		,@ServiceInstanceName			varchar(256)
		,@ReturnCode					int
		,@StartupInfo					varchar(30)
		,@Key							varchar(256)
		,@DisplayName					varchar(256)
		,@BinaryPath					varchar(1024)
		,@ServiceAccount				varchar(256)
		,@StartupType					int
		,@SvcStatus						varchar(15)
	

SET @Instance = CAST(SERVERPROPERTY('InstanceName') AS varchar(128))
SET @SQLVersion = CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))
SET @SQLVersion = LEFT(@SQLVersion, PATINDEX('%.%', @SQLVersion))


CREATE TABLE #Services
(
	Name			varchar(128)
	,DefaultName	varchar(128)
	,InstanceName	varchar(128)
	,Versions		varchar(128)
)

CREATE TABLE #Report
(
		Services			varchar(256)	NULL
		,DisplayName		varchar(256)	NULL
		,ServiceAccount		varchar(256)	NULL
		,StartType			varchar(25)		NULL
		,BinaryPath			varchar(512)	NULL
		,Status				varchar(15)		NULL		
)	

CREATE TABLE #ServicesKeys
(
	KeyName		varchar(128)
)

CREATE TABLE #Status
(
    SvcStatus varchar(15)
)

INSERT INTO #ServicesKeys
EXECUTE xp_instance_regenumkeys N'HKEY_LOCAL_MACHINE', 'SYSTEM\CurrentControlSet\Services\'

INSERT INTO #Services VALUES ('SQL Service', 'MSSQLSERVER', 'MSSQL$<instance>', ';8.;9.;10.')
INSERT INTO #Services VALUES ('SQL Agent', 'SQLSERVERAGENT', 'SQLAgent$<instance>', ';8.;9.;10.')
INSERT INTO #Services VALUES ('Analysis Services', 'MSSQLServerOLAPService', 'MSOLAP$<instance>', ';8.;9.;10.')
INSERT INTO #Services VALUES ('Reporting Services', 'ReportServer', 'ReportServer$<instance>', ';8.;9.;10.') 
INSERT INTO #Services VALUES ('Integration Services', 'MsDtsServer', 'MsDtsServer', ';9.;10.')
INSERT INTO #Services VALUES ('Integration Services', 'MsDtsServer100', 'MsDtsServer100', ';10.')
INSERT INTO #Services VALUES ('SQL Browser', 'SQLBrowser', 'SQLBrowser', ';9.;10.')
INSERT INTO #Services VALUES ('Full Text Search Engine', 'MSSEARCH', 'MSSEARCH', ';8.')
INSERT INTO #Services VALUES ('Full Text Search Engine', 'MSFTESQL', 'MSFTESQL$<instance>', ';9.;10.') 
INSERT INTO #Services VALUES ('SQL Full-text Filter Daemon Launcher', 'MSSQLFDLauncher', 'MSSQLFDLauncher$<instance>', ';10.') 
INSERT INTO #Services VALUES ('SQL Server AD Helper', 'MSSQLServerADHelper', 'MSSQLServerADHelper', ';9.;10.')
INSERT INTO #Services VALUES ('SQL VSS Writer', 'SQLWriter', 'SQLWriter', ';9.;10.')				
INSERT INTO #Services VALUES ('Distributed Transaction Coordinator', 'MSDTC', 'MSDTC', ';8.;9.;10.')				
INSERT INTO #Services VALUES ('COM+ System Application', 'COMSysApp', 'COMSysApp', ';8.;9.;10.')				
INSERT INTO #Services VALUES ('Cluster Service', 'ClusSvc', 'ClusSvc', ';8.;9.;10.')				

DECLARE CURSOR_SERVICES CURSOR FAST_FORWARD
FOR
	SELECT		A.Name
				,CASE WHEN LTRIM(RTRIM(ISNULL(@Instance, ''))) = ''
						THEN A.DefaultName 
						ELSE REPLACE(A.InstanceName, '<instance>', @Instance)
				   END
	FROM		#Services A
					JOIN #ServicesKeys B ON CASE WHEN LTRIM(RTRIM(ISNULL(@Instance, ''))) = ''
												THEN UPPER(A.DefaultName)
												ELSE UPPER(REPLACE(A.InstanceName, '<instance>', @Instance))
											END = UPPER(B.KeyName)
	WHERE		Versions LIKE '%' + @SQLVersion + '%'
	UNION ALL
	SELECT		A.KeyName
				,A.KeyName
	FROM		#ServicesKeys A
	WHERE       UPPER(A.KeyName) LIKE 'KOQCOLL%'
	   OR       UPPER(A.KeyName) LIKE 'KOQAGENT%'
	   OR       UPPER(A.KeyName) LIKE 'TSM SCHEDULER SERVICE%'
	   OR       UPPER(A.KeyName) LIKE 'TSM CLIENT SCHEDULER%'
	ORDER BY	1

OPEN CURSOR_SERVICES

FETCH NEXT FROM CURSOR_SERVICES
INTO @ServiceName, @ServiceInstanceName

WHILE @@FETCH_STATUS = 0
BEGIN 		
	SET @Key = N'SYSTEM\CurrentControlSet\Services\' + @ServiceInstanceName
	
	SET @DisplayName = NULL
	SET @DisplayName = null
	SET @BinaryPath = NULL
	SET @ServiceAccount = null
	SET @StartupType = NULL
	
	EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
								,@Key
								,N'DisplayName'
								,@DisplayName OUTPUT

	
	EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
								,@Key
								,N'ImagePath'
								,@BinaryPath OUTPUT

	EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
								,@Key
								,N'ObjectName'
								,@ServiceAccount OUTPUT
								
	EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
								,@Key
								,N'Start' --case [StartupType] when (0) then 'Boot' (1) then 'System', (2) then 'Automatic' when (3) then 'Manual' when (4) then 'Disable'  end
								,@StartupType OUTPUT


	SET @StartupInfo = CASE @StartupType
							WHEN 0 THEN 'Boot'
							WHEN 1 THEN 'System'
							WHEN 2 THEN 'Automatic'
							WHEN 3 THEN 'Manual'
							WHEN 4 THEN 'Disabled'
							ELSE 'Unknown'
					   END

	INSERT INTO #Status 
	EXECUTE xp_servicecontrol 'Querystate', @ServiceInstanceName

	SELECT @SvcStatus = SvcStatus FROM #Status

	IF ISNULL(@DisplayName, '') <> ''
		INSERT INTO #Report 
		(
				Services
				,DisplayName
				,ServiceAccount
				,StartType
				,BinaryPath
				,Status
		)
		VALUES 
		(
				@ServiceInstanceName
				,@DisplayName
				,@ServiceAccount
				,@StartupInfo
				,@BinaryPath
				,@SvcStatus
		)

	FETCH NEXT FROM CURSOR_SERVICES
	INTO @ServiceName,  @ServiceInstanceName
END

CLOSE CURSOR_SERVICES
DEALLOCATE CURSOR_SERVICES

SELECT		ISNULL(Services, '') + '<1>' +
				ISNULL(DisplayName, '') + '<2>' + 
				ISNULL(ServiceAccount, '') + '<3>' + 
				ISNULL(StartType, '') + '<4>' +
				ISNULL(BinaryPath, '') + '<5>' + 
				ISNULL(Status, '')
FROM		#Report

DROP TABLE #Report
DROP TABLE #Services
DROP TABLE #ServicesKeys
DROP TABLE #Status