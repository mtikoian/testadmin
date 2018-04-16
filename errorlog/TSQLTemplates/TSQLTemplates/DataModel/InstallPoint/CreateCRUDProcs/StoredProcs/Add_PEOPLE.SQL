IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  routine_schema = N'dbo' AND routine_name = N'Add_PEOPLE')
  BEGIN
    RAISERROR('Creating stub procedure "%s.%s".',10,1,'dbo','Add_PEOPLE') WITH NOWAIT;

    DECLARE @stmnt NVARCHAR(200);
    SET @stmnt = N'CREATE PROCEDURE dbo.Add_PEOPLE As Raiserror(''This is a stub routine and should not exist or be used'',16,1)';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        RAISERROR('ERROR: Unable to create stub procedure "%s.%s".',16,1,'dbo','Add_PEOPLE');
      END;
  END
ELSE
  BEGIN
    RAISERROR('Procedure "%s.%s" exists.',10,1,'dbo','Add_PEOPLE') WITH NOWAIT;
  END;
go

Alter PROCEDURE dbo.Add_PEOPLE (
   @pi_People_ID int = NULL,
   @pi_Phone_Number_Tx varchar(20) = NULL,
   @pi_Alternate_Phone_Number_Tx varchar(20) = NULL,
   @pi_People_Nm varchar(40) = NULL,
   @pi_Email_Address_Tx varchar(80) = NULL,
   @pi_Virtual_User_Fl bit = NULL,
   @pi_Group_Fl bit = NULL,
   @pi_SEI_Internal_Fl bit = NULL,
   @pi_Organization_ID int = NULL,
   @pi_Create_User_ID nvarchar(128) = NULL,
   @pi_Create_Dt datetime = NULL,
   @pi_Update_User_ID nvarchar(128) = NULL,
   @pi_Update_Dt datetime = NULL,
   @pi_People_Ver_Num int = NULL,
   @po_Error_Reason_Cd INT OUTPUT
) AS
BEGIN
/***
=pod

=begin text

   ================================================================================
   Name : Add_PEOPLE
   Author : POBrien 01/16/2013 10:47:12
   Description : Inserts a row in the dbo.PEOPLE table

   Revision: $Rev$
   URL: $URL$
   Last Checked in: $Author$
   ===============================================================================
   Parameters :
   Name                                | I/O | Description

   @pi_People_ID                        INPUT  People_ID                       
   @pi_Phone_Number_Tx                  INPUT  Phone_Number_Tx                 
   @pi_Alternate_Phone_Number_Tx        INPUT  Alternate_Phone_Number_Tx       
   @pi_People_Nm                        INPUT  People_Nm                       
   @pi_Email_Address_Tx                 INPUT  Email_Address_Tx                
   @pi_Virtual_User_Fl                  INPUT  Virtual_User_Fl                 
   @pi_Group_Fl                         INPUT  Group_Fl                        
   @pi_SEI_Internal_Fl                  INPUT  SEI_Internal_Fl                 
   @pi_Organization_ID                  INPUT  Organization_ID                 
   @pi_Create_User_ID                   INPUT  Create_User_ID                  
   @pi_Create_Dt                        INPUT  Create_Dt                       
   @pi_Update_User_ID                   INPUT  Update_User_ID                  
   @pi_Update_Dt                        INPUT  Update_Dt                       
   @pi_People_Ver_Num                   INPUT  People_Ver_Num                  
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
        InstallPoint.dbo.PEOPLE Table Information
        ----------------------------------------------------------------

        Primary Key Information
        -----------------------
        COLUMN_NAME                      KEY_SEQ  PK_NAME                         
        People_ID                        1        PK__PEOPLE__A6C71EA5655EB89F    

        Index Information
        -----------------
        Index Name                       Column Name                      Unique Unique Contraint Index Type      

        Foreign Key Information containing primary key of the table and all foreign keys that refer to it
        -------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        People_ID                        InstallPoint         dbo              INSTALL_USER                     People_ID                        1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefPEOPLE72                      PK__PEOPLE__A6C71EA5655EB89F    

        Foreign Key Information for all foreign keys in the table and the primary keys to which they refer
        --------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        Organization_ID                  InstallPoint         dbo              PEOPLE                           Organization_ID                  1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefORGANIZATION92                PK__ORGANIZA__A6FA250693BD3430  

        Column Information
        ------------------
        COLUMN_NAME                      TYPE_NAME            COLUMN_SIZE  DECIMAL_DIGITS   COLUMN_DEF           ORDINAL_POSITION IS_NULLABLE     
        Virtual_User_Fl                  bit                  0            0                                     6                YES             
        Create_Dt                        datetime             0            0                                     11               NO              
        Alternate_Phone_Number_Tx        varchar              20           0                                     3                YES             
        Group_Fl                         bit                  0            0                                     7                YES             
        Organization_ID                  int                  10           0                                     9                NO              
        Update_User_ID                   nvarchar             128          0                                     12               NO              
        Phone_Number_Tx                  varchar              20           0                                     2                YES             
        People_Ver_Num                   int                  10           0                                     14               NO              
        SEI_Internal_Fl                  bit                  0            0                                     8                YES             
        People_ID                        int                  10           0                                     1                NO              
        People_Nm                        varchar              40           0                                     4                YES             
        Update_Dt                        datetime             0            0                                     13               NO              
        Create_User_ID                   nvarchar             128          0                                     10               NO              
        Email_Address_Tx                 varchar              80           0                                     5                YES             

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
            INSERT INTO dbo.PEOPLE (
               People_ID
              ,Phone_Number_Tx
              ,Alternate_Phone_Number_Tx
              ,People_Nm
              ,Email_Address_Tx
              ,Virtual_User_Fl
              ,Group_Fl
              ,SEI_Internal_Fl
              ,Organization_ID
              ,Create_User_ID
              ,Create_Dt
              ,Update_User_ID
              ,Update_Dt
              ,People_Ver_Num
               )
               VALUES (
               @pi_People_ID
              ,@pi_Phone_Number_Tx
              ,@pi_Alternate_Phone_Number_Tx
              ,@pi_People_Nm
              ,@pi_Email_Address_Tx
              ,@pi_Virtual_User_Fl
              ,@pi_Group_Fl
              ,@pi_SEI_Internal_Fl
              ,@pi_Organization_ID
              ,@pi_Create_User_ID
              ,@pi_Create_Dt
              ,@pi_Update_User_ID
              ,@pi_Update_Dt
              ,@pi_People_Ver_Num
               );

            
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
		'Add_PEOPLE', -- Procedure_Name
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
         WHERE ROUTINE_SCHEMA = 'dbo' AND ROUTINE_NAME = 'Add_PEOPLE')
    BEGIN
        RAISERROR('Altered procedure "%s.%s".',10,1,'dbo','Add_PEOPLE') WITH NOWAIT;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'SVN Revision',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'PROCEDURE',
		                            @level1name = 'Add_PEOPLE';
	end try
	begin catch
		set nocount on;
	end catch;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'MS_Description',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'Procedure',
		                            @level1name = 'Add_PEOPLE';
	end try
	begin catch
		set nocount on;
	end catch;

        EXEC sp_addextendedproperty @name  = 'SVN Revision',
	                            @value      = '$Rev$',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'PROCEDURE',
	                            @level1name = 'Add_PEOPLE';

        EXEC sp_addextendedproperty @name  = 'MS_Description',
	                            @value      = 'dbo.Add_PEOPLE performs an insert of a row into the dbo.PEOPLE',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'Procedure',
	                            @level1name = 'Add_PEOPLE';
    END
ELSE
    BEGIN
        RAISERROR('ERROR: Unable to alter procedure "%s.%s".',16,1,'dbo','Add_PEOPLE');
    END;
GO

