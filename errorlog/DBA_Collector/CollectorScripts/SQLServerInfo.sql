SET NOCOUNT ON

DECLARE		@Platform					varchar(128)
			,@WindowsVerison			varchar(128)
			,@PhysicalMemory			int
			,@SortInfo					varchar(128)
			,@DynamicPort				varchar(128)
			,@StaticPort				varchar(128)
			,@TCPIP						int
			,@DBMailProfile				varchar(128)
			,@AgentMailProfile			varchar(128)
			,@LoginAudit				int
			,@ApproxStartDate			datetime
			,@PhysicalCPUCount			smallint
			,@LogicalCPUCount			smallint
			,@DetailDomainName			varchar(128)
			,@NamedPipes				bit
			,@Value						varchar(128)
			,@ForceProtocol				int
			,@StartPos					smallint
			,@EndPos					smallint
			,@Key						varchar(256)
			,@ProductCode				varchar(50)
			,@InstallDate				varchar(10)
			,@VMToolDisplayName			varchar(128)
			,@HardwareType				char(1)
			,@SQLProgramDirectory		varchar(256)
			,@SQLPath					varchar(256)
			,@SQLBinaryDirectory		varchar(256)
			,@DefaultDataDirectory		varchar(256)
			,@DefaultLogDirectory		varchar(256)
			,@DotNetVersion             varchar(128)
			,@SQLVersionMajor			varchar(10)
			
SET @SQLVersionMajor = LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), CHARINDEX('.', CAST(SERVERPROPERTY('ProductVersion') AS varchar(25))) - 1)
			
CREATE TABLE #ServerInfo
(
	Id					int
	,Name				varchar(256)
	,InternalValue		int
	,Character_Value	varchar(2000)
)

INSERT INTO #ServerInfo
EXECUTE master.dbo.xp_msver 

SELECT		@Platform = ISNULL(Character_Value, '')
FROM		#ServerInfo
WHERE		Name = 'Platform'

SELECT		@WindowsVerison = ISNULL(Character_Value, '')
FROM		#ServerInfo
WHERE		Name = 'WindowsVersion'

SELECT		@PhysicalMemory = ISNULL(InternalValue, '')
FROM		#ServerInfo
WHERE		Name = 'PhysicalMemory'

SELECT		@ApproxStartDate = crdate
FROM		master.dbo.sysdatabases
WHERE		name = 'tempdb'

SELECT		@PhysicalCPUCount = ISNULL(InternalValue, '')
FROM		#ServerInfo
WHERE		Name = 'ProcessorCount'

SET @LogicalCPUCount = @PhysicalCPUCount

			

SET @SQLPath = NULL

EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
										,'SOFTWARE\Microsoft\MSSQLServer\Setup\'
										,'SQLPath'
										,@SQLPath OUTPUT
										,'no_output'


SET @DefaultDataDirectory = NULL
SET @DefaultLogDirectory = NULL

EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
									,N'Software\Microsoft\MSSQLServer\MSSQLServer'
									,N'DefaultData'
									,@DefaultDataDirectory OUTPUT
									,NO_OUTPUT


EXEC master.dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE'
									,N'Software\Microsoft\MSSQLServer\MSSQLServer'
									,N'DefaultLog'
									,@DefaultLogDirectory OUTPUT
									,NO_OUTPUT

IF RIGHT(@SQLPath, 1) <> '\'
	SET @SQLPath = @SQLPath + '\'

