/* 
Name: Tables\cds.PendingTransaction.Table.sql              
Author: Rob McKenna (rmckenna)        
Description: Know Your Client Data Services (cds) Object Modify Script  
History:   
20140203  Create tables PendingTransaction and PendingTransaction_Pending                     
*/

BEGIN TRY

	IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]') 
					AND type in (N'U'))
		BEGIN
			CREATE TABLE [cds].[PendingTransaction_Pending](
				[PendingTransactionId] int IDENTITY(1,1) NOT NULL,
				[ClientId] char(12) NOT NULL,
				[FundId] int NOT NULL,
				[InvestorId] int NOT NULL,
				[TransactionTypeCode] int NOT NULL,
				[TransactionStatusTypeCode] int NOT NULL,
				[ExternalTransactionId] varchar(15),
				[AccountMaintenanceTypeCode] int,
				[TransfereeInvestorId] int,
				[TransferPackageRequiredFlag] bit,
				[SwitchInFundId] int,
				[ClientTypeCode] int,
				[TransactionAmount] numeric(15,0),
				[TransactionUnitShareAmount] numeric(15,0),
				[TransactionUnitTypeCode] int,
				[CommitmentAmount] numeric(10,0),
				[NotionalAmount] numeric(15,0),
				[CurrencyTypeCode] char(3),
				[EffectiveDate] datetime,
				[InvestmentTermTypeCode] int,
				[DocumentReceivedDate] datetime,
				[ProceedsReceivedDate] datetime,
				[ProceedsReleasedDate] datetime,
				[InterestEarned] numeric(15,0),
				[InstPCGTypeCode] int,
				[WorkflowTransactionId] varchar(15),
				[TransactionComments] varchar(250),
				[NewInvestorName] varchar(200),
				[Created] datetime NOT NULL CONSTRAINT DF_PendingTransaction_Pending_Created  DEFAULT (getdate()),
				[CreateUser] varchar(30) NOT NULL,
				[LastUpdate] datetime NOT NULL CONSTRAINT DF_PendingTransaction_Pending_LastUpdate  DEFAULT (getdate()),
				[UpdateUser] varchar(30) NOT NULL,
				[BatchId] int,
				[ReferenceKey] varchar(100),
				CONSTRAINT [PK_Transaction_Pending] PRIMARY KEY CLUSTERED
				( [PendingTransactionId] ASC )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY];

			PRINT 'cds.PendingTransaction_Pending table created'
		END
	ELSE
		PRINT 'cds.PendingTransaction_Pending table NOT created'

	SET ANSI_PADDING OFF
	
	--ClientFund
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_ClientFund]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending]
				WITH CHECK ADD CONSTRAINT [FK_PendingTransaction_Pending_ClientFund] FOREIGN KEY([ClientId],[FundId])
			REFERENCES [cds].[ClientFund_Pending] ([ClientId], [FundId]);
			
			PRINT 'cds.FK_PendingTransaction_Pending_ClientFund constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_ClientFund constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_ClientFund]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] CHECK CONSTRAINT [FK_PendingTransaction_Pending_ClientFund];

			PRINT 'cds.FK_PendingTransaction_Pending_ClientFund check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_ClientFund check constraint NOT altered'

	--FundInvestor
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_FundInvestor]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending]
				WITH CHECK ADD CONSTRAINT [FK_PendingTransaction_Pending_FundInvestor] FOREIGN KEY([FundId],[InvestorId])
			REFERENCES [cds].[FundInvestor_Pending] ([FundId],[InvestorId]);
			
			PRINT 'cds.FK_PendingTransaction_Pending_FundInvestor constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_FundInvestor constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_FundInvestor]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] CHECK CONSTRAINT [FK_PendingTransaction_Pending_FundInvestor];

			PRINT 'cds.FK_PendingTransaction_Pending_FundInvestor check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_FundInvestor check constraint NOT altered'

	--TransactionTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_TransactionType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_Pending_TransactionType] FOREIGN KEY([TransactionTypeCode])
			REFERENCES [cds].[TransactionType] ([TransactionTypeCode]);
			
			PRINT 'cds.FK_PendingTransaction_Pending_TransactionType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_TransactionType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_TransactionType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] CHECK CONSTRAINT [FK_PendingTransaction_Pending_TransactionType];
	
			PRINT 'cds.FK_PendingTransaction_Pending_TransactionType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_TransactionType cehck constraint NOT altered'

	--TransactionStatusTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_TransactionStatusType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_Pending_TransactionStatusType] FOREIGN KEY([TransactionStatusTypeCode])
			REFERENCES [cds].[TransactionStatusType] ([TransactionStatusTypeCode]);
				
			PRINT 'cds.FK_PendingTransaction_Pending_TransactionStatusType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_TransactionStatusType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_TransactionStatusType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] CHECK CONSTRAINT [FK_PendingTransaction_Pending_TransactionStatusType];
	
			PRINT 'cds.FK_PendingTransaction_Pending_TransactionStatusType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_TransactionStatusType cehck constraint NOT altered'

	--AccountMaintenanceTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_AccountMaintenanceType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_Pending_AccountMaintenanceType] FOREIGN KEY([AccountMaintenanceTypeCode])
			REFERENCES [cds].[AccountMaintenanceType] ([AccountMaintenanceTypeCode]);
				
			PRINT 'cds.FK_PendingTransaction_Pending_AccountMaintenanceType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_AccountMaintenanceType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_AccountMaintenanceType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] CHECK CONSTRAINT [FK_PendingTransaction_Pending_AccountMaintenanceType];
	
			PRINT 'cds.FK_PendingTransaction_Pending_AccountMaintenanceType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_AccountMaintenanceType cehck constraint NOT altered'

	--TransfereeInvestorId
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_TransfereeInvestor]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending]
				WITH CHECK ADD CONSTRAINT FK_PendingTransaction_Pending_TransfereeInvestor FOREIGN KEY([FundId],[TransfereeInvestorId])
			REFERENCES [cds].[FundInvestor_Pending] ([FundId],[InvestorId]);
			
			PRINT 'cds.FK_PendingTransaction_Pending_TransfereeInvestor constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_TransfereeInvestor constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_TransfereeInvestor]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] CHECK CONSTRAINT [FK_PendingTransaction_Pending_TransfereeInvestor];
					
			PRINT 'cds.FK_PendingTransaction_Pending_TransfereeInvestor check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_TransfereeInvestor check constraint NOT altered'

	--SwitchInFundId
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_SwitchInFund]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending]
				WITH CHECK ADD CONSTRAINT FK_PendingTransaction_Pending_SwitchInFund FOREIGN KEY([SwitchInFundId],[InvestorId])
			REFERENCES [cds].[FundInvestor_Pending] ([FundId],[InvestorId]);
			
			PRINT 'cds.FK_PendingTransaction_Pending_SwitchInFund constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_SwitchInFund constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_SwitchInFund]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] CHECK CONSTRAINT [FK_PendingTransaction_Pending_SwitchInFund];
					
			PRINT 'cds.FK_PendingTransaction_Pending_SwitchInFund check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_SwitchInFund check constraint NOT altered'

	--ClientTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_ClientType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_Pending_ClientType] FOREIGN KEY([ClientTypeCode])
			REFERENCES [cds].[ClientType] ([ClientTypeCode]);
				
			PRINT 'cds.FK_PendingTransaction_Pending_ClientType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_ClientType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_ClientType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] CHECK CONSTRAINT [FK_PendingTransaction_Pending_ClientType];
	
			PRINT 'cds.FK_PendingTransaction_Pending_ClientType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_ClientType cehck constraint NOT altered'

	--TransactionUnitTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_TransactionUnitType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_Pending_TransactionUnitType] FOREIGN KEY([TransactionUnitTypeCode])
			REFERENCES [cds].[TransactionUnitType] ([TransactionUnitTypeCode]);
				
			PRINT 'cds.FK_PendingTransaction_Pending_TransactionUnitType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_TransactionUnitType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_TransactionUnitType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] CHECK CONSTRAINT [FK_PendingTransaction_Pending_TransactionUnitType];
	
			PRINT 'cds.FK_PendingTransaction_Pending_TransactionUnitType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_TransactionUnitType cehck constraint NOT altered'

	--CurrencyTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_CurrencyType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_Pending_CurrencyType] FOREIGN KEY([CurrencyTypeCode])
			REFERENCES [cds].[CurrencyType] ([CurrencyTypeCode]);
				
			PRINT 'cds.FK_PendingTransaction_Pending_CurrencyType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_CurrencyType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_CurrencyType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] CHECK CONSTRAINT [FK_PendingTransaction_Pending_CurrencyType];
	
			PRINT 'cds.FK_PendingTransaction_Pending_CurrencyType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_CurrencyType cehck constraint NOT altered'

	--InvestmentTermTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_InvestmentTermType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_Pending_InvestmentTermType] FOREIGN KEY([InvestmentTermTypeCode])
			REFERENCES [cds].[InvestmentTermType] ([InvestmentTermTypeCode]);
				
			PRINT 'cds.FK_PendingTransaction_Pending_InvestmentTermType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_InvestmentTermType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_InvestmentTermType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] CHECK CONSTRAINT [FK_PendingTransaction_Pending_InvestmentTermType];
	
			PRINT 'cds.FK_PendingTransaction_Pending_InvestmentTermType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_InvestmentTermType cehck constraint NOT altered'

	--InstPCGTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_InstPCGType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_Pending_InstPCGType] FOREIGN KEY([InstPCGTypeCode])
			REFERENCES [cds].[InstPCGType] ([InstPCGTypeCode]);
				
			PRINT 'cds.FK_PendingTransaction_Pending_InstPCGType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_InstPCGType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_Pending_InstPCGType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction_Pending] CHECK CONSTRAINT [FK_PendingTransaction_Pending_InstPCGType];
	
			PRINT 'cds.FK_PendingTransaction_Pending_InvestmentTermType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_Pending_InvestmentTermType cehck constraint NOT altered'


	IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[cds].[PendingTransaction]') AND type in (N'U'))
		BEGIN
			CREATE TABLE [cds].[PendingTransaction](
				[PendingTransactionId] int IDENTITY(1,1) NOT NULL,
				[ClientId] char(12) NOT NULL,
				[FundId] int NOT NULL,
				[InvestorId] int NOT NULL,
				[TransactionTypeCode] int NOT NULL,
				[TransactionStatusTypeCode] int NOT NULL,
				[ExternalTransactionId] varchar(15),
				[AccountMaintenanceTypeCode] int,
				[TransfereeInvestorId] int,
				[TransferPackageRequiredFlag] bit,
				[SwitchInFundId] int,
				[ClientTypeCode] int,
				[TransactionAmount] numeric(15,0),
				[TransactionUnitShareAmount] numeric(15,0),
				[TransactionUnitTypeCode] int,
				[CommitmentAmount] numeric(10,0),
				[NotionalAmount] numeric(15,0),
				[CurrencyTypeCode] char(3),
				[EffectiveDate] datetime,
				[InvestmentTermTypeCode] int,
				[DocumentReceivedDate] datetime,
				[ProceedsReceivedDate] datetime,
				[ProceedsReleasedDate] datetime,
				[InterestEarned] numeric(15,0),
				[InstPCGTypeCode] int,
				[WorkflowTransactionId] varchar(15),
				[TransactionComments] varchar(250),
				[NewInvestorName] varchar(200),
				[Created] datetime NOT NULL CONSTRAINT DF_PendingTransaction_Created  DEFAULT (getdate()),
				[CreateUser] varchar(30) NOT NULL,
				[LastUpdate] datetime NOT NULL CONSTRAINT DF_PendingTransaction_LastUpdate  DEFAULT (getdate()),
				[UpdateUser] varchar(30) NOT NULL,
				[BatchId] int,
				[ReferenceKey] varchar(100),
				CONSTRAINT [PK_Transaction] PRIMARY KEY CLUSTERED
				( [PendingTransactionId] ASC )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY];

			PRINT 'cds.PendingTransaction table created'
		END
	ELSE
		PRINT 'cds.PendingTransaction table NOT created'

	SET ANSI_PADDING OFF
	
	--ClientFund
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_ClientFund]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction]
				WITH CHECK ADD CONSTRAINT [FK_PendingTransaction_ClientFund] FOREIGN KEY([ClientId],[FundId])
			REFERENCES [cds].[ClientFund] ([ClientId],[FundId]);
			
			PRINT 'cds.FK_PendingTransaction_ClientFund constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_ClientFund constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_ClientFund]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] CHECK CONSTRAINT [FK_PendingTransaction_ClientFund];

			PRINT 'cds.FK_PendingTransaction_ClientFund check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_ClientFund check constraint NOT altered'

	--FundInvestor
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_FundInvestor]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction]
				WITH CHECK ADD CONSTRAINT [FK_PendingTransaction_FundInvestor] FOREIGN KEY([FundId],[InvestorId])
			REFERENCES [cds].[FundInvestor] ([FundId],[InvestorId]);
			
			PRINT 'cds.FK_PendingTransaction_FundInvestor constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_FundInvestor constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_FundInvestor]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] CHECK CONSTRAINT [FK_PendingTransaction_FundInvestor];

			PRINT 'cds.FK_PendingTransaction_FundInvestor check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_FundInvestor check constraint NOT altered'

	--TransactionTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_TransactionType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_TransactionType] FOREIGN KEY([TransactionTypeCode])
			REFERENCES [cds].[TransactionType] ([TransactionTypeCode]);
			
			PRINT 'cds.FK_PendingTransaction_TransactionType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_TransactionType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_TransactionType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] CHECK CONSTRAINT [FK_PendingTransaction_TransactionType];
	
			PRINT 'cds.FK_PendingTransaction_TransactionType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_TransactionType cehck constraint NOT altered'

	--TransactionStatusTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_TransactionStatusType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_TransactionStatusType] FOREIGN KEY([TransactionStatusTypeCode])
			REFERENCES [cds].[TransactionStatusType] ([TransactionStatusTypeCode]);
				
			PRINT 'cds.FK_PendingTransaction_TransactionStatusType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_TransactionStatusType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_TransactionStatusType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] CHECK CONSTRAINT [FK_PendingTransaction_TransactionStatusType];
	
			PRINT 'cds.FK_PendingTransaction_TransactionStatusType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_TransactionStatusType cehck constraint NOT altered'

	--AccountMaintenanceTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_AccountMaintenanceType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_AccountMaintenanceType] FOREIGN KEY([AccountMaintenanceTypeCode])
			REFERENCES [cds].[AccountMaintenanceType] ([AccountMaintenanceTypeCode]);
				
			PRINT 'cds.FK_PendingTransaction_AccountMaintenanceType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_AccountMaintenanceType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_AccountMaintenanceType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] CHECK CONSTRAINT [FK_PendingTransaction_AccountMaintenanceType];
	
			PRINT 'cds.FK_PendingTransaction_AccountMaintenanceType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_AccountMaintenanceType cehck constraint NOT altered'

	--TransfereeInvestorId
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_TransfereeInvestor]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction]
				WITH CHECK ADD CONSTRAINT FK_PendingTransaction_TransfereeInvestor FOREIGN KEY([FundId],[TransfereeInvestorId])
			REFERENCES [cds].[FundInvestor] ([FundId],[InvestorId]);
			
			PRINT 'cds.FK_PendingTransaction_TransfereeInvestor constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_TransfereeInvestor constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_TransfereeInvestor]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] CHECK CONSTRAINT [FK_PendingTransaction_TransfereeInvestor];
					
			PRINT 'cds.FK_PendingTransaction_TransfereeInvestor check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_TransfereeInvestor check constraint NOT altered'

	--SwitchInFundId
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_SwitchInFund]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction]
				WITH CHECK ADD CONSTRAINT FK_PendingTransaction_SwitchInFund FOREIGN KEY([SwitchInFundId],[InvestorId])
			REFERENCES [cds].[FundInvestor] ([FundId],[InvestorId]);
			
			PRINT 'cds.FK_PendingTransaction_SwitchInFund constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_SwitchInFund constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_SwitchInFund]') 
				AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] CHECK CONSTRAINT [FK_PendingTransaction_SwitchInFund];
					
			PRINT 'cds.FK_PendingTransaction_SwitchInFund check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_SwitchInFund check constraint NOT altered'

	--ClientTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_ClientType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_ClientType] FOREIGN KEY([ClientTypeCode])
			REFERENCES [cds].[ClientType] ([ClientTypeCode]);
				
			PRINT 'cds.FK_PendingTransaction_ClientType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_ClientType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_ClientType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] CHECK CONSTRAINT [FK_PendingTransaction_ClientType];
	
			PRINT 'cds.FK_PendingTransaction_ClientType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_ClientType cehck constraint NOT altered'

	--TransactionUnitTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_TransactionUnitType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_TransactionUnitType] FOREIGN KEY([TransactionUnitTypeCode])
			REFERENCES [cds].[TransactionUnitType] ([TransactionUnitTypeCode]);
				
			PRINT 'cds.FK_PendingTransaction_TransactionUnitType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_TransactionUnitType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_TransactionUnitType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] CHECK CONSTRAINT [FK_PendingTransaction_TransactionUnitType];
	
			PRINT 'cds.FK_PendingTransaction_TransactionUnitType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_TransactionUnitType cehck constraint NOT altered'

	--CurrencyTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_CurrencyType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_CurrencyType] FOREIGN KEY([CurrencyTypeCode])
			REFERENCES [cds].[CurrencyType] ([CurrencyTypeCode]);
				
			PRINT 'cds.FK_PendingTransaction_CurrencyType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_CurrencyType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_CurrencyType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] CHECK CONSTRAINT [FK_PendingTransaction_CurrencyType];
	
			PRINT 'cds.FK_PendingTransaction_CurrencyType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_CurrencyType cehck constraint NOT altered'

	--InvestmentTermTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_InvestmentTermType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_InvestmentTermType] FOREIGN KEY([InvestmentTermTypeCode])
			REFERENCES [cds].[InvestmentTermType] ([InvestmentTermTypeCode]);
				
			PRINT 'cds.FK_PendingTransaction_InvestmentTermType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_InvestmentTermType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_InvestmentTermType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] CHECK CONSTRAINT [FK_PendingTransaction_InvestmentTermType];
	
			PRINT 'cds.FK_PendingTransaction_InvestmentTermType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_InvestmentTermType cehck constraint NOT altered'

	--InstPCGTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_InstPCGType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction]  WITH CHECK ADD  CONSTRAINT [FK_PendingTransaction_InstPCGType] FOREIGN KEY([InstPCGTypeCode])
			REFERENCES [cds].[InstPCGType] ([InstPCGTypeCode]);
				
			PRINT 'cds.FK_PendingTransaction_InstPCGType constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_InstPCGType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransaction_InstPCGType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransaction]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransaction] CHECK CONSTRAINT [FK_PendingTransaction_InstPCGType];
	
			PRINT 'cds.FK_PendingTransaction_InvestmentTermType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransaction_InvestmentTermType cehck constraint NOT altered'

END TRY

BEGIN CATCH
    DECLARE @errmsg NVARCHAR(2048);
    DECLARE @errsev INT;
    DECLARE @errstate INT;

    SET @errmsg = 'Error modifying Transaction tables ' + ERROR_MESSAGE();
    SET @errsev = ERROR_SEVERITY();
    SET @errstate = ERROR_STATE();

    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

GO 
