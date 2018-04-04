SET NOCOUNT ON

DECLARE @Key			varchar(512)
		,@Instance		varchar(128)
		,@StaticPort	varchar(128)		
		,@InstanceKey	varchar(128)
		
CREATE TABLE #Services
(
		Name		varchar(256)
)

CREATE TABLE #InstanceInfo
(
		PhysicalName		varchar(256)
		,SQLServerName		varchar(256)
		,Instance			varchar(256)
		,SQLServer			varchar(256)
		,IsClustered		bit
		,StaticPort			varchar(128)
)

SET @Key = N'SYSTEM\CurrentControlSet\Services\'

INSERT INTO #Services
EXECUTE master.dbo.xp_instance_regenumkeys 'HKEY_LOCAL_MACHINE', @Key

DECLARE CURSOR_INSTANCE CURSOR FAST_FORWARD
FOR
	SELECT		CASE WHEN UPPER(Name) = 'MSSQLSERVER' 
					THEN Name 
					ELSE RIGHT(Name, LEN(Name) - 6)
				END AS [Instance]
	FROM		#Services
	WHERE		UPPER(Name) = 'MSSQLSERVER'
	   OR		UPPER(Name) LIKE 'MSSQL$%'
	ORDER BY	1

OPEN CURSOR_INSTANCE
	
FETCH NEXT FROM CURSOR_INSTANCE
INTO @Instance
	
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @StaticPort = NULL
	
	IF LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), 1) = '8'
		BEGIN
			IF UPPER(@Instance) = 'MSSQLSERVER'
				BEGIN
					EXECUTE master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', 
									    		  'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\', 
												  'TcpPort',
												   @StaticPort OUTPUT,
												   'no_output'			
												   
					IF @StaticPort IS NULL
						BEGIN
							SET @Key = 'SOFTWARE\Wow6432Node\Microsoft\MSSQLServer\MSSQLServer\SuperSocketNetLib\Tcp\'
							
							EXECUTE master.dbo.xp_regread 'HKEY_LOCAL_MACHINE'
									    				  ,@Key 
														  ,'TcpPort'
														  ,@StaticPort OUTPUT
														  ,'no_output'
						END												   
				END
			ELSE				
				BEGIN 
					SET @Key = 'SOFTWARE\Microsoft\Microsoft SQL Server\' + @Instance + '\MSSQLServer\SuperSocketNetLib\Tcp\'
					
					EXECUTE master.dbo.xp_regread 'HKEY_LOCAL_MACHINE'
							   					  ,@Key 
												  ,'TcpPort'
												  ,@StaticPort OUTPUT
												  ,'no_output'
												  
					IF @StaticPort IS NULL
						BEGIN
							SET @Key = 'SOFTWARE\Wow6432Node\Microsoft\Microsoft SQL Server\' + @Instance + '\MSSQLServer\SuperSocketNetLib\Tcp\'
							EXECUTE master.dbo.xp_regread 'HKEY_LOCAL_MACHINE'
						   								  ,@Key 
														  ,'TcpPort'
														  ,@StaticPort OUTPUT
														  ,'no_output'												  				
						END
				END
		END
	ELSE
		BEGIN		
			SET @Key = 'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL\' 
					   
			EXECUTE master.dbo.xp_regread 'HKEY_LOCAL_MACHINE'
									      ,@Key 
										  ,@Instance
										  ,@InstanceKey OUTPUT
										  ,'no_output'							
										  						
			SET @Key = 'SOFTWARE\Microsoft\Microsoft SQL Server\' + @InstanceKey + '\MSSQLServer\SuperSocketNetLib\Tcp\IPAll\'
			
			EXECUTE master.dbo.xp_regread 'HKEY_LOCAL_MACHINE'
										  ,@Key 
										  ,'TcpPort'
										  ,@StaticPort OUTPUT 
										  ,'no_output'				
		END			

	INSERT INTO #InstanceInfo
	SELECT		CAST(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS varchar(256))	AS [PhysicalName]
				,CAST(SERVERPROPERTY('MachineName') AS varchar(256))				AS [SQLServerName]
				,@Instance															AS [Instance]
				,CASE WHEN UPPER(@Instance) = 'MSSQLSERVER' 
					THEN CAST(SERVERPROPERTY('MachineName') AS varchar(256))
					ELSE CAST(SERVERPROPERTY('MachineName') AS varchar(256)) + '\' + @Instance
				END																	AS [SQLServer]
				,CAST(SERVERPROPERTY('IsClustered') AS bit)							AS [Clustered]
				,@StaticPort														AS [StaticPort]
	
	FETCH NEXT FROM CURSOR_INSTANCE
	INTO @Instance
END

CLOSE CURSOR_INSTANCE
DEALLOCATE CURSOR_INSTANCE

SELECT		ISNULL(PhysicalName, SQLServerName) + '<1>' +
				SQLServerName + '<2>' +
				Instance + '<3>' + 
				SQLServer + '<4>' + 
				CAST(IsClustered AS CHAR(1)) + '<5>' +
				ISNULL(StaticPort, 'NULL') 
FROM		#InstanceInfo

DROP TABLE #Services
DROP TABLE #InstanceInfo

