USE AdventureWorks2014
go

IF EXISTS ( SELECT * FROM sys.procedures WHERE name='GetBadWolf' )
	DROP PROC GetBadWolf
GO

	CREATE PROC GetBadWolf
		(@Value int)
	AS
	BEGIN
		SELECT *
		INTO #prods
		FROM Purchasing.ProductVendor
	
		UPDATE #prods
		SET standardprice=(standardprice*(100.0+@Value))/100.0
	
		SELECT IncreasedPrice = SUM(standardprice)
		FROM #prods
	END
	GO
