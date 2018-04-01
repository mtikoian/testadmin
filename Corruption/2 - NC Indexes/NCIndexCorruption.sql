/*============================================================================
  File:     NCIndexCorruption.sql

  Summary:  This script demonstrates fixing non-clustered
			index corruption

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

/* Setup
USE master;
GO

-- Make sure the restore path exists...
RESTORE DATABASE DemoNCIndex FROM
	DISK = 'C:\SQLskills\CorruptionDemoBackups\CorruptDemoNCIndex.bak'
WITH REPLACE, STATS = 10;
GO
*/

-- Run a CHECKDB
DBCC CHECKDB (DemoNCIndex)
WITH NO_INFOMSGS, ALL_ERRORMSGS;
GO


-- Is it just non-clustered indexes?
-- Scan through all the errors looking for index IDs
-- Maybe use WITH TABLERESULTS?
DBCC CHECKDB (DemoNCIndex)
WITH NO_INFOMSGS, ALL_ERRORMSGS, TABLERESULTS;
GO

-- If you wanted to fix them with CHECKDB, it
-- may do single row repairs or rebuild the index,
-- depending on the error.
DBCC CHECKDB (DemoNCIndex, REPAIR_REBUILD)
WITH NO_INFOMSGS, ALL_ERRORMSGS, TABLERESULTS;
GO













-- You need to be in SINGLE_USER mode! Just to
-- fix non-clustered indexes.
--
-- That doesn't make sense. Just rebuild them
-- manually and keep the database online. Try an
-- online rebuild...
USE DemoNCIndex
GO
EXEC sp_HelpIndex 'Customers';
GO

ALTER INDEX - ON Customers REBUILD
WITH (ONLINE = ON);
GO

-- And check again...
DBCC CHECKDB (DemoNCIndex)
WITH NO_INFOMSGS, ALL_ERRORMSGS;
GO

















-- Didn't work! Online index rebuild scans
-- the old index...
-- Offline rebuild doesn't...
ALTER INDEX CustomerName ON Customers REBUILD;
GO

DBCC CHECKDB (DemoNCIndex)
WITH NO_INFOMSGS, ALL_ERRORMSGS;
GO