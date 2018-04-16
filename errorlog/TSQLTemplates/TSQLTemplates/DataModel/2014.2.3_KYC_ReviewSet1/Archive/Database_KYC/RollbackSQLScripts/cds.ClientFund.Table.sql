/* 
Name:			cds.ClientFund.Table.sql              
Author:			Rob McKenna    
Description:	Rollback to DROP the ClientFund and ClientFund_Pending tables
History:
				20140227	Initial Version 
*/

BEGIN TRY
	--ClientFund_Pending
	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_ClientFund_Pending_Client') 
				AND parent_object_id = OBJECT_ID(N'cds.ClientFund_Pending'))
		BEGIN
			ALTER TABLE [cds].[ClientFund_Pending] DROP CONSTRAINT [FK_ClientFund_Pending_Client]
			PRINT 'cds.FK_ClientFund_Pending_Client DROPPED'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Pending_Client NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_ClientFund_Pending_Fund') 
				AND parent_object_id = OBJECT_ID(N'cds.ClientFund_Pending'))
		BEGIN
			ALTER TABLE [cds].[ClientFund_Pending] DROP CONSTRAINT [FK_ClientFund_Pending_Fund]
			PRINT 'cds.FK_ClientFund_Pending_Fund DROPPED'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Pending_Fund NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_ClientFund_Pending_Client') 
				AND parent_object_id = OBJECT_ID(N'cds.ClientFund_Pending'))
		BEGIN
			ALTER TABLE [cds].[ClientFund_Pending] DROP CONSTRAINT [FK_ClientFund_Pending_Client]
			PRINT 'cds.FK_ClientFund_Pending_Client DROPPED'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Pending_Client NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_ClientFund_Pending_Fund') 
				AND parent_object_id = OBJECT_ID(N'cds.ClientFund_Pending'))
		BEGIN
			ALTER TABLE [cds].[ClientFund_Pending] DROP CONSTRAINT [FK_ClientFund_Pending_Fund]
			PRINT 'cds.FK_ClientFund_Pending_Fund DROPPED'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Pending_Fund NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_ClientFund_Pending_ActiveFlag') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[ClientFund_Pending] DROP CONSTRAINT [DF_ClientFund_Pending_ActiveFlag]
			PRINT 'cds.DF_ClientFund_Pending_ActiveFlag DROPPED'
		END
	ELSE
		PRINT 'cds.DF_ClientFund_Pending_ActiveFlag NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_ClientFund_Pending_Created') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[ClientFund_Pending] DROP CONSTRAINT [DF_ClientFund_Pending_Created]
			PRINT 'cds.DF_ClientFund_Pending_Created DROPPED'
		END
	ELSE
		PRINT 'cds.DF_ClientFund_Pending_Created NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_ClientFund_Pending_LastUpdate') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[ClientFund_Pending] DROP CONSTRAINT [DF_ClientFund_Pending_LastUpdate]
			PRINT 'cds.DF_ClientFund_Pending_LastUpdate DROPPED'
		END
	ELSE
		PRINT 'cds.DF_ClientFund_Pending_LastUpdate NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'cds.ClientFund_Pending') AND type in (N'U'))
		BEGIN 
			DROP TABLE [cds].[ClientFund_Pending]
			PRINT 'TABLE cds.ClientFund_Pending DROPPED SUCCESSFULLY'
		END	
	ELSE
		PRINT 'TABLE cds.ClientFund_Pending DOES NOT EXIST'

	--ClientFund
	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_ClientFund_Client') 
				AND parent_object_id = OBJECT_ID(N'cds.ClientFund'))
		BEGIN
			ALTER TABLE [cds].[ClientFund] DROP CONSTRAINT [FK_ClientFund_Client]
			PRINT 'cds.FK_ClientFund_Client DROPPED'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Client NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_ClientFund_Fund') 
				AND parent_object_id = OBJECT_ID(N'cds.ClientFund'))
		BEGIN
			ALTER TABLE [cds].[ClientFund] DROP CONSTRAINT [FK_ClientFund_Fund]
			PRINT 'cds.FK_ClientFund_Fund DROPPED'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Fund NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_ClientFund_Client') 
				AND parent_object_id = OBJECT_ID(N'cds.ClientFund'))
		BEGIN
			ALTER TABLE [cds].[ClientFund] DROP CONSTRAINT [FK_ClientFund_Client]
			PRINT 'cds.FK_ClientFund_Client DROPPED'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Client NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_ClientFund_Fund') 
				AND parent_object_id = OBJECT_ID(N'cds.ClientFund'))
		BEGIN
			ALTER TABLE [cds].[ClientFund] DROP CONSTRAINT [FK_ClientFund_Fund]
			PRINT 'cds.FK_ClientFund_Fund DROPPED'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Fund NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_ClientFund_ActiveFlag') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[ClientFund] DROP CONSTRAINT [DF_ClientFund_ActiveFlag]
			PRINT 'cds.DF_ClientFund_ActiveFlag DROPPED'
		END
	ELSE
		PRINT 'cds.DF_ClientFund_ActiveFlag NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_ClientFund_Created') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[ClientFund] DROP CONSTRAINT [DF_ClientFund_Created]
			PRINT 'cds.DF_ClientFund_Created DROPPED'
		END
	ELSE
		PRINT 'cds.DF_ClientFund_Created NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_ClientFund_LastUpdate') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[ClientFund] DROP CONSTRAINT [DF_ClientFund_LastUpdate]
			PRINT 'cds.DF_ClientFund_LastUpdate DROPPED'
		END
	ELSE
		PRINT 'cds.DF_ClientFund_LastUpdate NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'cds.ClientFund') AND type in (N'U'))
		BEGIN 
			DROP TABLE [cds].[ClientFund]
			PRINT 'TABLE cds.ClientFund DROPPED SUCCESSFULLY'
		END	
	ELSE
		PRINT 'TABLE cds.ClientFund DOES NOT EXIST'

END TRY

BEGIN CATCH
    DECLARE @errmsg NVARCHAR(2048);
    DECLARE @errsev INT;
    DECLARE @errstate INT;

    SET @errmsg = 'Error dropping objects ' + ERROR_MESSAGE();
    SET @errsev = ERROR_SEVERITY();
    SET @errstate = ERROR_STATE();

    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

GO