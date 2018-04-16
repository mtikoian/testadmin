--
-- TABLE: LOG_DETAIL
--

IF OBJECT_ID('dbo.LOG_DETAIL') IS NOT NULL
  BEGIN
    DROP TABLE dbo.LOG_DETAIL
    PRINT '<<< DROPPED TABLE dbo.LOG_DETAIL >>>'
  END
go

CREATE TABLE dbo.LOG_DETAIL(
  LOG_DETAIL_ID          BIGINT IDENTITY (1, 1) PRIMARY KEY CLUSTERED NOT NULL
 ,LOG_LEVEL_ID           SMALLINT NOT NULL
 ,LOG_DETAIL_DATE        DATETIME DEFAULT GETDATE() NOT NULL
 ,ORGANIZATION_ID        VARCHAR(128) NULL
 ,[USER_ID]              VARCHAR(128) NULL
 ,SYSTEM_USER_ID         VARCHAR(128)
 , -- MSSQL function SYSTEM_USER
  PROCEDURE_NAME         VARCHAR(128) NULL
 ,LOG_DETAIL_TEXT        VARCHAR(256) NOT NULL
 ,LOG_DIAGNOSTIC_NUM     INT NULL
 ,LOG_DIAGNOSTIC_TX      VARCHAR(256) NULL
 ,LOG_REFERENCE_TAG      VARCHAR(24) NULL
 ,TSQL_ERROR_LINE        INT NULL
 , -- MSSQL function ERROR_LINE
  TSQL_ERROR_MESSAGE     NVARCHAR(2048) NULL
 , -- MSSQL function ERROR_MESSAGE
  TSQL_ERROR_NUMBER      INT NULL
 , -- MSSQL function ERROR_NUMBER
  TSQL_ERROR_PROCEDURE   NVARCHAR(126) NULL
 , -- MSSQL function ERROR_PROCEDURE
  TSQL_ERROR_SEVERITY    INT NULL
 , -- MSSQL function ERROR_SEVERITY
  TSQL_ERROR_STATE       INT NULL -- MSSQL function ERROR_STATE
                                 )
go

CREATE INDEX IX_LOG_DETAIL_LEVEL_DATE
  ON dbo.LOG_DETAIL(
    LOG_LEVEL_ID
   ,LOG_DETAIL_DATE);
go

--
-- TABLE: LOG_LEVEL
--
IF OBJECT_ID('dbo.LOG_LEVEL') IS NOT NULL
  BEGIN
    DROP TABLE dbo.LOG_LEVEL
    PRINT '<<< DROPPED TABLE dbo.LOG_LEVEL >>>'
  END
go

CREATE TABLE dbo.LOG_LEVEL(
  LOG_LEVEL_ID      SMALLINT NOT NULL
 ,LOG_LEVEL_NAME    VARCHAR(20) NOT NULL
 ,RETAIN_DAYS_NUM   SMALLINT)
go

--
-- TABLE: LOG_SPEC
--
IF OBJECT_ID('dbo.LOG_SPEC') IS NOT NULL
  BEGIN
    DROP TABLE dbo.LOG_SPEC
    PRINT '<<< DROPPED TABLE dbo.LOG_SPEC >>>'
  END
go

CREATE TABLE dbo.LOG_SPEC(
  LOG_SPEC_ID       INT IDENTITY (1, 1) PRIMARY KEY CLUSTERED NOT NULL
 ,LOG_LEVEL_ID      SMALLINT
 ,ORGANIZATION_ID   VARCHAR(128)
 ,USER_ID           VARCHAR(128)
 ,PROCEDURE_NAME    VARCHAR(128)
 ,LOG_START_DATE    DATETIME
 ,LOG_STOP_DATE     DATETIME)
go

-- -------------------
-- LOG_LEVEL Seed Data
-- -------------------
INSERT INTO
  dbo.LOG_LEVEL(
    LOG_LEVEL_ID
   ,LOG_LEVEL_NAME
   ,RETAIN_DAYS_NUM)
VALUES
  (
    1
   ,'Error'
   ,180);

INSERT INTO
  dbo.LOG_LEVEL(
    LOG_LEVEL_ID
   ,LOG_LEVEL_NAME
   ,RETAIN_DAYS_NUM)
VALUES
  (
    2
   ,'Warning'
   ,180);

INSERT INTO
  dbo.LOG_LEVEL(
    LOG_LEVEL_ID
   ,LOG_LEVEL_NAME
   ,RETAIN_DAYS_NUM)
VALUES
  (
    3
   ,'Info'
   ,30);

INSERT INTO
  dbo.LOG_LEVEL(
    LOG_LEVEL_ID
   ,LOG_LEVEL_NAME
   ,RETAIN_DAYS_NUM)
VALUES
  (
    4
   ,'Debug'
   ,15);
go

IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = 'dbo' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'AddLogSpec')
  BEGIN
    DROP PROCEDURE dbo.AddLogSpec;
    PRINT '<<< DROPPED PROCEDURE dbo.AddLogSpec >>>';
  END;
GO

