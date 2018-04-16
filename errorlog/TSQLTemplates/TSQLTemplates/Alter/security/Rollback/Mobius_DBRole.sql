USE NETIKIP
GO

/***********************************************************************************
Author:          VBANDI
Description:	 Implementing Roles for Mobius Accounts to access NETIKIP
Scripted Date:   01.27.2013
************************************************************************************/
IF EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = N'svcMDBMobius'
		)
BEGIN
	EXEC sp_droprolemember 'u_role_mobius'
		,'svcMDBMobius'
END
GO

IF EXISTS (
		SELECT 1
		FROM sys.database_principals
		WHERE NAME = N'svcMDBMobius'
		)
BEGIN
	EXEC sp_droprolemember 'p_role_mobius'
		,'u_role_mobius'
END
GO

IF EXISTS (
		SELECT 1
		FROM SYS.DATABASE_PRINCIPALS
		WHERE NAME = N'svcMDBMobius'
		)
BEGIN
	DROP USER svcMDBMobius

	PRINT 'dropped svcMDBMobius User'
END
GO

IF EXISTS (
		SELECT 1
		FROM SYS.DATABASE_PRINCIPALS
		WHERE NAME = N'u_role_mobius'
			AND TYPE = 'R'
		)
BEGIN
	DROP ROLE u_role_mobius

	PRINT 'u_role_mobius dropped'
END
GO

IF EXISTS (
		SELECT 1
		FROM SYS.DATABASE_PRINCIPALS
		WHERE NAME = N'p_role_mobius'
			AND TYPE = 'R'
		)
BEGIN
	DROP ROLE p_role_mobius

	PRINT 'p_role_mobius dropped'
END
GO


