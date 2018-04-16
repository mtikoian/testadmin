USE NETIKIP;
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER OFF;
GO

/*      
* Copyright: This information constitutes the exclusive property of SEI
* Investments Company, and constitutes the confidential and proprietary
* information of SEI Investments Company.  The information shall not be
* used or disclosed for any purpose without the written consent of SEI 
* Investments Company.            
==================================================================================================      
Name    : Alter_Table_DW_FUNCTION_ITEM.sql
Author  : VBANDI  10/16/2014      
Description : This has been created for executing Alter Scripts for DW_FUNCTION_ITEM table.   
             
===================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name			Date		  Description      
---------------------------------------------------------------------------- 
VBANDI		10/16/2014       Initial Version      
========================================================================================================      
*/
DECLARE @ErrorEncountered BIT;

SET @ErrorEncountered = 0;

BEGIN TRY
	IF EXISTS (
			SELECT 1
			FROM information_schema.Tables
			WHERE Table_schema = 'dbo'
				AND Table_name = 'DW_FUNCTION_ITEM'
			)
	BEGIN
		IF EXISTS (
				SELECT 1
				FROM sys.indexes
				WHERE object_id = object_id('dbo.DW_FUNCTION_ITEM')
					AND NAME = 'IDX__DW_FUNCTION_ITEM_FN_ENABLE_IND'
				)
		BEGIN
			DROP INDEX IDX__DW_FUNCTION_ITEM_FN_ENABLE_IND ON dbo.DW_FUNCTION_ITEM;

			PRINT 'Dropped Index IDX__DW_FUNCTION_ITEM_FN_ENABLE_IND on DW_FUNCTION_ITEM';
		END;
		ELSE
		BEGIN
			PRINT 'Index IDX__DW_FUNCTION_ITEM_FN_ENABLE_IND doesnt exists on DW_FUNCTION_ITEM!!!';

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
			PRINT 'Dropped index Successfully for table DW_FUNCTION_ITEM';
		END;
	END
	ELSE
	BEGIN
		PRINT 'Some error occured while dropping index on DW_FUNCTION_ITEM!!!';
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


