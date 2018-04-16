USE NetikIP;-- Change Database Name
GO

/***********************************************************************************
Author			:           
Description		:	Delete records for KYC Online Dealboard report
						
FileName		:	Delete_KYC_Onbase_Duplicate_Records.sql
Scripted Date	:	04.17.2014
No of records that will be affected :
************************************************************************************/
SET XACT_ABORT ON;

DECLARE @Error INTEGER;
DECLARE @Deletebatchsize INT;
DECLARE @Rowcount BIGINT;
DECLARE @TOTALROWS INT;

SET @Deletebatchsize = 5000;--Increase batch size if records are more than 50k
SET @RowCount = 1;
SET @TOTALROWS = 0;

BEGIN TRY
	WHILE @ROWCOUNT > 0
	BEGIN
		BEGIN TRANSACTION

		DELETE TOP (@Deletebatchsize)
		FROM dbo.PORTFOLIO_PERFORMANCE
		WHERE ACCT_ID IN (
				'12345678'
				)

		SET @RowCount = @@rowcount
		SET @TOTALROWS = @TOTALROWS + @RowCount

		COMMIT TRANSACTION

		PRINT '*** Total Records Deleted in batch so far: ' + Cast(@RowCount AS VARCHAR(10));
	END

	PRINT 'Total records deleted from  dbo.PORTFOLIO_PERFORMANCE as of now ' + CAST(@TOTALROWS AS VARCHAR) + ' total rows'
END TRY

BEGIN CATCH
	IF Xact_state() <> 0
		ROLLBACK TRANSACTION

	SELECT ERROR_NUMBER() AS ErrorNumber
		,Error_message() AS ErrorMessage
		,ERROR_LINE() AS ErrorLine
		,ERROR_STATE() AS ErrorState
		,ERROR_SEVERITY() AS ErrorSeverity;

	PRINT 'ERROR: Deleting Records'

	RAISERROR (
			'Error encoutered while deleting records from table dbo.PORTFOLIO_PERFORMANCE'
			,16
			,1
			);
END CATCH
