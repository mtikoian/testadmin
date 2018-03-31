USE [AdventureWorks2014]
GO

ALTER PROC dbo.GetBadWolf
	(@Value int)
AS
BEGIN
	SELECT
        IncreasedPrice = SUM((standardprice*(100.0+@Value))/100.0)
    FROM
        Purchasing.ProductVendor
END

