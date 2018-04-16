/* 
Name:			Tables\cds.FundInvestor.Table.Alter.FundId.Part2.sql              
Author:			Rob McKenna    
Description:	ROLLBACK
				DROP unique index as part of conversion.
				FundInvestor.FundId will be converted from char(12) to int
History:
				20140227	Initial Version 
*/

BEGIN TRY
	--NULL out the FundId in FundInvestor
	UPDATE [cds].[FundInvestor] SET FundIdOLD = FundId;
	PRINT 'cds.FundInvestor FundIdOLD set to FundId'
	UPDATE [cds].[FundInvestor] SET FundId = NULL;
	PRINT 'cds.FundInvestor FundId set to NULL'
	
	--NULL out the FundId in FundInvestor_Pending
	UPDATE [cds].[FundInvestor_Pending] SET FundIdOLD = FundId;
	PRINT 'cds.FundInvestor_Pending FundIdOLD set to FundId'
	UPDATE [cds].[FundInvestor_Pending] SET FundId = NULL;
	PRINT 'cds.FundInvestor_Pending FundId set to NULL'

	--Change FundId to char(12) NULL on FundInvestor
	IF EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'FundInvestor'
		       		  AND column_name = 'FundIdOLD')
		BEGIN
			ALTER TABLE cds.FundInvestor ALTER COLUMN FundId char(12) NULL;

			PRINT 'cds.FundInvestor FundId changed to char(12) NULL'
		END
	ELSE
		PRINT 'cds.FundInvestor FundId NOT changed to char(12) NULL'

	--Change FundId to char(12) NULL on FundInvestor_Pending
	IF EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'FundInvestor_Pending'
		       		  AND column_name = 'FundIdOLD')
		BEGIN
			ALTER TABLE cds.FundInvestor_Pending ALTER COLUMN FundId char(12) NULL;

			PRINT 'cds.FundInvestor_Pending FundId changed to char(12) NULL'
		END
	ELSE
		PRINT 'cds.FundInvestor_Pending FundId NOT changed to char(12) NULL'

	UPDATE [cds].[FundInvestor] SET [cds].[FundInvestor].[FundId] = f.SourceSystemFundId
	FROM [cds].[FundInvestor] fi
	INNER JOIN [cds].[Fund] f ON f.FundId = fi.FundIdOLD;
	PRINT 'cds.FundInvestor set FundId to FundId from Fund'

	UPDATE [cds].[FundInvestor_Pending] SET [cds].[FundInvestor_Pending].[FundId] = f.SourceSystemFundId
	FROM [cds].[FundInvestor_Pending] fi
	INNER JOIN [cds].[Fund_Pending] f ON f.FundId = fi.FundIdOLD;
	PRINT 'cds.FundInvestor_Pending set FundId to FundId from Fund_Pending'

	--Change FundId to char(12) NOT NULL on FundInvestor
	IF EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'FundInvestor'
		       		  AND column_name = 'FundIdOLD')
		BEGIN
			ALTER TABLE cds.FundInvestor ALTER COLUMN FundId char(12) NOT NULL;

			PRINT 'cds.FundInvestor FundId changed to char(12) NOT NULL'
		END
	ELSE
		PRINT 'cds.FundInvestor FundId NOT changed to char(12) NULL'

	--Change FundId to char(12) NOT NULL on FundInvestor_Pending
	IF EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'FundInvestor_Pending'
		       		  AND column_name = 'FundIdOLD')
		BEGIN
			ALTER TABLE cds.FundInvestor_Pending ALTER COLUMN FundId char(12) NOT NULL;

			PRINT 'cds.FundInvestor_Pending FundId changed to char(12) NOT NULL'
		END
	ELSE
		PRINT 'cds.FundInvestor_Pending FundId NOT changed to char(12) NULL'

	--DROP FundIdOLD temp column from FundInvestor
	IF EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'FundInvestor'
		       		  AND column_name = 'FundIdOLD')
		BEGIN
			ALTER TABLE cds.FundInvestor DROP COLUMN FundIdOLD;
			PRINT 'cds.FundInvestor FundIdOLD column(s) dropped'
		END
	ELSE
		PRINT 'cds.FundInvestor FundIdOLD column(s) NOT dropped'

	--DROP FundIdOLD temp column from FundInvestor_Pending
	IF EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'FundInvestor_Pending'
		       		  AND column_name = 'FundIdOLD')
		BEGIN
			ALTER TABLE cds.FundInvestor_Pending DROP COLUMN FundIdOLD;
			PRINT 'cds.FundInvestor_Pending FundIdOLD column(s) dropped'
		END
	ELSE
		PRINT 'cds.FundInvestor_Pending FundIdOLD column(s) NOT dropped'

	--IXU IXU_FundInvestor_Fund_Investor on FundInvestor
	IF NOT EXISTS (SELECT *
			FROM sys.indexes
			WHERE name = 'IXU_FundInvestor_Fund_Investor'
			AND object_id = OBJECT_ID(N'[cds].[FundInvestors]'))
		
		BEGIN
			CREATE UNIQUE NONCLUSTERED INDEX [IXU_FundInvestor_Fund_Investor] ON [cds].[FundInvestor] 
			(
				[FundId] ASC,
				[InvestorId] ASC
			)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

			PRINT 'cds.IXU_FundInvestor_Fund_Investor Created'
		END
	ELSE
		PRINT 'cds.IXU_FundInvestor_Fund_Investor NOT Created'
		
	--IXU IXU_FundInvestor_Pending_Fund_Investor on FundInvestor_Pending
	IF NOT EXISTS (SELECT *
			FROM sys.indexes
			WHERE name = 'IXU_FundInvestor_Pending_Fund_Investor'
			AND object_id = OBJECT_ID(N'[cds].[ClientAddress_Pending]'))
			
		BEGIN
			CREATE UNIQUE NONCLUSTERED INDEX [IXU_FundInvestor_Pending_Fund_Investor] ON [cds].[FundInvestor_Pending] 
			(
				[FundId] ASC,
				[InvestorId] ASC
			)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

			PRINT 'cds.IXU_FundInvestor_Pending_Fund_Investor Created'
		END
	ELSE
		PRINT 'cds.IXU_FundInvestor_Pending_Fund_Investor NOT Created'

	--NIX NIX_cds_FundInvestor__WireId on FundInvestor
	IF NOT EXISTS (SELECT *
			FROM sys.indexes
			WHERE name = 'NIX_cds_FundInvestor__WireId'
			AND object_id = OBJECT_ID(N'[cds].[FundInvestor]'))
			
		BEGIN
			CREATE NONCLUSTERED INDEX [NIX_cds_FundInvestor__WireId] ON [cds].[FundInvestor] 
			(
				[WireId] ASC
			)
			INCLUDE ( [FundId],
			[InvestorId]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

			PRINT 'cds.NIX_cds_FundInvestor__WireId Created'
		END
	ELSE
		PRINT 'cds.NIX_cds_FundInvestor__WireId NOT Created'

END TRY

BEGIN CATCH
    DECLARE @errmsg NVARCHAR(2048);
    DECLARE @errsev INT;
    DECLARE @errstate INT;

    SET @errmsg = 'Error creating table ' + ERROR_MESSAGE();
    SET @errsev = ERROR_SEVERITY();
    SET @errstate = ERROR_STATE();

    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

GO