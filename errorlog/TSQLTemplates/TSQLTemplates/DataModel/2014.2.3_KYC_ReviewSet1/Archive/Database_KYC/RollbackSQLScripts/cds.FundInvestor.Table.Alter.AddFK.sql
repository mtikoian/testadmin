/* 
Name:			Tables\cds.FundInvestor.Table.Alter.AddFK.sql              
Author:			Rob McKenna    
Description:	Drop FK to FundId in FundInvestor and FundInvestor_Pending
History:
				20140227	Initial Version 
*/

BEGIN TRY

	--FundInvestor_Pending to Fund_Pending
	IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_FundInvestor_Pending_Fund]') AND parent_object_id = OBJECT_ID(N'[cds].[FundInvestor_Pending]'))
		BEGIN
			ALTER TABLE [cds].[FundInvestor_Pending] DROP CONSTRAINT [FK_FundInvestor_Pending_Fund]
			PRINT 'cds.FK_FundInvestor_Pending_Fund constraint DROPPED'
		END
	ELSE
		PRINT 'cds.FK_FundInvestor_Pending_Fund constraint NOT DROPPED'

	--FundInvestor to Fund
	IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_FundInvestor_Fund]') AND parent_object_id = OBJECT_ID(N'[cds].[FundInvestor]'))
		BEGIN
			ALTER TABLE [cds].[FundInvestor] DROP CONSTRAINT [FK_FundInvestor_Fund]
			PRINT 'cds.FK_FundInvestor_Fund constraint DROPPED'
		END
	ELSE
		PRINT 'cds.FK_FundInvestor_Fund constraint NOT DROPPED'
	
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