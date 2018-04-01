USE CorruptDemoDB;

--DROP TABLE #pageinfo;

DECLARE @pagenum INT;

SELECT
allocated_page_file_id AS PageFID
,allocated_page_page_id AS PagePID
,allocated_page_iam_file_id AS IAMFID
,allocated_page_iam_page_id AS IAMPID
,object_id AS ObjectID
,index_id AS IndexID
,partition_id AS PartitionNumber
,rowset_id AS PartitionID
,allocation_unit_type_desc AS iam_chain_type
,page_type AS PageType
,page_level AS IndexLevel
,next_page_file_id AS NextPageFID
,next_page_page_id AS NextPagePID
,previous_page_file_id AS PrevPageFID
,previous_page_page_id AS PrevPagePID
INTO #pageinfo
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('dbo.CorruptData'), 1, NULL, 'DETAILED')
WHERE is_allocated = 1;

--SELECT * FROM #pageinfo
--WHERE PageType = 2;

SELECT
@pagenum = MIN(allocated_page_page_id)
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('dbo.CorruptData'), 1, NULL, 'DETAILED')
WHERE is_allocated = 1
AND page_type = 1;

SELECT @pagenum

--SELECT * FROM CorruptData;

SELECT @pagenum * 8192 AS Offset;

/* Calculate offset
   PageID * 8192
   301 * 8192 = 2465792 */