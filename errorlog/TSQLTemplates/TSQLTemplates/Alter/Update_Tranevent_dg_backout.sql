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

		UPDATE TOP(@Updatebatchsize) dbo.tranevent_dg
		SET fld3_cmb_amt = fld3_cmb_amt * - 1
			,fld4_cmb_amt = fld4_cmb_amt * - 1
		WHERE trd_ex_eff_tms > '2013-01-01 00:00:00.000'
			AND rvsng_atev_id = 'back-out'
			AND (
				(
					trn_desc = 'buy'
					AND left(fld3_cmb_amt, 1) = '-'
					)
				OR (
					trn_desc = 'sell'
					AND left(fld3_cmb_amt, 1) <> '-'
					)
				)
			AND acct_id NOT IN (
				'1061%'
				,'1083%'
				,'1162%'
				,'1166%'
				,'1190%'
				,'1245%'
				,'1193%'
				,'1260%'
				,'1272%'
				,'1022%'
				,'1215%'
				,'1252%'
				,'1295%'
				,'1297%'
				,'1300%'
				,'1315%'
				,'1316%'
				,'1317%'
				,'1318%'
				);

		SET @RowCount = @@rowcount
		SET @TOTALROWS = @TOTALROWS + @RowCount

		COMMIT TRANSACTION

		PRINT 'Total records updated in batch ' + cast(@RowCount AS VARCHAR(10));

		WAITFOR DELAY '00:00:01';
	END

	PRINT 'Updated ' + CAST(@TOTALROWS AS VARCHAR) + ' total rows'
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
