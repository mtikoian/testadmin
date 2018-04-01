USE CorruptDemoDB
GO
 
/* Create table to hold the results of DBCC CHECKDB */
 
/****** Object:  Table [dbo].[DBCCResults]    Script Date: 9/30/2014 11:00:47 AM ******/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
SET ANSI_PADDING ON
GO
 
IF OBJECT_ID('CorruptDemoDB..DBCCResults') IS NOT NULL
BEGIN
 
    DROP TABLE DBCCResults;
 
END
 
IF OBJECT_ID('CorruptDemoDB..PageResults') IS NOT NULL
BEGIN
 
    DROP TABLE PageResults;
 
END
 
CREATE TABLE PageResults
(ParentObject VARCHAR(100)
,[IDNumber] INT
,[PhoneNumber] VARCHAR(1000))
 
CREATE TABLE [dbo].[DBCCResults](
    [Error] [bigint] NULL,
    [Level] [bigint] NULL,
    [State] [bigint] NULL,
    [MessageText] [varchar](7000) NULL,
    [RepairLevel] [varchar](7000) NULL,
    [Status] [bigint] NULL,
    [DbId] [bigint] NULL,
    [DbFragID] [bigint] NULL,
    [ObjId] [bigint] NULL,
    [IndId] [bigint] NULL,
    [PartID] [bigint] NULL,
    [AllocID] [bigint] NULL,
    [RidDbid] [bigint] NULL,
    [RidPruid] [bigint] NULL,
    [File] [bigint] NULL,
    [Page] [bigint] NULL,
    [Slot] [bigint] NULL,
    [RefDbid] [bigint] NULL,
    [RefPruId] [bigint] NULL,
    [RefFile] [bigint] NULL,
    [RefPage] [bigint] NULL,
    [RefSlot] [bigint] NULL,
    [Allocation] [bigint] NULL
) ON [PRIMARY]
 
GO
 