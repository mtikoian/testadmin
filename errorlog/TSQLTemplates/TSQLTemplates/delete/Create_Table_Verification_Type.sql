USE NetikIP
GO

/*
 File Name				: Create_Table_Verification_Type.sql
 Description   			: This tables stored Verification_Type information
 Created By    			: VBANDI
 Created Date  			: 02/24/2014
 Modification History	:
 ------------------------------------------------------------------------------
 Date		Modified By 		Description
*/
PRINT ''
PRINT '----------------------------------------'
PRINT 'TABLE script for Verification_Type'
PRINT '----------------------------------------'

BEGIN TRY

	IF  EXISTS 
		(
			SELECT 1 
			FROM   information_schema.Tables 
			WHERE  Table_schema = 'dbo' 
				   AND Table_name = 'Verification_Type'  
		)
		BEGIN
			DROP Table dbo.Verification_Type
			PRINT 'Table dbo.Verification_Type has been dropped.'
		END
CREATE TABLE dbo.Verification_Type (
	 Verification_Type_ID INT  NOT NULL,
	 Verification_Type_Name  varchar(50)  NOT NULL
						)

							

PRINT 'Adding constraints to TABLE dbo.Verification_Type'

		ALTER TABLE dbo.Verification_Type ADD
			constraint	PK__Verification_Type__Verification_Type_Id PRIMARY KEY CLUSTERED(Verification_Type_Id),
			constraint	UQ__Verification_Type__Verification_Type_Name	 UNIQUE NONCLUSTERED(Verification_Type_Name);


	-- Validate if the table has been created.
	IF  EXISTS 
		(
			SELECT 1 
			FROM   information_schema.Tables 
			WHERE  Table_schema = 'dbo' 
				   AND Table_name = 'Verification_Type'  
		)
		BEGIN
			PRINT 'Table dbo.Verification_Type has been created.'
		END
	ELSE
		BEGIN
			PRINT 'Failed to create Table dbo.Verification_Type!!!!!!!'
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
PRINT 'End of TABLE script for Verification_Type';
PRINT '----------------------------------------';
