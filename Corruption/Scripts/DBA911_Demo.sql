/*******************************************************************************

DBA 911: Database Corruption
David M Maxwell, March 2014

Please see the DBA911_Setup file for the links to download the sample databases
and restore or create them. Demo databases and basis for this code is by Paul 
Randal: http://www.sqlskills.com/blogs/paul. Feel free to download his scripts
and compare them to mine, if you would like to see where I deviate. 

Read through this file, and run the appropriate code as required to demonstrate
the particular concept or technique being shown.

*******************************************************************************/

/*******************************************************************************
**   Demo 1 - [DBCC DBINFO]                                  				  **
*******************************************************************************/
/* 
DBCC DBINFO outputs a ton of information about a datbaase. Of particular
importance are two fields; dbi_dbccFlags indicates data purity checks are
being run on the database when it is = 2, and dbi_dbccLastKnownGood shows
the last time DBCC CHECKDB finished successfully on the database. I recommend
running this command with TABLERESULTS and sending it to a temp table for 
parsing. 
*/

DBCC TRACEON(3604);
GO

DBCC DBINFO(DemoDataPurity) WITH TABLERESULTS;
GO

/* 
Just get the info we want. First, create a temp table to hold the results. 
*/

IF (SELECT OBJECT_ID('tempdb.dbo.#dbinfo')) IS NOT NULL
BEGIN 
	DROP TABLE #dbinfo;
END

CREATE TABLE #dbinfo (
	[ParentObject] nvarchar(128),
	[Object] nvarchar(128),
	[Field] nvarchar(128),
	[Value] nvarchar(max)
	)
;

/* 
Now use INSERT..EXEC to send the results into the temp table. 
*/
INSERT INTO #dbinfo
EXEC ('DBCC DBINFO(DemoDataPurity) WITH TABLERESULTS;');

/* 
Finally, select the results we want from the temp table. 
*/
SELECT [Field], [Value] FROM #dbinfo
WHERE [Field] IN ('dbi_dbccLastKnownGood', 'dbi_dbccFlags');
GO

/* 
DBCC CHECKDB(<database_name>) WITH ESTIMATEONLY will show how much TempDB 
space will be required to run CHECKDB.

This command includes data purity checks by default. Remember that data purity
checks will validate that the values stored in a column that has a valid range
of values, fall within that range.

Also note that in SQL Server 2008 R2 and 2012, there's an estimation bug where
the values it provides can be artificially low for large databases. See: 
http://www.sqlskills.com/blogs/paul/how-does-dbcc-checkdb-with-estimateonly-work/
*/
DBCC CHECKDB(DemoDataPurity) WITH 
	ESTIMATEONLY;
GO

/* 
This time, we turn purity checks off by specifying PHYSICAL_ONLY. Note that
this requires less space in tempdb, because CHECKDB has less work to do. 
Remember that PHYSICAL_ONLY and DATA_PURITY are mutually exclusive. if you 
use both options in the command, you'll get PHYSICAL_ONLY.

PHYSICAL_ONLY just reads the data pages off the disk to ensure that they can
be read. Nothing more.
*/
DBCC CHECKDB(DemoDataPurity) WITH 
	PHYSICAL_ONLY,
	ESTIMATEONLY;
GO

/* Here are a few more options for CHECKDB that you should be aware of.
   I will not run these as part of my demos below. As always, you can check the 
   Books Online entry for CHECKDB for more details. 
   (http://technet.microsoft.com/en-us/library/ms176064.aspx) */
DBCC CHECKDB(master) 
	-- WITH 
	-- NO_INFOMSGS 
		/* Suppresses success messages for objects. Not default. */
	--,ALL_ERRORMSGS 
		/* Ensures all error messages are displayed. Default. (Remember SSMS Limits!) */
	--,EXTENDED_LOGICAL_CHECKS 
		/* XML indexes, Spatial indexes, indexed views... Not default. */
;		
GO


/*******************************************************************************
**   Demo 2 -  [DemoDataPurity] - Data Purity								  **
*******************************************************************************/
/* 
We receive a call from the web applications team that the website is 
not displaying a certain product correctly. When trying to browse the bike
frames for sale, the site crashes with an unknown error. The query provided 
is:
*/

SELECT Name, cast(Price as money)
FROM DemoDataPurity.dbo.Products
WHERE name LIKE 'LL Road Frame %'
ORDER BY ProductID;
GO

