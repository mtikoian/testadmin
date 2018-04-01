USE AdventureWorks2014;
GO

-- Single point lookup using a Range Index
CHECKPOINT
GO
DBCC DROPCLEANBUFFERS
GO
DBCC FREEPROCCACHE
GO

/***********************************************************
	
	Demonstrate Range Index vs. Disk-Based NonClustered Index Seek
	** Include execution plan with results **

***********************************************************/

SET STATISTICS IO ON
-- Single point lookup. Difference between disk-based vs memory optimized
-- Performance due to the Key Lookup to pull back all other column data
SELECT * FROM [Person].[Address] WHERE ModifiedDate = '2013-12-21';
-- All inmem indexes are covering; therefore, no Key Lookup
SELECT * FROM [MOD].[Address] WHERE ModifiedDate = '2013-12-21';

 
SET STATISTICS IO ON
SET STATISTICS TIME ON
-- Performance almost equal, because the data is returned by the NC Index on the
-- disk-based table. In-memory is not always faster
SELECT ModifiedDate FROM [Person].[Address] WHERE ModifiedDate = '2013-07-31';
SELECT ModifiedDate FROM [MOD].[Address] WHERE ModifiedDate = '2013-07-31';

-- Perform a range query
SELECT * FROM [Person].[Address] WHERE ModifiedDate BETWEEN '2013-12-01' AND '2013-12-21';
-- As expected the memory optimized table performs better
SELECT * FROM [MOD].[Address] WHERE ModifiedDate BETWEEN '2013-12-01' AND '2013-12-21';

-- NonClustered Index in ASC order for our MOD table.
--	, ModifiedDate	DATETIME NOT NULL INDEX [IX_MODAddress_ModifiedDate] NONCLUSTERED

-- Performs Index Seek
SELECT * FROM [MOD].[Address] WHERE ModifiedDate BETWEEN '2013-12-01' AND '2013-12-21' ORDER BY ModifiedDate;
-- Performs Index Seek, but must also sort the data; cannot return the data in opposite order of the index.
SELECT * FROM [MOD].[Address] WHERE ModifiedDate BETWEEN '2013-12-01' AND '2013-12-21' ORDER BY ModifiedDate DESC; -- ASC;

