USE [master]
GO
CREATE TABLE #LogSpace
(
	LS_DBName			varchar(128),
	LS_SizeInMB			dec(20,4),
	LS_PercentSpaceUsed	dec(20,4),
	LS_Status			int
)

INSERT INTO #LogSpace
EXECUTE ('DBCC sqlperf(logspace)')

CREATE TABLE #FileStats
(
	FS_FileId		smallint,
	FS_GroupId		smallint,
	FS_TotalExtents	int,
	FS_UsedExtents	int,
	FS_LogicalName	varchar(255),
	FS_Filename		varchar(255)
)
	
INSERT INTO #FileStats
EXECUTE sys.sp_MSforeachdb 'USE [?];DBCC showfilestats WITH NO_INFOMSGS'

SELECT		DB_NAME(A.database_id)									AS [Database]
			,A.type_desc											AS [Type]
			,A.name													AS [LogicalName]
			,(FS_TotalExtents * 64) / 1024.0						AS [TotalSpace_MB]
			,(FS_UsedExtents * 64) / 1024.0							AS [UsedSpace_MB]
			,((FS_TotalExtents - FS_UsedExtents) * 64) / 1024.0		AS [UnusedSpace_MB]
			,((FS_TotalExtents - FS_UsedExtents)/(FS_TotalExtents * 1.0)) * 100.0		AS [Percent_Unused]
			,A.physical_name										AS [PhysicalName]
FROM		sys.master_files	A
				JOIN #FileStats B ON A.name				= B.FS_LogicalName
				                 AND A.physical_name	= B.FS_Filename
UNION ALL                				                				                 
SELECT		LS_DBName												AS [Datbase]
			,'LOG'													AS [Type]
			,''														AS [LogicalName]
			,LS_SizeInMB											AS [TotalSpace_MB]
			,LS_SizeInMB * (LS_PercentSpaceUsed/100)				AS [UsedSpace_MB]
			,LS_SizeInMB - (LS_SizeInMB * (LS_PercentSpaceUsed/100)) AS [UnusedSpace_MB]
			,(LS_SizeInMB - (LS_SizeInMB * (LS_PercentSpaceUsed/100)))/LS_SizeInMB * 100 AS [Percent_Unused]
			,''														AS [PhysicalName]
FROM		#LogSpace
ORDER BY	1, 2

DROP TABLE #FileStats
DROP TABLE #LogSpace