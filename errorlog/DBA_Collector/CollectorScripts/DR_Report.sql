SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
   *******************************************************************************
    ENVIRONMENT:    SQL 2005,2008,2012,2014

	NAME:           GENERATEDRREPORT

    DESCRIPTION:    THIS PROCEDURE GENERATES A DR REPORT ABOUT THE CURRENT
                    SQL SERVER.  IT LIST THE FOLLOWING INFORMATION
                    
                        * SQL SERVER INFORMATION - SQL & WINDOW VERSION, 
                          DRIVE SPACE, EDITION, COLLATION, PATHS, ETC.
                        * SECURITY INFORMATION -  AUTHENTICATION, AUDIT LEVEL,
                          SERVICE ACCOUNT INFO
                        * NETWORK CONFIGURATIONS - WHAT PROTOCOLS ARE ENABLED
                          AND WHAT PORTS ARE USED
                        * ANY NON MS SHIPPED EXTENDED PROCS.  THIS IS TO MAKE
                          SURE IF THERE ARE DLLS THAT NEEDS TO BE MIGRATED
                        * DATABASE INFO - LOCATION AND FILE SIZE
                        * RESTORE INFORMATION - BASED ON THE LATEST FULL BACKUPS
                          THIS WILL LIST ALL THE RESTORE COMMANDS THAT IS NEEDED.
                    
    AUTHOR         DATE       VERSION  DESCRIPTION
    -------------- ---------- -------- ------------------------------------------
    VBANDI        04/08/2015 1.0      INITIAL CREATION
   *******************************************************************************
*/

SET NOCOUNT ON

DECLARE		@WindowsVerison			varchar(128)
			,@PhysicalCPUCount		tinyint
			,@LogicalCPUCount		smallint
			,@PhysicalMemory		int
			,@Drive					char(1)
			,@FreeSpace				int
			,@ApproxStartDate		datetime
			,@Value					nvarchar(1024)
			,@SQLPath				varchar(256)
			,@BackupPath			varchar(256)
			,@DefaultDataPath		varchar(256)
			,@DefaultLogPath		varchar(256)
			,@Command				nvarchar(4000)
			,@ReturnValue			int
			,@IPAddress				varchar(256)
			,@DetailDomainName		varchar(128)
			,@LoginMode				varchar(25)
			,@AuditLevel			varchar(25)
			,@Domain				varchar(128)
			,@Proxy					varchar(128)
			,@ServiceAccount		varchar(256)	
			,@Key					varchar(256)	
			,@NumValue				int
			,@DynamicPort			varchar(128)
			,@TCPPort				varchar(128)
			,@XP					varchar(128)
			,@DLL					varchar(256)
			,@Type					varchar(15)
			,@Logical				varchar(256)
			,@Physical				varchar(512)
			,@PriorDB				varchar(128)
			,@DbName				varchar(128)
			,@BackupFile			varchar(1024)
			,@FileSize				decimal(15, 5)
			,@PrevDbName			varchar(128)
			,@PrevType				varchar(15)
			,@SQL					varchar(2048)
			,@Move					varchar(1024)
			,@CrLF					char(2)
			,@BackupSetId			int
			,@BackupStart			datetime


PRINT REPLICATE('*', 80)
PRINT '*' + REPLICATE(' ', 78) + '*'
PRINT '*' + REPLICATE(' ', 35) + 'DR REPORT' + REPLICATE(' ', 34) + '*'
PRINT '*' + REPLICATE(' ', 26) + CONVERT(varchar(30), GETDATE(), 109) + REPLICATE(' ', 26) + '*'
PRINT '*' + REPLICATE(' ', 78) + '*'
PRINT REPLICATE('*', 80)
PRINT ''

			
CREATE TABLE #ServerInfo
(
	Id					int
	,Name				varchar(256)
	,InternalValue		int
	,Character_Value	varchar(2000)
)