CREATE PROCEDURE dbo.AddLogSpec(@pi_LOG_LEVEL_ID SMALLINT = NULL, @pi_ORGANIZATION_ID VARCHAR(128) = NULL,
  @pi_UserID VARCHAR(128) = NULL, @pi_PROCEDURE_NAME VARCHAR(128) = NULL,
  @pi_START_DATE DATETIME = NULL, @pi_STOP_DATE DATETIME = NULL,
  @po_LOG_SPEC_ID INT OUTPUT, @po_Error_Reason_Cd INT OUTPUT)
AS
  BEGIN
    /***
    =pod

    =begin text

      ================================================================================
      Name : AddLogSpec

      Author : pobrien 10/06/2011

      Description : Inserts a row in the LOG_SPEC table.

      ===============================================================================
      Parameters :
      Name                                | I/O   | Description

      @pi_LOG_LEVEL_ID                      INPUT   A valid Log level ID (Must be valued)
      @pi_ORGANIZATION_ID                   INPUT   Organization ID
      @pi_UserID                            INPUT   User ID
      @pi_PROCEDURE_NAME                    INPUT   Stored Procedure name
      @pi_START_DATE                        INPUT   Datetime to start logging
      @pi_STOP_DATE                         INPUT   Datetime to stop logging
      @po_LOG_SPEC_ID                       OUTPUT  Log_Spec.Log_Spec_ID
      @po_Error_Reason_Cd                   OUTPUT  Reason code 

      --------------------------------------------------------------------------------
      Error Reason codes:

      1 - Invalid Log_Level_ID parameter.

      --------------------------------------------------------------------------------
      Return Value: 0
      Success : 0
      Failure : Non zero : Log_Detail.Log_Detail_ID

      Revisions :
      --------------------------------------------------------------------------------
      Ini    | Date          | Description
      --------------------------------------------------------------------------------
      pobrien  10/10/2011      Initial version.
      ================================================================================

    =end text

    =cut
    ***/
    -- Return code from called stored procedures.
    DECLARE @ReturnCode INT;

    -- Table to stored LOG_SPEC row identity column inserted
    DECLARE @LogSpecRows TABLE (Log_Spec_ID INT NOT NULL);

    -- Log Level (LL) Error
    DECLARE @LL_Error SMALLINT;
    -- Log Level (LL) Warning
    DECLARE @LL_Warning SMALLINT;
    -- Log Level (LL) Info
    DECLARE @LL_Info SMALLINT;
    -- Log Level (LL) Debug
    DECLARE @LL_Debug SMALLINT;

    -- Initialize Variables
    -- --------------------
    -- Return code from stored procedures
    SET @ReturnCode     = 0;
    SET @po_Error_Reason_Cd = 0;

    -- Identity value of Log_Spec row to be inserted.
    SET @po_LOG_SPEC_ID = 0;

    -- Log Level (LL) Error
    SET @LL_Error       = 1;
    -- Log Level (LL) Warning
    SET @LL_Warning     = 2;
    -- Log Level (LL) Info
    SET @LL_Info        = 3;
    -- Log Level (LL) Debug
    SET @LL_Debug       = 4;

    -- Stops the message that shows the count of the number of rows affected by a
    -- Transact-SQL statement or stored procedure from being returned as part of the result set
    SET  NOCOUNT ON;

    -- The Log Level ID must be valid
    IF (@pi_LOG_LEVEL_ID IS NULL) OR (@pi_LOG_LEVEL_ID < @LL_Error OR @pi_LOG_LEVEL_ID > @LL_Debug)
      BEGIN
        SET @po_Error_Reason_Cd = 1;
        RETURN @ReturnCode;
      END;

    BEGIN TRY
      INSERT INTO dbo.LOG_SPEC(LOG_LEVEL_ID, ORGANIZATION_ID, [USER_ID], PROCEDURE_NAME, LOG_START_DATE, LOG_STOP_DATE)
      OUTPUT      inserted.Log_Spec_ID
      INTO        @LogSpecRows
      VALUES      (@pi_LOG_LEVEL_ID, @pi_ORGANIZATION_ID, @pi_UserID, @pi_PROCEDURE_NAME, @pi_START_DATE, @pi_STOP_DATE);

      -- Get the Log_Spec_ID Identity value for the row just inserted.
      SELECT @po_Log_Spec_ID = Log_Spec_ID FROM @LogSpecRows;
    END TRY
    BEGIN CATCH
      -- Roll back any active or uncommittable transactions before
      -- logging any information in the Log_Detail table.
      -- XACT_STATE = 0 means there is no transaction and a commit or rollback operation would generate an error.
      -- XACT_STATE = -1 The transaction is in an uncommittable state
      IF XACT_STATE () <> 0
          BEGIN
              ROLLBACK TRANSACTION;
          END;

      -- Log error to the Log_Detail table
      EXECUTE dbo.LogEntry 1, NULL,NULL,'AddLogSpec','',NULL,NULL,NULL, @LogDetailID = @ReturnCode OUTPUT;
    END CATCH;

    RETURN @ReturnCode;
  END;
GO

IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = 'dbo' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'AddLogSpec')
  BEGIN
    PRINT '<<< CREATED PROCEDURE dbo.AddLogSpec >>>';
  END
