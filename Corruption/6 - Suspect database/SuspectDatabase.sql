/*============================================================================
  File:     SuspectDatabase.sql

  Summary:  This script creates and fixes the
			DemoSuspect database.

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

USE MASTER
GO
DROP DATABASE DemoSuspect
GO
CREATE DATABASE DemoSuspect
GO






-- Create a human resources table
USE DemoSuspect;
GO
CREATE TABLE Employees (
	FirstName    VARCHAR (20),
	LastName     VARCHAR (20),
	YearlyBonus	 INT);
GO












-- With some random data...
INSERT INTO Employees VALUES (
	'Paul', 'Randal', 10000);
INSERT INTO Employees VALUES (
	'Kimberly', 'Tripp', 10000);
GO











-- Simulate an 'oops' transaction
BEGIN TRAN;
UPDATE Employees
	SET YearlyBonus = 0
	WHERE LastName = 'Tripp';
GO
CHECKPOINT;
GO








-- Simulate hardware failure with corruption
-- SHUTDOWN WITH NOWAIT in another window and
-- use a hex editor to whack the log file header









-- after shutdown/corruption/startup

USE DemoSuspect;
GO
















-- Uh-oh - maybe detach/reattach will help
SELECT DATABASEPROPERTYEX (
	'DemoSuspect', 'STATUS');
GO

EXEC sp_detach_db 'DemoSuspect';
GO

SELECT * FROM sys.databases
WHERE NAME = 'DemoSuspect';
GO













-- Try attaching it again
EXEC sp_attach_db @dbname = N'DemoSuspect', 
    @filename1 = N'c:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\DemoSuspect.mdf', 
    @filename2 = N'c:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\DemoSuspect_log.ldf';
GO












-- Ok - try using the ATTACH_REBUILD_LOG command
CREATE DATABASE DemoSuspect ON
    (NAME = DemoSuspect,
	FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\DemoSuspect.mdf')
FOR ATTACH_REBUILD_LOG
GO















-- Ok - try removing the log file and then
-- using the ATTACH_REBUILD_LOG command
CREATE DATABASE DemoSuspect ON
    (NAME = DemoSuspect,
	FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\Data\DemoSuspect.mdf')
FOR ATTACH_REBUILD_LOG
GO











-- Ok - we're going to have to hack it back into the server

-- Create a dummy database, shutdown the server and swap in
-- the corrupt files, restart and it should be there

CREATE DATABASE DemoSuspect;
GO

-- Check the files are there...

SHUTDOWN;
GO







-- Now try using the database
USE DemoSuspect;
GO

SELECT DATABASEPROPERTYEX (
	'DemoSuspect', 'STATUS');
GO






















-- Let's try EMERGENCY mode repair
ALTER DATABASE DemoSuspect SET EMERGENCY;
GO
DBCC CHECKDB (DemoSuspect, REPAIR_ALLOW_DATA_LOSS)
WITH NO_INFOMSGS, ALL_ERRORMSGS;
GO
















-- Ok - single user mode as well
ALTER DATABASE DemoSuspect SET SINGLE_USER;
GO
DBCC CHECKDB (DemoSuspect, REPAIR_ALLOW_DATA_LOSS)
WITH NO_INFOMSGS, ALL_ERRORMSGS;
GO

















-- Now try again...
USE DemoSuspect;
GO

-- Check the state
SELECT DATABASEPROPERTYEX (
	'DemoSuspect', 'STATUS');
GO

-- What about the data?
SELECT * FROM Employees;
GO


