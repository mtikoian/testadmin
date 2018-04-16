USE NetikIP;
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER OFF;
GO

/*      
==================================================================================================      
Name    : Alter_Table_UDF_Investor_Values.sql
Author  : VBANDI 
===================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name			Date		  Description      
---------------------------------------------------------------------------- 
VBANDI		   03/21/2014	  Initial Version   
========================================================================================================      
*/
BEGIN TRY
	IF EXISTS (
			SELECT 1
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE table_name = 'UDF_Investor_Values'
				AND column_name = 'Trade_Dt'
			)
	BEGIN
		ALTER TABLE dbo.UDF_Investor_Values DROP COLUMN Trade_Dt;

		PRINT 'Trade_Dt column dropped from UDF_Investor_Values ';
	END;
	ELSE
	BEGIN
		PRINT 'Trade_Dt column doesnt exists ';
	END;
END TRY

BEGIN CATCH
	DECLARE @errmsg NVARCHAR(2048);
	DECLARE @errsev INT;
	DECLARE @errstate INT;

	SET @errmsg = 'Error Altering objects' + ERROR_MESSAGE();
	SET @errsev = ERROR_SEVERITY();
	SET @errstate = ERROR_STATE();

	RAISERROR (
			@errmsg
			,@errsev
			,@errstate
			);
END CATCH;
