USE NETIKIP  --> Change database name 
GO

SET XACT_ABORT ON

DECLARE @Error INTEGER;
DECLARE @Updatebatchsize INT;
DECLARE @Rowcount BIGINT;
DECLARE @TOTALROWS INT;

SET @Rowcount = 1;
SET @Updatebatchsize = 5000;--Increase batch size to 10k, if you are deleting more than 50k 
SET @TOTALROWS = 0;

BEGIN TRY
	WHILE (1 = 1)
	BEGIN
		BEGIN TRANSACTION

		UPDATE TOP (@Updatebatchsize) dbo.tranevent_dg
		SET col1 = ''
			,col2 = ''
		WHERE acct_id LIKE '1234-5-%'
			AND bk_id = 'FF'

		SET @RowCount = @@rowcount;
		SET @TOTALROWS = @TOTALROWS + @RowCount;

		PRINT 'Records updated in batch ' + cast(@RowCount AS VARCHAR(10));

		IF @RowCount = 0 -- terminating condition;
		BEGIN
			COMMIT TRANSACTION;

			BREAK;
		END;

		COMMIT TRANSACTION;

		WAITFOR DELAY '00:00:01';
	END;

	PRINT 'Total records Updated as of now ' + CAST(@TOTALROWS AS VARCHAR) + ' total rows';
END TRY

BEGIN CATCH
	IF Xact_state() <> 0
		ROLLBACK TRANSACTION

	SELECT ERROR_NUMBER() AS ErrorNumber
		,Error_message() AS ErrorMessage
		,ERROR_LINE() AS ErrorLine
		,ERROR_STATE() AS ErrorState
		,ERROR_SEVERITY() AS ErrorSeverity;

	PRINT 'ERROR:while updating records for tables dbo.tranevent_dg'

	RAISERROR (
			'Error encoutered while updating records for tables dbo.tranevent_dg'
			,16
			,1
			);
END CATCH
