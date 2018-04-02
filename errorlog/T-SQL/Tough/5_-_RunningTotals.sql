USE DataWindows
GO



/**************************************************************
***   Running Totals
**************************************************************/ 

IF OBJECT_ID('dbo.Transactions', 'U') IS NOT NULL DROP TABLE dbo.Transactions;

CREATE TABLE dbo.Transactions (
  actid  INT   NOT NULL,                -- partitioning column
  tranid INT   NOT NULL,                -- ordering column
  val    MONEY NOT NULL,                -- measure
  CONSTRAINT PK_Transactions PRIMARY KEY(actid, tranid)
);
GO

-- small set of sample data
INSERT INTO dbo.Transactions(actid, tranid, val) VALUES
  (1,  1,  4.00),
  (1,  2, -2.00),
  (1,  3,  5.00),
  (1,  4,  2.00),
  (1,  5,  1.00),
  (1,  6,  3.00),
  (1,  7, -4.00),
  (1,  8, -1.00),
  (1,  9, -2.00),
  (1, 10, -3.00),
  (2,  1,  2.00),
  (2,  2,  1.00),
  (2,  3,  5.00),
  (2,  4,  1.00),
  (2,  5, -5.00),
  (2,  6,  4.00),
  (2,  7,  2.00),
  (2,  8, -4.00),
  (2,  9, -5.00),
  (2, 10,  4.00),
  (3,  1, -3.00),
  (3,  2,  3.00),
  (3,  3, -2.00),
  (3,  4,  1.00),
  (3,  5,  4.00),
  (3,  6, -1.00),
  (3,  7,  5.00),
  (3,  8,  3.00),
  (3,  9,  5.00),
  (3, 10, -3.00);
GO



-- Set-Based Solution Using Subqueries
SELECT actid, tranid, val,
  (SELECT SUM(T2.val)
   FROM dbo.Transactions AS T2
   WHERE T2.actid = T1.actid
     AND T2.tranid <= T1.tranid) AS balance
FROM dbo.Transactions AS T1
ORDER BY actid, tranid;

-- Set-Based Solution Using Joins
SELECT T1.actid, T1.tranid, T1.val,
  SUM(T2.val) AS balance
FROM dbo.Transactions AS T1
  JOIN dbo.Transactions AS T2
    ON T2.actid = T1.actid
   AND T2.tranid <= T1.tranid
GROUP BY T1.actid, T1.tranid, T1.val
ORDER BY T1.actid, T1.tranid;





-- large set of sample data (change inputs as needed)
TRUNCATE TABLE dbo.Transactions;

DECLARE
  @num_partitions     AS INT = 10,
  @rows_per_partition AS INT = 10000;

INSERT INTO dbo.Transactions WITH (TABLOCK) (actid, tranid, val)
SELECT NP.n, RPP.n,
  (ABS(CHECKSUM(NEWID())%2)*2-1) * (1 + ABS(CHECKSUM(NEWID())%5))
FROM dbo.GetNums(1, @num_partitions) AS NP
CROSS JOIN dbo.GetNums(1, @rows_per_partition) AS RPP;



set statistics io, time on;


-- Set-Based Solution Using Subqueries -- 1 min 07 sec
SELECT actid, tranid, val,
  (SELECT SUM(T2.val)
   FROM dbo.Transactions AS T2
   WHERE T2.actid = T1.actid
     AND T2.tranid <= T1.tranid) AS balance
FROM dbo.Transactions AS T1
ORDER BY actid, tranid;
/*
(100000 row(s) affected)
Table 'Transactions'. Scan count 100001, logical reads 1883054 ...

 SQL Server Execution Times:
   CPU time = 67032 ms,  elapsed time = 67105 ms.
*/


-- Set-Based Solution Using Joins -- 1 min 42 sec
SELECT T1.actid, T1.tranid, T1.val,
  SUM(T2.val) AS balance
FROM dbo.Transactions AS T1
  JOIN dbo.Transactions AS T2
    ON T2.actid = T1.actid
   AND T2.tranid <= T1.tranid
GROUP BY T1.actid, T1.tranid, T1.val
ORDER BY T1.actid, T1.tranid;
/*
(100000 row(s) affected)
Table 'Transactions'. Scan count 100001, logical reads 1878926 ...

 SQL Server Execution Times:
   CPU time = 102032 ms,  elapsed time = 102061 ms.
*/


-- Cursor-Based Solution -- 
set statistics io, time off;

DECLARE @Result AS TABLE
(
  actid   INT,
  tranid  INT,
  val     MONEY,
  balance MONEY
);

DECLARE
  @actid    AS INT,
  @prvactid AS INT,
  @tranid   AS INT,
  @val      AS MONEY,
  @balance  AS MONEY;

DECLARE C CURSOR FAST_FORWARD FOR
  SELECT actid, tranid, val
  FROM dbo.Transactions
  ORDER BY actid, tranid;

OPEN C

FETCH NEXT FROM C INTO @actid, @tranid, @val;
SELECT @prvactid = @actid, @balance = 0;

WHILE @@fetch_status = 0
BEGIN
  IF @actid <> @prvactid
    SELECT @prvactid = @actid, @balance = 0;

  SET @balance = @balance + @val;
  INSERT INTO @Result VALUES(@actid, @tranid, @val, @balance);
  
  FETCH NEXT FROM C INTO @actid, @tranid, @val;
END

CLOSE C;
DEALLOCATE C;

SELECT * FROM @Result;





set statistics io, time on;

-- Set-Based Solution Using Window Functions
SELECT actid, tranid, val
  , balance = SUM(val) OVER(PARTITION BY actid ORDER BY tranid
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM dbo.Transactions;

set statistics io, time off;
