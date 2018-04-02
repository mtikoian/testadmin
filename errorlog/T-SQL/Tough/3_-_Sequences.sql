USE DataWindows
GO
set statistics io, time on;


/**************************************************************
***   Virtual numbers table 
**************************************************************/


-- two rows
SELECT n FROM ( VALUES (1) ,(1) ) AS D(n);

-- four rows
WITH
  L0   AS ( SELECT n FROM ( VALUES (1) ,(1) ) AS D(n) )
SELECT 1 AS n FROM L0 AS A CROSS JOIN L0 AS B;

-- 16 rows
WITH
    L0   AS ( SELECT n FROM ( VALUES (1) ,(1) ) AS D(n) )
  , L1   AS ( SELECT 1 AS n FROM L0 AS A CROSS JOIN L0 AS B )
SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B;



IF OBJECT_ID('dbo.GetNums', 'IF') IS NOT NULL DROP FUNCTION dbo.GetNums;
GO
CREATE FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
  WITH
    L0   AS (SELECT c FROM (VALUES(1),(1)) AS D(c)),         --             2 rows
    L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B), --             4 rows
    L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B), --            16 rows
    L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B), --           256 rows
    L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B), --        65,356 rows
    L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B), -- 4,294,967,296 rows
    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
            FROM L5)
  SELECT TOP(@high - @low + 1) @low + rownum - 1 AS n
  FROM Nums
  ORDER BY rownum;
GO
SELECT * FROM dbo.GetNums(20, 25);


GO
ALTER FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
  WITH
    L0   AS (SELECT c FROM (VALUES(1),(1)) AS D(c)),         --             2 rows
    L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B), --             4 rows
    L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B), --            16 rows
    L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B), --           256 rows
    L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B), --        65,356 rows
    L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B), -- 4,294,967,296 rows
    Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum
            FROM L5)
  SELECT @low + rownum - 1 AS n
  FROM Nums
  ORDER BY rownum
  OFFSET 0 ROWS FETCH FIRST @high - @low + 1 ROWS ONLY;
GO

SELECT * FROM dbo.GetNums(20, 25);




/**************************************************************
***   Sequences of Numbers
**************************************************************/

-- 3 min 54 sec for 10,000,000 rows
-- 23 seconds for 1,000,000 rows
SELECT n
FROM dbo.GetNums(1, 1000000);
GO


-- ??? for 10,000,000 rows, with results discarded
DECLARE @Num BIGINT;
SELECT @Num = n
FROM dbo.GetNums(1, 10000000);
GO




/**************************************************************
***   Sequences of Dates, Times 
**************************************************************/

DECLARE 
  @start AS DATE = '2015-05-01',
  @end   AS DATE = '2016-04-30';

SELECT DATEADD(day, n, @start) AS dt
FROM dbo.GetNums(0, DATEDIFF(day, @start, @end)) AS Nums;
GO


DECLARE 
    @start AS DATETIME2 = '2016-09-08 00:00:00.0000000'
  , @end   AS DATETIME2 = '2016-09-10 12:00:00.0000000'
  , @hours AS INT       = 4

SELECT DATEADD(hour, n *@hours, @start) AS dt
FROM dbo.GetNums(0, DATEDIFF(hour, @start, @end)/@hours) AS Nums;
GO




set statistics io, time off;
