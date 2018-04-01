USE AdventureWorks2014;
GO 

/********************************************

	Create new Memory Optimized Table

********************************************/

-- Create new schema for the purposes of comparision with disk-based table
	CREATE SCHEMA [MOD] AUTHORIZATION [dbo]; -- Memory Optimized Data
GO

*** Step-1 -- Create Disk-based table

-- DROP TABLE [MOD].[Durable]

 CREATE TABLE [MOD].[Durable]
 (
 	TableID		INT NOT NULL
	, Column1	VARCHAR(24) NOT NULL
	, Column2	VARCHAR(24) NULL
	, Column3	VARCHAR(5000) NULL --< No issue created a table with potential overflow of rowsize 8060 bytes
	, Column4	VARCHAR(5000) NULL --< No issue created a table with potential overflow of rowsize 8060 bytes

) ON [PRIMARY]
GO 	-- No indexes, No PK, Just a Heap








*** Step-2 -- Create Memory Optimized Table

DROP TABLE [MOD].[Durable];
GO

 CREATE TABLE [MOD].[Durable]
 (
 	TableID		INT NOT NULL
	, Column1	VARCHAR(24) NOT NULL
	, Column2	VARCHAR(24) NULL

--< 1. Note the lack of a filegroup
-- By default there is only one memory optimized filegroup; therefore, no need to specify
) WITH(MEMORY_OPTIMIZED=ON, DURABILITY=SCHEMA_AND_DATA);
				-- DURABILITY option NOT mandatory; default is SCHEMA_AND_DATA
GO
-- Received error, because you are forced to have a PK when creating a 













*** Step-3 -- Missing PRIMARY KEY

 CREATE TABLE [MOD].[Durable]
 (
 	TableID		INT NOT NULL PRIMARY KEY --< Add our Primary Key
	, Column1	VARCHAR(24) NOT NULL
	, Column2	VARCHAR(24) NULL

) WITH(MEMORY_OPTIMIZED=ON, DURABILITY=SCHEMA_AND_DATA);
GO















*** Step-4 -- PRIMARY KEY fix; NONCLUSTERED
		   -- Simplest syntax for a DURABLE
		   --	in-memory table.
 CREATE TABLE [MOD].[Durable]
 (
 	TableID		INT NOT NULL PRIMARY KEY NONCLUSTERED
				-- InMemory tables can only have NONCLUSTERED Indexes
				-- By default SQL will try to create a PK as CLUSTERED
	, Column1	VARCHAR(24) NOT NULL
	, Column2	VARCHAR(24) NULL

) WITH(MEMORY_OPTIMIZED=ON, DURABILITY=SCHEMA_AND_DATA);
GO















*** Step-5 -- NonDurable

 CREATE TABLE [MOD].[NonDurable]
 (
 	TableID		INT NOT NULL 
								-- 1) New Inline syntax for SQL2014
	, Column1	VARCHAR(24) NOT NULL INDEX [IX_Column1] ( [Column1] ) 
	, Column2	VARCHAR(24) NULL
	, Column3	VARCHAR(5000) NULL
	, Column4	VARCHAR(5000) NULL

	, INDEX [IX_Column2] ( [Column2] ) -- 2) Can still declare index after columns
		-- 3) NONCLUSTERED	
		--		a. The "NONCLUSTERED" hint is optional, 
		--               unless being defined against the primary key

) WITH(MEMORY_OPTIMIZED=ON, DURABILITY=SCHEMA_ONLY); 
						--< SCHEMA_ONLY option; literally no safety net
						-- Use cases: Staging, Website Session State
GO

















*** Step-6 -- NonDurable; Fix NULLABLE Column

 CREATE TABLE [MOD].[NonDurable]
 (
 	TableID		INT NOT NULL 
	, Column1	VARCHAR(24) NOT NULL INDEX [IX_Column1] ( [Column1] )
	, Column2	VARCHAR(24) NOT NULL --< Fix NULLABLE Column
	, Column3	VARCHAR(3850) NULL --< Fix our row size limitation issues
	, Column4	VARCHAR(3850) NULL --< Fix our row size limitation issues

	, INDEX [IX_Column2] ( [Column2] )
		
) WITH(MEMORY_OPTIMIZED=ON, DURABILITY=SCHEMA_ONLY); 
GO












*** Step-7 -- NonDurable; Fix BIN2 collation
			-- Simplest form of a NonDurable table

 CREATE TABLE [MOD].[NonDurable]
 (
 	TableID		INT NOT NULL 
	-- New BIN2 Collation
	, Column1	VARCHAR(24) COLLATE Latin1_General_100_BIN2 NOT NULL 
				INDEX [IX_Column1] ( [Column1] )
	-- New BIN2 Collation only necessary if in an index
	, Column2	VARCHAR(24) COLLATE Latin1_General_100_BIN2 NOT NULL
	, Column3	VARCHAR(3850) NULL
	, Column4	VARCHAR(3850) NULL

	, INDEX [IX_Column2] ( [Column2] )
		-- The string data type must be defined using a BIN2 collation
				
) WITH(MEMORY_OPTIMIZED=ON, DURABILITY=SCHEMA_ONLY); 
GO




/*  -- Look at our new table in an existing system view
    -- New 2014 columns are available

 select t.name as 'Table Name' 
		, t.schema_id
		, t.object_id
		, filestream_data_space_id
		, is_memory_optimized
		, durability
		, durability_desc
   from sys.tables t
  where type='U'
    and	t.schema_id = SCHEMA_ID(N'MOD');
	
*/


-- Look at our table via SSMS properties


-- Location of the dll files that represent the structure of the table we just created
-- C:\Program Files\Microsoft SQL Server\MSSQL12.SQL2014\MSSQL\DATA
