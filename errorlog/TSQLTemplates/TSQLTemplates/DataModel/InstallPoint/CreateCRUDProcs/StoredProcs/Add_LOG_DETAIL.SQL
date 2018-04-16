IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  routine_schema = N'dbo' AND routine_name = N'Add_LOG_DETAIL')
  BEGIN
    RAISERROR('Creating stub procedure "%s.%s".',10,1,'dbo','Add_LOG_DETAIL') WITH NOWAIT;

    DECLARE @stmnt NVARCHAR(200);
    SET @stmnt = N'CREATE PROCEDURE dbo.Add_LOG_DETAIL As Raiserror(''This is a stub routine and should not exist or be used'',16,1)';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        RAISERROR('ERROR: Unable to create stub procedure "%s.%s".',16,1,'dbo','Add_LOG_DETAIL');
      END;
  END
ELSE
  BEGIN
    RAISERROR('Procedure "%s.%s" exists.',10,1,'dbo','Add_LOG_DETAIL') WITH NOWAIT;
  END;
go

Alter PROCEDURE dbo.Add_LOG_DETAIL (
   @pi_LOG_LEVEL_ID smallint = NULL,
   @pi_LOG_DETAIL_DATE datetime = NULL,
   @pi_ORGANIZATION_ID varchar(128) = NULL,
   @pi_USER_ID varchar(128) = NULL,
   @pi_SYSTEM_USER_ID varchar(128) = NULL,
   @pi_PROCEDURE_NAME varchar(128) = NULL,
   @pi_LOG_DETAIL_TEXT varchar(256) = NULL,
   @pi_LOG_DIAGNOSTIC_NUM int = NULL,
   @pi_LOG_REFERENCE_TAG varchar(24) = NULL,
   @pi_TSQL_ERROR_LINE int = NULL,
   @pi_TSQL_ERROR_MESSAGE nvarchar(2048) = NULL,
   @pi_TSQL_ERROR_NUMBER int = NULL,
   @pi_TSQL_ERROR_PROCEDURE nvarchar(126) = NULL,
   @pi_TSQL_ERROR_SEVERITY int = NULL,
   @pi_TSQL_ERROR_STATE int = NULL,
   @po_LOG_DETAIL_ID INT OUTPUT,
   @po_Error_Reason_Cd INT OUTPUT
) AS
BEGIN
/***
=pod

=begin text

   ================================================================================
   Name : Add_LOG_DETAIL
   Author : POBrien 01/16/2013 10:47:12
   Description : Inserts a row in the dbo.LOG_DETAIL table

   Revision: $Rev$
   URL: $URL$
   Last Checked in: $Author$
   ===============================================================================
   Parameters :
   Name                                | I/O | Description

   @pi_LOG_LEVEL_ID                     INPUT  LOG_LEVEL_ID                    
   @pi_LOG_DETAIL_DATE                  INPUT  LOG_DETAIL_DATE                 
   @pi_ORGANIZATION_ID                  INPUT  ORGANIZATION_ID                 
   @pi_USER_ID                          INPUT  USER_ID                         
   @pi_SYSTEM_USER_ID                   INPUT  SYSTEM_USER_ID                  
   @pi_PROCEDURE_NAME                   INPUT  PROCEDURE_NAME                  
   @pi_LOG_DETAIL_TEXT                  INPUT  LOG_DETAIL_TEXT                 
   @pi_LOG_DIAGNOSTIC_NUM               INPUT  LOG_DIAGNOSTIC_NUM              
   @pi_LOG_REFERENCE_TAG                INPUT  LOG_REFERENCE_TAG               
   @pi_TSQL_ERROR_LINE                  INPUT  TSQL_ERROR_LINE                 
   @pi_TSQL_ERROR_MESSAGE               INPUT  TSQL_ERROR_MESSAGE              
   @pi_TSQL_ERROR_NUMBER                INPUT  TSQL_ERROR_NUMBER               
   @pi_TSQL_ERROR_PROCEDURE             INPUT  TSQL_ERROR_PROCEDURE            
   @pi_TSQL_ERROR_SEVERITY              INPUT  TSQL_ERROR_SEVERITY             
   @pi_TSQL_ERROR_STATE                 INPUT  TSQL_ERROR_STATE                
   @po_LOG_DETAIL_ID                    OUTPUT LOG_DETAIL_ID                   
   @po_Error_Reason_Cd                  OUTPUT Error reason code               

   --------------------------------------------------------------------------------
   Error Reason codes: 


   --------------------------------------------------------------------------------
   Return Value: 0
   Success : 0
   Failure : Non zero error log id from the ErrorLog table.

   Revisions :
   --------------------------------------------------------------------------------
   Ini    | Date          | Description
   --------------------------------------------------------------------------------
   POBrien  01/16/2013 10:47:12       Initial version.
   ================================================================================

=end text

=cut
***/

        -- Return code from called stored procedures.
        DECLARE @ReturnCode   INT;

        -- Log_Detail.Log_Detail_ID
        DECLARE @po_Log_Detail_ID INT;
        
        -- Creation date for row inserted
        DECLARE @CreateDt   DATETIME;

        -- Version number for row inserted
        DECLARE @VerNum   INT;

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
        -- Error Reason Code
        SET @po_Error_Reason_Cd = 0;

        -- Return code from called stored procedures
        SET @ReturnCode = 0;

        -- Identity column
        SET @po_LOG_DETAIL_ID = 0;

        -- On failure of validation check, the error reason code for the failure.
        SET @po_Error_Reason_Cd = 0;

        -- Creation date for all rows inserted.
        SET @CreateDt = getdate ();

        -- Version number for all rows inserted.
        SET @VerNum = 1;
	
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

        /*
        InstallPoint.dbo.LOG_DETAIL Table Information
        ----------------------------------------------------------------

        Identity Column Name is LOG_DETAIL_ID

        Primary Key Information
        -----------------------
        COLUMN_NAME                      KEY_SEQ  PK_NAME                         
        LOG_DETAIL_ID                    1        PK__LOG_DETA__2ACD950A6AFF59C4  

        Index Information
        -----------------
        Index Name                       Column Name                      Unique Unique Contraint Index Type      
        IX_LOG_DETAIL_LEVEL_DATE         LOG_DETAIL_DATE                  0      0                NONCLUSTERED    
        IX_LOG_DETAIL_LEVEL_DATE         LOG_LEVEL_ID                     0      0                NONCLUSTERED    

        Column Information
        ------------------
        COLUMN_NAME                      TYPE_NAME            COLUMN_SIZE  DECIMAL_DIGITS   COLUMN_DEF           ORDINAL_POSITION IS_NULLABLE     
        TSQL_ERROR_LINE                  int                  10           0                                     11               YES             
        PROCEDURE_NAME                   varchar              128          0                                     7                YES             
        LOG_LEVEL_ID                     smallint             5            0                                     2                NO              
        LOG_DETAIL_ID                    bigint               19           0                                     1                NO              
        TSQL_ERROR_STATE                 int                  10           0                                     16               YES             
        TSQL_ERROR_NUMBER                int                  10           0                                     13               YES             
        SYSTEM_USER_ID                   varchar              128          0                                     6                YES             
        LOG_DETAIL_DATE                  datetime             0            0                (getdate())          3                NO              
        LOG_DIAGNOSTIC_NUM               int                  10           0                                     9                YES             
        TSQL_ERROR_MESSAGE               nvarchar             2048         0                                     12               YES             
        TSQL_ERROR_PROCEDURE             nvarchar             126          0                                     14               YES             
        TSQL_ERROR_SEVERITY              int                  10           0                                     15               YES             
        LOG_DETAIL_TEXT                  varchar              256          0                                     8                NO              
        ORGANIZATION_ID                  varchar              128          0                                     4                YES             
        LOG_REFERENCE_TAG                varchar              24           0                                     10               YES             
        USER_ID                          varchar              128          0                                     5                YES             

        */

        BEGIN TRY
            -- Validate all the parameters.
            -- Set the @po_Error_Reason_Cd and @ReturnCode based on validation results.


            -- Validation code here


            -- If we did not pass validation of the parameters, set the reason code and return value.
            IF ((@po_Error_Reason_Cd <> 0) OR (@ReturnCode <> 0))
            BEGIN
                RETURN @ReturnCode;
            END;

            -- Start the transaction
            BEGIN TRANSACTION;

            -- Insert the row
            INSERT INTO dbo.LOG_DETAIL (
               LOG_LEVEL_ID
              ,LOG_DETAIL_DATE
              ,ORGANIZATION_ID
              ,USER_ID
              ,SYSTEM_USER_ID
              ,PROCEDURE_NAME
              ,LOG_DETAIL_TEXT
              ,LOG_DIAGNOSTIC_NUM
              ,LOG_REFERENCE_TAG
              ,TSQL_ERROR_LINE
              ,TSQL_ERROR_MESSAGE
              ,TSQL_ERROR_NUMBER
              ,TSQL_ERROR_PROCEDURE
              ,TSQL_ERROR_SEVERITY
              ,TSQL_ERROR_STATE
               )
               VALUES (
               @pi_LOG_LEVEL_ID
              ,@pi_LOG_DETAIL_DATE
              ,@pi_ORGANIZATION_ID
              ,@pi_USER_ID
              ,@pi_SYSTEM_USER_ID
              ,@pi_PROCEDURE_NAME
              ,@pi_LOG_DETAIL_TEXT
              ,@pi_LOG_DIAGNOSTIC_NUM
              ,@pi_LOG_REFERENCE_TAG
              ,@pi_TSQL_ERROR_LINE
              ,@pi_TSQL_ERROR_MESSAGE
              ,@pi_TSQL_ERROR_NUMBER
              ,@pi_TSQL_ERROR_PROCEDURE
              ,@pi_TSQL_ERROR_SEVERITY
              ,@pi_TSQL_ERROR_STATE
               );

            -- Get the Identity value for the row just inserted.
            SET @po_LOG_DETAIL_ID = SCOPE_IDENTITY ();

            
            -- Commit the transaction
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            -- Roll back any active or uncommittable transactions before
            -- inserting information in the ErrorLog.
            -- XACT_STATE = 0 means there is no transaction and a commit or rollback operation would generate an error.
            -- XACT_STATE = -1 The transaction is in an uncommittable state
            IF XACT_STATE () <> 0
                BEGIN
                    ROLLBACK TRANSACTION;
                END;

            -- Log error to the ErrorLog table
            Exec dbo.LogEntry 
		@LL_Error, -- Log_Level_ID
		NULL, -- Organization_ID
		NULL, -- UserID
		'Add_LOG_DETAIL', -- Procedure_Name
		'Procedure failure catch block',  -- Log_Detail_Text
		0, -- Log_Diagnostic_Num
		'CATCH', -- Log_Reference_Tag
		@po_Log_Detail_ID = @po_Log_Detail_ID out, -- Log_Detail_ID
		@po_Error_Reason_Cd = @po_Error_Reason_Cd out; -- Error_Reason_Cd
            Set @ReturnCode = @po_Log_Detail_ID;
        END CATCH;

        RETURN @ReturnCode;
    END;
