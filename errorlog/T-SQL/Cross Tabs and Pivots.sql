/**********************************************************************************************************************
 Cross Tabs and Pivots, Part 1 - Converting Rows to Columns
 Written by: Jeff Moden - July 2008
 Purpose:    The purpose of this article is to provide an introduction to Cross Tabs and Pivots and how they can be 
             used to "rotate" data.  This is the code from the article.
**********************************************************************************************************************/
--=====================================================================================================================
--      A simple introduction to Cross Tabs: (2000 - 2005)
--=====================================================================================================================
--===== Sample data #1 (#SomeTable1)
--===== Create a test table and some data 
 CREATE TABLE #SomeTable1
        (
        Year    SMALLINT,
        Quarter TINYINT, 
        Amount  DECIMAL(2,1)
        )
GO
 INSERT INTO #SomeTable1 
        (Year, Quarter, Amount)
 SELECT 2006, 1, 1.1 UNION ALL
 SELECT 2006, 2, 1.2 UNION ALL
 SELECT 2006, 3, 1.3 UNION ALL
 SELECT 2006, 4, 1.4 UNION ALL
 SELECT 2007, 1, 2.1 UNION ALL
 SELECT 2007, 2, 2.2 UNION ALL
 SELECT 2007, 3, 2.3 UNION ALL
 SELECT 2007, 4, 2.4 UNION ALL
 SELECT 2008, 1, 1.5 UNION ALL
 SELECT 2008, 3, 2.3 UNION ALL
 SELECT 2008, 4, 1.9
GO
-----------------------------------------------------------------------------------------------------------------------
/*====== Desired results
Year   1st Qtr 2nd Qtr 3rd Qtr 4th Qtr Total 
------ ------- ------- ------- ------- ----- 
2006     1.1     1.2     1.3     1.4     5.0
2007     2.1     2.2     2.3     2.4     9.0
2008     1.5     0.0     2.3     1.9     5.7
*/
-----------------------------------------------------------------------------------------------------------------------
--===== The KEY to Cross Tabs!

--===== Simple sum/total for each year
 SELECT Year,
        SUM(Amount) AS Total
   FROM #SomeTable1
  GROUP BY Year
  ORDER BY Year

/*===== Above code produces the following...
Year   Total                                    
------ ---------------------------------------- 
2006   5.0
2007   9.0
2008   5.7
*/
--===== Each quarter is just like the total except it has a CASE
     -- statement to isolate the amount for each quarter.
 SELECT Year,
        SUM(CASE WHEN Quarter = 1 THEN Amount ELSE 0 END) AS [1st Qtr],
        SUM(CASE WHEN Quarter = 2 THEN Amount ELSE 0 END) AS [2nd Qtr],
        SUM(CASE WHEN Quarter = 3 THEN Amount ELSE 0 END) AS [3rd Qtr],
        SUM(CASE WHEN Quarter = 4 THEN Amount ELSE 0 END) AS [4th Qtr],
        SUM(Amount) AS Total
   FROM #SomeTable1
  GROUP BY Year

--===== We can use the STR function to right justify data and make it prettier.
     -- Note that this should really be done by the GUI or Reporting Tool and
     -- not in T-SQL.
 SELECT Year,
        STR(SUM(CASE WHEN Quarter = 1 THEN Amount ELSE 0 END),5,1) AS [1st Qtr],
        STR(SUM(CASE WHEN Quarter = 2 THEN Amount ELSE 0 END),5,1) AS [2nd Qtr],
        STR(SUM(CASE WHEN Quarter = 3 THEN Amount ELSE 0 END),5,1) AS [3rd Qtr],
        STR(SUM(CASE WHEN Quarter = 4 THEN Amount ELSE 0 END),5,1) AS [4th Qtr],
        STR(SUM(Amount),5,1) AS Total
   FROM #SomeTable1
  GROUP BY Year 

