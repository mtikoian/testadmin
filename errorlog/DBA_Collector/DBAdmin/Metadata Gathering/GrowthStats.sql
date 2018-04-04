SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH GrowthStats AS
(
  SELECT  ROW_NUMBER() OVER(PARTITION BY fgs.DatabaseKey ORDER BY fgs.DateKey) RowId,
          fgs.DatabaseKey,
          fgs.Datekey,
          fgs.DataSize,
          fgs.LogSize,
          fgs.IndexSize,
          fgs.DataUsed,
          fgs.LogSize
  FROM    Growth.factDBGrowth fgs
            JOIN Common.dimDatabase db
              ON db.DatabaseKey = fgs.DatabaseKey
            --JOIN dbo.Calendar cal
            --  ON fgs.DateKey = cal.DateKey
  WHERE   --fgs.DateKey >= DATEADD(dd,-365,CURRENT_TIMESTAMP) AND 
          db.DatabaseName LIKE 'POLLFTP2'
), DailyGrowthDetail AS
(
SELECT  gr1.DatabaseKey,
        gr1.DateKey,
        gr1.DataUsed - gr2.DataUsed DailyGrowth,
        gr1.IndexSize - gr2.IndexSize DailyIndexGrowth,
        gr1.LogSize - gr2.LogSize DailyLogGrowth
FROM    GrowthStats gr1
          JOIN GrowthStats gr2
            ON gr1.DatabaseKey = gr2.DatabaseKey
            AND gr1.RowId = gr2.RowId + 1
),
DailyGrowth AS
(
SELECT  dgd.DatabaseKey,
        AVG(DailyGrowth) AverageGrowth,
        AVG(DailyIndexGrowth) AverageIndexGrowth,
        AVG(DailyLogGrowth) AverageLogGrowth
FROM    DailyGrowthDetail dgd
GROUP BY dgd.DatabaseKey
), LatestDate AS
(
  SELECT  MAX(fgs.DateKey) DateKey,
          fgs.DatabaseKey
  FROM    GrowthStats fgs
  GROUP BY fgs.DatabaseKey
), LatestSize AS
(
  SELECT  fgs.DatabaseKey,
          fgs.DataUsed,
          fgs.DataSize,
          fgs.IndexSize,
          fgs.LogSize
  FROM    LatestDate ld
            JOIN GrowthStats fgs
              ON ld.DatabaseKey = fgs.DatabaseKey
                 AND ld.DateKey = fgs.DateKey
)
--SELECT * FROM DailyGrowthDetail ls JOIN Common.dimDatabase db ON ls.DatabaseKey = db.DatabaseKey ORDER BY DatabaseName
SELECT  db.DatabaseName
        ,ls.DataUsed CurrentUsed
        ,ls.DataSize CurrentSize
        ,ls.DataUsed + (dg.AverageGrowth * 730) + ((ls.DataUsed + (dg.AverageGrowth * 730))*.3) PredictedSize
        ,ls.LogSize CurrentLogSize
        ,ls.LogSize + (dg.AverageLogGrowth * 730) PredictedLogSize
FROM    DailyGrowth dg
          JOIN LatestSize ls
            ON dg.DatabaseKey = ls.DatabaseKey
          JOIN Common.dimDatabase db
            ON ls.DatabaseKey = db.DatabaseKey;