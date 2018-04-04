/* 2005,2008,2008R2,2012 */
/************************************************************************************************************
' Name		: SQLServerConfig.sql
' Author	: Alfredo Giotti
' Date      : May 24, 2010
' Description	: This procedure will:
'                 1.) Set Server Wide Settings for SQL server 2008
'                     a.) blocked process threshold = 30 seconds 
'                     c.) cost threshold for parallelism = 20 seconds
'                     d.) Database Mail XPs = 1
'                     e.) max degree of parallelism = 2
'                     f.) max server memory (MB) = size of physical memory - 2GB
'                     g.) min server memory (MB) = 2GB
'                     h.) Ole Automation Procedures = 1
'                     i.) optimize for ad hoc workloads = 1
'                     j.) remote admin connections = 1
'                     k.) xp_cmdshell = 1
'
'    IMPORTANT NOTES: 
'                    1.) Please don't run this script in a production server until you've tested its effects.
'                        Run it inside a transaction so that you can ROLLBACK in case of trouble.
'                    2.) Set your SSMS results window to TEXT ouput for better viewing. Ctrl+T
'                        Otherwise make sure you view the MESSAGES tab on the results pane
'
' Parameters	:
' Name				[I/O]	Description
'---------------------------------------------------------------------------------------
'
'---------------------------------------------------------------------------------------
' Return Value	:        
' Success:                      [ O ] 
' Failure:                      [ O ]  
'
' Revisions:
' --------------------------------------------------------------------------------------
' Ini |	Date	   |	Description
' --------------------------------------------------------------------------------------
************************************************************************************************************/
SET NOCOUNT ON;

/* Declare variables to be used as constants. */
DECLARE @BlockedProcessThreshold TINYINT        ; SET @BlockedProcessThreshold = 30; 
DECLARE @CommonCriteriaComplianceEnabled TINYINT; SET @CommonCriteriaComplianceEnabled = 1;
DECLARE @CostThresholdForParallelism TINYINT    ; SET @CostThresholdForParallelism = 25;
DECLARE @DatabaseMailXPs TINYINT                ; SET @DatabaseMailXPs = 1;
DECLARE @MaxDegreeOfParallelism TINYINT         ; SET @MaxDegreeOfParallelism = 2;
DECLARE @MaxServerMemory BIGINT                 ; 
DECLARE @MinServerMemory INTEGER                ; SET @MinServerMemory = 128;
DECLARE @OleAutomationProcedures TINYINT        ; SET @OleAutomationProcedures = 1;
DECLARE @OptimizeForAdHocWorkloads TINYINT      ; SET @OptimizeForAdHocWorkloads = 1;
DECLARE @RemoteAdminConnections TINYINT         ; SET @RemoteAdminConnections = 1;
DECLARE @xp_cmdshell TINYINT                    ; SET @xp_cmdshell = 1;

/* Declare and Instantiate variables */
DECLARE @ErrorMessage NVARCHAR(4000)            ; SET @ErrorMessage = '';
DECLARE @ErrorSeverity INTEGER                  ; SET @ErrorSeverity = 0;
DECLARE @ErrorState INTEGER                     ; SET @ErrorState = 0;
DECLARE @Error TINYINT                          ; SET @Error = 0;
DECLARE @InformationalOutput nvarchar(4000)     ; SET @InformationalOutput = '';

/* Determine the version of SQL */
DECLARE @VersionString VARCHAR(25),
		@MajorVersion INT;

SELECT	@VersionString = CONVERT(VARCHAR(25),SERVERPROPERTY('ProductVersion'));

SELECT	@MajorVersion = SUBSTRING(@VersionString,1,CHARINDEX('.',@VersionString,1)-1);

/* Output previous values */
SELECT 'Before Modifications',*
FROM sys.configurations 
where name in ( 'blocked process threshold (s)'
               , 'common criteria compliance enabled'
               , 'cost threshold for parallelism'
               , 'Database Mail XPs'
               , 'max degree of parallelism'
               , 'max server memory (MB)'
               , 'min server memory (MB)'
               , 'Ole Automation Procedures'
               , 'optimize for ad hoc workloads'
               , 'remote admin connections'
               , 'xp_cmdshell'
               
              )
order by [name] ;


