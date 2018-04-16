/* 
Name:			Tables\cds.FundInvestor.Table.Alter.FundId.Part1.sql              
Author:			Rob McKenna    
Description:	DROP unique index as part of conversion.
				FundInvestor.FundId will be converted from char(12) to int
History:
				20140227	Initial Version 
*/

BEGIN TRY

	--NIX NIX_cds_FundInvestor__WireId on FundInvestor
	IF EXISTS (SELECT *
			FROM sys.indexes
			WHERE name = 'NIX_cds_FundInvestor__WireId'
			AND object_id = OBJECT_ID(N'[cds].[FundInvestor]'))
			
		BEGIN
			DROP INDEX [NIX_cds_FundInvestor__WireId] ON [cds].[FundInvestor]
			PRINT 'cds.NIX_cds_FundInvestor__WireId DROPPED'
		END
	ELSE
		PRINT 'cds.NIX_cds_FundInvestor__WireId NOT DROPPED'

	--IXU IXU_FundInvestor_Fund_Investor on FundInvestor
	IF EXISTS (SELECT *
			FROM sys.indexes
			WHERE name = 'IXU_FundInvestor_Fund_Investor'
			AND object_id = OBJECT_ID(N'[cds].[FundInvestor]'))
		
		BEGIN
			DROP INDEX [cds].[FundInvestor].[IXU_FundInvestor_Fund_Investor]

			PRINT 'cds.IXU_FundInvestor_Fund_Investor DROPPED'
		END
	ELSE
		PRINT 'cds.IXU_FundInvestor_Fund_Investor NOT DROPPED'
		
	--IXU IXU_FundInvestor_Pending_Fund_Investor on FundInvestor_Pending
	IF EXISTS (SELECT *
			FROM sys.indexes
			WHERE name = 'IXU_FundInvestor_Pending_Fund_Investor'
			AND object_id = OBJECT_ID(N'[cds].[FundInvestor_Pending]'))
			
		BEGIN
			DROP INDEX [cds].[FundInvestor_Pending].[IXU_FundInvestor_Pending_Fund_Investor]

			PRINT 'cds.IXU_FundInvestor_Pending_Fund_Investor DROPPED'
		END
	ELSE
		PRINT 'cds.IXU_FundInvestor_Pending_Fund_Investor NOT DROPPED'

	--Add FundIdOLD temp column to FundInvestor
	IF NOT EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'FundInvestor'
		       		  AND column_name = 'FundIdOLD')
		BEGIN
			ALTER TABLE cds.FundInvestor ADD FundIdOLD char(12) NULL;
			ALTER TABLE cds.FundInvestor ALTER COLUMN FundId char(12) NULL;

			PRINT 'cds.FundInvestor FundIdOLD added'
		END
	ELSE
		PRINT 'cds.FundInvestor FundIdOLD NOT added'

	--Add FundIdOLD temp column to FundInvestor_Pending
	IF NOT EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'FundInvestor_Pending'
		       		  AND column_name = 'FundIdOLD')
		BEGIN
			ALTER TABLE cds.FundInvestor_Pending ADD FundIdOLD char(12) NULL;
			ALTER TABLE cds.FundInvestor_Pending ALTER COLUMN FundId char(12) NULL;

			PRINT 'cds.FundInvestor_Pending FundIdOLD added'
		END
	ELSE
		PRINT 'cds.FundInvestor_Pending FundIdOLD NOT added'

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