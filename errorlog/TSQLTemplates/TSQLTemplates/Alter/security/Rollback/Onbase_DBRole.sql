USE NETIKIP;
GO

/***********************************************************************************
Author:          VBANDI
Description:	 Implementing Roles for Onbase Accounts to access NETIKIP
Scripted Date:   03.17.2013
************************************************************************************/
IF EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = N'svcMDBOnbase'
		)
BEGIN
	EXEC dbo.sp_droprolemember 'u_role_Onbase'
		,'sei-domain-1\IMS-OnBase-Utility-Servers';
END;
GO

IF EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = N'sei-domain-1\IMS-OnBase-Utility-Servers'
		)
BEGIN
	EXEC dbo.sp_droprolemember 'p_role_Onbase'
		,'u_role_Onbase';
END;
GO

IF EXISTS (
		SELECT 1
		FROM SYS.DATABASE_PRINCIPALS
		WHERE NAME = N'sei-domain-1\IMS-OnBase-Utility-Servers'
		)
BEGIN
	DROP USER [sei-domain-1\IMS-OnBase-Utility-Servers];

	PRINT 'dropped sei-domain-1\IMS-OnBase-Utility-Servers User';
END;
GO

IF EXISTS (
		SELECT 1
		FROM SYS.DATABASE_PRINCIPALS
		WHERE NAME = N'u_role_Onbase'
			AND TYPE = 'R'
		)
BEGIN
	DROP ROLE u_role_Onbase;

	PRINT 'u_role_Onbase dropped';
END;
GO

IF EXISTS (
		SELECT 1
		FROM SYS.DATABASE_PRINCIPALS
		WHERE NAME = N'p_role_Onbase'
			AND TYPE = 'R'
		)
BEGIN
	DROP ROLE p_role_Onbase;

	PRINT 'p_role_Onbase dropped';
END;
GO