--=====================================================================================================================
--      A simple introduction to Pivots: (2005)
--=====================================================================================================================
--===== Use a Pivot to do the same thing we did with the Cross Tab
 SELECT Year,             --(4)
        [1] AS [1st Qtr], --(3)
        [2] AS [2nd Qtr],
        [3] AS [3rd Qtr],
        [4] AS [4th Qtr],
        [1]+[2]+[3]+[4] AS Total --(5)
   FROM (SELECT Year, Quarter,Amount FROM #SomeTable1)  AS src --(1)
  PIVOT (SUM(Amount) FOR Quarter IN ([1],[2],[3],[4])) AS pvt --(2)
  ORDER BY Year

--===== Converting NULLs to zero's in the Pivot using COALESCE
 SELECT Year, 
        COALESCE([1],0) AS [1st Qtr],
        COALESCE([2],0) AS [2nd Qtr],
        COALESCE([3],0) AS [3rd Qtr],
        COALESCE([4],0) AS [4th Qtr],
        COALESCE([1],0) + COALESCE([2] ,0) + COALESCE([3],0) + COALESCE([4],0) AS Total
   FROM (SELECT Year, Quarter,Amount FROM #SomeTable1)  AS src 
  PIVOT (SUM(Amount) FOR Quarter IN ([1],[2],[3],[4])) AS pvt 
  ORDER BY Year

--=====================================================================================================================
--      Readability comparison... (without right justification code)
--=====================================================================================================================
--===== The Cross Tab example 
 SELECT Year,
        SUM(CASE WHEN Quarter = 1 THEN Amount ELSE 0 END) AS [1st Qtr],
        SUM(CASE WHEN Quarter = 2 THEN Amount ELSE 0 END) AS [2nd Qtr],
        SUM(CASE WHEN Quarter = 3 THEN Amount ELSE 0 END) AS [3rd Qtr],
        SUM(CASE WHEN Quarter = 4 THEN Amount ELSE 0 END) AS [4th Qtr],
        SUM(Amount) AS Total
   FROM #SomeTable1
  GROUP BY Year

--===== The Pivot Example
 SELECT Year, 
        COALESCE([1],0) AS [1st Qtr],
        COALESCE([2],0) AS [2nd Qtr],
        COALESCE([3],0) AS [3rd Qtr],
        COALESCE([4],0) AS [4th Qtr],
        COALESCE([1],0) + COALESCE([2] ,0) + COALESCE([3],0) + COALESCE([4],0) AS Total
   FROM (SELECT Year, Quarter,Amount FROM #SomeTable1)  AS src 
  PIVOT (SUM(Amount) FOR Quarter IN ([1],[2],[3],[4])) AS pvt 
  ORDER BY Year

--=====================================================================================================================
--      Multiple Aggregations In a Cross Tab (or, "The Problem with Pivots")
--=====================================================================================================================
/*===== Desired result
Company Year   Q1Amt Q1Qty Q2Amt Q2Qty Q3Amt Q3Qty Q4Amt Q4Qty TotalAmt TotalQty
------- ------ ----- ----- ----- ----- ----- ----- ----- ----- -------- --------
ABC     2006   1.1   2.2   1.2   2.4   1.3   1.3   1.4   4.2   5.0      10.1
ABC     2007   2.1   2.3   2.2   3.1   2.3   2.1   2.4   1.5   9.0      9.0
ABC     2008   1.5   5.1   0.0   0.0   2.3   3.3   1.9   4.2   5.7      12.6
XYZ     2006   2.1   3.6   2.2   1.8   3.3   2.6   2.4   3.7   10.0     11.7
XYZ     2007   3.1   1.9   1.2   1.2   3.3   4.2   1.4   4.0   9.0      11.3
XYZ     2008   2.5   3.9   3.5   2.1   1.3   3.9   3.9   3.4   11.2     13.3
*/

--===== Sample data #2 (#SomeTable2)
--===== Create a test table and some data 
 CREATE TABLE #SomeTable2
        (
        Company  VARCHAR(3),
        Year     SMALLINT,
        Quarter  TINYINT, 
        Amount   DECIMAL(2,1),
        Quantity DECIMAL(2,1)
        )
GO
 INSERT INTO #SomeTable2
        (Company,Year, Quarter, Amount, Quantity)
 SELECT 'ABC', 2006, 1, 1.1, 2.2 UNION ALL
 SELECT 'ABC', 2006, 2, 1.2, 2.4 UNION ALL
 SELECT 'ABC', 2006, 3, 1.3, 1.3 UNION ALL
 SELECT 'ABC', 2006, 4, 1.4, 4.2 UNION ALL
 SELECT 'ABC', 2007, 1, 2.1, 2.3 UNION ALL
 SELECT 'ABC', 2007, 2, 2.2, 3.1 UNION ALL
 SELECT 'ABC', 2007, 3, 2.3, 2.1 UNION ALL
 SELECT 'ABC', 2007, 4, 2.4, 1.5 UNION ALL
 SELECT 'ABC', 2008, 1, 1.5, 5.1 UNION ALL
 SELECT 'ABC', 2008, 3, 2.3, 3.3 UNION ALL
 SELECT 'ABC', 2008, 4, 1.9, 4.2 UNION ALL
 SELECT 'XYZ', 2006, 1, 2.1, 3.6 UNION ALL
 SELECT 'XYZ', 2006, 2, 2.2, 1.8 UNION ALL
 SELECT 'XYZ', 2006, 3, 3.3, 2.6 UNION ALL
 SELECT 'XYZ', 2006, 4, 2.4, 3.7 UNION ALL
 SELECT 'XYZ', 2007, 1, 3.1, 1.9 UNION ALL
 SELECT 'XYZ', 2007, 2, 1.2, 1.2 UNION ALL
 SELECT 'XYZ', 2007, 3, 3.3, 4.2 UNION ALL
 SELECT 'XYZ', 2007, 4, 1.4, 4.0 UNION ALL
 SELECT 'XYZ', 2008, 1, 2.5, 3.9 UNION ALL
 SELECT 'XYZ', 2008, 2, 3.5, 2.1 UNION ALL 
 SELECT 'XYZ', 2008, 3, 1.3, 3.9 UNION ALL
 SELECT 'XYZ', 2008, 4, 3.9, 3.4
GO
--===== The "Problem with Pivots" is you need to do one Pivot for each aggregate.
     -- This code Pivots the Amt and Qty values by quarter.
 SELECT amt.Company,
        amt.Year,
        COALESCE(amt.[1],0) AS Q1Amt,
        COALESCE(qty.[1],0) AS Q1Qty,
        COALESCE(amt.[2],0) AS Q2Amt,
        COALESCE(qty.[2],0) AS Q2Qty,
        COALESCE(amt.[3],0) AS Q3Amt,
        COALESCE(qty.[3],0) AS Q3Qty,
        COALESCE(amt.[4],0) AS Q4Amt,
        COALESCE(qty.[4],0) AS Q4Qty,
        COALESCE(amt.[1],0)+COALESCE(amt.[2],0)+COALESCE(amt.[3],0)+COALESCE(amt.[4],0) AS TotalAmt,
        COALESCE(qty.[1],0)+COALESCE(qty.[2],0)+COALESCE(qty.[3],0)+COALESCE(qty.[4],0) AS TotalQty
   FROM (SELECT Company, Year, Quarter, Amount FROM #SomeTable2) t1
        PIVOT (SUM(Amount) FOR Quarter IN ([1], [2], [3], [4])) AS amt
  INNER JOIN 
        (SELECT Company, Year, Quarter, Quantity FROM #SomeTable2) t2
        PIVOT (SUM(Quantity) FOR Quarter IN ([1], [2], [3], [4])) AS qty
     ON qty.Company = amt.Company 
    AND qty.Year    = amt.Year         
  ORDER BY amt.Company, amt.Year

--===== Doing multiple aggregations in Cross Tabs is as simple as CPR
     -- (CPR = Cut, Paste, Replace). AND, the table is "dipped" only
     -- once instead of twice so there are NO JOINS to worry about!
 SELECT Company,
        Year,
        SUM(CASE WHEN Quarter = 1 THEN Amount   ELSE 0 END) AS Q1Amt,
        SUM(CASE WHEN Quarter = 1 THEN Quantity ELSE 0 END) AS Q1Qty,
        SUM(CASE WHEN Quarter = 2 THEN Amount   ELSE 0 END) AS Q2Amt,
        SUM(CASE WHEN Quarter = 2 THEN Quantity ELSE 0 END) AS Q2Qty,
        SUM(CASE WHEN Quarter = 3 THEN Amount   ELSE 0 END) AS Q3Amt,
        SUM(CASE WHEN Quarter = 3 THEN Quantity ELSE 0 END) AS Q3Qty,
        SUM(CASE WHEN Quarter = 4 THEN Amount   ELSE 0 END) AS Q4Amt,
        SUM(CASE WHEN Quarter = 4 THEN Quantity ELSE 0 END) AS Q4Qty,
        SUM(Amount)   AS TotalAmt,
        SUM(Quantity) AS TotalQty
   FROM #SomeTable2
  GROUP BY Company, Year
  ORDER BY Company, Year

--=====================================================================================================================
--      Pre-aggregation and Performance
--=====================================================================================================================
--===== Create and populate a 1,000,000 row test table.
     -- Column "RowNum" has a range of 1 to 1,000,000 unique numbers
     -- Column "Company" has a range of "AAA" to "BBB" non-unique 3 character strings
     -- Column "Amount has a range of 0.0000 to 9999.9900 non-unique numbers
     -- Column "Quantity" has a range of 1 to 50,000 non-unique numbers
     -- Column "Date" has a range of  >=01/01/2000 and <01/01/2010 non-unique date/times
     -- Columns Year and Quarter are the similarly named components of Date
     -- Jeff Moden
 SELECT TOP 1000000 --<<Look!  Change this number for testing different size tables
        RowNum       = IDENTITY(INT,1,1),
        Company      = CHAR(ABS(CHECKSUM(NEWID()))%2+65)
                     + CHAR(ABS(CHECKSUM(NEWID()))%2+65)
                     + CHAR(ABS(CHECKSUM(NEWID()))%2+65),
        Amount       = CAST(ABS(CHECKSUM(NEWID()))%1000000/100.0 AS MONEY),
        Quantity     = ABS(CHECKSUM(NEWID()))%50000+1,
        Date         = CAST(RAND(CHECKSUM(NEWID()))*3653.0+36524.0 AS DATETIME),
        Year         = CAST(NULL AS SMALLINT),
        Quarter      = CAST(NULL AS TINYINT)
   INTO #SomeTable3
   FROM Master.sys.SysColumns t1
  CROSS JOIN
        Master.sys.SysColumns t2 

--===== Fill in the Year and Quarter columns from the Date column
 UPDATE #SomeTable3
    SET Year    = DATEPART(yy,Date),
        Quarter = DATEPART(qq,Date)

--===== A table is not properly formed unless a Primary Key has been assigned
     -- Takes about 1 second to execute.
  ALTER TABLE #SomeTable3
        ADD PRIMARY KEY CLUSTERED (RowNum)

CREATE NONCLUSTERED INDEX IX_#SomeTable3_Cover1 
    ON dbo.#SomeTable3 (Company, Year)
       INCLUDE (Amount, Quantity, Quarter) 
GO
    SET STATISTICS TIME OFF
    SET STATISTICS IO OFF
GO
---------------------------------------------------------------------------------------------------
--===== "Normal" Cross Tab
  PRINT REPLICATE('=',100)
  PRINT '=============== "Normal" Cross Tab ==============='
    SET STATISTICS IO ON
    SET STATISTICS TIME ON

 SELECT Company,
        Year,
        SUM(CASE WHEN Quarter = 1 THEN Amount   ELSE 0 END) AS Q1Amt,
        SUM(CASE WHEN Quarter = 1 THEN Quantity ELSE 0 END) AS Q1Qty,
        SUM(CASE WHEN Quarter = 2 THEN Amount   ELSE 0 END) AS Q2Amt,
        SUM(CASE WHEN Quarter = 2 THEN Quantity ELSE 0 END) AS Q2Qty,
        SUM(CASE WHEN Quarter = 3 THEN Amount   ELSE 0 END) AS Q3Amt,
        SUM(CASE WHEN Quarter = 3 THEN Quantity ELSE 0 END) AS Q3Qty,
        SUM(CASE WHEN Quarter = 4 THEN Amount   ELSE 0 END) AS Q4Amt,
        SUM(CASE WHEN Quarter = 4 THEN Quantity ELSE 0 END) AS Q4Qty,
        SUM(Amount)   AS TotalAmt,
        SUM(Quantity) AS TotalQty
   FROM #SomeTable3
  GROUP BY Company, Year
  ORDER BY Company, Year

    SET STATISTICS TIME OFF
    SET STATISTICS IO OFF
---------------------------------------------------------------------------------------------------
--===== "Normal" Pivot
  PRINT REPLICATE('=',100)
  PRINT '=============== "Normal" Pivot ==============='
    SET STATISTICS IO ON
    SET STATISTICS TIME ON

 SELECT amt.Company,
        amt.Year,
        COALESCE(amt.[1],0) AS Q1Amt,
        COALESCE(qty.[1],0) AS Q1Qty,
        COALESCE(amt.[2],0) AS Q2Amt,
        COALESCE(qty.[2],0) AS Q2Qty,
        COALESCE(amt.[3],0) AS Q3Amt,
        COALESCE(qty.[3],0) AS Q3Qty,
        COALESCE(amt.[4],0) AS Q4Amt,
        COALESCE(qty.[4],0) AS Q5Qty,
        COALESCE(amt.[1],0)+COALESCE(amt.[2],0)+COALESCE(amt.[3],0)+COALESCE(amt.[4],0) AS TotalAmt,
        COALESCE(qty.[1],0)+COALESCE(qty.[2],0)+COALESCE(qty.[3],0)+COALESCE(qty.[4],0) AS TotalQty
   FROM (SELECT Company, Year, Quarter, Amount FROM #SomeTable3) t1
        PIVOT (SUM(Amount) FOR Quarter IN ([1], [2], [3], [4])) AS amt
  INNER JOIN 
        (SELECT Company, Year, Quarter, Quantity FROM #SomeTable3) t2
        PIVOT (SUM(Quantity) FOR Quarter IN ([1], [2], [3], [4])) AS qty
     ON qty.Company = amt.Company 
    AND qty.Year    = amt.Year         
  ORDER BY amt.Company, amt.Year

    SET STATISTICS TIME OFF
    SET STATISTICS IO OFF
---------------------------------------------------------------------------------------------------
--===== "Pre-aggregated" Cross Tab
  PRINT REPLICATE('=',100)
  PRINT '=============== "Pre-aggregated" Cross Tab ==============='
    SET STATISTICS IO ON
    SET STATISTICS TIME ON

 SELECT Company,
        Year,
        SUM(CASE WHEN Quarter = 1 THEN Amount   ELSE 0 END) AS Q1Amt,
        SUM(CASE WHEN Quarter = 1 THEN Quantity ELSE 0 END) AS Q1Qty,
        SUM(CASE WHEN Quarter = 2 THEN Amount   ELSE 0 END) AS Q2Amt,
        SUM(CASE WHEN Quarter = 2 THEN Quantity ELSE 0 END) AS Q2Qty,
        SUM(CASE WHEN Quarter = 3 THEN Amount   ELSE 0 END) AS Q3Amt,
        SUM(CASE WHEN Quarter = 3 THEN Quantity ELSE 0 END) AS Q3Qty,
        SUM(CASE WHEN Quarter = 4 THEN Amount   ELSE 0 END) AS Q4Amt,
        SUM(CASE WHEN Quarter = 4 THEN Quantity ELSE 0 END) AS Q4Qty,
        SUM(Amount)   AS TotalAmt,
        SUM(Quantity) AS TotalQty
   FROM (SELECT Company,Year,Quarter,SUM(Amount) AS Amount,SUM(Quantity) AS Quantity
           FROM #SomeTable3 GROUP BY Company,Year,Quarter) d
  GROUP BY Company, Year
  ORDER BY Company, Year

    SET STATISTICS TIME OFF
    SET STATISTICS IO OFF
---------------------------------------------------------------------------------------------------
--===== "Pre-aggregated" Pivot
  PRINT REPLICATE('=',100)
  PRINT '=============== "Pre-aggregated" Pivot ==============='
    SET STATISTICS IO ON
    SET STATISTICS TIME ON

 SELECT amt.Company,
        amt.Year,
        COALESCE(amt.[1],0) AS Q1Amt,
        COALESCE(qty.[1],0) AS Q1Qty,
        COALESCE(amt.[2],0) AS Q2Amt,
        COALESCE(qty.[2],0) AS Q2Qty,
        COALESCE(amt.[3],0) AS Q3Amt,
        COALESCE(qty.[3],0) AS Q3Qty,
        COALESCE(amt.[4],0) AS Q4Amt,
        COALESCE(qty.[4],0) AS Q5Qty,
        COALESCE(amt.[1],0)+COALESCE(amt.[2],0)+COALESCE(amt.[3],0)+COALESCE(amt.[4],0) AS TotalAmt,
        COALESCE(qty.[1],0)+COALESCE(qty.[2],0)+COALESCE(qty.[3],0)+COALESCE(qty.[4],0) AS TotalQty
   FROM (SELECT Company, Year, Quarter, SUM(Amount) AS Amount FROM #SomeTable3 GROUP BY Company, Year, Quarter) t1
        PIVOT (SUM(Amount) FOR Quarter IN ([1], [2], [3], [4])) AS amt
  INNER JOIN 
        (SELECT Company, Year, Quarter, SUM(Quantity) AS Quantity FROM #SomeTable3 GROUP BY Company, Year, Quarter) t2
        PIVOT (SUM(Quantity) FOR Quarter IN ([1], [2], [3], [4])) AS qty
     ON qty.Company = amt.Company 
    AND qty.Year    = amt.Year         
  ORDER BY amt.Company, amt.Year

    SET STATISTICS TIME OFF
    SET STATISTICS IO OFF
---------------------------------------------------------------------------------------------------
--===== "Pre-aggregated" Cross Tab with CTE
  PRINT REPLICATE('=',100)
  PRINT '=============== "Pre-aggregated" Cross Tab with CTE ==============='
    SET STATISTICS IO ON
    SET STATISTICS TIME ON

;WITH
ctePreAgg AS
(SELECT Company,Year,Quarter,SUM(Amount) AS Amount,SUM(Quantity) AS Quantity
   FROM #SomeTable3 
  GROUP BY Company,Year,Quarter
)
 SELECT Company,
        Year,
        SUM(CASE WHEN Quarter = 1 THEN Amount   ELSE 0 END) AS Q1Amt,
        SUM(CASE WHEN Quarter = 1 THEN Quantity ELSE 0 END) AS Q1Qty,
        SUM(CASE WHEN Quarter = 2 THEN Amount   ELSE 0 END) AS Q2Amt,
        SUM(CASE WHEN Quarter = 2 THEN Quantity ELSE 0 END) AS Q2Qty,
        SUM(CASE WHEN Quarter = 3 THEN Amount   ELSE 0 END) AS Q3Amt,
        SUM(CASE WHEN Quarter = 3 THEN Quantity ELSE 0 END) AS Q3Qty,
        SUM(CASE WHEN Quarter = 4 THEN Amount   ELSE 0 END) AS Q4Amt,
        SUM(CASE WHEN Quarter = 4 THEN Quantity ELSE 0 END) AS Q4Qty,
        SUM(Amount)   AS TotalAmt,
        SUM(Quantity) AS TotalQty
   FROM ctePreAgg
  GROUP BY Company, Year
  ORDER BY Company, Year

    SET STATISTICS TIME OFF
    SET STATISTICS IO OFF
---------------------------------------------------------------------------------------------------
--===== "Pre-aggregated" Pivot with CTE
  PRINT REPLICATE('=',100)
  PRINT '=============== "Pre-aggregated" Pivot with CTE ==============='
    SET STATISTICS IO ON
    SET STATISTICS TIME ON

;WITH
ctePreAgg AS
(SELECT Company,Year,Quarter,SUM(Amount) AS Amount,SUM(Quantity) AS Quantity
   FROM #SomeTable3 
  GROUP BY Company,Year,Quarter
)
 SELECT amt.Company,
        amt.Year,
        COALESCE(amt.[1],0) AS Q1Amt,
        COALESCE(qty.[1],0) AS Q1Qty,
        COALESCE(amt.[2],0) AS Q2Amt,
        COALESCE(qty.[2],0) AS Q2Qty,
        COALESCE(amt.[3],0) AS Q3Amt,
        COALESCE(qty.[3],0) AS Q3Qty,
        COALESCE(amt.[4],0) AS Q4Amt,
        COALESCE(qty.[4],0) AS Q5Qty,
        COALESCE(amt.[1],0)+COALESCE(amt.[2],0)+COALESCE(amt.[3],0)+COALESCE(amt.[4],0) AS TotalAmt,
        COALESCE(qty.[1],0)+COALESCE(qty.[2],0)+COALESCE(qty.[3],0)+COALESCE(qty.[4],0) AS TotalQty
   FROM (SELECT Company, Year, Quarter, Amount FROM ctePreAgg) AS t1
        PIVOT (SUM(Amount) FOR Quarter IN ([1], [2], [3], [4])) AS amt
  INNER JOIN 
        (SELECT Company, Year, Quarter, Quantity FROM ctePreAgg) AS t2
        PIVOT (SUM(Quantity) FOR Quarter IN ([1], [2], [3], [4])) AS qty
     ON qty.Company = amt.Company 
    AND qty.Year    = amt.Year         
  ORDER BY amt.Company, amt.Year

    SET STATISTICS TIME OFF
    SET STATISTICS IO OFF
---------------------------------------------------------------------------------------------------
