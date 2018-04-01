/*============================================================================
  File:     01CreateRestoreOrRepair.sql

  Summary:  This script creates a demo database to use in a repair vs restore
			demo.

  Date:     June 2008

  SQL Server Versions:
		10.0.1600.22 (SS2008 RTM)
		9.00.3068.00 (SS2005 SP2+)
------------------------------------------------------------------------------
  Copyright (C) 2008 Paul S. Randal, SQLskills.com
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

-- Create the database and take a full backup

USE master;
GO

IF DATABASEPROPERTY ('DemoRestoreOrRepair', 'Version') > 0
	DROP DATABASE DemoRestoreOrRepair;
GO

CREATE DATABASE DemoRestoreOrRepair;
GO

-- Set the recovery mode to full
ALTER DATABASE DemoRestoreOrRepair SET RECOVERY FULL;
GO

-- Create a table to play with.
CREATE TABLE DemoRestoreOrRepair.dbo.sales (
	salesID INT IDENTITY,
	customerID INT DEFAULT CONVERT (INT, 100000 * RAND ()),
	salesDate DATETIME DEFAULT GETDATE (),
	salesAmount MONEY);

CREATE CLUSTERED INDEX salesCI ON
	DemoRestoreOrRepair.dbo.sales (salesID);
GO

-- Populate the table
SET NOCOUNT ON;
GO

DECLARE @count INT
SELECT @count = 0
WHILE (@count < 5000)
BEGIN
	INSERT INTO DemoRestoreOrRepair.dbo.sales (salesAmount)
		VALUES (100 * RAND ());
	SELECT @count = @count + 1
END;
GO

-- Take a full backup.
BACKUP DATABASE DemoRestoreOrRepair TO
	DISK = 'C:\SQLskills\DemoRestoreOrRepair.bak'
	WITH INIT;
GO
BACKUP LOG DemoRestoreOrRepair TO
	DISK = 'C:\SQLskills\DemoRestoreOrRepair_LOG1.bak'
	WITH INIT;
GO

-- Now shutdown and zero out a page to simulate an IO error
-- Picking page (1, 158) to corrupt
-- Remember to then backup the corrupt database for Part 2
/*
BACKUP DATABASE DemoRestoreOrRepair TO
	DISK = 'C:\SQLskills\CorruptionDemoBackups\CorruptDemoRestoreOrRepair.bak';
	WITH INIT;
GO
*/