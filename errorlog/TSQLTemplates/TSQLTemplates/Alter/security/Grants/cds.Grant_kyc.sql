/* 
Name: Tables\cds.Grant.sql              
Author: Sam Page (fpageiv.com)        
Description: Know Your Client Data Services (cds) Schema Grant  

	Creates new "permissions" role (p_role_cds) and associates
	it as owner of the cds schema.

	Creates new "users" role (u_role_cds), and adds this role as
	member of the p_role_cds role.

	Adds the application domain account "seicitrix_dmn1\svcnetikmdb3" as a 
	member of the u_role_cds role.

History:                                   
20131017 sp Initial Version 
20131114 sp Change user name for production.
*/
   -- AFL
USE [NetikIP];
GO

-- Create the UI user in the NetikIP database
IF NOT  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'seicitrix_dmn1\svcnetikmdb3')
CREATE USER [seicitrix_dmn1\svcnetikmdb3] FOR LOGIN [seicitrix_dmn1\svcnetikmdb3] WITH DEFAULT_SCHEMA=[dbo];
GO
   -- AFL

BEGIN TRY

CREATE ROLE p_role_cds AUTHORIZATION dbo

ALTER AUTHORIZATION ON SCHEMA::cds TO p_role_cds

GRANT SELECT ON dbo.CUST TO p_role_cds;

GRANT SELECT ON dbo.GP_FUND TO p_role_cds;

CREATE ROLE u_role_cds AUTHORIZATION dbo;

EXEC sp_addrolemember N'p_role_cds', N'u_role_cds'

EXEC sp_addrolemember 'u_role_cds', 'seicitrix_dmn1\svcnetikmdb3'

END TRY

BEGIN CATCH
    DECLARE @errmsg NVARCHAR(2048);
    DECLARE @errsev INT;
    DECLARE @errstate INT;

    SET @errmsg = 'Error dropping objects' + ERROR_MESSAGE();
    SET @errsev = ERROR_SEVERITY();
    SET @errstate = ERROR_STATE();

    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

GO 

