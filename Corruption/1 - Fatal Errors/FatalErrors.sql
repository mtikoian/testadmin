/*============================================================================
  File:     FatalErrors.sql

  Summary:  This script shows some fatal (to CHECKDB) corruptions

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
RESTORE DATABASE DemoFatalCorruption1 FROM
	DISK = 'C:\SQLskills\CorruptionDemoBackups\CorruptDemoFatalCorruption1.bak'
WITH REPLACE, STATS = 10;
GO
RESTORE DATABASE DemoFatalCorruption2 FROM
	DISK = 'C:\SQLskills\CorruptionDemoBackups\CorruptDemoFatalCorruption2.bak'
WITH REPLACE, STATS = 10;
GO
*/

USE master;
GO

-- Corrupt IAM chain for sys.syshobts
--
DBCC CHECKDB (DemoFatalCorruption1)
WITH NO_INFOMSGS, ALL_ERRORMSGS;
GO

-- Corruption found by the metadata layer
-- of the Engine
DBCC CHECKDB (DemoFatalCorruption2)
WITH NO_INFOMSGS, ALL_ERRORMSGS;
GO
