/***********************************************************
	
	Demonstrate Hash Index vs. Disk-Based Clustered Index
	** Include execution plan with results **

***********************************************************/
USE AdventureWorks2014;
GO

CHECKPOINT
GO
DBCC DROPCLEANBUFFERS
GO
DBCC FREEPROCCACHE
GO

-- ** Include execution plan with results **
SET STATISTICS IO ON
GO
SET STATISTICS TIME ON
GO

--, CONSTRAINT PK_MODAddress_Address_ID PRIMARY KEY NONCLUSTERED HASH
--(	[AddressID] ) WITH (BUCKET_COUNT=30000)
	SELECT * FROM PERSON.ADDRESS WHERE ADDRESSID = 26007;
	SELECT * FROM MOD.ADDRESS WHERE ADDRESSID = 26007;

-- Demonstrates how a Hash Index will perform poorly in a range index query
SELECT * FROM MOD.ADDRESS WHERE ADDRESSID = 100;
SELECT * FROM MOD.ADDRESS WHERE ADDRESSID BETWEEN 100 AND 26007;
