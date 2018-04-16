
USE NETIKIP
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


  /***
================================================================================
 Name        : cds.TransactionType.INSERT.sql
 Description : This script adds values for the FundType table
--------------------------------------------------------------------------------
 Ini    |   Date      | Description
 RJM		02/27/2014	Truncate existing Transaction Type as values are no longer valid.
						(Existing table is not used yet.)
						INSERT Transaction Types into TransactionType table

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

		IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_Pending_TransactionType') 
					AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction_Pending'))
			BEGIN
				ALTER TABLE [cds].[PendingTransaction_Pending] DROP CONSTRAINT [FK_PendingTransaction_Pending_TransactionType]
				PRINT 'cds.FK_PendingTransaction_Pending_TransactionType DROPPED'
			END
		ELSE
			PRINT 'cds.FK_PendingTransaction_Pending_TransactionType NOT DROPPED'

		IF  EXISTS (SELECT 1 FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'cds.FK_PendingTransaction_TransactionType') 
					AND parent_object_id = OBJECT_ID(N'cds.PendingTransaction'))
			BEGIN
				ALTER TABLE [cds].[PendingTransaction] DROP CONSTRAINT [FK_PendingTransaction_TransactionType]
				PRINT 'cds.FK_PendingTransaction_TransactionType DROPPED'
			END
		ELSE
			PRINT 'cds.FK_PendingTransaction_TransactionType NOT DROPPED'

		-------------------------------------------------
		--TRUNCTATE TransactionType Table
		TRUNCATE TABLE [NetikIP].[cds].[TransactionType];
		PRINT 'cds.TransactionType TRUNCATED'
		-------------------------------------------------

		INSERT INTO [NetikIP].[cds].[TransactionType]
				   ([TransactionTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (1
				   ,'New Subscription'
				   ,1
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionType]
				   ([TransactionTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (2
				   ,'Additional Subscription'
				   ,2
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionType]
				   ([TransactionTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (3
				   ,'Partial Redemption'
				   ,3
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionType]
				   ([TransactionTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (4
				   ,'Full Redemption'
				   ,4
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionType]
				   ([TransactionTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (5
				   ,'Partial Transfer'
				   ,5
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionType]
				   ([TransactionTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (6
				   ,'Full Transfer'
				   ,6
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionType]
				   ([TransactionTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (7
				   ,'Partial Switch'
				   ,7
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionType]
				   ([TransactionTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (8
				   ,'Full Switch'
				   ,8
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionType]
				   ([TransactionTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (9
				   ,'Rebate'
				   ,9
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionType]
				   ([TransactionTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (10
				   ,'Equalization'
				   ,10
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionType]
				   ([TransactionTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (11
				   ,'New Commitment'
				   ,11
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionType]
				   ([TransactionTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (12
				   ,'Capital Call'
				   ,12
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionType]
				   ([TransactionTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (13
				   ,'Distribution'
				   ,13
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');

		INSERT INTO [NetikIP].[cds].[TransactionType]
				   ([TransactionTypeCode]
				   ,[Value]
				   ,[SortOrder]
				   ,[Created]
				   ,[CreateUser]
				   ,[LastUpdate]
				   ,[UpdateUser])
			 VALUES
				   (14
				   ,'Account Maintenance'
				   ,14
				   ,GETDATE()
				   ,'dev'
				   ,GETDATE()
				   ,'dev');
	PRINT 'TransactionType table INSERTs complete.'

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

  
