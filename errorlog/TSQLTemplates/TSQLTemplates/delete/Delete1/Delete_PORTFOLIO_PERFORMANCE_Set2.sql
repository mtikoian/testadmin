USE smaip
GO

--File Name : Delete_PORTFOLIO_PERFORMANCE_Set2.sql
-- Deletes 40165 records 
SET XACT_ABORT ON

DECLARE @Error INTEGER
DECLARE @Deletebatchsize INT
DECLARE @Rowcount BIGINT
DECLARE @TOTALROWS INT

SET @Deletebatchsize = 10000;
SET @RowCount = 1;
SET @TOTALROWS = 0;

BEGIN TRY
	WHILE @ROWCOUNT > 0
	BEGIN
		BEGIN TRANSACTION

		DELETE TOP (@Deletebatchsize)
		FROM dbo.tes_inq
	output deleted.*
		WHERE inq_num IN (
				26,27,28,29,30,31,32,33,34,35,36,37,38,39,40
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

	SET @Error = Error_number();

	SELECT Error_number() AS ErrorNumber
		,Error_message() AS ErrorMessage;

	PRINT 'ERROR: Deleting Records'

	RAISERROR (
			'Error encoutered while deleting records from table dbo.PORTFOLIO_PERFORMANCE'
			,16
			,1
			);
END CATCH
