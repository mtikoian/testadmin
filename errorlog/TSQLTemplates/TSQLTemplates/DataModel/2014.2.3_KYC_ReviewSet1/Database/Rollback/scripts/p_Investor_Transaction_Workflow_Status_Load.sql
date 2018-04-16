USE NetikIP;
GO

-- Drop stored procedure if it already exists
IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.ROUTINES
		WHERE SPECIFIC_SCHEMA = N'dbo'
			AND SPECIFIC_NAME = N'p_Investor_Transaction_Workflow_Status_Load'
		)
BEGIN
	DROP PROCEDURE dbo.p_Investor_Transaction_Workflow_Status_Load;

	PRINT 'PROCEDURE dbo.p_Investor_Transaction_Workflow_Status_Load has been dropped.';
END;
GO
