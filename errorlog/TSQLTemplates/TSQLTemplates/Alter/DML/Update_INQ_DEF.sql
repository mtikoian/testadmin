USE NetikIP
GO

/*
To update record in INQ_DEF table
*/
SET NOCOUNT ON

DECLARE @Error INTEGER;
DECLARE @Rowcount BIGINT;

SET @Rowcount = 0;

BEGIN TRY
	BEGIN TRANSACTION

	UPDATE dbo.INQ_DEF
	SET HDR_PROC_NME = 'p_PositionVal_HdrInfo_Select_P2P'
	WHERE INQ_NME = 'Select Period Performance'
		AND HDR_PROC_NME = 'sp_PositionVal_HdrInfo_Select'

	SET @Rowcount = @@rowcount

	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION;
	END

	PRINT REPLICATE('*', 60)
	PRINT 'Total Records updated = ' + cast(@RowCount AS VARCHAR(10));
	PRINT REPLICATE('*', 60)
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0 or Xact_state() <> 0
		ROLLBACK TRANSACTION;

	SET @Error = ERROR_NUMBER();

	RAISERROR (
			'Error during Update'
			,16
			,1
			);

	SELECT ERROR_NUMBER() AS ErrorNumber
		,ERROR_MESSAGE() AS ErrorMessage;
END CATCH
