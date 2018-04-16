IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  routine_schema = N'dbo' AND routine_name = N'Get_SCHEDULE')
  BEGIN
    RAISERROR('Creating stub procedure "%s.%s".',10,1,'dbo','Get_SCHEDULE') WITH NOWAIT;

    DECLARE @stmnt NVARCHAR(200);
    SET @stmnt = N'CREATE PROCEDURE dbo.Get_SCHEDULE As Raiserror(''This is a stub routine and should not exist or be used'',16,1)';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        RAISERROR('ERROR: Unable to create stub procedure "%s.%s".',16,1,'dbo','Get_SCHEDULE');
      END;
  END
ELSE
  BEGIN
    RAISERROR('Procedure "%s.%s" exists.',10,1,'dbo','Get_SCHEDULE') WITH NOWAIT;
  END;
go

Alter PROCEDURE dbo.Get_SCHEDULE (
   @pi_Schedule_Nm varchar(100) = NULL,
   @pi_Organization_ID int = NULL,
   @pi_Schedule_Dt datetime = NULL,
   @pi_Completion_Dt datetime = NULL,
   @pi_Request_Ticket_Num int = NULL,
   @pi_Create_User_ID nvarchar(128) = NULL,
   @pi_Create_Dt datetime = NULL,
   @pi_Update_User_ID nvarchar(128) = NULL,
   @pi_Update_Dt datetime = NULL,
   @pi_Schedule_Ver_Num int = NULL,
   @pi_Schedule_ID INT,
   @po_Error_Reason_Cd INT OUTPUT
) AS
BEGIN
/***
=pod

=begin text

   ================================================================================
   Name : Get_SCHEDULE
   Author : POBrien 01/16/2013 10:47:13
   Description : Selects a row from dbo.SCHEDULE table

   Revision: $Rev$
   URL: $URL$
   Last Checked in: $Author$
   ===============================================================================
   Parameters :
   Name                                | I/O | Description
   @pi_Schedule_Nm                      INPUT  Schedule_Nm                     
   @pi_Organization_ID                  INPUT  Organization_ID                 
   @pi_Schedule_Dt                      INPUT  Schedule_Dt                     
   @pi_Completion_Dt                    INPUT  Completion_Dt                   
   @pi_Request_Ticket_Num               INPUT  Request_Ticket_Num              
   @pi_Create_User_ID                   INPUT  Create_User_ID                  
   @pi_Create_Dt                        INPUT  Create_Dt                       
   @pi_Update_User_ID                   INPUT  Update_User_ID                  
   @pi_Update_Dt                        INPUT  Update_Dt                       
   @pi_Schedule_Ver_Num                 INPUT  Schedule_Ver_Num                
   @pi_Schedule_ID                      INPUT  Schedule_ID                     
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
        InstallPoint.dbo.SCHEDULE Table Information
        ----------------------------------------------------------------

        Identity Column Name is Schedule_ID

        Primary Key Information
        -----------------------
        COLUMN_NAME                      KEY_SEQ  PK_NAME                         
        Schedule_ID                      1        PK__SCHEDULE__8C4D3BBB58901E88  

        Index Information
        -----------------
        Index Name                       Column Name                      Unique Unique Contraint Index Type      

        Foreign Key Information containing primary key of the table and all foreign keys that refer to it
        -------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        Schedule_ID                      InstallPoint         dbo              SCHEDULE_DETAIL                  Schedule_ID                      1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefSCHEDULE100                   PK__SCHEDULE__8C4D3BBB58901E88  

        Foreign Key Information for all foreign keys in the table and the primary keys to which they refer
        --------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        Organization_ID                  InstallPoint         dbo              SCHEDULE                         Organization_ID                  1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefORGANIZATION99                PK__ORGANIZA__A6FA250693BD3430  

        Column Information
        ------------------
        COLUMN_NAME                      TYPE_NAME            COLUMN_SIZE  DECIMAL_DIGITS   COLUMN_DEF           ORDINAL_POSITION IS_NULLABLE     
        Request_Ticket_Num               int                  10           0                                     6                YES             
        Schedule_Ver_Num                 int                  10           0                                     11               NO              
        Organization_ID                  int                  10           0                                     3                NO              
        Create_User_ID                   nvarchar             128          0                                     7                NO              
        Update_User_ID                   nvarchar             128          0                                     9                NO              
        Schedule_Nm                      varchar              100          0                                     2                YES             
        Create_Dt                        datetime             0            0                                     8                NO              
        Schedule_ID                      bigint               19           0                                     1                NO              
        Schedule_Dt                      datetime             0            0                                     4                YES             
        Update_Dt                        datetime             0            0                                     10               NO              
        Completion_Dt                    datetime             0            0                                     5                YES             

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
               Schedule_ID,
               Schedule_Nm,
               Organization_ID,
               Schedule_Dt,
               Completion_Dt,
               Request_Ticket_Num,
               Create_User_ID,
               Create_Dt,
               Update_User_ID,
               Update_Dt,
               Schedule_Ver_Num
            FROM dbo.SCHEDULE
            WHERE Schedule_ID = @pi_Schedule_ID;

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
               'Get_SCHEDULE',                        -- Procedure_Name
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
         WHERE ROUTINE_SCHEMA = 'dbo' AND ROUTINE_NAME = 'Get_SCHEDULE')
    BEGIN
        RAISERROR('Altered procedure "%s.%s".',10,1,'dbo','Get_SCHEDULE') WITH NOWAIT;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'SVN Revision',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'PROCEDURE',
		                            @level1name = 'Get_SCHEDULE';
	end try
	begin catch
		set nocount on;
	end catch;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'MS_Description',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'Procedure',
		                            @level1name = 'Get_SCHEDULE';
	end try
	begin catch
		set nocount on;
	end catch;

        EXEC sp_addextendedproperty @name  = 'SVN Revision',
	                            @value      = '$Rev$',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'PROCEDURE',
	                            @level1name = 'Get_SCHEDULE';

        EXEC sp_addextendedproperty @name  = 'MS_Description',
	                            @value      = 'dbo.Get_SCHEDULE performs a select of a row from the dbo.SCHEDULE',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'Procedure',
	                            @level1name = 'Get_SCHEDULE';
    END
ELSE
    BEGIN
        RAISERROR('ERROR: Unable to alter procedure "%s.%s".',16,1,'dbo','Get_SCHEDULE');
    END;
GO

