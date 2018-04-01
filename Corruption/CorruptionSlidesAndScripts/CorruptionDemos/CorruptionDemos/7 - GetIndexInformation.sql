USE CorruptDemoDB;

SET NOCOUNT ON;

DECLARE @loopcount INT = 1;
DECLARE @looplimit INT = 10;
DECLARE @pagenumber INT;
DECLARE @sqlstr NVARCHAR(4000);

IF OBJECT_ID('tempdb..#pageinfo') IS NOT NULL
BEGIN

	DROP TABLE #pageinfo;

END

--Listing 1. Queries for sys.dm_db_database_page_allocations and DBCC IND

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
--INTO #pageinfo
FROM sys.dm_db_database_page_allocations(DB_ID(), OBJECT_ID('dbo.CorruptData'), 1, NULL, 'DETAILED')
WHERE is_allocated = 1;


ALTER DATABASE CorruptDemoDB
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

WHILE @loopcount <= @looplimit
BEGIN

	SELECT TOP 1 @pagenumber = PagePID FROM #pageinfo;

	SET @sqlstr = 'DBCC WRITEPAGE (N''CorruptDemoDB'', 1, ' + CAST(@pagenumber AS NVARCHAR) + ', 1000, 1, 0x01, 1);';

	--PRINT @sqlstr;
	EXEC sp_executesql @sqlstr;

	--DBCC WRITEPAGE (N'CorruptDemoDB', 1, 10696, 1500, 1, 0x01, 1);

	SET @loopcount += 1;

	DELETE FROM #pageinfo WHERE PagePID = @pagenumber;

END

ALTER DATABASE CorruptDemoDB
SET MULTI_USER;