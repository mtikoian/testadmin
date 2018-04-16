IF NOT EXISTS
     (SELECT 1
      FROM   information_schema.routines
      WHERE  routine_schema = N'dbo' AND routine_name = N'Del_PRODUCT_COMPONENT')
  BEGIN
    RAISERROR('Creating stub procedure "%s.%s".',10,1,'dbo','Del_PRODUCT_COMPONENT') WITH NOWAIT;

    DECLARE @stmnt NVARCHAR(200);
    SET @stmnt = N'CREATE PROCEDURE dbo.Del_PRODUCT_COMPONENT As Raiserror(''This is a stub routine and should not exist or be used'',16,1)';
    EXEC sp_executesql @stmnt;

    IF (@@ERROR <> 0)
      BEGIN
        RAISERROR('ERROR: Unable to create stub procedure "%s.%s".',16,1,'dbo','Del_PRODUCT_COMPONENT');
      END;
  END
ELSE
  BEGIN
    RAISERROR('Procedure "%s.%s" exists.',10,1,'dbo','Del_PRODUCT_COMPONENT') WITH NOWAIT;
  END;
go

Alter PROCEDURE dbo.Del_PRODUCT_COMPONENT (
   @pi_Product_Version_ID int = NULL,
   @pi_Product_Component_Nm varchar(100) = NULL,
   @pi_Component_Type_Cd int = NULL,
   @pi_Availability_Dt datetime = NULL,
   @pi_In_Production_Fl bit = NULL,
   @pi_Product_Component_Dsc varchar(200) = NULL,
   @pi_Template_URL_Tx varchar(200) = NULL,
   @pi_Order_Num int = NULL,
   @pi_Create_User_ID nvarchar(128) = NULL,
   @pi_Create_Dt datetime = NULL,
   @pi_Update_User_ID nvarchar(128) = NULL,
   @pi_Update_Dt datetime = NULL,
   @pi_Product_Component_Ver_Num int = NULL,
   @pi_Product_Component_ID INT,
   @po_Error_Reason_Cd INT OUTPUT
) AS
BEGIN
/***
=pod

=begin text

   ================================================================================
   Name : Del_PRODUCT_COMPONENT
   Author : POBrien 01/16/2013 10:47:12
   Description : Deletes a row from the dbo.PRODUCT_COMPONENT table

   Revision: $Rev$
   URL: $URL$
   Last Checked in: $Author$
   ===============================================================================
   Parameters :
   Name                                | I/O | Description
   @pi_Product_Version_ID               INPUT  Product_Version_ID              
   @pi_Product_Component_Nm             INPUT  Product_Component_Nm            
   @pi_Component_Type_Cd                INPUT  Component_Type_Cd               
   @pi_Availability_Dt                  INPUT  Availability_Dt                 
   @pi_In_Production_Fl                 INPUT  In_Production_Fl                
   @pi_Product_Component_Dsc            INPUT  Product_Component_Dsc           
   @pi_Template_URL_Tx                  INPUT  Template_URL_Tx                 
   @pi_Order_Num                        INPUT  Order_Num                       
   @pi_Create_User_ID                   INPUT  Create_User_ID                  
   @pi_Create_Dt                        INPUT  Create_Dt                       
   @pi_Update_User_ID                   INPUT  Update_User_ID                  
   @pi_Update_Dt                        INPUT  Update_Dt                       
   @pi_Product_Component_Ver_Num        INPUT  Product_Component_Ver_Num       
   @pi_Product_Component_ID             INPUT  Product_Component_ID            
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
        InstallPoint.dbo.PRODUCT_COMPONENT Table Information
        ----------------------------------------------------------------

        Identity Column Name is Product_Component_ID

        Primary Key Information
        -----------------------
        COLUMN_NAME                      KEY_SEQ  PK_NAME                         
        Product_Component_ID             1        PK__PRODUCT___B5F39AE151C21788  

        Index Information
        -----------------
        Index Name                       Column Name                      Unique Unique Contraint Index Type      

        Foreign Key Information containing primary key of the table and all foreign keys that refer to it
        -------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        Product_Component_ID             InstallPoint         dbo              PRODUCT_INSTALLATION             Product_Component_ID             1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefPRODUCT_COMPONENT52           PK__PRODUCT___B5F39AE151C21788  

        Foreign Key Information for all foreign keys in the table and the primary keys to which they refer
        --------------------------------------------------------------------------------------------------
        PKCOLUMN_NAME                    FKTABLE_CAT          FKTABLE_SCHEM    FKTABLE_NAME                     FKCOLUMN_NAME                    KEY_SEQ  UPDATE_RULE      DELETE_RULE      DEFERRABILITY    FK_NAME                          PK_NAME                         
        Product_Version_ID               InstallPoint         dbo              PRODUCT_COMPONENT                Product_Version_ID               1        NO ACTION        NO ACTION        NOT DEFERRABLE   RefPRODUCT_VERSION12             PK__PRODUCT___F29FB6FF7E9DCADF  

        Column Information
        ------------------
        COLUMN_NAME                      TYPE_NAME            COLUMN_SIZE  DECIMAL_DIGITS   COLUMN_DEF           ORDINAL_POSITION IS_NULLABLE     
        In_Production_Fl                 bit                  0            0                                     6                YES             
        Create_Dt                        datetime             0            0                                     11               NO              
        Product_Component_Nm             varchar              100          0                                     3                NO              
        Product_Component_Dsc            varchar              200          0                                     7                YES             
        Order_Num                        int                  10           0                                     9                YES             
        Update_User_ID                   nvarchar             128          0                                     12               NO              
        Product_Version_ID               int                  10           0                                     2                NO              
        Product_Component_Ver_Num        int                  10           0                                     14               NO              
        Template_URL_Tx                  varchar              200          0                                     8                YES             
        Product_Component_ID             int                  10           0                                     1                NO              
        Component_Type_Cd                int                  10           0                                     4                NO              
        Update_Dt                        datetime             0            0                                     13               NO              
        Create_User_ID                   nvarchar             128          0                                     10               NO              
        Availability_Dt                  datetime             0            0                                     5                YES             

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
            IF (@pi_Product_Component_Ver_Num >= 10000)
            BEGIN
               SET @VerNum = 1;
            END
            ELSE
            BEGIN
               SET @VerNum = @pi_Product_Component_Ver_Num + 1;
            END;

            -- Start the transaction
            BEGIN TRANSACTION;

            -- Delete the row
            DELETE FROM dbo.PRODUCT_COMPONENT
            WHERE Product_Component_ID = @pi_Product_Component_ID
              AND Product_Component_Ver_Num = @pi_Product_Component_Ver_Num;

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
		'Del_PRODUCT_COMPONENT', -- Procedure_Name
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
         WHERE ROUTINE_SCHEMA = 'dbo' AND ROUTINE_NAME = 'Del_PRODUCT_COMPONENT')
    BEGIN
        RAISERROR('Altered procedure "%s.%s".',10,1,'dbo','Del_PRODUCT_COMPONENT') WITH NOWAIT;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'SVN Revision',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'PROCEDURE',
		                            @level1name = 'Del_PRODUCT_COMPONENT';
	end try
	begin catch
		set nocount on;
	end catch;

	begin try
	        EXEC sp_dropextendedproperty @name  = 'MS_Description',
		                            @level0type = 'SCHEMA',
		                            @level0name = 'dbo',
		                            @level1type = 'Procedure',
		                            @level1name = 'Del_PRODUCT_COMPONENT';
	end try
	begin catch
		set nocount on;
	end catch;

        EXEC sp_addextendedproperty @name  = 'SVN Revision',
	                            @value      = '$Rev$',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'PROCEDURE',
	                            @level1name = 'Del_PRODUCT_COMPONENT';

        EXEC sp_addextendedproperty @name  = 'MS_Description',
	                            @value      = 'dbo.Del_PRODUCT_COMPONENT performs a delete of a row from the dbo.PRODUCT_COMPONENT',
	                            @level0type = 'SCHEMA',
	                            @level0name = 'dbo',
	                            @level1type = 'Procedure',
	                            @level1name = 'Del_PRODUCT_COMPONENT';
    END
ELSE
    BEGIN
        RAISERROR('ERROR: Unable to alter procedure "%s.%s".',16,1,'dbo','Del_PRODUCT_COMPONENT');
    END;
GO

