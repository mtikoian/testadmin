USE NetikIP
GO

/*
 File Name				: Create_Table_Corporation_Type.sql
 Description   			: This tables stored Corporation_Type information
 Created By    			: VBANDI
 Created Date  			: 02/24/2014
 Modification History	:
 ------------------------------------------------------------------------------
 Date		Modified By 		Description
*/
PRINT ''
PRINT '----------------------------------------'
PRINT 'TABLE script for Corporation_Type'
PRINT '----------------------------------------'

BEGIN TRY

	IF  EXISTS 
		(
			SELECT 1 
			FROM   information_schema.Tables 
			WHERE  Table_schema = 'dbo' 
				   AND Table_name = 'Corporation_Type'  
		)
		BEGIN
			DROP Table dbo.Corporation_Type
			PRINT 'Table dbo.Corporation_Type has been dropped.'
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
PRINT 'End of TABLE script for Corporation_Type';
PRINT '----------------------------------------';
