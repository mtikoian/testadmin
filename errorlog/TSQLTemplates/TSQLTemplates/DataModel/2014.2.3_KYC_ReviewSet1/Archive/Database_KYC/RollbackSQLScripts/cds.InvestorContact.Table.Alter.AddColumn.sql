/* 
Name:			Tables\cds.InvestorContact.Table.Alter.AddColumns.sql              
Author:			Rob McKenna    
Description:	Add FinancialAdvisorId and FinancialAdvisorAccountNumber 
				to InvestorContact and InvestorContact_Pending
History:
				20140304	Initial Version 
*/

BEGIN TRY

	IF EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'InvestorContact_Pending'
		       		  AND column_name = 'FinancialAdvisorId')
		BEGIN
			ALTER TABLE cds.InvestorContact_Pending DROP COLUMN
				FinancialAdvisorId,
				FinancialAdvisorAccountNumber

			PRINT 'cds.InvestorContact_Pending FinancialAdvisorId, FinancialAdvisorAccountNumber DROPPED'
		END
	ELSE
		PRINT 'cds.InvestorContact_Pending FinancialAdvisorId, FinancialAdvisorAccountNumber NOT DROPPED'

	IF EXISTS (SELECT 1
		       FROM   information_schema.columns
		       WHERE  table_schema = 'cds'
		       		  AND table_name = 'InvestorContact'
		       		  AND column_name = 'FinancialAdvisorId')
		BEGIN
			ALTER TABLE cds.InvestorContact DROP COLUMN
				FinancialAdvisorId,
				FinancialAdvisorAccountNumber

			PRINT 'cds.InvestorContact FinancialAdvisorId, FinancialAdvisorAccountNumber DROPPED'
		END
	ELSE
		PRINT 'cds.InvestorContact FinancialAdvisorId, FinancialAdvisorAccountNumber NOT DROPPED'

END TRY

BEGIN CATCH
    DECLARE @errmsg NVARCHAR(2048);
    DECLARE @errsev INT;
    DECLARE @errstate INT;

    SET @errmsg = 'Error adding FinancialAdvisorId, FinancialAdvisorAccountNumber columns ' + ERROR_MESSAGE();
    SET @errsev = ERROR_SEVERITY();
    SET @errstate = ERROR_STATE();

    RAISERROR(@errmsg,@errsev,@errstate);

END CATCH

GO 

