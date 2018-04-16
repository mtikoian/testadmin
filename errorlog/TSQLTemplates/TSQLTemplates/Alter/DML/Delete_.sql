USE [NetikDP]
GO

/***
================================================================================
 Name        : Delete_INF_FILE_BATCHID.sql
 Author      : SMehrotra [VPerala] - 07/17/2013
 Description : Delete duplicate batchIds [INF_FILE_BATCHID]
===============================================================================
 Revisions    :
--------------------------------------------------------------------------------
 Ini			|   Date		|	 Description
 SMehrotra		    07/17/2013		 Initial Version
--------------------------------------------------------------------------------
================================================================================
***/
SET NOCOUNT ON
DECLARE @Error INTEGER;
DECLARE @Rowcount BIGINT;
set @Rowcount = 0 ;

BEGIN TRY
	BEGIN TRANSACTION

	DELETE
	FROM [NetikDP].[dbo].[INF_FILE_BATCHID]
	WHERE BATCH_ID IN (
			SELECT BATCH_ID
			FROM [NetikDP].[dbo].[INF_FILE_BATCHID] WITH (NOLOCK)
			GROUP BY BATCH_ID
			HAVING COUNT(BATCH_ID) > 1
			)
set @Rowcount = @@rowcount
	IF @@trancount > 0
	BEGIN
		COMMIT TRANSACTION;

PRINT REPLICATE('*', 60)    
PRINT  'Total Records deleted = ' +  cast(@RowCount AS VARCHAR(10))   ;
PRINT REPLICATE('*', 60)
	END
END TRY

BEGIN CATCH
	SET @Error = error_number();

	IF @@trancount <> 0
		ROLLBACK TRANSACTION;

	RAISERROR (
			'Error during Deletion'
			,16
			,1
			);

	SELECT error_number() AS ErrorNumber
		,error_message() AS ErrorMessage;
END CATCH
GO


