-- For details please visit https://www.simple-talk.com/sql/database-administration/migrating-disk-based-table-memory-optimized-table-sql-server/

-- Detirmine if the database is MEMORY OPTIMIZED DATA enabled
USE TestDB
GO

SELECT g.name, g.type_desc, f.physical_name 
 FROM sys.filegroups g JOIN sys.database_files f ON g.data_space_id = f.data_space_id 
 WHERE g.type = 'FX' AND f.type = 2


 /*************** Create DB with MEMORY OPTIMIZED DATA enable *****************/
CREATE DATABASE [TestDB]
 ON  PRIMARY 
( NAME = N'TestDB_data', FILENAME = N'C:\DataSQL2016\TestDB_data.mdf'),
 FILEGROUP [TestDBSampleDB_mod_fg] CONTAINS MEMORY_OPTIMIZED_DATA  DEFAULT
( NAME = N'TestDB_mod_dir', FILENAME = N'C:\DataSQL2016\TestDB_mod_dir' , MAXSIZE = UNLIMITED)
 LOG ON 
( NAME = N'TestDBSampleDB_log', FILENAME = N'C:\DataSQL2016\TestDB_log.ldf' )



/*
--In order to enable the MEMORY_OPTIMIZED_DATA option for an existing database, 
--you need to create a filegroup with the MEMORY_OPTIMIZED_DATA option, and then files can be added to the filegoup. 

ALTER DATABASE [TestDB] 
ADD FILEGROUP [TestDBSampleDB_mod_fg] CONTAINS MEMORY_OPTIMIZED_DATA; 

ALTER DATABASE [TestDB] 
ADD FILE (NAME='TestDB_mod_dir', FILENAME='C:\C:\DataSQL2016\TestDB_mod_dir') 
	TO FILEGROUP [TestDBSampleDB_mod_fg];
*/
USE [TestDB]
GO

CREATE TABLE dbo.TEST_Disk(
	ID  int IDENTITY(10000, 1),
	ProductID int NOT NULL,
	OrderQty int NOT NULL,
	SumOrder as ProductID + OrderQty,
	XMLData XML NULL,
	Description varchar(1000) SPARSE,
	StartDate datetime CONSTRAINT DF_TEST_DiskStart DEFAULT getdate() NOT NULL,
	ModifiedDate datetime CONSTRAINT DF_TEST_DiskEnd DEFAULT getdate() NOT NULL,
 CONSTRAINT PK_TEST_Disk_ID PRIMARY KEY CLUSTERED
	(
		ID 
	) 
)

--- PowerShell to verify migration: Save-SqlMigrationReport –FolderPath “C:\Temp” 
/*
The following data types are not supported: 
	datetimeoffset, geography, geometry, hierarchyid, rowversion, xml, sql_variant, 
	all User-Defined Types and all legacy LOB data types (including text, ntext, and image)
*/

/*********************************************************************************************************************/

CREATE TABLE dbo.TEST_Memory(
	ID  int IDENTITY(1, 1),
	ProductID int NOT NULL,
	OrderQty int NOT NULL,
	SumOrder int NULL,
	XMLData nvarchar(MAX) NULL,
	Description varchar(1000) NULL,
	StartDate datetime CONSTRAINT DF_TEST_MemoryStart DEFAULT getdate() NOT NULL,
	ModifiedDate datetime CONSTRAINT DF_TEST_MemoryEnd DEFAULT getdate() NOT NULL,
 CONSTRAINT PK_TEST_Memory_ID PRIMARY KEY NONCLUSTERED HASH
	(
		ID 
	)WITH (BUCKET_COUNT = 1572864) 
) WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )

GO


-- DROP TABLE dbo.TEST_Memory
--Setting the IDENTITY seed to 10,000, but, the memory-optimized table does not support the DBCC command to reset IDENTITY. 
--SET IDENTITY_INSERT TEST_Memory ON will do it for us.

-- 1. Insert dummy row
SET IDENTITY_INSERT TEST_Memory ON
	INSERT TEST_Memory (ID,ProductID, OrderQty, SumOrder)
	SELECT 10000, 1,1,1
SET IDENTITY_INSERT TEST_Memory OFF

-- 2. Remove the record
DELETE TEST_Memory WHERE ID = 10000

-- 3. Verify Current Identity
SELECT TABLE_NAME, IDENT_SEED(TABLE_NAME) AS Seed, IDENT_CURRENT(TABLE_NAME) AS Current_Identity
FROM INFORMATION_SCHEMA.TABLES
WHERE OBJECTPROPERTY(OBJECT_ID(TABLE_NAME), 'TableHasIdentity') = 1
AND TABLE_NAME = 'TEST_Memory'


/************************* Indexing Table **********************/

SELECT object_name(hs.object_id) AS [Object Name],
   i.name as [Index Name],
   hs.total_bucket_count,
   hs.empty_bucket_count,
   (hs.total_bucket_count-hs.empty_bucket_count) * 1.3 as NeededBucked,
   FLOOR(hs.empty_bucket_count*1.0/hs.total_bucket_count * 100) AS [Empty Bucket %],
   hs.avg_chain_length,
   hs.max_chain_length
FROM sys.dm_db_xtp_hash_index_stats AS hs
   JOIN sys.indexes AS i ON hs.object_id=i.object_id AND hs.index_id=i.index_id