INSERT INTO #ServerInfo
EXECUTE master.dbo.xp_msver 


SELECT		@WindowsVerison = ISNULL(Character_Value, '')
FROM		#ServerInfo
WHERE		Name = 'WindowsVersion'

SELECT  @PhysicalCPUCount = cpu_count / hyperthread_ratio 
FROM    sys.dm_os_sys_info WITH (NOLOCK);


SELECT  @LogicalCPUCount = cpu_count
FROM    sys.dm_os_sys_info WITH (NOLOCK);

SELECT		@PhysicalMemory = ISNULL(InternalValue, '')
FROM		#ServerInfo
WHERE		Name = 'PhysicalMemory'

SELECT		@ApproxStartDate = crdate
FROM		master.dbo.sysdatabases WITH (NOLOCK)
WHERE		name = 'tempdb'

PRINT  'BEGIN SQL SERVER INFORMATION' 
PRINT  '    Machine Name:       ' + CAST(ISNULL(SERVERPROPERTY('MachineName'), 'NULL') AS varchar(128))

SET @DetailDomainName = NULL

EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE'
							,'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
							,'Domain'
							,@DetailDomainName OUTPUT

PRINT  '    Domain:             ' +  ISNULL(@DetailDomainName, 'Unable to retrieve Domain Info')



PRINT ''
PRINT  '    Windows Version:    ' +  @WindowsVerison
PRINT  '    Physical CPU:       ' +  CAST(@PhysicalCPUCount AS varchar(128))
PRINT  '    Logical CPU:        ' +  CAST(@LogicalCPUCount AS varchar(128))
PRINT  '    Physical Memory:    ' +  CAST(@PhysicalMemory AS varchar(128))
PRINT '' 

CREATE TABLE #DriveInfo
(
	Drive		char(1)
	,FreeSpace	int
)

INSERT INTO #DriveInfo
EXECUTE sys.xp_fixeddrives

DECLARE CURSOR_DRIVES CURSOR FAST_FORWARD
FOR
	SELECT		Drive
				,FreeSpace
	FROM		#DriveInfo

OPEN CURSOR_DRIVES

FETCH NEXT FROM CURSOR_DRIVES
INTO @Drive, @FreeSpace

PRINT  '    Drives:          '

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT  '       ' + @Drive + ':               ' + CAST(@FreeSpace AS varchar(25)) + ' MB of Free Space'
	FETCH NEXT FROM CURSOR_DRIVES
	INTO @Drive, @FreeSpace
END

CLOSE CURSOR_DRIVES
DEALLOCATE CURSOR_DRIVES

DROP TABLE #DriveInfo

PRINT ''
PRINT '    SQL Server:         ' + CAST(ISNULL(SERVERPROPERTY('ServerName'), 'NULL') AS varchar(128))
PRINT '    Instance Name:      ' + CAST(ISNULL(SERVERPROPERTY('InstanceName'), 'Default') AS varchar(128))
PRINT '    Approx Start Date:  ' + CONVERT(varchar(35), @ApproxStartDate, 109)
PRINT '    SQL Edition:        ' + CAST(ISNULL(SERVERPROPERTY('Edition'), 'NULL') AS varchar(128))
PRINT '    Product Version:    ' + CAST(ISNULL(SERVERPROPERTY('ProductVersion'), 'NULL') AS varchar(128))
PRINT '    Product Level:      ' + CAST(ISNULL(SERVERPROPERTY('ProductLevel'), 'NULL') AS varchar(128))
PRINT '    Collation:          ' + CAST(ISNULL(SERVERPROPERTY('Collation'), 'NULL') AS varchar(128))
PRINT '    Character Set:      ' + CAST(ISNULL(SERVERPROPERTY('SqlCharSetName'), 'NULL') AS varchar(128))
PRINT '    Sort Order:         ' + CAST(ISNULL(SERVERPROPERTY('SqlSortOrderName'), 'NULL') AS varchar(128))
PRINT '    Is Clustered:       ' + CASE WHEN CAST(SERVERPROPERTY('IsClustered')AS varchar(128)) = 0 THEN 'No' ELSE 'Yes' END
PRINT '    Filestream:         ' + CASE CAST(SERVERPROPERTY('FilestreamConfiguredLevel') AS int) 
										WHEN 0 THEN '0 - Disabled'
										WHEN 1 THEN '*** 1 - Enabled (T-SQL Access)'
										WHEN 2 THEN '*** 2 - Enabled (T-SQL & Win32 Streaming Access)'
										ELSE '*** ' +  CAST(SERVERPROPERTY('FilestreamConfiguredLevel') AS varchar(25)) + ' - Unknown'
								   END
