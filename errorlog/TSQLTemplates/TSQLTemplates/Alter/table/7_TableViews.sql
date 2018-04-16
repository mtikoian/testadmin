/*
Table, View changes since the June 2011 review

Generated from RedGate SQL Compare.

*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
USE [$(PAS_DB)] 

GO
IF EXISTS (SELECT * FROM tempdb..sysobjects WHERE id=OBJECT_ID('tempdb..#tmpErrors')) DROP TABLE #tmpErrors
GO
CREATE TABLE #tmpErrors (Error int)
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION
GO
PRINT N'Dropping foreign keys from [dbo].[ArchiveSEIClientTransactionMessageHistory]'
GO
ALTER TABLE [dbo].[ArchiveSEIClientTransactionMessageHistory] DROP
CONSTRAINT [FK_ArchiveSEIClientTransactionMessageHistory_SEIClientTransactionID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [dbo].[SEIClientTransactionMessageHistory]'
GO
ALTER TABLE [dbo].[SEIClientTransactionMessageHistory] DROP
CONSTRAINT [FK_SEIClientTransactionMessageHistory_SEIClientTransactionID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping foreign keys from [dbo].[AccountQueue]'
GO
ALTER TABLE [dbo].[AccountQueue] DROP
CONSTRAINT [FK_AccountQueue_AccountID],
CONSTRAINT [FK_AccountQueue_AccountQueueStatusID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[ArchiveSEIClientTransactionMessageHistory]'
GO
ALTER TABLE [dbo].[ArchiveSEIClientTransactionMessageHistory] DROP CONSTRAINT [PK_CI_ArchiveSEIClientTransactionMessageHistory]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[SEIClientTransactionMessageHistory]'
GO
ALTER TABLE [dbo].[SEIClientTransactionMessageHistory] DROP CONSTRAINT [PK_CI_SEIClientTransactionMessageHistory]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[SEIClientTransactionMessageHistory]'
GO
ALTER TABLE [dbo].[SEIClientTransactionMessageHistory] DROP CONSTRAINT [DF_SEIClientTransactionMessageHistory_SystemCreateDate]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[SEIClientTransactionMessageHistory]'
GO
ALTER TABLE [dbo].[SEIClientTransactionMessageHistory] DROP CONSTRAINT [DF_SEIClientTransactionMessageHistory_SystemCreateUser]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[SEIClientTransactionMessageHistory]'
GO
ALTER TABLE [dbo].[SEIClientTransactionMessageHistory] DROP CONSTRAINT [DF_SEIClientTransactionMessageHistory_SystemUpdateDate]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[SEIClientTransactionMessageHistory]'
GO
ALTER TABLE [dbo].[SEIClientTransactionMessageHistory] DROP CONSTRAINT [DF_SEIClientTransactionMessageHistory_SystemUpdateUser]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[AccountQueue]'
GO
ALTER TABLE [dbo].[AccountQueue] DROP CONSTRAINT [PK_CI_AccountQueue]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[AccountQueue]'
GO
ALTER TABLE [dbo].[AccountQueue] DROP CONSTRAINT [DF_AccountQueue_PriorityNumber]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[AccountQueue]'
GO
ALTER TABLE [dbo].[AccountQueue] DROP CONSTRAINT [DF__AccountQu__Queue__3EBD23B6]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[AccountQueue]'
GO
ALTER TABLE [dbo].[AccountQueue] DROP CONSTRAINT [DF_AccountQueue_Retries]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[AccountQueue]'
GO
ALTER TABLE [dbo].[AccountQueue] DROP CONSTRAINT [DF_AccountQueue_SystemCreateDate]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[AccountQueue]'
GO
ALTER TABLE [dbo].[AccountQueue] DROP CONSTRAINT [DF_AccountQueue_SystemCreateUser]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[AccountQueue]'
GO
ALTER TABLE [dbo].[AccountQueue] DROP CONSTRAINT [DF_AccountQueue_SystemUpdateDate]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[AccountQueue]'
GO
ALTER TABLE [dbo].[AccountQueue] DROP CONSTRAINT [DF_AccountQueue_SystemUpdateUser]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[AccountQueueStatus]'
GO
ALTER TABLE [dbo].[AccountQueueStatus] DROP CONSTRAINT [PK_CI_AccountQueueStatus]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[AccountQueueStatus]'
GO
ALTER TABLE [dbo].[AccountQueueStatus] DROP CONSTRAINT [DF_AccountQueueStatus_SystemCreateDate]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[AccountQueueStatus]'
GO
ALTER TABLE [dbo].[AccountQueueStatus] DROP CONSTRAINT [DF_AccountQueueStatus_SystemCreateUser]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[AccountQueueStatus]'
GO
ALTER TABLE [dbo].[AccountQueueStatus] DROP CONSTRAINT [DF_AccountQueueStatus_SystemUpdateDate]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[AccountQueueStatus]'
GO
ALTER TABLE [dbo].[AccountQueueStatus] DROP CONSTRAINT [DF_AccountQueueStatus_SystemUpdateUser]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[PostReconResult]'
GO
ALTER TABLE [dbo].[PostReconResult] DROP CONSTRAINT [PK_CI_PostReconResult]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[PostReconResult]'
GO
ALTER TABLE [dbo].[PostReconResult] DROP CONSTRAINT [UC_PostReconResult_AccountID]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[PostReconResult]'
GO
ALTER TABLE [dbo].[PostReconResult] DROP CONSTRAINT [DF_PostReconResult_SystemCreateDate]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[PostReconResult]'
GO
ALTER TABLE [dbo].[PostReconResult] DROP CONSTRAINT [DF_PostReconResult_SystemCreateUser]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[PostReconResult]'
GO
ALTER TABLE [dbo].[PostReconResult] DROP CONSTRAINT [DF_PostReconResult_SystemUpdateDate]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[PostReconResult]'
GO
ALTER TABLE [dbo].[PostReconResult] DROP CONSTRAINT [DF_PostReconResult_SystemUpdateUser]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping constraints from [dbo].[PostReconResult]'
GO
ALTER TABLE [dbo].[PostReconResult] DROP CONSTRAINT [DF_PostReconResult_DaysAged]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping index [NCI_ArchiveSEIClientTransactionMessageHistory_SEIClientTransactionID] from [dbo].[ArchiveSEIClientTransactionMessageHistory]'
GO
DROP INDEX [NCI_ArchiveSEIClientTransactionMessageHistory_SEIClientTransactionID] ON [dbo].[ArchiveSEIClientTransactionMessageHistory]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping index [NCI_SEIClientTransactionMessageHistory_SEIClientTransactionID] from [dbo].[SEIClientTransactionMessageHistory]'
GO
DROP INDEX [NCI_SEIClientTransactionMessageHistory_SEIClientTransactionID] ON [dbo].[SEIClientTransactionMessageHistory]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping index [NCI_AccountQueue_AccountID] from [dbo].[AccountQueue]'
GO
DROP INDEX [NCI_AccountQueue_AccountID] ON [dbo].[AccountQueue]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping index [NCI_AccountQueue_AccountQueueStatusID] from [dbo].[AccountQueue]'
GO
DROP INDEX [NCI_AccountQueue_AccountQueueStatusID] ON [dbo].[AccountQueue]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping index [NCI_AccountQueue_AccountQueueStatusID] from [dbo].[AccountQueueStatus]'
GO
DROP INDEX [NCI_AccountQueue_AccountQueueStatusID] ON [dbo].[AccountQueueStatus]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[AccountQueueStatus]'
GO
DROP TABLE [dbo].[AccountQueueStatus]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[AccountQueue]'
GO
DROP TABLE [dbo].[AccountQueue]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping [dbo].[PostReconResult]'
GO
DROP TABLE [dbo].[PostReconResult]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Rebuilding [dbo].[ArchiveSEIClientTransactionMessageHistory]'
GO
CREATE TABLE [dbo].[tmp_rg_xx_ArchiveSEIClientTransactionMessageHistory]
(
[SEIClientTransactionMessageHistoryID] [int] NOT NULL,
[SEIClientTransactionID] [int] NOT NULL,
[MessageSource] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageStatusIndicator] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageResult] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FullMessage] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemCreateDate] [datetime] NOT NULL,
[SystemCreateUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SystemUpdateDate] [datetime] NOT NULL,
[SystemUpdateUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OverrodeTrxRecord] [bit] NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
INSERT INTO [dbo].[tmp_rg_xx_ArchiveSEIClientTransactionMessageHistory]([SEIClientTransactionMessageHistoryID], [SEIClientTransactionID], [MessageSource], [SystemCreateDate], [SystemCreateUser], [SystemUpdateDate], [SystemUpdateUser]) SELECT [SEIClientTransactionMessageHistoryID], [SEIClientTransactionID], [MessageSource], [SystemCreateDate], [SystemCreateUser], [SystemUpdateDate], [SystemUpdateUser] FROM [dbo].[ArchiveSEIClientTransactionMessageHistory]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
DROP TABLE [dbo].[ArchiveSEIClientTransactionMessageHistory]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_rename N'[dbo].[tmp_rg_xx_ArchiveSEIClientTransactionMessageHistory]', N'ArchiveSEIClientTransactionMessageHistory'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_CI_ArchiveSEIClientTransactionMessageHistory] on [dbo].[ArchiveSEIClientTransactionMessageHistory]'
GO
ALTER TABLE [dbo].[ArchiveSEIClientTransactionMessageHistory] ADD CONSTRAINT [PK_CI_ArchiveSEIClientTransactionMessageHistory] PRIMARY KEY CLUSTERED  ([SEIClientTransactionMessageHistoryID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [NCI_ArchiveSEIClientTransactionMessageHistory_SEIClientTransactionID] on [dbo].[ArchiveSEIClientTransactionMessageHistory]'
GO
CREATE NONCLUSTERED INDEX [NCI_ArchiveSEIClientTransactionMessageHistory_SEIClientTransactionID] ON [dbo].[ArchiveSEIClientTransactionMessageHistory] ([SEIClientTransactionID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[PASReportClient]'
GO
CREATE TABLE [dbo].[PASReportClient]
(
[PASReportClientID] [int] NOT NULL IDENTITY(1, 1),
[PASReportID] [int] NOT NULL,
[ClientID] [int] NULL,
[ReportDirectory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportFormat] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemCreateDate] [datetime] NOT NULL CONSTRAINT [DF_PASReportClient_SystemCreateDate] DEFAULT (getdate()),
[SystemCreateUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PASReportClient_SystemCreateUser] DEFAULT (suser_name()),
[SystemUpdateDate] [datetime] NOT NULL CONSTRAINT [DF_PASReportClient_SystemUpdateDate] DEFAULT (getdate()),
[SystemUpdateUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PASReportClient_SystemUpdateUser] DEFAULT (suser_name())
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_CI_PASReportClient] on [dbo].[PASReportClient]'
GO
ALTER TABLE [dbo].[PASReportClient] ADD CONSTRAINT [PK_CI_PASReportClient] PRIMARY KEY CLUSTERED  ([PASReportClientID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Rebuilding [dbo].[SEIClientTransactionMessageHistory]'
GO
CREATE TABLE [dbo].[tmp_rg_xx_SEIClientTransactionMessageHistory]
(
[SEIClientTransactionMessageHistoryID] [int] NOT NULL IDENTITY(1, 1),
[SEIClientTransactionID] [int] NOT NULL,
[MessageSource] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageStatusIndicator] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageResult] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullMessage] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemCreateDate] [datetime] NOT NULL CONSTRAINT [DF_SEIClientTransactionMessageHistory_SystemCreateDate] DEFAULT (getdate()),
[SystemCreateUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SEIClientTransactionMessageHistory_SystemCreateUser] DEFAULT (suser_sname()),
[SystemUpdateDate] [datetime] NOT NULL CONSTRAINT [DF_SEIClientTransactionMessageHistory_SystemUpdateDate] DEFAULT (getdate()),
[SystemUpdateUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SEIClientTransactionMessageHistory_SystemUpdateUser] DEFAULT (suser_sname()),
[OverrodeTrxRecord] [bit] NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
SET IDENTITY_INSERT [dbo].[tmp_rg_xx_SEIClientTransactionMessageHistory] ON
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
INSERT INTO [dbo].[tmp_rg_xx_SEIClientTransactionMessageHistory]([SEIClientTransactionMessageHistoryID], [SEIClientTransactionID], [MessageSource], [SystemCreateDate], [SystemCreateUser], [SystemUpdateDate], [SystemUpdateUser]) SELECT [SEIClientTransactionMessageHistoryID], [SEIClientTransactionID], [MessageSource], [SystemCreateDate], [SystemCreateUser], [SystemUpdateDate], [SystemUpdateUser] FROM [dbo].[SEIClientTransactionMessageHistory]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
SET IDENTITY_INSERT [dbo].[tmp_rg_xx_SEIClientTransactionMessageHistory] OFF
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
DECLARE @idVal BIGINT
SELECT @idVal = IDENT_CURRENT(N'[dbo].[SEIClientTransactionMessageHistory]')
IF @idVal IS NOT NULL
    DBCC CHECKIDENT(N'[dbo].[tmp_rg_xx_SEIClientTransactionMessageHistory]', RESEED, @idVal)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
DROP TABLE [dbo].[SEIClientTransactionMessageHistory]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
EXEC sp_rename N'[dbo].[tmp_rg_xx_SEIClientTransactionMessageHistory]', N'SEIClientTransactionMessageHistory'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_CI_SEIClientTransactionMessageHistory] on [dbo].[SEIClientTransactionMessageHistory]'
GO
ALTER TABLE [dbo].[SEIClientTransactionMessageHistory] ADD CONSTRAINT [PK_CI_SEIClientTransactionMessageHistory] PRIMARY KEY CLUSTERED  ([SEIClientTransactionMessageHistoryID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [NCI_SEIClientTransactionMessageHistory_SEIClientTransactionID] on [dbo].[SEIClientTransactionMessageHistory]'
GO
CREATE NONCLUSTERED INDEX [NCI_SEIClientTransactionMessageHistory_SEIClientTransactionID] ON [dbo].[SEIClientTransactionMessageHistory] ([SEIClientTransactionID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[AccountProcessingStatus]'
GO
CREATE TABLE [dbo].[AccountProcessingStatus]
(
[AccountProcessingStatusID] [int] NOT NULL IDENTITY(1, 1),
[AccountID] [int] NOT NULL,
[AccountProcessingStartDate] [datetime] NOT NULL,
[AccountProcessingEndDate] [datetime] NULL,
[AccountProcessingMessage] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrorFl] [bit] NULL,
[SystemCreateDate] [datetime] NOT NULL CONSTRAINT [DF_AccountProcessingStatus_SystemCreateDate] DEFAULT (getdate()),
[SystemCreateUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AccountProcessingStatus_SystemCreateUser] DEFAULT (suser_name()),
[SystemUpdateDate] [datetime] NULL CONSTRAINT [DF_AccountProcessingStatus_SystemUpdateDate] DEFAULT (getdate()),
[SystemUpdateUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_AccountProcessingStatus_SystemUpdateUser] DEFAULT (suser_name()),
[ErrorLocation] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_CI_AccountProcessingStatus] on [dbo].[AccountProcessingStatus]'
GO
ALTER TABLE [dbo].[AccountProcessingStatus] ADD CONSTRAINT [PK_CI_AccountProcessingStatus] PRIMARY KEY CLUSTERED  ([AccountProcessingStatusID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [NCI_AccountProcessingStatus_AccountID] on [dbo].[AccountProcessingStatus]'
GO
CREATE NONCLUSTERED INDEX [NCI_AccountProcessingStatus_AccountID] ON [dbo].[AccountProcessingStatus] ([AccountID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [NCI_AccountProcessingStatus_AccountProcessingStartDate] on [dbo].[AccountProcessingStatus]'
GO
CREATE NONCLUSTERED INDEX [NCI_AccountProcessingStatus_AccountProcessingStartDate] ON [dbo].[AccountProcessingStatus] ([AccountProcessingStartDate], [AccountProcessingEndDate])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[v_SEIClientTransactionALL]'
GO


 

ALTER VIEW [dbo].[v_SEIClientTransactionALL]
AS
       /***
================================================================================
Name : v_SEIClientTransactionALL
Author : LRhoads
Description : Used to pull ALL transactions back together for anything that needs
it.  The VAST majority of all PAS activities only need transactions "in flight"
and none of the archived ones (eg. ones that have already been sent to Trust)
===============================================================================
Parameters :
Name            |I/O|     Description

--------------------------------------------------------------------------------
Returns :
Name Type (length)     Description
--------------------------------------------------------------------------------
 

Return Value: Return code
Success : 0
Failure : @@ERROR
Error number and Description

Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR 2011.08.31  add source column
================================================================================
***/
SELECT  SEIClientTransactionID
      , AccountID
      , AggregatorRecordType
      , TransactionDate
      , AggregatorRecordBasis
      , CustodianAccountNumber
      , AggregatorTransactionType
      , SEITransactionTypeID
      , Portfolio
      , SecurityIdentifier
      , SecurityIdentifierType
      , SecurityDescription
      , SecurityType
      , SharesParValue
      , AccruedIncomeLocal
      , SettlementDate
      , TradeDate
      , CurrentCustodianSecurityPrice
      , CurrencyCodeLocal
      , OriginalFaceAmount
      , SettlementAmountLocal
      , CommissionsFees
      , BrokerName
      , CustodianTransactionDescription
      , CustodianTransactionReferenceNumber
      , CustodianTransactionRelatedReferenceNumber
      , AggregatorFileID
      , SourceRowID
      , TargetAccountingSystemName
      , TargetAccountingSystemClientID
      , TargetAccountingSystemAccountIdentifier
      , SEIClientTransactionStatusID
      , Reversal
      , AggregatorTransactionSubType
      , SentToTargetDate
      , CostBasisBase
      , CostBasisLocal
      , SystemCreateDate
      , SystemCreateUser
      , SystemUpdateDate
      , SystemUpdateUser
      , SendToTargetAccountingSystem
      , 'SCT' AS Source
