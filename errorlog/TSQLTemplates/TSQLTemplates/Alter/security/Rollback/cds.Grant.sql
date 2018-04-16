/* 
Name: Tables\cds.Grant.sql              
Author: Sam Page (fpageiv.com)        
Description: Know Your Client Data Services (cds) Schema Revoke  

	Undo p_role_cds and u_role_cds changes.

History:                                   
20131017 sp Initial Version 
20131114 sp Change user name for production.
*/

BEGIN TRY

EXEC sp_droprolemember 'u_role_cds', 'seicitrix_dmn1\svcnetikmdb3'

EXEC sp_droprolemember 'p_role_cds', 'u_role_cds'

ALTER AUTHORIZATION ON SCHEMA::cds TO dbo

DROP ROLE u_role_cds

DROP ROLE p_role_cds

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

