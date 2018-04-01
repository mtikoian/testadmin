/*============================================================================
  File:     FixUsingRepair.sql

  Summary:  This script repairs the DemoRestoreOrRepair
			database using CHECKDB.

  Date:     June 2008

  SQL Server Versions:
		10.0.1600.22 (SS2008 RTM)
		9.00.3068.00 (SS2005 SP2+)
------------------------------------------------------------------------------
  Written By Paul S. Randal, SQLskills.com
  All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you give due credit.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

-- Disaster recovery simulation of a zero'd page using CHECKDB
-- and then recovering lost rows from a backup.

-- Now imagine we only had the full backup and the database
-- is in SIMPLE recovery mode. No single page restore is
-- possible.

-- Reset back to the corrupt database
RESTORE DATABASE DemoRestoreOrRepair FROM
	DISK = 'C:\SQLskills\CorruptionDemoBackups\CorruptDemoRestoreOrRepair.bak'
	WITH REPLACE;
GO

-- Innocent user query on the sales table
SELECT SUM (salesAmount) FROM DemoRestoreOrRepair.dbo.sales
	WHERE salesAmount < $1.00;
GO

-- Uh-oh - corruption!
-- Check the database using DBCC CHECKDB
DBCC CHECKDB (DemoRestoreOrRepair)
	WITH ALL_ERRORMSGS, NO_INFOMSGS;
GO

-- Hmm - only a full backup. What to do?
-- We're going to have to run repair to fix this.
-- Can we use the full backup to get the data back?

-- First thing - take a backup of the corrupt database
-- in case anything goes wrong.
BACKUP DATABASE DemoRestoreOrRepair TO
	DISK = 'C:\SQLskills\DemoRestoreOrRepair_BeforeRepair.bak'
	WITH INIT;
GO

-- Now run repair
ALTER DATABASE DemoRestoreOrRepair SET SINGLE_USER;
GO

DBCC CHECKDB (DemoRestoreOrRepair, REPAIR_ALLOW_DATA_LOSS)
	WITH ALL_ERRORMSGS, NO_INFOMSGS;
GO

ALTER DATABASE DemoRestoreOrRepair SET RESTRICTED_USER;
GO

-- How many rows did we lose?
SELECT COUNT (*) FROM DemoRestoreOrRepair.dbo.sales;
GO

-- Can we tell the range? We know the salesID is monatonically
-- increasing...
-- Start of the missing range is when a value does not have a
-- plus-1 neighbor.
SELECT MIN(salesID + 1) FROM DemoRestoreOrRepair.dbo.sales as A
WHERE NOT EXISTS (
	SELECT salesID FROM DemoRestoreOrRepair.dbo.sales as B
	WHERE B.salesID = A.salesID + 1);
GO
-- End of the missing range is when a value does not have a
-- minus-1 neighbor
SELECT MAX(salesID - 1) FROM DemoRestoreOrRepair.dbo.sales as A
WHERE NOT EXISTS (
	SELECT salesID FROM DemoRestoreOrRepair.dbo.sales as B
	WHERE B.salesID = A.salesID - 1)
GO








-- Looks like salesID X to Y inclusive

-- Let's restore the full backup to a different location
RESTORE FILELISTONLY FROM
	DISK = 'C:\SQLskills\DemoRestoreOrRepair.bak';
GO

RESTORE DATABASE DemoRestoreOrRepairCopy FROM
	DISK = 'C:\SQLskills\DemoRestoreOrRepair.bak'
	WITH MOVE N'DemoRestoreOrRepair'
		TO N'C:\SQLskills\DemoRestoreOrRepairCopy.mdf', 
	MOVE N'DemoRestoreOrRepair_log'
		TO N'C:\SQLskills\DemoRestoreOrRepairCopy_log.ldf', 
	REPLACE;
GO

-- And look in the corrupt page
DBCC TRACEON (3604);
GO
DBCC PAGE (DemoRestoreOrRepairCopy, 1, 158, 3);
GO












-- Cool! The page in the backup contains the
-- data range that is missing. Now we can copy it
-- back to the real database. Only problem is that we
-- don't know if anything changed on the rows - but at
-- least we get the data back.

-- Preserve identity values
SET IDENTITY_INSERT DemoRestoreOrRepair.dbo.sales ON;
GO

-- Copy the rows over
SET NOCOUNT OFF;
GO

INSERT INTO DemoRestoreOrRepair.dbo.sales (
	salesID, customerID, salesDate, salesAmount)
SELECT * FROM DemoRestoreOrRepairCopy.dbo.sales AS copy
WHERE copy.salesID > X AND copy.salesID < Y;
GO

-- Restore identity behavior.
SET IDENTITY_INSERT DemoRestoreOrRepair.dbo.sales OFF;
GO

-- Check the row count
SELECT COUNT(*) FROM DemoRestoreOrRepair.dbo.sales;
GO


