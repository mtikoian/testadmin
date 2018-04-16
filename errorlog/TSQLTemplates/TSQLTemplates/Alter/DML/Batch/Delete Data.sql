USE NetikIP
GO

SET XACT_ABORT  ON
DECLARE @Error INTEGER
DECLARE @Deletebatchsize INT
DECLARE @Rowcount BIGINT
DECLARE @acct_id CHAR(20)
DECLARE @as_of_tms DATETIME

SET @Deletebatchsize = 5000
SET @RowCount = 1;
SET @acct_id = '1052-1-00745'
SET @as_of_tms = '07-31-2013 00:00:00.000'

BEGIN TRY
	WHILE @ROWCOUNT > 0
	BEGIN
		BEGIN TRANSACTION

		DELETE TOP (@Deletebatchsize)
		FROM dbo.position_dg
		WHERE acct_id = @acct_id
			AND as_of_tms < @as_of_tms

		SET @RowCount = @@rowcount

		COMMIT

		PRINT '*** Total Records Deleted In dbo.position_dg so far: ' + Cast(@RowCount AS VARCHAR(10));
	END

	SET @RowCount = 1;-- reset counter

	WHILE @ROWCOUNT > 0 -- delete records from tranevent_dg
	BEGIN
		BEGIN TRANSACTION

		DELETE TOP (@Deletebatchsize)
		FROM dbo.tranevent_dg
		WHERE acct_id = @acct_id
			AND fld4_tms < @as_of_tms

		SET @RowCount = @@rowcount

		COMMIT

		PRINT '*** Total Records Deleted In dbo.tranevent_dg so far: ' + Cast(@RowCount AS VARCHAR(10));
	END

	SET @RowCount = 1;-- reset counter

	WHILE @ROWCOUNT > 0 -- delete records from POSITION_PL_TOTAL
	BEGIN
		BEGIN TRANSACTION

		DELETE TOP (@Deletebatchsize)
		FROM dbo.POSITION_PL_TOTAL
		WHERE acct_id = @acct_id
			AND as_of_tms < @as_of_tms

		SET @RowCount = @@rowcount

		COMMIT

		PRINT '*** Total Records Deleted In dbo.POSITION_PL_TOTAL so far: ' + Cast(@RowCount AS VARCHAR(10));
	END

	SET @RowCount = 1;-- reset counter

	WHILE @ROWCOUNT > 0 -- delete records from lot_dg
	BEGIN
		BEGIN TRANSACTION

		DELETE TOP (@Deletebatchsize)
		FROM dbo.lot_dg
		WHERE acct_id = @acct_id
			AND as_of_tms < @as_of_tms

		SET @RowCount = @@rowcount

		COMMIT

		PRINT '*** Total Records Deleted In dbo.lot_dg so far: ' + Cast(@RowCount AS VARCHAR(10));
	END

END TRY 

BEGIN CATCH

    IF Xact_state() <> 0 ROLLBACK TRANSACTION 
    
    SET @Error = Error_number(); 

    SELECT Error_number()  AS ErrorNumber, 
           Error_message() AS ErrorMessage; 

    PRINT 'ERROR: dbo.SEI_PurgeIPDataMoreThan2Years'

    RAISERROR('Error encoutered while deleting records from tables dbo.TRANEVENT_DG,dbo.lot_dg,dbo.POSITION_PL_TOTAL and position_dg table',16,1); 

    
END CATCH 