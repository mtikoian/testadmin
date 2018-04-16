USE NetikIP
GO

/*
 File Name				: Create_Table_Transaction_Status.sql
 Description   			: This tables stored Transaction_Status information
 Created By    			: VBANDI
 Created Date  			: 02/24/2014
 Modification History	:
 ------------------------------------------------------------------------------
 Date		Modified By 		Description
*/
PRINT ''
PRINT '----------------------------------------'
PRINT 'TABLE script for Transaction_Status'
PRINT '----------------------------------------'

BEGIN TRY

	IF  EXISTS 
		(
			SELECT 1 
			FROM   information_schema.Tables 
			WHERE  Table_schema = 'dbo' 
				   AND Table_name = 'Transaction_Status'  
		)
		BEGIN
			DROP Table dbo.Transaction_Status
			PRINT 'Table dbo.Transaction_Status has been dropped.'
		END
CREATE TABLE dbo.Transaction_Status (
	 Transaction_Status_Cd INT  NOT NULL,
	 Transaction_Status_Name  varchar(60)  NOT NULL
						)

							

PRINT 'Adding constraints to TABLE dbo.Transaction_Status'

		ALTER TABLE dbo.Transaction_Status ADD
			constraint	PK__Transaction_Status__Transaction_Status_Cd PRIMARY KEY CLUSTERED(Transaction_Status_Cd),
			constraint	UQ__Transaction_Status__Transaction_Status_Name	 UNIQUE NONCLUSTERED(Transaction_Status_Name);


	-- Validate if the table has been created.
	IF  EXISTS 
		(
			SELECT 1 
			FROM   information_schema.Tables 
			WHERE  Table_schema = 'dbo' 
				   AND Table_name = 'Transaction_Status'  
		)
		BEGIN
			PRINT 'Table dbo.Transaction_Status has been created.'
		END
	ELSE
		BEGIN
			PRINT 'Failed to create Table dbo.Transaction_Status_Info!!!!!!!'
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
PRINT 'End of TABLE script for Transaction_Status';
PRINT '----------------------------------------';
