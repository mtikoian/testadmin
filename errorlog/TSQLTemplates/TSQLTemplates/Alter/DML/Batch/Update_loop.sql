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
	 WHILE (1 = 1)
	BEGIN
		BEGIN TRANSACTION

		UPDATE TOP (@Updatebatchsize) dbo.tranevent_dg
		SET acrinc_alt_cmb_amt = (
				CASE 
					WHEN inc_ps_alt_amt > 0
						THEN inc_ps_alt_amt
					ELSE 0
					END
				)
			,acrinc_cmb_amt = (
				CASE 
					WHEN inc_ps_amt > 0
						THEN inc_ps_amt
					ELSE 0
					END
				)
			,acrexp_alt_cmb_amt = (
				CASE 
					WHEN inc_ps_alt_amt < 0
						THEN inc_ps_alt_amt
					ELSE 0
					END
				)
			,acrexp_cmb_amt = (
				CASE 
					WHEN inc_ps_amt < 0
						THEN inc_ps_amt
					ELSE 0
					END
				)
		WHERE acct_id LIKE '1228-1-%'
			AND bk_id = 'hf'

		 IF @@ROWCOUNT = 0 -- terminating condition;
      BEGIN
        COMMIT TRANSACTION
        BREAK
      END
    
    COMMIT TRANSACTION
-- WAITFOR DELAY '00:00:01';
END

	PRINT 'Total records Updated as of now ' + CAST(@TOTALROWS AS VARCHAR) + ' total rows'
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