FROM    dbo.SEIClientTransaction sct
UNION ALL
SELECT  SEIClientTransactionID
      , AccountID
      , AggregatorRecordType
      , TransactionDate
      , AggregatorRecordBasis
      , CustodianAccountNumber
      , AggregatorTransactionType
      , SEITransactionTypeID
      , Portfolio
      , SecurityIdentifier
      , SecurityIdentifierType
      , SecurityDescription
      , SecurityType
      , SharesParValue
      , AccruedIncomeLocal
      , SettlementDate
      , TradeDate
      , CurrentCustodianSecurityPrice
      , CurrencyCodeLocal
      , OriginalFaceAmount
      , SettlementAmountLocal
      , CommissionsFees
      , BrokerName
      , CustodianTransactionDescription
      , CustodianTransactionReferenceNumber
      , CustodianTransactionRelatedReferenceNumber
      , AggregatorFileID
      , SourceRowID
      , TargetAccountingSystemName
      , TargetAccountingSystemClientID
      , TargetAccountingSystemAccountIdentifier
      , SEIClientTransactionStatusID
      , Reversal
      , AggregatorTransactionSubType
      , SentToTargetDate
      , CostBasisBase
      , CostBasisLocal
      , SystemCreateDate
      , SystemCreateUser
      , SystemUpdateDate
      , SystemUpdateUser
      , 0
      , 'ASCT' AS Source
