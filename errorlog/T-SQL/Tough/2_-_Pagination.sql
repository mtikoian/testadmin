USE DataWindows
GO
set statistics io, time on;




/**************************************************************
***   Paging
**************************************************************/

-- with ROW_NUMBER
DECLARE
  @pagenum  AS INT = 3,
  @pagesize AS INT = 25;

WITH cteBase AS
(
  SELECT ROW_NUMBER() OVER( ORDER BY orderdate, orderid ) AS rownum,
    orderid, orderdate, custid, empid
  FROM Sales.Orders
)
SELECT orderid, orderdate, custid, empid, rownum
FROM cteBase
WHERE rownum BETWEEN (@pagenum - 1) * @pagesize + 1
                 AND @pagenum * @pagesize
ORDER BY rownum;
GO


-- with OFFSET/FETCH
DECLARE
  @pagenum  AS INT = 3,
  @pagesize AS INT = 25;

SELECT orderid, orderdate, custid, empid
FROM Sales.Orders
ORDER BY orderdate, orderid
OFFSET (@pagenum - 1) * @pagesize ROWS FETCH NEXT @pagesize ROWS ONLY;
GO

 
set statistics io, time off;
