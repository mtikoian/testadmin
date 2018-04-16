DECLARE @xml XML

SELECT @xml =(SELECT *
FROM OPENROWSET
(BULK   'E:\4queries.sqlplan',
SINGLE_BLOB) XMLShowPlan
);

WITH XMLNAMESPACES  
   (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
    
SELECT DISTINCT
		op.value('@PhysicalOp', 'nvarchar(200)') AS PhysicalOp 
		,(op.value('@EstimateRows', 'float') * (op.value('@EstimateRewinds', 'float')
		+  op.value('@EstimateRebinds', 'float') + 1.0)) AS EstimateRows
		, all_actual.ActualRows as ActualRows
		, (all_actual.ActualRows) - (op.value('@EstimateRows', 'float') * (op.value('@EstimateRewinds', 'float')
		+  op.value('@EstimateRebinds', 'float') + 1.0)) as Diff
		,
		(SELECT tbl.value('(@Table)[1]', 'VARCHAR(128)')
		FROM op.nodes('.//Object') AS obj(tbl) 
		FOR  XML PATH('') 
		) AS Tbl
       ,
		(SELECT  idx.value('(@Index)[1]', 'VARCHAR(128)') + ', ' 
		FROM op.nodes('.//Object') AS obj(idx) 
		FOR  XML PATH('')
		) AS Idx
       
INTO #SkewedStats
FROM  @xml.nodes('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan"; //RelOp') AS RelOp ( op )
CROSS APPLY (
		SELECT SUM(r.i.value('@ActualRows', 'float')) ActualRows
		FROM op.nodes('.//RunTimeInformation/RunTimeCountersPerThread') as r(i)
		) all_actual

SELECT * 
FROM #SkewedStats 
WHERE PhysicalOp in ('Table Scan','Clustered Index Scan','Index Scan', 'Index Seek', 'Clustered Index Seek')
ORDER BY 2 DESC
DROP TABLE #SkewedStats
