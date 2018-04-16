USE NETIKIP
GO
/*      
==================================================================================================      
Name    : Alter_Table_INVESTOR 
Author  : VBANDI  08/16/2013      
Description : This has been created for executing Alter Scripts for INVESTOR table.   
             
===================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name			Date		  Description      
---------------------------------------------------------------------------- 
VBANDI     07/16/2013      Initial Version      
========================================================================================================      
*/ 


IF NOT EXISTS (SELECT 1 FROM sys.indexes
		WHERE object_id = OBJECT_ID(N'dbo.INVESTOR') AND NAME = N'PK_INVESTOR_INVESTOR_SYSID_CUST_ID')
	
	ALTER TABLE dbo.INVESTOR ADD CONSTRAINT PK_INVESTOR_INVESTOR_SYSID_CUST_ID PRIMARY KEY CLUSTERED (
		INVESTOR_SYSID ,CUST_ID )
	
---Validation 
IF EXISTS
     (SELECT 1 FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
      WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N'INVESTOR' AND
        CONSTRAINT_NAME = N'PK_INVESTOR_INVESTOR_SYSID_CUST_ID')
 
    PRINT 'Created Index PK_INVESTOR_INVESTOR_SYSID_CUST_ID on INVESTOR'
ELSE
    PRINT 'Failed to create Index PK_INVESTOR_INVESTOR_SYSID_CUST_ID on INVESTOR!!!'
GO
PRINT '';

IF NOT EXISTS ( SELECT 1 FROM sys.indexes
		WHERE object_id = object_id('dbo.INVESTOR') AND NAME = 'IDX_INVESTOR_CUST_ID')
	
	CREATE INDEX IDX_INVESTOR_CUST_ID ON dbo.INVESTOR (CUST_ID)

IF EXISTS ( SELECT 1 FROM sys.indexes
		WHERE object_id = object_id('dbo.INVESTOR') AND NAME = 'IDX_INVESTOR_CUST_ID')
	PRINT 'Created Index IDX_INVESTOR_CUST_ID on INVESTOR'
ELSE
	PRINT 'Failed to create Index IDX_INVESTOR_CUST_ID on INVESTOR!!!'
GO
PRINT '';
