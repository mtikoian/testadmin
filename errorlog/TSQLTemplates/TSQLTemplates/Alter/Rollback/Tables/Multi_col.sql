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
----Droping  new columns added to table DP_T_AccountTotals------
PRINT 'Rolling Back  DP_T_AccountTotals table';

IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'DP_T_AccountTotals'
			AND COLUMN_NAME = 'instance_id'
		)
	ALTER TABLE dbo.DP_T_AccountTotals

DROP COLUMN instance_id

IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'DP_T_AccountTotals'
			AND COLUMN_NAME = 'inf_flag'
		)
	ALTER TABLE dbo.DP_T_AccountTotals

DROP COLUMN inf_flag


Print 'Roll Back Ends for table DP_T_AccountTotals'

