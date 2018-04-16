/* 
Name:			Tables\cds.FundInvestor.Table.Alter.AddFK.sql              
Author:			Rob McKenna    
Description:	Add FK to FundId in FundInvestor and FundInvestor_Pending
History:
				20140227	Initial Version 
*/

BEGIN TRY

	--FundInvestor_Pending to Fund_Pending
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_FundInvestor_Pending_Fund]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[FundInvestor_Pending]'))
		BEGIN
			ALTER TABLE [cds].[FundInvestor_Pending]  WITH CHECK ADD  CONSTRAINT [FK_FundInvestor_Pending_Fund] FOREIGN KEY([FundId])
			REFERENCES [cds].[Fund_Pending] ([FundId]);
			
			PRINT 'cds.FK_FundInvestor_Pending_Fund constraint created'
		END
	ELSE
		PRINT 'cds.FK_FundInvestor_Pending_Fund constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_FundInvestor_Pending_Fund]') 
				AND parent_object_id = OBJECT_ID(N'[cds].[FundInvestor_Pending]'))
		BEGIN
			ALTER TABLE [cds].[FundInvestor_Pending] CHECK CONSTRAINT [FK_FundInvestor_Pending_Fund];

			PRINT 'cds.FK_FundInvestor_Pending_Fund check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_FundInvestor_Pending_Fund check constraint NOT altered'


	--FundInvestor to Fund
	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_FundInvestor_Fund]') 
					AND parent_object_id = OBJECT_ID(N'[cds].[FundInvestor]'))
		BEGIN
			ALTER TABLE [cds].[FundInvestor]  WITH CHECK ADD  CONSTRAINT [FK_FundInvestor_Fund] FOREIGN KEY([FundId])
			REFERENCES [cds].[Fund] ([FundId]);
			
			PRINT 'cds.FK_FundInvestor_Fund constraint created'
		END
	ELSE
		PRINT 'cds.FK_FundInvestor_Fund constraint NOT created'

	IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[cds].[FK_FundInvestor_Fund]') 
				AND parent_object_id = OBJECT_ID(N'[cds].[FundInvestor]'))
		BEGIN
			ALTER TABLE [cds].[FundInvestor] CHECK CONSTRAINT [FK_FundInvestor_Fund];

			PRINT 'cds.FK_FundInvestor_Fund check constraint altered'
		END
	ELSE
		PRINT 'cds.FK_FundInvestor_Fund check constraint NOT altered'


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