IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  routine_schema = N'dbo' AND routine_name = N'Upd_AUDIT_TRAIL')
  BEGIN
    RAISERROR('Creating stub procedure "%s.%s".',10,1,'dbo','Upd_AUDIT_TRAIL') WITH NOWAIT;

    DECLARE @stmnt NVARCHAR(200);
    SET @stmnt = N'CREATE PROCEDURE dbo.Upd_AUDIT_TRAIL As Raiserror(''This is a stub routine and should not exist or be used'',16,1)';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        RAISERROR('ERROR: Unable to create stub procedure "%s.%s".',16,1,'dbo','Upd_AUDIT_TRAIL');
      END;
  END
ELSE
  BEGIN
    RAISERROR('Procedure "%s.%s" exists.',10,1,'dbo','Upd_AUDIT_TRAIL') WITH NOWAIT;
  END;
go

Alter PROCEDURE dbo.Upd_AUDIT_TRAIL (
   @pi_Structure_Version_Tag varchar(20) = NULL,
   @pi_Table_Name varchar(32) = NULL,
   @pi_Column_Name varchar(32) = NULL,
   @pi_Audit_Type varchar(10) = NULL,
   @pi_User_ID nvarchar(128) = NULL,
   @pi_Audit_Timestamp datetime = NULL,
   @pi_Old_Value varchar(1000) = NULL,
   @pi_New_Value varchar(1000) = NULL,
   @pi_Primary_Key_Value varchar(200) = NULL,
   @pi_Sequence_Num numeric(15,0) = NULL,
   @pi_Split_Num int = NULL,
   @pi_Audit_Trail_ID INT,
   @po_Error_Reason_Cd INT OUTPUT
) AS
BEGIN
/***
=pod

=begin text

   ================================================================================
   Name : Upd_AUDIT_TRAIL
   Author : POBrien 01/16/2013 10:47:10
   Description : Updates a row in dbo.AUDIT_TRAIL table

   Revision: $Rev$
   URL: $URL$
   Last Checked in: $Author$
   ===============================================================================
   Parameters :
   Name                                | I/O | Description
   @pi_Structure_Version_Tag            INPUT  Structure_Version_Tag           
   @pi_Table_Name                       INPUT  Table_Name                      
   @pi_Column_Name                      INPUT  Column_Name                     
   @pi_Audit_Type                       INPUT  Audit_Type                      
   @pi_User_ID                          INPUT  User_ID                         
   @pi_Audit_Timestamp                  INPUT  Audit_Timestamp                 
   @pi_Old_Value                        INPUT  Old_Value                       
   @pi_New_Value                        INPUT  New_Value                       
   @pi_Primary_Key_Value                INPUT  Primary_Key_Value               
   @pi_Sequence_Num                     INPUT  Sequence_Num                    
   @pi_Split_Num                        INPUT  Split_Num                       
   @pi_Audit_Trail_ID                   INPUT  Audit_Trail_ID                  
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
   POBrien  01/16/2013 10:47:10       Initial version.
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
        InstallPoint.dbo.AUDIT_TRAIL Table Information
        ----------------------------------------------------------------

        Identity Column Name is Audit_Trail_ID

        Primary Key Information
        -----------------------
        COLUMN_NAME                      KEY_SEQ  PK_NAME                         
        Audit_Trail_ID                   1        PK__AUDIT_TR__C0E310AA2B345A7A  

        Index Information
        -----------------
        Index Name                       Column Name                      Unique Unique Contraint Index Type      

        Column Information
        ------------------
        COLUMN_NAME                      TYPE_NAME            COLUMN_SIZE  DECIMAL_DIGITS   COLUMN_DEF           ORDINAL_POSITION IS_NULLABLE     
        User_ID                          nvarchar             128          0                                     6                NO              
        Sequence_Num                     numeric              15           0                                     11               NO              
        Table_Name                       varchar              32           0                                     3                NO              
        Audit_Timestamp                  datetime             0            0                (getdate())          7                NO              
        New_Value                        varchar              1000         0                                     9                YES             
        Split_Num                        int                  10           0                ((1))                12               NO              
        Structure_Version_Tag            varchar              20           0                                     2                YES             
        Old_Value                        varchar              1000         0                                     8                YES             
        Audit_Trail_ID                   numeric              15           0                                     1                NO              
        Column_Name                      varchar              32           0                                     4                NO              
        Primary_Key_Value                varchar              200          0                                     10               NO              
        Audit_Type                       varchar              10           0                                     5                NO              

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

            -- Update the row
            UPDATE dbo.AUDIT_TRAIL
               SET Structure_Version_Tag = @pi_Structure_Version_Tag
                  ,Table_Name = @pi_Table_Name
                  ,Column_Name = @pi_Column_Name
                  ,Audit_Type = @pi_Audit_Type
                  ,User_ID = @pi_User_ID
                  ,Audit_Timestamp = @pi_Audit_Timestamp
                  ,Old_Value = @pi_Old_Value
                  ,New_Value = @pi_New_Value
                  ,Primary_Key_Value = @pi_Primary_Key_Value
                  ,Sequence_Num = @pi_Sequence_Num
                  ,Split_Num = @pi_Split_Num
                WHERE Audit_Trail_ID = @pi_Audit_Trail_ID;

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
		'Upd_AUDIT_TRAIL', -- Procedure_Name
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
         WHERE ROUTINE_SCHEMA = 'dbo' AND ROUTINE_NAME = 'Upd_AUDIT_TRAIL')
    BEGIN
        RAISERROR('Altered procedure "%s.%s".',10,1,'dbo','Upd_AUDIT_TRAIL') WITH NOWAIT;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'SVN Revision',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'PROCEDURE',
		                            @level1name = 'Upd_AUDIT_TRAIL';
	end try
	begin catch
		set nocount on;
	end catch;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'MS_Description',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'Procedure',
		                            @level1name = 'Upd_AUDIT_TRAIL';
	end try
	begin catch
		set nocount on;
	end catch;

        EXEC sp_addextendedproperty @name  = 'SVN Revision',
	                            @value      = '$Rev$',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'PROCEDURE',
	                            @level1name = 'Upd_AUDIT_TRAIL';

        EXEC sp_addextendedproperty @name  = 'MS_Description',
	                            @value      = 'dbo.Upd_AUDIT_TRAIL performs an update of a row into the dbo.AUDIT_TRAIL',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'Procedure',
	                            @level1name = 'Upd_AUDIT_TRAIL';
    END
ELSE
    BEGIN
        RAISERROR('ERROR: Unable to alter procedure "%s.%s".',16,1,'dbo','Upd_AUDIT_TRAIL');
    END;
GO

