IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  routine_schema = N'dbo' AND routine_name = N'Upd_PRODUCT')
  BEGIN
    RAISERROR('Creating stub procedure "%s.%s".',10,1,'dbo','Upd_PRODUCT') WITH NOWAIT;

    DECLARE @stmnt NVARCHAR(200);
    SET @stmnt = N'CREATE PROCEDURE dbo.Upd_PRODUCT As Raiserror(''This is a stub routine and should not exist or be used'',16,1)';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        RAISERROR('ERROR: Unable to create stub procedure "%s.%s".',16,1,'dbo','Upd_PRODUCT');
      END;
  END
ELSE
  BEGIN
    RAISERROR('Procedure "%s.%s" exists.',10,1,'dbo','Upd_PRODUCT') WITH NOWAIT;
  END;
go

Alter PROCEDURE dbo.Upd_PRODUCT (
   @pi_Product_Nm varchar(40) = NULL,
   @pi_Product_Type_Cd int = NULL,
   @pi_Organization_ID int = NULL,
   @pi_Product_Dsc varchar(200) = NULL,
   @pi_Product_Abrv_Tx varchar(10) = NULL,
   @pi_Create_User_ID nvarchar(128) = NULL,
   @pi_Create_Dt datetime = NULL,
   @pi_Update_User_ID nvarchar(128) = NULL,
   @pi_Update_Dt datetime = NULL,
   @pi_Product_Ver_Num int = NULL,
   @pi_Product_ID INT,
   @po_Error_Reason_Cd INT OUTPUT
) AS
BEGIN
/***
=pod

=begin text

   ================================================================================
   Name : Upd_PRODUCT
   Author : POBrien 01/16/2013 08:09:02
   Description : Updates a row in dbo.PRODUCT table

   Revision: $Rev$
   URL: $URL$
   Last Checked in: $Author$
   ===============================================================================
   Parameters :
   Name                                | I/O | Description
   @pi_Product_Nm                       INPUT  Product_Nm                      
   @pi_Product_Type_Cd                  INPUT  Product_Type_Cd                 
   @pi_Organization_ID                  INPUT  Organization_ID                 
   @pi_Product_Dsc                      INPUT  Product_Dsc                     
   @pi_Product_Abrv_Tx                  INPUT  Product_Abrv_Tx                 
   @pi_Create_User_ID                   INPUT  Create_User_ID                  
   @pi_Create_Dt                        INPUT  Create_Dt                       
   @pi_Update_User_ID                   INPUT  Update_User_ID                  
   @pi_Update_Dt                        INPUT  Update_Dt                       
   @pi_Product_Ver_Num                  INPUT  Product_Ver_Num                 
   @pi_Product_ID                       INPUT  Product_ID                      
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
        InstallPoint.dbo.PRODUCT Table Information
        ----------------------------------------------------------------

        Identity Column Name is Product_ID

        Primary Key Information
        -----------------------
        COLUMN_NAME                      KEY_SEQ  PK_NAME                         
        Product_ID                       1        PK__PRODUCT__9834FB9A987D51B1   

        Index Information
        -----------------
        Index Name                       Column Name                      Unique Unique Contraint Index Type      

        Foreign Key Information containing primary key of the table and all foreign keys that refer to it
        -------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        Product_ID                       InstallPoint         dbo              PRODUCT_VERSION                  Product_ID                       1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefPRODUCT4                      PK__PRODUCT__9834FB9A987D51B1   

        Foreign Key Information for all foreign keys in the table and the primary keys to which they refer
        --------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        Product_Type_Cd                  InstallPoint         dbo              PRODUCT                          Product_Type_Cd                  1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefPRODUCT_TYPE41                PK__PRODUCT___9CEF4276E1F090B7  

        Column Information
        ------------------
        COLUMN_NAME                      TYPE_NAME            COLUMN_SIZE  DECIMAL_DIGITS   COLUMN_DEF           ORDINAL_POSITION IS_NULLABLE     
        Product_Abrv_Tx                  varchar              10           0                                     6                YES             
        Product_Ver_Num                  int                  10           0                                     11               NO              
        Product_Type_Cd                  int                  10           0                                     3                YES             
        Create_User_ID                   nvarchar             128          0                                     7                NO              
        Update_User_ID                   nvarchar             128          0                                     9                NO              
        Product_Nm                       varchar              40           0                                     2                YES             
        Create_Dt                        datetime             0            0                                     8                NO              
        Product_ID                       int                  10           0                                     1                NO              
        Organization_ID                  int                  10           0                                     4                YES             
        Update_Dt                        datetime             0            0                                     10               NO              
        Product_Dsc                      varchar              200          0                                     5                YES             

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
            IF (@pi_Product_Ver_Num >= 10000)
            BEGIN
               SET @VerNum = 1;
            END
            ELSE
            BEGIN
               SET @VerNum = @pi_Product_Ver_Num + 1;
            END;

            -- Start the transaction
            BEGIN TRANSACTION;

            -- Update the row
            UPDATE dbo.PRODUCT
               SET Product_Nm = @pi_Product_Nm
                  ,Product_Type_Cd = @pi_Product_Type_Cd
                  ,Organization_ID = @pi_Organization_ID
                  ,Product_Dsc = @pi_Product_Dsc
                  ,Product_Abrv_Tx = @pi_Product_Abrv_Tx
                  ,Create_User_ID = @pi_Create_User_ID
                  ,Create_Dt = @pi_Create_Dt
                  ,Update_User_ID = @pi_Update_User_ID
                  ,Update_Dt = @pi_Update_Dt
                  ,Product_Ver_Num = @VerNum
                WHERE Product_ID = @pi_Product_ID
                  AND Product_Ver_Num = @pi_Product_Ver_Num;

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
		'Upd_PRODUCT', -- Procedure_Name
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
         WHERE ROUTINE_SCHEMA = 'dbo' AND ROUTINE_NAME = 'Upd_PRODUCT')
    BEGIN
        RAISERROR('Altered procedure "%s.%s".',10,1,'dbo','Upd_PRODUCT') WITH NOWAIT;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'SVN Revision',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'PROCEDURE',
		                            @level1name = 'Upd_PRODUCT';
	end try
	begin catch
		set nocount on;
	end catch;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'MS_Description',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'Procedure',
		                            @level1name = 'Upd_PRODUCT';
	end try
	begin catch
		set nocount on;
	end catch;

        EXEC sp_addextendedproperty @name  = 'SVN Revision',
	                            @value      = '$Rev$',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'PROCEDURE',
	                            @level1name = 'Upd_PRODUCT';

        EXEC sp_addextendedproperty @name  = 'MS_Description',
	                            @value      = 'dbo.Upd_PRODUCT performs an update of a row into the dbo.PRODUCT',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'Procedure',
	                            @level1name = 'Upd_PRODUCT';
    END
ELSE
    BEGIN
        RAISERROR('ERROR: Unable to alter procedure "%s.%s".',16,1,'dbo','Upd_PRODUCT');
    END;
GO

