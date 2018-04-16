USE NetikIP
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*      
==================================================================================================      
Name    : Alter_Table CUST   
Author  : SGottipati  07/24/2013      
Description : This has been created for executing Alter Scripts for CUST table.   
             
===================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name			Date		  Description      
---------------------------------------------------------------------------- 
SGottipati     07/24/2013      Initial Version      
========================================================================================================      
*/ 
IF NOT EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CUST'  AND  COLUMN_NAME = 'ADD_LN5_NME')
	
  BEGIN
        
     ALTER TABLE dbo.CUST
     ADD ADD_LN5_NME VARCHAR(50) NULL     


    PRINT 'Column ADD_LN5_NME Added'
	END
ELSE
	PRINT 'Column ADD_LN5_NME Already Exists'
GO



