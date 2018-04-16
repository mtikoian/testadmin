USE NetikDP
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

/*      
==================================================================================================      
Name    : Alter_Table INF_FILE_BATCHID 
Author  : SGottipati  07/24/2013      
Description : This has been created for Rollback Alter Scripts for CUST table.   
             
===================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name			Date		  Description      
---------------------------------------------------------------------------- 
SGottipati    07/24/2013      Initial Version      
========================================================================================================      
*/
IF  EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'INF_FILE_BATCHID'
			AND COLUMN_NAME = 'Src_ID'
		)
BEGIN
	ALTER TABLE dbo.INF_FILE_BATCHID 

	DROP COLUMN Src_ID

	PRINT 'Column Src_ID Droped'
END
ELSE
	PRINT 'Column Src_ID Already Exists'
GO


