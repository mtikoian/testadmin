/* 
Name: cds.Grant.ServiceAccount_DEV.sql              
Author: Rob McKenna (rmckenna)
Description: Know Your Client Data Services (cds) Schema Grant  

                Adds the application domain account "CTC\IMSKYC_SVC_WEB_DEV" as a 
                member of the u_role_cds role.

History:                                   
20140304 sp Initial Version 
*/
USE [NetikIP];
GO

-- Create the UI user in the NetikIP database
IF NOT  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'CTC\IMSKYC_SVC_WEB_DEV')
CREATE USER [CTC\IMSKYC_SVC_WEB_DEV] FOR LOGIN [CTC\IMSKYC_SVC_WEB_DEV] WITH DEFAULT_SCHEMA=[dbo];
GO


BEGIN TRY


EXEC sp_addrolemember 'u_role_cds', 'CTS\IMSKYC_SVC_WEB_DEV'

END TRY

BEGIN CATCH
    DECLARE @errmsg NVARCHAR(2048);
    DECLARE @errsev INT;
    DECLARE @errstate INT;

    SET @errmsg = 'Error creating user and adding to role ' + ERROR_MESSAGE();
    SET @errsev = ERROR_SEVERITY();
    SET @errstate = ERROR_STATE();

    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

GO 
