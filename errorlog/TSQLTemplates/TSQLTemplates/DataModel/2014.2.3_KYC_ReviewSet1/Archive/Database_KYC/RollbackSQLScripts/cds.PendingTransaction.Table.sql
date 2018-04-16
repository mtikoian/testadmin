/* 
Name:			Tables\cds.PendingTransaction.Table.sql              
Author:			Rob McKenna    
Description:	Rollback to DROP the PendingTransactiont and PendingTransaction_Pending tables
History:
				20140227	Initial Version 
*/

BEGIN TRY
	--PendingTransaction_Pending
	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_Pending_AccountMaintenanceType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction_Pending'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [FK_PendingTransaction_Pending_AccountMaintenanceType]
			PRINT 'cds.FK_PendingTransaction_Pending_AccountMaintenanceType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_AccountMaintenanceType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_Pending_ClientFund') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction_Pending'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [FK_PendingTransaction_Pending_ClientFund]
			PRINT 'cds.FK_PendingTransaction_Pending_ClientFund DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_ClientFund NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_Pending_ClientType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction_Pending'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [FK_PendingTransaction_Pending_ClientType]
			PRINT 'cds.FK_PendingTransaction_Pending_ClientType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_ClientType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_Pending_CurrencyType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction_Pending'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [FK_PendingTransaction_Pending_CurrencyType]
			PRINT 'cds.FK_PendingTransaction_Pending_CurrencyType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_CurrencyType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_Pending_FundInvestor') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction_Pending'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [FK_PendingTransaction_Pending_FundInvestor]
			PRINT 'cds.FK_PendingTransaction_Pending_FundInvestor DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_FundInvestor NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_Pending_InstPCGType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction_Pending'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [FK_PendingTransaction_Pending_InstPCGType]
			PRINT 'cds.FK_PendingTransaction_Pending_InstPCGType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_InstPCGType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_Pending_InvestmentTermType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction_Pending'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [FK_PendingTransaction_Pending_InvestmentTermType]
			PRINT 'cds.FK_PendingTransaction_Pending_InvestmentTermType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_InvestmentTermType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_Pending_SwitchInFundInvestor') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction_Pending'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [FK_PendingTransaction_Pending_SwitchInFundInvestor]
			PRINT 'cds.FK_PendingTransaction_Pending_SwitchInFundInvestor DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_SwitchInFundInvestor NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_Pending_TransactionStatusType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction_Pending'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [FK_PendingTransaction_Pending_TransactionStatusType]
			PRINT 'cds.FK_PendingTransaction_Pending_TransactionStatusType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_TransactionStatusType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_Pending_TransactionType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction_Pending'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [FK_PendingTransaction_Pending_TransactionType]
			PRINT 'cds.FK_PendingTransaction_Pending_TransactionType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_TransactionType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_Pending_TransactionUnitType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction_Pending'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [FK_PendingTransaction_Pending_TransactionUnitType]
			PRINT 'cds.FK_PendingTransaction_Pending_TransactionUnitType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_TransactionUnitType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_Pending_TransfereeFundInvestor') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction_Pending'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [FK_PendingTransaction_Pending_TransfereeFundInvestor]
			PRINT 'cds.FK_PendingTransaction_Pending_TransfereeFundInvestor DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_TransfereeFundInvestor NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_Pending_ClientFund') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction_Pending'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [FK_PendingTransaction_Pending_ClientFund]
			PRINT 'cds.FK_PendingTransaction_Pending_ClientFund DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_ClientFund NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_PendingTransaction_Pending_Created') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [DF_PendingTransaction_Pending_Created]
			PRINT 'cds.DF_PendingTransaction_Pending_Created DROPPED'
		END
	ELSE
		PRINT 'cds.DF_PendingTransaction_Pending_Created NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_PendingTransaction_Pending_LastUpdate') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [DF_PendingTransaction_Pending_LastUpdate]
			PRINT 'cds.DF_PendingTransaction_Pending_LastUpdate DROPPED'
		END
	ELSE
		PRINT 'cds.DF_PendingTransaction_Pending_LastUpdate NOT DROPPED'
		
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'cds.PendingTransaction_Pending') AND type in (N'U'))
		BEGIN 
			DROP TABLE [cds].[PendingTransaction_Pending]
			PRINT 'TABLE cds.PendingTransaction_Pending DROPPED SUCCESSFULLY'
		END	
	ELSE
		PRINT 'TABLE cds.PendingTransaction_Pending DOES NOT EXIST'


	--PendingTransaction
	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_AccountMaintenanceType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [FK_PendingTransaction_AccountMaintenanceType]
			PRINT 'cds.FK_PendingTransaction_AccountMaintenanceType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_AccountMaintenanceType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_ClientFund') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [FK_PendingTransaction_ClientFund]
			PRINT 'cds.FK_PendingTransaction_ClientFund DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_ClientFund NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_ClientType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [FK_PendingTransaction_ClientType]
			PRINT 'cds.FK_PendingTransaction_ClientType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_ClientType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_CurrencyType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [FK_PendingTransaction_CurrencyType]
			PRINT 'cds.FK_PendingTransaction_CurrencyType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_CurrencyType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_FundInvestor') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [FK_PendingTransaction_FundInvestor]
			PRINT 'cds.FK_PendingTransaction_FundInvestor DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_FundInvestor NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_InstPCGType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [FK_PendingTransaction_InstPCGType]
			PRINT 'cds.FK_PendingTransaction_InstPCGType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_InstPCGType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_InvestmentTermType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [FK_PendingTransaction_InvestmentTermType]
			PRINT 'cds.FK_PendingTransaction_InvestmentTermType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_InvestmentTermType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_SwitchInFundInvestor') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [FK_PendingTransaction_SwitchInFundInvestor]
			PRINT 'cds.FK_PendingTransaction_SwitchInFundInvestor DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_SwitchInFundInvestor NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_TransactionStatusType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [FK_PendingTransaction_TransactionStatusType]
			PRINT 'cds.FK_PendingTransaction_TransactionStatusType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_TransactionStatusType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_TransactionType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [FK_PendingTransaction_TransactionType]
			PRINT 'cds.FK_PendingTransaction_TransactionType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_TransactionType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_TransactionUnitType') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [FK_PendingTransaction_TransactionUnitType]
			PRINT 'cds.FK_PendingTransaction_TransactionUnitType DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_TransactionUnitType NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_TransfereeFundInvestor') 
				AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [FK_PendingTransaction_TransfereeFundInvestor]
			PRINT 'cds.FK_PendingTransaction_TransfereeFundInvestor DROPPED'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_TransfereeFundInvestor NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_PendingTransaction_Create') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [DF_PendingTransaction_Created]
			PRINT 'cds.DF_PendingTransaction_Created DROPPED'
		END
	ELSE
		PRINT 'cds.DF_PendingTransaction_Created NOT DROPPED'

	IF  EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'cds.DF_PendingTransaction_LastUpdate') AND type = 'D')
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [DF_PendingTransaction_LastUpdate]
			PRINT 'cds.DF_PendingTransaction_LastUpdate DROPPED'
		END
	ELSE
		PRINT 'cds.DF_PendingTransaction_LastUpdate NOT DROPPED'
		
	IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'cds.PendingTransaction') AND type in (N'U'))
		BEGIN 
			DROP TABLE [cds].[PendingTransaction]
			PRINT 'TABLE cds.PendingTransaction DROPPED SUCCESSFULLY'
		END	
	ELSE
		PRINT 'TABLE cds.PendingTransaction DOES NOT EXIST'

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

