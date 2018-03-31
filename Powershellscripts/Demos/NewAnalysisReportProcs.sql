CREATE PROCEDURE [Analysis].[selComparativeAnalysisReport] (@InstanceName varchar(50))
AS
SET NOCOUNT ON

DECLARE @Sep INT, @BoxNm VARCHAR(50), @InstNm VARCHAR(50)

SELECT @Sep = CHARINDEX('\', @InstanceName)

IF @Sep > 0
  BEGIN
  SELECT @BoxNm = SUBSTRING(@InstanceName, 1, @Sep - 1), @InstNm = SUBSTRING(@InstanceName, @Sep + 1, (LEN(@InstanceName) - @Sep))
  END
ELSE
  BEGIN
  SELECT @BoxNm = @InstanceName, @InstNm = 'MSSQLSERVER'
  END

SELECT CONVERT(char(10), s.[PerfDate], 101) as PerfDate
      ,CONVERT(char(8), s.[PerfDate], 108) as PerfTime
      ,s.[PctProc]
      ,i.[BatReqSec]
      ,i.[BufCchHit]
      ,i.[PgLifeExp]
FROM [Analysis].[ServerStats] s
INNER JOIN [Analysis].[InstanceStats] i
ON s.[ServerID] = i.[ServerID]
WHERE s.ServerNm = @BoxNm
AND i.ServerNm = @BoxNm
AND i.InstanceNm = @InstNm
AND s.[PerfDate] > DATEADD(dd, -35, GETDATE())
ORDER BY CONVERT(Date,s.[PerfDate]) DESC, PerfTime ASC
GO

CREATE PROCEDURE [Analysis].[selPerformanceAnalysisReport] (@InstanceName varchar(50), @PerfDate DATETIME)
AS
SET NOCOUNT ON

DECLARE @Sep INT, @BoxNm VARCHAR(50), @InstNm VARCHAR(50)

SELECT @Sep = CHARINDEX('\', @InstanceName)

IF @Sep > 0
  BEGIN
  SELECT @BoxNm = SUBSTRING(@InstanceName, 1, @Sep - 1), @InstNm = SUBSTRING(@InstanceName, @Sep + 1, (LEN(@InstanceName) - @Sep))
  END
ELSE
  BEGIN
  SELECT @BoxNm = @InstanceName, @InstNm = 'MSSQLSERVER'
  END

SELECT CONVERT(char(8), s.[PerfDate], 108) as PerfTime
      ,s.[ServerNm]
      ,i.[InstanceNm]
      ,s.[PctProc]
      ,s.[Memory]
      ,s.[PgFilUse]
      ,s.[DskSecRd]
      ,s.[DskSecWrt]
      ,s.[ProcQueLn]
      ,i.[FwdRecSec]
      ,i.[PgSpltSec]
      ,i.[BufCchHit]
      ,i.[PgLifeExp]
      ,i.[LogGrwths]
      ,i.[BlkProcs]
      ,i.[BatReqSec]
      ,i.[SQLCompSec]
      ,i.[SQLRcmpSec]
FROM [Analysis].[ServerStats] s
INNER JOIN [Analysis].[InstanceStats] i
ON s.[ServerID] = i.[ServerID]
WHERE s.ServerNm = @BoxNm
AND i.ServerNm = @BoxNm
AND i.InstanceNm = @InstNm
AND s.[PerfDate] BETWEEN @PerfDate AND DATEADD(DAY,1,@PerfDate)
GO
