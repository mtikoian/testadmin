
USE NETIKIP
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


  /***
================================================================================
 Name        : cds.Investor.Update.ClientId.sql
 Description : This script adds values for the FundType table
--------------------------------------------------------------------------------
 Ini    |   Date      | Description
 RJM		02/27/2014	Updates ClientId in Investor and Investor_Pending

--------------------------------------------------------------------------------

***/
  SET NOCOUNT ON
  DECLARE @ROWCOUNT BIGINT;

  PRINT '***** Insert into KYC - Investor *****';
  PRINT 'SQL Start Time: ' + + convert(VARCHAR(30), getdate(), 121);
  PRINT '';

  BEGIN TRY
    BEGIN TRANSACTION;

    PRINT 'Transaction is started';
    PRINT ''
	--Update Investors related to AG
	UPDATE [cds].[Investor_Pending]
	SET [ClientId] = '1164'
	WHERE LEFT(ThirdPartyId,2) = 'AG';
	PRINT 'Investor_Pending ClientId set to 1164 for AG'

	UPDATE [cds].[Investor]
	SET [ClientId] = '1164'
	WHERE LEFT(ThirdPartyId,2) = 'AG';
	PRINT 'Investor ClientId set to 1164 for AG'

	IF NOT EXISTS(SELECT 1 FROM [cds].[Client_Pending] WHERE [ClientId] = '9999')
		BEGIN
			INSERT INTO [cds].[Client_Pending] ([ClientId],[ClientName],[Mnemonic],[Created],[CreateUser],[LastUpdate],[UpdateUser])
			VALUES ('9999','World Wide Capital','WWC',GETDATE(),'dev',GETDATE(),'dev');
			PRINT '9999 Did NOT exist but was created'
		END
	ELSE
		PRINT '9999 already existed'

	IF NOT EXISTS(SELECT 1 FROM [cds].[Client] WHERE [ClientId] = '9999')
		BEGIN
			INSERT INTO [cds].[Client] ([ClientId],[ClientName],[Mnemonic],[Created],[CreateUser],[LastUpdate],[UpdateUser])
			VALUES ('9999','World Wide Capital','WWC',GETDATE(),'dev',GETDATE(),'dev');
			PRINT '9999 Did NOT exist but was created'
		END
	ELSE
		PRINT '9999 already existed'
		
	--Update remaining Investors to WWC
	UPDATE [cds].[Investor_Pending]
	SET [ClientId] = '9999'
	WHERE [ClientId] IS NULL;
	PRINT 'Investor_Pending ClientId set to 9999 for WWC'

	UPDATE [cds].[Investor]
	SET [ClientId] = '9999'
	WHERE [ClientId] IS NULL;
	PRINT 'Investor ClientId set to 9999 for WWC'

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

  
