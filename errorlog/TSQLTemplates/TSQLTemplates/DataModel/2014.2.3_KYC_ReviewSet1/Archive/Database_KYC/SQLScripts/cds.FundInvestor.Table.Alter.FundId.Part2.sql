/* 
Name:			Tables\cds.FundInvestor.Table.Alter.FundId.Part2.sql              
Author:			Rob McKenna    
Description:	DROP unique index as part of conversion.
				FundInvestor.FundId will be converted from char(12) to int
				All relational data will be converted to the new model
History:
				20140227	Initial Version 
*/

BEGIN TRY

	--NULL out the FundId in FundInvestor
	UPDATE [cds].[FundInvestor] SET FundIdOLD = FundId;
	UPDATE [cds].[FundInvestor] SET FundId = NULL;
	PRINT 'cds.FundInvetor FundId set to NULL'
	
	--NULL out the FundId in FundInvestor_Pending
	UPDATE [cds].[FundInvestor_Pending] SET FundIdOLD = FundId;
	UPDATE [cds].[FundInvestor_Pending] SET FundId = NULL;
	PRINT 'cds.FundInvetor_Pending FundId set to NULL'

	--Change FundId to int NULL on FundInvestor
	IF EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'FundInvestor'
		       		  AND column_name = 'FundIdOLD')
		BEGIN
			ALTER TABLE cds.FundInvestor ALTER COLUMN FundId int NULL;

			PRINT 'cds.FundInvestor FundId altered'
		END
	ELSE
		PRINT 'cds.FundInvestor FundId NOT altered'

	--Change FundId to int NULL on FundInvestor_Pending
	IF EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'FundInvestor_Pending'
		       		  AND column_name = 'FundIdOLD')
		BEGIN
			ALTER TABLE cds.FundInvestor_Pending ALTER COLUMN FundId int NULL;

			PRINT 'cds.FundInvestor_Pending FundId altered'
		END
	ELSE
		PRINT 'cds.FundInvestor_Pending FundId NOT altered'

	UPDATE [cds].[FundInvestor_Pending] SET [cds].[FundInvestor_Pending].[FundId] = f.FundId
	FROM [cds].[FundInvestor_Pending] fi
	INNER JOIN [cds].[Fund_Pending] f ON f.SourceSystemFundId = fi.FundIdOLD;
	PRINT 'cds.FundInvestor_Pending set FundId to FundId from Fund_Pending'
			
	UPDATE [cds].[FundInvestor] SET [cds].[FundInvestor].[FundId] = f.FundId
	FROM [cds].[FundInvestor] fi
	INNER JOIN [cds].[Fund] f ON f.SourceSystemFundId = fi.FundIdOLD;
	PRINT 'cds.FundInvestor set FundId to FundId from Fund'

	--Change FundId to int NOT NULL on FundInvestor
	IF EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'FundInvestor'
		       		  AND column_name = 'FundIdOLD')
		BEGIN
			ALTER TABLE cds.FundInvestor ALTER COLUMN FundId int NOT NULL;

			PRINT 'cds.FundInvestor FundId int NOT NULL SUCCESS'
		END
	ELSE
		PRINT 'cds.FundInvestor FundId int NOT NULL FAILED'

	--Change FundId to int NOT NULL on FundInvestor_Pending
	IF EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'FundInvestor_Pending'
		       		  AND column_name = 'FundIdOLD')
		BEGIN
			ALTER TABLE cds.FundInvestor_Pending ALTER COLUMN FundId int NOT NULL;

			PRINT 'cds.FundInvestor_Pending FundId int NOT NULL SUCCESS'
		END
	ELSE
		PRINT 'cds.FundInvestor_Pending FundId int NOT NULL FAILED'

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
	IF NOT EXISTS (SELECT 1
			FROM sys.indexes
			WHERE name = 'IXU_FundInvestor_Fund_Investor'
			AND object_id = OBJECT_ID(N'[cds].[FundInvestor]'))
		
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
	IF NOT EXISTS (SELECT 1
			FROM sys.indexes
			WHERE name = 'IXU_FundInvestor_Pending_Fund_Investor'
			AND object_id = OBJECT_ID(N'[cds].[FundInvestor_Pending]'))
			
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
	IF NOT EXISTS (SELECT 1
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