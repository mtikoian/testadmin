	--Created by: Aaron Buma
	--Website: www.AaronBuma.com
	--Twitter: @AaronDBuma

	RAISERROR ('Dont run the whole script, just run sections at a time', 20, 1)  WITH LOG;
	------------------------ EXAMPLES SETUP ------------------------

	USE Master;
	GO

	IF EXISTS(SELECT name 
			FROM sys.databases 
			WHERE name = 'QueryTraining')
	BEGIN
	ALTER DATABASE [QueryTraining] 
		SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [QueryTraining];
	END
	CREATE DATABASE [QueryTraining];
	GO

	USE [QueryTraining];


	CREATE TABLE [dbo].[Inventory](
	[InventoryID] [INTEGER] IDENTITY(1,1) PRIMARY KEY,
	[Category] [VARCHAR](200), 
	[ItemSKU] [VARCHAR](200),
	[Description] [VARCHAR](4000),
	[QuantityOnHand] [INT],
	[UnitCost] DECIMAL(10,2),
	[UnitRetail] DECIMAL(10,2),
	[Archived] BIT
	); 


	INSERT INTO dbo.Inventory (Category, ItemSKU, Description, QuantityOnHand, UnitCost, UnitRetail, Archived)
	VALUES
	('SLEEPINGBAG', 'SB001-LG-RED', 'Sleeping Bag - Large - RED', 5, 5.75, 19.99, 0),
	('SLEEPINGBAG', 'SB001-LG-GRN', 'Sleeping Bag - Large - GREEN', 13, 5.75, 14.99, 1),
	('SLEEPINGBAG', 'SB001-LG-BLK', 'Sleeping Bag - Large - BLACK', 1, 5.75, 19.99, 0),
	('TENT', 'TT001-10-CMO', 'Tent - 10 Man - CAMO', 5, 10.00, 99.95, 0),
	('AXE', 'AX013-HT-BLK', 'Axe - Hatchet - Black', 35, 4.99, 24.95, 0),
	('FOOD', 'MR005-1S-SPG', 'MRE - 1 Serve - Spaghetti', 5, 0.50, 7.99, 0),
	('FOOD', 'MR006-1A-PIZ', 'MRE - 13', 1, NULL, 99.95, 0);

	---------------------------------------------------------------
	--TOP (N)
	---------------------------------------------------------------

	--All results
	SELECT * 
	  FROM dbo.Inventory AS i;
 
	--TOP 3 without no order by, sorting is up to Query Optimizer 
	SELECT TOP 3 *
	  FROM dbo.Inventory AS i;
 
	--TOP 3 with an order by 
	SELECT TOP 3 *
	  FROM dbo.Inventory AS i
	 ORDER BY i.QuantityOnHand DESC;
 



	--Using a variable, TOP(N)
	--requires ()
	DECLARE @TOP_NUMBER_OF_ROWS INT = 3;

	SELECT TOP (@TOP_NUMBER_OF_ROWS) *
	  FROM dbo.Inventory AS i
	 ORDER BY i.QuantityOnHand DESC;
 

	--SO HOW CAN TOP(2) RETURN MORE THAN 2 ROWS??? ..... "WITH TIES"
	--SELECT TOP 2 WITH TIES [columnA]
	--This will include additional rows that match 2nd row on [columnA]

	--All rows, for review
	SELECT * FROM dbo.Inventory AS i;

	--Only returns one row 
	SELECT TOP 1 i.UnitCost,
		   i.ItemSKU
	  FROM dbo.Inventory AS i
	 WHERE i.Category = 'SLEEPINGBAG'
	 ORDER BY i.UnitCost DESC;



	--Returns all rows that match the highest UnitCost value   
	SELECT TOP 1 WITH TIES i.UnitCost,
		   i.ItemSKU
	  FROM dbo.Inventory AS i
	 WHERE i.Category = 'SLEEPINGBAG'
	 ORDER BY i.UnitCost DESC;
  
  
   
 
	--TOP N PERCENT 
	--N can be any value 0 <= N <= 100
	--N can be a variable with the same constraints 

	--A hardcoded percentage   
	SELECT TOP 0 PERCENT *
	  FROM dbo.Inventory;
   
	SELECT TOP 10 PERCENT *
	  FROM dbo.Inventory;
   
	SELECT TOP 20 PERCENT *
	  FROM dbo.Inventory;

	--As a variable percentage 
	DECLARE @PERCENT_OF_ROWS_TO_SHOW DECIMAL(5,2) = 10;

	SELECT TOP (@PERCENT_OF_ROWS_TO_SHOW) PERCENT *
	  FROM dbo.Inventory;

	GO   
	DECLARE @PERCENT_OF_ROWS_TO_SHOW DECIMAL(5,2) = 45.2;

	SELECT TOP (@PERCENT_OF_ROWS_TO_SHOW) PERCENT *
	  FROM dbo.Inventory;

	--------------------------------------------------------------------
	--USING TOP(N) to perform tasks
	--------------------------------------------------------------------   
	--Can you do an delete top 3?
	BEGIN TRAN

		SELECT * 
		  FROM dbo.Inventory;

		DELETE TOP (3) dbo.Inventory;

		SELECT * 
		  FROM dbo.Inventory;

	ROLLBACK TRAN  
	--YES!, but it's not safe, especially without an ORDER BY
	--It is possible to delete more that N rows 
	--	if the Nth row has duplicates (similar to WITH TIES)






	--Can you do an update top 10?  
	BEGIN TRAN

		UPDATE TOP (3) i
		   SET i.QuantityOnHand = i.QuantityOnHand - 5
		  FROM dbo.Inventory AS i
		 ORDER BY i.QuantityOnHand DESC; 

	ROLLBACK TRAN






 
	--How can you reduce the quantity on hand for the top 3 highest values
	BEGIN TRAN

		SELECT i.ItemSKU, 
			   i.QuantityOnHand
		  FROM dbo.Inventory AS i
		 ORDER BY i.ItemSKU DESC;
	 
		UPDATE i
		   SET i.QuantityOnHand = i.QuantityOnHand - 5
		  FROM dbo.Inventory AS i
		 WHERE i.InventoryID IN (
				SELECT TOP (3) subI.InventoryID
				  FROM dbo.Inventory AS subI
				 ORDER BY subI.QuantityOnHand DESC
			);
		--Generate the list of top 3 candidate ID's as a subquery
		--and join to the update statement on the ID.
	  
		SELECT i.ItemSKU, 
			   i.QuantityOnHand
		  FROM dbo.Inventory AS i
		 ORDER BY i.ItemSKU DESC;

	ROLLBACK TRAN







 
	--If business logic requires it,
	--	can you use WITH TIES?
	BEGIN TRAN

		SELECT i.ItemSKU, 
			   i.QuantityOnHand
		  FROM dbo.Inventory AS i
		 ORDER BY i.ItemSKU DESC;
	 
		UPDATE i
		   SET i.QuantityOnHand = i.QuantityOnHand - 5
		  FROM dbo.Inventory AS i
		 WHERE i.InventoryID IN (
				SELECT TOP (3) WITH TIES subI.InventoryID
				  FROM dbo.Inventory AS subI
				 ORDER BY subI.QuantityOnHand DESC
			);
	  
		SELECT i.ItemSKU, 
			   i.QuantityOnHand
		  FROM dbo.Inventory AS i
		 ORDER BY i.ItemSKU DESC;

	ROLLBACK TRAN
 




	--Slides
	-------------------------------------------------------------------
	--RANK, DENSE_RANK and ROW_NUMBER 
	-------------------------------------------------------------------
	--When a duplicate is encountered, the 'rank' is repeated until the next non-duplicate value,
	--the sequence continues at "the duplicated rank" added to "number of duplicates"   

	SELECT i.ItemSKU,
		   i.UnitRetail,
		   RANK() OVER(ORDER BY i.UnitRetail ASC) AS rankUnitCost
	  FROM dbo.Inventory AS i;
	--Where's the rank 4? 

	--DENSE_RANK, has a sequential rank if duplicates are encountered
	SELECT i.ItemSKU,
		   i.UnitRetail,
		   DENSE_RANK() OVER(ORDER BY i.UnitRetail ASC) AS denseRankUnitCost
	  FROM dbo.Inventory AS i;
	--rank 4 is included 
 
 
 
 
	--Question: How can you get to the items WITH the lowest 5 UnitRetail prices?
	
	SELECT *,
		RANK() OVER(ORDER BY i.UnitRetail ASC) AS rankUnitCost
	FROM dbo.Inventory AS i
	WHERE (RANK() OVER(ORDER BY i.UnitRetail ASC)) <= 5;
	--ERROR!
	--Rank is applied after results are returned, so it can't be used to filter


	--use a sub query
	SELECT * 
	FROM (

			SELECT *,
					RANK() OVER(ORDER BY i.UnitRetail ASC) AS rankUnitCost
			FROM dbo.Inventory AS i

		) subTable
	WHERE subTable.rankUnitCost <= 5;


	--But is using RANK correct?	
   
	SELECT * 
	FROM (

			SELECT *,
					DENSE_RANK() OVER(ORDER BY i.UnitRetail ASC) AS denseRankUnitCost
			FROM dbo.Inventory AS i

		) subTable
	WHERE subTable.denseRankUnitCost <= 5;
	--Since RANK() is not sequential when duplicates exist, it will stop the results early.
	--Using DENSE_RANK will return the correct results because it is sequential with duplicates.
  
 

	--ROW_NUMBER: 
	--Disregards duplicates

	SELECT i.ItemSKU,
		   i.UnitRetail,
		   RANK() OVER(ORDER BY i.UnitRetail ASC) AS rankUnitCost,
		   DENSE_RANK() OVER(ORDER BY i.UnitRetail ASC) AS denseRankUnitCost,
		   ROW_NUMBER() OVER(ORDER BY i.UnitRetail ASC) AS rowUnitCost
	  FROM dbo.Inventory AS i;




	--Slides
	---------------------------------------------------------------------
	--Data Paging with OFFSET and FETCH
	---------------------------------------------------------------------
	--Example methods prior to 2012
  
	-- A combination of using the 'TOP(n)' function
	  SELECT *
		FROM dbo.Inventory AS i
	   ORDER BY i.InventoryID ASC;

	--TO GET ROWS 3 THROUGH 5
	DECLARE @startResultRange INT = 4;
	DECLARE @endResultRange INT = 7;

	  SELECT TOP (@endResultRange - @startResultRange) *
		FROM dbo.Inventory AS i
	   WHERE i.InventoryID NOT IN(
				  SELECT TOP (@startResultRange - 1) i2.InventoryID
					FROM dbo.Inventory AS i2
				   ORDER BY i2.InventoryID ASC)
	   ORDER BY i.InventoryID ASC;
 





	--USING ROW_NUMBER()
	--Requires CTE, Derived table or temp table
	--Which applies a filter to already ranked rows
  
	--Return ALL rows
	  SELECT *
		FROM dbo.Inventory AS i
	   ORDER BY i.InventoryID ASC;
	
	DECLARE @pageSize AS INT = 3;
	DECLARE @pageNum AS INT = 2; 

	--Return Page 2, when each page has 3 rows
	--	ie: Return rows 4-6
	;WITH cteInventory AS 
	( 
	 SELECT i.InventoryID,
			i.category,
			i.itemSku,
			i.Description,
			i.QuantityOnHand,
			i.UnitCost,
			i.UnitRetail,
			i.Archived,
			ROW_NUMBER() OVER (ORDER BY i.InventoryID ASC) AS RowNum
	   FROM dbo.Inventory AS i
	) 
	 SELECT i.InventoryID,
			i.category,
			i.itemSku,
			i.Description,
			i.QuantityOnHand,
			i.UnitCost,
			i.UnitRetail,
			i.Archived
	   FROM cteInventory i
	  WHERE i.RowNum BETWEEN ((@pageNum - 1) * @pageSize + 1) AND (@pageNum * @pageSize)
	  ORDER BY i.RowNum; 



	GO
	--2012 - with OFFSET and FETCH
	--Does not require filtering on an entire result set
	--Much more performant on first page compared to previous methods
	--Noticeably better on after-first-page

	--Return ALL rows
	 SELECT *
	   FROM dbo.Inventory AS i
	  ORDER BY i.InventoryID ASC;
	
	DECLARE @pageSize AS INT = 3;
	DECLARE @pageNum AS INT = 2; 

	--Return Page 2, when each page has 3 rows
	--	ie: Return rows 4-6
	 SELECT i.InventoryID,
			i.category,
			i.itemSku,
			i.Description,
			i.QuantityOnHand,
			i.UnitCost,
			i.UnitRetail,
			i.Archived
	   FROM dbo.Inventory i
	  ORDER BY i.InventoryID ASC
	 OFFSET (@pageNum - 1) * @pageSize ROWS FETCH NEXT @pageSize ROWS ONLY;
	  

    

	--Slides












