IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  routine_schema = N'dbo' AND routine_name = N'Get_TASK_INSTANCE')
  BEGIN
    RAISERROR('Creating stub procedure "%s.%s".',10,1,'dbo','Get_TASK_INSTANCE') WITH NOWAIT;

    DECLARE @stmnt NVARCHAR(200);
    SET @stmnt = N'CREATE PROCEDURE dbo.Get_TASK_INSTANCE As Raiserror(''This is a stub routine and should not exist or be used'',16,1)';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        RAISERROR('ERROR: Unable to create stub procedure "%s.%s".',16,1,'dbo','Get_TASK_INSTANCE');
      END;
  END
ELSE
  BEGIN
    RAISERROR('Procedure "%s.%s" exists.',10,1,'dbo','Get_TASK_INSTANCE') WITH NOWAIT;
  END;
go

Alter PROCEDURE dbo.Get_TASK_INSTANCE (
   @pi_Task_Instance_ID bigint = NULL,
   @pi_Server_ID int = NULL,
   @pi_Organization_ID int = NULL,
   @pi_Task_Status_Cd int = NULL,
   @pi_Instance_File_Nm varchar(200) = NULL,
   @pi_Task_ID int = NULL,
   @pi_Request_Ticket_Num int = NULL,
   @pi_Completion_Wait_Tm datetime = NULL,
   @pi_Scheduled_Completion_Dt datetime = NULL,
   @pi_Scheduled_Completion_Dt_1 datetime = NULL,
   @pi_Actual_Completion_Dt datetime = NULL,
   @pi_Create_User_ID nvarchar(128) = NULL,
   @pi_Create_Dt datetime = NULL,
   @pi_Update_User_ID nvarchar(128) = NULL,
   @pi_Update_Dt datetime = NULL,
   @pi_Task_Instance_Ver_Num int = NULL,
   @po_Error_Reason_Cd INT OUTPUT
) AS
BEGIN
/***
=pod

=begin text

   ================================================================================
   Name : Get_TASK_INSTANCE
   Author : POBrien 01/16/2013 10:47:13
   Description : Selects a row from dbo.TASK_INSTANCE table

   Revision: $Rev$
   URL: $URL$
   Last Checked in: $Author$
   ===============================================================================
   Parameters :
   Name                                | I/O | Description
   @pi_Task_Instance_ID                 INPUT  Task_Instance_ID                
   @pi_Server_ID                        INPUT  Server_ID                       
   @pi_Organization_ID                  INPUT  Organization_ID                 
   @pi_Task_Status_Cd                   INPUT  Task_Status_Cd                  
   @pi_Instance_File_Nm                 INPUT  Instance_File_Nm                
   @pi_Task_ID                          INPUT  Task_ID                         
   @pi_Request_Ticket_Num               INPUT  Request_Ticket_Num              
   @pi_Completion_Wait_Tm               INPUT  Completion_Wait_Tm              
   @pi_Scheduled_Completion_Dt          INPUT  Scheduled_Completion_Dt         
   @pi_Scheduled_Completion_Dt_1        INPUT  Scheduled_Completion_Dt_1       
   @pi_Actual_Completion_Dt             INPUT  Actual_Completion_Dt            
   @pi_Create_User_ID                   INPUT  Create_User_ID                  
   @pi_Create_Dt                        INPUT  Create_Dt                       
   @pi_Update_User_ID                   INPUT  Update_User_ID                  
   @pi_Update_Dt                        INPUT  Update_Dt                       
   @pi_Task_Instance_Ver_Num            INPUT  Task_Instance_Ver_Num           
   @po_Error_Reason_Cd                  OUTPUT Error reason code               
   
   --------------------------------------------------------------------------------
   Error Reason codes: 

       1 - No rows qualified for the select

   --------------------------------------------------------------------------------
   Return Value: 0
   Success : 0
   Failure : Non zero error log id from the ErrorLog table.

   Revisions :
   --------------------------------------------------------------------------------
   Ini    | Date          | Description
   --------------------------------------------------------------------------------
   POBrien  01/16/2013 10:47:13       Initial version.
   ================================================================================

=end text

=cut
***/

        -- Return code from called stored procedures.
        DECLARE @ReturnCode   INT;

        -- Log_Detail.Log_Detail_ID
        DECLARE @po_Log_Detail_ID INT;

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

        -- On failure of validation check, the error reason code for the failure.
        SET @po_Error_Reason_Cd = 0;
	
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
        InstallPoint.dbo.TASK_INSTANCE Table Information
        ----------------------------------------------------------------

        Primary Key Information
        -----------------------
        COLUMN_NAME                      KEY_SEQ  PK_NAME                         
        Task_Instance_ID                 1        PK__TASK_INS__F5D7B1C9B319A4AF  

        Index Information
        -----------------
        Index Name                       Column Name                      Unique Unique Contraint Index Type      

        Foreign Key Information containing primary key of the table and all foreign keys that refer to it
        -------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        Task_Instance_ID                 InstallPoint         dbo              TASK_LOG                         Task_Instance_ID                 1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefTASK_INSTANCE19               PK__TASK_INS__F5D7B1C9B319A4AF  

        Foreign Key Information for all foreign keys in the table and the primary keys to which they refer
        --------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        Task_Status_Cd                   InstallPoint         dbo              TASK_INSTANCE                    Task_Status_Cd                   1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefTASK_STATUS20                 PK__TASK_STA__E9B54BC7887FC3D5  

        Column Information
        ------------------
        COLUMN_NAME                      TYPE_NAME            COLUMN_SIZE  DECIMAL_DIGITS   COLUMN_DEF           ORDINAL_POSITION IS_NULLABLE     
        Actual_Completion_Dt             datetime             0            0                                     11               YES             
        Request_Ticket_Num               int                  10           0                                     7                YES             
        Server_ID                        int                  10           0                                     2                YES             
        Task_Instance_ID                 bigint               19           0                                     1                NO              
        Task_Instance_Ver_Num            int                  10           0                                     16               NO              
        Create_Dt                        datetime             0            0                                     13               NO              
        Task_ID                          int                  10           0                                     6                NO              
        Organization_ID                  int                  10           0                                     3                NO              
        Scheduled_Completion_Dt          datetime             0            0                                     9                YES             
        Create_User_ID                   nvarchar             128          0                                     12               NO              
        Update_User_ID                   nvarchar             128          0                                     14               NO              
        Update_Dt                        datetime             0            0                                     15               NO              
        Completion_Wait_Tm               datetime             0            0                                     8                YES             
        Task_Status_Cd                   int                  10           0                                     4                NO              
        Scheduled_Completion_Dt_1        datetime             0            0                                     10               YES             
        Instance_File_Nm                 varchar              200          0                                     5                YES             

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

            -- Select a row
            Select
               Task_Instance_ID,
               Server_ID,
               Organization_ID,
               Task_Status_Cd,
               Instance_File_Nm,
               Task_ID,
               Request_Ticket_Num,
               Completion_Wait_Tm,
               Scheduled_Completion_Dt,
               Scheduled_Completion_Dt_1,
               Actual_Completion_Dt,
               Create_User_ID,
               Create_Dt,
               Update_User_ID,
               Update_Dt,
               Task_Instance_Ver_Num
            FROM dbo.TASK_INSTANCE
            WHERE Task_Instance_ID = @pi_Task_Instance_ID;

            -- Make sure we selected at least one row
            IF (@@ROWCOUNT = 0)
            BEGIN
                -- No row qualified for selection based on where clause
                SET @po_Error_Reason_Cd = 1;
            END;

        END TRY
        BEGIN CATCH
            -- Print the error information
            EXECUTE dbo.p_admPrintError ;

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
               @LL_Error,                       -- Log_Level_ID
               NULL,                            -- Organization_ID
               NULL,                            -- UserID
               'Get_TASK_INSTANCE',                        -- Procedure_Name
               'Procedure failure catch block', -- Log_Detail_Text
               0,                               -- Log_Diagnostic_Num
               'CATCH',                         -- Log_Reference_Tag
               @po_Log_Detail_ID = @po_Log_Detail_ID out,      -- Log_Detail_ID
               @po_Error_Reason_Cd = @po_Error_Reason_Cd out;  -- Error_Reason_Cd

            Set @ReturnCode = @po_Log_Detail_ID;
        END CATCH;

        RETURN @ReturnCode;
    END;