FROM    dbo.ArchiveSEIClientTransaction asct 
 



GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[v_SEIClientTransactionImpact]'
GO
EXEC sp_refreshview N'[dbo].[v_SEIClientTransactionImpact]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Refreshing [dbo].[v_SendToTargetCheck]'
GO
EXEC sp_refreshview N'[dbo].[v_SendToTargetCheck]'
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[UDF_ODTFailureList]'
GO
ALTER   FUNCTION [dbo].[UDF_ODTFailureList](@BalanceResultID INT)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @Output VARCHAR(8000)
	; 
    WITH  LastFailure
          AS ( SELECT   br.BalanceResultID
                      , sctmh.SEIClientTransactionID
                      , sctmh.MessageResult
                      , RANK() OVER ( PARTITION BY br.BalanceResultID, sctmh.SEIClientTransactionID ORDER BY sctmh.SystemUpdateDate DESC ) AS Rnk
               FROM     dbo.BalanceResult br
                        INNER JOIN dbo.BalanceResultTransaction brt ON br.BalanceResultID = brt.BalanceResultID
                        INNER JOIN SEIClientTransactionMessageHistory sctmh ON brt.SEIClientTransactionID = sctmh.SEIClientTransactionID
                        INNER JOIN dbo.SEIClientTransaction sct ON sctmh.SEIClientTransactionID = sct.SEIClientTransactionID
               --WHERE    br.SecurityIdentifier = sct.SecurityIdentifier
             )
           
       
	SELECT @Output =	COALESCE(@Output + ', ', '') + MessageResult 
       FROM     LastFailure sctmh 
       WHERE rnk = 1      
       AND   BalanceResultID =  @BalanceResultID  

	RETURN @Output
END
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[p_BurstTradeFilterPending]'
GO



ALTER   PROC [dbo].[p_BurstTradeFilterPending] (@Trades TradeFilterTrades READONLY, @PASAccountID INT  )
AS 
    BEGIN

/***
================================================================================
Name : p_BurstTradeFilterPending
Author : LRhoads - 01/24/2011 
Description : Takes the MOXY/TradeFilter trades in table parameter and updates/inserts
            corresponding rows in dbo.TradeFilterClientTransaction    
===============================================================================
Parameters :
Name            |I/O|     Description
@Trades         I           table parameter of trades
@PASAccountID   I           TAS's Account ID
--------------------------------------------------------------------------------
Returns :
Name Type (length)     Description
--------------------------------------------------------------------------------
 

Return Value: Return code
Success : 0
Failure : @@ERROR
Error number and Description

Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR  2011.01.24 Initial
LLR  2011.04.18 Modified to accept ClientID and get all for a client
LLR  2011.05.10 New parameter for the PASAccountID; we only want to upsert those.
                would only be an issue for the "really rich guy"
LLR  2011.10.12 T3K has null for cash, not 0, we we added isnulls                
================================================================================
***/
        SET NOCOUNT ON 
        SET XACT_ABORT ON 
--Declare

        DECLARE @sql_error INTEGER
        ,   @TradeFilterSourceID INTEGER 
        
                    