ELSE
  BEGIN
    PRINT '<<< FAILED CREATING PROCEDURE dbo.AddLogSpec >>>';
  END;
GO

IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = 'dbo' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'UpdLogSpec')
  BEGIN
    DROP PROCEDURE dbo.UpdLogSpec;
    PRINT '<<< DROPPED PROCEDURE dbo.UpdLogSpec >>>';
  END;
GO

CREATE PROCEDURE dbo.UpdLogSpec(
  @pi_LOG_SPEC_ID      INT = NULL
 ,@pi_ORGANIZATION_ID  VARCHAR(128) = NULL
 ,@pi_UserID           VARCHAR(128) = NULL
 ,@pi_PROCEDURE_NAME   VARCHAR(128) = NULL
 ,@pi_START_DATE       DATETIME = NULL
 ,@pi_STOP_DATE        DATETIME = NULL
 ,@po_Error_Reason_Cd  INT OUTPUT)
AS
  BEGIN
    /***
    =pod

    =begin text

      ================================================================================
      Name : UpdLogSpec

      Author : pobrien 10/06/2011

      Description : Updates a row in the LOG_SPEC table.

      ===============================================================================
      Parameters :
      Name                                | I/O   | Description

      @pi_LOG_SPEC_ID                       INPUT   A valid Log Spec ID (Must be valued)
      @pi_ORGANIZATION_ID                   INPUT   Organization ID
      @pi_UserID                            INPUT   User ID
      @pi_PROCEDURE_NAME                    INPUT   Stored Procedure name
      @pi_START_DATE                        INPUT   Datetime to start logging
      @pi_STOP_DATE                         INPUT   Datetime to stop logging
      @po_Error_Reason_Cd                   OUTPUT  Reason code

      --------------------------------------------------------------------------------
      Error Reason codes:

      1 - Invalid Log_Spec_ID parameter.
      2 - Log_Spec_ID does not exist.
      3 - Error updating Log_Spec row

      --------------------------------------------------------------------------------
      Return Value: 0
      Success : 0
      Failure : Non zero : Log_Detail.Log_Detail_ID

      Revisions :
      --------------------------------------------------------------------------------
      Ini    | Date          | Description
      --------------------------------------------------------------------------------
      pobrien  10/10/2011      Initial version.
      ================================================================================

    =end text

    =cut
    ***/
    -- Return code from called stored procedures.
    DECLARE @ReturnCode   INT;

    -- Log Level (LL) Error
    DECLARE @LL_Error   SMALLINT;
    -- Log Level (LL) Warning
    DECLARE @LL_Warning   SMALLINT;
    -- Log Level (LL) Info
    DECLARE @LL_Info   SMALLINT;
    -- Log Level (LL) Debug
    DECLARE @LL_Debug   SMALLINT;

    -- Initialize Variables
    -- --------------------
    -- Return code from stored procedures
    SET @ReturnCode = 0;
    SET @po_Error_Reason_Cd = 0;

    -- Log Level (LL) Error
    SET @LL_Error   = 1;
    -- Log Level (LL) Warning
    SET @LL_Warning = 2;
    -- Log Level (LL) Info
    SET @LL_Info    = 3;
    -- Log Level (LL) Debug
    SET @LL_Debug   = 4;

    -- Stops the message that shows the count of the number of rows affected by a
    -- Transact-SQL statement or stored procedure from being returned as part of the result set
    SET  NOCOUNT ON;

    -- The Log Spec ID must be valid
    IF (@pi_LOG_SPEC_ID IS NULL)
      BEGIN
        SET @po_Error_Reason_Cd = 1;
        RETURN @ReturnCode;
      END;

    BEGIN TRY
      UPDATE
        dbo.LOG_SPEC
      SET
        ORGANIZATION_ID = @pi_ORGANIZATION_ID
       ,[USER_ID]       = @pi_UserID
       ,PROCEDURE_NAME  = @pi_PROCEDURE_NAME
       ,LOG_START_DATE  = @pi_START_DATE
       ,LOG_STOP_DATE   = @pi_STOP_DATE
      WHERE
        Log_Spec_ID = @pi_Log_Spec_ID;

      IF (@@ROWCOUNT = 0)
        SET @po_Error_Reason_Cd = 2;

      RETURN @ReturnCode
    END TRY
    BEGIN CATCH
      -- Roll back any active or uncommittable transactions before
      -- logging any information in the Log_Detail table.
      -- XACT_STATE = 0 means there is no transaction and a commit or rollback operation would generate an error.
      -- XACT_STATE = -1 The transaction is in an uncommittable state
      IF XACT_STATE () <> 0
          BEGIN
              ROLLBACK TRANSACTION;
          END;

      -- Log error to the Log_Detail table
      EXECUTE dbo.LogEntry 1, NULL,NULL,'UpdLogSpec','',NULL,NULL,NULL, @LogDetailID = @ReturnCode OUTPUT;
    END CATCH;

    RETURN @ReturnCode;
  END;
GO

IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = 'dbo' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'UpdLogSpec')
  BEGIN
    PRINT '<<< CREATED PROCEDURE dbo.UpdLogSpec >>>';
  END
