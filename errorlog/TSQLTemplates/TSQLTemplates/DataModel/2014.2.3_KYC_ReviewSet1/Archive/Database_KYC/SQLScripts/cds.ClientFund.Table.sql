/* 
Name: Tables\cds.ClientFund.Table.sql              
Author: Rob McKenna (rmckenna)        
Description: Know Your Client Data Services (cds) Object Modify Script  
History:   
20140203  Create tables ClientFund and ClientFund_Pending                     
*/

BEGIN TRY

	IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[cds].[ClientFund_Pending]') 
					AND type in (N'U'))
		BEGIN
			CREATE TABLE [cds].[ClientFund_Pending](
				[ClientFundId] int IDENTITY(1,1) NOT NULL,
				[ClientId] char(12) NOT NULL,
				[FundId] int NOT NULL,
				[ActiveFlag] bit NOT NULL CONSTRAINT DF_ClientFund_Pending_ActiveFlag  DEFAULT ((1)),
				[Created] datetime NOT NULL CONSTRAINT DF_ClientFund_Pending_Created  DEFAULT (getdate()),
				[CreateUser] varchar(30) NOT NULL,
				[LastUpdate] datetime NOT NULL CONSTRAINT DF_ClientFund_Pending_LastUpdate  DEFAULT (getdate()),
				[UpdateUser] varchar(30) NOT NULL,
				[BatchId] int,
				[ReferenceKey] varchar(100),
				CONSTRAINT [PK_ClientFund_Pending] PRIMARY KEY CLUSTERED
				( [ClientFundId] ASC )
					WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY];
					
			PRINT 'cds.ClientFund_Pending table created'
		END
	ELSE
		PRINT 'cds.ClientFund_Pending table NOT created'

	SET ANSI_PADDING OFF

	--Client
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_ClientFund_Pending_Client]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[ClientFund_Pending]'))
		BEGIN
			ALTER TABLE [cds].[ClientFund_Pending]  WITH CHECK ADD  CONSTRAINT FK_ClientFund_Pending_Client FOREIGN KEY([ClientId])
			REFERENCES [cds].[Client_Pending] ([ClientId]);
			
			PRINT 'cds.FK_ClientFund_Pending_Client constraint created'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Pending_Client constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_ClientFund_Pending_Client]') 
				AND parent_object_id = OBJECT_ID(N'[cds].[ClientFund_Pending]'))
		BEGIN
			ALTER TABLE [cds].[ClientFund_Pending] CHECK CONSTRAINT FK_ClientFund_Pending_Client;
			
			PRINT 'cds.FK_ClientFund_Pending_Client check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Pending_Client check constraint NOT altered'

	--Fund
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_ClientFund_Pending_Fund]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[ClientFund_Pending]'))
		BEGIN
			ALTER TABLE [cds].[ClientFund_Pending]  WITH CHECK ADD  CONSTRAINT FK_ClientFund_Pending_Fund FOREIGN KEY([FundId])
			REFERENCES [cds].[Fund_Pending] ([FundId]);
			
			PRINT 'cds.FK_ClientFund_Pending_Fund constraint created'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Pending_Fund constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_ClientFund_Pending_Fund]') 
				AND parent_object_id = OBJECT_ID(N'[cds].[ClientFund_Pending]'))
		BEGIN
			ALTER TABLE [cds].[ClientFund_Pending] CHECK CONSTRAINT FK_ClientFund_Pending_Fund;
			
			PRINT 'cds.FK_ClientFund_Pending_Fund check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Pending_Fund check constraint NOT altered'

	--IXU IXU_ClientFund_Pending_Client_Fund on ClientFund_Pending
	IF NOT EXISTS (SELECT *
			FROM sys.indexes
			WHERE name = 'IXU_ClientFund_Pending_Client_Fund'
			AND object_id = OBJECT_ID(N'[cds].[ClientFund_Pending]'))
		
		BEGIN
			CREATE UNIQUE NONCLUSTERED INDEX [IXU_ClientFund_Pending_Client_Fund] ON [cds].[ClientFund_Pending] 
			(
				[ClientId] ASC,
				[FundId] ASC
			)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

			PRINT 'cds.IXU_ClientFund_Pending_Client_Fund created'
		END
	ELSE
		PRINT 'cds.IXU_ClientFund_Pending_Client_Fund NOT created'

	--ClientFund
	IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[cds].[ClientFund]') AND type in (N'U'))
		BEGIN
			CREATE TABLE [cds].[ClientFund](
				[ClientFundId] int NOT NULL,
				[ClientId] char(12) NOT NULL,
				[FundId] int NOT NULL,
				[ActiveFlag] bit NOT NULL CONSTRAINT DF_ClientFund_ActiveFlag  DEFAULT ((1)),
				[Created] datetime NOT NULL CONSTRAINT DF_ClientFund_Created  DEFAULT (getdate()),
				[CreateUser] varchar(30) NOT NULL,
				[LastUpdate] datetime NOT NULL CONSTRAINT DF_ClientFund_LastUpdate  DEFAULT (getdate()),
				[UpdateUser] varchar(30) NOT NULL,
				[BatchId] int,
				[ReferenceKey] varchar(100),
				CONSTRAINT [PK_ClientFund] PRIMARY KEY CLUSTERED
				( [ClientFundId] ASC )
					WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY];
				
			PRINT 'cds.ClientFund table created'
		END
	ELSE
		PRINT 'cds.ClientFund table NOT created'

	SET ANSI_PADDING OFF

	--ClientFund
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_ClientFund_Client]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[ClientFund]'))
		BEGIN
			ALTER TABLE [cds].[ClientFund]  WITH CHECK ADD  CONSTRAINT FK_ClientFund_Client FOREIGN KEY([ClientId])
			REFERENCES [cds].[Client] ([ClientId]);
			
			PRINT 'cds.FK_ClientFund_Client constraint created'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Client constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_ClientFund_Client]') 
				AND parent_object_id = OBJECT_ID(N'[cds].[ClientFund]'))
		BEGIN
			ALTER TABLE [cds].[ClientFund] CHECK CONSTRAINT FK_ClientFund_Client;
			
			PRINT 'cds.FK_ClientFund_Client check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Client check constraint NOT altered'

	--Fund
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_ClientFund_Fund]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[ClientFund]'))
		BEGIN
			ALTER TABLE [cds].[ClientFund]  WITH CHECK ADD  CONSTRAINT FK_ClientFund_Fund FOREIGN KEY([FundId])
			REFERENCES [cds].[Fund] ([FundId]);
			
			PRINT 'cds.FK_ClientFund_Fund constraint created'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Fund constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_ClientFund_Fund]') 
				AND parent_object_id = OBJECT_ID(N'[cds].[ClientFund]'))
		BEGIN
			ALTER TABLE [cds].[ClientFund] CHECK CONSTRAINT FK_ClientFund_Fund;
			
			PRINT 'cds.FK_ClientFund_Fund check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_ClientFund_Fund check constraint NOT altered'

	--IXU IXU_ClientFund_Client_Fund on ClientFund
	IF NOT EXISTS (SELECT *
			FROM sys.indexes
			WHERE name = 'IXU_ClientFund_Client_Fund'
			AND object_id = OBJECT_ID(N'[cds].[ClientFund]'))
		
		BEGIN
			CREATE UNIQUE NONCLUSTERED INDEX [IXU_ClientFund_Client_Fund] ON [cds].[ClientFund] 
			(
				[ClientId] ASC,
				[FundId] ASC
			)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

			PRINT 'cds.IXU_ClientFund_Client_Fund created'
		END
	ELSE
		PRINT 'cds.IXU_ClientFund_Client_Fund NOT created'

END TRY

BEGIN CATCH
    DECLARE @errmsg NVARCHAR(2048);
    DECLARE @errsev INT;
    DECLARE @errstate INT;

    SET @errmsg = 'Error modifying ClientFund tables ' + ERROR_MESSAGE();
    SET @errsev = ERROR_SEVERITY();
    SET @errstate = ERROR_STATE();

    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

GO