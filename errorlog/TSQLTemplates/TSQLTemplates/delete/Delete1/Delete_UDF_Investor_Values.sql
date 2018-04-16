USE NetikIP;
GO

--File Name : Delete_UDF_Investor_Values.sql
SET XACT_ABORT ON;

DECLARE @Error INTEGER;
DECLARE @Deletebatchsize INT;
DECLARE @Rowcount BIGINT;
DECLARE @TOTALROWS INT;

SET @Deletebatchsize = 5000;
SET @RowCount = 1;
SET @TOTALROWS = 0;

BEGIN TRY
	WHILE @ROWCOUNT > 0
	BEGIN
		BEGIN TRANSACTION;

With CTE
AS
(
	Select	Acct_Id
				,Instr_Id
				,As_of_dt
				,Ref_Acct_Id
				,Alternate_Class_Series_Id
				,Trade_Dt,
			ROW_NUMBER()
				OVER (PARTITION BY Acct_Id
				,Instr_Id
				,As_of_dt
				,Ref_Acct_Id
				,Alternate_Class_Series_Id
				,Trade_Dt
				,Field_Value_Type_Cd
						ORDER BY Acct_Id
				,Instr_Id
				,As_of_dt
				,Ref_Acct_Id
				,Alternate_Class_Series_Id
				,Trade_Dt,Field_Value_Type_Cd) AS RowNumber
				,[Field_Value_Type_Cd]
	from	dbo.UDF_Investor_Values
)

delete TOP (@Deletebatchsize)
FROM	CTE
WHERE	RowNumber > 1;

--select 
--Acct_Id
--				,Instr_Id
--				,As_of_dt
--				,Ref_Acct_Id
--				,Alternate_Class_Series_Id
--				,Trade_Dt
--				,RowNumber
--				,[Field_Value_Type_Cd]
--FROM	CTE
--WHERE	RowNumber > 1;




		SET @RowCount = @@rowcount
		SET @TOTALROWS = @TOTALROWS + @RowCount

		COMMIT TRANSACTION

		PRINT '*** Total Records Deleted in batch so far: ' + Cast(@RowCount AS VARCHAR(10));
	END

	PRINT 'Total records deleted from  dbo.UDF_Investor_Values as of now ' + CAST(@TOTALROWS AS VARCHAR) + ' total rows'
END TRY

BEGIN CATCH
	IF Xact_state() <> 0
		ROLLBACK TRANSACTION

	SET @Error = Error_number();

	SELECT Error_number() AS ErrorNumber
		,Error_message() AS ErrorMessage;

	PRINT 'ERROR: Deleting Records'

	RAISERROR (
			'Error encoutered while deleting records from table dbo.UDF_Investor_Values'
			,16
			,1
			);
END CATCH
