USE NETIKIP;
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER OFF;
GO

/*      
==================================================================================================      
Name    : Alter_Table_ISSUE_PRICE.sql
Author  : VBANDI  04/08/2014      
Description : This has been created for executing Alter Scripts for ISSUE_PRICE table.   
             
===================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name			Date		  Description      
---------------------------------------------------------------------------- 
VBANDI			04/08/2014       Initial Version      
========================================================================================================      
*/
DECLARE @ErrorEncountered BIT;

SET @ErrorEncountered = 0;

BEGIN TRY
	IF EXISTS (
			SELECT 1
			FROM information_schema.Tables
			WHERE Table_schema = 'dbo'
				AND Table_name = 'ISSUE_PRICE'
			)
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM sys.indexes
				WHERE object_id = object_id('dbo.ISSUE_PRICE')
					AND NAME = 'UQ_IDX__ISSUE_PRICE_INSTR_ID_PRC_TMS'
				)
		BEGIN
			DROP INDEX UQ_IDX__ISSUE_PRICE_INSTR_ID_PRC_TMS ON dbo.ISSUE_PRICE;

			PRINT 'Dropped Index UQ_IDX__ISSUE_PRICE_INSTR_ID_PRC_TMS on ISSUE_PRICE';
		END;
		ELSE
		BEGIN
			PRINT 'Index UQ_IDX__ISSUE_PRICE_INSTR_ID_PRC_TMS still exists on ISSUE_PRICE!!!';

			SET @ErrorEncountered = 1;
		END;

		--check for errors 
		IF @ErrorEncountered = 1
		BEGIN
			PRINT ' ';
			PRINT ' ';
			PRINT '**********************';
			PRINT 'ERROR OCCURRED';
		END;
		ELSE
		BEGIN
			PRINT ' ';
			PRINT ' ';
			PRINT '**********************';
			PRINT 'Dropped index Successfully for table ISSUE_PRICE';
		END;
	END
	ELSE
	BEGIN
		PRINT 'Some error occured while dropping index on ISSUE_PRICE!!!';
	END;
END TRY

BEGIN CATCH
	DECLARE @errmsg NVARCHAR(2048);
	DECLARE @errsev INT;
	DECLARE @errstate INT;

	SET @errmsg = 'Error Dropping index' + ERROR_MESSAGE();
	SET @errsev = ERROR_SEVERITY();
	SET @errstate = ERROR_STATE();

	RAISERROR (
			@errmsg
			,@errsev
			,@errstate
			);
END CATCH;
GO


