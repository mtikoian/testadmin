USE NetikIP
GO
/***
================================================================================
 Name        : Insert_DATA_RETENTION_POLICY_1317_1318.sql
 Author      : VBANDI- 01/14/2014
 Description : Turn Off purge process for 1317 and 1318
===============================================================================
 Revisions    :
--------------------------------------------------------------------------------
 Ini			|   Date		|	 Description
 VBANDI			 01/14/2014			 Initial Version
--------------------------------------------------------------------------------
================================================================================
***/
SET NOCOUNT ON

DECLARE @Error INTEGER;
DECLARE @Rowcount BIGINT;

SET @Rowcount = 0;
SET NOCOUNT ON

BEGIN TRY
	BEGIN TRANSACTION
	
		IF NOT EXISTS (SELECT 1 FROM dbo.DATA_RETENTION_POLICY WHERE CUST_ID='1317' AND RETENTION_PERIOD_CD=2)
BEGIN
		INSERT INTO dbo.DATA_RETENTION_POLICY (CUST_ID,RETENTION_PERIOD_CD,RETENTION_LEN_NUM) VALUES ('1317',2,480)												
		
END
SET @RowCount = @RowCount + @@ROWCOUNT


	IF NOT EXISTS (SELECT 1 FROM dbo.DATA_RETENTION_POLICY WHERE CUST_ID='1318' AND RETENTION_PERIOD_CD=2)
BEGIN
		INSERT INTO dbo.DATA_RETENTION_POLICY (CUST_ID,RETENTION_PERIOD_CD,RETENTION_LEN_NUM) VALUES ('1318',2,480)												
	END
		

	SET @RowCount = @RowCount + @@ROWCOUNT

	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION;

		PRINT REPLICATE('*', 60)
		PRINT 'Total Records Inserted = ' + cast(@RowCount AS VARCHAR(10));
		PRINT REPLICATE('*', 60)
	END
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0
		OR Xact_state() <> 0
		ROLLBACK TRANSACTION;

	SET @Error = ERROR_NUMBER();

	RAISERROR (
			'Error during Insertion'
			,16
			,1
			);

	SELECT ERROR_NUMBER() AS ErrorNumber
		,ERROR_MESSAGE() AS ErrorMessage;
END CATCH

IF @Error <> 0
BEGIN
	IF @@TRANCOUNT <> 0
		ROLLBACK TRANSACTION;
END;
