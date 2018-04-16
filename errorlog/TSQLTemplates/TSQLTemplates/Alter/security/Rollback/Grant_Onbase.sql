USE NETIKIP;
GO
/***********************************************************************************
Author:          VBANDI
Description:	 Grant access to Roles for Onbase Accounts in  NETIKIP
Scripted Date:   03.19.2013
************************************************************************************/
IF EXISTS (
		SELECT 1
		FROM sysusers u
		WHERE issqlrole = 1
			AND NAME = 'p_role_Onbase'
		)
BEGIN
	REVOKE INSERT
		ON dbo.Investor_Transaction_Workflow_Status
		TO p_role_Onbase AS dbo;

	REVOKE SELECT
		ON dbo.Investor_Transaction_Workflow_Status
		TO p_role_Onbase AS dbo;

	REVOKE UPDATE
		ON dbo.Investor_Transaction_Workflow_Status
		TO p_role_Onbase AS dbo;

	REVOKE EXECUTE
		ON dbo.p_Investor_Transaction_Workflow_Status_Load
		TO p_role_Onbase AS dbo;

	PRINT '>>>Revoked permissions of p_role_Onbase<<<';
END;