/* 
Since the error is an Arithmetic Overflow error, corruption is a likely 
suspect. Let's run a consistency check. 
*/

DBCC CHECKDB(DemoDataPurity) WITH 
	NO_INFOMSGS;
GO

/* 
The error indicates that a value in the [price] column is either too high or 
too low of a value for that column. Note that CHECKDB does not indicate a 
repair level, in this case, because this is a Data Purity error. SQL Server 
would not know what repairs to make, since it doesn't know what the data 
should be.

We'll begin by taking a tail log backup, so we have a place to recover from, 
just in case. This is good policy for any corruption situation, regardless of 
the type. 
*/

BACKUP LOG DemoDataPurity
TO DISK = 'C:\DBA911\Backups\DemoDataPurity_BeforeRepair.trn'
WITH CHECKSUM, NO_TRUNCATE, INIT, FORMAT;
GO

USE DemoDataPurity; 
GO

/*	
Now let's check the rest of the page and see if we can identify which record
is causing us the trouble. To do this, we'll use DBCC PAGE, one of the most
useful commands in SQL Server. It will read any accessible page, in any file
within SQL 

Note that it will return errors and mark pages as suspect if you use it on 
log files. It wasn't built for that. (It does *not* damage them.)

DBCC PAGE, by default, outputs to the error log.  We need to turn on trace
flag 3604 to get it to output to the console. 
*/

DBCC TRACEON(3604);
GO

DBCC PAGE ('DemoDataPurity',1,24473,3);  /* Style 3 - All Headers, Hex, and Details. */
GO

/* 	
If we search the results for "Slot 91" we see that the record in question is 
for the part "LL Road Frame - Black, 52".  Armed with this information we 
go to our sales department and ask what the price for that part should be.
Our sales department tells us that the proper cost for this item is $337.22. 
All we need to do now is update the offending record. 
*/

UPDATE Products
SET Price = 337.22
WHERE ProductID = 243;
GO

/*	
If we want to, we can run that same DBCC PAGE command to verify that the 
record was correctly updated. (Besides, it's fun.)
*/

DBCC PAGE ('DemoDataPurity',1,24473,3);
GO

/*	
Again, we can search for "Slot 91" and see that SQL Server is now displaying
valid data for that particular column.

Finally, we run our CHECKDB again to verify that there are no further issues 
in the database. It's usually a good idea to run CHECKDB both before and
after altering a database in a way that fixes corruption. Just to be safe.
*/

DBCC CHECKDB(DemoDataPurity) WITH 
	NO_INFOMSGS;
GO

/*	
Finally, another log backup, so that we have a clean point to restore to
in the future, if need be. 
*/
BACKUP LOG DemoDataPurity
TO DISK = 'C:\DBA911\Backups\DemoDataPurity_AfterRepair.trn'
WITH CHECKSUM, INIT, FORMAT;
GO

/* Let's test our reporting query now. */
SELECT Name, cast(Price as money)
FROM DemoDataPurity.dbo.Products
WHERE name LIKE 'LL Road Frame %'
ORDER BY ProductID;
GO



/*******************************************************************************
**   Demo 3 - [DemoNCIndex]  NonClustered Index corruption   				  **
*******************************************************************************/
/*  
We've just restored a database from another server to use it in a test environment. 
Let's run a consistency check on it. This time, we're going to do it with 
TABLERESULTS. You'll see why in a minute.
*/
DBCC CHECKDB(DemoNCIndex) WITH 
  	NO_INFOMSGS
   ,TABLERESULTS
;
GO

/*	
Lots more errors this time.  Also note that this time, we have a repair suggestion. 

There are three repair levels available with CHECKDB: 

	- Repair_Fast - Does nothing. Literally nothing. 

	- Repair_Rebuild - Fixes errors in nonclustered indexes only. No risk
	  of data loss.

	- Repair_Allow_Data_Loss - just what it says on the label. 
	  Repair_Allow_Data_Loss will delete whatever *it* wants to delete in 
	  order to make the database consistent. Keep that in mind when 
	  designing your recovery strategy.


CHECKDB tells us the minimum repair level is repair_rebuild.  Since this is a 
nonclustered index, and therefore redundant data, that's what we're going to do.  

As further validation, note that by using TABLERESULTS we can visually scan 
down the index ID column and see that all of the corruption errors are on 
index ID 2 - which is a nonclustered index. (0 would be a heap, and 1 would be
the clustered index.)

In most cases, it's usually easier, faster and less intrusive to just rebuild 
the index. Especially in the case of a nonclustered index. In this particular 
case, we want to illustrate exactly what CHECKDB does when it fixes corruption 
in a nonclustered index. 

First, and always, we take a tail log backup. 
*/
BACKUP LOG DemoNCIndex
TO DISK = 'C:\DBA911\Backups\DemoNCIndex_BeforeRepair.trn'
WITH CHECKSUM, INIT, FORMAT, NO_TRUNCATE;
GO

