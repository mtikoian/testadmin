/* 
Name:			Tables\cds.Investor.Table.Alter.AddClientId.sql              
Author:			Rob McKenna    
Description:	Add ClientId to Investor and Investor_Pending
History:
				20140227	Initial Version 
*/

BEGIN TRY

	IF NOT EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'Investor'
		       		  AND column_name = 'ClientId')
		BEGIN
			ALTER TABLE cds.Investor ADD ClientId char(12) NULL;

			PRINT 'cds.Investor ClientId added'
		END
	ELSE
		PRINT 'cds.Investor ClientId NOT added'

	IF NOT EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'Investor_Pending'
		       		  AND column_name = 'ClientId')
		BEGIN
			ALTER TABLE cds.Investor_Pending ADD ClientId char(12) NULL;

			PRINT 'cds.Investor_Pending ClientId added'
		END
	ELSE
		PRINT 'cds.Investor_Pending ClientId NOT added'

END TRY

BEGIN CATCH
    DECLARE @errmsg NVARCHAR(2048);
    DECLARE @errsev INT;
    DECLARE @errstate INT;

    SET @errmsg = 'Error adding DocumentPermissionId column ' + ERROR_MESSAGE();
    SET @errsev = ERROR_SEVERITY();
    SET @errstate = ERROR_STATE();

    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

GO 