PRINT '' 

SET @Value = NULL

EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
										,'SOFTWARE\Microsoft\MSSQLServer\Setup\'
										,'FeatureList'
										,@Value OUTPUT
										,'no_output'
										
PRINT  '    Feature List:       ' + ISNULL(@Value, '')

PRINT '' 

SET @Value = NULL

EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
										,'SOFTWARE\Microsoft\MSSQLServer\Setup\'
										,'SQLProgramDir'
										,@Value OUTPUT
										,'no_output'
										
PRINT  '    SQL Program Dir:    ' + ISNULL(@Value, '')

SET @Value = NULL

EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
										,'SOFTWARE\Microsoft\MSSQLServer\Setup\'
										,'SQLPath'
										,@Value OUTPUT
										,'no_output'
										
PRINT  '    SQL Path:           ' + ISNULL(@Value, '')

SET @Value = NULL

EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
										,'SOFTWARE\Microsoft\MSSQLServer\Setup\'
										,'SQLBinRoot'
										,@Value OUTPUT
										,'no_output'
										
PRINT  '    SQL Binary Dir:     ' + ISNULL(@Value, '')

SET @Value = NULL

EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
										,'SOFTWARE\Microsoft\MSSQLServer\Setup\'
										,'SQLDataRoot'
										,@Value OUTPUT
										,'no_output'
										
PRINT  '    SQL Data Root:      ' + ISNULL(@Value, '')

SET @Value = NULL

EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
										,'SOFTWARE\Microsoft\MSSQLServer\Setup\'
										,'FullTextDefaultPath'
										,@Value OUTPUT
										,'no_output'
										
PRINT  '    FullText Def Path:  ' + ISNULL(@Value, '')

PRINT '' 

SET @SQLPath = NULL
SET @DefaultDataPath = NULL
SET @DefaultLogPath = NULL
SET @BackupPath = NULL

EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
									,N'SOFTWARE\Microsoft\MSSQLServer\Setup'
									,N'SQLPath'
									,@SQLPath OUTPUT


EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
									,N'Software\Microsoft\MSSQLServer\MSSQLServer'
									,N'BackupDirectory'
									,@BackupPath OUTPUT


EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
									,N'Software\Microsoft\MSSQLServer\MSSQLServer'
									,N'DefaultData'
									,@DefaultDataPath OUTPUT
									,NO_OUTPUT


EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
									,N'Software\Microsoft\MSSQLServer\MSSQLServer'
									,N'DefaultLog'
									,@DefaultLogPath OUTPUT
									,NO_OUTPUT

IF RIGHT(@SQLPath, 1) <> '\'
	SET @SQLPath = @SQLPath + '\'


