USE AdventureWorks2014;
GO

-- Natively Compiled Stored Procedure Template
CREATE PROCEDURE selAddressModifiedDate_MOD 
(	@BeginModifiedDate DATETIME
	, @EndmodifiedDate DATETIME )
WITH
	NATIVE_COMPILATION
	, SCHEMABINDING
	, EXECUTE AS OWNER
AS
BEGIN ATOMIC
  WITH
 ( TRANSACTION ISOLATION LEVEL = SNAPSHOT
	  , LANGUAGE = 'english')
	  
  SELECT AddressID, AddressLine1
		, AddressLine2, City
		, StateProvinceID, PostalCode
		, rowguid, ModifiedDate 
    FROM [MOD].[Address] 
   WHERE ModifiedDate 
         BETWEEN @BeginModifiedDate AND @EndmodifiedDate;

END;


/*

	EXECUTE dbo.selAddressModifiedDate_MOD '2013-12-01', '2013-12-21'

*/