/*============================================================================
  File:     FixUsingPageRestore.sql

  Summary:  This script repairs the DemoRestoreOrRepair
			database using single page restore.

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

-- Disaster recovery simulation of a zero'd page, using
-- single-page restore.

-- Must execute Setup scripts first for this to work.

-- Innocent user query on the sales table
SELECT SUM (salesAmount) FROM
	DemoRestoreOrRepair.dbo.sales
WHERE salesAmount < $1.00;
GO

-- Uh-oh - corruption!
-- Check the database using DBCC CHECKDB
DBCC CHECKDB (DemoRestoreOrRepair)
	WITH ALL_ERRORMSGS, NO_INFOMSGS;
GO

-- What does the page look like? Try doing an
-- interpreted dump of the page using DBCC PAGE
DBCC TRACEON (3604); -- necessary for correct output
GO
DBCC PAGE (DemoRestoreOrRepair, 1, 158, 3);
GO

-- DBCC PAGE can't work out how to dump the page
-- because the header is zero'd. Try a hex dump.
DBCC PAGE (DemoRestoreOrRepair, 1, 158, 2);
GO

-- Wow - totally zero! Looks like an IO error.

-- First thing to do, disallow user access.
-- Remember not to set it to OFFLINE otherwise not
-- even sysadmin can access the database.
ALTER DATABASE DemoRestoreOrRepair SET RESTRICTED_USER;
GO

-- Before we decide to fix the database using single-page
-- restore, let's see if any other pages are corrupt
SELECT * FROM msdb..suspect_pages;
GO

-- Now restore the single damaged page
USE master;
GO

-- First backup the tail of the log...
BACKUP LOG DemoRestoreOrRepair TO
	DISK = 'C:\SQLskills\DemoRestoreOrRepair_LOG_TAIL.bak'
	WITH INIT;
GO

-- And then start restoring, first with the full backup...
RESTORE DATABASE DemoRestoreOrRepair
	PAGE = '1:158' FROM
	DISK = 'C:\SQLskills\DemoRestoreOrRepair.bak';
GO

-- Now the first log backup...
RESTORE LOG DemoRestoreOrRepair FROM
	DISK = 'C:\SQLskills\DemoRestoreOrRepair_LOG1.bak'
	WITH NORECOVERY;
GO
-- And so on...

-- Finally with the tail of the log
RESTORE LOG DemoRestoreOrRepair FROM
	DISK = 'C:\SQLskills\DemoRestoreOrRepair_LOG_TAIL.bak'
	WITH NORECOVERY;
GO

-- And finish up with recovery. Notice all restore commands
-- used NORECOVERY to prevent mistakes
RESTORE DATABASE DemoRestoreOrRepair WITH RECOVERY;
GO

-- Bring the database online again
ALTER DATABASE DemoRestoreOrRepair SET MULTI_USER;
GO

-- Check the database for corruption again
DBCC CHECKDB (DemoRestoreOrRepair)
	WITH ALL_ERRORMSGS, NO_INFOMSGS;
GO

-- Final sanity check - run the user query again
SELECT SUM (salesAmount) FROM DemoRestoreOrRepair.dbo.sales
	WHERE salesAmount < $1.00;
GO
