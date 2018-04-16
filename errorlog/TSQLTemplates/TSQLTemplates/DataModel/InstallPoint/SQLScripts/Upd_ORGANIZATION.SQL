IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  routine_schema = N'dbo' AND routine_name = N'Upd_ORGANIZATION')
  BEGIN
    RAISERROR('Creating stub procedure "%s.%s".',10,1,'dbo','Upd_ORGANIZATION') WITH NOWAIT;

    DECLARE @stmnt NVARCHAR(200);
    SET @stmnt = N'CREATE PROCEDURE dbo.Upd_ORGANIZATION As Raiserror(''This is a stub routine and should not exist or be used'',16,1)';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        RAISERROR('ERROR: Unable to create stub procedure "%s.%s".',16,1,'dbo','Upd_ORGANIZATION');
      END;
  END
ELSE
  BEGIN
    RAISERROR('Procedure "%s.%s" exists.',10,1,'dbo','Upd_ORGANIZATION') WITH NOWAIT;
  END;
go

Alter PROCEDURE dbo.Upd_ORGANIZATION (
   @pi_Organization_Nm varchar(40) = NULL,
   @pi_Organization_Dsc varchar(400) = NULL,
   @pi_Client_T3K_Master_ID int = NULL,
   @pi_Client_T3K_Supervisor_ID int = NULL,
   @pi_T3K_Shared_Master_Fl bit = NULL,
   @pi_Mainframe_System_Nm varchar(1) = NULL,
   @pi_ADABAS_DB_Num smallint = NULL,
   @pi_SEI_Client_ID varchar(20) = NULL,
   @pi_Organization_Active_Fl bit = NULL,
   @pi_Organization_Abrv_Tx varchar(10) = NULL,
   @pi_Job_Naming_Abrv_Tx varchar(3) = NULL,
   @pi_Create_User_ID nvarchar(128) = NULL,
   @pi_Create_Dt datetime = NULL,
   @pi_Update_User_ID nvarchar(128) = NULL,
   @pi_Update_Dt datetime = NULL,
   @pi_Organization_Ver_Num int = NULL,
   @pi_Organization_ID INT,
   @po_Error_Reason_Cd INT OUTPUT
) AS
BEGIN
/***
=pod

=begin text

   ================================================================================
   Name : Upd_ORGANIZATION
   Author : POBrien 01/16/2013 08:09:02
   Description : Updates a row in dbo.ORGANIZATION table

   Revision: $Rev$
   URL: $URL$
   Last Checked in: $Author$
   ===============================================================================
   Parameters :
   Name                                | I/O | Description
   @pi_Organization_Nm                  INPUT  Organization_Nm                 
   @pi_Organization_Dsc                 INPUT  Organization_Dsc                
   @pi_Client_T3K_Master_ID             INPUT  Client_T3K_Master_ID            
   @pi_Client_T3K_Supervisor_ID         INPUT  Client_T3K_Supervisor_ID        
   @pi_T3K_Shared_Master_Fl             INPUT  T3K_Shared_Master_Fl            
   @pi_Mainframe_System_Nm              INPUT  Mainframe_System_Nm             
   @pi_ADABAS_DB_Num                    INPUT  ADABAS_DB_Num                   
   @pi_SEI_Client_ID                    INPUT  SEI_Client_ID                   
   @pi_Organization_Active_Fl           INPUT  Organization_Active_Fl          
   @pi_Organization_Abrv_Tx             INPUT  Organization_Abrv_Tx            
   @pi_Job_Naming_Abrv_Tx               INPUT  Job_Naming_Abrv_Tx              
   @pi_Create_User_ID                   INPUT  Create_User_ID                  
   @pi_Create_Dt                        INPUT  Create_Dt                       
   @pi_Update_User_ID                   INPUT  Update_User_ID                  
   @pi_Update_Dt                        INPUT  Update_Dt                       
   @pi_Organization_Ver_Num             INPUT  Organization_Ver_Num            
   @pi_Organization_ID                  INPUT  Organization_ID                 
   @po_Error_Reason_Cd                  OUTPUT Error reason code               
   
   --------------------------------------------------------------------------------
   Error Reason codes: 

       1 - No rows qualified for update based on where clause
       2 - Too many rows qualified for update based on where clause

   --------------------------------------------------------------------------------
   Return Value: 0
   Success : 0
   Failure : Non zero error log id from the ErrorLog table.

   Revisions :
   --------------------------------------------------------------------------------
   Ini    | Date          | Description
   --------------------------------------------------------------------------------
   POBrien  01/16/2013 08:09:02       Initial version.
   ================================================================================

=end text

=cut
***/

        -- Return code from called stored procedures.
        DECLARE @ReturnCode   INT;

        -- Log_Detail.Log_Detail_ID
        DECLARE @po_Log_Detail_ID INT;
        
        -- Update date for row updated
        DECLARE @UpdateDt   DATETIME;
        
        -- Version number
        DECLARE @VerNum    SMALLINT;

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

        -- Update date for rows updated.
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
        InstallPoint.dbo.ORGANIZATION Table Information
        ----------------------------------------------------------------

        Identity Column Name is Organization_ID

        Primary Key Information
        -----------------------
        COLUMN_NAME                      KEY_SEQ  PK_NAME                         
        Organization_ID                  1        PK__ORGANIZA__A6FA25062D57A235  

        Index Information
        -----------------
        Index Name                       Column Name                      Unique Unique Contraint Index Type      

        Foreign Key Information containing primary key of the table and all foreign keys that refer to it
        -------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        Organization_ID                  InstallPoint         dbo              TASK_INSTANCE                    Organization_ID                  1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefORGANIZATION38                PK__ORGANIZA__A6FA25062D57A235  

        Column Information
        ------------------
        COLUMN_NAME                      TYPE_NAME            COLUMN_SIZE  DECIMAL_DIGITS   COLUMN_DEF           ORDINAL_POSITION IS_NULLABLE     
        Organization_Abrv_Tx             varchar              10           0                                     11               YES             
        Mainframe_System_Nm              varchar              1            0                                     7                YES             
        Organization_Ver_Num             int                  10           0                                     17               NO              
        Organization_Nm                  varchar              40           0                                     2                NO              
        Organization_ID                  int                  10           0                                     1                NO              
        Update_Dt                        datetime             0            0                                     16               NO              
        Create_User_ID                   nvarchar             128          0                                     13               NO              
        T3K_Shared_Master_Fl             bit                  0            0                                     6                YES             
        Organization_Dsc                 varchar              400          0                                     3                YES             
        SEI_Client_ID                    varchar              20           0                                     9                YES             
        Job_Naming_Abrv_Tx               varchar              3            0                                     12               YES             
        Create_Dt                        datetime             0            0                                     14               NO              
        Update_User_ID                   nvarchar             128          0                                     15               NO              
        ADABAS_DB_Num                    smallint             5            0                                     8                YES             
        Client_T3K_Master_ID             int                  10           0                                     4                YES             
        Organization_Active_Fl           bit                  0            0                                     10               YES             
        Client_T3K_Supervisor_ID         int                  10           0                                     5                YES             

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
            IF (@pi_Organization_Ver_Num >= 10000)
            BEGIN
               SET @VerNum = 1;
            END
            ELSE
            BEGIN
               SET @VerNum = @pi_Organization_Ver_Num + 1;
            END;

            -- Start the transaction
            BEGIN TRANSACTION;

            -- Update the row
            UPDATE dbo.ORGANIZATION
               SET Organization_Nm = @pi_Organization_Nm
                  ,Organization_Dsc = @pi_Organization_Dsc
                  ,Client_T3K_Master_ID = @pi_Client_T3K_Master_ID
                  ,Client_T3K_Supervisor_ID = @pi_Client_T3K_Supervisor_ID
                  ,T3K_Shared_Master_Fl = @pi_T3K_Shared_Master_Fl
                  ,Mainframe_System_Nm = @pi_Mainframe_System_Nm
                  ,ADABAS_DB_Num = @pi_ADABAS_DB_Num
                  ,SEI_Client_ID = @pi_SEI_Client_ID
                  ,Organization_Active_Fl = @pi_Organization_Active_Fl
                  ,Organization_Abrv_Tx = @pi_Organization_Abrv_Tx
                  ,Job_Naming_Abrv_Tx = @pi_Job_Naming_Abrv_Tx
                  ,Create_User_ID = @pi_Create_User_ID
                  ,Create_Dt = @pi_Create_Dt
                  ,Update_User_ID = @pi_Update_User_ID
                  ,Update_Dt = @pi_Update_Dt
                  ,Organization_Ver_Num = @VerNum
                WHERE Organization_ID = @pi_Organization_ID
                  AND Organization_Ver_Num = @pi_Organization_Ver_Num;

            -- Make sure we updated one row
            IF (@@ROWCOUNT = 0)
            BEGIN
                -- No row qualified for update based on where clause
                SET @po_Error_Reason_Cd = 1;
                RAISERROR ('No rows qualified for update based on where clause.',16,1);
            END
            
            ELSE IF (@@ROWCOUNT > 1)
            BEGIN
                -- Too many rows qualified for update based on where clause
                SET @po_Error_Reason_Cd = 2;
                RAISERROR ('Too many rows qualified for update based on where clause.',16,1);
            END;

            -- Commit the transaction
            COMMIT TRANSACTION;
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
		@LL_Error, -- Log_Level_ID
		NULL, -- Organization_ID
		NULL, -- UserID
		'Upd_ORGANIZATION', -- Procedure_Name
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
         WHERE ROUTINE_SCHEMA = 'dbo' AND ROUTINE_NAME = 'Upd_ORGANIZATION')
    BEGIN
        RAISERROR('Altered procedure "%s.%s".',10,1,'dbo','Upd_ORGANIZATION') WITH NOWAIT;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'SVN Revision',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'PROCEDURE',
		                            @level1name = 'Upd_ORGANIZATION';
	end try
	begin catch
		set nocount on;
	end catch;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'MS_Description',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'Procedure',
		                            @level1name = 'Upd_ORGANIZATION';
	end try
	begin catch
		set nocount on;
	end catch;

        EXEC sp_addextendedproperty @name  = 'SVN Revision',
	                            @value      = '$Rev$',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'PROCEDURE',
	                            @level1name = 'Upd_ORGANIZATION';

        EXEC sp_addextendedproperty @name  = 'MS_Description',
	                            @value      = 'dbo.Upd_ORGANIZATION performs an update of a row into the dbo.ORGANIZATION',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'Procedure',
	                            @level1name = 'Upd_ORGANIZATION';
    END
ELSE
    BEGIN
        RAISERROR('ERROR: Unable to alter procedure "%s.%s".',16,1,'dbo','Upd_ORGANIZATION');
    END;
GO

