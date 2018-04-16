/* 
Name:			Tables\cds.InvestorContact.Table.Alter.AddColumns.sql              
Author:			Rob McKenna    
Description:	Add FinancialAdvisorId and FinancialAdvisorAccountNumber 
				to InvestorContact and InvestorContact_Pending
History:
				20140304	Initial Version 
*/

BEGIN TRY

	IF NOT EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'InvestorContact_Pending'
		       		  AND column_name = 'FinancialAdvisorId')
		BEGIN
			ALTER TABLE cds.InvestorContact_Pending ADD
				FinancialAdvisorId varchar(15) NULL,
				FinancialAdvisorAccountNumber varchar(50) NULL;

			PRINT 'cds.InvestorContact_Pending FinancialAdvisorId, FinancialAdvisorAccountNumber added'
		END
	ELSE
		PRINT 'cds.InvestorContact_Pending FinancialAdvisorId, FinancialAdvisorAccountNumber NOT added'

	IF NOT EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'InvestorContact'
		       		  AND column_name = 'FinancialAdvisorId')
		BEGIN
			ALTER TABLE cds.InvestorContact ADD 
				FinancialAdvisorId varchar(15) NULL,
				FinancialAdvisorAccountNumber varchar(50) NULL;

			PRINT 'cds.InvestorContact FinancialAdvisorId, FinancialAdvisorAccountNumber added'
		END
	ELSE
		PRINT 'cds.InvestorContact FinancialAdvisorId, FinancialAdvisorAccountNumber NOT added'

END TRY

BEGIN CATCH
    DECLARE @errmsg NVARCHAR(2048);
    DECLARE @errsev INT;
    DECLARE @errstate INT;

    SET @errmsg = 'Error adding FinancialAdvisorId, FinancialAdvidorAccountNumber columns ' + ERROR_MESSAGE();
    SET @errsev = ERROR_SEVERITY();
    SET @errstate = ERROR_STATE();

    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

GO 