ELSE
  BEGIN
    PRINT '<<< FAILED CREATING PROCEDURE dbo.UpdLogSpec >>>';
  END;
GO

IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = 'dbo' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'DelLogSpec')
  BEGIN
    DROP PROCEDURE dbo.DelLogSpec;
    PRINT '<<< DROPPED PROCEDURE dbo.DelLogSpec >>>';
  END;
GO

CREATE PROCEDURE dbo.DelLogSpec(@pi_LOG_SPEC_ID INT = NULL, @po_Error_Reason_Cd INT OUTPUT)
AS
  BEGIN
    /***
    =pod

    =begin text

      ================================================================================
      Name : DelLogSpec

      Author : pobrien 10/06/2011

      Description : Deletes a row in the LOG_SPEC table.

      ===============================================================================
      Parameters :
      Name                                | I/O   | Description

      @pi_LOG_SPEC_ID                       INPUT   A valid Log Spec ID (Must be valued)
      @po_Error_Reason_Cd                   OUTPUT  Reason code

      --------------------------------------------------------------------------------
      Error Reason codes:

      1 - Invalid Log_Spec_ID parameter.
      2 - Log_Spec_ID does not exist.

      --------------------------------------------------------------------------------
      Return Value: 0
      Success : 0
      Failure : Non zero : Log_Detail.Log_Detail_ID

      Revisions :
      --------------------------------------------------------------------------------
      Ini    | Date          | Description
      --------------------------------------------------------------------------------
      pobrien  10/10/2011      Initial version.
      ================================================================================

    =end text

    =cut
    ***/
    -- Return code from called stored procedures.
    DECLARE @ReturnCode   INT;

    -- Initialize Variables
    -- --------------------
    -- Return code from stored procedures
    SET @ReturnCode = 0;
    SET @po_Error_Reason_Cd = 0;

    -- Stops the message that shows the count of the number of rows affected by a
    -- Transact-SQL statement or stored procedure from being returned as part of the result set
    SET  NOCOUNT ON;

    -- The Log Spec ID must be valid
    IF (@pi_LOG_SPEC_ID IS NULL)
      BEGIN
        SET @po_Error_Reason_Cd = 1;
        RETURN @ReturnCode;
      END;

    BEGIN TRY
      DELETE FROM
        dbo.LOG_SPEC
      WHERE
        Log_Spec_ID = @pi_Log_Spec_ID;

      IF (@@ROWCOUNT = 0)
        SET @po_Error_Reason_Cd = 2;

      RETURN @ReturnCode
    END TRY
    BEGIN CATCH
      -- Roll back any active or uncommittable transactions before
      -- logging any information in the Log_Detail table.
      -- XACT_STATE = 0 means there is no transaction and a commit or rollback operation would generate an error.
      -- XACT_STATE = -1 The transaction is in an uncommittable state
      IF XACT_STATE () <> 0
          BEGIN
              ROLLBACK TRANSACTION;
          END;

      -- Log error to the Log_Detail table
      EXECUTE dbo.LogEntry 1, NULL,NULL,'DelLogSpec','',NULL,NULL,NULL, @LogDetailID = @ReturnCode OUTPUT;
    END CATCH;

    RETURN @ReturnCode;
  END;
GO

IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = 'dbo' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'DelLogSpec')
  BEGIN
    PRINT '<<< CREATED PROCEDURE dbo.DelLogSpec >>>';
  END
ELSE
  BEGIN
    PRINT '<<< FAILED CREATING PROCEDURE dbo.DelLogSpec >>>';
  END;
GO

IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = 'dbo' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'InsertLogDetail')
  BEGIN
    DROP PROCEDURE dbo.InsertLogDetail;
    PRINT '<<< DROPPED PROCEDURE dbo.InsertLogDetail >>>';
  END;
GO

CREATE PROCEDURE dbo.InsertLogDetail(
  @pi_LOG_LEVEL_ID        SMALLINT = NULL
 ,@pi_ORGANIZATION_ID     VARCHAR(128) = NULL
 ,@pi_UserID              VARCHAR(128) = NULL
 ,@pi_PROCEDURE_NAME      VARCHAR(128) = NULL
 ,@pi_LOG_DETAIL_TEXT     VARCHAR(256) = NULL
 ,@pi_LOG_DIAGNOSTIC_NUM  INT = NULL
 ,@pi_LOG_DIAGNOSTIC_TX   VARCHAR(256) = NULL
 ,@pi_LOG_REFERENCE_TAG   VARCHAR(24) = NULL
 ,@po_Log_Detail_ID       INT OUTPUT)
