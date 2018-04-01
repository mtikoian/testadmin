USE AdventureWorks2014;
GO
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[MOD].[Address]') AND TYPE IN (N'U'))
   DROP TABLE [MOD].[Address];
GO

--IF EXISTS (select * from sys.schemas where schema_id=SCHEMA_ID(N'MOD'))
--	DROP SCHEMA [MOD];
--GO 
 	-- Create new schema for the purposes of comparision with disk-based table
--	CREATE SCHEMA [MOD] AUTHORIZATION [dbo]; -- Memory Optimized Data
--GO

USE AdventureWorks2014;
GO 
 CREATE TABLE [MOD].[Address]
 (	AddressID		INT NOT NULL IDENTITY(1,1)
	, AddressLine1	NVARCHAR(120) COLLATE Latin1_General_100_BIN2 NOT NULL
	, AddressLine2	NVARCHAR(120) NULL		-- Purposely left out collation
	, City			NVARCHAR(60) COLLATE Latin1_General_100_BIN2 NOT NULL
	, StateProvinceID	INT NOT NULL
	, PostalCode	NVARCHAR(30) COLLATE Latin1_General_100_BIN2 NOT NULL
--	, SpatialLocation GEOGRAPHY NULL    Not Supported
												/*** Inline nonclustered index ***/
	, rowguid		UNIQUEIDENTIFIER NOT NULL INDEX [AK_MODAddress_rowguid] NONCLUSTERED 
					CONSTRAINT [DF_MODAddress_rowguid] DEFAULT ( NEWID() )
	, ModifiedDate	DATETIME NOT NULL INDEX [IX_MODAddress_ModifiedDate] NONCLUSTERED
					CONSTRAINT [DF_MODAddress_ModifiedDate] DEFAULT ( GETDATE() )

	, INDEX [IX_MODAddress_AddressLine1_AddressLine2_City_StateProvinceID_PostalCode]
		NONCLUSTERED
	(	[AddressLine1] ASC
--		, [City] ASC
		, [StateProvinceID] ASC
		, [PostalCode] ASC
	)

	, INDEX [IX_MODAddress_City]
		--NONCLUSTERED	1. The "NONCLUSTERED" hint is optional, 
		--               if it is not being defined against the primary key
		--				2. The string data type is defined using a BIN2 collation
		--				3. The column is defined as NOT NULL
	(
		[City] DESC
	)

	, INDEX [IX_MODAddress_StateProvinceID] 
		NONCLUSTERED
	(
		[StateProvinceID] ASC
	)
									-- NONCLUSTERED hint is mandatory here
	, CONSTRAINT PK_MODAddress_Address_ID PRIMARY KEY NONCLUSTERED HASH
	(	[AddressID] ) WITH (BUCKET_COUNT=30000)
) WITH(MEMORY_OPTIMIZED=ON, DURABILITY=SCHEMA_AND_DATA);
GO

CREATE INDEX IX_Address_ModifiedDate 
	ON Person.Address (ModifiedDate);
GO


/*
-- All table and stored procedure DLLs currently
-- loaded in memory on the server.

	SELECT name, description 
	  FROM sys.dm_os_loaded_modules
     WHERE description = 'XTP Native DLL';

*/