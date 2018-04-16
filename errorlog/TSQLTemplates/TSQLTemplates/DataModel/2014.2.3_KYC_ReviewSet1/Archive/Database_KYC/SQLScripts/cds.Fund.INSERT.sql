
USE NETIKIP
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


  /***
================================================================================
 Name        : cds.FundType.INSERT.sql
 Description : This script adds values for the FundType table
--------------------------------------------------------------------------------
 Ini    |   Date      | Description
 RJM		02/27/2014	INSERT Fund Types into FundType table

--------------------------------------------------------------------------------

***/
  SET NOCOUNT ON
  DECLARE @ROWCOUNT BIGINT;

  PRINT '***** Insert into KYC - Fund *****';
  PRINT 'SQL Start Time: ' + + convert(VARCHAR(30), getdate(), 121);
  PRINT '';

  BEGIN TRY
    BEGIN TRANSACTION;

    PRINT 'Transaction is started';
    PRINT ''
	
	IF NOT EXISTS (SELECT 1 FROM [NetikIP].[cds].[Fund_Pending])
		BEGIN
		
			INSERT INTO [NetikIP].[cds].[Fund_Pending]
				([SourceSystemFundId], [ClientId], [FundName], [FundDescription], [FundMnemonic], [FundTypeCode], 
					[Created], [CreateUser], [LastUpdate], [UpdateUser])
			SELECT DISTINCT [ACCT_ID], [CUST_ID], [ACCT_NME], [ACCT_DESC], [NAME_SORT_KEY_TXT], 1, 
				GETDATE(), 'dev', GETDATE(), 'dev'
			FROM [NetikIP].[dbo].[IVW_ACCT] ia
				INNER JOIN [NetikIP].[cds].[FundInvestor_Pending] fip
					ON ia.ACCT_ID = fip.FundId;
			PRINT 'cds.Fund_Pending populated with data corresponding to FundInvestor_Pending'

			INSERT INTO [NetikIP].[cds].[Fund] (
				[FundId], [ClientId], [SourceSystemFundId], [FundName], [FundDescription], [FundMnemonic], [FundTypeCode], 
					[ActiveFlag], [Created], [CreateUser], [LastUpdate], [UpdateUser])
				SELECT [FundId], [ClientId], [SourceSystemFundId], [FundName], [FundDescription], [FundMnemonic], [FundTypeCode], 
					[ActiveFlag], [Created], [CreateUser], [LastUpdate], [UpdateUser]
				FROM [NetikIP].[cds].[Fund_Pending];
			PRINT 'cds.Fund populated with data from Fund_Investor'
		END
	ELSE
		PRINT 'Fund records already existed.'
		
	SET @ROWCOUNT = @@ROWCOUNT
    COMMIT TRANSACTION;

    PRINT 'Insert = '+ cast(@RowCount AS VARCHAR(10));
    PRINT 'Transaction is committed'  ;
    PRINT '';
  END TRY

  BEGIN CATCH
    IF @@trancount > 0
    BEGIN
      ROLLBACK TRANSACTION;

      PRINT 'Transaction is rolled back';
    END

    DECLARE @errmsg NVARCHAR(2100)
      ,@errsev INT
      ,@errstate INT;

  
    SET @errmsg = 'Error in updating data : ' + Error_message()
    SET @errsev = Error_severity()
    SET @errstate = Error_state()

    RAISERROR (
        @errmsg
        ,@errsev
        ,@errstate
        );
  END CATCH

  
