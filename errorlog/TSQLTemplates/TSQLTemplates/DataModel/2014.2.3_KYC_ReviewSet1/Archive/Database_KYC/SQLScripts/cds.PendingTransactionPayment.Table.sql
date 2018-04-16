/* 
Name: Tables\cds.PendingTransactionPayment.Table.sql              
Author: Rob McKenna (rmckenna)        
Description: Know Your Client Data Services (cds) Object Modify Script  
History:   
20140203  Create tables PendingTransactionPayment and PendingTransactionPayment_Pending                     
*/

BEGIN TRY

	IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[cds].[PendingTransactionPayment_Pending]') AND type in (N'U'))
		BEGIN
			CREATE TABLE [cds].[PendingTransactionPayment_Pending](
				[PendingTransactionPaymentId] int IDENTITY(1,1) NOT NULL,
				[PendingTransactionId] int NOT NULL,
				[PaymentAmount] numeric(15,0) NOT NULL,
				[PaymentDate] datetime NOT NULL,
				[HoldbackFlag] bit NOT NULL CONSTRAINT DF_PendingTransactionPayment_Pending_HoldbackFlag  DEFAULT ((0)),
				[FinalPaymentFlag] bit NOT NULL CONSTRAINT DF_PendingTransactionPayment_Pending_FinalPaymentFlag  DEFAULT ((0)),
				[Created] datetime NOT NULL CONSTRAINT DF_PendingTransactionPayment_Pending_Created  DEFAULT (getdate()),
				[CreateUser] varchar(30) NOT NULL,
				[LastUpdate] datetime NOT NULL CONSTRAINT DF_PendingTransactionPayment_Pending_LastUpdate  DEFAULT (getdate()),
				[UpdateUser] varchar(30) NOT NULL,
				[BatchId] int,
				[ReferenceKey] varchar(100),
				CONSTRAINT [PK_PendingTransactionPayment_Pending] PRIMARY KEY CLUSTERED
				( [PendingTransactionPaymentId] ASC )
					WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY];
					
			PRINT 'cds.PendingTransactionPayment_Pending table created'
		END
	ELSE
		PRINT 'cds.PendingTransactionPayment_Pending table NOT created'

	SET ANSI_PADDING OFF

	--Client
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransactionPayment_Pending_Transaction]') AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransactionPayment_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransactionPayment_Pending]  WITH CHECK ADD  CONSTRAINT FK_PendingTransactionPayment_Pending_Transaction FOREIGN KEY([PendingTransactionId])
			REFERENCES [cds].[PendingTransaction_Pending] ([PendingTransactionId]);
					
			PRINT 'cds.FK_PendingTransactionPayment_Pending_Transaction constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransactionPayment_Pending_Transaction constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransactionPayment_Pending_Transaction]') AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransactionPayment_Pending]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransactionPayment_Pending] CHECK CONSTRAINT FK_PendingTransactionPayment_Pending_Transaction
					
			PRINT 'cds.FK_PendingTransactionPayment_Pending_Transaction check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransactionPayment_Pending_Transaction check constraint NOT altered'
		

	IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[cds].[PendingTransactionPayment]') AND type in (N'U'))
		BEGIN
			CREATE TABLE [cds].[PendingTransactionPayment](
				[PendingTransactionPaymentId] int IDENTITY(1,1) NOT NULL,
				[PendingTransactionId] int NOT NULL,
				[PaymentAmount] numeric(15,0) NOT NULL,
				[PaymentDate] datetime NOT NULL,
				[HoldbackFlag] bit NOT NULL CONSTRAINT DF_PendingTransactionPayment_HoldbackFlag  DEFAULT ((0)),
				[FinalPaymentFlag] bit NOT NULL CONSTRAINT DF_PendingTransactionPayment_FinalPaymentFlag  DEFAULT ((0)),
				[Created] datetime NOT NULL CONSTRAINT DF_PendingTransactionPayment_Created  DEFAULT (getdate()),
				[CreateUser] varchar(30) NOT NULL,
				[LastUpdate] datetime NOT NULL CONSTRAINT DF_PendingTransactionPayment_LastUpdate  DEFAULT (getdate()),
				[UpdateUser] varchar(30) NOT NULL,
				[BatchId] int,
				[ReferenceKey] varchar(100),
				CONSTRAINT [PK_TransactionPayment] PRIMARY KEY CLUSTERED
				( [PendingTransactionPaymentId] ASC )
					WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY];
					
			PRINT 'cds.PendingTransactionPayment table created'
		END
	ELSE
		PRINT 'cds.PendingTransactionPayment table NOT created'


	SET ANSI_PADDING OFF

	--Client
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransactionPayment_Transaction]') AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransactionPayment]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransactionPayment]  WITH CHECK ADD  CONSTRAINT FK_PendingTransactionPayment_Transaction FOREIGN KEY([PendingTransactionId])
			REFERENCES [cds].[PendingTransaction] ([PendingTransactionId]);
							
			PRINT 'cds.FK_PendingTransactionPayment_Transaction constraint created'
		END
	ELSE
		PRINT 'cds.FK_PendingTransactionPayment_Transaction constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_PendingTransactionPayment_Transaction]') AND parent_object_id = OBJECT_ID(N'[cds].[PendingTransactionPayment]'))
		BEGIN
			ALTER TABLE [cds].[PendingTransactionPayment] CHECK CONSTRAINT FK_PendingTransactionPayment_Transaction;
					
			PRINT 'cds.FK_PendingTransactionPayment_Transaction check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_PendingTransactionPayment_Transaction check constraint NOT altered'

END TRY

BEGIN CATCH
    DECLARE @errmsg NVARCHAR(2048);
    DECLARE @errsev INT;
    DECLARE @errstate INT;

    SET @errmsg = 'Error modifying PendingTransactionPayment tables ' + ERROR_MESSAGE();
    SET @errsev = ERROR_SEVERITY();
    SET @errstate = ERROR_STATE();

    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

GO