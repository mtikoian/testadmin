/* 
Name:			cds.Fund.Table.sql              
Author:			Rob McKenna    
Description:	Rollback to DROP the Fund and Fund_Pending tables
History:
				20140227	Initial Version 
*/

BEGIN TRY

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_Fund_Pending_Fund') AND parent_object_id = OBJECT_ID(N'cds.Fund_Pending'))
		BEGIN
			ALTER TABLE [cds].[Fund_Pending] DROP CONSTRAINT [FK_Fund_Pending_Fund]
			PRINT 'cds.FK_Fund_Pending_Fund DROPPED'
		END
	ELSE
		PRINT 'cds.FK_Fund_Pending_Fund NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_Fund_Pending_FundType') AND parent_object_id = OBJECT_ID(N'cds.Fund_Pending'))
		BEGIN
			ALTER TABLE [cds].[Fund_Pending] DROP CONSTRAINT [FK_Fund_Pending_FundType]
			PRINT 'cds.FK_Fund_Pending_FundType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_Fund_Pending_FundType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_Fund_Pending_ActiveFlag') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[Fund_Pending] DROP CONSTRAINT [DF_Fund_Pending_ActiveFlag]
			PRINT 'cds.DF_Fund_Pending_ActiveFlag DROPPED'
		END
	ELSE
		PRINT 'cds.DF_Fund_Pending_ActiveFlag NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_Fund_Pending_Created') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[Fund_Pending] DROP CONSTRAINT [DF_Fund_Pending_Created]
			PRINT 'cds.DF_Fund_Pending_Created DROPPED'
		END
	ELSE
		PRINT 'cds.DF_Fund_Pending_Created NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_Fund_Pending_LastUpdate') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[Fund_Pending] DROP CONSTRAINT [DF_Fund_Pending_LastUpdate]
			PRINT 'cds.DF_Fund_Pending_LastUpdate DROPPED'
		END
	ELSE
		PRINT 'cds.DF_Fund_Pending_LastUpdate NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'cds.Fund_Pending') AND type in (N'U'))
		BEGIN 
			DROP TABLE [cds].[Fund_Pending]
			PRINT 'TABLE cds.Fund_Pending DROPPED SUCCESSFULLY'
		END	
	ELSE
		PRINT 'TABLE cds.Fund_Pending DOES NOT EXIST'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_Fund_Fund') AND parent_object_id = OBJECT_ID(N'cds.Fund'))
		BEGIN
			ALTER TABLE [cds].[Fund] DROP CONSTRAINT [FK_Fund_Fund]
			PRINT 'cds.FK_Fund_Fund DROPPED'
		END
	ELSE
		PRINT 'cds.FK_Fund_Fund NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_Fund_FundType') AND parent_object_id = OBJECT_ID(N'cds.Fund'))
		BEGIN
			ALTER TABLE [cds].[Fund] DROP CONSTRAINT [FK_Fund_FundType]
			PRINT 'cds.FK_Fund_FundType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_Fund_FundType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_Fund_ActiveFlag') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[Fund] DROP CONSTRAINT [DF_Fund_ActiveFlag]
			PRINT 'cds.DF_Fund_ActiveFlag DROPPED'
		END
	ELSE
		PRINT 'cds.DF_Fund_ActiveFlag NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_Fund_Created') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[Fund] DROP CONSTRAINT [DF_Fund_Created]
			PRINT 'cds.DF_Fund_Created DROPPED'
		END
	ELSE
		PRINT 'cds.DF_Fund_Created NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_Fund_LastUpdate') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[Fund] DROP CONSTRAINT [DF_Fund_LastUpdate]
			PRINT 'cds.DF_Fund_LastUpdate DROPPED'
		END
	ELSE
		PRINT 'cds.DF_Fund_LastUpdate NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'cds.Fund') AND type in (N'U'))
		BEGIN 
			DROP TABLE [cds].[Fund]
			PRINT 'TABLE cds.Fund DROPPED SUCCESSFULLY'
		END	
	ELSE
		PRINT 'TABLE cds.Fund DOES NOT EXIST'

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