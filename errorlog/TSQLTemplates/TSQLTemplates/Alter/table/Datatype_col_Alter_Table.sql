USE NetikDP
GO
/*      
==================================================================================================      
Name		: DP_PI_U_ISSUEACTIVITY,DP_T_ISSUEACTIVITY,ISSUE_DG      
Author		: MChawla   - 07/23/2013      
Description : This has been created for executing alter Scripts for typed tables.   
             
===================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name  Date  Description      
---------- ---------- --------------------------------------------------------      
   
========================================================================================================      
*/    


IF  EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DP_PI_U_ISSUEACTIVITY'  AND  COLUMN_NAME = 'FLD21_IND')
	BEGIN
	ALTER TABLE dbo.DP_PI_U_ISSUEACTIVITY
	ALTER COLUMN FLD21_IND VARCHAR(50) NULL
		PRINT 'FLD21_IND Column Altered'
	END
ELSE
	BEGIN
		PRINT 'FLD21_IND Column Not Exists'
	END
GO	
	
IF  EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'DP_T_ISSUEACTIVITY'  AND  COLUMN_NAME = 'FLD21_IND')
	BEGIN
	ALTER TABLE dbo.DP_T_ISSUEACTIVITY
	ALTER COLUMN FLD21_IND VARCHAR(50) NULL
		PRINT 'FLD21_IND Column Altered'
	END
ELSE
	BEGIN
		PRINT 'FLD21_IND Column Not Exists'
	END

GO
USE NETIKIP
GO	
IF  EXISTS( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ISSUE_DG'  AND  COLUMN_NAME = 'FLD21_IND')
	BEGIN
	ALTER TABLE dbo.ISSUE_DG
	ALTER COLUMN FLD21_IND VARCHAR(50) NULL
		PRINT 'FLD21_IND Column Altered'
	END
ELSE
	BEGIN
		PRINT 'FLD21_IND Column Not Exists'
	END
	
GO