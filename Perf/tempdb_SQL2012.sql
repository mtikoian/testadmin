/*============================================================================
  File:     tempdb_SQL2012.sql

  SQL Server Versions: 2012 onwards
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2013, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/


SELECT @@VERSION;
GO

USE [tempdb];
GO

SELECT 
	[file_id],
	[name],
	[physical_name],
	[size],
	[SizeinMB] = CAST([size] as DECIMAL(38,0))/128.,
	[SpaceUsed] = CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128., 
	[FreeSpace] = (CAST([size] as DECIMAL(38,0))/128) - (CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128.),
	[max_size],
	[growth],
	[is_percent_growth]
FROM [sys].[database_files];

SELECT 
	[database_id],
	[file_id],
	[name],
	[physical_name],
	[size],
	[SizeinMB] = CAST([size] as DECIMAL(38,0))/128.,
	[SpaceUsed] = CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128., 
	[FreeSpace] = (CAST([size] as DECIMAL(38,0))/128) - (CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128.),
	[max_size],
	[growth],
	[is_percent_growth]
FROM [master].[sys].[master_files]
WHERE [database_id] = DB_ID('tempdb');


/*
	Download AdventureWorks database from CodePlex
	http://msftdbprodsamples.codeplex.com/
*/
SELECT 
	[sh].[SalesOrderID],
	[sd].[SalesOrderDetailID],
	[sh].[RevisionNumber],
	[sh].[OrderDate],
	[sh].[DueDate],
	[sh].[ShipDate],
	[sh].[Status],
	[sh].[OnlineOrderFlag],
	[sh].[SalesOrderNumber],
	[sh].[PurchaseOrderNumber],
	[sh].[AccountNumber],
	[sh].[CustomerID],
	[sh].[SalesPersonID],
	[sh].[TerritoryID],
	[sh].[BillToAddressID],
	[sh].[ShipToAddressID],
	[sh].[ShipMethodID],
	[sh].[CreditCardID],
	[sh].[CreditCardApprovalCode],
	[sh].[CurrencyRateID],
	[sh].[SubTotal],
	[sh].[TaxAmt],
	[sh].[Freight],
	[sh].[TotalDue],
	[sh].[Comment],
	[sh].[ModifiedDate],
	[sd].[CarrierTrackingNumber],
	[sd].[OrderQty],
	[sd].[ProductID],
	[sd].[SpecialOfferID],
	[sd].[UnitPrice],
	[sd].[UnitPriceDiscount],
	[sd].[LineTotal],
	[sd].[rowguid]
INTO #tmpSalesInfo
FROM [AdventureWorks2012].[Sales].[SalesOrderHeader] [sh]
LEFT OUTER JOIN [AdventureWorks2012].[Sales].[SalesOrderDetail] [sd] ON [sh].[SalesOrderID] = [sd].[SalesOrderID]
ORDER BY [sd].[SalesOrderDetailID] DESC;
GO


sp_spaceused '#tmpSalesInfo';
GO


USE [tempdb];
GO

SELECT 
	[file_id],
	[name],
	[physical_name],
	[size],
	[SizeinMB] = CAST([size] as DECIMAL(38,0))/128.,
	[SpaceUsed] = CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128., 
	[FreeSpace] = (CAST([size] as DECIMAL(38,0))/128) - (CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128.),
	[max_size],
	[growth],
	[is_percent_growth]
FROM [sys].[database_files];

SELECT 
	[database_id],
	[file_id],
	[name],
	[physical_name],
	[size],
	[SizeinMB] = CAST([size] as DECIMAL(38,0))/128.,
	[SpaceUsed] = CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128., 
	[FreeSpace] = (CAST([size] as DECIMAL(38,0))/128) - (CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128.),
	[max_size],
	[growth],
	[is_percent_growth]
FROM [master].[sys].[master_files]
WHERE [database_id] = DB_ID('tempdb');


/*
	http://blogs.msdn.com/b/ialonso/archive/2012/10/08/inaccurate-values-for-currently-allocated-space-and-available-free-space-in-the-shrink-file-dialog-for-tempdb-only.aspx
*/

SELECT 
	[database_id],
	[file_id],
	[size_on_disk_bytes],
	[SizeOnDiskMB] = ([size_on_disk_bytes]/1024)/1024
FROM [sys].[dm_io_virtual_file_stats] (DB_ID('tempdb'), NULL);



/*
	Note that if you grow the data or log file 
	for any database OTHER than tempdb, the
	change is reflected in master.sys.master_files
*/
USE [AdventureWorks2012];
GO

SELECT 
	[file_id],
	[name],
	[physical_name],
	[size],
	[SizeinMB] = CAST([size] as DECIMAL(38,0))/128.,
	[SpaceUsed] = CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128., 
	[FreeSpace] = (CAST([size] as DECIMAL(38,0))/128) - (CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128.),
	[max_size],
	[growth],
	[is_percent_growth]
FROM [sys].[database_files];

SELECT 
	[database_id],
	[file_id],
	[name],
	[physical_name],
	[size],
	[SizeinMB] = CAST([size] as DECIMAL(38,0))/128.,
	[SpaceUsed] = CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128., 
	[FreeSpace] = (CAST([size] as DECIMAL(38,0))/128) - (CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128.),
	[max_size],
	[growth],
	[is_percent_growth]
FROM [master].[sys].[master_files]
WHERE [database_id] = DB_ID('AdventureWorks2012');



USE [AdventureWorks2012]
GO

INSERT INTO [Sales].[SalesOrderDetail] (
	[SalesOrderID],
    [CarrierTrackingNumber],
    [OrderQty],
    [ProductID],
    [SpecialOfferID],
    [UnitPrice],
    [UnitPriceDiscount],
    [rowguid],
    [ModifiedDate]
	)
SELECT 
	[SalesOrderID],
	[CarrierTrackingNumber],
	[OrderQty],
	[ProductID],
	[SpecialOfferID],
	[UnitPrice],
	[UnitPriceDiscount],
	NEWID(),
	[ModifiedDate]
FROM [Sales].[SalesOrderDetail];


SELECT 
	[file_id],
	[name],
	[physical_name],
	[size],
	[SizeinMB] = CAST([size] as DECIMAL(38,0))/128.,
	[SpaceUsed] = CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128., 
	[FreeSpace] = (CAST([size] as DECIMAL(38,0))/128) - (CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128.),
	[max_size],
	[growth],
	[is_percent_growth]
FROM [sys].[database_files];

SELECT 
	[database_id],
	[file_id],
	[name],
	[physical_name],
	[size],
	[SizeinMB] = CAST([size] as DECIMAL(38,0))/128.,
	[SpaceUsed] = CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128., 
	[FreeSpace] = (CAST([size] as DECIMAL(38,0))/128) - (CAST(FILEPROPERTY([name],'SpaceUsed') AS DECIMAL(38,0))/128.),
	[max_size],
	[growth],
	[is_percent_growth]
FROM [master].[sys].[master_files]
WHERE [database_id] = DB_ID('AdventureWorks2012');


SELECT 
	[database_id],
	[file_id],
	[size_on_disk_bytes],
	[SizeOnDiskMB] = ([size_on_disk_bytes]/1024)/1024
FROM [sys].[dm_io_virtual_file_stats] (DB_ID('AdventureWorks2012'), NULL);


