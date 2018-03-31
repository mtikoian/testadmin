IF NOT EXISTS(SELECT * FROM sys.databases WHERE [name] = 'QueryPerformance')
BEGIN
	CREATE DATABASE QueryPerformance;
END;
GO

USE QueryPerformance;
GO

IF OBJECT_ID('dbo.ParameterSniffing') IS NOT NULL DROP PROCEDURE dbo.ParameterSniffing;
GO

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

CREATE PROC dbo.ParameterSniffing
	@OrderQuantity smallint,
	@LogExecutionFlag bit = 1
AS

/********************************************
Return the total count of ResellerSales orders
that had the specified OrderQuantity, and optionally
filtered by Reseller

2014-01-01 gvr Initial creation
********************************************/

SET NOCOUNT ON;
SET ARITHABORT ON;

SELECT COALESCE(SUM(ExtendedAmount), 0) AS TotalAmount
	FROM AdventureWorks2012.dbo.ResellerSales
	WHERE OrderQuantity = @OrderQuantity;
 
GO