BEGIN TRY

    /* enable advanced options */
    BEGIN TRY
        exec sp_configure 'SHOW ADVANCED OPTIONS', 1;
        RECONFIGURE WITH OVERRIDE;
    END TRY
    BEGIN CATCH
        SET @Error = 1;
    
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, -- Message text.
                   @ErrorSeverity, -- Severity.
                   @ErrorState -- State.
                   );
    END CATCH ;
    
    /* enable blocked process threshold */
    BEGIN TRY
        exec sp_configure 'blocked process threshold', @BlockedProcessThreshold;
    END TRY
    BEGIN CATCH
        SET @Error = 1;
    
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
    
        RAISERROR (@ErrorMessage, -- Message text.
                   @ErrorSeverity, -- Severity.
                   @ErrorState -- State.
                   );
    END CATCH ;
    
  
    /* set cost threshold for parallelism */        
    BEGIN TRY    
        exec sp_configure 'cost threshold for parallelism', @CostThresholdForParallelism;
    END TRY
    BEGIN CATCH
        SET @Error = 1;
    
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
    
        RAISERROR (@ErrorMessage, -- Message text.
                   @ErrorSeverity, -- Severity.
                   @ErrorState -- State.
                   );
    END CATCH ; 
    
    /* enable Database Mail XPs */
    BEGIN TRY
        exec sp_configure 'Database Mail XPs', @DatabaseMailXPs;
    END TRY
    BEGIN CATCH
        SET @Error = 1;
    
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
    
        RAISERROR (@ErrorMessage, -- Message text.
                   @ErrorSeverity, -- Severity.
                   @ErrorState -- State.
                   );
    END CATCH ; 
    
    /* set max degree of parallelism */
    BEGIN TRY
        exec sp_configure 'max degree of parallelism', @MaxDegreeOfParallelism;
    END TRY
    BEGIN CATCH
        SET @Error = 1;
    
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
    
        RAISERROR (@ErrorMessage, -- Message text.
                   @ErrorSeverity, -- Severity.
                   @ErrorState -- State.
                   );
    END CATCH ; 
    
    /* set max server memory */
    BEGIN TRY
         /* Capture physical memory size to be used for the Max Server Memory value 
         If physical memory is greater than 20GB then leave 4GB for the OS 
         If physical memory is less than 20GB then leave 2GB for the OS */ 
         SELECT @MaxServerMemory = (physical_memory_in_bytes/1048576) FROM sys.dm_os_sys_info;

         SET @MaxServerMemory = @MaxServerMemory - 1024;
            
         exec sp_configure 'max server memory (MB)', @MaxServerMemory;
    END TRY
    BEGIN CATCH
        SET @Error = 1;
    
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
    
        RAISERROR (@ErrorMessage, -- Message text.
                   @ErrorSeverity, -- Severity.
                   @ErrorState -- State.
                   );
    END CATCH ;
    
    /* set min server memory */
    BEGIN TRY
        exec sp_configure 'min server memory (MB)', @MinServerMemory;
    END TRY
    BEGIN CATCH
        SET @Error = 1;
    
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
     
        RAISERROR (@ErrorMessage, -- Message text.
                   @ErrorSeverity, -- Severity.
                   @ErrorState -- State.
                   );
    END CATCH ; 
    
    /* enable Ole Automation Procedures */
    BEGIN TRY
        exec sp_configure 'Ole Automation Procedures', @OleAutomationProcedures;
    END TRY
    BEGIN CATCH
        SET @Error = 1;
    
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
        
        RAISERROR (@ErrorMessage, -- Message text.
                   @ErrorSeverity, -- Severity.
                   @ErrorState -- State.
                   );
    END CATCH ; 
    
    /* enable optimize for ad hoc workloads */
    IF (@MajorVersion >= 10)
	BEGIN TRY
		exec sp_configure 'optimize for ad hoc workloads', @OptimizeForAdHocWorkloads;
    END TRY
    BEGIN CATCH
        SET @Error = 1;
    
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
    
        RAISERROR (@ErrorMessage, -- Message text.
                   @ErrorSeverity, -- Severity.
                   @ErrorState -- State.
                   );
    END CATCH ; 
    
    /* enable remote admin connections */
    BEGIN TRY
        exec sp_configure 'remote admin connections', @RemoteAdminConnections;
    END TRY
    BEGIN CATCH
        SET @Error = 1;
    
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
    
        RAISERROR (@ErrorMessage, -- Message text.
                   @ErrorSeverity, -- Severity.
                   @ErrorState -- State.
                   );
    END CATCH ; 
    
    BEGIN TRY
        exec sp_configure 'xp_cmdshell', @xp_cmdshell;
    END TRY
    BEGIN CATCH
        SET @Error = 1;
    
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
    
        RAISERROR (@ErrorMessage, -- Message text.
                   @ErrorSeverity, -- Severity.
                   @ErrorState -- State.
                   );
    END CATCH ; 
    
    
    RECONFIGURE WITH OVERRIDE ;
    
    /* Output post values */
    SELECT 'After Modifications', *
    FROM sys.configurations 
    where name in ( 'blocked process threshold (s)'
                   , 'common criteria compliance enabled'
                   , 'cost threshold for parallelism'
                   , 'Database Mail XPs'
                   , 'max degree of parallelism'
                   , 'max server memory (MB)'
                   , 'min server memory (MB)'
                   , 'Ole Automation Procedures'
                   , 'optimize for ad hoc workloads'
                   , 'remote admin connections'
                   , 'xp_cmdshell'
                   
                  )
    order by [name] ;
    

END TRY
BEGIN CATCH
    SET @InformationalOutput = N'---> Unhandled exception: attempting to set server-level configuation.';
    SELECT @InformationalOutput ;
    
    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH;


IF @Error = 1
BEGIN

    RAISERROR('There was one or more errors while attempting set server configuration options, SEE PREVIOUS ERRORS!',16,1) WITH NOWAIT, LOG;
    
    SET @InformationalOutput = 'DateTime: ' + CONVERT(nvarchar,GETDATE(),120)
                             + ' | Server Configuration Ended (WITH ERRORS)';
    PRINT @InformationalOutput ;
    
END
ELSE
BEGIN

    SET @InformationalOutput = 'DateTime: ' + CONVERT(nvarchar,GETDATE(),120)
                       + ' | Server Configuration has ended, (WITH SUCCESS): RESTART SQL SERVER';
    PRINT @InformationalOutput ;
    
END; 