AS
  BEGIN
    /***
    =pod

    =begin text

      ================================================================================
      Name : InsertLogDetail

      Author : pobrien 10/06/2011

      Description : Inserts a row in the LOG_DETAIL table.

        *** This routine is internal to the generic logging mechanisim and should ***
        *** only be called from the LogEntry stored procedure                     ***

      ===============================================================================
      Parameters :
      Name                                | I/O   | Description

      @pi_LOG_LEVEL_ID                      INPUT   Log level ID
      @pi_UserID                            INPUT   User ID
      @pi_ORGANIZATION_ID                   INPUT   Organization ID
      @pi_PROCEDURE_NAME                    INPUT   Stored Procedure name
      @pi_LOG_DETAIL_TEXT                   INPUT   Text to log
      @pi_LOG_DIAGNOSTIC_NUM                INPUT   Diagnostic number
      @pi_LOG_DIAGNOSTIC_TX                 INPUT   Diagnostic text
      @pi_LOG_REFERENCE_TAG                 INPUT   Reference tag
      @po_Log_Detail_ID                     OUTPUT  Log_Detail.Log_Detail_ID

      --------------------------------------------------------------------------------
      Error Reason codes:

      1 - Failed to perform logging.

      --------------------------------------------------------------------------------
      Return Value: 0
      Success : 0
      Failure : Non zero : Log_Detail.Log_Detail_ID

      Revisions :
      --------------------------------------------------------------------------------
      Ini    | Date          | Description
      --------------------------------------------------------------------------------
      pobrien  10/06/2011 09:14:08       Initial version.
      ================================================================================

    =end text

    =cut
    ***/
    -- Return code from called stored procedures.
    DECLARE @ReturnCode   INT;

    -- Table to capture log detail id inserted
    DECLARE @TblLogDetail TABLE (Log_Detail_ID INT NOT NULL);

    -- Initialize Variables
    -- --------------------
    -- Return code from stored procedures
    SET @ReturnCode = 0;

    -- Stops the message that shows the count of the number of rows affected by a
    -- Transact-SQL statement or stored procedure from being returned as part of the result set
    SET  NOCOUNT ON;

    BEGIN TRY
      INSERT INTO
        dbo.LOG_DETAIL(
          LOG_LEVEL_ID
         ,LOG_DETAIL_DATE
         ,ORGANIZATION_ID
         ,[USER_ID]
         ,SYSTEM_USER_ID
         ,PROCEDURE_NAME
         ,LOG_DETAIL_TEXT
         ,LOG_DIAGNOSTIC_NUM
         ,LOG_DIAGNOSTIC_TX
         ,LOG_REFERENCE_TAG
         ,TSQL_ERROR_LINE
         ,TSQL_ERROR_MESSAGE
         ,TSQL_ERROR_NUMBER
         ,TSQL_ERROR_PROCEDURE
         ,TSQL_ERROR_SEVERITY
         ,TSQL_ERROR_STATE)
      OUTPUT inserted.Log_Detail_ID Into @TblLogDetail
      VALUES
        (
          @pi_LOG_LEVEL_ID
         ,getdate()
         ,@pi_ORGANIZATION_ID
         ,@pi_UserID
         ,SYSTEM_USER
         ,@pi_PROCEDURE_NAME
         ,@pi_LOG_DETAIL_TEXT
         ,@pi_LOG_DIAGNOSTIC_NUM
         ,@pi_LOG_DIAGNOSTIC_TX
         ,@pi_LOG_REFERENCE_TAG
         ,ERROR_LINE()
         ,ERROR_MESSAGE()
         ,ERROR_NUMBER()
         ,ERROR_PROCEDURE()
         ,ERROR_SEVERITY()
         ,ERROR_STATE());
      
      -- Set the output variable for the log detail id.
      Select @po_Log_Detail_ID = Log_Detail_ID From @TblLogDetail;
    END TRY
    BEGIN CATCH
      -- Roll back any active or uncommittable transactions before
      -- logging any information in the Log_Detail table.
      -- XACT_STATE = 0 means there is no transaction and a commit or rollback operation would generate an error.
      -- XACT_STATE = -1 The transaction is in an uncommittable state
      IF XACT_STATE () <> 0
          BEGIN
              ROLLBACK TRANSACTION;
          END;

      -- Log error to the Log_Detail table
      EXECUTE dbo.LogEntry 1, NULL,NULL,'InsertLogDetail','',NULL,NULL,NULL, @LogDetailID = @ReturnCode OUTPUT;
    END CATCH;

    RETURN @ReturnCode;
  END;
GO

IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = 'dbo' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'InsertLogDetail')
  BEGIN
    PRINT '<<< CREATED PROCEDURE dbo.InsertLogDetail >>>';
  END
ELSE
  BEGIN
    PRINT '<<< FAILED CREATING PROCEDURE dbo.InsertLogDetail >>>';
  END;
GO

IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = 'dbo' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'LogEntry')
  BEGIN
    DROP PROCEDURE dbo.LogEntry;
    PRINT '<<< DROPPED PROCEDURE dbo.LogEntry >>>';
  END;
GO

CREATE PROCEDURE dbo.LogEntry (
   @pi_LOG_LEVEL_ID          SMALLINT = NULL,
   @pi_ORGANIZATION_ID       VARCHAR (128) = NULL,
   @pi_UserID                VARCHAR (128) = NULL,
   @pi_PROCEDURE_NAME        VARCHAR (128) = NULL,
   @pi_LOG_DETAIL_TEXT       VARCHAR (256) = NULL,
   @pi_LOG_DIAGNOSTIC_NUM    INT = NULL,
   @pi_LOG_DIAGNOSTIC_TX     VARCHAR(256) = NULL,
   @pi_LOG_REFERENCE_TAG     VARCHAR (24) = NULL,
   @po_Log_Detail_ID         INT OUTPUT,
   @po_Error_Reason_Cd       INT OUTPUT)
