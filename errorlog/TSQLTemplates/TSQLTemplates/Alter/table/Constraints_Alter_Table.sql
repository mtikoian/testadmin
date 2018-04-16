USE NETIKIP
GO
/*      
==================================================================================================      
Name    : Alter_Table_ACCT_PREF  
Author  : VBANDI  10/15/2013      
Description : This has been created for executing Alter Scripts for ACCT_PREF table.   
Dropping column ECR_Package_Name 
ECR_Package_ID NULL, int(10) – Unique identifier corresponding to the ECR Package Name already in the ACCT_PREF table
Period_Num  INT- The frequency for which the IPC team provides client reporting for the given Account ID
Period_Day INT– The day for which the client reporting package is due to the client for the given Account ID           
===================================================================================================      
Returns  :     N/A
Usage:      
History:      
      
Name			Date		  Description      
---------------------------------------------------------------------------- 
VBANDI		  10/15/2013      Initial Version      
VBANDI		  10/17/2013	  Period_CT column is not required for ECR Tagged --VBANDI 10172013  
VBANDI		  10/25/2013	  PERIOD_ID, PERIOD_DAY columns already exists in ims.IPCClientAccountSleeve table
							  in NETIKEXT and not required in NETIKIP database Tag --VBANDI 10252013
========================================================================================================      
*/ 


DECLARE @ErrorEncountered BIT

SET @ErrorEncountered = 0;

BEGIN TRY
	IF EXISTS (
			SELECT 1
			FROM information_schema.Tables
			WHERE Table_schema = 'dbo'
				AND Table_name = 'ACCT_PREF'
			)
BEGIN
		
		IF EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'ACCT_PREF'
					AND column_name = 'ECR_PACKAGE_NAME')
		BEGIN
		ALTER TABLE NETIKIP.dbo.ACCT_PREF DROP COLUMN ECR_PACKAGE_NAME 
		PRINT 'ECR_PACKAGE_NAME column Dropped from table ACCT_PERF'  
		END
		ELSE
		BEGIN
			PRINT 'Column ECR_PACKAGE_NAME alreday exists '
			SET @ErrorEncountered = 1
		END;
		
		
		IF NOT EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'ACCT_PREF'
					AND column_name = 'ECR_PACKAGE_ID')
		BEGIN
			ALTER TABLE NETIKIP.dbo.ACCT_PREF ADD ECR_PACKAGE_ID INT NULL

		PRINT 'ECR_PACKAGE_ID column added to  table ACCT_PREF' 
		END
		ELSE
		BEGIN
			PRINT 'Column ECR_PACKAGE_ID alreday exists '
			SET @ErrorEncountered = 1
		END;
		/*Start VBANDI 10252013*/
		--IF NOT EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'ACCT_PREF'
		--			AND column_name = 'PERIOD_ID')
		--BEGIN
		--	ALTER TABLE NETIKIP.dbo.ACCT_PREF ADD PERIOD_ID INT NULL

		--PRINT 'PERIOD_ID column added to table ACCT_PREF' 
		--END
		--ELSE
		--BEGIN
		--	PRINT 'Column PERIOD_ID alreday exists '
		--	SET @ErrorEncountered = 1
		--END;
		
		--IF NOT EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'ACCT_PREF'
		--			AND column_name = 'PERIOD_DAY')
		--BEGIN
		--	ALTER TABLE NETIKIP.dbo.ACCT_PREF ADD PERIOD_DAY INT NULL

		--PRINT 'PERIOD_DAY column added to table ACCT_PREF' 
		--END
		--ELSE
		--BEGIN
		--	PRINT 'Column PERIOD_DAY alreday exists '
		--	SET @ErrorEncountered = 1
		--END;
		/*END VBANDI 10252013*/
		/*Start VBANDI 10172013*/ 
		--IF NOT EXISTS (SELECT 1  FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'ACCT_PREF'
		--			AND column_name = 'PERIOD_CT')
		--BEGIN
		--	ALTER TABLE NETIKIP.dbo.ACCT_PREF ADD PERIOD_CT INT NOT NULL
		--	CONSTRAINT DF__ACCT_PREF__PERIOD_CT DEFAULT(0) WITH VALUES

		--PRINT 'column PERIOD_CT  added to table ACCT_PREF' 
		--END
		--ELSE
		--BEGIN
		--	PRINT 'Column PERIOD_CT alreday exists '
		--	SET @ErrorEncountered = 1
		--END;
		/*END VBANDI 10172013*/ 
		/*Start VBANDI 10252013*/
		--PRINT 'Adding constraints to TABLE dbo.ACCT_PREF'
		----Adding constraints to the table
		--IF NOT EXISTS (
		--	SELECT 1
		--	FROM sys.foreign_keys
		--	WHERE NAME = 'FK__ACCT_PREF__PERIOD_ID__SEI_PERIOD'
		--)
		--BEGIN
		--ALTER TABLE dbo.ACCT_PREF ADD
		--constraint	FK__ACCT_PREF__PERIOD_ID__SEI_PERIOD
		--		FOREIGN KEY(PERIOD_ID) 
		--			REFERENCES dbo.SEI_PERIOD(PERIOD_ID)
			
		--PRINT 'Added constraint **FK__ACCT_PREF__PERIOD_ID__SEI_PERIOD** to table ACCT_PREF' 
		--END	
		--ELSE
		--BEGIN
		--	PRINT 'constraint **FK__ACCT_PREF__PERIOD_ID__SEI_PERIOD** still exists '
		--	SET @ErrorEncountered = 1
		--END;
		/*END VBANDI 10252013*/
     --check for errors 
    IF @ErrorEncountered = 1
    BEGIN
        PRINT ' '
        PRINT ' '
        PRINT '**********************'
        PRINT 'ERROR OCCURRED'
    END
    ELSE
    BEGIN
        PRINT ' '
        PRINT ' '
        PRINT '**********************'
        PRINT 'Columns Altered Successfully for table ACCT_PREF'
      END
  END
  ELSE
  BEGIN
    PRINT 'Some error occured while altering table ACCT_PREF!!!'
  END

END TRY

BEGIN CATCH
END CATCH