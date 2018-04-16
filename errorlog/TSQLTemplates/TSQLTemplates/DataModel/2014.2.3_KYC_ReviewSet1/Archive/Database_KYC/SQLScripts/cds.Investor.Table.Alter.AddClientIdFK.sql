/* 
Name:			Tables\cds.Investor.Table.Alter.AddClientIdFK.sql              
Author:			Rob McKenna    
Description:	Add ClientId to Investor and Investor_Pending
History:
				20140227	Initial Version 
*/

BEGIN TRY
		
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_Investor_Pending_Client') 
					AND parent_object_id = OBJECT_ID(N'cds.Investor_Pending'))
		BEGIN
		ALTER TABLE cds.Investor_Pending  WITH CHECK ADD  CONSTRAINT FK_Investor_Pending_Client FOREIGN KEY(ClientId)
			REFERENCES cds.Client_Pending(ClientId);

			PRINT 'cds.FK_Investor_Pending_Client created'
		END
	ELSE
		PRINT 'cds.FK_Investor_Pending_Client NOT created'
		
	IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_Investor_Pending_Client') 
				AND parent_object_id = OBJECT_ID(N'cds.Investor_Pending'))
		BEGIN
		ALTER TABLE cds.Investor_Pending CHECK CONSTRAINT FK_Investor_Pending_Client	

			PRINT 'cds.FK_Investor_Pending_Client created'
		END
	ELSE
		PRINT 'cds.FK_Investor_Pending_Client NOT created'

	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_Investor_Client') 
					AND parent_object_id = OBJECT_ID(N'cds.Investor'))
		BEGIN
		ALTER TABLE cds.Investor  WITH CHECK ADD  CONSTRAINT FK_Investor_Client FOREIGN KEY(ClientId)
			REFERENCES cds.Client(ClientId);

			PRINT 'cds.FK_Investor_Client created'
		END
	ELSE
		PRINT 'cds.FK_Investor_Client NOT created'
		
	IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_Investor_Client') 
				AND parent_object_id = OBJECT_ID(N'cds.Investor'))
		BEGIN
		ALTER TABLE cds.Investor CHECK CONSTRAINT FK_Investor_Client

			PRINT 'cds.FK_Investor_Client created'
		END
	ELSE
		PRINT 'cds.FK_Investor_Client NOT created'

END TRY

BEGIN CATCH
    DECLARE @errmsg NVARCHAR(2048);
    DECLARE @errsev INT;
    DECLARE @errstate INT;

    SET @errmsg = 'Error adding ClientId column ' + ERROR_MESSAGE();
    SET @errsev = ERROR_SEVERITY();
    SET @errstate = ERROR_STATE();

    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

GO 

