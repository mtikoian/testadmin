USE NetikDP
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*      
==================================================================================================      
Name    : Alter_Table_DP_T_AccountTotals   
Author  : SGottipati  08/15/2013      
Description : This has been created for executing Alter Scripts for DP_T_AccountTotals table.   
             
===================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name			Date		  Description      
---------------------------------------------------------------------------- 
SGottipati     08/15/2013      Initial Version      
========================================================================================================      
*/ 
IF NOT EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DP_T_AccountTotals'  AND  COLUMN_NAME = 'instance_id')
	
  BEGIN
        
     ALTER TABLE dbo.DP_T_AccountTotals
     ADD instance_id INT NULL,
         inf_flag INT NULL;      

    PRINT 'Columns Altered Successfully for table DP_T_AccountTotals'
	END
ELSE
	PRINT 'Columns Altered failed for table DP_T_AccountTotals'
GO