-- Initialize Variables
                
        BEGIN TRY
        SELECT  @sql_error = 0
        
        SELECT @TradeFilterSourceID = TradeFilterSourceID
        FROM dbo.TradeFilterSource tfs
        WHERE TradeFilterSourceName = 'Moxy'
 
        IF @TradeFilterSourceID IS NULL 
            SELECT @TradeFilterSourceID = 1
            
            BEGIN TRANSACTION                  

            MERGE INTO dbo.TradeFilterClientTransaction AS a
                USING 
                    ( SELECT    a2.AccountID
                              , Pending_Item_Num
                              , Portfolio_Num
                              , COALESCE(CUSIP, SEDOL, ISIN, OtherSecurityType) AS SecurityIdentifier
                              , Asset_Short_Nm
                              , ABS(Shares) AS SharesParValue -- PAS only has as positives...
                              , ISNULL(P1Cash,0) +ISNULL(P2Cash, 0) + ISNULL(P3Cash, 0) AS SettleAmount
                              , OriginalFace
                              , Trade_Cancelled_Fl
                              , Record_Complete_Fl
                              , Trade_Dt
                              , Settlement_Dt
                              , Last_Update_Dt
                              , CASE Trade_Type_Cd 
                                        WHEN 11 THEN 23
                                        WHEN 21 THEN 4
                                END AS SEITransactionTypeID --we only allow buys and sells
                              , @TradeFilterSourceID AS TradeFilterSourceID
                      FROM      @Trades m
                                INNER JOIN dbo.Account a2 ON m.TASAccountID = a2.TargetAccountingSystemAccountIdentifier
                                            AND a2.ClientID = m.ClientID
                      WHERE     Trade_Type_CD IN ( 11, 21 ) --Moxy only allows these 2 which map to 23 & 4
                                AND ( a2.InactiveDate IS NULL
                                      OR a2.InactiveDate > CURRENT_TIMESTAMP
                                    )
                                AND a2.AccountID = @PASAccountID  --for that "rich guy", only update this one...
                    ) AS s
                ON a.AccountID = s.AccountID
                    AND a.PendingItemNum = s.Pending_Item_Num
                WHEN MATCHED 
                    THEN   
             UPDATE      SET
                    a.Portfolio = s.Portfolio_Num
                  , a.SecurityIdentifier = s.SecurityIdentifier
                  , a.AssetShortNm = s.Asset_Short_Nm
                  , a.SharesParValue = s.SharesParValue
                  , a.SettleAmount = s.SettleAmount
                  , a.OriginalFace = s.OriginalFace
                  , a.TradeCancelledFl = s.Trade_Cancelled_Fl
                  , a.RecordCompleteFl = s.Record_Complete_Fl
                  , a.TradeDate = s.Trade_Dt
                  , a.SettlementDate = s.Settlement_dt
                  , a.SEITransactionTypeID = a.SEITransactionTypeID
                WHEN NOT MATCHED 
                    THEN   
                         INSERT (
                                  AccountID
                                , PendingItemNum
                                , Portfolio
                                , SecurityIdentifier
                                , AssetShortNm
                                , SharesParValue
                                , SettleAmount
                                , OriginalFace
                                , TradeCancelledFl
                                , RecordCompleteFl
                                , TradeDate
                                , SettlementDate
                                , SEITransactionTypeID 
                                , TradeFilterSourceID
                                )
                         VALUES ( s.AccountID
                                , s.Pending_Item_Num
                                , s.Portfolio_Num
                                , s.SecurityIdentifier
                                , s.Asset_Short_Nm
                                , s.SharesParValue
                                , s.SettleAmount
                                , s.OriginalFace
                                , s.Trade_Cancelled_Fl
                                , s.Record_Complete_Fl
                                , s.Trade_Dt
                                , s.Settlement_dt
                                , s.SEITransactionTypeID   
                                , s.TradeFilterSourceID
                                ) ;   
  
                                      
            COMMIT TRANSACTION                                             

        END TRY
        BEGIN CATCH

            DECLARE @errno INT
              , @errmsg VARCHAR(100)
              , @errsev INT
              , @errstate INT 

            SELECT  @errno = ERROR_NUMBER()
                  , @errmsg = ERROR_MESSAGE()
                  , @errsev = ERROR_SEVERITY()
                  , @errstate = ERROR_STATE() 

            IF @@Trancount > 0 
                ROLLBACK TRANSACTION
                         
            RAISERROR(@errmsg, @errsev, @errstate) 

        END CATCH

        IF @errno <> 0 
            RETURN @errno
        ELSE 
            RETURN @sql_error


    END








GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[v_SEIClientTransactionSearch]'
GO
 


ALTER VIEW [dbo].[v_SEIClientTransactionSearch]
AS
      /***
================================================================================
Name : v_SEIClientTransactionSearch]
Author : ASelke
Description : Pulls data back for UI Search
===============================================================================
Parameters :
Name            |I/O|     Description
--------------------------------------------------------------------------------
Returns :
Name Type (length)     Description
--------------------------------------------------------------------------------
 

Return Value: Return code
Success : 0
Failure : @@ERROR
Error number and Description

Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR 2011.05.24  Balance Table rename
LLR 2011.09.01  New columns added
================================================================================
***/
 
SELECT  sct.SEIClientTransactionID
      , a.AccountID
      , a.TargetAccountingSystemAccountIdentifier
      , a.CustodianAccountNumber
      , cl.ClientID
      , cl.ClientName
      , c.CustodianID
      , c.CustodianName
      , tas.TargetAccountingSystemID
      , tas.TargetAccountingSystemName
      , stt.SEITransactionTypeID
      , stt.TransactionType
      , i.CashImpact
      , sct.CustodianTransactionDescription
      , p.SendToTargetAccountingSystem
      , af.DateFileProcessed
      , af.FileNameDataDate
      , sct.Reversal
      , sct.SecurityIdentifier
      , sct.SecurityDescription
      , sct.SharesParValue
      , sct.AccruedIncomeLocal
      , sct.TransactionDate
      , sct.SettlementDate
      , sct.TradeDate
      , sct.OriginalFaceAmount
      , sct.SettlementAmountLocal
      , sct.CommissionsFees
      , sct.SentToTargetDate
      , scts.SEIClientTransactionStatusID
      , scts.StatusCode
      , sct.SystemCreateUser
      , sct.SystemUpdateUser
      , CASE WHEN sct.SentToTargetDate IS NOT NULL THEN 'Sent'
             WHEN ISNULL(sct.SendToTargetAccountingSystem, 0) = 1 THEN 'Ready'
             WHEN sct.SEIClientTransactionStatusID = 1
                  AND p.SEIClientTransactionID IS NOT NULL THEN 'NotReady'
             ELSE ISNULL(scts.StatusCode, 'Unknown')
        END AS GeneralTransactionState
      , CASE WHEN ISNULL(af.AggregatorFileID, 0) > 0 THEN 'Custodian'
             WHEN CHARINDEX('svcPAS', sct.SystemCreateUser) > 0 THEN 'Rule'
             ELSE 'User'
        END AS CreatedByUserType
      , sct.Source
      , sct.AggregatorFileID
      , sct.AggregatorRecordBasis
      , sct.AggregatorRecordType
      , sct.AggregatorTransactionSubType
      , sct.AggregatorTransactionType
      , sct.BrokerName
      , sct.CostBasisBase
      , sct.CostBasisLocal
      , sct.CurrencyCodeLocal
      , sct.CurrentCustodianSecurityPrice
      , sct.CustodianTransactionReferenceNumber
      , sct.CustodianTransactionRelatedReferenceNumber
      , sct.Portfolio
      , sct.SecurityIdentifierType
      , sct.SecurityType
      , sct.SourceRowID
      , sct.SystemCreateDate
      , sct.TargetAccountingSystemClientID
      , sct.SystemUpdateDate
      , ty.TransactionTypeDescription
FROM    v_SEIClientTransactionALL sct
        INNER JOIN Account a ON sct.AccountID = a.AccountID
        INNER JOIN Client cl ON a.ClientID = cl.ClientID
        INNER JOIN Custodian c ON a.CustodianID = c.CustodianID
        INNER JOIN SEITransactionType stt ON sct.SEITransactionTypeID = stt.SEITransactionTypeID
        INNER JOIN TargetAccountingSystem tas ON cl.TargetAccountingSystemID = tas.TargetAccountingSystemID
        INNER JOIN v_SEIClientTransactionImpact i ON sct.SEIClientTransactionID = i.SEIClientTransactionID
        INNER JOIN dbo.SEIClientTransactionStatus scts ON scts.SEIClientTransactionStatusID = sct.SEIClientTransactionStatusID
        LEFT OUTER JOIN ( SELECT    s.SEITransactionTypeID
                                  , t.TransactionTypeDescription
                          FROM      dbo.TargetAccountingSystemSEITransactionType s
                                    INNER JOIN dbo.TargetAccountingSystemTransactionType t ON s.TargetAccountingSystemTransactionTypeID = t.TargetAccountingSystemTransactionTypeID
                        ) ty ON ty.SEITransactionTypeID = sct.SEITransactionTypeID
        LEFT OUTER JOIN ( SELECT    sct2.SEIClientTransactionID
                                  , sct2.SendToTargetAccountingSystem
                          FROM      BalanceResult pbr
                                    INNER JOIN BalanceResultTransaction pbrt ON pbr.BalanceResultID = pbrt.BalanceResultID
                                    INNER JOIN dbo.SEIClientTransaction sct2 ON sct2.SEIClientTransactionID = pbrt.SEIClientTransactionID
                          WHERE     pbr.SecurityIdentifier = sct2.SecurityIdentifier
                        ) p ON sct.SEIClientTransactionID = p.SEIClientTransactionID
        LEFT OUTER JOIN AggregatorFile af ON sct.AggregatorFileID = af.AggregatorFileID 








GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[PASReport]'
GO
CREATE TABLE [dbo].[PASReport]
(
[PASReportID] [int] NOT NULL IDENTITY(1, 1),
[PASReportName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SystemCreateDate] [datetime] NOT NULL CONSTRAINT [DF_PASReport_SystemCreateDate] DEFAULT (getdate()),
[SystemCreateUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PASReport_SystemCreateUser] DEFAULT (suser_name()),
[SystemUpdateDate] [datetime] NOT NULL CONSTRAINT [DF_PASReport_SystemUpdateDate] DEFAULT (getdate()),
[SystemUpdateUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PASReport_SystemUpdateUser] DEFAULT (suser_name())
)
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating primary key [PK_CI_PASReport] on [dbo].[PASReport]'
GO
ALTER TABLE [dbo].[PASReport] ADD CONSTRAINT [PK_CI_PASReport] PRIMARY KEY CLUSTERED  ([PASReportID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [UI_PASReport_PASReportName] on [dbo].[PASReport]'
GO
CREATE NONCLUSTERED INDEX [UI_PASReport_PASReportName] ON [dbo].[PASReport] ([PASReportName])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[v_TradeFilterAdjustment]'
GO









ALTER VIEW [dbo].[v_TradeFilterAdjustment] AS 
 




/***
================================================================================
Name : v_TradeFilterAdjustment
Author : LRhoads April 2011 
Description : Used to adjust positions by the corresponding pending trades.  Pending
trades are also thought of as 'MOXY'. 

--for a BUY/SEITransactionTypeID = 4, we need to adjust SHARES DOWN by this amount and CASH UP by SettleAmount

--for a Sell/SEITransactionTypeID = 23, we need to adjust SHARES UP by this amount and CASH DOWN by SettleAmount

===============================================================================
Parameters :
Name            |I/O|     Description

--------------------------------------------------------------------------------
Returns :
Name Type (length)     Description
--------------------------------------------------------------------------------
 

Return Value: Return code
Success : 0
Failure : @@ERROR
Error number and Description

Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR 2011.04.01 Initial Creation
LLR 2011.10.12 Flip sign.  Buys & Sells values get subtracted, not added, so this
               process needs to take the existing:               
                  , SUM(-1 * SharesParValue) AS Adjustment
                  , SUM(ISNULL(SettleAmount, 0)) AS SettleAmount
               and make it:               
                  , SUM(SharesParValue) AS Adjustment
                  , SUM(-1 * ISNULL(SettleAmount, 0)) AS SettleAmount
================================================================================
***/

SELECT  AccountID
      , SecurityIdentifier
      , SUM(Adjustment) AS Adjustment
      , MAX(SystemUpdateDate) AS SystemUpdateDate
FROM    ( SELECT    AccountID
                  , SecurityIdentifier
                  , SUM(SharesParValue) AS Adjustment
                  , SUM(-1 * ISNULL(SettleAmount, 0)) AS SettleAmount
                  , MAX(SystemUpdateDate) AS SystemUpdateDate
          FROM      dbo.TradeFilterClientTransaction tfct 
          WHERE     SecurityIdentifier <> 'CASH'
                    AND SEITransactionTypeID = 4
                    AND TradeFilterClientTransactionMatchID IS NULL 
                    AND TradeCancelledFl = 0
                    
          GROUP BY  AccountID
                  , SecurityIdentifier
          UNION ALL
          SELECT    AccountID
                  , SecurityIdentifier
                  , SUM(-1 * SharesParValue)
                  , SUM(ISNULL(SettleAmount, 0))
                  , MAX(SystemUpdateDate) AS SystemUpdateDate
          FROM      dbo.TradeFilterClientTransaction tfct
          WHERE     SecurityIdentifier <> 'CASH'
                    AND SEITransactionTypeID = 23
                    AND TradeFilterClientTransactionMatchID IS NULL 
                    AND TradeCancelledFl = 0
          GROUP BY  AccountID
                  , SecurityIdentifier
        ) a
GROUP BY AccountID
      , SecurityIdentifier
UNION ALL
SELECT  AccountID
      , 'CASH'
      , SUM(SettleAmount) AS Adjustment
      , MAX(SystemUpdateDate) AS SystemUpdateDate
FROM    ( SELECT    AccountID
                  , SecurityIdentifier
                  , SUM(SharesParValue) AS Adjustment
                  , SUM(ISNULL( SettleAmount, 0)) AS SettleAmount --used to be -1*
                  , MAX(SystemUpdateDate) AS SystemUpdateDate
          FROM      dbo.TradeFilterClientTransaction tfct
          WHERE     SecurityIdentifier <> 'CASH'
                    AND SEITransactionTypeID = 4
                    AND TradeFilterClientTransactionMatchID IS NULL 
                    AND TradeCancelledFl = 0
          GROUP BY  AccountID
                  , SecurityIdentifier
          UNION ALL
          SELECT    AccountID
                  , SecurityIdentifier
                  , SUM(-1 * SharesParValue)
                  , SUM(ISNULL(SettleAmount, 0))
                  , MAX(SystemUpdateDate) AS SystemUpdateDate
          FROM      dbo.TradeFilterClientTransaction tfct
          WHERE     SecurityIdentifier <> 'CASH'
                    AND SEITransactionTypeID = 23
                    AND TradeFilterClientTransactionMatchID IS NULL 
                    AND TradeCancelledFl = 0
          GROUP BY  AccountID
                  , SecurityIdentifier
        ) a
GROUP BY AccountID   












GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[v_ODTSEIClientTransaction]'
GO



 
CREATE  VIEW [dbo].[v_ODTSEIClientTransaction]
AS

/***
================================================================================
Name : v_ODTSEIClientTransaction
Author : LRhoads  
Description : Used to present the required transaction columns for consumption
by ODT (WebOA).
===============================================================================
Parameters :
Name            |I/O|     Description    
--------------------------------------------------------------------------------
Returns :
Name Type (length)     Description
--------------------------------------------------------------------------------
 

Return Value: Return code
Success : 0
Failure : @@ERROR
Error number and Description

Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR 20110705    Initial Creation              
LLR 20110726    Add SendToTargetAccountingSystem and correct LEFT OUTER JOIN issue
LLR 20110901    Add new column for SecurityType
LLR 20110909    sign for Commission Adjustment
================================================================================
***/

      SELECT    sct.SEIClientTransactionID
              , stt.TransactionType
              , tastt.TransactionTypeDescription
              , a.TargetAccountingSystemAccountIdentifier
              , sct.Portfolio
              , sct.SecurityIdentifier
              , sct.SharesParValue
              , sct.AccruedIncomeLocal
              , sct.CurrentCustodianSecurityPrice
              , sct.SettlementDate
              , sct.TradeDate
              , sct.OriginalFaceAmount
              , sct.SettlementAmountLocal
              , sct.CommissionsFees
              , sct.BrokerName
              , sct.CustodianTransactionDescription
              , sct.Reversal
              , sct.CostBasisBase
              , sct.AccountID
              , cc.CodeValue 
              , a.ClientID
              , sct.SendToTargetAccountingSystem
              , sct.SecurityType
              --, CASE stt.CashImpact
              --      WHEN '+' THEN ISNULL(sct.CommissionsFees,0) * -1
              --      ELSE ISNULL(sct.CommissionsFees, 0)
              --  END AS CommissionAdjustment 
              , CASE stt.CashImpact
                    WHEN '-' THEN ISNULL(sct.CommissionsFees,0) * -1
                    ELSE ISNULL(sct.CommissionsFees, 0)
                END AS CommissionAdjustment 
      FROM      SEIClientTransaction sct
                INNER JOIN dbo.SEITransactionType stt ON sct.SEITransactionTypeID = stt.SEITransactionTypeID
                INNER JOIN dbo.TargetAccountingSystemSEITransactionType tasstt ON stt.SEITransactionTypeID = tasstt.SEITransactionTypeID
                INNER JOIN dbo.TargetAccountingSystemTransactionType tastt ON tasstt.TargetAccountingSystemTransactionTypeID = tastt.TargetAccountingSystemTransactionTypeID
                INNER JOIN dbo.Account a ON a.AccountID = sct.AccountID 
                LEFT OUTER JOIN (dbo.ClientCodeType cct 
                            INNER JOIN dbo.ClientCode cc ON cc.ClientCodeTypeID = cct.ClientCodeTypeID)
                        ON cc.ClientID = a.ClientID
                    AND cct.TargetAccountingSystemSEITransactionTypeID = tasstt.TargetAccountingSystemSEITransactionTypeID




GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating [dbo].[v_ClientCode]'
GO






CREATE VIEW [dbo].[v_ClientCode] AS 

/***
================================================================================
Name : v_ClientCode
Author : LRhoads  
Description : Used to present the required client codes for the various Receipt/
Disbursement/Reg/Loc/etc for a client.
===============================================================================
Parameters :
Name            |I/O|     Description    
--------------------------------------------------------------------------------
Returns :
Name Type (length)     Description
--------------------------------------------------------------------------------
 

Return Value: Return code
Success : 0
Failure : @@ERROR
Error number and Description

Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR 20110705    Initial Creation              
LLR 20110721    add ODT Overrides to results
LLR 20110728    add AccountID
================================================================================
***/
SELECT  a2.ClientID
      , [ADRF]
      , [AIP]
      , [AIS]
      , [BrkFin]
      , [DDC]
      , [DRC]
      , [DvRC]
      , [FR]
      , [FTD]
      , [FTW]
      , [InRC]
      , [ItRC]
      , [LOC]
      , [LTG]
      , [MISCFEE]
      , [REG]
      , [ROC]
      , [STG]
      , [UserOvr]
      , [LocOvr]
      , [ODTCntxt]
      , AccountID
FROM    ( SELECT    CodeValue
                  , ClientID
                  , StandardCode
          FROM      dbo.ClientCode cc
                    INNER JOIN dbo.ClientCodeType cct ON cc.ClientCodeTypeID = cct.ClientCodeTypeID
        ) AS a PIVOT ( MAX(a.CodeValue) 
                FOR StandardCode 
                IN ( [ADRF], [AIP], [AIS], [AUTOCOM], [BrkFin], [DDC], [DRC], [DREJSUSP], [DvRC], [FR], [FTD], [FTW],
                     [HREJSUSP], [InRC], [ItRC], [LOC], [LTG], [MISCFEE], [REG], [REJCRLID], [ROC], [STG], [UserOvr], [LocOvr],
        [ODTCntxt] ) ) AS p
    
        INNER JOIN dbo.Account a2
        ON a2.ClientID = p.ClientID  
    
 
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[v_SEIClientTransaction]'
GO


ALTER VIEW [dbo].[v_SEIClientTransaction] AS

/***
================================================================================
Name : v_SEIClientTransaction
Author : LRhoads - 09/09/2010 
Description : Pulls data back to present denormalized view of "Standardized" Transactions
===============================================================================
Parameters :
Name            |I/O|     Description
SourceFileName  I          Name of file moving to Normalized Positions         
--------------------------------------------------------------------------------
Returns :
Name Type (length)     Description
--------------------------------------------------------------------------------
 

Return Value: Return code
Success : 0
Failure : @@ERROR
Error number and Description

Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR 2010.12.27 Removed GETDATE to CURRENT_TIMESTAMP
LLR 2011.05.10 SEIClientTransactionStatusID no longer nullable
LLR 2011.07.26 AggregratorFile join needs to be LEFT OUTER JOIN
================================================================================
***/

SELECT 
sct.SEIClientTransactionID
, sct.AccountID
, sct.AggregatorRecordType 
, sct.TransactionDate
, sct.AggregatorRecordBasis
, sct.CustodianAccountNumber
, sct.AggregatorTransactionType
, sct.SEITransactionTypeID
, stt.TransactionType AS SEITransactionType
, sct.Portfolio
, sct.SecurityIdentifier
, sct.SecurityIdentifierType
, sct.SecurityDescription
, sct.SecurityType
, sct.SharesParValue
, sct.AccruedIncomeLocal
, sct.SettlementDate
, sct.TradeDate
, sct.CurrentCustodianSecurityPrice
, sct.CurrencyCodeLocal
, sct.OriginalFaceAmount
, sct.SettlementAmountLocal
, sct.CommissionsFees
, sct.BrokerName
, sct.CustodianTransactionDescription
, sct.CustodianTransactionReferenceNumber
, sct.CustodianTransactionRelatedReferenceNumber
, af.SourceFileName
, sct.SourceRowID
, sct.TargetAccountingSystemName
, sct.TargetAccountingSystemClientID
, sct.TargetAccountingSystemAccountIdentifier
, sct.SEIClientTransactionStatusID
, scts.StatusCode AS SEIClientTransactionStatusCode
, scts.StatusDescription AS SEIClientTransactionStatusDescription
, sct.Reversal
, sct.AggregatorTransactionSubType
, vac.Aggregatorid
, a.AggregatorName
, vac.CustodianID
, c2.CustodianName
, a2.ClientID
, c.ClientName
, sct.SystemCreateDate
, sct.SystemCreateUser
, sct.SystemUpdateDate
, sct.SystemUpdateUser
FROM dbo.SEIClientTransaction sct
INNER JOIN dbo.Account a2
ON a2.AccountID= sct.AccountID
INNER JOIN dbo.Client c
ON a2.ClientID = c.ClientID
INNER JOIN dbo.Custodian c2
ON c2.CustodianID = a2.CustodianID
INNER JOIN dbo.v_AggregatorCustodian vac
ON vac.CustodianID = c2.CustodianID
AND sct.TransactionDate BETWEEN vac.StartDate AND ISNULL(vac.EndDate, CURRENT_TIMESTAMP)
INNER JOIN dbo.Aggregator  a 
ON a.AggregatorID = vac.aggregatorid
INNER JOIN dbo.SEITransactionType stt
ON stt.SEITransactionTypeID = sct.SEITransactionTypeID
INNER JOIN dbo.SEIClientTransactionStatus scts
ON scts.SEIClientTransactionStatusID = sct.SEIClientTransactionStatusID
LEFT OUTER JOIN dbo.AggregatorFile af
ON af.AggregatorFileID = sct.AggregatorFileID






GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[AccountProcessingStatus]'
GO
ALTER TABLE [dbo].[AccountProcessingStatus] ADD
CONSTRAINT [FK_AccountProcessingStatus_AccountID] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([AccountID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[ArchiveSEIClientTransactionMessageHistory]'
GO
ALTER TABLE [dbo].[ArchiveSEIClientTransactionMessageHistory] ADD
CONSTRAINT [FK_ArchiveSEIClientTransactionMessageHistory_SEIClientTransactionID] FOREIGN KEY ([SEIClientTransactionID]) REFERENCES [dbo].[ArchiveSEIClientTransaction] ([SEIClientTransactionID]) ON DELETE CASCADE
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[PASReportClient]'
GO
ALTER TABLE [dbo].[PASReportClient] ADD
CONSTRAINT [FK_PASReportClient_PASReportID] FOREIGN KEY ([PASReportID]) REFERENCES [dbo].[PASReport] ([PASReportID]),
CONSTRAINT [FK_PASReportClient_ClientID] FOREIGN KEY ([ClientID]) REFERENCES [dbo].[Client] ([ClientID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding foreign keys to [dbo].[SEIClientTransactionMessageHistory]'
GO
ALTER TABLE [dbo].[SEIClientTransactionMessageHistory] ADD
CONSTRAINT [FK_SEIClientTransactionMessageHistory_SEIClientTransactionID] FOREIGN KEY ([SEIClientTransactionID]) REFERENCES [dbo].[SEIClientTransaction] ([SEIClientTransactionID]) ON DELETE CASCADE
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering trigger [dbo].[tUID_SEIClientTransaction_ForArchival] on [dbo].[SEIClientTransaction]'
GO

-- =============================================
-- Author:		LRhoads
-- Create date: 2011.04.26
-- Description:	Trigger to move rows to ArchiveSEIClientTransaction
--              AND ArchiveSEIClientTransactionMessageHistory (ODT results)
--              Only rows still actively involved in PreBalance are 
--              retained all others are archived.
-- CHANGE HISTORY:
-- LLR      2011.07.18  Added column for OverrodeTrxRecord
-- =============================================
ALTER TRIGGER [dbo].[tUID_SEIClientTransaction_ForArchival] ON [dbo].[SEIClientTransaction]
       AFTER INSERT,  UPDATE, DELETE
AS
       BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON ;
	
             DECLARE @SEIClientTransaction TABLE
                     (
                       SEIClientTransactionID INT
                     )
             BEGIN TRY
        
                   BEGIN TRAN 
        
                   INSERT   @SEIClientTransaction
                            (
                              SEIClientTransactionID
                            )
                            SELECT  DISTINCT sct.SEIClientTransactionID
                            FROM    dbo.SEIClientTransaction sct
                                    INNER JOIN dbo.SEIClientTransactionStatus scts ON sct.SEIClientTransactionStatusID = scts.SEIClientTransactionStatusID
                                    INNER JOIN INSERTED i ON i.SEIClientTransactionID = sct.SEIClientTransactionID
                                    --we do "logical" deletes, so always inserted...
                            WHERE   PreBalance = 0 
        
                
                   INSERT   dbo.ArchiveSEIClientTransaction
                            (
                              SEIClientTransactionID
                            , AccountID
                            , AggregatorRecordType
                            , TransactionDate
                            , AggregatorRecordBasis
                            , CustodianAccountNumber
                            , AggregatorTransactionType
                            , SEITransactionTypeID
                            , Portfolio
                            , SecurityIdentifier
                            , SecurityIdentifierType
                            , SecurityDescription
                            , SecurityType
                            , SharesParValue
                            , AccruedIncomeLocal
                            , SettlementDate
                            , TradeDate
                            , CurrentCustodianSecurityPrice
                            , CurrencyCodeLocal
                            , OriginalFaceAmount
                            , SettlementAmountLocal
                            , CommissionsFees
                            , BrokerName
                            , CustodianTransactionDescription
                            , CustodianTransactionReferenceNumber
                            , CustodianTransactionRelatedReferenceNumber
                            , AggregatorFileID
                            , SourceRowID
                            , TargetAccountingSystemName
                            , TargetAccountingSystemClientID
                            , TargetAccountingSystemAccountIdentifier
                            , SEIClientTransactionStatusID
                            , Reversal
                            , AggregatorTransactionSubType
                            , SentToTargetDate
                            , CostBasisBase
                            , CostBasisLocal
                            , SystemCreateDate
                            , SystemCreateUser
                            , SystemUpdateDate
                            , SystemUpdateUser 
                            , TradeFilterClientTransactionMatchID
                            )
                            SELECT  sct.SEIClientTransactionID
                                  , AccountID
                                  , AggregatorRecordType
                                  , TransactionDate
                                  , AggregatorRecordBasis
                                  , CustodianAccountNumber
                                  , AggregatorTransactionType
                                  , SEITransactionTypeID
                                  , Portfolio
                                  , SecurityIdentifier
                                  , SecurityIdentifierType
                                  , SecurityDescription
                                  , SecurityType
                                  , SharesParValue
                                  , AccruedIncomeLocal
                                  , SettlementDate
                                  , TradeDate
                                  , CurrentCustodianSecurityPrice
                                  , CurrencyCodeLocal
                                  , OriginalFaceAmount
                                  , SettlementAmountLocal
                                  , CommissionsFees
                                  , BrokerName
                                  , CustodianTransactionDescription
                                  , CustodianTransactionReferenceNumber
                                  , CustodianTransactionRelatedReferenceNumber
                                  , AggregatorFileID
                                  , SourceRowID
                                  , TargetAccountingSystemName
                                  , TargetAccountingSystemClientID
                                  , TargetAccountingSystemAccountIdentifier
                                  , SEIClientTransactionStatusID
                                  , Reversal
                                  , AggregatorTransactionSubType
                                  , SentToTargetDate
                                  , CostBasisBase
                                  , CostBasisLocal
                                  , SystemCreateDate
                                  , SystemCreateUser
                                  , SystemUpdateDate
                                  , SystemUpdateUser
                                  , TradeFilterClientTransactionMatchID
                            FROM    @SEIClientTransaction t
                                    INNER JOIN dbo.SEIClientTransaction sct ON t.SEIClientTransactionID = sct.SEIClientTransactionID
        
                   INSERT   dbo.ArchiveSEIClientTransactionMessageHistory
                            (
                              SEIClientTransactionMessageHistoryID
                            , SEIClientTransactionID
                            , MessageSource
                            , MessageStatusIndicator
                            , MessageResult
                            , FullMessage
                            , OverrodeTrxRecord
                            , SystemCreateDate
                            , SystemCreateUser
                            , SystemUpdateDate
                            , SystemUpdateUser
                            )
                            SELECT  sctmh.SEIClientTransactionMessageHistoryID
                                  , sctmh.SEIClientTransactionID
                                  , sctmh.MessageSource
                                  , sctmh.MessageStatusIndicator
                                  , sctmh.MessageResult
                                  , sctmh.FullMessage
                                  , sctmh.OverrodeTrxRecord
                                  , sctmh.SystemCreateDate
                                  , sctmh.SystemCreateUser
                                  , sctmh.SystemUpdateDate
                                  , sctmh.SystemUpdateUser
                            FROM    @SEIClientTransaction sct
                                    INNER JOIN dbo.SEIClientTransactionMessageHistory sctmh ON sct.SEIClientTransactionID = sctmh.SEIClientTransactionID
        
                   DELETE   sctmh
                   FROM     @SEIClientTransaction sct
                            INNER JOIN dbo.SEIClientTransactionMessageHistory sctmh ON sct.SEIClientTransactionID = sctmh.SEIClientTransactionID
                
                
                   DELETE   sct
                   FROM     @SEIClientTransaction t
                            INNER JOIN dbo.SEIClientTransaction sct ON t.SEIClientTransactionID = sct.SEIClientTransactionID
        
        
                   COMMIT TRAN
            
             END TRY 
            
             BEGIN CATCH
                   IF @@TRANCOUNT > 0 
                      ROLLBACK TRAN 
            
                   DECLARE @errmsg VARCHAR(500)
                         , @errsev INT
                         , @errstate INT
                         , @sql_error INT 
             
                   SELECT   @sql_error = ERROR_NUMBER()
                          , @errmsg = ERROR_MESSAGE()
                          , @errsev = ERROR_SEVERITY()
                          , @errstate = ERROR_STATE() ;
 
                   RAISERROR(@errmsg, @errsev, @errstate) ;

             END CATCH ;

       END















GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering trigger order for [dbo].[tUID_SEIClientTransaction_ForArchival] on [dbo].[SEIClientTransaction]'
GO
EXEC sp_settriggerorder N'[dbo].[tUID_SEIClientTransaction_ForArchival]', 'last', 'update', null
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[ti_AccountProcessingStatus] on [dbo].[AccountProcessingStatus]'
GO
/* 
 * TRIGGER: dbo.ti_AccountProcessingStatus 
 */

CREATE TRIGGER dbo.ti_AccountProcessingStatus ON dbo.AccountProcessingStatus FOR INSERT 
AS
/***
================================================================================
Author : LRhoads 2011.08.05
Description : Trigger
===============================================================================
Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR  2011.08.05 Initial Creation
================================================================================
***/
UPDATE a 
SET 
     SystemCreateDate = CURRENT_TIMESTAMP
     ,SystemCreateUser = CASE 
                    WHEN UPDATE (SystemUpdateUser)  THEN i.SystemUpdateUser
                         ELSE SUSER_NAME()
                    END 
     , SystemUpdateDate = CURRENT_TIMESTAMP
     ,SystemUpdateUser = CASE 
                    WHEN UPDATE (SystemUpdateUser)  THEN i.SystemUpdateUser
                         ELSE SUSER_NAME()
                    END 
FROM AccountProcessingStatus a INNER JOIN INSERTED i
     ON a.AccountProcessingStatusID = i.AccountProcessingStatusID
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[tu_AccountProcessingStatus] on [dbo].[AccountProcessingStatus]'
GO
/* 
 * TRIGGER: dbo.tu_AccountProcessingStatus 
 */

CREATE TRIGGER dbo.tu_AccountProcessingStatus ON dbo.AccountProcessingStatus FOR UPDATE 
AS
/***
================================================================================
Author : LRhoads 2011.08.05
Description : Trigger
===============================================================================
Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR  2011.08.05 Initial Creation
================================================================================
***/
UPDATE a 
SET 
     SystemUpdateDate = CURRENT_TIMESTAMP
     ,SystemUpdateUser = CASE 
                    WHEN UPDATE (SystemUpdateUser)  THEN i.SystemUpdateUser
                         ELSE SUSER_NAME()
                    END 
FROM AccountProcessingStatus a INNER JOIN INSERTED i
     ON a.AccountProcessingStatusID = i.AccountProcessingStatusID
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[ti_PASReport] on [dbo].[PASReport]'
GO





/* 
 * TRIGGER: dbo.ti_PASReport 
 */




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER[dbo].[ti_PASReport] ON [dbo].[PASReport] FOR INSERT 
AS
/***
================================================================================
Author : LRhoads 2010.12.27
Description : Trigger
===============================================================================
Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR  2010.12.27 Trigger altered to modify GETDATE to CURRENT_TIMESTAMP
================================================================================
***/
UPDATE a 
SET 
     SystemCreateDate = CURRENT_TIMESTAMP
     ,SystemCreateUser = CASE 
                    WHEN UPDATE (SystemUpdateUser)  THEN i.SystemUpdateUser
                         ELSE SUSER_NAME()
                    END 
FROM PASReport a INNER JOIN INSERTED i
     ON a.PASReportID = i.PASReportID



GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[tu_PASReport] on [dbo].[PASReport]'
GO





/* 
 * TRIGGER: dbo.tu_PASReport 
 */




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER[dbo].[tu_PASReport] ON [dbo].[PASReport] FOR UPDATE 
AS
/***
================================================================================
Author : LRhoads 2010.12.27
Description : Trigger
===============================================================================
Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR  2010.12.27 Trigger altered to modify GETDATE to CURRENT_TIMESTAMP
================================================================================
***/
UPDATE a 
SET 
     SystemUpdateDate = CURRENT_TIMESTAMP
     ,SystemUpdateUser = CASE 
                    WHEN UPDATE (SystemUpdateUser)  THEN i.SystemUpdateUser
                         ELSE SUSER_NAME()
                    END 
FROM PASReport a INNER JOIN INSERTED i
     ON a.PASReportID = i.PASReportID



GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[ti_PASReportClient] on [dbo].[PASReportClient]'
GO
/* 
 * TRIGGER: dbo.ti_PASReportClient 
 */




CREATE TRIGGER[dbo].[ti_PASReportClient] ON dbo.PASReportClient FOR INSERT 
AS
/***
================================================================================
Author : LRhoads 2010.12.27
Description : Trigger
===============================================================================
Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR  2010.12.27 Trigger altered to modify GETDATE to CURRENT_TIMESTAMP
================================================================================
***/
UPDATE a 
SET 
     SystemCreateDate = CURRENT_TIMESTAMP
     ,SystemUpdateDate = CURRENT_TIMESTAMP
     ,SystemUpdateUser = CASE 
                    WHEN UPDATE (SystemUpdateUser)  THEN i.SystemUpdateUser
                         ELSE SUSER_NAME()
                    END 
     ,SystemCreateUser = CASE 
                    WHEN UPDATE (SystemUpdateUser)  THEN i.SystemUpdateUser
                         ELSE SUSER_NAME()
                    END 
FROM PASReportClient a INNER JOIN INSERTED i
     ON a.PASReportClientID = i.PASReportClientID
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[tu_PASReportClient] on [dbo].[PASReportClient]'
GO
/* 
 * TRIGGER: dbo.tu_PASReportClient 
 */

CREATE TRIGGER[dbo].[tu_PASReportClient] ON dbo.PASReportClient FOR UPDATE 
AS
/***
================================================================================
Author : LRhoads 2010.12.27
Description : Trigger
===============================================================================
Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR  2010.12.27 Trigger altered to modify GETDATE to CURRENT_TIMESTAMP
================================================================================
***/
UPDATE a 
SET 
     SystemUpdateDate = CURRENT_TIMESTAMP
     ,SystemUpdateUser = CASE 
                    WHEN UPDATE (SystemUpdateUser)  THEN i.SystemUpdateUser
                         ELSE SUSER_NAME()
                    END 
FROM PASReportClient a INNER JOIN INSERTED i
     ON a.PASReportClientID = i.PASReportClientID
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[ti_SEIClientTransactionMessageHistory] on [dbo].[SEIClientTransactionMessageHistory]'
GO
/* 
 * TRIGGER: dbo.ti_SEIClientTransactionMessageHistory
 */

CREATE TRIGGER[dbo].[ti_SEIClientTransactionMessageHistory] ON dbo.SEIClientTransactionMessageHistory FOR INSERT 
AS
/***
================================================================================
Author : LRhoads 2010.12.27
Description : Trigger
===============================================================================
Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR 2011.03.16 Initial Creation
================================================================================
***/
UPDATE a 
SET 
     SystemCreateDate = CURRENT_TIMESTAMP
     ,SystemUpdateUser = CASE 
                    WHEN UPDATE (SystemUpdateUser)  THEN i.SystemUpdateUser
                         ELSE SUSER_NAME()
                    END 
FROM SEIClientTransactionMessageHistory a INNER JOIN INSERTED i
     ON a.SEIClientTransactionMessageHistoryID = i.SEIClientTransactionMessageHistoryID
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating trigger [dbo].[tu_SEIClientTransactionMessageHistory] on [dbo].[SEIClientTransactionMessageHistory]'
GO
CREATE TRIGGER[dbo].[tu_SEIClientTransactionMessageHistory] ON dbo.SEIClientTransactionMessageHistory FOR UPDATE 
AS
/***
================================================================================
Author : LRhoads 2010.12.27
Description : Trigger
===============================================================================
Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
LLR 2011.03.16 Initial Creation
================================================================================
***/
UPDATE a 
SET 
     SystemUpdateDate = CURRENT_TIMESTAMP
     ,SystemUpdateUser = CASE 
                    WHEN UPDATE (SystemUpdateUser)  THEN i.SystemUpdateUser
                         ELSE SUSER_NAME()
                    END 
FROM SEIClientTransactionMessageHistory a INNER JOIN INSERTED i
     ON a.SEIClientTransactionMessageHistoryID = i.SEIClientTransactionMessageHistoryID
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering permissions on [dbo].[TradeFilterTrades]'
GO
GRANT EXECUTE ON TYPE:: [dbo].[TradeFilterTrades] TO [prole_PAS_APP]
GO
PRINT N'Altering permissions on [dbo].[TASPosition]'
GO
GRANT EXECUTE ON TYPE:: [dbo].[TASPosition] TO [prole_PAS_APP]
GO
PRINT N'Altering permissions on [dbo].[BalanceAccount]'
GO
GRANT EXECUTE ON TYPE:: [dbo].[BalanceAccount] TO [prole_PAS_APP]
GO
PRINT N'Altering permissions on [dbo].[BalanceTransaction]'
GO
GRANT EXECUTE ON TYPE:: [dbo].[BalanceTransaction] TO [prole_PAS_APP]
GO
PRINT N'Altering permissions on [dbo].[v_ClientCode]'
GO
GRANT SELECT ON  [dbo].[v_ClientCode] TO [prole_PAS_APP]
GRANT SELECT ON  [dbo].[v_ClientCode] TO [prole_PAS_SSIS]
GO
PRINT N'Altering permissions on [dbo].[v_ODTSEIClientTransaction]'
GO
GRANT SELECT ON  [dbo].[v_ODTSEIClientTransaction] TO [prole_PAS_APP]
GRANT SELECT ON  [dbo].[v_ODTSEIClientTransaction] TO [prole_PAS_SSIS]
GO
PRINT N'Altering permissions on [dbo].[v_SEIClientTransaction]'
GO
GRANT SELECT ON  [dbo].[v_SEIClientTransaction] TO [prole_PAS_APP]
GRANT SELECT ON  [dbo].[v_SEIClientTransaction] TO [prole_PAS_SSIS]
GRANT SELECT ON  [dbo].[v_SEIClientTransaction] TO [prole_PAS_SSRS]
GO
PRINT N'Altering permissions on [dbo].[p_BurstTASPosition]'
GO
REVOKE EXECUTE ON  [dbo].[p_BurstTASPosition] TO [prole_PAS_SSIS]
REVOKE EXECUTE ON  [dbo].[p_BurstTASPosition] TO [prole_PAS_SSRS]
GO
PRINT N'Altering permissions on [dbo].[p_BurstTradeFilterPending]'
GO
GRANT EXECUTE ON  [dbo].[p_BurstTradeFilterPending] TO [prole_PAS_APP]
GO
IF EXISTS (SELECT * FROM #tmpErrors) ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT>0 BEGIN
PRINT 'The database update succeeded'
COMMIT TRANSACTION
END
ELSE PRINT 'The database update failed'
GO
DROP TABLE #tmpErrors
GO
