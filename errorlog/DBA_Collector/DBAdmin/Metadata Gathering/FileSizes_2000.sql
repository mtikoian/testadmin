--Script to calculate information about the Data Files

SET  QUOTED_IDENTIFIER OFF
SET  NOCOUNT ON

DECLARE @dbname   VARCHAR (50)
DECLARE @string   VARCHAR (400)
SET @string = ''

--create table #tempfilestats 
--(
--	DBName VARCHAR(256) DEFAULT NULL,
--	FileId INT,
--	FileGroup INT,
--	TotalExtents FLOAT,
--	UsedExtents FLOAT,
--	Name SYSNAME,
--	[FileName] SYSNAME
--);


CREATE TABLE #dbstats
(
   dbname          VARCHAR (50),
   FileGroupType	 VARCHAR (25),
   FileGroupName   VARCHAR (25),
   TotalSizeinMB   DEC (8, 2),
   UsedSizeinMB    DEC (8, 2)
)


exec sp_msforeachdb '
USE [?];
RAISERROR(''Processing database %s'',1,1,''?'') WITH NOWAIT;
INSERT	#DBStats
SELECT	''?'',
				CASE [groupid] WHEN 0 THEN ''LOG'' ELSE ''ROWS'' END,
				[name],
				[size]*8/1024,
				FILEPROPERTY([name],''SpaceUsed'')*8/1024
FROM		sysfiles;'


--INSERT	#DBStats
--SELECT	DBName,
--				Name,
--				TotalExtents * 64 / 1024,
--				UsedExtents * 64 / 1024
--FROM		#tempfilestats;


SELECT	DBName,
				FileGroupName,
				FileGroupType,
				TotalSizeInMB,
				UsedSizeInMb
FROM		#DBStats;

SELECT	DBName,
				FileGroupType,
				SUM(TotalSizeInMb) TotalSizeByType,
				SUM(UsedSizeInMb) TotalUsedSizeByType
FROM		#DBStats
GROUP BY DBName, FileGroupType
ORDER BY DBName, FileGroupType;

SELECT	FileGroupType,
				SUM(TotalSizeInMb) TotalSizeByType,
				SUM(UsedSizeInMb) TotalUsedSizeByType
FROM		#DBStats
GROUP BY FileGroupType


DROP TABLE #dbstats
