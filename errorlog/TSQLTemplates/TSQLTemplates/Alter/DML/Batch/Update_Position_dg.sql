USE NETIKIP;
GO

SET XACT_ABORT ON;

DECLARE @Error INTEGER;
DECLARE @Updatebatchsize INT;
DECLARE @Rowcount BIGINT;
DECLARE @TOTALROWS INT;

SET @Rowcount = 0;
SET @Updatebatchsize = 20000;
SET @TOTALROWS = 0;

PRINT '-------------Script Started at	 :' + CONVERT(CHAR(23), GETDATE(), 121) + '------------------------';
PRINT SPACE(100);

BEGIN TRY
	WHILE 1 = 1
	BEGIN
		BEGIN TRANSACTION;

		UPDATE TOP (@Updatebatchsize) dbo.position_dg
		SET INSTR_ID = 'MD_762875'
		WHERE instr_id = 'MD_232243'
			AND INQ_BASIS_NUM = 1
			AND bk_id = 'hf'
			AND ORG_ID = 'SEI';
		SET @RowCount = @@rowcount;
		SET @TOTALROWS = @TOTALROWS + @RowCount;


		IF @RowCount = 0 -- terminating condition;
		BEGIN
			COMMIT TRANSACTION;

			BREAK;
		END;

		COMMIT TRANSACTION;

		-- WAITFOR DELAY '00:00:01';
		PRINT 'Total records Updated as of now ' + CAST(@TOTALROWS AS VARCHAR) + ' total rows';
	END;
END TRY

BEGIN CATCH
	IF XACT_STATE() <> 0
		OR @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRANSACTION;
	END;

	DECLARE @error_Message VARCHAR(4000);
	DECLARE @error_Severity INT;
	DECLARE @error_State INT;

	SET @error_Message = 'Error encoutered while updating records for tables dbo.Position_dg ' + ERROR_MESSAGE();
	SET @error_Severity = ERROR_SEVERITY();
	SET @error_State = ERROR_STATE();

	RAISERROR (
			@error_Message
			,@error_Severity
			,@error_State
			);
END CATCH;

PRINT SPACE(100);
PRINT '-------------Script completed at :' + CONVERT(CHAR(23), GETDATE(), 121) + '------------------------';
