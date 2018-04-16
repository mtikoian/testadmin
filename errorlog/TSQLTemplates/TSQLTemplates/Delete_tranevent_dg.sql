USE NetikIP
GO

--File Name : Delete_tranevent_dg.sql
-- Deletes 70438 records 
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
DELETE
	FROM dbo.tranevent_dg
	WHERE fld4_tms = '2014-01-31 23:59:59.000'
		AND inq_basis_num = 5
		AND trn_desc <> 'Dividend'
		AND (
			acct_id LIKE '1317%'
			OR acct_id LIKE '1318%'
			)

		SET @RowCount = @@rowcount
		SET @TOTALROWS = @TOTALROWS + @RowCount

		COMMIT TRANSACTION

		PRINT '*** Total Records Deleted in batch so far: ' + Cast(@RowCount AS VARCHAR(10));
	END

	PRINT 'Total records deleted from  dbo.tranevent_dg as of now ' + CAST(@TOTALROWS AS VARCHAR) + ' total rows'
END TRY

BEGIN CATCH
	IF Xact_state() <> 0
		ROLLBACK TRANSACTION

	SET @Error = Error_number();

	SELECT Error_number() AS ErrorNumber
		,Error_message() AS ErrorMessage;

	PRINT 'ERROR: Deleting Records'

	RAISERROR (
			'Error encoutered while deleting records from table dbo.tranevent_dg'
			,16
			,1
			);
END CATCH
