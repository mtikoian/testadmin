USE NETIKIP  --> Change database name 
GO

SET XACT_ABORT ON

DECLARE @Error INTEGER;
DECLARE @Updatebatchsize INT;
DECLARE @Rowcount BIGINT;
DECLARE @TOTALROWS INT;

SET @Rowcount = 1;
SET @Updatebatchsize = 5000;--Increase batch size to 10k, if you are deleting more than 50k 
SET @TOTALROWS = 0;

BEGIN TRY
	
		BEGIN TRANSACTION

		delete from   dbo.tranevent_dg
		output deleted.*
		where 

		COMMIT TRANSACTION;

	

	PRINT 'Total records Updated as of now ' + CAST(@TOTALROWS AS VARCHAR) + ' total rows';
END TRY

BEGIN CATCH
	IF Xact_state() <> 0
		ROLLBACK TRANSACTION

	SELECT ERROR_NUMBER() AS ErrorNumber
		,Error_message() AS ErrorMessage
		,ERROR_LINE() AS ErrorLine
		,ERROR_STATE() AS ErrorState
		,ERROR_SEVERITY() AS ErrorSeverity;

	PRINT 'ERROR:while updating records for tables dbo.tranevent_dg'

	RAISERROR (
			'Error encoutered while updating records for tables dbo.tranevent_dg'
			,16
			,1
			);
END CATCH
