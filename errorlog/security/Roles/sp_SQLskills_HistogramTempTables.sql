USE [master];
GO

IF OBJECT_ID(N'sp_SQLskills_HistogramTempTables') IS NOT NULL
	DROP PROCEDURE [dbo].[sp_SQLskills_HistogramTempTables];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [dbo].[sp_SQLskills_HistogramTempTables]
(
	@management		varchar(5) = 'QUERY'
)
AS
SET NOCOUNT ON

IF UPPER(@management) = 'QUERY'
	SELECT 'SELECT * FROM [tempdb]..' + QUOTENAME([tso].[name]) AS 'Queries'
	FROM [tempdb].[sys].[objects] AS [tso]
	WHERE [tso].[name] LIKE 'SQLskills[_]HistogramAnalysisOf%'

IF UPPER(@management) = 'DROP'
	SELECT 'DROP TABLE [tempdb]..' + QUOTENAME([tso].[name]) AS 'Drop statements'
	FROM [tempdb].[sys].[objects] AS [tso]
	WHERE [tso].[name] LIKE 'SQLskills[_]HistogramAnalysisOf%'
GO

EXEC [sys].[sp_MS_marksystemobject] 'sp_SQLskills_HistogramTempTables';
GO