SET @DefaultDataDirectory = ISNULL(@DefaultDataDirectory, @SQLPath + 'DATA\')
SET @DefaultLogDirectory = ISNULL(@DefaultLogDirectory, @SQLPath + 'DATA\')


SET @DetailDomainName = NULL

EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE'
							,'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
							,'Domain'
							,@DetailDomainName OUTPUT

SET @VMToolDisplayName = NULL

EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE'
							,'SYSTEM\CurrentControlSet\Services\VMTools'
							,'DisplayName'
							,@VMToolDisplayName OUTPUT

IF @VMToolDisplayName IS NULL
	SET @HardwareType = 'P'
ELSE
	SET @HardwareType = 'V'
										
SET @NamedPipes = 0
SET @TCPIP = 0
SET @DynamicPort = NULL

SET @SortInfo = CAST(ISNULL(SERVERPROPERTY('SqlSortOrderName'), 'NULL') AS varchar(128))

IF @SQLVersionMajor = '8'
	BEGIN	
		CREATE TABLE #List
		(
			Name		varchar(25)
			,Protocol	varchar(25)
		)

		INSERT INTO #List
		EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
									,N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\'
									,N'ProtocolList'
									,@Value OUTPUT
									,'NO_OUTPUT'	

		IF EXISTS(SELECT * FROM #List WHERE Protocol = 'np')
			SET @NamedPipes = 1

		IF EXISTS(SELECT * FROM #List WHERE Protocol = 'tcp')
			SET @TCPIP = 1
												
		EXECUTE master.dbo.xp_instance_regread 'HKEY_LOCAL_MACHINE', 
											   'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\', 
											   'TcpPort',
											   @StaticPort OUTPUT,
											   'no_output'

		DROP TABLE #List
		

        SET @ProductCode = 'Microsoft SQL Server 2000' + CASE 
                                                            WHEN CAST(ISNULL(SERVERPROPERTY('InstanceName'), '') AS varchar(128)) = ''  THEN  CAST(ISNULL(SERVERPROPERTY('InstanceName'), '') AS varchar(128))
                                                            ELSE ' (' + CAST(ISNULL(SERVERPROPERTY('InstanceName'), '') AS varchar(128))  + ')'
                                                         END

        -- GO IN UNINSTALL INFO TO GRAB INSTALL DATE
        SET @Key = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + @ProductCode 

        SET @InstallDate = NULL							    
        EXECUTE master.dbo.xp_regread   'HKEY_LOCAL_MACHINE'
							            ,@Key
							            ,'InstallDate'
							            ,@InstallDate OUTPUT		
	END
ELSE
	BEGIN		
		SET @SQLProgramDirectory = NULL			

		EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
												,'SOFTWARE\Microsoft\MSSQLServer\Setup\'
												,'SQLProgramDir'
												,@SQLProgramDirectory OUTPUT
												,'no_output'

		SET @SQLBinaryDirectory = NULL

		EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
												,'SOFTWARE\Microsoft\MSSQLServer\Setup\'
												,'SQLBinRoot'
												,@SQLBinaryDirectory OUTPUT
												,'no_output'
	
		SELECT  @PhysicalCPUCount = cpu_count / hyperthread_ratio 
		FROM    sys.dm_os_sys_info

		SELECT  @LogicalCPUCount = cpu_count
		FROM    sys.dm_os_sys_info

		EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
									,N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Np\'
									,N'Enabled'
									,@NamedPipes OUTPUT
									,'NO_OUTPUT'

		EXECUTE master.dbo.xp_instance_regread 'HKEY_LOCAL_MACHINE', 
											   'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\', 
											   'Enabled', 
											   @TCPIP OUTPUT, 
											   'no_output'				
		 
		EXECUTE master.dbo.xp_instance_regread 'HKEY_LOCAL_MACHINE', 
											   'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IPAll\', 
											   'TcpDynamicPorts', 
											   @DynamicPort OUTPUT, 
											   'no_output'
		 
		EXECUTE master.dbo.xp_instance_regread 'HKEY_LOCAL_MACHINE', 
											   'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib\Tcp\IPAll\', 
											   'TcpPort', 
											   @StaticPort OUTPUT, 
											   'no_output'				

		EXECUTE xp_instance_regread N'HKEY_LOCAL_MACHINE'
									,N'Software\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\'
									,N'ForceEncryption'
									,@ForceProtocol OUTPUT
									,'NO_OUTPUT'

		SET @ForceProtocol = ISNULL(@ForceProtocol, 0)
									
		EXECUTE master.dbo.xp_instance_regread 'HKEY_LOCAL_MACHINE', 
											   'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', 
											   'DatabaseMailProfile',
											   @AgentMailProfile OUTPUT,
											   'no_output'


		SELECT		@DBMailProfile = B.name
		FROM		msdb.dbo.sysmail_principalprofile A
						JOIN msdb.dbo.sysmail_profile B ON A.profile_id = B.profile_id
		WHERE		principal_sid = 0

        SET @ProductCode = NULL

        -- GRAB PRODUCT CODE FOR INSTANCE
        SET @Key = 'SOFTWARE\Microsoft\MSSQLServer\Setup\'
        EXECUTE master.dbo.xp_instance_regread 'HKEY_LOCAL_MACHINE'
							                    ,@Key
							                    ,'ProductCode'
							                    ,@ProductCode OUTPUT

        -- GO IN UNINSTALL INFO TO GRAB INSTALL DATE
        SET @Key = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\' + @ProductCode + '\'

        SET @InstallDate = NULL							    
        EXECUTE master.dbo.xp_regread   'HKEY_LOCAL_MACHINE'
							            ,@Key
							            ,'InstallDate'
							            ,@InstallDate OUTPUT			
	END
	
SET @InstallDate = CONVERT(char(10), CAST(@InstallDate AS datetime), 101)

EXECUTE master.dbo.xp_instance_regread	N'HKEY_LOCAL_MACHINE'
										,N'Software\Microsoft\MSSQLServer\MSSQLServer'
										,N'AuditLevel'
										,@LoginAudit OUTPUT


IF OBJECT_ID('tempdb..#SubKeys') IS NOT NULL
	DROP TABLE #SubKeys

CREATE TABLE #SubKeys
(
	Name        varchar(128)
)

INSERT INTO #SubKeys
EXECUTE xp_instance_regenumkeys 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Microsoft'


IF EXISTS(SELECT * FROM #SubKeys WHERE Name = 'NET Framework Setup')
	BEGIN
		TRUNCATE TABLE #SubKeys

		INSERT INTO #SubKeys
		EXECUTE xp_instance_regenumkeys 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Microsoft\NET Framework Setup\NDP'

		DECLARE CURSOR_DOTNET CURSOR FAST_FORWARD
		FOR
			SELECT      Name
			FROM        #SubKeys
			WHERE       Name LIKE 'v%'
			ORDER BY    1 DESC

		OPEN CURSOR_DOTNET

		FETCH NEXT FROM CURSOR_DOTNET
		INTO @Value

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @DotNetVersion = NULL

			SET @Key = 'SOFTWARE\Microsoft\NET Framework Setup\NDP\' + @Value + '\' 

			EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
													,@Key
													,'Version'
													,@DotNetVersion OUTPUT
													,'no_output'    

			IF @DotNetVersion IS NOT NULL
				BREAK
			ELSE
				BEGIN            
					SET @Key = 'SOFTWARE\Microsoft\NET Framework Setup\NDP\' + @Value + '\Client\' 

					EXECUTE master.dbo.xp_instance_regread	'HKEY_LOCAL_MACHINE'
															,@Key
															,'Version'
															,@DotNetVersion OUTPUT
															,'no_output'    
		        
					IF @DotNetVersion IS NOT NULL
						BREAK                
				END

			FETCH NEXT FROM CURSOR_DOTNET
			INTO @Value
		END

		CLOSE CURSOR_DOTNET
		DEALLOCATE CURSOR_DOTNET
	END

SELECT		ISNULL(@DetailDomainName, 'NULL') + '<1>' +								-- Domain
				CASE WHEN CAST(SERVERPROPERTY('IsClustered') AS char(1)) = 1
						THEN 'C' -- Clustered
						ELSE 'S' -- Standalone
				END  + '<2>' +														-- ServerType
				CAST(@NamedPipes AS char(1)) + '<3>' +								-- NamedPipes
				CAST(@TCPIP AS char(1)) + '<4>' +									-- TCPIP				
				ISNULL(@DynamicPort, '') + '<5>' +									-- Dynamic Port
				ISNULL(@StaticPort, '') + '<6>' +									-- Static Port
				ISNULL(CAST(@ForceProtocol AS CHAR(1)), '') + '<7>' +				-- Force Protocol Encryption
				CAST(SERVERPROPERTY('ProductVersion') AS varchar(128)) + '<8>' +	-- Version
				CAST(SERVERPROPERTY('Edition') AS varchar(128)) + '<9>' +			-- Edition
				CAST(SERVERPROPERTY('Collation') AS varchar(128)) + '<10>' +		-- Collation
				ISNULL(@SortInfo, '') + '<11>' +									-- SortInfo
				@WindowsVerison + '<12>' +											-- WindowsVersion
				@Platform + '<13>' +												-- Platform
				CAST(@PhysicalCPUCount AS varchar(10)) + '<14>' +					-- PhysicalCPU
				CAST(@LogicalCPUCount AS varchar(10)) + '<15>' +					-- LogicalCPU
				CAST(@PhysicalMemory AS varchar(50)) + '<16>' +						-- PhysicalMemory				
				ISNULL(@DBMailProfile, '') + '<17>' +								-- DB Mail Profile
				ISNULL(@AgentMailProfile, '') + '<18>' +							-- Agent Mail Profile
				ISNULL(CAST(@LoginAudit AS varchar(1)), '') + '<19>' +				-- Login Audit	
				CONVERT(varchar(30), @ApproxStartDate, 109) + '<20>' +  			-- Approx Start Date
				ISNULL(@InstallDate, '') + '<21>' +									-- Install Date
                ISNULL(CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS varchar(128)), 'Unable To Determine') + '<22>' +
				ISNULL(@@SERVERNAME, '') + '<23>' +									-- @@ SERVERNAME 
				@HardwareType + '<24>' + 
				ISNULL(@SQLProgramDirectory, '') + '<25>' + 
				ISNULL(@SQLPath, '') + '<26>' + 
				ISNULL(@SQLBinaryDirectory, '') + '<27>' + 
				ISNULL(@DefaultDataDirectory, '') + '<28>' + 
				ISNULL(@DefaultLogDirectory, '') + '<29>' + 
				ISNULL(@DotNetVersion, '')

				
/*
SELECT		ISNULL(@DetailDomainName, 'NULL') 									AS [Domain]
			,CASE WHEN CAST(SERVERPROPERTY('IsClustered') AS char(1)) = 1
					THEN 'C' -- Clustered
					ELSE 'S' -- Standalone
			END																	AS [ServerType]
			,CAST(@NamedPipes AS char(1))										AS [NamedPipes]
			,CAST(@TCPIP AS char(1))		 									AS [TCPIP]		
			,ISNULL(@DynamicPort, '')		 									AS [Dynamic Port]
			,ISNULL(@StaticPort, '')	 										AS [Static Port]
			,ISNULL(CAST(@ForceProtocol AS CHAR(1)), '')		 				AS [Force Protocol Encryption]
			,CAST(SERVERPROPERTY('ProductVersion') AS varchar(128))				AS [Version]
			,CAST(SERVERPROPERTY('Edition') AS varchar(128))		 			AS [Edition]
			,CAST(SERVERPROPERTY('Collation') AS varchar(128))					AS [Collation]
			,ISNULL(@SortInfo, '')			 									AS [SortInfo]
			,@WindowsVerison													AS [WindowsVersion]
			,@Platform															AS [Platform]
			,CAST(@PhysicalCPUCount AS varchar(10))			 					AS [PhysicalCPU]
			,CAST(@LogicalCPUCount AS varchar(10))			 					AS [LogicalCPU]
			,CAST(@PhysicalMemory AS varchar(50))		 						AS [PhysicalMemory]
			,ISNULL(@DBMailProfile, '')			 								AS [DB Mail Profile]
			,ISNULL(@AgentMailProfile, '')										AS [Agent Mail Profile]
			,ISNULL(CAST(@LoginAudit AS varchar(1)), '')		 				AS [Login Audit]
			,CONVERT(varchar(30), @ApproxStartDate, 109) 						AS [Approx Start Date]
			,@InstallDate														AS [SQL Install Date]
*/

DROP TABLE #ServerInfo
