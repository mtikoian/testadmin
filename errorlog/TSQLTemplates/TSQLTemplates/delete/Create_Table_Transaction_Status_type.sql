USE NetikIP
GO

/*
 File Name				: Create_Table_Transaction_Status_type.sql
 Description   			: This tables stored Transaction_Status_type information
 Created By    			: VBANDI
 Created Date  			: 02/24/2014
 Modification History	:
 ------------------------------------------------------------------------------
 Date		Modified By 		Description
*/
PRINT ''
PRINT '----------------------------------------'
PRINT 'TABLE script for Transaction_Status_type'
PRINT '----------------------------------------'

BEGIN TRY

	IF  EXISTS 
		(
			SELECT 1 
			FROM   information_schema.Tables 
			WHERE  Table_schema = 'dbo' 
				   AND Table_name = 'Transaction_Status_type'  
		)
		BEGIN
			DROP Table dbo.Transaction_Status_type
			PRINT 'Table dbo.Transaction_Status_type has been dropped.'
		END
CREATE TABLE dbo.Transaction_Status_Type (
	 Transaction_Status_Type_ID INT  NOT NULL,
	 Transaction_Status_Type_Name  varchar(50)  NOT NULL
						)

							

PRINT 'Adding constraints to TABLE dbo.Transaction_Status_type'

		ALTER TABLE dbo.Transaction_Status_type ADD
			constraint	PK__Transaction_Status_type__SEI_Transaction_Status_Type_Id PRIMARY KEY CLUSTERED(SEI_Transaction_Status_Type_Id),
			constraint	UQ__Transaction_Status_type__Transaction_Status_Type_Name	 UNIQUE NONCLUSTERED(Transaction_Status_Type_Name);


	-- Validate if the table has been created.
	IF  EXISTS 
		(
			SELECT 1 
			FROM   information_schema.Tables 
			WHERE  Table_schema = 'dbo' 
				   AND Table_name = 'Transaction_Status_type'  
		)
		BEGIN
			PRINT 'Table dbo.Transaction_Status_type has been created.'
		END
	ELSE
		BEGIN
			PRINT 'Failed to create Table dbo.Transaction_Status_type_Info!!!!!!!'
		END

END TRY
BEGIN CATCH
  DECLARE @error_Message VARCHAR(2100); 
        DECLARE @error_Severity INT; 
        DECLARE @error_State INT; 
	
        SET @error_Message = Error_Message() 
        SET @error_Severity = Error_Severity() 
        SET @error_State = Error_State()         

        RAISERROR (@error_Message,@error_Severity,@error_State); 
END CATCH;
PRINT '';
PRINT 'End of TABLE script for Transaction_Status_type';
PRINT '----------------------------------------';
