USE NETIKIP;
GO

/***********************************************************************************
Author:          VBANDI
Description:	 Implementing Roles for Onbase Accounts to access NETIKIP
Scripted Date:   01.27.2013
************************************************************************************/


IF NOT EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = 'sei-domain-1\IMS-OnBase-Utility-Servers'
		)
	CREATE USER [sei-domain-1\IMS-OnBase-Utility-Servers]
	FOR LOGIN [sei-domain-1\IMS-OnBase-Utility-Servers];

PRINT 'Added [sei-domain-1\IMS-OnBase-Utility-Servers] SQL User';
GO

--Data base Role for Onbase  
/*
creation of the role 
*/
-- Create the urole  
IF NOT EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = N'u_role_Onbase'
			AND type = 'R'
		)
	CREATE ROLE u_role_Onbase AUTHORIZATION dbo;
GO

IF EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = N'u_role_Onbase'
			AND type IN ('R')
		)
BEGIN
	PRINT '<<< CREATED ROLE  u_role_Onbase IN DATABASE >>>';
END;
GO

-- Create the  prole 
IF NOT EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = N'p_role_Onbase'
			AND type = 'R'
		)
	CREATE ROLE p_role_Onbase AUTHORIZATION dbo;
GO

IF EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = N'p_role_Onbase'
			AND type IN ('R')
		)
BEGIN
	PRINT '<<< CREATED ROLE p_role_Onbase IN DATABASE  >>>';
END;
GO

-- Add the urole to the prole (permissions granted to prole)
EXEC dbo.sp_addrolemember @rolename = 'p_role_Onbase'
	,@membername = 'u_role_Onbase';

IF EXISTS (
		SELECT 1
		FROM sys.database_role_members drm
		INNER JOIN sys.database_principals dp ON drm.role_principal_id = dp.principal_id
		WHERE dp.type = 'R'
			AND dp.NAME = 'p_role_Onbase'
		)
BEGIN
	PRINT '<<< ADDED ROLE MEMBER u_role_Onbase TO p_role_Onbase IN DATABASE  >>>';
END;
GO

IF EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = 'svcMDBOnbase'
		)
BEGIN
	EXEC dbo.sp_addrolemember 'u_role_Onbase'
		,'sei-domain-1\IMS-OnBase-Utility-Servers';
END;
GO