/************************************************************************************************************************/
-- determine BUCKET_COUNT. AGV ration about 1.68 per row
;WITH CTE AS
(
SELECT COUNT(DISTINCT ProductID) CntID FROM TEST_Memory
)
SELECT POWER(2,CEILING(LOG(CntID)/LOG(2))) AS [BUCKET COUNT]
FROM CTE

--ALTER TABLE DDL need to be execute to create additional index on the memory-optimized table.
--- Modify BUCKET_COUNT
   ALTER TABLE TEST_Memory  
       ALTER INDEX PK_TEST_Memory_ID  
              REBUILD WITH (BUCKET_COUNT=8388608); 


/*************************************************************************************************************************/

;With ZeroToNine (Digit) As 
(Select 0 As Digit
        Union All
  Select Digit + 1 From ZeroToNine Where Digit < 9),
    OneMillionRows (Number) As (
        Select 
          Number = SixthDigit.Digit  * 100000 
                 + FifthDigit.Digit  *  10000 
                 + FourthDigit.Digit *   1000 
                 + ThirdDigit.Digit  *    100 
                 + SecondDigit.Digit *     10 
                 + FirstDigit.Digit  *      1 
        From
            ZeroToNine As FirstDigit  Cross Join
            ZeroToNine As SecondDigit Cross Join
            ZeroToNine As ThirdDigit  Cross Join
            ZeroToNine As FourthDigit Cross Join
            ZeroToNine As FifthDigit  Cross Join
            ZeroToNine As SixthDigit
)
Select   Number+1 ID,ABS(CHECKSUM(NEWID())) % 50 ProductID, ABS(CHECKSUM(NEWID())) % 55 OrderQty
, (SELECT Number+1 as ProductID,ABS(CHECKSUM(NEWID())) % 50 as OrderQty FROM master.dbo.spt_values as data 
		WHERE type = 'p' and data.number = v.number % 2047 FOR XML AUTO, ELEMENTS, TYPE  ) XMLData
INTO TEST_DataLoad
From OneMillionRows v

/************************************************ Load the tables and compare ******************************************************************/

---- Load disk-based table
SET STATISTICS TIME ON; 
INSERT [dbo].[TEST_Disk] ( ProductID, OrderQty )
select ProductID, OrderQty from TEST_DataLoad
SET STATISTICS TIME OFF; 
 --SQL Server Execution Times:
 --  CPU time = 2140 ms,  elapsed time = 2446 ms.

---- Load the memory-optimized table
SET STATISTICS TIME ON; 
INSERT [dbo].[TEST_Memory](ProductID, OrderQty, SumOrder)
select ProductID, OrderQty,ProductID + OrderQty from TEST_DataLoad
SET STATISTICS TIME OFF; 




/******************************************************************************************************************/

-- Creating UDTT for Natively Compiled Stored Procedure

CREATE TYPE tt_TEST_Memory as TABLE(
	ProductID int NOT NULL,
	OrderQty int NOT NULL,
	XMLData varchar(max) NULL,
	[Description] varchar(1000)   NULL,
	StartDate datetime NOT NULL,
	ModifiedDate datetime NOT NULL,
	INDEX IXNC NONCLUSTERED 
	(
		StartDate ASC   --- must have an index
	)
)
WITH ( MEMORY_OPTIMIZED = ON )

-- Creating Natively Compiled Stored Procedure 

CREATE PROCEDURE [dbo].[usp_NC_Insert_TEST_Memory]
	(@VRT dbo.tt_TEST_Memory READONLY)
WITH NATIVE_COMPILATION, SCHEMABINDING
AS
BEGIN ATOMIC
WITH (TRANSACTION ISOLATION LEVEL=snapshot, LANGUAGE=N'us_english')
	INSERT [dbo].[TEST_Memory] (ProductID, OrderQty, SumOrder, XMLData, Description, StartDate, ModifiedDate)
	SELECT  ProductID, OrderQty, [ProductID]+[OrderQty], XMLData, Description, StartDate, ModifiedDate
	FROM @VRT

END
GO

/******************************************************************************************************************/
DECLARE @IMOT dbo.tt_TEST_Memory 

INSERT @IMOT
select ProductID, OrderQty,  NULL XMLData, NULL Description, getdate() StartDate, getdate() ModifiedDate 
from TEST_DataLoad

SET STATISTICS TIME ON; 
EXEC [dbo].[usp_NC_Insert_TEST_Memory] @IMOT
SET STATISTICS TIME OFF; 

-- DELETE [TEST_Memory]
/******************************************************************************************************************/

CREATE TRIGGER tr_TriggerName
 ON TableName
AFTER INSERT, UPDATE, DELETE 
AS
BEGIN 
/*
The trigger code here
*/
END
GO

--Migrating the trigger to an In-Memory OLTP table

CREATE TRIGGER tr_TriggerName
 ON TableName
 WITH NATIVE_COMPILATION, SCHEMABINDING
AFTER INSERT, UPDATE, DELETE  
AS
BEGIN ATOMIC
WITH (TRANSACTION ISOLATION LEVEL=snapshot, LANGUAGE=N'us_english')
/*
	The trigger code here
*/
END