GO

IF EXISTS
       (SELECT 1
          FROM INFORMATION_SCHEMA.ROUTINES
         WHERE ROUTINE_SCHEMA = 'dbo' AND ROUTINE_NAME = 'Get_TASK_INSTANCE')
    BEGIN
        RAISERROR('Altered procedure "%s.%s".',10,1,'dbo','Get_TASK_INSTANCE') WITH NOWAIT;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'SVN Revision',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'PROCEDURE',
		                            @level1name = 'Get_TASK_INSTANCE';
	end try
	begin catch
		set nocount on;
	end catch;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'MS_Description',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'Procedure',
		                            @level1name = 'Get_TASK_INSTANCE';
	end try
	begin catch
		set nocount on;
	end catch;

        EXEC sp_addextendedproperty @name  = 'SVN Revision',
	                            @value      = '$Rev$',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'PROCEDURE',
	                            @level1name = 'Get_TASK_INSTANCE';

        EXEC sp_addextendedproperty @name  = 'MS_Description',
	                            @value      = 'dbo.Get_TASK_INSTANCE performs a select of a row from the dbo.TASK_INSTANCE',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'Procedure',
	                            @level1name = 'Get_TASK_INSTANCE';
    END
ELSE
    BEGIN
        RAISERROR('ERROR: Unable to alter procedure "%s.%s".',16,1,'dbo','Get_TASK_INSTANCE');
    END;
GO

