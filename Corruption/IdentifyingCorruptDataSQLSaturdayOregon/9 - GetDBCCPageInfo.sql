USE CorruptDemoDB;
 
/* Drop temp tables if they exist */
SET NOCOUNT ON;

TRUNCATE TABLE PageResults;
 
IF OBJECT_ID('tempdb..#DBCCPages') IS NOT NULL
BEGIN
     
    DROP TABLE #DBCCPages;
 
END
 
IF OBJECT_ID('tempdb..#PageResults') IS NOT NULL
BEGIN
     
    DROP TABLE #PageResults;
 
END
 
/* Create temp tables */
CREATE TABLE #PageResults
(ParentObject VARCHAR(100)
,[Object] VARCHAR(1000)
,[Field] VARCHAR(100)
,[VALUE] VARCHAR(1000))
 
/* Declare local variables */
DECLARE @loopcount INT = 1;
DECLARE @looplimit INT;
DECLARE @sqlstr NVARCHAR(4000);
DECLARE @pagenum BIGINT;

--SELECT * FROM DBCCResults
 
/* Select information about the corrupt data
   This example selects rows with a RepairLevel of repair_allow_data_loss for a single object */
SELECT DISTINCT O.name, T.RepairLevel, T.IndId, T.PartID, T.Page 
INTO #DBCCPages 
FROM DBCCResults T
INNER JOIN CorruptDemoDB.sys.objects O
ON t.ObjId = O.object_id
WHERE RepairLevel = 'repair_allow_data_loss'
AND O.name = 'CorruptData'
--AND T.Page <> 303
ORDER BY O.name, T.Page;

--SELECT * FROM #DBCCPages
 
/* Set the loop limit */
SET @looplimit = @@ROWCOUNT;
 
/* Build a DBCC PAGE statement for each corrupt page and execute it
   Insert the results into the #PageResults temp table */
WHILE @loopcount <= @looplimit
BEGIN
 
    SELECT TOP 1 @pagenum = Page FROM #DBCCPages
 
    SET @sqlstr = 'DBCC PAGE (CorruptDemoDB,1,' + CAST(@pagenum AS NVARCHAR) + ',3) WITH TABLERESULTS'
 
    INSERT INTO #PageResults
    EXEC sp_executesql @sqlstr;
 
    SET @loopcount += 1;
 
    DELETE FROM #DBCCPages WHERE Page = @pagenum;
     
END

SELECT * FROM #PageResults

USE CorruptDemoDB;
/* Select data from PageResults to return the key value for each row contained on a corrupt page */

INSERT INTO CorruptDemoDB..PageResults
(ParentObject
,IDNumber
,PhoneNumber
,FirstName
,LastName)
SELECT ParentObject,
     CAST(MIN(CASE Field WHEN 'IDNumber' THEN VALUE END) AS INT) AS IDNumber,
	 MIN(CASE Field WHEN 'PhoneNumber' THEN VALUE END) AS PhoneNumber,
	 MIN(CASE Field WHEN 'FirstName' THEN VALUE END) AS FirstName,
	 MIN(CASE Field WHEN 'LastName' THEN VALUE END) AS LastName
   FROM #PageResults
   --WHERE Field = 'IDNumber'
   GROUP BY ParentObject
   ORDER BY IDNumber, PhoneNumber

SELECT ParentObject, IDNumber, PhoneNumber, FirstName, LastName
FROM CorruptDemoDB..PageResults
WHERE IDNumber IS NOT NULL
ORDER BY IDNumber, PhoneNumber 


