USE NETIKIP
GO

SET XACT_ABORT ON

DECLARE @Error INTEGER
DECLARE @Updatebatchsize INT
DECLARE @Rowcount BIGINT
DECLARE @TOTALROWS INT

SET @Rowcount = 1
SET @Updatebatchsize = 5000
SET @TOTALROWS = 0

BEGIN TRY
	WHILE @Rowcount > 0
	BEGIN
		BEGIN TRANSACTION

		UPDATE TOP (@Updatebatchsize) dbo.tranevent_dg
		SET fld3_cmb_amt = fld3_cmb_amt * - 1
			,fld4_cmb_amt = fld4_cmb_amt * - 1
		--select count(*) from tranevent_dg
		WHERE trd_ex_eff_tms > '2013-01-01 00:00:00.000'
			AND rvsng_atev_id = 'back-out'
			AND (
				(
					trn_desc = 'buy'
					AND left(fld3_cmb_amt, 1) = '-'
					)
				OR (
					rvsng_atev_id = 'back-out'
					AND left(fld3_cmb_amt, 1) <> '-'
					)
				)
				and acct_id like '1061%';

 
 --IF @RowCount = 0
 --     BEGIN
 --       COMMIT TRANSACTION
        
 --       BREAK
 --     END
		
 SET @RowCount = @@rowcount
 SET @TOTALROWS = @TOTALROWS + @RowCount
		COMMIT TRANSACTION

		PRINT 'Records updated in batch ' + cast(@RowCount AS VARCHAR(10));

		WAITFOR DELAY '00:00:01';
	END
	PRINT 'Total records Updated as of now ' + CAST(@TOTALROWS as varchar) + ' total rows'

END TRY

BEGIN CATCH
	IF Xact_state() <> 0
		ROLLBACK TRANSACTION

	SET @Error = Error_number();

	SELECT Error_number() AS ErrorNumber
		,Error_message() AS ErrorMessage;

	PRINT 'ERROR:while updating records for tables dbo.TRANEVENT_DG'

	RAISERROR (
			'Error encoutered while updating records for tables dbo.TRANEVENT_DG'
			,16
			,1
			);
END CATCH
