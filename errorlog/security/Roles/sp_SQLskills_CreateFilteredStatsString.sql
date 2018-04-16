USE [master];
GO

IF OBJECT_ID(N'sp_SQLskills_CreateFilteredStatsString') IS NOT NULL
	DROP PROCEDURE [sp_SQLskills_CreateFilteredStatsString];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [dbo].[sp_SQLskills_CreateFilteredStatsString]
(
	@schemaname					sysname	
	, @objectname				sysname
	, @columnname				sysname
	, @twopartname				nvarchar(520)
	, @MinValue					sql_variant
	, @MaxValue					sql_variant = NULL
	, @coldef					nvarchar(100)
	, @coldefcollationforcast	nvarchar(100)
	, @usecollation				bit
	, @fullscan					varchar(8) = NULL
	, @samplepercent			tinyint = NULL
)
AS
SET NOCOUNT ON

DECLARE @execstring				nvarchar(max)

SELECT @execstring = N'CREATE STATISTICS ' + 
						QUOTENAME(N'SQLskills_FS_'
							+ SUBSTRING(@schemaname, 1, 10) + N'_' 
							+ SUBSTRING(@objectname, 1, 32) + N'_' 
							+ SUBSTRING(@columnname, 1, 32) + N'_' 
							+ CASE
								WHEN SUBSTRING(@coldef, 1, 4) IN (N'date', N'time')
									THEN CONVERT(varchar, @MinValue, 126)  
								ELSE
									CONVERT(varchar, @MinValue)  
							  END
							+ CASE WHEN @MaxValue IS NOT NULL
                                THEN N'_'
							        + CASE
								        WHEN SUBSTRING(@coldef, 1, 4) IN (N'date', N'time')
									        THEN CONVERT(varchar, @MaxValue, 126)
								        ELSE
									        CONVERT(varchar, @MaxValue)
							          END
                                ELSE
                                    + N'_unbounded'
                              END
							, ']') 
						+ N' ON ' + @twopartname + N' (' + QUOTENAME(@columnname, N']') + N') ' 
						+ N' WHERE ' + QUOTENAME(@columnname, N']') 
						+ N' >= CAST(''' + REPLACE(CONVERT(varchar, @MinValue), '''', '''''') 
						+ N''' AS ' + @coldef 
						+ N') '
                        + CASE WHEN @MaxValue IS NOT NULL
                            THEN N' AND '
						    + QUOTENAME(@columnname, N']') 
						    + N' < CAST(''' + REPLACE(CONVERT(varchar, @MaxValue), '''', '''''') 
						    + N''' AS ' + @coldef 
                            + N') '
                          ELSE N''
                          END
						+ CASE 
							WHEN UPPER(@fullscan) = N'FULLSCAN'
								THEN N' WITH FULLSCAN'
							WHEN UPPER(@fullscan) = N'SAMPLE' 
									AND @samplepercent IS NOT NULL
								THEN N' WITH SAMPLE ' + CONVERT(varchar, @samplepercent)
							ELSE N''
						  END

--SELECT @execstring
EXEC (@execstring)
GO

EXEC [sys].[sp_MS_marksystemobject] 'sp_SQLskills_CreateFilteredStatsString';
GO