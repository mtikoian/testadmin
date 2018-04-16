
USE NETIKIP
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


  /***
================================================================================
 Name        : cds.TransactionStatusType.INSERT.sql
 Description : This script adds values for the FundType table
--------------------------------------------------------------------------------
 Ini    |   Date      | Description
 RJM		02/27/2014	INSERT Transaction Status Types into TransactionStatusType table

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

		INSERT INTO [NetikIP].[cds].[TransactionStatusType]
				   ([TransactionStatusTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (1
				   ,'Active'
				   ,1
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionStatusType]
				   ([TransactionStatusTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (2
				   ,'Cancel'
				   ,2
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionStatusType]
				   ([TransactionStatusTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (3
				   ,'Delete'
				   ,3
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

	PRINT 'TransactionStatusType table INSERTs complete.'

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

  