AS
   BEGIN
      /***
      =pod

      =begin text

        ================================================================================
        Name : LogEntry

        Author : pobrien 10/06/2011

        Description : This is the entry point for all logging.
        
          The LogEntry stored procedure and related logging components were designed to
          give flexibility when logging information from errors through debugging.
          
          When logging, the log level id and log detail text must be valued.
          
          The TSQL functions
          
            SYSTEM_USER, ERROR_LINE, ERROR_MESSAGE, ERROR_NUMBER, ERROR_PROCEDURE, 
            ERROR_SEVERITY and ERROR_STATE
            
          are always logged to the LOG_DETAIL table. 
          

        ===============================================================================
        Parameters :
        Name                                | I/O   | Description

        @pi_LOG_LEVEL_ID                      INPUT   A valid Log level ID (Must be valued)
        @pi_ORGANIZATION_ID                   INPUT   Organization ID
        @pi_UserID                            INPUT   User ID
        @pi_PROCEDURE_NAME                    INPUT   Stored Procedure name
        @pi_LOG_DETAIL_TEXT                   INPUT   Text to log (Must be valued)
        @pi_LOG_DIAGNOSTIC_NUM                INPUT   Diagnostic number
        @pi_LOG_DIAGNOSTIC_TX                 INPUT   Diagnostic text
        @pi_LOG_REFERENCE_TAG                 INPUT   Reference tag
        @po_Log_Detail_ID                     OUTPUT  Log_Detail.Log_Detail_ID
        @po_Error_Reason_Cd                   OUTPUT  Error reason code

        --------------------------------------------------------------------------------
        Error Reason codes:

        1 - Invalid Log Level ID parameter
        2 - Invalid Log Detail Text parameter
        3 - Failed to perform logging.

        --------------------------------------------------------------------------------
        Return Value: 0
        Success : 0
        Failure : Non zero : Log_Detail.Log_Detail_ID

        Revisions :
        --------------------------------------------------------------------------------
        Ini    | Date          | Description
        --------------------------------------------------------------------------------
        pobrien  10/06/2011      Initial version.
        ================================================================================

      =end text

      =cut
      ***/
      -- Return code from called stored procedures.
      DECLARE @ReturnCode   INT;

      -- Count variable
      DECLARE @Counter   INT;

      -- Currnet date for tests
      DECLARE @CurrentDt   DATETIME;

      -- Log Specification Count
      DECLARE @LogSpecificationCount   INT;

      -- Log Level (LL) Error
      DECLARE @LL_Error   SMALLINT;
      -- Log Level (LL) Warning
      DECLARE @LL_Warning   SMALLINT;
      -- Log Level (LL) Info
      DECLARE @LL_Info   SMALLINT;
      -- Log Level (LL) Debug
      DECLARE @LL_Debug   SMALLINT;

      -- Initialize Variables
      -- --------------------
      -- Return code from called stored procedures
      SET @ReturnCode = 0;
      SET @po_Error_Reason_Cd = 0;

      -- Output parameters
      SET @po_Error_Reason_Cd = 0;
      SET @po_Log_Detail_ID = 0;

      -- Current date for tests
      SET @CurrentDt = getdate ();

      -- Log Level (LL) Error
      SET @LL_Error = 1;
      -- Log Level (LL) Warning
      SET @LL_Warning = 2;
      -- Log Level (LL) Info
      SET @LL_Info = 3;
      -- Log Level (LL) Debug
      SET @LL_Debug = 4;

      -- Log Specification Count. Assume we will find at least one log specification.
      SET @LogSpecificationCount = 0;

      -- Stops the message that shows the count of the number of rows affected by a
      -- Transact-SQL statement or stored procedure from being returned as part of the result set
      SET  NOCOUNT ON;

      -- If the log level is null, assume debug
      IF @pi_LOG_LEVEL_ID IS NULL
      BEGIN
         SET @po_Error_Reason_Cd = 1;
         RETURN @ReturnCode;
      END;

      -- If the log detail text is null, set it
      IF @pi_LOG_DETAIL_TEXT IS NULL
      BEGIN
         SET @po_Error_Reason_Cd = 2;
         RETURN @ReturnCode;
      END;


      BEGIN TRY
         -- If this logging call is for debugging ...
         IF (@pi_LOG_LEVEL_ID = @LL_Debug)
            BEGIN
               -- Find qualifying log specification rows
               SELECT @Counter = Count (*)
                 FROM dbo.LOG_SPEC
                WHERE (Log_Level_ID = @LL_Debug)
                  AND (COALESCE(ORGANIZATION_ID,'') = COALESCE(@pi_ORGANIZATION_ID,''))
                  AND (COALESCE([USER_ID],'') = COALESCE(@pi_UserID,''))
                  AND (COALESCE(PROCEDURE_NAME,'') = COALESCE(@pi_PROCEDURE_NAME,''))
                  AND ( (Log_Start_Date IS NOT NULL) AND (Log_Start_Date <= @CurrentDt) AND ((LOG_Stop_Date IS NULL) OR (Log_Stop_Date >= @CurrentDt)) );

          -- If we found matching rows, set the specification count
          IF (@Counter > 0)
            BEGIN
              SET @LogSpecificationCount = @Counter;
            END;
        END;

      -- If we found debugging log specifications or the requested logging level is less than than debugging, log it.
      IF ((@LogSpecificationCount > 0) OR (@pi_LOG_LEVEL_ID < @LL_Debug))
      BEGIN
        EXEC @ReturnCode = dbo.InsertLogDetail @pi_LOG_LEVEL_ID,@pi_ORGANIZATION_ID,@pi_UserID,@pi_PROCEDURE_NAME,@pi_LOG_DETAIL_TEXT,@pi_LOG_DIAGNOSTIC_NUM,@pi_LOG_DIAGNOSTIC_TX,@pi_LOG_REFERENCE_TAG, @po_Log_Detail_ID = @po_Log_Detail_ID OUTPUT;
      END;

    END TRY
    BEGIN CATCH
      -- Roll back any active or uncommittable transactions before
      -- logging any information in the Log_Detail table.
      -- XACT_STATE = 0 means there is no transaction and a commit or rollback operation would generate an error.
      -- XACT_STATE = -1 The transaction is in an uncommittable state
      IF XACT_STATE () <> 0
          BEGIN
              ROLLBACK TRANSACTION;
          END;

      -- Log error to the Log_Detail table
      EXECUTE dbo.LogEntry 1, NULL,NULL,'LogEntry','',NULL,NULL,NULL, @LogDetailID = @ReturnCode OUTPUT;
    END CATCH;

    RETURN @ReturnCode;
  END;
