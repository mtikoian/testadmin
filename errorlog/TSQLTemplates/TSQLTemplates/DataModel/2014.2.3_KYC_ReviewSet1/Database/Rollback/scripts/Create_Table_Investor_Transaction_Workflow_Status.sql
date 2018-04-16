USE NetikIP
GO

/*
 File Name				: Create_Table_Investor_Transaction_Workflow_Status.sql
 Description   			: This tables stored Investor_Transaction_Workflow_Status information
 Created By    			: VBANDI
 Created Date  			: 02/24/2014
 Modification History	:
 ------------------------------------------------------------------------------
 Date		Modified By 		Description
*/
PRINT ''
PRINT '----------------------------------------'
PRINT 'TABLE script for Investor_Transaction_Workflow_Status'
PRINT '----------------------------------------'

BEGIN TRY
	IF EXISTS (
			SELECT 1
			FROM information_schema.Tables
			WHERE Table_schema = 'dbo'
				AND Table_name = 'Investor_Transaction_Workflow_Status'
			)
	BEGIN
		DROP TABLE dbo.Investor_Transaction_Workflow_Status;
		PRINT 'Table dbo.Investor_Transaction_Workflow_Status has been dropped.';
	END

	-- Validate if the table has been created.
	IF EXISTS (
			SELECT 1
			FROM information_schema.Tables
			WHERE Table_schema = 'dbo'
				AND Table_name = 'Investor_Transaction_Workflow_Status'
			)
	BEGIN
		PRINT 'Table dbo.Investor_Transaction_Workflow_Status has been created.'
	END
	ELSE
	BEGIN
		PRINT 'Dropped dbo.Investor_Transaction_Workflow_Status_Info!!!!!!!'
	END
END TRY

BEGIN CATCH
	DECLARE @error_Message VARCHAR(2100);
	DECLARE @error_Severity INT;
	DECLARE @error_State INT;

	SET @error_Message = Error_Message()
	SET @error_Severity = Error_Severity()
	SET @error_State = Error_State()

	RAISERROR (
			@error_Message
			,@error_Severity
			,@error_State
			);
END CATCH;

PRINT '';
PRINT 'End of TABLE script for Investor_Transaction_Workflow_Status';
PRINT '----------------------------------------';
