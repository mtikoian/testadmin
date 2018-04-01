/*============================================================================
   File: SQLskillsSPConfigureChanged.sql

   Summary: This script reports the time that sp_configure options were
			last changed

   SQL Server Versions:
         2005 RTM onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com
	
  (c) 2011, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/


SET NOCOUNT ON;

-- Create the temp table
--
IF EXISTS (SELECT * FROM msdb.sys.objects WHERE NAME = 'SQLskillsDBCCPage')
DROP TABLE msdb.dbo.SQLskillsDBCCPage;

CREATE TABLE msdb.dbo.SQLskillsDBCCPage (
	[ParentObject] VARCHAR (100),
	[Object]       VARCHAR (100),
	[Field]        VARCHAR (100),
	[VALUE]        VARCHAR (100)); 

DECLARE @hours			INT;
DECLARE @minutes		INT;
DECLARE @seconds		INT;
DECLARE @milliseconds	BIGINT;
DECLARE @LastUpdateTime	DATETIME;
DECLARE @upddate		INT;
DECLARE @updtime		BIGINT;
DECLARE @dbccPageString VARCHAR (200);

-- Build the dynamic SQL
--
SELECT @dbccPageString = 'DBCC PAGE (master, 1, 10, 3) WITH TABLERESULTS, NO_INFOMSGS';

-- Empty out the temp table and insert into it again
--
INSERT INTO msdb.dbo.SQLskillsDBCCPage EXEC (@dbccPageString);

SELECT @updtime = [VALUE] FROM msdb.dbo.SQLskillsDBCCPage
WHERE [Field] = 'cfgupdtime';
SELECT @upddate = [VALUE] FROM msdb.dbo.SQLskillsDBCCPage
WHERE [Field] = 'cfgupddate';

-- Convert updtime to seconds
SELECT @milliseconds = CONVERT (INT, CONVERT (FLOAT, @updtime) * (3 + 1.0/3))
SELECT @updtime = @milliseconds / 1000;

-- Pull out hours, minutes, seconds, milliseconds
SELECT @hours = @updtime / 3600;

SELECT @minutes = (@updtime % 3600) / 60;

SELECT @seconds = @updtime - (@hours * 3600) - (@minutes * 60);

-- Calculate number of milliseconds
SELECT @milliseconds = @milliseconds -
	@seconds * 1000 -
	@minutes * 60 * 1000 -
	@hours * 3600 * 1000;
	
-- No messy conversion code required for the date as SQL Server can do it for us
SELECT @LastUpdateTime = DATEADD (DAY, @upddate, '1900-01-01');

-- And add in the hours, minutes, seconds, and milliseconds
-- There are nicer functions to do this but they don't work in 2005/2008
SELECT @LastUpdateTime = DATEADD (HOUR, @hours, @LastUpdateTime);
SELECT @LastUpdateTime = DATEADD (MINUTE, @minutes, @LastUpdateTime);
SELECT @LastUpdateTime = DATEADD (SECOND, @seconds, @LastUpdateTime);
SELECT @LastUpdateTime = DATEADD (MILLISECOND, @milliseconds, @LastUpdateTime);

SELECT @LastUpdateTime AS 'sp_configure options last updated';

-- Clean up
--
DROP TABLE msdb.dbo.SQLskillsDBCCPage;
GO
