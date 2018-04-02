USE DataWindows
GO



/**************************************************************
***   Gaps and Islands
**************************************************************/ 


-- dbo.IslandsInt (numeric sequence with unique values, interval: 1)
IF OBJECT_ID('dbo.IslandsInt', 'U') IS NOT NULL DROP TABLE dbo.IslandsInt;
GO
CREATE TABLE dbo.IslandsInt (
  col1 INT NOT NULL
    CONSTRAINT PK_IslandsInt PRIMARY KEY
);
GO

INSERT INTO dbo.IslandsInt(col1)
  VALUES (2),(3)
        ,(7),(8),(9)
        ,(11)
        ,(15),(16),(17)
        ,(28);
GO



-- dbo.IslandsDate (date sequence with unique values, interval: 1 day)
IF OBJECT_ID('dbo.IslandsDate', 'U') IS NOT NULL DROP TABLE dbo.IslandsDate;
GO
CREATE TABLE dbo.IslandsDate (
  col1 DATE NOT NULL
    CONSTRAINT PK_IslandsDate PRIMARY KEY
);
GO

INSERT INTO dbo.IslandsDate(col1)
SELECT DATEADD(day, col1 -1, '2016-08-01')
FROM IslandsInt;
GO







/**************************************************************
***   Islands
**************************************************************/ 

-- Find the islands
SELECT a.col1
  , grp = (SELECT MIN(b.col1)
           FROM dbo.IslandsInt AS b
           WHERE b.col1 >= a.col1
             AND NOT EXISTS (SELECT 1
                             FROM dbo.IslandsInt AS c
                             WHERE c.col1 = b.col1 +1
                             )
           )
FROM dbo.IslandsInt AS a;


set statistics io, time on;

-- Find MIN() and MAX() of col1, GROUP BY grp
WITH cteGroup As (
    SELECT a.col1
      , grp = (SELECT MIN(b.col1)
               FROM dbo.IslandsInt AS b
               WHERE b.col1 >= a.col1
                 AND NOT EXISTS (SELECT 1
                                 FROM dbo.IslandsInt AS c
                                 WHERE c.col1 = b.col1 +1
                                 )
               )
    FROM dbo.IslandsInt AS a
)
SELECT IslandStart = MIN(cte.col1)
     , islandEnd   = MAX(cte.col1)
FROM cteGroup AS cte
GROUP BY cte.grp
ORDER BY cte.grp;

/*
S L O W ! ! !
  2 FULL Table/CI scans per row ....
*/




-- Using ROW_NUMBER
SELECT a.col1
  , grp = a.col1 - ROW_NUMBER() OVER (ORDER BY a.col1)
FROM dbo.IslandsInt AS a
ORDER BY a.col1;


-- Find MIN() and MAX() of col1, GROUP BY grp
WITH cteGroup As (
  SELECT a.col1
    , grp = a.col1 - ROW_NUMBER() OVER (ORDER BY a.col1)
  FROM dbo.IslandsInt AS a
)
SELECT IslandsInttart = MIN(cte.col1)
     , islandEnd   = MAX(cte.col1)
FROM cteGroup AS cte
GROUP BY cte.grp
ORDER BY cte.grp;




-- diff between col1 and dense rank
SELECT col1,
  DENSE_RANK() OVER(ORDER BY col1) AS drnk,
  col1 - DENSE_RANK() OVER(ORDER BY col1) AS diff
FROM dbo.IslandsInt;

-- Numeric
WITH cteData AS (
  SELECT col1, col1 - DENSE_RANK() OVER(ORDER BY col1) AS diff
  FROM dbo.IslandsInt
)
SELECT MIN(col1) AS rangeStart
     , MAX(col1) AS rangeEnd
FROM cteData
GROUP BY diff;

-- Dates
WITH cteData AS (
  SELECT col1, DATEADD(day, -1 * DENSE_RANK() OVER(ORDER BY col1), col1) AS diff
  FROM dbo.IslandsDate
)
SELECT MIN(col1) AS rangeStart
     , MAX(col1) AS rangeEnd
FROM cteData
GROUP BY diff;






/**************************************************************
***   Gaps
**************************************************************/ 

SELECT cur = col1
      , nxt = LEAD(col1) OVER(ORDER BY col1)
FROM dbo.IslandsInt

-- Numeric
WITH cteData AS (
  SELECT cur = col1
       , nxt = LEAD(col1) OVER(ORDER BY col1)
  FROM dbo.IslandsInt
)
SELECT cur, nxt
     , GapStart = cur + 1
     , GapEnd   = nxt - 1
FROM cteData
WHERE nxt - cur > 1;

-- Dates
WITH cteData AS (
  SELECT cur = col1
       , nxt = LEAD(col1) OVER(ORDER BY col1)
  FROM dbo.IslandsDate
)
SELECT cur, nxt
     , GapStart = DATEADD(day, 1, cur)
     , GapEnd   = DATEADD(day, -1, nxt)
FROM cteData
WHERE DATEDIFF(day, cur, nxt) > 1;



set statistics io, time off;

