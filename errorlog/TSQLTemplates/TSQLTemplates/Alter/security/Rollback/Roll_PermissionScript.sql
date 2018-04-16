USE [NetikExt]
GO

/*==================================================================================================           
Name		: PermissionScript.sql           
Author		: vperala 
Description : Grant Permission to Infomatica user to laod GL data into NetikExt database.

*/
-----------------------------------------------Production-----------------------------------------------


	IF  EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'seicitrix_dmn1/svcINFPWCPRD')
		EXEC sp_droprolemember N'p_role_IMS', N'seicitrix_dmn1/svcINFPWCPRD'
	GO

	IF  EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'seicitrix_dmn1/svcINFPWCPRD')
		EXEC sp_droprolemember N'u_role_ims', N'seicitrix_dmn1/svcINFPWCPRD'
	GO


	IF  EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'seicitrix_dmn1/svcINFPWCPRD')
	BEGIN
		PRINT 'seicitrix_dmn1/svcINFPWCPRD user exist; DROPPING'
		DROP USER [seicitrix_dmn1/svcINFPWCPRD]
	END
	ELSE
		PRINT 'seicitrix_dmn1/svcINFPWCPRD NOT exist in the database'
	GO
	
	
