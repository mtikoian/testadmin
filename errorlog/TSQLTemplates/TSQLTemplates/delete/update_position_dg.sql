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

		UPDATE TOP (@Updatebatchsize) dbo.Position_dg
		SET ADJST_TMS  =  at.END_ADJUST_TMS
		FROM Position_dg DG
		INNER JOIN dbo.acct_totals at 
		ON  DG.ACCT_ID = AT.ACCT_ID
		   AND at.BK_ID = dg.BK_ID
		   AND at.ORG_ID = dg.ORG_ID
		   AND at.END_TMS = dg.AS_OF_TMS
		   AND at.INQ_BASIS_NUM = dg.INQ_BASIS_NUM
		WHERE at.end_tms = '2013-12-31 23:59:59.000'
		AND DG.INQ_BASIS_NUM = 5
		AND DG.ACCT_ID LIKE '1260-3-%'
		AND ADJST_TMS  <> at.END_ADJUST_TMS
		
 SET @RowCount = @@rowcount
 COMMIT TRANSACTION
 if @@rowcount = 0 
 break;
 SET @TOTALROWS = @TOTALROWS + @RowCount
		--COMMIT TRANSACTION

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

	PRINT 'ERROR:while updating records for tables dbo.Position_dg'

	RAISERROR (
			'Error encoutered while updating records for tables dbo.Position_dg'
			,16
			,1
			);
END CATCH
