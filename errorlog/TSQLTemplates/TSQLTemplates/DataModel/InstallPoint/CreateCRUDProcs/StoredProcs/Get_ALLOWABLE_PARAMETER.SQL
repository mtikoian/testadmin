IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  routine_schema = N'dbo' AND routine_name = N'Get_ALLOWABLE_PARAMETER')
  BEGIN
    RAISERROR('Creating stub procedure "%s.%s".',10,1,'dbo','Get_ALLOWABLE_PARAMETER') WITH NOWAIT;

    DECLARE @stmnt NVARCHAR(200);
    SET @stmnt = N'CREATE PROCEDURE dbo.Get_ALLOWABLE_PARAMETER As Raiserror(''This is a stub routine and should not exist or be used'',16,1)';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        RAISERROR('ERROR: Unable to create stub procedure "%s.%s".',16,1,'dbo','Get_ALLOWABLE_PARAMETER');
      END;
  END
ELSE
  BEGIN
    RAISERROR('Procedure "%s.%s" exists.',10,1,'dbo','Get_ALLOWABLE_PARAMETER') WITH NOWAIT;
  END;
go

Alter PROCEDURE dbo.Get_ALLOWABLE_PARAMETER (
   @pi_Parameter_Nm varchar(100) = NULL,
   @pi_Parameter_Dsc varchar(400) = NULL,
   @pi_Parameter_Tag_Tx varchar(100) = NULL,
   @pi_Parameter_Keyword_Tx varchar(80) = NULL,
   @pi_Data_Type_Cd int = NULL,
   @pi_Default_Value_Tx varchar(400) = NULL,
   @pi_Default_Value_Num int = NULL,
   @pi_Default_Value_Fl bit = NULL,
   @pi_Reserved_Word_Fl bit = NULL,
   @pi_Parm_Domain_ID int = NULL,
   @pi_Generate_Name_Fl bit = NULL,
   @pi_Create_User_ID nvarchar(128) = NULL,
   @pi_Create_Dt datetime = NULL,
   @pi_Update_User_ID nvarchar(128) = NULL,
   @pi_Update_Dt datetime = NULL,
   @pi_Allowable_Parameter_Ver_Num int = NULL,
   @pi_Parameter_ID INT,
   @po_Error_Reason_Cd INT OUTPUT
) AS
BEGIN
/***
=pod

=begin text

   ================================================================================
   Name : Get_ALLOWABLE_PARAMETER
   Author : POBrien 01/16/2013 10:47:10
   Description : Selects a row from dbo.ALLOWABLE_PARAMETER table

   Revision: $Rev$
   URL: $URL$
   Last Checked in: $Author$
   ===============================================================================
   Parameters :
   Name                                | I/O | Description
   @pi_Parameter_Nm                     INPUT  Parameter_Nm                    
   @pi_Parameter_Dsc                    INPUT  Parameter_Dsc                   
   @pi_Parameter_Tag_Tx                 INPUT  Parameter_Tag_Tx                
   @pi_Parameter_Keyword_Tx             INPUT  Parameter_Keyword_Tx            
   @pi_Data_Type_Cd                     INPUT  Data_Type_Cd                    
   @pi_Default_Value_Tx                 INPUT  Default_Value_Tx                
   @pi_Default_Value_Num                INPUT  Default_Value_Num               
   @pi_Default_Value_Fl                 INPUT  Default_Value_Fl                
   @pi_Reserved_Word_Fl                 INPUT  Reserved_Word_Fl                
   @pi_Parm_Domain_ID                   INPUT  Parm_Domain_ID                  
   @pi_Generate_Name_Fl                 INPUT  Generate_Name_Fl                
   @pi_Create_User_ID                   INPUT  Create_User_ID                  
   @pi_Create_Dt                        INPUT  Create_Dt                       
   @pi_Update_User_ID                   INPUT  Update_User_ID                  
   @pi_Update_Dt                        INPUT  Update_Dt                       
   @pi_Allowable_Parameter_Ver_Num      INPUT  Allowable_Parameter_Ver_Num     
   @pi_Parameter_ID                     INPUT  Parameter_ID                    
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
   POBrien  01/16/2013 10:47:10       Initial version.
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
        InstallPoint.dbo.ALLOWABLE_PARAMETER Table Information
        ----------------------------------------------------------------

        Identity Column Name is Parameter_ID

        Primary Key Information
        -----------------------
        COLUMN_NAME                      KEY_SEQ  PK_NAME                         
        Parameter_ID                     1        PK__ALLOWABL__41963A08E545ECB0  

        Index Information
        -----------------
        Index Name                       Column Name                      Unique Unique Contraint Index Type      

        Foreign Key Information containing primary key of the table and all foreign keys that refer to it
        -------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        Parameter_ID                     InstallPoint         dbo              PARAMETER_USAGE                  Parameter_ID                     1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefALLOWABLE_PARAMETER16         PK__ALLOWABL__41963A08E545ECB0  

        Foreign Key Information for all foreign keys in the table and the primary keys to which they refer
        --------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        Parm_Domain_ID                   InstallPoint         dbo              ALLOWABLE_PARAMETER              Parm_Domain_ID                   1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefPARM_DOMAIN82                 PK__PARM_DOM__201A7299E602F670  

        Column Information
        ------------------
        COLUMN_NAME                      TYPE_NAME            COLUMN_SIZE  DECIMAL_DIGITS   COLUMN_DEF           ORDINAL_POSITION IS_NULLABLE     
        Parm_Domain_ID                   int                  10           0                                     11               NO              
        Default_Value_Tx                 varchar              400          0                                     7                YES             
        Allowable_Parameter_Ver_Num      int                  10           0                                     17               NO              
        Parameter_Nm                     varchar              100          0                                     2                NO              
        Parameter_ID                     int                  10           0                                     1                NO              
        Update_Dt                        datetime             0            0                                     16               NO              
        Create_User_ID                   nvarchar             128          0                                     13               NO              
        Data_Type_Cd                     int                  10           0                                     6                NO              
        Parameter_Dsc                    varchar              400          0                                     3                YES             
        Default_Value_Fl                 bit                  0            0                                     9                YES             
        Generate_Name_Fl                 bit                  0            0                                     12               YES             
        Create_Dt                        datetime             0            0                                     14               NO              
        Update_User_ID                   nvarchar             128          0                                     15               NO              
        Default_Value_Num                int                  10           0                                     8                YES             
        Parameter_Tag_Tx                 varchar              100          0                                     4                YES             
        Reserved_Word_Fl                 bit                  0            0                                     10               YES             
        Parameter_Keyword_Tx             varchar              80           0                                     5                YES             

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
               Parameter_ID,
               Parameter_Nm,
               Parameter_Dsc,
               Parameter_Tag_Tx,
               Parameter_Keyword_Tx,
               Data_Type_Cd,
               Default_Value_Tx,
               Default_Value_Num,
               Default_Value_Fl,
               Reserved_Word_Fl,
               Parm_Domain_ID,
               Generate_Name_Fl,
               Create_User_ID,
               Create_Dt,
               Update_User_ID,
               Update_Dt,
               Allowable_Parameter_Ver_Num
            FROM dbo.ALLOWABLE_PARAMETER
            WHERE Parameter_ID = @pi_Parameter_ID;

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
               'Get_ALLOWABLE_PARAMETER',                        -- Procedure_Name
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
         WHERE ROUTINE_SCHEMA = 'dbo' AND ROUTINE_NAME = 'Get_ALLOWABLE_PARAMETER')
    BEGIN
        RAISERROR('Altered procedure "%s.%s".',10,1,'dbo','Get_ALLOWABLE_PARAMETER') WITH NOWAIT;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'SVN Revision',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'PROCEDURE',
		                            @level1name = 'Get_ALLOWABLE_PARAMETER';
	end try
	begin catch
		set nocount on;
	end catch;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'MS_Description',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'Procedure',
		                            @level1name = 'Get_ALLOWABLE_PARAMETER';
	end try
	begin catch
		set nocount on;
	end catch;

        EXEC sp_addextendedproperty @name  = 'SVN Revision',
	                            @value      = '$Rev$',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'PROCEDURE',
	                            @level1name = 'Get_ALLOWABLE_PARAMETER';

        EXEC sp_addextendedproperty @name  = 'MS_Description',
	                            @value      = 'dbo.Get_ALLOWABLE_PARAMETER performs a select of a row from the dbo.ALLOWABLE_PARAMETER',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'Procedure',
	                            @level1name = 'Get_ALLOWABLE_PARAMETER';
    END
ELSE
    BEGIN
        RAISERROR('ERROR: Unable to alter procedure "%s.%s".',16,1,'dbo','Get_ALLOWABLE_PARAMETER');
    END;
GO

