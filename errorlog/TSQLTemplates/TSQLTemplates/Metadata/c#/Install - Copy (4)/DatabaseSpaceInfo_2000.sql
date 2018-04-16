SET NOCOUNT ON

DECLARE @SQL			varchar(2000)

/* BEGIN - STORING LOG SPACE - */

CREATE TABLE #LogSpace
(
	LS_DBName			varchar(128),
	LS_SizeInMB			dec(20,4),
	LS_PercentSpaceUsed	dec(20,4),
	LS_Status			int
)

INSERT INTO #LogSpace
EXECUTE ('DBCC sqlperf(logspace)')

/* END - STORING LOG SPACE - */

/* BEGIN - STORING FILE STATISTICS - */

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
EXECUTE dbo.sp_MSforeachdb 'USE [?];DBCC showfilestats WITH NO_INFOMSGS'

/* END - STORING FILE STATISTICS - */

/* BEGIN - COLLECTING DATA FILE INFO */

CREATE TABLE #DBDataFileInfo
(
	DbName			varchar(128)
	,LogicalName	varchar(128)	
	,TotalSpaceMB	dec(20,4)
	,UsedSpaceMB	dec(20,4)
	,UnusedSpaceMB	dec(20,4)
	,PhysicalName	varchar(256)
)
	
SET @SQL = '	
				USE [?];
				SELECT		''?'' 
							,FS_LogicalName 							
							,CAST(CAST((FS_TotalExtents * 64) / 1024.0 AS decimal(10, 2)) AS varchar(15)) 
							,CAST(CAST((FS_UsedExtents * 64) / 1024.0 AS decimal(10, 2)) AS varchar(15)) 
							,CAST(CAST(((FS_TotalExtents - FS_UsedExtents) * 64) / 1024.0 AS decimal(10, 2)) AS varchar(15)) 
							,RTRIM(f.filename) 
				FROM		#FileStats FS
								JOIN sysfiles		f	ON FS.FS_LogicalName	= f.name COLLATE DATABASE_DEFAULT
									 				   AND FS.FS_Filename		= f.filename COLLATE DATABASE_DEFAULT
								CROSS JOIN master.dbo.spt_values v 
				WHERE		v.number = 1
				  AND 		v.type = ''E''
		'
INSERT INTO #DBDataFileInfo 
EXECUTE dbo.sp_MSforeachdb @SQL

  
/* BEGIN - SHOW DATA & LOG FILE REPORT OF THE CURRENT DB */


SELECT		DbName
			,'Data' AS [Type]
			,LogicalName
			,TotalSpaceMB
			,UsedSpaceMB
			,UnusedSpaceMB
			,(UnusedSpaceMB/TotalSpaceMB) * 100 AS [PercentUnused]
			,PhysicalName
FROM		#DBDataFileInfo  
UNION ALL
SELECT		LS_DBName
			,'Log'
			,'Transaction Log'
			,CAST(CAST(LS_SizeInMB AS decimal(10, 2)) AS varchar(15))
			,CAST(CAST(LS_SizeInMB * (LS_PercentSpaceUsed / 100) AS decimal(10, 2)) AS varchar(15))
			,CAST(CAST(LS_SizeInMB - (LS_SizeInMB * (LS_PercentSpaceUsed / 100)) AS decimal(10, 2)) AS varchar(15))
			,(LS_SizeInMB - (LS_SizeInMB * (LS_PercentSpaceUsed/100)))/LS_SizeInMB * 100
			,''
FROM		#LogSpace
				CROSS JOIN master.dbo.spt_values v
WHERE		v.number = 1
  AND 		v.type = 'E'
ORDER BY	1, 2

/* END - SHOW DATA & LOG FILE REPORT OF THE CURRENT DB */

/* BEGIN - REMOVE TEMPORARY TABLES */

DROP TABLE #LogSpace
DROP TABLE #FileStats 
DROP TABLE #DBDataFileInfo

/* END - REMOVE TEMPORARY TABLES */

