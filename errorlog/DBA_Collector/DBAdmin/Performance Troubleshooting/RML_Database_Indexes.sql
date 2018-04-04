sp_helpindex 'readtrace.tblstatements'

USE [PerfAnalysis]
GO

/****** Object:  Index [tblStatements_12]    Script Date: 04/07/2011 14:59:24 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[ReadTrace].[tblStatements]') AND name = N'tblStatements_12')
DROP INDEX [tblStatements_12] ON [ReadTrace].[tblStatements] WITH ( ONLINE = OFF )
GO

USE [PerfAnalysis]
GO

/****** Object:  Index [tblStatements_12]    Script Date: 04/07/2011 14:59:25 ******/
CREATE NONCLUSTERED INDEX [tblStatements_12] ON [ReadTrace].[tblStatements] 
(
	[BatchSeq] ASC,
	[StmtSeq] ASC,
	[StartTime] ASC
)
INCLUDE
(
	HashId,
	Duration,
	Reads,
	Writes,
	CPU,
	Nestlevel,
	ParentStmtSeq
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

USE [PerfAnalysis]
GO

/****** Object:  Index [tblStatements_6]    Script Date: 04/07/2011 15:04:33 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[ReadTrace].[tblStatements]') AND name = N'tblStatements_6')
DROP INDEX [tblStatements_6] ON [ReadTrace].[tblStatements] WITH ( ONLINE = OFF )
GO

USE [PerfAnalysis]
GO

/****** Object:  Index [tblStatements_6]    Script Date: 04/07/2011 15:04:33 ******/
CREATE NONCLUSTERED INDEX [tblStatements_6] ON [ReadTrace].[tblStatements] 
(
	[StmtSeq] ASC
)
INCLUDE 
(
	HashID
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


USE [PerfAnalysis]
GO

/****** Object:  Index [tblStatements_10]    Script Date: 04/07/2011 16:14:28 ******/
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[ReadTrace].[tblStatements]') AND name = N'tblStatements_10')
DROP INDEX [tblStatements_10] ON [ReadTrace].[tblStatements] WITH ( ONLINE = OFF )
GO

USE [PerfAnalysis]
GO

/****** Object:  Index [tblStatements_10]    Script Date: 04/07/2011 16:14:29 ******/
CREATE NONCLUSTERED INDEX [tblStatements_10] ON [ReadTrace].[tblStatements] 
(
	[BatchSeq] ASC,
	[EndSeq] ASC
)
INCLUDE 
(	[EndTime],
	[NestLevel],
	[StmtSeq],
	[StartSeq]
) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
