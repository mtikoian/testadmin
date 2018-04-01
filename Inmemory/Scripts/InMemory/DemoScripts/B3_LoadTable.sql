-- Step - 3
--	Load our in-memory table

USE AdventureWorks2014;
GO

 SET IDENTITY_INSERT [MOD].[Address] ON;

 INSERT INTO [MOD].[Address]
 (	AddressID, AddressLine1
	, AddressLine2, City
	, StateProvinceID, PostalCode
		--, SpatialLocation
	, rowguid, ModifiedDate  )

 SELECT AddressID
		, AddressLine1
		, AddressLine2
		, City
		, StateProvinceID
		, PostalCode
		--, SpatialLocation
		, rowguid
		, ModifiedDate   
   FROM [Person].[Address];		-- Data from disk-based table for comparison

   SET IDENTITY_INSERT [MOD].[Address] OFF;

  ALTER TABLE [Person].[Address]
   DROP COLUMN Spatiallocation;

   -- Auto update statistics does not work for in-memory tables
   -- After a large update / insert, statistics must be updated manually.
   UPDATE STATISTICS [MOD].[Address] WITH FULLSCAN, NORECOMPUTE;
   GO