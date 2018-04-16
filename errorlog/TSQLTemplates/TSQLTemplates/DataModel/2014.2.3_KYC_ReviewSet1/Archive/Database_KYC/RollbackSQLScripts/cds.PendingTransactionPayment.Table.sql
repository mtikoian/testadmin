/* 
Name:			Tables\cds.PendingTransactionPayment.Table.sql              
Author:			Rob McKenna    
Description:	Rollback to DROP the PendingTransactionPayment and PendingTransactionPayment_Pending tables
History:
				20140227	Initial Version 
*/

BEGIN TRY
	--PendingTransactionPayment_Pending
	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransactionPayment_Pending_Transaction') AND parent_object_id = OBJECT_ID(N'cds.PendingTransactionPayment_Pending'))
		BEGIN
			ALTER TABLE [cds].[PendingTransactionPayment_Pending] DROP CONSTRAINT [FK_PendingTransactionPayment_Pending_Transaction]
			PRINT 'cds.FK_PendingTransactionPayment_Pending_Transaction DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransactionPayment_Pending_Transaction NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_PendingTransactionPayment_Pending_HoldbackFlag') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[PendingTransactionPayment_Pending] DROP CONSTRAINT [DF_PendingTransactionPayment_Pending_HoldbackFlag]
			PRINT 'cds.DF_PendingTransactionPayment_Pending_HoldbackFlag DROPPED'
		END
	ELSE
		PRINT 'cds.DF_PendingTransactionPayment_Pending_HoldbackFlag NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_PendingTransactionPayment_Pending_FinalPaymentFlag') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[PendingTransactionPayment_Pending] DROP CONSTRAINT [DF_PendingTransactionPayment_Pending_FinalPaymentFlag]
			PRINT 'cds.DF_PendingTransactionPayment_Pending_FinalPaymentFlag DROPPED'
		END
	ELSE
		PRINT 'cds.DF_PendingTransactionPayment_Pending_FinalPaymentFlag NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_PendingTransactionPayment_Pending_Created') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[PendingTransactionPayment_Pending] DROP CONSTRAINT [DF_PendingTransactionPayment_Pending_Created]
			PRINT 'cds.DF_PendingTransactionPayment_Pending_Created DROPPED'
		END
	ELSE
		PRINT 'cds.DF_PendingTransactionPayment_Pending_Created NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_PendingTransactionPayment_Pending_LastUpdate') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[PendingTransactionPayment_Pending] DROP CONSTRAINT [DF_PendingTransactionPayment_Pending_LastUpdate]
			PRINT 'cds.DF_PendingTransactionPayment_Pending_LastUpdate DROPPED'
		END
	ELSE
		PRINT 'cds.DF_PendingTransactionPayment_Pending_LastUpdate NOT DROPPED'
		
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'cds.PendingTransactionPayment_Pending') AND type in (N'U'))
		BEGIN 
			DROP TABLE [cds].[PendingTransactionPayment_Pending]
			PRINT 'TABLE cds.PendingTransactionPayment_Pending DROPPED SUCCESSFULLY'
		END	
	ELSE
		PRINT 'TABLE cds.PendingTransactionPayment_Pending DOES NOT EXIST'
		
	--PendingTransactionPayment
	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransactionPayment_Transaction') AND parent_object_id = OBJECT_ID(N'cds.PendingTransactionPayment'))
		BEGIN
			ALTER TABLE [cds].[PendingTransactionPayment] DROP CONSTRAINT [FK_PendingTransactionPayment_Transaction]
			PRINT 'cds.FK_PendingTransactionPayment_Transaction DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransactionPayment_Transaction NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_PendingTransactionPayment_HoldbackFlag') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[PendingTransactionPayment] DROP CONSTRAINT [DF_PendingTransactionPayment_HoldbackFlag]
			PRINT 'cds.DF_PendingTransactionPayment_HoldbackFlag DROPPED'
		END
	ELSE
		PRINT 'cds.DF_PendingTransactionPayment_HoldbackFlag NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_PendingTransactionPayment_FinalPaymentFlag') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[PendingTransactionPayment] DROP CONSTRAINT [DF_PendingTransactionPayment_FinalPaymentFlag]
			PRINT 'cds.DF_PendingTransactionPayment_FinalPaymentFlag DROPPED'
		END
	ELSE
		PRINT 'cds.DF_PendingTransactionPayment_FinalPaymentFlag NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_PendingTransactionPayment_Created') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[PendingTransactionPayment] DROP CONSTRAINT [DF_PendingTransactionPayment_Created]
			PRINT 'cds.DF_PendingTransactionPayment_Created DROPPED'
		END
	ELSE
		PRINT 'cds.DF_PendingTransactionPayment_Created NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_PendingTransactionPayment_LastUpdate') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[PendingTransactionPayment] DROP CONSTRAINT [DF_PendingTransactionPayment_LastUpdate]
			PRINT 'cds.DF_PendingTransactionPayment_LastUpdate DROPPED'
		END
	ELSE
		PRINT 'cds.DF_PendingTransactionPayment_LastUpdate NOT DROPPED'
		
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'cds.PendingTransactionPayment') AND type in (N'U'))
		BEGIN 
			DROP TABLE [cds].[PendingTransactionPayment]
			PRINT 'TABLE cds.PendingTransactionPayment DROPPED SUCCESSFULLY'
		END	
	ELSE
		PRINT 'TABLE cds.PendingTransactionPayment DOES NOT EXIST'

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