GO

IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = 'dbo' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'LogEntry')
  BEGIN
    PRINT '<<< CREATED PROCEDURE dbo.LogEntry >>>';
  END
ELSE
  BEGIN
    PRINT '<<< FAILED CREATING PROCEDURE dbo.LogEntry >>>';
  END;
GO

IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = 'dbo' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'PurgeLogDetail')
  BEGIN
    DROP PROCEDURE dbo.PurgeLogDetail;
    PRINT '<<< DROPPED PROCEDURE dbo.PurgeLogDetail >>>';
  END;
GO

CREATE PROCEDURE dbo.PurgeLogDetail(
  @pi_LOG_LEVEL_ID    SMALLINT = NULL
 ,@pi_CommitRowCount  INT = NULL)
AS
  BEGIN
    /***
    =pod

    =begin text

      ================================================================================
      Name : PurgeLogDetail

      Author : pobrien 10/06/2011

      Description : Purges the Log_Detail table based on retention days specificed in
                    the Log_Level table for the log level type received or the longest
                    retention period (Error type).

                    If @pi_LOG_LEVEL_ID is NULL, a default log level of DEBUG is used.

                    If @pi_CommitRowCount is NULL, a default row count of 10,000 is used.

      ===============================================================================
      Parameters :
      Name                                | I/O   | Description

      @pi_LOG_LEVEL_ID                      INPUT   Log level ID
      @pi_CommitRowCount                    INPUT   Commit deletes every x rows

      --------------------------------------------------------------------------------
      Error Reason codes:

      1 - An error has occurred while purging the Log_Detail table. Check the
          Log_Detail table for details.

      --------------------------------------------------------------------------------
      Return Value: 0
      Success : 0
      Failure : Non zero error log id from the ErrorLog table.

      Revisions :
      --------------------------------------------------------------------------------
      Ini    | Date          | Description
      --------------------------------------------------------------------------------
      pobrien  08/15/2011 09:14:08       Initial version.
      ================================================================================

    =end text

    =cut
    ***/
    -- Return code from called stored procedures.
    DECLARE @ReturnCode   INT;

    -- Default commit row count
    DECLARE @DefaultCommitRowCount   INT;

    -- Log_Detail.Log_Detail_ID
    DECLARE @LogDetailID INT;

    -- Log Level ID to process
    DECLARE @LogLevelID   SMALLINT;

    -- Commit every x rows
    DECLARE @CommitRowCount   INT;

    -- Number of rows to be purged
    DECLARE @TotalRowsDeleted   INT;

    -- General counter
    DECLARE @Counter   INT;

    -- Number of days to retain log entry
    DECLARE @RetainDaysNum   SMALLINT;

    -- Current date minus retain days + 1
    DECLARE @RetainDt   DATETIME;

    -- Log text
    DECLARE @LogText   VARCHAR(256);

    -- SYSTEM_USER
    DECLARE @User   VARCHAR(128);

    -- Log Level (LL) Error
    DECLARE @LL_Error   SMALLINT;
    -- Log Level (LL) Warning
    DECLARE @LL_Warning   SMALLINT;
    -- Log Level (LL) Info
    DECLARE @LL_Info   SMALLINT;
    -- Log Level (LL) Debug
    DECLARE @LL_Debug   SMALLINT;

    -- Initialize Variables
    -- --------------------
    -- Return code from stored procedures
    SET @ReturnCode            = 0;

    -- Default commit row count
    SET @DefaultCommitRowCount = 10000;

    -- Initialize count of rows deleted
    SET @TotalRowsDeleted      = 0;

    -- Log Level (LL) Error
    SET @LL_Error              = 1;
    -- Log Level (LL) Warning
    SET @LL_Warning            = 2;
    -- Log Level (LL) Info
    SET @LL_Info               = 3;
    -- Log Level (LL) Debug
    SET @LL_Debug              = 4;

    -- Stops the message that shows the count of the number of rows affected by a
    -- Transact-SQL statement or stored procedure from being returned as part of the result set
    SET  NOCOUNT ON;

    BEGIN TRY
      -- Set the log level id to use. If the user gave us something
      -- out of range, assume the longest retention (Error)
      IF @pi_LOG_LEVEL_ID IS NULL
        SET @pi_LOG_LEVEL_ID = @LL_Error
      ELSE
        IF (@pi_LOG_LEVEL_ID < @LL_Error OR
            @pi_LOG_LEVEL_ID > @LL_Debug)
          BEGIN
            SET @LogLevelID = @LL_Error;
          END
        ELSE
          BEGIN
            SET @LogLevelID = @pi_LOG_LEVEL_ID;
          END;

      IF @pi_CommitRowCount IS NULL
        SET @CommitRowCount = @DefaultCommitRowCount
      ELSE
        IF @pi_CommitRowCount < @DefaultCommitRowCount
          SET @CommitRowCount = @DefaultCommitRowCount
        ELSE
          SET @CommitRowCount = @pi_CommitRowCount;


      -- Get the days to retain the log level
      SELECT
      @RetainDaysNum = RETAIN_DAYS_NUM
      FROM
      dbo.LOG_LEVEL
      WHERE
      LOG_LEVEL_ID = @LogLevelID;

      -- Calulate date to which we compare log detail rows for deletion.
      SET @RetainDt      = DATEADD(
                             dd
                            ,-@RetainDaysNum + 1
                            ,getdate());


      -- Initialize the counter of rows deleted.
      SET @Counter       = 1;

      -- Delete the log detail rows
      WHILE (@Counter > 0)
        BEGIN
          -- Start the transaction
          BEGIN TRANSACTION;

          DELETE
            TOP (@CommitRowCount)
          FROM
            dbo.LOG_DETAIL
          WHERE
            LOG_LEVEL_ID = @LogLevelID AND
            LOG_DETAIL_DATE <= @RetainDt;

          -- Get count deleted
          SET @Counter          = @@ROWCOUNT;

          -- Increment total rows deleted
          SET @TotalRowsDeleted = @TotalRowsDeleted + @Counter;

          -- Commit the transaction
          COMMIT TRANSACTION;
        END;

      -- Construct the log text
      SET @LogText       = 'Log_Level_ID ' +
                           CAST(@LogLevelID AS VARCHAR(2)) +
                           ' Retain_Days_Num = ' +
                           CAST(@RetainDaysNum AS VARCHAR(4)) +
                           ' RetainDt = ' +
                           CONVERT(
                             VARCHAR(20)
                            ,@RetainDt
                            ,121) +
                           ' Deleted Count = ' +
                           Cast(@TotalRowsDeleted AS VARCHAR(20));

      -- Get the system user
      SET @User          = SYSTEM_USER;

      -- Log that we did a log detail purge
      EXEC dbo.LogEntry @LL_Info
                       ,NULL
                       ,@User
                       ,'PurgeLogDetail'
                       ,@LogText
                       ,NULL
                       ,NULL
                       ,'PurgeLogDetail'
                       ,@LogDetailID = @LogDetailID OUTPUT;
    END TRY
    BEGIN CATCH
      -- Roll back any active or uncommittable transactions before
      -- inserting information in the ErrorLog.
      -- XACT_STATE = 0 means there is no transaction and a commit or rollback operation would generate an error.
      -- XACT_STATE = -1 The transaction is in an uncommittable state
      IF XACT_STATE() <> 0
        BEGIN
          ROLLBACK TRANSACTION;
        END;

      -- Log the error
      EXEC dbo.LogEntry @LL_Error
                       ,NULL
                       ,NULL
                       ,'PurgeLogDetail'
                       ,'An error occurred while purging old log records'
                       ,NULL
                       ,NULL
                       ,'PurgeLogDetail'
                       ,@LogDetailID = @ReturnCode OUTPUT;
    END CATCH;

    RETURN @ReturnCode;
  END;
GO

IF EXISTS
     (SELECT
        1
      FROM
        INFORMATION_SCHEMA.ROUTINES
      WHERE
        SPECIFIC_SCHEMA = 'dbo' AND
        ROUTINE_TYPE = 'PROCEDURE' AND
        ROUTINE_NAME = 'PurgeLogDetail')
  BEGIN
    PRINT '<<< CREATED PROCEDURE dbo.PurgeLogDetail >>>';
  END
ELSE
  BEGIN
    PRINT '<<< FAILED CREATING PROCEDURE dbo.PurgeLogDetail >>>';
  END;
GO
