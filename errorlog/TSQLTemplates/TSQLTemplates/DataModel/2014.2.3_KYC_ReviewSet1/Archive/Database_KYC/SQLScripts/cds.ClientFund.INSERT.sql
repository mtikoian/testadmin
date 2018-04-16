
USE NETIKIP
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


  /***
================================================================================
 Name        : cds.ClientFund.INSERT.sql
 Description : This script adds values for the ClientFund table
--------------------------------------------------------------------------------
 Ini    |   Date      | Description
 RJM		02/27/2014	INSERT Client and Fund relationships into ClientFund tables
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
	
	INSERT INTO [NetikIP].[cds].[ClientFund_Pending]
		([ClientId], [FundId], [Created], [CreateUser], [LastUpdate], [UpdateUser])
	SELECT '1164', [FundId], GETDATE(), 'dev', GETDATE(), 'dev' 
	FROM [NetikIP].[cds].[Fund_Pending]
	WHERE SourceSystemFundId LIKE '1164%';
	PRINT 'cds.ClientFund_Pending INSERT for 1164'
	
	INSERT INTO [NetikIP].[cds].[ClientFund_Pending]
		([ClientId], [FundId], [Created], [CreateUser], [LastUpdate], [UpdateUser])
	SELECT '9999', [FundId], [Created], [CreateUser], [LastUpdate], [UpdateUser]
	FROM [NetikIP].[cds].[Fund_Pending]
	WHERE SourceSystemFundId LIKE '9999%';
	PRINT 'cds.ClientFund_Pending INSERT for 9999'

	INSERT INTO [NetikIP].[cds].[ClientFund] (
		[ClientFundId], [ClientId], [FundId], [ActiveFlag], [Created], [CreateUser], [LastUpdate], [UpdateUser])
		SELECT [ClientFundId], [ClientId], [FundId], [ActiveFlag], [Created], [CreateUser], [LastUpdate], [UpdateUser]
		FROM [NetikIP].[cds].[ClientFund_Pending];
	PRINT 'cds.ClientFund INSERT to copy from pending table'

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

  
