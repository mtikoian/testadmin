IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  routine_schema = N'dbo' AND routine_name = N'Del_LOG_SPEC')
  BEGIN
    RAISERROR('Creating stub procedure "%s.%s".',10,1,'dbo','Del_LOG_SPEC') WITH NOWAIT;

    DECLARE @stmnt NVARCHAR(200);
    SET @stmnt = N'CREATE PROCEDURE dbo.Del_LOG_SPEC As Raiserror(''This is a stub routine and should not exist or be used'',16,1)';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        RAISERROR('ERROR: Unable to create stub procedure "%s.%s".',16,1,'dbo','Del_LOG_SPEC');
      END;
  END
ELSE
  BEGIN
    RAISERROR('Procedure "%s.%s" exists.',10,1,'dbo','Del_LOG_SPEC') WITH NOWAIT;
  END;
go

Alter PROCEDURE dbo.Del_LOG_SPEC (
   @pi_LOG_LEVEL_ID smallint = NULL,
   @pi_ORGANIZATION_ID varchar(128) = NULL,
   @pi_USER_ID varchar(128) = NULL,
   @pi_PROCEDURE_NAME varchar(128) = NULL,
   @pi_LOG_START_DATE datetime = NULL,
   @pi_LOG_STOP_DATE datetime = NULL,
   @pi_LOG_SPEC_ID INT,
   @po_Error_Reason_Cd INT OUTPUT
) AS
BEGIN
/***
=pod

=begin text

   ================================================================================
   Name : Del_LOG_SPEC
   Author : POBrien 01/16/2013 10:47:12
   Description : Deletes a row from the dbo.LOG_SPEC table

   Revision: $Rev$
   URL: $URL$
   Last Checked in: $Author$
   ===============================================================================
   Parameters :
   Name                                | I/O | Description
   @pi_LOG_LEVEL_ID                     INPUT  LOG_LEVEL_ID                    
   @pi_ORGANIZATION_ID                  INPUT  ORGANIZATION_ID                 
   @pi_USER_ID                          INPUT  USER_ID                         
   @pi_PROCEDURE_NAME                   INPUT  PROCEDURE_NAME                  
   @pi_LOG_START_DATE                   INPUT  LOG_START_DATE                  
   @pi_LOG_STOP_DATE                    INPUT  LOG_STOP_DATE                   
   @pi_LOG_SPEC_ID                      INPUT  LOG_SPEC_ID                     
   @po_Error_Reason_Cd                  OUTPUT Error reason code               
   
   --------------------------------------------------------------------------------
   Error Reason codes: 

       1 - No rows qualified for delete based on where clause
       2 - Too many rows qualified for delete based on where clause

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
        
        -- Update date for row logically deleted
        DECLARE @UpdateDt   DATETIME;

        -- Log Level (LL) Error
        DECLARE @LL_Error   SMALLINT;
        -- Log Level (LL) Warning
        DECLARE @LL_Warning   SMALLINT;
        -- Log Level (LL) Info
        DECLARE @LL_Info   SMALLINT;
        -- Log Level (LL) Debug
        DECLARE @LL_Debug   SMALLINT;

        DECLARE @VerNum INT;

        -- Initialize Variables
        -- --------------------
        -- Error Reason Code
        SET @po_Error_Reason_Cd = 0;

        -- Return code from called stored procedures
        SET @ReturnCode = 0;

        -- On failure of validation check, the error reason code for the failure.
        SET @po_Error_Reason_Cd = 0;

        -- Update date for rows logically deleted.
        SET @UpdateDt = getdate ();
	
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
        InstallPoint.dbo.LOG_SPEC Table Information
        ----------------------------------------------------------------

        Identity Column Name is LOG_SPEC_ID

        Primary Key Information
        -----------------------
        COLUMN_NAME                      KEY_SEQ  PK_NAME                         
        LOG_SPEC_ID                      1        PK__LOG_SPEC__45BDF49E4798F5D7  

        Index Information
        -----------------
        Index Name                       Column Name                      Unique Unique Contraint Index Type      

        Column Information
        ------------------
        COLUMN_NAME                      TYPE_NAME            COLUMN_SIZE  DECIMAL_DIGITS   COLUMN_DEF           ORDINAL_POSITION IS_NULLABLE     
        LOG_START_DATE                   datetime             0            0                                     6                YES             
        USER_ID                          varchar              128          0                                     4                YES             
        LOG_SPEC_ID                      int                  10           0                                     1                NO              
        ORGANIZATION_ID                  varchar              128          0                                     3                YES             
        LOG_STOP_DATE                    datetime             0            0                                     7                YES             
        LOG_LEVEL_ID                     smallint             5            0                                     2                YES             
        PROCEDURE_NAME                   varchar              128          0                                     5                YES             

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

            -- Delete the row
            DELETE FROM dbo.LOG_SPEC
            WHERE LOG_SPEC_ID = @pi_LOG_SPEC_ID;

            -- Make sure we Deleted one row
            IF (@@ROWCOUNT = 0)
            BEGIN
                -- No row qualified for delete based on where clause
                SET @po_Error_Reason_Cd = 1;
                RAISERROR ('No rows qualified for delete based on where clause.',16,1);
            END
            
            ELSE IF (@@ROWCOUNT > 1)
            BEGIN
                -- Too many rows qualified for delete based on where clause
                SET @po_Error_Reason_Cd = 2;
                RAISERROR ('Too many rows qualified for delete based on where clause.',16,1);
            END;

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
		'Del_LOG_SPEC', -- Procedure_Name
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
         WHERE ROUTINE_SCHEMA = 'dbo' AND ROUTINE_NAME = 'Del_LOG_SPEC')
    BEGIN
        RAISERROR('Altered procedure "%s.%s".',10,1,'dbo','Del_LOG_SPEC') WITH NOWAIT;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'SVN Revision',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'PROCEDURE',
		                            @level1name = 'Del_LOG_SPEC';
	end try
	begin catch
		set nocount on;
	end catch;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'MS_Description',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'Procedure',
		                            @level1name = 'Del_LOG_SPEC';
	end try
	begin catch
		set nocount on;
	end catch;

        EXEC sp_addextendedproperty @name  = 'SVN Revision',
	                            @value      = '$Rev$',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'PROCEDURE',
	                            @level1name = 'Del_LOG_SPEC';

        EXEC sp_addextendedproperty @name  = 'MS_Description',
	                            @value      = 'dbo.Del_LOG_SPEC performs a delete of a row from the dbo.LOG_SPEC',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'Procedure',
	                            @level1name = 'Del_LOG_SPEC';
    END
ELSE
    BEGIN
        RAISERROR('ERROR: Unable to alter procedure "%s.%s".',16,1,'dbo','Del_LOG_SPEC');
    END;
GO

