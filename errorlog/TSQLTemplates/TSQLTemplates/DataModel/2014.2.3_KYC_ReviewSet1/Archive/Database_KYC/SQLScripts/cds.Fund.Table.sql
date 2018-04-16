/* 
Name: Tables\cds.Fund.Table.sql              
Author: Rob McKenna (rmckenna)        
Description: Know Your Client Data Services (cds) Object Modify Script  
History:   
20140203  Create tables Fund and Fund_Pending                     
*/

BEGIN TRY

	IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[cds].[Fund_Pending]') 
					AND type in (N'U'))
		BEGIN
			CREATE TABLE [cds].[Fund_Pending](
				[FundId] int IDENTITY(1,1) NOT NULL,
				[ClientId] char(12) NOT NULL,
				[SourceSystemFundId] varchar(20),
				[FundName] varchar(60),
				[FundDescription] varchar(255),
				[FundMnemonic] varchar(12),
				[FundTypeCode] int NOT NULL,
				[ParentFundId] int,
				[ActiveFlag] bit NOT NULL CONSTRAINT DF_Fund_Pending_ActiveFlag  DEFAULT ((1)),
				[Created] datetime NOT NULL CONSTRAINT DF_Fund_Pending_Created  DEFAULT (getdate()),
				[CreateUser] varchar(30) NOT NULL,
				[LastUpdate] datetime NOT NULL CONSTRAINT DF_Fund_Pending_LastUpdate  DEFAULT (getdate()),
				[UpdateUser] varchar(30) NOT NULL,
				[BatchId] int,
				[ReferenceKey] varchar(100),
				CONSTRAINT [PK_Fund_Pending] PRIMARY KEY CLUSTERED
				( [FundId] ASC )
					WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY];
					
			PRINT 'cds.Fund_Pending table created'
		END
	ELSE
		PRINT 'cds.Fund_Pending table NOT created'

	--ParentFundId
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_Fund_Pending_Fund]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[Fund_Pending]'))
		BEGIN
			ALTER TABLE [cds].[Fund_Pending]  WITH CHECK ADD  CONSTRAINT [FK_Fund_Pending_Fund] FOREIGN KEY([ParentFundId])
			REFERENCES [cds].[Fund_Pending] ([FundId]);
			
			PRINT 'cds.FK_Fund_Pending_Fund constraint created'
		END
	ELSE
		PRINT 'cds.FK_Fund_Pending_Fund constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_Fund_Pending_Fund]') 
				AND parent_object_id = OBJECT_ID(N'[cds].[Fund_Pending]'))
		BEGIN
			ALTER TABLE [cds].[Fund_Pending] CHECK CONSTRAINT [FK_Fund_Pending_Fund];
	
			PRINT 'cds.FK_Fund_Pending_Fund check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_Fund_Pending_Fund check constraint NOT altered'

	--FundTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_Fund_Pending_FundType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[Fund_Pending]'))
		BEGIN
			ALTER TABLE [cds].[Fund_Pending]  WITH CHECK ADD  CONSTRAINT [FK_Fund_Pending_FundType] FOREIGN KEY([FundTypeCode])
			REFERENCES [cds].[FundType] ([FundTypeCode]);
			
			PRINT 'cds.FK_Fund_Pending_FundType constraint created'
		END
	ELSE
		PRINT 'cds.FK_Fund_Pending_FundType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_Fund_Pending_FundType]') 
				AND parent_object_id = OBJECT_ID(N'[cds].[Fund_Pending]'))
		BEGIN
			ALTER TABLE [cds].[Fund_Pending] CHECK CONSTRAINT [FK_Fund_Pending_FundType];
	
			PRINT 'cds.FK_Fund_Pending_FundType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_Fund_Pending_FundType check constraint NOT altered'

	----FundName Unique
	--IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[cds].[Fund_Pending]') 
	--				AND name = N'IXU_Fund_Pending_ClientId_FundName')
	--	BEGIN
	--		CREATE UNIQUE NONCLUSTERED INDEX [IXU_Fund_Pending_ClientId_FundName] ON [cds].[Fund_Pending] 
	--		(
	--			[ClientId] ASC,
	--			[FundName] ASC
	--		);
	--		PRINT 'cds.IXU_Fund_Pending_ClientId_FundName created'
	--	END
	--ELSE
	--	PRINT 'cds.IXU_Fund_Pending_ClientId_FundName NOT created'


	IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[cds].[Fund]') AND type in (N'U'))
		BEGIN
			CREATE TABLE [cds].[Fund](
				[FundId] int NOT NULL,
				[ClientId] char(12) NOT NULL,
				[SourceSystemFundId] varchar(20),
				[FundName] varchar(60),
				[FundDescription] varchar(255),
				[FundMnemonic] varchar(12),
				[FundTypeCode] int NOT NULL,
				[ParentFundId] int,
				[ActiveFlag] bit NOT NULL CONSTRAINT DF_Fund_ActiveFlag  DEFAULT ((1)),
				[Created] datetime NOT NULL CONSTRAINT DF_Fund_Created  DEFAULT (getdate()),
				[CreateUser] varchar(30) NOT NULL,
				[LastUpdate] datetime NOT NULL CONSTRAINT DF_Fund_LastUpdate  DEFAULT (getdate()),
				[UpdateUser] varchar(30) NOT NULL,
				[BatchId] int,
				[ReferenceKey] varchar(100),
				CONSTRAINT [PK_Fund] PRIMARY KEY CLUSTERED
				( [FundId] ASC )
					WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]) ON [PRIMARY];
				
			PRINT 'cds.Fund table created'
		END
	ELSE
		PRINT 'cds.Fund table NOT created'

	--ParentFundId
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_Fund_Fund]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[Fund]'))
		BEGIN
			ALTER TABLE [cds].[Fund]  WITH CHECK ADD  CONSTRAINT [FK_Fund_Fund] FOREIGN KEY([ParentFundId])
			REFERENCES [cds].[Fund] ([FundId]);
			
			PRINT 'cds.FK_Fund_Fund constraint created'
		END
	ELSE
		PRINT 'cds.FK_Fund_Fund constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_Fund_Fund]') 
				AND parent_object_id = OBJECT_ID(N'[cds].[Fund]'))
		BEGIN
			ALTER TABLE [cds].[Fund] CHECK CONSTRAINT [FK_Fund_Fund];
	
			PRINT 'cds.FK_Fund_Fund check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_Fund_Fund check constraint NOT altered'

	--FundTypeCode
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_Fund_FundType]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[Fund]'))
		BEGIN
			ALTER TABLE [cds].[Fund]  WITH CHECK ADD  CONSTRAINT [FK_Fund_FundType] FOREIGN KEY([FundTypeCode])
			REFERENCES [cds].[FundType] ([FundTypeCode]);
			
			PRINT 'cds.FK_Fund_FundType constraint created'
		END
	ELSE
		PRINT 'cds.FK_Fund_FundType constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_Fund_FundType]') 
				AND parent_object_id = OBJECT_ID(N'[cds].[Fund]'))
		BEGIN
			ALTER TABLE [cds].[Fund] CHECK CONSTRAINT [FK_Fund_FundType];
	
			PRINT 'cds.FK_Fund_FundType check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_Fund_FundType check constraint NOT altered'


	----FundName Unique
	--IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'[cds].[Fund]') 
	--				AND name = N'IXU_Fund_ClientId_FundName')
	--	BEGIN
	--		CREATE UNIQUE NONCLUSTERED INDEX [IXU_Fund_ClientId_FundName] ON [cds].[Fund] 
	--		(
	--			[ClientId] ASC,
	--			[FundName] ASC
	--		);
	--		PRINT 'cds.IXU_Fund_ClientId_FundName created'
	--	END
	--ELSE
	--	PRINT 'cds.IXU_Fund_ClientId_FundName NOT created'

END TRY

BEGIN CATCH
    DECLARE @errmsg NVARCHAR(2048);
    DECLARE @errsev INT;
    DECLARE @errstate INT;

    SET @errmsg = 'Error modifying Fund tables ' + ERROR_MESSAGE();
    SET @errsev = ERROR_SEVERITY();
    SET @errstate = ERROR_STATE();

    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

GO