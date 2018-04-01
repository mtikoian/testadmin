-- Collation when comparing strings declared as BIN2
USE AdventureWorks2014;
GO

-- Initial results
SELECT AddressID, AddressLine1, RowGuid
   FROM [MOD].[Address] 
  WHERE AddressID IN (804, 831);

-- Without Collation specified; BIN2 is case sensitive
SELECT AddressID, AddressLine1, RowGuid
   FROM [MOD].[Address] 
  WHERE AddressID IN (804, 831)
    AND AddressLine1 LIKE '%plaza'; -- '%Plaza'

-- Resuls with collation specified
 SELECT AddressID, AddressLine1, RowGuid
   FROM [MOD].[Address] 
  WHERE AddressID IN (804, 831)
    AND AddressLine1 COLLATE SQL_Latin1_General_CP1_CI_AS LIKE '%plaza'

/*	Table definition for the AddressLine1 column

	, AddressLine1	NVARCHAR(120) COLLATE Latin1_General_100_BIN2 NOT NULL
	, AddressLine2	NVARCHAR(120) NULL		-- Purposely left out collation

*/


/**********************************************************
	ORDER BY AddressLine1
**********************************************************/

-- Prep data
 UPDATE [MOD].[Address]
    SET AddressLine1 = LOWER(AddressLine1)
  WHERE AddressID = 804;


-- Run both queries together for comparison
-- Order BY without collation
 SELECT AddressID, AddressLine1, RowGuid
   FROM [MOD].[Address] 
  WHERE AddressID IN (804, 831)
  ORDER BY AddressLine1 ASC; -- DESC;

-- Order BY with collation
 SELECT AddressID, AddressLine1, RowGuid
   FROM [MOD].[Address] 
  WHERE AddressID IN (804, 831)
  ORDER BY AddressLine1 COLLATE SQL_Latin1_General_CP1_CI_AS ASC; -- DESC;