SET @SQLPath = @SQLPath
SET @DefaultDataPath = ISNULL(@DefaultDataPath, @SQLPath + 'DATA\')
SET @DefaultLogPath = ISNULL(@DefaultLogPath, @SQLPath + 'DATA\')

PRINT  '    Backup Dir:         ' + @BackupPath
PRINT  '    Default Data Dir:   ' + @DefaultDataPath
PRINT  '    Default Log Dir:    ' + @DefaultLogPath


PRINT  'END SQL SERVER INFORMATION' 
PRINT ''

DROP TABLE #ServerInfo

-- SECURITY INFO
PRINT 'BEGIN SECURITY INFO '


CREATE TABLE #Info
(
	Name		varchar(128)
	,value		varchar(256)
)

INSERT INTO #Info
EXECUTE sys.xp_loginconfig

SELECT		@LoginMode = value
FROM		#Info 
WHERE		Name = 'login mode'

SELECT		@AuditLevel = value
FROM		#Info 
WHERE		Name = 'audit level'

SELECT		@Domain = value
FROM		#Info 
WHERE		Name = 'default domain'

DROP TABLE #Info 

PRINT '    Domain:             ' + @Domain
PRINT '    Authentication:     ' + @LoginMode
PRINT '    Audit Level:        ' + CASE @AuditLevel 
										WHEN 'none' THEN '*** ' 
										WHEN 'success' THEN '*** '
										ELSE ''
							       END + @AuditLevel

SELECT		@Proxy = credential_identity 
FROM		sys.credentials
WHERE		name = '##xp_cmdshell_proxy_account##'

PRINT '    Server Proxy:       ' + ISNULL(@Proxy, '')  

SET @ServiceAccount = NULL
SET @Key = 'SYSTEM\CurrentControlSet\Services\' + CASE WHEN UPPER(CAST(ISNULL(SERVERPROPERTY('InstanceName'), 'Default') AS varchar(128))) IN ('DEFAULT', 'MSSQLSERVER') THEN 'MSSQLSERVER' ELSE 'MSSQL$' + CAST(SERVERPROPERTY('InstanceName') AS varchar(128)) END

EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
							,@Key
							,N'ObjectName'
							,@ServiceAccount OUTPUT
							,'NO_OUTPUT'

PRINT '    SQL Service Acct:   ' + ISNULL(@ServiceAccount, '')  

SET @ServiceAccount = NULL
SET @Key = 'SYSTEM\CurrentControlSet\Services\' + CASE WHEN UPPER(CAST(ISNULL(SERVERPROPERTY('InstanceName'), 'Default') AS varchar(128))) IN ('DEFAULT', 'MSSQLSERVER') THEN 'SQLSERVERAGENT' ELSE 'SQLAgent$' + CAST(SERVERPROPERTY('InstanceName') AS varchar(128)) END

EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
							,@Key
							,N'ObjectName'
							,@ServiceAccount OUTPUT
							,'NO_OUTPUT'

PRINT '    SQL Agent Acct:     ' + ISNULL(@ServiceAccount, '')  


PRINT 'END SECURITY INFO '
PRINT ''

-- NETWORK CONFIGURATIONS 
PRINT 'BEGIN NETWORK CONFIGURATIONS '

SET @DynamicPort = NULL
SET @TCPPort = NULL

EXECUTE xp_instance_regread 'HKEY_LOCAL_MACHINE' 
							,'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IPAll\'
							,'TcpDynamicPorts'
							,@DynamicPort OUTPUT
							,'NO_OUTPUT'
 
EXECUTE xp_instance_regread 'HKEY_LOCAL_MACHINE'
							,'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IPAll\'
							,'TcpPort'
							,@TCPPort OUTPUT
							,'NO_OUTPUT'				

SET @NumValue = NULL

EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
							,N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\'
							,N'Enabled'
							,@Value OUTPUT
							,'NO_OUTPUT'

PRINT '    TCP/IP:             ' + CASE WHEN @NumValue = 0 THEN '*** Disabled' ELSE 'Enabled' END

IF ISNULL(@NumValue, 1) <> 0 
	BEGIN
		PRINT '        Static Port:    ' + ISNULL(@TCPPort, '') 
		PRINT '        Dynamic Port:   ' + CASE WHEN LTRIM(ISNULL(@DynamicPort, '')) = '' THEN '' ELSE '*** ' END + ISNULL(@DynamicPort, '') 
	END

SET @NumValue = NULL
	
EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
							,N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\'
							,N'ForceEncryption'
							,@NumValue OUTPUT
							,'NO_OUTPUT'

PRINT '    Force Protocol:     ' + CASE WHEN @NumValue = 0 THEN 'Disabled' ELSE 'Enabled' END
							
SET @NumValue = NULL

EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
							,N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Np\'
							,N'Enabled'
							,@NumValue OUTPUT
							,'NO_OUTPUT'

PRINT '    Named Pipes:        ' + CASE WHEN @NumValue = 1 THEN '*** Enabled' ELSE 'Disabled' END

SET @NumValue = NULL

EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
							,N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Sm\'
							,N'Enabled'
							,@NumValue OUTPUT
							,'NO_OUTPUT'

PRINT '    Shared Memory:      ' + CASE WHEN @NumValue = 1 THEN 'Enabled' ELSE '*** Disabled' END

SET @NumValue = NULL

EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
							,N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Via\'
							,N'Enabled'
							,@NumValue OUTPUT
							,'NO_OUTPUT'

PRINT '    VIA:                ' + CASE WHEN @NumValue = 1 THEN '*** Enabled' ELSE 'Disabled' END

PRINT 'END NETWORK CONFIGURATIONS '
PRINT ''

PRINT 'BEGIN NON MS SHIPPED PROCEDURES '
		
CREATE TABLE #XP_Info
(
	Name		varchar(128)
	,dll		varchar(256)
)

INSERT INTO #XP_Info
EXECUTE sp_helpextendedproc

DECLARE CURSOR_XP CURSOR FAST_FORWARD FOR
	SELECT		A.name
				,B.dll
	FROM		sys.all_objects A 
					JOIN #XP_Info B ON A.name = B.Name
	WHERE		A.type = 'X'
	  AND		A.is_ms_shipped = 0

OPEN CURSOR_XP

FETCH NEXT FROM CURSOR_XP
INTO @XP, @DLL

IF @@FETCH_STATUS <> 0
	PRINT '    No Extended Procedures Found'
ELSE
	BEGIN
		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT '    * ' + @XP + ' (' + @DLL + ')'	

			FETCH NEXT FROM CURSOR_XP
			INTO @XP, @DLL
		END
	END

CLOSE CURSOR_XP
DEALLOCATE CURSOR_XP

DROP TABLE #XP_Info
	
PRINT 'END NON MS SHIPPED EXTENDED PROCEDURES '
PRINT ''

-- DATABASE LOCATION INFO 
PRINT 'BEGIN DATABASE LOCATION INFO '

DECLARE CURSOR_DBFILES CURSOR FAST_FORWARD
FOR
	SELECT		A.name					AS [Database]
				,B.type_desc			AS [Type]
				,B.name					AS [LogicalName]
				,B.physical_name		AS [PhysicalName]
				,(B.Size * 8) /1024.0		AS [FileSize_MB]
	FROM		sys.databases				A WITH (NOLOCK)
					JOIN sys.master_files	B WITH (NOLOCK) ON A.database_id = B.database_id
	ORDER BY	A.name
				,B.type_desc DESC

OPEN CURSOR_DBFILES

FETCH NEXT FROM CURSOR_DBFILES
INTO @DbName, @Type, @Logical, @Physical, @FileSize

SET @PriorDB = ''

WHILE @@FETCH_STATUS = 0
BEGIN
	IF @PriorDB <> @DbName
		PRINT '    ' + QUOTENAME(@DbName)

	PRINT '        ' + @Type + ' - ' + @Logical + ' (' + @Physical + ' - ' + CAST(@FileSize AS varchar(25)) + ' MB)'

	SET @PriorDB = @DbName 

	FETCH NEXT FROM CURSOR_DBFILES
	INTO @DbName, @Type, @Logical, @Physical, @FileSize
END

CLOSE CURSOR_DBFILES
DEALLOCATE CURSOR_DBFILES

PRINT 'END DATABASE LOCATION INFO '
PRINT ''

SET @CrLf = CHAR(13) + CHAR(10)
		
DECLARE CURSOR_RESTORE CURSOR FAST_FORWARD
FOR
	WITH LatestFullBackup
	AS
	(
	SELECT		D.name AS database_name
				,F.physical_device_name 
				,S.backup_set_id
				,S.backup_start_date
				,S.checkpoint_lsn	
				,S.type		
	FROM		master.sys.databases				D
					JOIN msdb.dbo.backupset			S ON D.name				= S.database_name
					JOIN msdb.dbo.backupmediafamily	F ON S.media_set_id		= F.media_set_id
					JOIN (
							SELECT		D.name AS DbName
										,MAX(S.backup_start_date) AS backup_start_date
							FROM		master.sys.databases				D
											JOIN msdb.dbo.backupset			S ON D.name				= S.database_name
							WHERE		S.is_copy_only = 0
							  AND		S.backup_finish_date IS NOT NULL
							  AND		S.type = 'D'
							GROUP BY	D.name
						) LastFullBackup			ON S.database_name		= LastFullBackup.DbName
												   AND S.backup_start_date	= LastFullBackup.backup_start_date
	)
	SELECT		database_name
				,type	
				,physical_device_name
				,backup_set_id
				,backup_start_date
	FROM		LatestFullBackup
	UNION
	SELECT		A.database_name
				,A.type
				,C.physical_device_name
				,A.backup_set_id
				,A.backup_start_date
	FROM		msdb.dbo.backupset A
					JOIN LatestFullBackup B ON A.database_name		= B.database_name
										   AND A.database_backup_lsn = B.checkpoint_lsn
										   AND A.backup_start_date   >= B.backup_start_date																	
					JOIN msdb.dbo.backupmediafamily	C ON A.media_set_id		= C.media_set_id
	WHERE		A.type IN ('I', 'L')
	ORDER BY	database_name
				,backup_start_date			 

OPEN CURSOR_RESTORE

FETCH NEXT FROM CURSOR_RESTORE
INTO @DbName, @Type, @BackupFile, @BackupSetId, @BackupStart

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
					PRINT '-- ' + REPLICATE('*', 150)

					PRINT '-- FULL BEING RESTORED FOR DATABASE ' + UPPER(@DbName)
					
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
							PRINT '    -- DIFFERENTIAL BEING RESTORED FOR DATABASE ' + UPPER(@DbName)
							
							PRINT '    RESTORE DATABASE ' + QUOTENAME(@DbName) 
							PRINT '    FROM DISK = N''' + @BackupFile + ''''
							PRINT '    WITH'
							PRINT '            STATS = 10,'				
						END
					ELSE
						BEGIN		
							PRINT '    -- TRANSACTION LOG BEING RESTORED FOR DATABASE ' + UPPER(@DbName)
									
							PRINT '    RESTORE LOG ' + QUOTENAME(@DbName) 
							PRINT '    FROM DISK = N''' + @BackupFile + ''''
							PRINT '    WITH'
							PRINT '            STATS = 10,'									
						END
				END
																	
			FETCH NEXT FROM CURSOR_RESTORE
			INTO @DbName, @Type, @BackupFile, @BackupSetId, @BackupStart

			IF @PrevDbName <> ISNULL(@DbName, '') OR @Type = 'D' OR @@FETCH_STATUS <> 0
				BEGIN
					PRINT '            RECOVERY'	
					PRINT ''
					
					SET @PrevDbName = @DbName
				END
			ELSE
				BEGIN
					PRINT '            NORECOVERY'	
					PRINT ''
					
				END
		END
	END
	
CLOSE CURSOR_RESTORE
DEALLOCATE CURSOR_RESTORE