/* 
Now that we have a backup, we need to put the database in single user mode so we 
can run a repair. If the database is not in single user mode when we try to run
the repair, we'll get an error.
*/

ALTER DATABASE DemoNCIndex
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

/* 
Now we can run CHECKDB using the repair_rebuild option.
*/
DBCC CHECKDB (DemoNCIndex, repair_rebuild)
WITH NO_INFOMSGS;
GO

/* 
Notice that in the resulting output, we now get additional lines with our error
messages, stating that the errors have been repaired. The Repair_Rebuild option 
will make changes in the nonclustered index so that it matches up with the 
clustered index. The output doesn't say it actually rebuilt the index, but rather 
that it inserted or deleted rows where necessary to match the clustered index.

With the summary info at the end of the operation, we also get lines stating how 
many errors were fixed, as well as found. The numbers match, so we know that all
the errors were fixed. 

Let's take another log backup.
*/
BACKUP LOG DemoNCIndex
TO DISK = 'C:\DBA911\Backups\DemoNCIndex_AfterRepair.trn'
WITH CHECKSUM, INIT, FORMAT;
GO

/* 
Any time we run a repair of a database, we always want to run another CHECKDB, 
just in case any further errors were introduced as a result of the repair. 
*/
DBCC CHECKDB(DemoNCIndex) WITH 
	NO_INFOMSGS;
GO

/* 
Once the results come back clean, we can set the database back to multi-user, 
and move on. 
*/

ALTER DATABASE DemoNCIndex
SET MULTI_USER;
GO



/*******************************************************************************
**   Demo 4 - [DemoRepairOrRestore]  Page corruption and single page restore. **
*******************************************************************************/
/* 
A report developer is trying to get a count of the total sales records, and the
sum of their amounts for the entire sales period. Here's the query that they 
wrote to do so.  
*/
SELECT Records = COUNT(*), TotalSales = SUM(salesAmount)
FROM DemoRestoreOrRepair.dbo.Sales;
GO

/* 
Ouch - that looked like it hurt. This time, the error is very descriptive, and
tells us exactly what happened. The page checksum no longer matches the data on 
the actual page. Something has changed that page while SQL Server wasn't looking.
We also get some advice on where to look for additional informatin and what
steps to take next. Let's follow the advice and run a full consistency check. 
*/
DBCC CHECKDB (DemoRestoreOrRepair) WITH 
	NO_INFOMSGS;
GO

/* 
Now things are getting more interesting.  This error states that the PageID in 
the header of page 1:284 is incorrect.  Let's try looking at that page using the 
same DBCC PAGE command that we used earlier.  (Making sure that TF3604 is turned
on so we get the output to the console, rather than the error log.)
*/
DBCC TRACEON(3604);
GO

DBCC PAGE('DemoRestoreOrRepair',1,284,3);
GO

/* 
Since the page *type* is also zeroed, DBCC PAGE can't figure out how to interpret the 
page data like it did before. We'll do a hex dump of the page instead, to see
exactly what the data looks like on disk.
*/
DBCC PAGE('DemoRestoreOrRepair',1,284,2); /* Style 2 - Page header and hex only. */
GO

/* 
Yep - the whole page is nothing but 0's, indicating an IO error of some kind. 
Using the suspect_pages table in MSDB, we can see if any other pages have been 
marked as suspect per the last time they were read.
*/
SELECT * FROM msdb.dbo.suspect_pages;
GO

/* 
That's the only suspect page, so we can fix this with a single-page restore. 

Requirements for a single-page restore:
	* Enterprise Edition of SQL Server.  (In 2014?)
	* Database in FULL recovery model.
	* Tail log backup.

We'll start by taking the required tail-log backup.
*/
BACKUP LOG DemoRestoreOrRepair 
TO DISK = 'C:\DBA911\Backups\DemoRestoreOrRepair_TailLog.trn'
WITH NO_TRUNCATE, INIT, FORMAT;
GO

