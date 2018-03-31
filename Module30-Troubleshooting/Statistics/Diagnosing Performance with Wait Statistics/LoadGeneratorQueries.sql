-- Queries used for Load generator
SELECT 	*
FROM [dbo].[FactInternetSales] with(tablock);

Update  [dbo].[FactInternetSales] 
Set OrderQuantity = OrderQuantity + 1;

ALTER INDEX ALL On dbo.FactResellerSales REBUILD
	With  (ONLINE = On,
	MAXDOP = 8,
	SORT_IN_TEMPDB = ON);

Select * INTO #FISR
From dbo.FactInternetSalesReason, dbo.FactFinance;

Drop Table #FISR;
