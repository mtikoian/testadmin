USE [NetikExt]
GO

/*==================================================================================================           
Name		: PermissionScript.sql           
Author		: vperala 
Description : Grant Permission to Infomatica user to laod GL data into NetikExt database.

*/
-----------------------------------------------Production-----------------------------------------------


	IF  NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'seicitrix_dmn1/svcINFPWCPRD')
	BEGIN
		PRINT 'seicitrix_dmn1/svcINFPWCPRD user doesnot exist; Creating'
		CREATE USER [seicitrix_dmn1/svcINFPWCPRD] FOR LOGIN [seicitrix_dmn1/svcINFPWCPRD] WITH DEFAULT_SCHEMA=[ims]
	END
	ELSE
		PRINT 'seicitrix_dmn1/svcINFPWCPRD user already exist in the database'
	GO

	IF  EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'seicitrix_dmn1/svcINFPWCPRD')
		EXEC sp_addrolemember N'p_role_IMS', N'seicitrix_dmn1/svcINFPWCPRD'
	GO

	IF  EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'seicitrix_dmn1/svcINFPWCPRD')
		EXEC sp_addrolemember N'u_role_ims',N'seicitrix_dmn1/svcINFPWCPRD'
	GO


	IF  EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'seicitrix_dmn1/svcINFPWCPRD')
		GRANT EXECUTE ON [ims].[p_F11_GetRequestInfo] TO [seicitrix_dmn1/svcINFPWCPRD]
	GO

	IF  EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'seicitrix_dmn1/svcINFPWCPRD')
		GRANT EXECUTE ON [ims].[p_inf_GetFileInfoId] TO [seicitrix_dmn1/svcINFPWCPRD]
	GO

	IF  EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'seicitrix_dmn1/svcINFPWCPRD')
	BEGIN
		GRANT EXECUTE ON [ims].[p_inf_GetCustomerInfo] TO [seicitrix_dmn1/svcINFPWCPRD]				
	END
	GO