/* 
Now we start the restore, only restoring the single page from the full backup, 
then adding each log backup.  Note that we're using the NORECOVERY option with 
every restore to make sure we don't prematurely end the restore process. 
*/
RESTORE DATABASE DemoRestoreOrRepair PAGE = '1:284'
FROM DISK = 'C:\DBA911\Backups\DemoRestoreOrRepair.bak'
WITH NORECOVERY;
GO

/* 
Now restore the tail log backup we just took. Any transactions that affected
the page we just restored will now be applied to the database, making it 
transactionally consistent.
*/
RESTORE LOG DemoRestoreOrRepair
FROM DISK = 'C:\DBA911\Backups\DemoRestoreOrRepair_TailLog.trn'
WITH NORECOVERY;
GO

/* 
Now that the restore is complete, we can run through crash recovery, rolling
the committed transactions forward, and the uncommitted transactions back. 
*/
RESTORE DATABASE DemoRestoreOrRepair
WITH RECOVERY;
GO

/* 
So how does the page look now? 
*/
DBCC PAGE('DemoRestoreOrRepair',1,284,3);
GO

/* 
Excellent. Our data has returned. And just to be on the safe side, we run
another consistency check. 
*/
DBCC CHECKDB (DemoRestoreOrRepair) WITH 
	NO_INFOMSGS;
GO

/* 
Now the developer can successfully run their query.  
*/
SELECT Records = COUNT(*), TotalSales = SUM(salesAmount)
FROM DemoRestoreOrRepair.dbo.Sales;
GO


/* 
But... what would have happened if we had *not* been able to do our single-page
restore?
*/

/*******************************************************************************
**   Demo 5 - [RepairOrRestore]  Page corruption and repair_allow_data_loss.  **
*******************************************************************************/
/* 
First, we need to bring back our corrupted database. 
*/
RESTORE DATABASE DemoRestoreOrRepair
FROM DISK = 'C:\DBA911\Backups\CorruptDemoRestoreOrRepair.bak'
WITH REPLACE;
GO

/* 
Let's say we didn't have a valid backup to restore from, or that backup was lost 
or corrupt, or that we're in SIMPLE recovery mode, or...? We would be confronted
with a situation requiring a repair.  Let's see what happens. 
*/
DBCC CHECKDB (DemoRestoreOrRepair) WITH 
	NO_INFOMSGS;
GO

/* 
Note that the output clearly indicates that repair_allow_data_loss is the 
only option available to us. CHECKDB is saying, "I can fix this, but I'm going
to have to delete something in order to do it, and you may not like what I 
choose to delete."

Again, single-user mode is required to run a repair statement.
*/
ALTER DATABASE DemoRestoreOrRepair
SET SINGLE_USER;
GO

/* 
Now run the repair statement and evaluate the output. 
*/
DBCC CHECKDB (DemoRestoreOrRepair, repair_allow_data_loss) WITH 
	NO_INFOMSGS;
GO

/* 
The repair completed. The output clearly states that the corrupted page was 
'deallocated' from the database, and that the clustered index was rebuilt. 
CHECKDB removed that page from the database, along with anything that was on it,
and rebuilt the clustered index, making sure that all the remaining pages were
properly linked.

Now we run CHECKDB again, to make sure nothing else was damaged or requires 
additional repair. 
*/
DBCC CHECKDB (DemoRestoreOrRepair) WITH 
	NO_INFOMSGS;
GO

/* 
A clean return. But what happened to our data? Before we turn this back over
to the end users, let's check the data ourselves. We'll place the database in 
RESTRICTED user mode, so that only administrators and those with db_owner access
can get in.
*/
ALTER DATABASE DemoRestoreOrRepair
SET RESTRICTED_USER;
GO

SELECT Records = COUNT(*), TotalSales = SUM(salesAmount)
FROM DemoRestoreOrRepair.dbo.Sales;
GO

/* 
Our results are different, indicating that we lost records. That's why they 
call it repair_allow_data_loss. :-)

So here is what I would consider the major takeaways from this presentation. 

* Work with your business people to have a plan in the event of corruption. 
* Check for corruption consistently. 
* Take the backups you need to be able to do the restore you want. 
* Practice your backups, and your corruption plans, regularly. 

*/