GO

IF EXISTS
       (SELECT 1
          FROM INFORMATION_SCHEMA.ROUTINES
         WHERE ROUTINE_SCHEMA = 'dbo' AND ROUTINE_NAME = 'Add_LOG_DETAIL')
    BEGIN
        RAISERROR('Altered procedure "%s.%s".',10,1,'dbo','Add_LOG_DETAIL') WITH NOWAIT;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'SVN Revision',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'PROCEDURE',
		                            @level1name = 'Add_LOG_DETAIL';
	end try
	begin catch
		set nocount on;
	end catch;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'MS_Description',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'Procedure',
		                            @level1name = 'Add_LOG_DETAIL';
	end try
	begin catch
		set nocount on;
	end catch;

        EXEC sp_addextendedproperty @name  = 'SVN Revision',
	                            @value      = '$Rev$',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'PROCEDURE',
	                            @level1name = 'Add_LOG_DETAIL';

        EXEC sp_addextendedproperty @name  = 'MS_Description',
	                            @value      = 'dbo.Add_LOG_DETAIL performs an insert of a row into the dbo.LOG_DETAIL',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'Procedure',
	                            @level1name = 'Add_LOG_DETAIL';
    END
ELSE
    BEGIN
        RAISERROR('ERROR: Unable to alter procedure "%s.%s".',16,1,'dbo','Add_LOG_DETAIL');
    END;
GO

