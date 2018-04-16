IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  routine_schema = N'dbo' AND routine_name = N'Del_DB_CONTROL')
  BEGIN
    RAISERROR('Creating stub procedure "%s.%s".',10,1,'dbo','Del_DB_CONTROL') WITH NOWAIT;

    DECLARE @stmnt NVARCHAR(200);
    SET @stmnt = N'CREATE PROCEDURE dbo.Del_DB_CONTROL As Raiserror(''This is a stub routine and should not exist or be used'',16,1)';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        RAISERROR('ERROR: Unable to create stub procedure "%s.%s".',16,1,'dbo','Del_DB_CONTROL');
      END;
  END
ELSE
  BEGIN
    RAISERROR('Procedure "%s.%s" exists.',10,1,'dbo','Del_DB_CONTROL') WITH NOWAIT;
  END;
go

Alter PROCEDURE dbo.Del_DB_CONTROL (
   @pi_Structure_Version_Tag varchar(20) = NULL,
   @pi_Code_Version_Tag varchar(20) = NULL,
   @pi_Test_Env_Flg bit = NULL,
   @pi_Delta_Comment_Tx varchar(100) = NULL,
   @pi_Last_Change_Process_Dt datetime = NULL,
   @pi_DB_Control_Ver_Num smallint = NULL,
   @po_Error_Reason_Cd INT OUTPUT
) AS
BEGIN
/***
=pod

=begin text

   ================================================================================
   Name : Del_DB_CONTROL
   Author : POBrien 01/16/2013 08:09:01
   Description : Deletes a row from the dbo.DB_CONTROL table

   Revision: $Rev$
   URL: $URL$
   Last Checked in: $Author$
   ===============================================================================
   Parameters :
   Name                                | I/O | Description
   @pi_Structure_Version_Tag            INPUT  Structure_Version_Tag           
   @pi_Code_Version_Tag                 INPUT  Code_Version_Tag                
   @pi_Test_Env_Flg                     INPUT  Test_Env_Flg                    
   @pi_Delta_Comment_Tx                 INPUT  Delta_Comment_Tx                
   @pi_Last_Change_Process_Dt           INPUT  Last_Change_Process_Dt          
   @pi_DB_Control_Ver_Num               INPUT  DB_Control_Ver_Num              
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
   POBrien  01/16/2013 08:09:01       Initial version.
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
        InstallPoint.dbo.DB_CONTROL Table Information
        ----------------------------------------------------------------

        Index Information
        -----------------
        Index Name                       Column Name                      Unique Unique Contraint Index Type      

        Column Information
        ------------------
        COLUMN_NAME                      TYPE_NAME            COLUMN_SIZE  DECIMAL_DIGITS   COLUMN_DEF           ORDINAL_POSITION IS_NULLABLE     
        DB_Control_Ver_Num               smallint             5            0                ((1))                6                NO              
        Delta_Comment_Tx                 varchar              100          0                                     4                YES             
        Structure_Version_Tag            varchar              20           0                                     1                YES             
        Test_Env_Flg                     bit                  0            0                ((0))                3                NO              
        Code_Version_Tag                 varchar              20           0                                     2                YES             
        Last_Change_Process_Dt           datetime             0            0                                     5                YES             

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

            -- Increment version number
            IF (@pi_DB_Control_Ver_Num >= 10000)
            BEGIN
               SET @VerNum = 1;
            END
            ELSE
            BEGIN
               SET @VerNum = @pi_DB_Control_Ver_Num + 1;
            END;

            -- Start the transaction
            BEGIN TRANSACTION;

            -- Delete the row
            DELETE FROM dbo.DB_CONTROL
            WHERE Structure_Version_Tag = @pi_Structure_Version_Tag
              AND Code_Version_Tag = @pi_Code_Version_Tag
              AND Test_Env_Flg = @pi_Test_Env_Flg
              AND Delta_Comment_Tx = @pi_Delta_Comment_Tx
              AND Last_Change_Process_Dt = @pi_Last_Change_Process_Dt
              AND DB_Control_Ver_Num = @pi_DB_Control_Ver_Num;

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
		'Del_DB_CONTROL', -- Procedure_Name
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
         WHERE ROUTINE_SCHEMA = 'dbo' AND ROUTINE_NAME = 'Del_DB_CONTROL')
    BEGIN
        RAISERROR('Altered procedure "%s.%s".',10,1,'dbo','Del_DB_CONTROL') WITH NOWAIT;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'SVN Revision',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'PROCEDURE',
		                            @level1name = 'Del_DB_CONTROL';
	end try
	begin catch
		set nocount on;
	end catch;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'MS_Description',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'Procedure',
		                            @level1name = 'Del_DB_CONTROL';
	end try
	begin catch
		set nocount on;
	end catch;

        EXEC sp_addextendedproperty @name  = 'SVN Revision',
	                            @value      = '$Rev$',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'PROCEDURE',
	                            @level1name = 'Del_DB_CONTROL';

        EXEC sp_addextendedproperty @name  = 'MS_Description',
	                            @value      = 'dbo.Del_DB_CONTROL performs a delete of a row from the dbo.DB_CONTROL',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'Procedure',
	                            @level1name = 'Del_DB_CONTROL';
    END
ELSE
    BEGIN
        RAISERROR('ERROR: Unable to alter procedure "%s.%s".',16,1,'dbo','Del_DB_CONTROL');
    END;
GO

