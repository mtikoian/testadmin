USE NetikDP;
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER OFF;
GO

/*      
==================================================================================================      
Name    : Alter_Table_INF_INVESTOR.sql
Author  : VBANDI   
Description : This has been created for executing Alter Scripts for INF_INVESTOR table.   
             
===================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name			Date		  Description      
---------------------------------------------------------------------------- 
VBANDI		   02/21/2014			Initial Version   
========================================================================================================      
*/
DECLARE @ErrorEncountered BIT;

SET @ErrorEncountered = 0;

BEGIN TRY
	IF EXISTS (
			SELECT 1
			FROM information_schema.Tables
			WHERE Table_schema = 'cds'
				AND Table_name = 'INF_INVESTOR'
			)
	BEGIN
		IF EXISTS (
				SELECT *
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE table_name = 'INF_INVESTOR'
					AND column_name = 'Beneficial_Owner_Form_PF'
					AND CHARACTER_MAXIMUM_LENGTH = 100
				)
		BEGIN
			ALTER TABLE cds.INF_INVESTOR

			ALTER COLUMN Beneficial_Owner_Form_PF VARCHAR(50);

			PRINT 'Beneficial_Owner_Form_PF column length altered to VARCHAR(50)';
		END;
		ELSE
		BEGIN
			PRINT 'Column-Beneficial_Owner_Form_PF length still VARCHAR(100)!!!';

			SET @ErrorEncountered = 1;
		END;

		IF EXISTS (
				SELECT 1
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE table_name = 'INF_INVESTOR'
					AND column_name = 'AIFMD_Investor_Type_Name'
					AND CHARACTER_MAXIMUM_LENGTH = 70
				)
		BEGIN
			ALTER TABLE cds.INF_INVESTOR

			ALTER COLUMN AIFMD_Investor_Type_Name VARCHAR(50);

			PRINT 'AIFMD_Investor_Type_Name column length added to VARCHAR(50)';
		END;
		ELSE
		BEGIN
			PRINT 'Column-AIFMD_Investor_Type_Name length still VARCHAR(70)!!! ';

			SET @ErrorEncountered = 1;
		END;

		--check for errors 
		IF @ErrorEncountered = 1
		BEGIN
			PRINT ' ';
			PRINT ' ';
			PRINT '**********************';
			PRINT 'ERROR OCCURRED';
		END
		ELSE
		BEGIN
			PRINT ' ';
			PRINT ' ';
			PRINT '**********************';
			PRINT 'Columns Altered Successfully for table INF_INVESTOR';
		END;
	END;
	ELSE
	BEGIN
		PRINT 'Some error occured while altering table INF_INVESTOR!!!'
	END;
END TRY

BEGIN CATCH
	DECLARE @errmsg NVARCHAR(2048);
	DECLARE @errsev INT;
	DECLARE @errstate INT;

	SET @errmsg = 'Error adding objects' + ERROR_MESSAGE();
	SET @errsev = ERROR_SEVERITY();
	SET @errstate = ERROR_STATE();

	RAISERROR (
			@errmsg
			,@errsev
			,@errstate
			);
END CATCH;
