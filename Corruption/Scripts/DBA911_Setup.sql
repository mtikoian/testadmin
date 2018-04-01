/*******************************************************************************

DBA 911: Database Corruption
David M Maxwell, December 2013

This is the setup / reset script for the sample databases relevant to this 
presentation.  The sample database files are provided courtesy of Paul Randal and 
SQLSkills.com.  They can be downloaded from: 

http://www.sqlskills.com/blogs/paul/corruption-demo-databases-and-scripts/

Specifically, you want the demo files for the DemoDataPurity and DemoNCIndex 
databases, as well as the script for the RestoreOrRepair demo. You'll use the
script from Paul to create the database, then will need to find a way to corrupt
it. I would recommend the use of a hex editor, or searching Paul's blog for "the 
most dangerous command you can run in SQL Server". Follow the directions carefully.

Run the "DROP BLOCK" commands to clear out databases that are not in the beginning
state for this presentation, if they already exist. Then run the "RESTORE BLOCK" 
commands to set up the appropriate databases for demonstration. 

*******************************************************************************/
USE [master];
GO

/******************************************************************************
**									DROP BLOCK								 **
*******************************************************************************/


IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DemoDataPurity')
BEGIN 
	DROP DATABASE DemoDataPurity
END
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DemoNCIndex')
BEGIN 
	DROP DATABASE DemoNCIndex
END
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DemoRestoreOrRepair')
BEGIN 
	DROP DATABASE DemoRestoreOrRepair
END
GO

/******************************************************************************
**								RESTORE BLOCK								 **
*******************************************************************************/

/* SalesDBData - Restored to illustrate data purity error / fix. */ 

RESTORE DATABASE DemoDataPurity
FROM DISK = 'C:\DBA911\Backups\CorruptDemoDataPurity.bak'
WITH MOVE 'SalesDBData' TO 'C:\DBA911\Data\DemoDataPurity.mdf', 
	 MOVE 'SalesDBLog' TO 'C:\DBA911\Logs\DemoDataPurity_LOG.ldf';
GO


/* SalesDB_NCI - Restored to illustrate nonclustered index corruption and repair. */

RESTORE DATABASE DemoNCIndex 
FROM DISK = 'C:\DBA911\Backups\CorruptDemoNCIndex.bak'
WITH MOVE 'SalesDBData' TO 'C:\DBA911\Data\DemoNCI.mdf',
	 MOVE 'SalesDBLog' TO 'C:\DBA911\Logs\DemoNCILog.ldf'
;
GO


/*	RestoreOrRepair - Restored to illustrate corruption requiring either restore 
	or data loss. (Note - this is for MY setup purposes, since I already created
	the DB - you will want to create your own, following Paul Randal's 
	instructions.
*/

RESTORE DATABASE DemoRestoreOrRepair
FROM DISK = 'C:\DBA911\Backups\DemoRestoreOrRepair.bak'
WITH MOVE 'DemoRestoreOrRepair' TO 'C:\DBA911\Data\DemoRestoreOrRepair.mdf',
	 MOVE 'DemoRestoreOrRepair_log' TO 'C:\DBA911\Logs\DemoRestoreOrRepair_log.LDF';
GO


