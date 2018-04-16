USE BloomBerg_STG;
GO

/*      
==================================================================================================      
Name    : Alter_Table_BBSourceValuesHistory 
Author  : DDWIVEDI  03/19/2014      
Description : This has been created for executing Alter Scripts for BBSourceValuesHistory table.   
             
===================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name			Date		  Description      
---------------------------------------------------------------------------- 
DDWIVEDI     07/16/2013      Initial Version      
========================================================================================================      
*/
IF EXISTS (
		SELECT 1
		FROM sys.indexes
		WHERE object_id = OBJECT_ID(N'BloomBerg.BBSourceValuesHistory')
			AND NAME = N'IDX_BBSourceValuesHistory_UniqueKey'
		)
BEGIN
	DROP INDEX IDX_BBSourceValuesHistory_UniqueKey ON BloomBerg.BBSourceValuesHistory;

	PRINT 'Dropped Index IDX_BBSourceValuesHistory_UniqueKey on BloomBerg.BBSourceValuesHistory!!!'
END;
GO

IF NOT EXISTS (
		SELECT 1
		FROM sys.indexes
		WHERE object_id = OBJECT_ID(N'BloomBerg.BBSourceValuesHistory')
			AND NAME = N'IDX_BBSourceValuesHistory_UniqueKey'
		)
BEGIN
	CREATE NONCLUSTERED INDEX IDX_BBSourceValuesHistory_UniqueKey ON BloomBerg.BBSourceValuesHistory (UniqueKey ASC);

	PRINT ' Index IDX_BBSourceValuesHistory_UniqueKey created on BloomBerg.BBSourceValuesHistory!!!'
END;
GO


