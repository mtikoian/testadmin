/****************Step1********************/
SELECT
            o.name AS TableName
            , i.name AS IndexName
            , i.type_desc AS IndexType
            , STATS_DATE(i.[object_id], i.index_id) AS StatisticsDate
FROM
            sys.indexes i
            JOIN sys.objects o ON i.[object_id] = o.[object_id]
WHERE
            o.type = 'U'     --Only get indexes for User Created Tables
            AND i.name IS NOT NULL
            AND o.name = 'TRANEVENT_DG'    --- To find stats of an object 
ORDER BY
            o.name, i.[type] 
/****************Step2********************/

DBCC SHOW_STATISTICS ('dbo.TRANEVENT_DG', 'PK_TRANEVENT_DG') WITH STAT_HEADER;

DBCC SHOW_STATISTICS ('dbo.TRANEVENT_DG', 'PK_TRANEVENT_DG'); -- specify table and index name you are instersted at 
--Look at the difference between rows/rows sampled and when stats were last updated on 
--density vector density* total rows(rows)
/****************Step3********************/
--DECLARE @version 

--select @@version


----------------------------------------------------------------------------------- 
---- The sample scripts are not supported under any Microsoft standard support 
---- program or service. The sample scripts are provided AS IS without warranty  
---- of any kind. Microsoft further disclaims all implied warranties including,  
---- without limitation, any implied warranties of merchantability or of fitness for 
---- a particular purpose. The entire risk arising out of the use or performance of  
---- the sample scripts and documentation remains with you. In no event shall 
---- Microsoft, its authors, or anyone else involved in the creation, production, or 
---- delivery of the scripts be liable for any damages whatsoever (including, 
---- without limitation, damages for loss of business profits, business interruption, 
---- loss of business information, or other pecuniary loss) arising out of the use 
---- of or inability to use the sample scripts or documentation, even if Microsoft 
---- has been advised of the possibility of such damages 
----------------------------------------------------------------------------------- 

--DECLARE @Build nvarchar(20);
--DECLARE @B1 nvarchar(20) ;
--DECLARE @B2 nvarchar(20);
--DECLARE @B3 nvarchar(20);
--DECLARE @BT1 nvarchar(20) ;
--DECLARE @BT2 nvarchar(20) ;
--SET @Build = CONVERT(nvarchar(20),(SELECT SERVERPROPERTY('ProductVersion')))
--SELECT @Build AS ProductVersion
--SET @B1 = SUBSTRING(@Build,0,PATINDEX('%.%',@Build))
--SET @BT1 = SUBSTRING(@Build,(LEN(@B1+'.')+1),LEN(@Build))
--SET @B2 = SUBSTRING(@BT1,0,PATINDEX('%.%',@BT1))
--SELECT @BT2 = SUBSTRING(@BT1,(LEN(@B2+'.')+1),LEN(@BT1))
--SET @B3 = SUBSTRING(@BT2,0,PATINDEX('%.%',@BT2))

--IF (CAST(@B1 AS int)=10 AND CAST(@B2 AS int)=50 AND CAST(@B3 AS int) >= 4000) OR (CAST(@B1 AS int)=11 AND CAST(@B2 AS int)=00 AND CAST(@B3 AS int)>= 4000)
--BEGIN
--SELECT obj.name AS ObjectName, obj.object_id, stat.name AS StatisticsName, stat.stats_id, last_updated, modification_counter
--FROM sys.objects AS obj
--JOIN sys.stats AS stat 
--ON stat.object_id = obj.object_id
--CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
--WHERE obj.type='U' and sp.modification_counter>1000
--END
--ELSE
--BEGIN
--	PRINT 'SQL Server version is not SQL Server 2008 R2 starting with Service Package 2 or SQL Server 2012 starting with Service Package 1';
--END




SELECT i.index_id, i.name, s.avg_fragmentation_in_percent
   FROM sys.dm_db_index_physical_stats (
      DB_ID(N'netikip'), 
      OBJECT_ID(N'tranevent_dg'),
      DEFAULT, DEFAULT, DEFAULT) s, sys.indexes i
   WHERE s.object_id = i.object_id
      AND s.index_id = i.index_id;

	 sp_whoisactive

	 ALTER INDEX TEDG_EvCrTmsInqCset_xnn ON [dbo].tranevent_dg REBUILD WITH (FILLFACTOR = 90,ONLINE = ON,SORT_IN_TEMPDB = ON)
	 ALTER INDEX ALL ON [dbo].fx_rate REBUILD WITH (FILLFACTOR = 90)
	 UPDATE STATISTICS [dbo].fx_rate
	 UPDATE STATISTICS [dbo].tranevent_dg TEDG_EvCrTmsInqCset_xnn