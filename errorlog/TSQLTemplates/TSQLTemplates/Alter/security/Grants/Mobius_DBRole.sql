USE NETIKIP
GO

/***********************************************************************************
Author:          VBANDI
Description:	 Implementing Roles for Mobius Accounts to access NETIKIP
Scripted Date:   01.27.2013
************************************************************************************/
IF NOT EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = 'svcMDBMobius'
		)
	CREATE USER svcMDBMobius
	FOR LOGIN svcMDBMobius

PRINT 'Added svcMDBMobius SQL User'
GO

--Data base Role for Mobius  
/*
creation of the role 
*/
-- Create the urole  
IF NOT EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = N'u_role_mobius'
			AND type = 'R'
		)
	CREATE ROLE u_role_mobius AUTHORIZATION dbo;
GO

IF EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = N'u_role_mobius'
			AND type IN ('R')
		)
BEGIN
	PRINT '<<< CREATED ROLE  u_role_mobius IN DATABASE >>>'
END
GO

-- Create the  prole 
IF NOT EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = N'p_role_mobius'
			AND type = 'R'
		)
	CREATE ROLE p_role_mobius AUTHORIZATION dbo;
GO

IF EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = N'p_role_mobius'
			AND type IN ('R')
		)
BEGIN
	PRINT '<<< CREATED ROLE p_role_mobius IN DATABASE  >>>'
END
GO

-- Add the urole to the prole (permissions granted to prole)
EXEC sp_addrolemember @rolename = 'p_role_mobius'
	,@membername = 'u_role_mobius'

IF EXISTS (
		SELECT 1
		FROM sys.database_role_members drm
		INNER JOIN sys.database_principals dp ON drm.role_principal_id = dp.principal_id
		WHERE dp.type = 'R'
			AND dp.NAME = 'p_role_mobius'
		)
BEGIN
	PRINT '<<< ADDED ROLE MEMBER u_role_mobius TO p_role_mobius IN DATABASE  >>>'
END
GO

IF EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = 'svcMDBMobius'
		)
BEGIN
	EXEC sp_addrolemember 'u_role_mobius'
		,'svcMDBMobius'
END
GO


