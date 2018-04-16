IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  routine_schema = N'dbo' AND routine_name = N'Add_SERVER')
  BEGIN
    RAISERROR('Creating stub procedure "%s.%s".',10,1,'dbo','Add_SERVER') WITH NOWAIT;

    DECLARE @stmnt NVARCHAR(200);
    SET @stmnt = N'CREATE PROCEDURE dbo.Add_SERVER As Raiserror(''This is a stub routine and should not exist or be used'',16,1)';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        RAISERROR('ERROR: Unable to create stub procedure "%s.%s".',16,1,'dbo','Add_SERVER');
      END;
  END
ELSE
  BEGIN
    RAISERROR('Procedure "%s.%s" exists.',10,1,'dbo','Add_SERVER') WITH NOWAIT;
  END;
go

Alter PROCEDURE dbo.Add_SERVER (
   @pi_Environment_Type_Cd int = NULL,
   @pi_Server_Nm varchar(40) = NULL,
   @pi_Server_Dsc varchar(200) = NULL,
   @pi_Virtual_Fl bit = NULL,
   @pi_Server_Active_Fl bit = NULL,
   @pi_Server_Abrx_Tx varchar(10) = NULL,
   @pi_Create_User_ID nvarchar(128) = NULL,
   @pi_Create_Dt datetime = NULL,
   @pi_Update_User_ID nvarchar(128) = NULL,
   @pi_Update_Dt datetime = NULL,
   @pi_Server_Ver_Num int = NULL,
   @po_Server_ID INT OUTPUT,
   @po_Error_Reason_Cd INT OUTPUT
) AS
BEGIN
/***
=pod

=begin text

   ================================================================================
   Name : Add_SERVER
   Author : POBrien 01/16/2013 08:09:03
   Description : Inserts a row in the dbo.SERVER table

   Revision: $Rev$
   URL: $URL$
   Last Checked in: $Author$
   ===============================================================================
   Parameters :
   Name                                | I/O | Description

   @pi_Environment_Type_Cd              INPUT  Environment_Type_Cd             
   @pi_Server_Nm                        INPUT  Server_Nm                       
   @pi_Server_Dsc                       INPUT  Server_Dsc                      
   @pi_Virtual_Fl                       INPUT  Virtual_Fl                      
   @pi_Server_Active_Fl                 INPUT  Server_Active_Fl                
   @pi_Server_Abrx_Tx                   INPUT  Server_Abrx_Tx                  
   @pi_Create_User_ID                   INPUT  Create_User_ID                  
   @pi_Create_Dt                        INPUT  Create_Dt                       
   @pi_Update_User_ID                   INPUT  Update_User_ID                  
   @pi_Update_Dt                        INPUT  Update_Dt                       
   @pi_Server_Ver_Num                   INPUT  Server_Ver_Num                  
   @po_Server_ID                        OUTPUT Server_ID                       
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
   POBrien  01/16/2013 08:09:03       Initial version.
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
        SET @po_Server_ID = 0;

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
        InstallPoint.dbo.SERVER Table Information
        ----------------------------------------------------------------

        Identity Column Name is Server_ID

        Primary Key Information
        -----------------------
        COLUMN_NAME                      KEY_SEQ  PK_NAME                         
        Server_ID                        1        PK__SERVER__FED35533B9A2790E    

        Index Information
        -----------------
        Index Name                       Column Name                      Unique Unique Contraint Index Type      

        Foreign Key Information containing primary key of the table and all foreign keys that refer to it
        -------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        Server_ID                        InstallPoint         dbo              TASK_INSTANCE                    Server_ID                        1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefSERVER67                      PK__SERVER__FED35533B9A2790E    

        Foreign Key Information for all foreign keys in the table and the primary keys to which they refer
        --------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        Environment_Type_Cd              InstallPoint         dbo              SERVER                           Environment_Type_Cd              1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefENVIRONMENT_TYPE89            PK__ENVIRONM__9AA5B78B4CCDFFE1  

        Column Information
        ------------------
        COLUMN_NAME                      TYPE_NAME            COLUMN_SIZE  DECIMAL_DIGITS   COLUMN_DEF           ORDINAL_POSITION IS_NULLABLE     
        Server_Active_Fl                 bit                  0            0                                     6                YES             
        Update_Dt                        datetime             0            0                                     11               NO              
        Server_Nm                        varchar              40           0                                     3                YES             
        Server_Abrx_Tx                   varchar              10           0                                     7                YES             
        Create_Dt                        datetime             0            0                                     9                NO              
        Server_Ver_Num                   int                  10           0                                     12               NO              
        Environment_Type_Cd              int                  10           0                                     2                YES             
        Create_User_ID                   nvarchar             128          0                                     8                NO              
        Server_ID                        int                  10           0                                     1                NO              
        Server_Dsc                       varchar              200          0                                     4                YES             
        Update_User_ID                   nvarchar             128          0                                     10               NO              
        Virtual_Fl                       bit                  0            0                                     5                YES             

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
            INSERT INTO dbo.SERVER (
               Environment_Type_Cd
              ,Server_Nm
              ,Server_Dsc
              ,Virtual_Fl
              ,Server_Active_Fl
              ,Server_Abrx_Tx
              ,Create_User_ID
              ,Create_Dt
              ,Update_User_ID
              ,Update_Dt
              ,Server_Ver_Num
               )
               VALUES (
               @pi_Environment_Type_Cd
              ,@pi_Server_Nm
              ,@pi_Server_Dsc
              ,@pi_Virtual_Fl
              ,@pi_Server_Active_Fl
              ,@pi_Server_Abrx_Tx
              ,@pi_Create_User_ID
              ,@pi_Create_Dt
              ,@pi_Update_User_ID
              ,@pi_Update_Dt
              ,@pi_Server_Ver_Num
               );

            -- Get the Identity value for the row just inserted.
            SET @po_Server_ID = SCOPE_IDENTITY ();

            
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
		'Add_SERVER', -- Procedure_Name
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
         WHERE ROUTINE_SCHEMA = 'dbo' AND ROUTINE_NAME = 'Add_SERVER')
    BEGIN
        RAISERROR('Altered procedure "%s.%s".',10,1,'dbo','Add_SERVER') WITH NOWAIT;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'SVN Revision',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'PROCEDURE',
		                            @level1name = 'Add_SERVER';
	end try
	begin catch
		set nocount on;
	end catch;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'MS_Description',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'Procedure',
		                            @level1name = 'Add_SERVER';
	end try
	begin catch
		set nocount on;
	end catch;

        EXEC sp_addextendedproperty @name  = 'SVN Revision',
	                            @value      = '$Rev$',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'PROCEDURE',
	                            @level1name = 'Add_SERVER';

        EXEC sp_addextendedproperty @name  = 'MS_Description',
	                            @value      = 'dbo.Add_SERVER performs an insert of a row into the dbo.SERVER',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'Procedure',
	                            @level1name = 'Add_SERVER';
    END
ELSE
    BEGIN
        RAISERROR('ERROR: Unable to alter procedure "%s.%s".',16,1,'dbo','Add_SERVER');
    END;
GO

