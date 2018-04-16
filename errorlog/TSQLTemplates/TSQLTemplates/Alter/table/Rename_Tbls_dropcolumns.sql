
USE [$(PAS_DB)] 

SET ANSI_WARNINGS OFF
SET NOCOUNT ON 

SET NUMERIC_ROUNDABORT OFF 
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
IF EXISTS ( SELECT  *
            FROM    tempdb..sysobjects
            WHERE   id = OBJECT_ID('tempdb..#tmpErrors') ) 
   DROP TABLE #tmpErrors
GO
CREATE TABLE #tmpErrors ( Error INT )
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
GO
BEGIN TRANSACTION


BEGIN TRAN


--Update Control table for logging
UPDATE    dbo.DB_CONTROL
SET       Structure_Version_Tag = 'Dxxx'
      , Code_Version_Tag = 'Dxxx'
      , Last_Change_Process_Dt = CURRENT_TIMESTAMP

RAISERROR (N'Update of DB Version.....Done!', 10, 1) WITH NOWAIT ;
      
--First do renames of "PreBalance" items to "Balance"

PRINT '============================='
PRINT '     Begin sp_renames'
PRINT '============================='

IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResult_MissingData')
EXEC sp_rename 'DF_PreBalanceResult_MissingData', 'DF_BalanceResult_MissingData'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResult_NegativePosition')
EXEC sp_rename 'DF_PreBalanceResult_NegativePosition', 'DF_BalanceResult_NegativePosition'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResult_SendToTargetAccountingSystem')
EXEC sp_rename 'DF_PreBalanceResult_SendToTargetAccountingSystem', 'DF_BalanceResult_SendToTargetAccountingSystem'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResult_SystemCreateDate')
EXEC sp_rename 'DF_PreBalanceResult_SystemCreateDate', 'DF_BalanceResult_SystemCreateDate'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResult_SystemCreateUser')
EXEC sp_rename 'DF_PreBalanceResult_SystemCreateUser', 'DF_BalanceResult_SystemCreateUser'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResult_SystemUpdateDate')
EXEC sp_rename 'DF_PreBalanceResult_SystemUpdateDate', 'DF_BalanceResult_SystemUpdateDate'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResult_SystemUpdateUser')
EXEC sp_rename 'DF_PreBalanceResult_SystemUpdateUser', 'DF_BalanceResult_SystemUpdateUser'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResultComment_SystemCreateDate')
EXEC sp_rename 'DF_PreBalanceResultComment_SystemCreateDate', 'DF_BalanceResultComment_SystemCreateDate'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResultComment_SystemCreateUser')
EXEC sp_rename 'DF_PreBalanceResultComment_SystemCreateUser', 'DF_BalanceResultComment_SystemCreateUser'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResultComment_SystemUpdateDate')
EXEC sp_rename 'DF_PreBalanceResultComment_SystemUpdateDate', 'DF_BalanceResultComment_SystemUpdateDate'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResultComment_SystemUpdateUser')
EXEC sp_rename 'DF_PreBalanceResultComment_SystemUpdateUser', 'DF_BalanceResultComment_SystemUpdateUser'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResultTransaction_SystemCreateDate')
EXEC sp_rename 'DF_PreBalanceResultTransaction_SystemCreateDate', 'DF_BalanceResultTransaction_SystemCreateDate'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResultTransaction_SystemCreateUser')
EXEC sp_rename 'DF_PreBalanceResultTransaction_SystemCreateUser', 'DF_BalanceResultTransaction_SystemCreateUser'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResultTransaction_SystemUpdateDate')
EXEC sp_rename 'DF_PreBalanceResultTransaction_SystemUpdateDate', 'DF_BalanceResultTransaction_SystemUpdateDate'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='DF_PreBalanceResultTransaction_SystemUpdateUser')
EXEC sp_rename 'DF_PreBalanceResultTransaction_SystemUpdateUser', 'DF_BalanceResultTransaction_SystemUpdateUser'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='FK_PreBalanceResult_LastPendingStatusID')
EXEC sp_rename 'FK_PreBalanceResult_LastPendingStatusID', 'FK_BalanceResult_LastPendingStatusID'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='FK_PreBalanceResult_PendingStatusID')
EXEC sp_rename 'FK_PreBalanceResult_PendingStatusID', 'FK_BalanceResult_PendingStatusID'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='FK_PreBalanceResultComment_PreBalanceResultCommentTypeID')
EXEC sp_rename 'FK_PreBalanceResultComment_PreBalanceResultCommentTypeID', 'FK_BalanceResultComment_BalanceResultCommentTypeID'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='FK_PreBalanceResultComment_PreBalanceResultID')
EXEC sp_rename 'FK_PreBalanceResultComment_PreBalanceResultID', 'FK_BalanceResultComment_BalanceResultID'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='FK_PreBalanceResultTransaction_PreBalanceResultID')
EXEC sp_rename 'FK_PreBalanceResultTransaction_PreBalanceResultID', 'FK_BalanceResultTransaction_BalanceResultID'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='FK_PreBalanceResultTransaction_SEIClientTransactionID')
EXEC sp_rename 'FK_PreBalanceResultTransaction_SEIClientTransactionID', 'FK_BalanceResultTransaction_SEIClientTransactionID'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='PK_CI_PreBalanceResult')
EXEC sp_rename 'PK_CI_PreBalanceResult', 'PK_CI_BalanceResult'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='PK_CI_PreBalanceResultComment')
EXEC sp_rename 'PK_CI_PreBalanceResultComment', 'PK_CI_BalanceResultComment'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='PK_CI_PreBalanceResultCommentType')
EXEC sp_rename 'PK_CI_PreBalanceResultCommentType', 'PK_CI_BalanceResultCommentType'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='PK_CI_PreBalanceResultTransaction')
EXEC sp_rename 'PK_CI_PreBalanceResultTransaction', 'PK_CI_BalanceResultTransaction'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='UC_PreBalanceResult_AccountID')
EXEC sp_rename 'UC_PreBalanceResult_AccountID', 'UC_BalanceResult_AccountID'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_ArchivePreBalance')
EXEC sp_rename 'p_ArchivePreBalance', 'p_ArchiveBalance'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_DeletePreBalanceResult')
EXEC sp_rename 'p_DeletePreBalanceResult', 'p_DeleteBalanceResult'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_DeletePreBalanceResultComment')
EXEC sp_rename 'p_DeletePreBalanceResultComment', 'p_DeleteBalanceResultComment'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_DeletePreBalanceResultCommentType')
EXEC sp_rename 'p_DeletePreBalanceResultCommentType', 'p_DeleteBalanceResultCommentType'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_GetPreBalanceResultLockStatus')
EXEC sp_rename 'p_GetPreBalanceResultLockStatus', 'p_GetBalanceResultLockStatus'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_InsertPreBalanceResult')
EXEC sp_rename 'p_InsertPreBalanceResult', 'p_InsertBalanceResult'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_InsertPreBalanceResultComment')
EXEC sp_rename 'p_InsertPreBalanceResultComment', 'p_InsertBalanceResultComment'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_InsertPreBalanceResultCommentType')
EXEC sp_rename 'p_InsertPreBalanceResultCommentType', 'p_InsertBalanceResultCommentType'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_LockPreBalanceResult')
EXEC sp_rename 'p_LockPreBalanceResult', 'p_LockBalanceResult'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_PASRulePreBalanceCreateMMSweepTrx')
EXEC sp_rename 'p_PASRulePreBalanceCreateMMSweepTrx', 'p_PASRuleBalanceCreateMMSweepTrx'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_PASRulePreBalanceDayZeroBuyFrees')
EXEC sp_rename 'p_PASRulePreBalanceDayZeroBuyFrees', 'p_PASRuleBalanceDayZeroBuyFrees'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_RunPreBalance')
EXEC sp_rename 'p_RunPreBalance', 'p_RunBalance'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_UnlockPreBalanceResult')
EXEC sp_rename 'p_UnlockPreBalanceResult', 'p_UnlockBalanceResult'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_UpdatePreBalanceResult')
EXEC sp_rename 'p_UpdatePreBalanceResult', 'p_UpdateBalanceResult'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_UpdatePreBalanceResultComment')
EXEC sp_rename 'p_UpdatePreBalanceResultComment', 'p_UpdateBalanceResultComment'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='p_UpdatePreBalanceResultCommentType')
EXEC sp_rename 'p_UpdatePreBalanceResultCommentType', 'p_UpdateBalanceResultCommentType'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='UDF_PreBalanceResultsToBeLocked')
EXEC sp_rename 'UDF_PreBalanceResultsToBeLocked', 'UDF_BalanceResultsToBeLocked'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='ti_PreBalanceResult')
EXEC sp_rename 'ti_PreBalanceResult', 'ti_BalanceResult'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='ti_PreBalanceResultComment')
EXEC sp_rename 'ti_PreBalanceResultComment', 'ti_BalanceResultComment'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='ti_PreBalanceResultCommentType')
EXEC sp_rename 'ti_PreBalanceResultCommentType', 'ti_BalanceResultCommentType'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='tu_PreBalanceResult')
EXEC sp_rename 'tu_PreBalanceResult', 'tu_BalanceResult'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='tu_PreBalanceResultComment')
EXEC sp_rename 'tu_PreBalanceResultComment', 'tu_BalanceResultComment'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='tu_PreBalanceResultCommentType')
EXEC sp_rename 'tu_PreBalanceResultCommentType', 'tu_BalanceResultCommentType'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='ArchivePreBalanceResult')
EXEC sp_rename 'ArchivePreBalanceResult', 'ArchiveBalanceResult'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='ArchivePreBalanceResultComment')
EXEC sp_rename 'ArchivePreBalanceResultComment', 'ArchiveBalanceResultComment'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='PreBalanceResult')
EXEC sp_rename 'PreBalanceResult', 'BalanceResult'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='PreBalanceResultComment')
EXEC sp_rename 'PreBalanceResultComment', 'BalanceResultComment'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='PreBalanceResultCommentType')
EXEC sp_rename 'PreBalanceResultCommentType', 'BalanceResultCommentType'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM sysobjects WHERE name ='PreBalanceResultTransaction')
EXEC sp_rename 'PreBalanceResultTransaction', 'BalanceResultTransaction'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO


IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME ='PreBalanceResultCommentTypeCode' AND TABLE_NAME = 'BalanceResultCommentType')
EXEC sp_rename 'BalanceResultCommentType.PreBalanceResultCommentTypeCode', 'BalanceResultCommentType.BalanceResultCommentTypeCode', 'COLUMN'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME ='PreBalanceResultCommentTypeDescription' AND TABLE_NAME = 'BalanceResultCommentType')
EXEC sp_rename 'BalanceResultCommentType.PreBalanceResultCommentTypeDescription', 'BalanceResultCommentType.BalanceResultCommentTypeDescription', 'COLUMN'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME ='PreBalanceResultCommentTypeID' AND TABLE_NAME = 'BalanceResultCommentType')
EXEC sp_rename 'BalanceResultCommentType.PreBalanceResultCommentTypeID', 'BalanceResultCommentType.BalanceResultCommentTypeID', 'COLUMN'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME ='PreBalanceResultID' AND TABLE_NAME = 'BalanceResultTransaction')
EXEC sp_rename 'BalanceResultTransaction.PreBalanceResultID', 'BalanceResultTransaction.BalanceResultID', 'COLUMN'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME ='PreBalanceResultID' AND TABLE_NAME = 'ArchiveBalanceResultComment')
EXEC sp_rename 'ArchiveBalanceResultComment.PreBalanceResultID', 'ArchiveBalanceResultComment.BalanceResultID', 'COLUMN'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME ='PreBalanceResultCommentID' AND TABLE_NAME = 'ArchiveBalanceResultComment')
EXEC sp_rename 'ArchiveBalanceResultComment.PreBalanceResultCommentID', 'ArchiveBalanceResultComment.BalanceResultCommentID', 'COLUMN'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME ='PreBalanceResultCommentTypeID' AND TABLE_NAME = 'ArchiveBalanceResultComment')
EXEC sp_rename 'ArchiveBalanceResultComment.PreBalanceResultCommentTypeID', 'ArchiveBalanceResultComment.BalanceResultCommentTypeID', 'COLUMN'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME ='PreBalanceResultID' AND TABLE_NAME = 'ArchiveBalanceResult')
EXEC sp_rename 'ArchiveBalanceResult.PreBalanceResultID', 'ArchiveBalanceResult.BalanceResultID', 'COLUMN'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME ='PreBalanceResultID' AND TABLE_NAME = 'TargetAccountingSystemFileDetail')
EXEC sp_rename 'TargetAccountingSystemFileDetail.PreBalanceResultID', 'TargetAccountingSystemFileDetail.BalanceResultID', 'COLUMN'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME ='PreBalanceResultID' AND TABLE_NAME = 'BalanceResult')
EXEC sp_rename 'BalanceResult.PreBalanceResultID', 'BalanceResult.BalanceResultID', 'COLUMN'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME ='PreBalanceResultID' AND TABLE_NAME = 'BalanceResultComment')
EXEC sp_rename 'BalanceResultComment.PreBalanceResultID', 'BalanceResultComment.BalanceResultID', 'COLUMN'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME ='PreBalanceResultCommentID' AND TABLE_NAME = 'BalanceResultComment')
EXEC sp_rename 'BalanceResultComment.PreBalanceResultCommentID', 'BalanceResultComment.BalanceResultCommentID', 'COLUMN'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME ='PreBalanceResultCommentTypeID' AND TABLE_NAME = 'BalanceResultComment')
EXEC sp_rename 'BalanceResultComment.PreBalanceResultCommentTypeID', 'BalanceResultComment.BalanceResultCommentTypeID', 'COLUMN'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO

      
PRINT '============================='
PRINT '     Completed sp_renames'
PRINT '============================='
    
    
 --do some data that isn't dependent on DDL changes
UPDATE  dbo.SEITransactionType
SET     CashImpact = 0
      , SharesImpact = 0
      , AccruedInterestImpact = 0
WHERE   TransactionType = 'Amortization'
     
PRINT '>>> ' + CAST(@@ROWCOUNT AS VARCHAR) + ' SEITransactionType row(s) updated'


UPDATE dbo.SEITransactionType
SET SharesImpact = 0
WHERE TransactionType = 'Return of Capital'

PRINT '>>> ' + CAST(@@ROWCOUNT AS VARCHAR) + ' SEITransactionType row(s) updated'



UPDATE  dbo.SEIClientPositionStatus
SET     StatusCode = 'Valid'
      , StatusDescription = 'Valid, no known issue'
          
PRINT '>>> ' + CAST(@@ROWCOUNT AS VARCHAR) + ' SEIClientPositionStatus row(s) updated'

INSERT  dbo.SEIClientPositionStatus
        (
          StatusCode
        , StatusDescription
        , PreBalance
            
        )
VALUES  (
          'NegPos'
        , 'Negative Position'
        , 1
            
        )

PRINT '>>> ' + CAST(@@ROWCOUNT AS VARCHAR) + ' SEIClientPositionStatus row(s) inserted'
    
    
UPDATE  dbo.SEIClientPosition
SET     SEIClientPositionStatusID = CASE WHEN SEIClientPositionStatusID = 1 THEN 2
                                         WHEN SEIClientPositionStatusID IS NULL THEN 1
                                    END 
              
     
PRINT '>>> ' + CAST(@@ROWCOUNT AS VARCHAR) + ' SEIClientPosition row(s) updated'
    
UPDATE  dbo.SEIClientTransactionStatus
SET     StatusCode = 'Valid'
      , StatusDescription = 'Valid, no known issue'
      , PreBalance = 1
WHERE   SEIClientTransactionStatusID = 1    
     
PRINT '>>> ' + CAST(@@ROWCOUNT AS VARCHAR) + ' SEIClientTransactionStatus row(s) updated'
        
--pass update columns so trigger does not overwrite the system values.        
UPDATE  dbo.SEIClientTransaction
SET     SEIClientTransactionStatusID = 1
      , SystemUpdateDate = SystemUpdateDate
      , SystemUpdateUser = SystemUpdateUser
WHERE   SEIClientTransactionStatusID IS NULL 
    
PRINT '>>> ' + CAST(@@ROWCOUNT AS VARCHAR) + ' SEIClientTransaction row(s) updated'
                       
UPDATE  dbo.PASRule
SET     PASRuleProc = REPLACE(PASRuleProc, 'PreBalance', 'Balance')
WHERE   PASRuleProc LIKE '%PreBalance%'
    
PRINT '>>> ' + CAST(@@ROWCOUNT AS VARCHAR) + ' PASRule row(s) updated'
     

DELETE  dbo.PASConfiguration
WHERE   PASConfigurationName = 'GetODRPositions'  
    
PRINT '>>> ' + CAST(@@ROWCOUNT AS VARCHAR) + ' PASConfiguration row(s) deleted'

UPDATE  dbo.AggregatorCustodian
SET     AggregatorCustodianIdentifier = AggregatorCustodianDescription
WHERE   AggregatorID = 2
    
PRINT '>>> ' + CAST(@@ROWCOUNT AS VARCHAR) + ' AggregatorCustodian row(s) updated'


--these were being done via ISIN code Xref -- need to be done via XREF tbl
IF NOT EXISTS ( SELECT  1
                FROM    dbo.ClientSecurityIdentifierXREF csix
                WHERE   ClientID = 1
                        AND TargetAccountingSystemSecurityIdentifier = 'B29WS06'
                        AND CustodianSecurityIdentifier = 'CA29251ZAS61' ) 
   INSERT   dbo.ClientSecurityIdentifierXREF
            (
              ClientID
            , CustodianSecurityIdentifier
            , TargetAccountingSystemSecurityIdentifier
            )
   VALUES   (
              1
            , 'CA29251ZAS61'
            , 'B29WS06'
            )

IF NOT EXISTS ( SELECT  1
                FROM    dbo.ClientSecurityIdentifierXREF csix
                WHERE   ClientID = 1
                        AND TargetAccountingSystemSecurityIdentifier = 'B4PM5Y7'
                        AND CustodianSecurityIdentifier = 'CA135087ZJ69' ) 
   INSERT   dbo.ClientSecurityIdentifierXREF
            (
              ClientID
            , CustodianSecurityIdentifier
            , TargetAccountingSystemSecurityIdentifier
            )
   VALUES   (
              1
            , 'CA135087ZJ69'
            , 'B4PM5Y7'
            )
         

PRINT '>>> ClientSecurityIdentifierXREF row(s) inserted'





 
GO
PRINT N'Dropping foreign keys from [dbo].[BalanceResultComment]'
GO

IF ( SELECT COUNT(1) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
            WHERE TABLE_NAME ='BalanceResultComment' 
            AND CONSTRAINT_NAME IN ('FK_BalanceResultComment_BalanceResultID','FK_BalanceResultComment_BalanceResultCommentTypeID' )) = 2
ALTER TABLE [dbo].[BalanceResultComment] DROP
CONSTRAINT [FK_BalanceResultComment_BalanceResultID],
CONSTRAINT [FK_BalanceResultComment_BalanceResultCommentTypeID]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping foreign keys from [dbo].[BalanceResultTransaction]'
GO
IF ( SELECT COUNT(1) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
            WHERE TABLE_NAME ='BalanceResultTransaction' 
            AND CONSTRAINT_NAME IN('FK_BalanceResultTransaction_BalanceResultID','FK_BalanceResultTransaction_SEIClientTransactionID' )) = 2
ALTER TABLE [dbo].[BalanceResultTransaction] DROP
CONSTRAINT [FK_BalanceResultTransaction_BalanceResultID],
CONSTRAINT [FK_BalanceResultTransaction_SEIClientTransactionID]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping foreign keys from [dbo].[BalanceResult]'
GO
IF ( SELECT COUNT(1) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
            WHERE TABLE_NAME ='BalanceResult' 
            AND CONSTRAINT_NAME IN('FK_BalanceResult_PendingStatusID','FK_BalanceResult_LastPendingStatusID' )) = 2
ALTER TABLE [dbo].[BalanceResult] DROP
CONSTRAINT [FK_BalanceResult_PendingStatusID],
CONSTRAINT [FK_BalanceResult_LastPendingStatusID]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping foreign keys from [dbo].[SEIClientTransaction]'
GO
IF ( SELECT COUNT(1) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
            WHERE TABLE_NAME ='SEIClientTransaction' 
            AND CONSTRAINT_NAME IN('FK_SEIClientTransaction_TargetAccountingSystemFileID' )) = 1
ALTER TABLE [dbo].[SEIClientTransaction] DROP
CONSTRAINT [FK_SEIClientTransaction_TargetAccountingSystemFileID]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping foreign keys from [dbo].[TargetAccountingSystemFileDetail]'
GO
IF ( SELECT COUNT(1) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
            WHERE TABLE_NAME ='TargetAccountingSystemFileDetail' 
            AND CONSTRAINT_NAME IN('FK_TargetAccountingSystemFileDetail_TargetAccountingSystemFileID' )) = 1
ALTER TABLE [dbo].[TargetAccountingSystemFileDetail] DROP
CONSTRAINT [FK_TargetAccountingSystemFileDetail_TargetAccountingSystemFileID]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping foreign keys from [dbo].[TargetAccountingSystemFile]'
GO
IF ( SELECT COUNT(1) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
            WHERE TABLE_NAME ='TargetAccountingSystemFile' 
            AND CONSTRAINT_NAME IN('FK_TargetAccountingSystemFile_ClientID' , 'FK_TargetAccountingSystemFile_TargetAccountingSystemID' )) = 2
ALTER TABLE [dbo].[TargetAccountingSystemFile] DROP
CONSTRAINT [FK_TargetAccountingSystemFile_ClientID],
CONSTRAINT [FK_TargetAccountingSystemFile_TargetAccountingSystemID]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResult]'
GO
IF ( SELECT COUNT(1) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
            WHERE TABLE_NAME ='BalanceResult' 
            AND CONSTRAINT_NAME IN('PK_CI_BalanceResult' )) = 1
ALTER TABLE [dbo].[BalanceResult] DROP CONSTRAINT [PK_CI_BalanceResult]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO 
PRINT N'Dropping constraints from [dbo].[BalanceResult]'
GO
IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE 
            WHERE TABLE_NAME ='BalanceResult' 
            AND CONSTRAINT_NAME = 'UC_BalanceResult_AccountID' ) 
ALTER TABLE [dbo].[BalanceResult] DROP CONSTRAINT [UC_BalanceResult_AccountID]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResult]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_BalanceResult_MissingData'
            AND xtype = 'd') 
ALTER TABLE [dbo].[BalanceResult] DROP CONSTRAINT [DF_BalanceResult_MissingData]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResult]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_BalanceResult_NegativePosition'
            AND xtype = 'd') 
ALTER TABLE [dbo].[BalanceResult] DROP CONSTRAINT [DF_BalanceResult_NegativePosition]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResult]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_BalanceResult_SystemCreateDate'
            AND xtype = 'd') 
ALTER TABLE [dbo].[BalanceResult] DROP CONSTRAINT [DF_BalanceResult_SystemCreateDate]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResult]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_BalanceResult_SystemCreateUser'
            AND xtype = 'd') 
ALTER TABLE [dbo].[BalanceResult] DROP CONSTRAINT [DF_BalanceResult_SystemCreateUser]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResult]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_BalanceResult_SystemUpdateDate'
            AND xtype = 'd') 
ALTER TABLE [dbo].[BalanceResult] DROP CONSTRAINT [DF_BalanceResult_SystemUpdateDate]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResult]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_BalanceResult_SystemUpdateUser'
            AND xtype = 'd') 
ALTER TABLE [dbo].[BalanceResult] DROP CONSTRAINT [DF_BalanceResult_SystemUpdateUser]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResult]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_BalanceResult_SendToTargetAccountingSystem'
            AND xtype = 'd') 
ALTER TABLE [dbo].[BalanceResult] DROP CONSTRAINT [DF_BalanceResult_SendToTargetAccountingSystem]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResultComment]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'PK_CI_BalanceResultComment'
            AND xtype = 'd') 
ALTER TABLE [dbo].[BalanceResultComment] DROP CONSTRAINT [PK_CI_BalanceResultComment]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResultComment]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_BalanceResultComment_SystemCreateDate'
            AND xtype = 'd') 
ALTER TABLE [dbo].[BalanceResultComment] DROP CONSTRAINT [DF_BalanceResultComment_SystemCreateDate]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResultComment]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_BalanceResultComment_SystemCreateUser'
            AND xtype = 'd') 
ALTER TABLE [dbo].[BalanceResultComment] DROP CONSTRAINT [DF_BalanceResultComment_SystemCreateUser]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResultComment]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_BalanceResultComment_SystemUpdateDate'
            AND xtype = 'd') 
ALTER TABLE [dbo].[BalanceResultComment] DROP CONSTRAINT [DF_BalanceResultComment_SystemUpdateDate]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResultComment]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_BalanceResultComment_SystemUpdateUser'
            AND xtype = 'd')
ALTER TABLE [dbo].[BalanceResultComment] DROP CONSTRAINT [DF_BalanceResultComment_SystemUpdateUser]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResultCommentType]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'PK_CI_BalanceResultCommentType'
            AND xtype = 'd')
ALTER TABLE [dbo].[BalanceResultCommentType] DROP CONSTRAINT [PK_CI_BalanceResultCommentType]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[BalanceResultTransaction]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'PK_CI_BalanceResultTransaction'
            AND xtype = 'PK')
ALTER TABLE [dbo].[BalanceResultTransaction] DROP CONSTRAINT [PK_CI_BalanceResultTransaction]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemPosition]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'PK_CI_TargetAccountingSystemPosition'
            AND xtype = 'PK')
ALTER TABLE [dbo].[TargetAccountingSystemPosition] DROP CONSTRAINT [PK_CI_TargetAccountingSystemPosition]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemPosition]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_TargetAccountingSystemPosition_SystemCreateDate'
            AND xtype = 'D')
ALTER TABLE [dbo].[TargetAccountingSystemPosition] DROP CONSTRAINT [DF_TargetAccountingSystemPosition_SystemCreateDate]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemPosition]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_TargetAccountingSystemPosition_SystemCreateUser'
            AND xtype = 'D')
ALTER TABLE [dbo].[TargetAccountingSystemPosition] DROP CONSTRAINT [DF_TargetAccountingSystemPosition_SystemCreateUser]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemPosition]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_TargetAccountingSystemPosition_SystemUpdateDate'
            AND xtype = 'D')
ALTER TABLE [dbo].[TargetAccountingSystemPosition] DROP CONSTRAINT [DF_TargetAccountingSystemPosition_SystemUpdateDate]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemPosition]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_TargetAccountingSystemPosition_SystemUpdateUser'
            AND xtype = 'D')
ALTER TABLE [dbo].[TargetAccountingSystemPosition] DROP CONSTRAINT [DF_TargetAccountingSystemPosition_SystemUpdateUser]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemFile]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'PK_CI_TargetAccountingSystemFile'
            AND xtype = 'PK')
ALTER TABLE [dbo].[TargetAccountingSystemFile] DROP CONSTRAINT [PK_CI_TargetAccountingSystemFile]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemFile]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_TargetAccountingSystemFile_NumberRecordsOutput'
            AND xtype = 'D')
ALTER TABLE [dbo].[TargetAccountingSystemFile] DROP CONSTRAINT [DF_TargetAccountingSystemFile_NumberRecordsOutput]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemFile]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_TargetAccountingSystemFile_DateFileProcessed'
            AND xtype = 'D')
ALTER TABLE [dbo].[TargetAccountingSystemFile] DROP CONSTRAINT [DF_TargetAccountingSystemFile_DateFileProcessed]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemFile]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_TargetAccountingSystemFile_SystemCreateDate'
            AND xtype = 'D')
ALTER TABLE [dbo].[TargetAccountingSystemFile] DROP CONSTRAINT [DF_TargetAccountingSystemFile_SystemCreateDate]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemFile]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_TargetAccountingSystemFile_SystemCreateUser'
            AND xtype = 'D')
ALTER TABLE [dbo].[TargetAccountingSystemFile] DROP CONSTRAINT [DF_TargetAccountingSystemFile_SystemCreateUser]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemFile]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_TargetAccountingSystemFile_SystemUpdateDate'
            AND xtype = 'D')
ALTER TABLE [dbo].[TargetAccountingSystemFile] DROP CONSTRAINT [DF_TargetAccountingSystemFile_SystemUpdateDate]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemFile]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_TargetAccountingSystemFile_SystemUpdateUser'
            AND xtype = 'D')
ALTER TABLE [dbo].[TargetAccountingSystemFile] DROP CONSTRAINT [DF_TargetAccountingSystemFile_SystemUpdateUser]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemFileDetail]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'PK_CI_TargetAccountingSystemFileDetail'
            AND xtype = 'PK')
ALTER TABLE [dbo].[TargetAccountingSystemFileDetail] DROP CONSTRAINT [PK_CI_TargetAccountingSystemFileDetail]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemFileDetail]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_TargetAccountingSystemFileDetail_SystemCreateDate'
            AND xtype = 'D')
ALTER TABLE [dbo].[TargetAccountingSystemFileDetail] DROP CONSTRAINT [DF_TargetAccountingSystemFileDetail_SystemCreateDate]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemFileDetail]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_TargetAccountingSystemFileDetail_SystemCreateUser'
            AND xtype = 'D')
ALTER TABLE [dbo].[TargetAccountingSystemFileDetail] DROP CONSTRAINT [DF_TargetAccountingSystemFileDetail_SystemCreateUser]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemFileDetail]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_TargetAccountingSystemFileDetail_SystemUpdateDate'
            AND xtype = 'D')
ALTER TABLE [dbo].[TargetAccountingSystemFileDetail] DROP CONSTRAINT [DF_TargetAccountingSystemFileDetail_SystemUpdateDate]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[TargetAccountingSystemFileDetail]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_TargetAccountingSystemFileDetail_SystemUpdateUser'
            AND xtype = 'D')
ALTER TABLE [dbo].[TargetAccountingSystemFileDetail] DROP CONSTRAINT [DF_TargetAccountingSystemFileDetail_SystemUpdateUser]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping constraints from [dbo].[Stage_TargetAccountingSystemPosition]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'DF_Stage_TargetAccountingSystemPosition_SystemCreateDate'
            AND xtype = 'D')
ALTER TABLE [dbo].[Stage_TargetAccountingSystemPosition] DROP CONSTRAINT [DF_Stage_TargetAccountingSystemPosition_SystemCreateDate]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping index [UI_PreBalanceResultCommentType_PreBalanceResultCommentTypeCode] from [dbo].[BalanceResultCommentType]'
GO
IF EXISTS ( SELECT 1 FROM sysindexes
            WHERE name = 'UI_PreBalanceResultCommentType_PreBalanceResultCommentTypeCode' )
DROP INDEX [UI_PreBalanceResultCommentType_PreBalanceResultCommentTypeCode] ON [dbo].[BalanceResultCommentType]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping index [NCI_SEIClientTransaction_TargetAccountingSystemFileID] from [dbo].[SEIClientTransaction]'
GO
IF EXISTS ( SELECT 1 FROM sysindexes
            WHERE name = 'NCI_SEIClientTransaction_TargetAccountingSystemFileID' )
DROP INDEX [NCI_SEIClientTransaction_TargetAccountingSystemFileID] ON [dbo].[SEIClientTransaction]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping index [NCI_TargetAccountingSystemPosition_TargetAccountingSystemAccountIdentifier_PositionDate] from [dbo].[TargetAccountingSystemPosition]'
GO
IF EXISTS ( SELECT 1 FROM sysindexes
            WHERE name = 'NCI_TargetAccountingSystemPosition_TargetAccountingSystemAccountIdentifier_PositionDate' )
DROP INDEX [NCI_TargetAccountingSystemPosition_TargetAccountingSystemAccountIdentifier_PositionDate] ON [dbo].[TargetAccountingSystemPosition]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping index [NCI_TargetAccountingSystemPosition_TargetAccountingSystemID_TargetAccountingSystemClientID_TargetAccountingSystemAc] from [dbo].[TargetAccountingSystemPosition]'
GO
IF EXISTS ( SELECT 1 FROM sysindexes
            WHERE name = 'NCI_TargetAccountingSystemPosition_TargetAccountingSystemID_TargetAccountingSystemClientID_TargetAccountingSystemAc' )
DROP INDEX [NCI_TargetAccountingSystemPosition_TargetAccountingSystemID_TargetAccountingSystemClientID_TargetAccountingSystemAc] ON [dbo].[TargetAccountingSystemPosition]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping index [NCI_TargetAccountingSystemPosition_CUSIP] from [dbo].[TargetAccountingSystemPosition]'
GO
IF EXISTS ( SELECT 1 FROM sysindexes
            WHERE name = 'NCI_TargetAccountingSystemPosition_CUSIP' )
DROP INDEX [NCI_TargetAccountingSystemPosition_CUSIP] ON [dbo].[TargetAccountingSystemPosition]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping index [NCI_TargetAccountingSystemPosition_CUSIP_ISIN] from [dbo].[TargetAccountingSystemPosition]'
GO
IF EXISTS ( SELECT 1 FROM sysindexes
            WHERE name = 'NCI_TargetAccountingSystemPosition_CUSIP_ISIN' )
DROP INDEX [NCI_TargetAccountingSystemPosition_CUSIP_ISIN] ON [dbo].[TargetAccountingSystemPosition]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping index [NCI_ArchivePreBalanceResult_SystemUpdateDate] from [dbo].[ArchiveBalanceResult]'
GO
IF EXISTS ( SELECT 1 FROM sysindexes
            WHERE name = 'NCI_ArchivePreBalanceResult_SystemUpdateDate' )
DROP INDEX [NCI_ArchivePreBalanceResult_SystemUpdateDate] ON [dbo].[ArchiveBalanceResult]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping index [NCI_TargetAccountingSystemFileDetail_TargetAccountingSystemFileID] from [dbo].[TargetAccountingSystemFileDetail]'
GO
IF EXISTS ( SELECT 1 FROM sysindexes
            WHERE name = 'NCI_TargetAccountingSystemFileDetail_TargetAccountingSystemFileID' )
DROP INDEX [NCI_TargetAccountingSystemFileDetail_TargetAccountingSystemFileID] ON [dbo].[TargetAccountingSystemFileDetail]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping index [NCI_TargetAccountingSystemFileDetail_AccountID] from [dbo].[TargetAccountingSystemFileDetail]'
GO
IF EXISTS ( SELECT 1 FROM sysindexes
            WHERE name = 'NCI_TargetAccountingSystemFileDetail_AccountID' )
DROP INDEX [NCI_TargetAccountingSystemFileDetail_AccountID] ON [dbo].[TargetAccountingSystemFileDetail]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping trigger [dbo].[Account_AUDTRG] from [dbo].[Account]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'Account_AUDTRG'
            AND xtype = 'TR' )
DROP TRIGGER [dbo].[Account_AUDTRG]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping trigger [dbo].[Aggregator_AUDTRG] from [dbo].[Aggregator]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'Aggregator_AUDTRG'
            AND xtype = 'TR' )
DROP TRIGGER [dbo].[Aggregator_AUDTRG]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping trigger [dbo].[AggregatorCustodian_AUDTRG] from [dbo].[AggregatorCustodian]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'AggregatorCustodian_AUDTRG'
            AND xtype = 'TR' )
DROP TRIGGER [dbo].[AggregatorCustodian_AUDTRG]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping trigger [dbo].[Client_AUDTRG] from [dbo].[Client]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'Client_AUDTRG'
            AND xtype = 'TR' )
DROP TRIGGER [dbo].[Client_AUDTRG]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping trigger [dbo].[ClientCustodianPASRule_AUDTRG] from [dbo].[ClientCustodianPASRule]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'ClientCustodianPASRule_AUDTRG'
            AND xtype = 'TR' )
DROP TRIGGER [dbo].[ClientCustodianPASRule_AUDTRG]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping trigger [dbo].[Custodian_AUDTRG] from [dbo].[Custodian]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'Custodian_AUDTRG'
            AND xtype = 'TR' )
DROP TRIGGER [dbo].[Custodian_AUDTRG]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping trigger [dbo].[PASRule_AUDTRG] from [dbo].[PASRule]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'PASRule_AUDTRG'
            AND xtype = 'TR' )
DROP TRIGGER [dbo].[PASRule_AUDTRG]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping trigger [dbo].[SEIClientTransaction_AUDTRG] from [dbo].[SEIClientTransaction]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'SEIClientTransaction_AUDTRG'
            AND xtype = 'TR' )
DROP TRIGGER [dbo].[SEIClientTransaction_AUDTRG]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping trigger [dbo].[SEITransactionType_AUDTRG] from [dbo].[SEITransactionType]'
GO
IF EXISTS ( SELECT 1 FROM sysobjects
            WHERE name = 'SEITransactionType_AUDTRG'
            AND xtype = 'TR' )
DROP TRIGGER [dbo].[SEITransactionType_AUDTRG]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping [dbo].[ArchiveBalanceResultComment]'
GO
IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_NAME = 'ArchiveBalanceResultComment'   )
DROP TABLE [dbo].[ArchiveBalanceResultComment]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping [dbo].[Stage_AssetBackedSecurity]'
GO
IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_NAME = 'Stage_AssetBackedSecurity'   )
DROP TABLE [dbo].[Stage_AssetBackedSecurity]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping [dbo].[ArchiveBalanceResult]'
GO
IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_NAME = 'ArchiveBalanceResult'   )
DROP TABLE [dbo].[ArchiveBalanceResult]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping [dbo].[Stage_TargetAccountingSystemPosition]'
GO
IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_NAME = 'Stage_TargetAccountingSystemPosition'   )
DROP TABLE [dbo].[Stage_TargetAccountingSystemPosition]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping [dbo].[TargetAccountingSystemFile]'
GO
IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_NAME = 'TargetAccountingSystemFile'   )
DROP TABLE [dbo].[TargetAccountingSystemFile]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping [dbo].[TargetAccountingSystemFileDetail]'
GO
IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_NAME = 'TargetAccountingSystemFileDetail'   )
DROP TABLE [dbo].[TargetAccountingSystemFileDetail]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping [dbo].[PreStage_EvareTransaction]'
GO
IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_NAME = 'PreStage_EvareTransaction'   )
DROP TABLE [dbo].[PreStage_EvareTransaction]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping [dbo].[PreStage_EvarePosition]'
GO
IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_NAME = 'PreStage_EvarePosition'   )
DROP TABLE [dbo].[PreStage_EvarePosition]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping [dbo].[PreStage_EvarePosition_Error]'
GO
IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_NAME = 'PreStage_EvarePosition_Error'   )
DROP TABLE [dbo].[PreStage_EvarePosition_Error]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping [dbo].[PreStage_BAATransaction]'
GO
IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_NAME = 'PreStage_BAATransaction'   )
DROP TABLE [dbo].[PreStage_BAATransaction]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping [dbo].[PreStage_BAAPosition]'
GO
IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_NAME = 'PreStage_BAAPosition'   )
DROP TABLE [dbo].[PreStage_BAAPosition]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Dropping [dbo].[PreStage_BAAAccount]'
GO
IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES
            WHERE TABLE_NAME = 'PreStage_BAAAccount'   )
DROP TABLE [dbo].[PreStage_BAAAccount]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering [dbo].[Stage_EvarePosition]'
GO
IF EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = 'Stage_EvarePosition'
            AND COLUMN_NAME = 'SourceFileName'   )
ALTER TABLE [dbo].[Stage_EvarePosition] ALTER COLUMN [SourceFileName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating [dbo].[ArchiveSEIClientTransactionMessageHistory]'
GO
IF NOT EXISTS ( SELECT 1 FROM INFORMATION_SCHEMA.TABLES 
            WHERE TABLE_NAME = 'ArchiveSEIClientTransactionMessageHistory' )
CREATE TABLE [dbo].[ArchiveSEIClientTransactionMessageHistory]
       (
         [SEIClientTransactionMessageHistoryID] [int] NOT NULL
       , [SEIClientTransactionID] [int] NOT NULL
       , [MessageSource] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS
                                       NOT NULL
       , [MessageSourceNum] [int] NOT NULL
       , [MessageSourceTxt] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
       , [SystemCreateDate] [datetime] NOT NULL
       , [SystemCreateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
       , [SystemUpdateDate] [datetime] NOT NULL
       , [SystemUpdateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
       )
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating primary key [PK_CI_ArchiveSEIClientTransactionMessageHistory] on [dbo].[ArchiveSEIClientTransactionMessageHistory]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'PK_CI_ArchiveSEIClientTransactionMessageHistory' )
ALTER TABLE [dbo].[ArchiveSEIClientTransactionMessageHistory] ADD CONSTRAINT [PK_CI_ArchiveSEIClientTransactionMessageHistory] PRIMARY KEY CLUSTERED  ([SEIClientTransactionMessageHistoryID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_SEIClientTransactionMessageHistory_SEIClientTransactionID] on [dbo].[ArchiveSEIClientTransactionMessageHistory]'
GO
IF NOT EXISTS (SELECT * FROM sysindexes WHERE name = 'NCI_ArchiveSEIClientTransactionMessageHistory_SEIClientTransactionID')
CREATE NONCLUSTERED INDEX [NCI_ArchiveSEIClientTransactionMessageHistory_SEIClientTransactionID] ON [dbo].[ArchiveSEIClientTransactionMessageHistory] ([SEIClientTransactionID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering [dbo].[TargetAccountingSystemPosition]'
GO
IF  (SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_NAME = 'TargetAccountingSystemPosition'
     AND COLUMN_NAME IN ('AccountID', 'AssetShortNm') ) = 0
ALTER TABLE [dbo].[TargetAccountingSystemPosition] ADD
[AccountID] [int] NULL,
[AssetShortNm] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
UPDATE  o
SET     AssetShortNm = AssetShortName
      , AccountID = a2.AccountID
FROM    dbo.Client c
        INNER JOIN dbo.Account a2 ON a2.ClientID = c.ClientID
        INNER JOIN dbo.v_AggregatorCustodian vac ON vac.CustodianID = a2.CustodianID
        INNER JOIN dbo.TargetAccountingSystemPosition o ON a2.TargetAccountingSystemAccountIdentifier = o.TargetAccountingSystemAccountIdentifier
                                                           AND o.TargetAccountingSystemClientID = c.TargetAccountingSystemClientID
                                                           AND o.TargetAccountingSystemID = c.TargetAccountingSystemID
WHERE   o.PositionDate BETWEEN vac.StartDate
                       AND     ISNULL(vac.EndDate, CURRENT_TIMESTAMP)
                   
                   
GO


IF  (SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_NAME = 'TargetAccountingSystemPosition'
     AND COLUMN_NAME = 'PostReconInd') =1
     DELETE dbo.TargetAccountingSystemPosition
     WHERE PostReconInd =0
GO     

IF  (SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_NAME = 'TargetAccountingSystemPosition'
     AND COLUMN_NAME IN ('TargetAccountingSystemID', 'TargetAccountingSystemClientID'
     , 'TargetAccountingSystemAccountIdentifier' ,'TargetAccountingSystemAccountDescription'
     , 'RecordBasis', 'Ticker', 'AssetShortName', 'PositionDate' , 'CustodianID', 'PostReconInd') ) > 0
ALTER TABLE [dbo].[TargetAccountingSystemPosition] DROP
COLUMN [TargetAccountingSystemID],
COLUMN [TargetAccountingSystemClientID],
COLUMN [TargetAccountingSystemAccountIdentifier],
COLUMN [TargetAccountingSystemAccountDescription],
COLUMN [RecordBasis],
COLUMN [Ticker],
COLUMN [AssetShortName],
COLUMN [PositionDate],
COLUMN [CustodianID],
COLUMN [PostReconInd]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF (SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TargetAccountingSystemPosition'
    AND COLUMN_NAME IN ('OtherSecurityType', 'Shares', 'SystemCreateDate', 'SystemCreateUser', 'SystemUpdateDate', 'SystemUpdateUser')) = 6
    BEGIN
    ALTER TABLE [dbo].[TargetAccountingSystemPosition] ALTER COLUMN [OtherSecurityType] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
    ALTER TABLE [dbo].[TargetAccountingSystemPosition] ALTER COLUMN [Shares] [float] NULL
    ALTER TABLE [dbo].[TargetAccountingSystemPosition] ALTER COLUMN [SystemCreateDate] [datetime] NULL
    ALTER TABLE [dbo].[TargetAccountingSystemPosition] ALTER COLUMN [SystemCreateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
    ALTER TABLE [dbo].[TargetAccountingSystemPosition] ALTER COLUMN [SystemUpdateDate] [datetime] NULL
    ALTER TABLE [dbo].[TargetAccountingSystemPosition] ALTER COLUMN [SystemUpdateUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
    END
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating primary key [PK_TargetAccountingSystemPosition] on [dbo].[TargetAccountingSystemPosition]'
GO
ALTER TABLE [dbo].[TargetAccountingSystemPosition] ADD CONSTRAINT [PK_TargetAccountingSystemPosition] PRIMARY KEY CLUSTERED  ([TargetAccountingSystemPositionID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating [dbo].[BAAFileProcessing]'
GO  
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='BAAFileProcessing')
CREATE TABLE [dbo].[BAAFileProcessing]
       (
         [FileNameDate] [varchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS
                                     NOT NULL
       , [PositionFileName] [varchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NULL
       , [AccountFilename] [varchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS
                                          NULL
       , [TransactionFileName] [varchar](260) COLLATE SQL_Latin1_General_CP1_CI_AS
                                              NULL
       )
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Rebuilding [dbo].[BalanceResultCommentType]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='tmp_rg_xx_BalanceResultCommentType')
CREATE TABLE [dbo].[tmp_rg_xx_BalanceResultCommentType]
       (
         [BalanceResultCommentTypeID] [int] NOT NULL
                                            IDENTITY(1, 1)
       , [BalanceResultCommentTypeCode] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS
                                                     NOT NULL
       , [BalanceResultCommentTypeDescription] [varchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS
                                                             NULL
       , [SystemCreateDate] [datetime] NULL
       , [SystemCreateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NULL
       , [SystemUpdateDate] [datetime] NULL
       , [SystemUpdateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NULL
       )
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
SET IDENTITY_INSERT [dbo].[tmp_rg_xx_BalanceResultCommentType] ON
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
INSERT  INTO [dbo].[tmp_rg_xx_BalanceResultCommentType]
        (
          [BalanceResultCommentTypeID]
        , [BalanceResultCommentTypeCode]
        , [BalanceResultCommentTypeDescription]
        , [SystemCreateDate]
        , [SystemCreateUser]
        , [SystemUpdateDate]
        , [SystemUpdateUser]
        )
        SELECT  [BalanceResultCommentType.BalanceResultCommentTypeID]
              , [BalanceResultCommentType.BalanceResultCommentTypeCode]
              , [BalanceResultCommentType.BalanceResultCommentTypeDescription]
              , [SystemCreateDate]
              , [SystemCreateUser]
              , [SystemUpdateDate]
              , [SystemUpdateUser]
        FROM    [dbo].[BalanceResultCommentType]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
SET IDENTITY_INSERT [dbo].[tmp_rg_xx_BalanceResultCommentType] OFF
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='BalanceResultCommentType')
DROP TABLE [dbo].[BalanceResultCommentType]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='tmp_rg_xx_BalanceResultCommentType')
EXEC sp_rename N'[dbo].[tmp_rg_xx_BalanceResultCommentType]', N'BalanceResultCommentType'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating primary key [PK_CI_BalanceResultCommentType] on [dbo].[BalanceResultCommentType]'
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PK_CI_BalanceResultCommentType' AND xtype = 'PK')
ALTER TABLE [dbo].[BalanceResultCommentType] ADD CONSTRAINT [PK_CI_BalanceResultCommentType] PRIMARY KEY CLUSTERED  ([BalanceResultCommentTypeID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [UI_PreBalanceResultCommentType_PreBalanceResultCommentTypeCode] on [dbo].[BalanceResultCommentType]'
GO
IF NOT EXISTS (SELECT 1 FROM sysindexes WHERE name = 'UI_PreBalanceResultCommentType_PreBalanceResultCommentTypeCode' )
CREATE NONCLUSTERED INDEX [UI_PreBalanceResultCommentType_PreBalanceResultCommentTypeCode] ON [dbo].[BalanceResultCommentType] ([BalanceResultCommentTypeCode])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering [dbo].[Stage_TargetAccountingSystemAccount]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Stage_TargetAccountingSystemAccount' AND COLUMN_NAME ='AdministratorName')
ALTER TABLE [dbo].[Stage_TargetAccountingSystemAccount] ADD
[AdministratorName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering [dbo].[SEIClientTransaction]'
GO
IF (SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='SEIClientTransaction' AND COLUMN_NAME IN ('TradeFilterClientTransactionMatchID', 'SendToTargetAccountingSystem')) =0
ALTER TABLE [dbo].[SEIClientTransaction] ADD
[TradeFilterClientTransactionMatchID] [int] NULL
,[SendToTargetAccountingSystem] [bit] NULL CONSTRAINT [DF_SEIClientTransaction_SendToTargetAccountingSystem] DEFAULT ((0))

GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO


IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Altering [dbo].[BalanceResult]'
GO
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_BalanceResult_SendToTargetAccountingSystem]') AND type = 'D')
 ALTER TABLE [dbo].[BalanceResult] DROP CONSTRAINT [DF_BalanceResult_SendToTargetAccountingSystem]
 
GO

PRINT N'Dropping index [NCI_PreBalanceResult_SendToTargetAccountingSystem] from [dbo].[BalanceResult]'
GO
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[BalanceResult]') AND name = N'NCI_PreBalanceResult_SendToTargetAccountingSystem')
DROP INDEX [NCI_PreBalanceResult_SendToTargetAccountingSystem] ON [dbo].[BalanceResult] WITH ( ONLINE = OFF )
GO

IF (SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'BalanceResult' AND COLUMN_NAME = 'SendToTargetAccountingSystem') =1
ALTER TABLE [dbo].[BalanceResult] DROP COLUMN [SendToTargetAccountingSystem]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
IF (SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'SEIClientTransaction' 
        AND COLUMN_NAME IN ( 'TargetAccountingSystemRegistrationCode',
        'TargetAccountingSystemLocationCode',
        'TargetAccountingSystemReceiptCode',
        'TargetAccountingSystemDisbursementCode',
        'TargetAccountingSystemFileID'
        )) =5
ALTER TABLE [dbo].[SEIClientTransaction] DROP
COLUMN [TargetAccountingSystemRegistrationCode],
COLUMN [TargetAccountingSystemLocationCode],
COLUMN [TargetAccountingSystemReceiptCode],
COLUMN [TargetAccountingSystemDisbursementCode],
COLUMN [TargetAccountingSystemFileID]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_SEIClientTransaction_TradeFilterClientTransactionMatchID] on [dbo].[SEIClientTransaction]'
GO
IF NOT EXISTS (SELECT 1 FROM sysindexes WHERE name = 'NCI_SEIClientTransaction_TradeFilterClientTransactionMatchID')
CREATE NONCLUSTERED INDEX [NCI_SEIClientTransaction_TradeFilterClientTransactionMatchID] ON [dbo].[SEIClientTransaction] ([TradeFilterClientTransactionMatchID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_SEIClientTransaction_SEIClientTransactionID_CustodianTransactionDescription] on [dbo].[SEIClientTransaction]'
GO
IF NOT EXISTS (SELECT 1 FROM sysindexes WHERE name = 'NCI_SEIClientTransaction_SEIClientTransactionID_CustodianTransactionDescription')
CREATE NONCLUSTERED INDEX [NCI_SEIClientTransaction_SEIClientTransactionID_CustodianTransactionDescription] ON [dbo].[SEIClientTransaction] ([SEIClientTransactionID]) INCLUDE ([CustodianTransactionDescription])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_SEIClientTransaction_SEITransactionTypeIDSettlementAmountLocalSEIClientTransactionStatusIDAggregatorFileID] on [dbo].[SEIClientTransaction]'
GO
IF NOT EXISTS (SELECT 1 FROM sysindexes WHERE name = 'NCI_SEIClientTransaction_SEITransactionTypeIDSettlementAmountLocalSEIClientTransactionStatusIDAggregatorFileID')
CREATE NONCLUSTERED INDEX [NCI_SEIClientTransaction_SEITransactionTypeIDSettlementAmountLocalSEIClientTransactionStatusIDAggregatorFileID] ON [dbo].[SEIClientTransaction] ([SEITransactionTypeID], [SettlementAmountLocal], [SEIClientTransactionStatusID], [AggregatorFileID]) INCLUDE ([CostBasisBase], [CostBasisLocal], [SEIClientTransactionID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering [dbo].[Account]'
GO
IF (SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Account' AND COLUMN_NAME IN ('AggregatorLastStatusInfo', 'AdministratorName')) = 0
ALTER TABLE [dbo].[Account] ADD
[AggregatorLastStatusInfo] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdministratorName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating [dbo].[AccountQueue]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME= 'AccountQueue')
CREATE TABLE [dbo].[AccountQueue]
       (
         [AccountQueueID] [int] NOT NULL
                                IDENTITY(1, 1)
       , [AccountID] [int] NOT NULL
       , [AccountQueueStatusID] [int] NOT NULL
       , [PriorityNumber] [int] NULL
                                CONSTRAINT [DF_AccountQueue_PriorityNumber] DEFAULT ( (15) )
       , [QueueRequestDate] [datetime] NULL
                                       CONSTRAINT [DF__AccountQu__Queue__3EBD23B6] DEFAULT ( GETDATE() )
       , [QueueDescription] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS
                                          NULL
       , [Retries] [int] NOT NULL
                         CONSTRAINT [DF_AccountQueue_Retries] DEFAULT ( (0) )
       , [SystemCreateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_AccountQueue_SystemCreateDate] DEFAULT ( GETDATE() )
       , [SystemCreateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_AccountQueue_SystemCreateUser] DEFAULT ( SUSER_NAME() )
       , [SystemUpdateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_AccountQueue_SystemUpdateDate] DEFAULT ( GETDATE() )
       , [SystemUpdateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_AccountQueue_SystemUpdateUser] DEFAULT ( SUSER_NAME() )
       )
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating primary key [PK_CI_AccountQueue] on [dbo].[AccountQueue]'
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PK_CI_AccountQueue' AND xtype = 'PK')
ALTER TABLE [dbo].[AccountQueue] ADD CONSTRAINT [PK_CI_AccountQueue] PRIMARY KEY CLUSTERED  ([AccountQueueID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_AccountQueue_AccountID] on [dbo].[AccountQueue]'
GO
IF NOT EXISTS (SELECT 1 FROM sysindexes WHERE name = 'NCI_AccountQueue_AccountID' )
CREATE NONCLUSTERED INDEX [NCI_AccountQueue_AccountID] ON [dbo].[AccountQueue] ([AccountID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating [dbo].[TradeFilterClientTransactionMatch]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME ='TradeFilterClientTransactionMatch')
CREATE TABLE [dbo].[TradeFilterClientTransactionMatch]
       (
         [TradeFilterClientTransactionMatchID] [int] NOT NULL
                                                     IDENTITY(1, 1)
       , [AccountID] [int] NOT NULL
       , [SEITransactionTypeID] [int] NOT NULL
       , [SecurityIdentifier] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS
                                             NOT NULL
       , [SharesParValue] [float] NOT NULL
       , [SettlementDate] [datetime] NULL
       , [TradeDate] [datetime] NULL
       , [SystemCreateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_TradeFilterClientTransactionMatch_SystemCreateDate] DEFAULT ( GETDATE() )
       , [SystemCreateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_TradeFilterClientTransactionMatch_SystemCreateUser] DEFAULT ( SUSER_NAME() )
       , [SystemUpdateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_TradeFilterClientTransactionMatch_SystemUpdateDate] DEFAULT ( GETDATE() )
       , [SystemUpdateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_TradeFilterClientTransactionMatch_SystemUpdateUser] DEFAULT ( SUSER_NAME() )
       , [TradeMatchDate] [datetime] NULL
       )
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating primary key [PK_CI_TradeFilterClientTransactionMatch] on [dbo].[TradeFilterClientTransactionMatch]'
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE xtype ='PK' AND name = 'PK_CI_TradeFilterClientTransactionMatch')
ALTER TABLE [dbo].[TradeFilterClientTransactionMatch] ADD CONSTRAINT [PK_CI_TradeFilterClientTransactionMatch] PRIMARY KEY CLUSTERED  ([TradeFilterClientTransactionMatchID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating [dbo].[TradeFilterClientTransaction]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'TradeFilterClientTransaction')
CREATE TABLE [dbo].[TradeFilterClientTransaction]
       (
         [TradeFilterClientTransactionID] [int] NOT NULL
                                                IDENTITY(1, 1)
       , [AccountID] [int] NOT NULL
       , [TradeFilterSourceID] [int] NOT NULL
       , [PendingItemNum] [int] NOT NULL
       , [Portfolio] [smallint] NULL
       , [SecurityIdentifier] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS
                                            NULL
       , [AssetShortNm] [varchar](36) COLLATE SQL_Latin1_General_CP1_CI_AS
                                      NULL
       , [SEITransactionTypeID] [int] NULL
       , [SharesParValue] [float] NULL
       , [SettleAmount] [float] NULL
       , [OriginalFace] [float] NULL
       , [TradeCancelledFl] [bit] NULL
       , [RecordCompleteFl] [bit] NULL
       , [TradeDate] [datetime] NULL
       , [SettlementDate] [datetime] NULL
       , [SourceLastUpdateDate] [datetime] NULL
       , [SystemCreateDate] [datetime] NULL
                                       CONSTRAINT [DF_TradeFilterClientTransaction_SystemCreateDate] DEFAULT ( GETDATE() )
       , [SystemCreateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NULL
                                           CONSTRAINT [DF_TradeFilterClientTransaction_SystemCreateUser] DEFAULT ( SUSER_NAME() )
       , [SystemUpdateDate] [datetime] NULL
                                       CONSTRAINT [DF_TradeFilterClientTransaction_SystemUpdateDate] DEFAULT ( GETDATE() )
       , [SystemUpdateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NULL
                                           CONSTRAINT [DF_TradeFilterClientTransaction_SystemUpdateUser] DEFAULT ( SUSER_NAME() )
       , [TradeFilterClientTransactionMatchID] [int] NULL
       )
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating primary key [PK_CI_TradeFilterClientTransaction] on [dbo].[TradeFilterClientTransaction]'
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE xtype = 'PK' AND name = 'PK_CI_TradeFilterClientTransaction')
ALTER TABLE [dbo].[TradeFilterClientTransaction] ADD CONSTRAINT [PK_CI_TradeFilterClientTransaction] PRIMARY KEY CLUSTERED  ([TradeFilterClientTransactionID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [UI_TradeFilterClientTransaction_AccountID] on [dbo].[TradeFilterClientTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'UI_TradeFilterClientTransaction_AccountID')
CREATE NONCLUSTERED INDEX [UI_TradeFilterClientTransaction_AccountID] ON [dbo].[TradeFilterClientTransaction] ([AccountID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [UI_TradeFilterClientTransaction_SEITransactionTypeID] on [dbo].[TradeFilterClientTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'UI_TradeFilterClientTransaction_SEITransactionTypeID')
CREATE NONCLUSTERED INDEX [UI_TradeFilterClientTransaction_SEITransactionTypeID] ON [dbo].[TradeFilterClientTransaction] ([SEITransactionTypeID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_TradeFilterClientTransaction_TradeFilterClientTransactionMatchID] on [dbo].[TradeFilterClientTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'NCI_TradeFilterClientTransaction_TradeFilterClientTransactionMatchID')
CREATE NONCLUSTERED INDEX [NCI_TradeFilterClientTransaction_TradeFilterClientTransactionMatchID] ON [dbo].[TradeFilterClientTransaction] ([TradeFilterClientTransactionMatchID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating [dbo].[SEIClientTransactionMessageHistory]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'SEIClientTransactionMessageHistory')
CREATE TABLE [dbo].[SEIClientTransactionMessageHistory]
       (
         [SEIClientTransactionMessageHistoryID] [int] NOT NULL
                                                      IDENTITY(1, 1)
       , [SEIClientTransactionID] [int] NOT NULL
       , [MessageSource] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS
                                       NOT NULL
       , [MessageSourceNum] [int] NOT NULL
       , [MessageSourceTxt] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
       , [SystemCreateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_SEIClientTransactionMessageHistory_SystemCreateDate] DEFAULT ( GETDATE() )
       , [SystemCreateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_SEIClientTransactionMessageHistory_SystemCreateUser] DEFAULT ( SUSER_SNAME() )
       , [SystemUpdateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_SEIClientTransactionMessageHistory_SystemUpdateDate] DEFAULT ( GETDATE() )
       , [SystemUpdateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_SEIClientTransactionMessageHistory_SystemUpdateUser] DEFAULT ( SUSER_SNAME() )
       )
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating primary key [PK_CI_SEIClientTransactionMessageHistory] on [dbo].[SEIClientTransactionMessageHistory]'
GO
IF NOT EXISTS(SELECT 1 FROM sysobjects WHERE xtype ='PK' AND name = 'PK_CI_SEIClientTransactionMessageHistory')
ALTER TABLE [dbo].[SEIClientTransactionMessageHistory] ADD CONSTRAINT [PK_CI_SEIClientTransactionMessageHistory] PRIMARY KEY CLUSTERED  ([SEIClientTransactionMessageHistoryID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_SEIClientTransactionMessageHistory_SEIClientTransactionID] on [dbo].[SEIClientTransactionMessageHistory]'
GO
IF NOT EXISTS (SELECT 1 FROM sysindexes WHERE name = 'NCI_SEIClientTransactionMessageHistory_SEIClientTransactionID')
CREATE NONCLUSTERED INDEX [NCI_SEIClientTransactionMessageHistory_SEIClientTransactionID] ON [dbo].[SEIClientTransactionMessageHistory] ([SEIClientTransactionID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering [dbo].[Custodian]'
GO
IF (SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Custodian' AND COLUMN_NAME IN ('InActiveDate', 'OptionContractIndicator'))=0
ALTER TABLE [dbo].[Custodian] ADD
[InActiveDate] [datetime] NULL,
[OptionContractIndicator] [bit] NOT NULL CONSTRAINT [DF_Custodian_OptionContractIndicator] DEFAULT ((0))
GO 
 

IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
 
 
 UPDATE dbo.Custodian SET OptionContractIndicator = 1 WHERE CustodianName IN ('NTC', 'TDW')
 GO
 IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
 
PRINT N'Altering [dbo].[BalanceResultTransaction]'
GO
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='BalanceResultTransaction' AND column_name = 'BalanceResultTransaction.BalanceResultID')
EXEC sp_rename N'[dbo].[BalanceResultTransaction].[BalanceResultTransaction.BalanceResultID]', N'BalanceResultID', 'COLUMN'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating primary key [PK_CI_BalanceResultTransaction] on [dbo].[BalanceResultTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysobjects WHERE name ='PK_CI_BalanceResultTransaction' AND xtype = 'PK')
ALTER TABLE [dbo].[BalanceResultTransaction] ADD CONSTRAINT [PK_CI_BalanceResultTransaction] PRIMARY KEY CLUSTERED  ([BalanceResultID], [SEIClientTransactionID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Rebuilding [dbo].[BalanceResult]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME= 'tmp_rg_xx_BalanceResult')
CREATE TABLE [dbo].[tmp_rg_xx_BalanceResult]
       (
         [BalanceResultID] [int] NOT NULL
                                 IDENTITY(1, 1)
       , [AccountID] [int] NOT NULL
       , [CustodianAccountNumber] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS
                                                NOT NULL
       , [CustodianID] [int] NOT NULL
       , [CustodianName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS
                                       NOT NULL
       , [AggregatorID] [int] NOT NULL
       , [AggregatorName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS
                                        NULL
       , [ClientID] [int] NOT NULL
       , [ClientName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                     NULL
       , [SecurityIdentifier] [varchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS
                                             NOT NULL
       , [OpeningSharesParValue] [float] NOT NULL
       , [TransactionSharesParValue] [float] NOT NULL
       , [TradeFilterAdjustment] [float] NULL
       , [ClosingSharesParValue] [float] NOT NULL
       , [OutOfBalance] [bit] NOT NULL
       , [MissingData] [bit] NOT NULL
                             CONSTRAINT [DF_BalanceResult_MissingData] DEFAULT ( (0) )
       , [NegativePosition] [bit] NOT NULL
                                  CONSTRAINT [DF_BalanceResult_NegativePosition] DEFAULT ( (0) )
       , [ODTFailure] [bit] NULL
                            CONSTRAINT [DF_BalanceResult_ODTFailure] DEFAULT ( (0) )
       , [PendingStatusID] [int] NULL
       , [LockedByUserID] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                         NULL
       , [TargetAccountingSystemName] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS
                                                    NOT NULL
       , [TargetAccountingSystemAccountIdentifier] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS
                                                                 NOT NULL
       , [TargetAccountingSystemAccountDescription] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                                                   NULL
       , [SystemCreateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_BalanceResult_SystemCreateDate] DEFAULT ( GETDATE() )
       , [SystemCreateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_BalanceResult_SystemCreateUser] DEFAULT ( SUSER_SNAME() )
       , [SystemUpdateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_BalanceResult_SystemUpdateDate] DEFAULT ( GETDATE() )
       , [SystemUpdateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_BalanceResult_SystemUpdateUser] DEFAULT ( SUSER_SNAME() )
       , [LockedOnDate] [datetime] NULL
       , [NumberTransactions] [int] NULL
       , [NumberTransactionsGone] [int] NULL
       , [LastPendingStatusID] [int] NULL
       )
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
SET IDENTITY_INSERT [dbo].[tmp_rg_xx_BalanceResult] ON
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
INSERT  INTO [dbo].[tmp_rg_xx_BalanceResult]
        (
          [BalanceResultID]
        , [AccountID]
        , [CustodianAccountNumber]
        , [CustodianID]
        , [CustodianName]
        , [AggregatorID]
        , [AggregatorName]
        , [ClientID]
        , [ClientName]
        , [SecurityIdentifier]
        , [OpeningSharesParValue]
        , [TransactionSharesParValue]
        , [ClosingSharesParValue]
        , [OutOfBalance]
        , [MissingData]
        , [NegativePosition]
        , [PendingStatusID]
        , [LockedByUserID]
        , [TargetAccountingSystemName]
        , [TargetAccountingSystemAccountIdentifier]
        , [TargetAccountingSystemAccountDescription]
        , [SystemCreateDate]
        , [SystemCreateUser]
        , [SystemUpdateDate]
        , [SystemUpdateUser]
        , [LockedOnDate]
        , [NumberTransactions]
        , [NumberTransactionsGone]
        , [LastPendingStatusID]
        )
        SELECT  [BalanceResult.BalanceResultID]
              , [AccountID]
              , [CustodianAccountNumber]
              , [CustodianID]
              , [CustodianName]
              , [AggregatorID]
              , [AggregatorName]
              , [ClientID]
              , [ClientName]
              , [SecurityIdentifier]
              , [OpeningSharesParValue]
              , [TransactionSharesParValue]
              , [ClosingSharesParValue]
              , [OutOfBalance]
              , [MissingData]
              , [NegativePosition]
              , [PendingStatusID]
              , [LockedByUserID]
              , [TargetAccountingSystemName]
              , [TargetAccountingSystemAccountIdentifier]
              , [TargetAccountingSystemAccountDescription]
              , [SystemCreateDate]
              , [SystemCreateUser]
              , [SystemUpdateDate]
              , [SystemUpdateUser]
              , [LockedOnDate]
              , [NumberTransactions]
              , [NumberTransactionsGone]
              , [LastPendingStatusID]
        FROM    [dbo].[BalanceResult]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
SET IDENTITY_INSERT [dbo].[tmp_rg_xx_BalanceResult] OFF
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='BalanceResult')
DROP TABLE [dbo].[BalanceResult]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
EXEC sp_rename N'[dbo].[tmp_rg_xx_BalanceResult]', N'BalanceResult'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating primary key [PK_CI_BalanceResult] on [dbo].[BalanceResult]'
GO
IF NOT EXISTS(SELECT 1 FROM sysobjects WHERE name = 'PK_CI_BalanceResult' AND xtype = 'PK')
ALTER TABLE [dbo].[BalanceResult] ADD CONSTRAINT [PK_CI_BalanceResult] PRIMARY KEY CLUSTERED  ([BalanceResultID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_PreBalanceResult_AccountIDSecurityIdentifier] on [dbo].[BalanceResult]'
GO
IF NOT EXISTS (SELECT 1 FROM sysindexes WHERE name  = 'NCI_PreBalanceResult_AccountIDSecurityIdentifier' )
CREATE NONCLUSTERED INDEX [NCI_PreBalanceResult_AccountIDSecurityIdentifier] ON [dbo].[BalanceResult] ([AccountID], [SecurityIdentifier])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering [dbo].[ArchiveSEIClientTransaction]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='ArchiveSEIClientTransaction' AND COLUMN_NAME= 'TradeFilterClientTransactionMatchID')
ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ADD
[TradeFilterClientTransactionMatchID] [int] NULL
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF (SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME='ArchiveSEIClientTransaction' 
    AND COLUMN_NAME IN ( 'TargetAccountingSystemRegistrationCode'
    , 'TargetAccountingSystemLocationCode'
    , 'TargetAccountingSystemReceiptCode'
    , 'TargetAccountingSystemDisbursementCode'
    , 'TargetAccountingSystemFileID'
    , 'ArchiveAction'
    , 'ArchiveUser'
    )) = 7

ALTER TABLE [dbo].[ArchiveSEIClientTransaction] DROP
COLUMN [TargetAccountingSystemRegistrationCode],
COLUMN [TargetAccountingSystemLocationCode],
COLUMN [TargetAccountingSystemReceiptCode],
COLUMN [TargetAccountingSystemDisbursementCode],
COLUMN [TargetAccountingSystemFileID],
COLUMN [ArchiveAction],
COLUMN [ArchiveUser]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF (SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME='ArchiveSEIClientTransaction' 
    AND COLUMN_NAME IN ( 'Reversal'
    , 'SystemCreateDate'
    , 'SystemCreateUser'
    , 'SystemUpdateDate'
    , 'SystemUpdateUser'
    , 'ArchiveDate'
    )) > 0
    BEGIN 
    ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ALTER COLUMN [Reversal] [bit] NOT NULL
    ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ALTER COLUMN [SystemCreateDate] [datetime] NOT NULL
    ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ALTER COLUMN [SystemCreateUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
    ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ALTER COLUMN [SystemUpdateDate] [datetime] NOT NULL
    ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ALTER COLUMN [SystemUpdateUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
    ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ALTER COLUMN [ArchiveDate] [datetime] NULL
    END 
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='ArchiveSEIClientTransaction')
TRUNCATE TABLE dbo.ArchiveSEIClientTransaction
GO

PRINT N'Creating primary key [PK_CI_ArchiveSEIClientTransaction] on [dbo].[ArchiveSEIClientTransaction]'
GO 
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PK_CI_ArchiveSEIClientTransaction' AND xtype = 'PK')
ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ADD CONSTRAINT [PK_CI_ArchiveSEIClientTransaction] PRIMARY KEY CLUSTERED  ([SEIClientTransactionID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_ArchiveSEIClientTransaction_Reversal] on [dbo].[ArchiveSEIClientTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'NCI_ArchiveSEIClientTransaction_Reversal')
CREATE NONCLUSTERED INDEX [NCI_ArchiveSEIClientTransaction_Reversal] ON [dbo].[ArchiveSEIClientTransaction] ([Reversal])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_ArchiveSEIClientTransaction_SecurityIdentifier] on [dbo].[ArchiveSEIClientTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'NCI_ArchiveSEIClientTransaction_SecurityIdentifier')
CREATE NONCLUSTERED INDEX [NCI_ArchiveSEIClientTransaction_SecurityIdentifier] ON [dbo].[ArchiveSEIClientTransaction] ([SecurityIdentifier]) INCLUDE ([AccountID], [AccruedIncomeLocal], [CommissionsFees], [CurrentCustodianSecurityPrice], [CustodianTransactionDescription], [OriginalFaceAmount], [Portfolio], [Reversal], [SEIClientTransactionID], [SEITransactionTypeID], [SettlementAmountLocal], [SettlementDate], [SharesParValue], [TradeDate], [TransactionDate])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_ArchiveSEIClientTransaction_ArchiveDate] on [dbo].[ArchiveSEIClientTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'NCI_ArchiveSEIClientTransaction_ArchiveDate')
CREATE NONCLUSTERED INDEX [NCI_ArchiveSEIClientTransaction_ArchiveDate] ON [dbo].[ArchiveSEIClientTransaction] ([ArchiveDate])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_ArchiveSEIClientTransaction_TradeFilterClientTransactionMatchID] on [dbo].[ArchiveSEIClientTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'NCI_ArchiveSEIClientTransaction_TradeFilterClientTransactionMatchID')
CREATE NONCLUSTERED INDEX [NCI_ArchiveSEIClientTransaction_TradeFilterClientTransactionMatchID] ON [dbo].[ArchiveSEIClientTransaction] ([TradeFilterClientTransactionMatchID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_ArchiveSEIClientTransaction_AccountID] on [dbo].[ArchiveSEIClientTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'NCI_ArchiveSEIClientTransaction_AccountID')
CREATE NONCLUSTERED INDEX [NCI_ArchiveSEIClientTransaction_AccountID] ON [dbo].[ArchiveSEIClientTransaction] ([AccountID]) INCLUDE ([CustodianAccountNumber], [SecurityIdentifier], [SEIClientTransactionID], [SEIClientTransactionStatusID], [SentToTargetDate])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_ArchiveSEIClientTransaction_AccountID_SEIClientTransactionStatusID_TransactionDate] on [dbo].[ArchiveSEIClientTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'NCI_ArchiveSEIClientTransaction_AccountID_SEIClientTransactionStatusID_TransactionDate')
CREATE NONCLUSTERED INDEX [NCI_ArchiveSEIClientTransaction_AccountID_SEIClientTransactionStatusID_TransactionDate] ON [dbo].[ArchiveSEIClientTransaction] ([AccountID], [SEIClientTransactionStatusID], [TransactionDate])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_ArchiveSEIClientTransaction_AggregatorFileID] on [dbo].[ArchiveSEIClientTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'NCI_ArchiveSEIClientTransaction_AggregatorFileID')
CREATE NONCLUSTERED INDEX [NCI_ArchiveSEIClientTransaction_AggregatorFileID] ON [dbo].[ArchiveSEIClientTransaction] ([AggregatorFileID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_ArchiveSEIClientTransaction_ArchiveSEIClientTransaction_CustodianTransactionDescription] on [dbo].[ArchiveSEIClientTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'NCI_ArchiveSEIClientTransaction_ArchiveSEIClientTransaction_CustodianTransactionDescription')
CREATE NONCLUSTERED INDEX [NCI_ArchiveSEIClientTransaction_ArchiveSEIClientTransaction_CustodianTransactionDescription] ON [dbo].[ArchiveSEIClientTransaction] ([SEIClientTransactionID]) INCLUDE ([CustodianTransactionDescription])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_ArchiveSEIClientTransaction_SEIClientTransactionStatusID] on [dbo].[ArchiveSEIClientTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'NCI_ArchiveSEIClientTransaction_SEIClientTransactionStatusID')
CREATE NONCLUSTERED INDEX [NCI_ArchiveSEIClientTransaction_SEIClientTransactionStatusID] ON [dbo].[ArchiveSEIClientTransaction] ([SEIClientTransactionStatusID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_ArchiveSEIClientTransaction_SEITransactionTypeID] on [dbo].[ArchiveSEIClientTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'NCI_ArchiveSEIClientTransaction_SEITransactionTypeID')
CREATE NONCLUSTERED INDEX [NCI_ArchiveSEIClientTransaction_SEITransactionTypeID] ON [dbo].[ArchiveSEIClientTransaction] ([SEITransactionTypeID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_ArchiveSEIClientTransaction_SEITransactionTypeIDSettlementAmountLocalSEIClientTransactionStatusIDAggregatorFileID] on [dbo].[ArchiveSEIClientTransaction]'
GO
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'NCI_ArchiveSEIClientTransaction_SEITransactionTypeIDSettlementAmountLocalSEIClientTransactionStatusIDAggregatorFileID')
CREATE NONCLUSTERED INDEX [NCI_ArchiveSEIClientTransaction_SEITransactionTypeIDSettlementAmountLocalSEIClientTransactionStatusIDAggregatorFileID] ON [dbo].[ArchiveSEIClientTransaction] ([SEITransactionTypeID], [SettlementAmountLocal], [SEIClientTransactionStatusID], [AggregatorFileID]) INCLUDE ([CostBasisBase], [CostBasisLocal], [SEIClientTransactionID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating [dbo].[AggregatorFileAccount]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='AggregatorFileAccount')
CREATE TABLE [dbo].[AggregatorFileAccount]
       (
         [AggregatorFileAccountID] [int] NOT NULL
                                         IDENTITY(1, 1)
       , [AggregatorFileID] [int] NOT NULL
       , [CustodianAccountNumber] [varchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS
                                                NOT NULL
       , [CustodianID] [int] NULL
       , [SystemCreateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_AggregatorFileAccount_SystemCreateDate] DEFAULT ( GETDATE() )
       , [SystemCreateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_AggregatorFileAccount_SystemCreateUser] DEFAULT ( SUSER_SNAME() )
       , [SystemUpdateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_AggregatorFileAccount_SystemUpdateDate] DEFAULT ( GETDATE() )
       , [SystemUpdateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_AggregatorFileAccount_SystemUpdateUser] DEFAULT ( SUSER_SNAME() )
       )
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating primary key [PK_CI_AggregatorFileAccount] on [dbo].[AggregatorFileAccount]'
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PK_CI_AggregatorFileAccount' AND xtype = 'PK')
ALTER TABLE [dbo].[AggregatorFileAccount] ADD CONSTRAINT [PK_CI_AggregatorFileAccount] PRIMARY KEY CLUSTERED  ([AggregatorFileAccountID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering [dbo].[AggregatorCustodian]'
GO
IF  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='AggregatorCustodian' AND COLUMN_NAME='AggregatorCustodianDescription')
ALTER TABLE [dbo].[AggregatorCustodian] DROP
COLUMN [AggregatorCustodianDescription]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF  EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='AggregatorCustodian' AND COLUMN_NAME='AggregatorCustodianIdentifier')
ALTER TABLE [dbo].[AggregatorCustodian] ALTER COLUMN [AggregatorCustodianIdentifier] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering [dbo].[SEIClientTransactionStatus]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME ='SEIClientTransactionStatus' AND COLUMN_NAME='TradeFilter')
ALTER TABLE [dbo].[SEIClientTransactionStatus] ADD
[TradeFilter] [bit] NOT NULL CONSTRAINT [DF_SEIClientTransactionStatus_TradeFilter] DEFAULT ((0))
GO
UPDATE  dbo.SEIClientTransactionStatus
SET     TradeFilter = 1
WHERE   StatusCode IN ( 'Valid', 'MissData' )
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Rebuilding [dbo].[BalanceResultComment]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='tmp_rg_xx_BalanceResultComment')
CREATE TABLE [dbo].[tmp_rg_xx_BalanceResultComment]
       (
         [BalanceResultCommentID] [int] NOT NULL
                                        IDENTITY(1, 1)
       , [BalanceResultID] [int] NOT NULL
       , [BalanceResultCommentTypeID] [int] NOT NULL
       , [Comment] [varchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS
                                   NOT NULL
       , [SystemCreateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_BalanceResultComment_SystemCreateDate] DEFAULT ( GETDATE() )
       , [SystemCreateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_BalanceResultComment_SystemCreateUser] DEFAULT ( SUSER_SNAME() )
       , [SystemUpdateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_BalanceResultComment_SystemUpdateDate] DEFAULT ( GETDATE() )
       , [SystemUpdateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_BalanceResultComment_SystemUpdateUser] DEFAULT ( SUSER_SNAME() )
       )
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
SET IDENTITY_INSERT [dbo].[tmp_rg_xx_BalanceResultComment] ON
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
INSERT  INTO [dbo].[tmp_rg_xx_BalanceResultComment]
        (
          [BalanceResultCommentID]
        , [BalanceResultID]
        , [BalanceResultCommentTypeID]
        , [Comment]
        , [SystemCreateDate]
        , [SystemCreateUser]
        , [SystemUpdateDate]
        , [SystemUpdateUser]
        )
        SELECT  [BalanceResultComment.BalanceResultCommentID]
              , [BalanceResultComment.BalanceResultID]
              , [BalanceResultComment.BalanceResultCommentTypeID]
              , [Comment]
              , [SystemCreateDate]
              , [SystemCreateUser]
              , [SystemUpdateDate]
              , [SystemUpdateUser]
        FROM    [dbo].[BalanceResultComment]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
SET IDENTITY_INSERT [dbo].[tmp_rg_xx_BalanceResultComment] OFF
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES  WHERE TABLE_NAME= 'BalanceResultComment')
DROP TABLE [dbo].[BalanceResultComment]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
EXEC sp_rename N'[dbo].[tmp_rg_xx_BalanceResultComment]', N'BalanceResultComment'
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating primary key [PK_CI_BalanceResultComment] on [dbo].[BalanceResultComment]'
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE xtype = 'PK' AND name = 'PK_CI_BalanceResultComment')
ALTER TABLE [dbo].[BalanceResultComment] ADD CONSTRAINT [PK_CI_BalanceResultComment] PRIMARY KEY CLUSTERED  ([BalanceResultCommentID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering [dbo].[v_IsAccountNew]'
GO


/* 
 * VIEW: dbo.v_IsAccountNew 
 */




ALTER  VIEW [dbo].[v_IsAccountNew]
AS
      SELECT    a.AccountID
              , CASE WHEN a.NewAccountFlag = 1
                          AND o.AccountID IS NULL THEN 1
                     ELSE 0
                END AS IsAccountNewFlag
      FROM      dbo.Account a
                LEFT OUTER JOIN ( SELECT DISTINCT
                                            AccountID
                                  FROM      TargetAccountingSystemPosition
                                ) o ON a.AccountID = o.AccountID

GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering [dbo].[AUDIT_TRAIL]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='AUDIT_TRAIL' AND COLUMN_NAME ='Split_Num')
ALTER TABLE [dbo].[AUDIT_TRAIL] ADD
[Split_Num] [int] NOT NULL CONSTRAINT [DF__AUDIT_TRA__Split__243E37A4] DEFAULT ((1))
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF (SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS  WHERE TABLE_NAME = 'AUDIT_TRAIL' AND COLUMN_NAME IN (
    'User_ID', 'Old_Value', 'New_Value')) = 3
    BEGIN 
    ALTER TABLE [dbo].[AUDIT_TRAIL] ALTER COLUMN [User_ID] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
    ALTER TABLE [dbo].[AUDIT_TRAIL] ALTER COLUMN [Old_Value] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
    ALTER TABLE [dbo].[AUDIT_TRAIL] ALTER COLUMN [New_Value] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
    END 
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [AUDIT_TRAIL_IX01] on [dbo].[AUDIT_TRAIL]'
GO
IF NOT EXISTS (SELECT 1 FROM sysindexes WHERE name = 'AUDIT_TRAIL_IX01')
CREATE UNIQUE NONCLUSTERED INDEX [AUDIT_TRAIL_IX01] ON [dbo].[AUDIT_TRAIL] ([Audit_Timestamp], [Audit_Trail_ID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating [dbo].[TradeFilterSource]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME= 'TradeFilterSource')
CREATE TABLE [dbo].[TradeFilterSource]
       (
         [TradeFilterSourceID] [int] NOT NULL
                                     IDENTITY(1, 1)
       , [TradeFilterSourceName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                                NOT NULL
       , [SystemCreateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_TradeFilterSource_SystemCreateDate] DEFAULT ( GETDATE() )
       , [SystemCreateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_TradeFilterSource_SystemCreateUser] DEFAULT ( SUSER_NAME() )
       , [SystemUpdateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_TradeFilterSource_SystemUpdateDate] DEFAULT ( GETDATE() )
       , [SystemUpdateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_TradeFilterSource_SystemUpdateUser] DEFAULT ( SUSER_NAME() )
       )
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating primary key [PK_CI_TradeFilterSource] on [dbo].[TradeFilterSource]'
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'PK_CI_TradeFilterSource' AND xtype = 'PK')
ALTER TABLE [dbo].[TradeFilterSource] ADD CONSTRAINT [PK_CI_TradeFilterSource] PRIMARY KEY CLUSTERED  ([TradeFilterSourceID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
INSERT  TradeFilterSource
        ( TradeFilterSourceName )
VALUES  ( 'T3K Moxy' )

GO
PRINT N'Creating [dbo].[AccountQueueStatus]'
GO
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='AccountQueueStatus')
CREATE TABLE [dbo].[AccountQueueStatus]
       (
         [AccountQueueStatusID] [int] NOT NULL
                                      IDENTITY(1, 1)
       , [AccountQueueStatus] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS
                                            NULL
       , [SystemCreateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_AccountQueueStatus_SystemCreateDate] DEFAULT ( GETDATE() )
       , [SystemCreateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_AccountQueueStatus_SystemCreateUser] DEFAULT ( SUSER_NAME() )
       , [SystemUpdateDate] [datetime] NOT NULL
                                       CONSTRAINT [DF_AccountQueueStatus_SystemUpdateDate] DEFAULT ( GETDATE() )
       , [SystemUpdateUser] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS
                                           NOT NULL
                                           CONSTRAINT [DF_AccountQueueStatus_SystemUpdateUser] DEFAULT ( SUSER_NAME() )
       )
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating primary key [PK_CI_AccountQueueStatus] on [dbo].[AccountQueueStatus]'
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'PK_CI_AccountQueueStatus' AND xtype = 'PK')
ALTER TABLE [dbo].[AccountQueueStatus] ADD CONSTRAINT [PK_CI_AccountQueueStatus] PRIMARY KEY CLUSTERED  ([AccountQueueStatusID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_AccountQueue_AccountQueueStatusID] on [dbo].[AccountQueueStatus]'
GO
IF NOT EXISTS (SELECT 1 FROM sysindexes WHERE name = 'NCI_AccountQueue_AccountQueueStatusID')
CREATE NONCLUSTERED INDEX [NCI_AccountQueue_AccountQueueStatusID] ON [dbo].[AccountQueueStatus] ([AccountQueueStatusID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering [dbo].[v_AggregatorCustodian]'
GO

/* 
 * VIEW: dbo.v_AggregatorCustodian 
 */




ALTER VIEW [dbo].[v_AggregatorCustodian]
AS
      /***
================================================================================
Name : v_AggregatorCustodian
Author : LRhoads - 09/09/2010 
Description : Used to calculate Start and End Dates based on data in StartDate.
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
LLR 2011.04.14  Inactivating custodians feature added to Custodian table, this now
                incorporates that column.
LLR 2012.04.21  Add in aggregator identifier                 
================================================================================
***/


WITH    CustodianHistory
          AS ( SELECT   ac.AggregatorCustodianID
                      , ac.AggregatorID
                      , ac.CustodianID
                      , ac.EffectiveStartDate
                      , c.InActiveDate
                      , ac.AggregatorCustodianIdentifier
                      , ROW_NUMBER() OVER ( PARTITION BY ac.CustodianID ORDER BY ac.EffectiveStartDate ) AS rownum
                      , c.OptionContractIndicator
               FROM     dbo.AggregatorCustodian ac
                        INNER JOIN AggregatorCustodian ph
                        INNER JOIN Custodian c ON c.CustodianId = ph.CustodianID ON ac.AggregatorID = ph.AggregatorID
                                                                                    AND ac.CustodianID = ph.CustodianID
                                                                                    AND ac.AggregatorCustodianID = ph.AggregatorCustodianID
             )
      SELECT    currow.AggregatorID AS AggregatorID
              , currow.CustodianID AS CustodianID
              , currow.AggregatorCustodianIdentifier
              , currow.EffectiveStartDate AS StartDate
          --below now takes into account the InActiveDate for custodian
              , CASE WHEN currow.InActiveDate IS NULL THEN DATEADD(ss, -1, nextrow.EffectiveStartDate)
                     WHEN nextrow.EffectiveStartDate < currow.InActiveDate THEN DATEADD(ss, -1, nextrow.EffectiveStartDate)
                     ELSE currow.InActiveDate
                END AS EndDate
              , currow.OptionContractIndicator
      FROM      CustodianHistory currow
                LEFT JOIN CustodianHistory nextrow ON currow.rownum = nextrow.rownum - 1
                                                      AND currow.CustodianID = nextrow.CustodianID
                LEFT JOIN CustodianHistory prevrow ON currow.rownum = prevrow.rownum + 1
                                                      AND currow.CustodianID = prevrow.CustodianID








GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering [dbo].[v_SEIClientTransaction]'
GO

/* 
 * VIEW: dbo.v_SEIClientTransaction 
 */



ALTER VIEW [dbo].[v_SEIClientTransaction]
AS
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
================================================================================
***/

SELECT  sct.SEIClientTransactionID
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
FROM    dbo.SEIClientTransaction sct
        INNER JOIN dbo.Account a2 ON a2.AccountID = sct.AccountID
        INNER JOIN dbo.Client c ON a2.ClientID = c.ClientID
        INNER JOIN dbo.Custodian c2 ON c2.CustodianID = a2.CustodianID
        INNER JOIN dbo.v_AggregatorCustodian vac ON vac.CustodianID = c2.CustodianID
                                                    AND sct.TransactionDate BETWEEN vac.StartDate
                                                                            AND     ISNULL(vac.EndDate, CURRENT_TIMESTAMP)
        INNER JOIN dbo.Aggregator a ON a.AggregatorID = vac.aggregatorid
        INNER JOIN dbo.SEITransactionType stt ON stt.SEITransactionTypeID = sct.SEITransactionTypeID
        INNER JOIN dbo.AggregatorFile af ON af.AggregatorFileID = sct.AggregatorFileID
        INNER JOIN dbo.SEIClientTransactionStatus scts ON scts.SEIClientTransactionStatusID = sct.SEIClientTransactionStatusID




GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO

--view that is referred to later:
/****** Object:  View [dbo].[v_SEIClientTransactionALL]    Script Date: 05/27/2011 15:39:18 ******/
IF EXISTS ( SELECT  *
            FROM    sys.views
            WHERE   object_id = OBJECT_ID(N'[dbo].[v_SEIClientTransactionALL]') ) 
   DROP VIEW [dbo].[v_SEIClientTransactionALL]
GO

/****** Object:  View [dbo].[v_SEIClientTransactionALL]    Script Date: 05/27/2011 15:39:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 

CREATE VIEW [dbo].[v_SEIClientTransactionALL]
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
FROM    dbo.ArchiveSEIClientTransaction asct 
 


GO

GRANT SELECT ON [dbo].[v_SEIClientTransactionALL] TO [prole_PAS_APP] AS [dbo]
GO

GRANT SELECT ON [dbo].[v_SEIClientTransactionALL] TO [prole_PAS_SSIS] AS [dbo]
GO

GRANT SELECT ON [dbo].[v_SEIClientTransactionALL] TO [prole_PAS_SSRS] AS [dbo]
GO


IF EXISTS ( SELECT  *
            FROM    sys.views
            WHERE   object_id = OBJECT_ID(N'[dbo].[v_SendToTargetCheck]') ) 
   DROP VIEW [dbo].[v_SendToTargetCheck]
GO


CREATE VIEW [dbo].[v_SendToTargetCheck] AS

/***
================================================================================
Name : v_SendToTargetCheck
Author : LRhoads  
Description : Returns those transactions with CASH impact but no SHARES impact
              where CASH is OOB but Security is not and they should not be
              sent to the target.
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
LLR 2011.06.07 Initial creation
================================================================================
***/



SELECT  a.SecurityIdentifier AS TrxSecurityIdentifier
      , a.BalanceResultID AS TrxBalanceResultID
      , b.SecurityIdentifier AS CashSecurityIdentifier
      , b.BalanceResultID AS CashBalanceResultID
      , a.Impact AS TrxImpact
      , b.Impact AS CashImpact
      , b.CashExceptionStatus
      , a.TrxExceptionStatus
      , b.SEIClientTransactionID AS SEIClientTransactionID
      , a.SEITransactionTypeID
      , stt.TransactionType
      , stt.CashImpact AS TransactionTypeCashImpact
      , stt.SharesImpact AS TransactionTypeSharesImpact
      , stt.AccruedInterestImpact
      , stt.DefaultPortfolio
FROM    ( SELECT    brc.SecurityIdentifier
                  , brtc.BalanceResultID
                  , brtc.SEIClientTransactionID
                  , brtc.Impact
                  , SEITransactionTypeID
                                  , CASE WHEN CAST(OutOfBalance AS INT) + CAST(missingData AS INT) + CAST(NegativePosition AS INT)  > 0 THEN 1
                                         ELSE 0
                                    END AS TrxExceptionStatus
          FROM      dbo.BalanceResultTransaction brtc
                    INNER JOIN dbo.BalanceResult brc ON brtc.BalanceResultID = brc.BalanceResultID
                    INNER JOIN dbo.SEIClientTransaction sct ON sct.SEIClientTransactionID = brtc.SEIClientTransactionID
        ) a
        INNER JOIN dbo.SEITransactionType stt ON a.SEITransactionTypeID = stt.SEITransactionTypeID
        LEFT OUTER  JOIN ( SELECT   brc.SecurityIdentifier
                                  , brtc.BalanceResultID
                                  , SEIClientTransactionID
                                  , brtc.Impact
                                  , CASE WHEN CAST(OutOfBalance AS INT) + CAST(missingData AS INT) + CAST(NegativePosition AS INT)  > 0 THEN 1
                                         ELSE 0
                                    END AS CashExceptionStatus
                           FROM     dbo.BalanceResultTransaction brtc
                                    INNER  JOIN dbo.BalanceResult brc ON brtc.BalanceResultID = brc.BalanceResultID
                         ) b ON a.SEIClientTransactionID = b.SEIClientTransactionID
      
WHERE   a.BalanceResultID <> b.BalanceResultID
        AND b.SecurityIdentifier = 'CASH'
        AND stt.SharesImpact = '0'
        AND b.CashExceptionStatus = 1
        AND a.TrxExceptionStatus = 0 

GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO


PRINT N'Altering permissions on [dbo].[v_SendToTargetCheck]'
GO
GRANT SELECT ON  [dbo].[v_SendToTargetCheck] TO [prole_PAS_APP]
GRANT SELECT ON  [dbo].[v_SendToTargetCheck] TO [prole_PAS_SSIS]
GRANT SELECT ON  [dbo].[v_SendToTargetCheck] TO [prole_PAS_SSRS]
GO 



PRINT N'Altering [dbo].[v_SEIClientTransactionImpact]'
GO


/* 
 * VIEW: dbo.v_SEIClientTransactionImpact 
 */






ALTER  VIEW [dbo].[v_SEIClientTransactionImpact]
AS
      SELECT    t.AccountID
              , t.SEIClientTransactionID
              , t.SentToTargetDate
              , t.SecurityIdentifier
              , t.Reversal
              , t.SEIClientTransactionStatusID
              , SharesImpact = ISNULL(CASE WHEN c.CustodianIsOriginalFace = 1
                                                AND s.SecurityIdentifier IS NOT NULL THEN CASE t.Reversal
                                                                                            WHEN 0 THEN CASE stt.SharesImpact
                                                                                                          WHEN '+' THEN ABS(t.OriginalFaceAmount)  -- POSITIVE
                                                                                                          WHEN '-' THEN -1 * ABS(t.OriginalFaceAmount)  -- NEGATIVE
                                                                                                          WHEN '0' THEN 0  -- ZERO
                                                                                                          ELSE 0
                                                                                                        END
                                                                                            ELSE CASE stt.SharesImpact
                                                                                                   WHEN '-' THEN ABS(t.OriginalFaceAmount)  -- POSITIVE
                                                                                                   WHEN '+' THEN -1 * ABS(t.OriginalFaceAmount)  -- NEGATIVE
                                                                                                   WHEN '0' THEN 0  -- ZERO
                                                                                                   ELSE 0
                                                                                                 END
                                                                                          END
                                           ELSE CASE t.Reversal
                                                  WHEN 0 THEN CASE stt.SharesImpact
                                                                WHEN '+' THEN ABS(t.SharesParValue)  -- POSITIVE
                                                                WHEN '-' THEN -1 * ABS(t.SharesParValue)  -- NEGATIVE
                                                                WHEN '0' THEN 0  -- ZERO
                                                                ELSE 0
                                                              END
                                                  ELSE CASE stt.SharesImpact
                                                         WHEN '-' THEN ABS(t.SharesParValue)  -- POSITIVE
                                                         WHEN '+' THEN -1 * ABS(t.SharesParValue)  -- NEGATIVE
                                                         WHEN '0' THEN 0  -- ZERO
                                                       END
                                                END
                                      END, 0)
              , CashImpact = CASE T.Reversal
                               WHEN 0 THEN ISNULL(CASE stt.CashImpact
                                                    WHEN '+' THEN -- POSITIVE
                                                         CASE stt.AccruedInterestImpact
                                                           WHEN '0' THEN ABS(t.SettlementAmountLocal)
                                                           WHEN '-' THEN ABS(t.SettlementAmountLocal) + -1 * ABS(ISNULL(t.AccruedIncomeLocal, 0))
                                                           WHEN '+' THEN ABS(t.SettlementAmountLocal) + ABS(ISNULL(t.AccruedIncomeLocal, 0))
                                                           ELSE 0
                                                         END
                                                    WHEN '-' THEN -- NEGATIVE
                                                         CASE stt.AccruedInterestImpact
                                                           WHEN '0' THEN -1 * ABS(t.SettlementAmountLocal)
                                                           WHEN '-' THEN -1 * ABS(t.SettlementAmountLocal) - 1 * ABS(ISNULL(t.AccruedIncomeLocal, 0))
                                                           WHEN '+' THEN -1 * ABS(t.SettlementAmountLocal) + ABS(ISNULL(t.AccruedIncomeLocal, 0))
                                                           ELSE 0
                                                         END
                                                    WHEN '0' THEN 0  -- ZERO
                                                    ELSE 0
                                                  END, 0)
                               ELSE ISNULL(CASE stt.CashImpact
                                             WHEN '-' THEN -- POSITIVE - Reverse
                                                  CASE stt.AccruedInterestImpact
                                                    WHEN '0' THEN ABS(t.SettlementAmountLocal)
                                                    WHEN '-' THEN ABS(t.SettlementAmountLocal) + ABS(ISNULL(t.AccruedIncomeLocal, 0))
                                                    WHEN '+' THEN ABS(t.SettlementAmountLocal) + -1 * ABS(ISNULL(t.AccruedIncomeLocal, 0))
                                                  END
                                             WHEN '+' THEN -- NEGATIVE
                                                  CASE stt.AccruedInterestImpact
                                                    WHEN '0' THEN -1 * ABS(t.SettlementAmountLocal)
                                                    WHEN '-' THEN -1 * ABS(t.SettlementAmountLocal) + ABS(ISNULL(t.AccruedIncomeLocal, 0))
                                                    WHEN '+' THEN -1 * ABS(t.SettlementAmountLocal) + -1 * ABS(ISNULL(t.AccruedIncomeLocal, 0))
                                                  END
                                             WHEN '0' THEN 0  -- ZERO
                                           END, 0)
                             END
      FROM      v_SEIClientTransactionAll t
                INNER JOIN dbo.SEITransactionType stt ON t.SEITransactionTypeID = stt.SEITransactionTypeID
                INNER JOIN Account a ON a.AccountID = T.AccountID
                INNER JOIN Custodian c ON c.CustodianID = a.CustodianID
                LEFT OUTER JOIN AssetBackedSecurity s ON s.SecurityIdentifier = T.SecurityIdentifier

GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
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
================================================================================
***/
 
SELECT sct.SEIClientTransactionID,
       a.AccountID,
       a.TargetAccountingSystemAccountIdentifier,
       a.CustodianAccountNumber,
       cl.ClientID,
       cl.ClientName,
       c.CustodianID,
       c.CustodianName,
       tas.TargetAccountingSystemID,
       tas.TargetAccountingSystemName,
       stt.SEITransactionTypeID,
       stt.TransactionType,
       i.CashImpact,
       sct.CustodianTransactionDescription,
       p.SendToTargetAccountingSystem,
       af.DateFileProcessed,
       af.FileNameDataDate,
       sct.Reversal,
       sct.SecurityIdentifier,
       sct.SecurityDescription,
       sct.SharesParValue,
       sct.AccruedIncomeLocal,
       sct.TransactionDate,
       sct.SettlementDate,
       sct.TradeDate,
       sct.OriginalFaceAmount,
       sct.SettlementAmountLocal,
       sct.CommissionsFees,
       sct.SentToTargetDate,
       scts.SEIClientTransactionStatusID,
       scts.StatusCode,
       sct.SystemCreateUser,
       sct.SystemUpdateUser,
       CASE WHEN sct.SentToTargetDate IS NOT NULL THEN 'Sent' 
			WHEN ISNULL(sct.SendToTargetAccountingSystem, 0) = 1 THEN 'Ready' 
			WHEN sct.SEIClientTransactionStatusID = 1 AND p.SEIClientTransactionID IS NOT NULL THEN 'NotReady'
			ELSE ISNULL(scts.StatusCode , 'Unknown')
	   END AS GeneralTransactionState,
       CASE WHEN ISNULL(af.AggregatorFileID, 0) > 0 THEN 'Custodian' 
			WHEN CHARINDEX('svcPAS', sct.SystemCreateUser) > 0 THEN 'Rule' 
			ELSE 'User' 
	   END AS CreatedByUserType

FROM   v_SEIClientTransactionALL sct
       INNER JOIN Account a
			ON sct.AccountID = a.AccountID
       INNER JOIN Client cl
			ON a.ClientID = cl.ClientID
       INNER JOIN Custodian c
			ON a.CustodianID = c.CustodianID
       INNER JOIN SEITransactionType stt
			ON sct.SEITransactionTypeID = stt.SEITransactionTypeID
       INNER JOIN TargetAccountingSystem tas
			ON cl.TargetAccountingSystemID = tas.TargetAccountingSystemID
       INNER JOIN v_SEIClientTransactionImpact i
		    ON sct.SEIClientTransactionID = i.SEIClientTransactionID
		    
       INNER JOIN dbo.SEIClientTransactionStatus    scts
		    ON scts.SEIClientTransactionStatusID = sct.SEIClientTransactionStatusID
       LEFT OUTER JOIN 
            (SELECT  sct2.SEIClientTransactionID, sct2.SendToTargetAccountingSystem
             FROM BalanceResult pbr
                INNER JOIN BalanceResultTransaction pbrt
			ON pbr.BalanceResultID = pbrt.BalanceResultID
			    INNER JOIN dbo.SEIClientTransaction sct2
			    ON sct2.SEIClientTransactionID =pbrt.SEIClientTransactionID 
			WHERE pbr.SecurityIdentifier = sct2.SecurityIdentifier ) p
			ON sct.SEIClientTransactionID = p.SEIClientTransactionID
       LEFT OUTER JOIN AggregatorFile af
			ON sct.AggregatorFileID = af.AggregatorFileID 

GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO 
PRINT N'Creating index [CI_EvareFileProcessing_FileNameDateAggregatorCustodianIdentifier] on [dbo].[EvareFileProcessing]'
GO
IF NOT EXISTS (SELECT 1 FROM sysindexes WHERE name = 'CI_EvareFileProcessing_FileNameDateAggregatorCustodianIdentifier')
CREATE CLUSTERED INDEX [CI_EvareFileProcessing_FileNameDateAggregatorCustodianIdentifier] ON [dbo].[EvareFileProcessing] ([FileNameDate], [AggregatorCustodianIdentifier])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_AggregatorFile_AggregatorFileTypeIDAggregatorFileIDSourceFileNameFileNameDataDate] on [dbo].[AggregatorFile]'
GO
IF NOT EXISTS (SELECT 1 FROM sysindexes WHERE name = 'NCI_AggregatorFile_AggregatorFileTypeIDAggregatorFileIDSourceFileNameFileNameDataDate')
CREATE NONCLUSTERED INDEX [NCI_AggregatorFile_AggregatorFileTypeIDAggregatorFileIDSourceFileNameFileNameDataDate] ON [dbo].[AggregatorFile] ([AggregatorFileTypeID], [AggregatorFileID], [SourceFileName], [FileNameDataDate])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_SEIPosition_SourceFileNameIncludeCustodianID] on [dbo].[SEIPosition]'
GO
IF NOT EXISTS (SELECT 1 FROM sysindexes WHERE name = 'NCI_SEIPosition_SourceFileNameIncludeCustodianID')
CREATE NONCLUSTERED INDEX [NCI_SEIPosition_SourceFileNameIncludeCustodianID] ON [dbo].[SEIPosition] ([SourceFileName]) INCLUDE ([CustodianID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating index [NCI_sysssislog_StartTime] on [dbo].[sysssislog]'
GO
IF NOT EXISTS (SELECT 1 FROM sysindexes WHERE name = 'NCI_sysssislog_StartTime')
CREATE NONCLUSTERED INDEX [NCI_sysssislog_StartTime] ON [dbo].[sysssislog] ([starttime]) INCLUDE ([id])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Adding constraints to [dbo].[ArchiveSEIClientTransaction]'
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'chk_ArchiveSEIClientTransactionRecordBasis' AND xtype = 'c')
ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ADD CONSTRAINT [chk_ArchiveSEIClientTransactionRecordBasis] CHECK (([AggregatorRecordBasis]='SD' OR [AggregatorRecordBasis]='TD'))
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'chk_ArchiveSEIClientTransactionRecordType' AND xtype = 'c')
ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ADD CONSTRAINT [chk_ArchiveSEIClientTransactionRecordType] CHECK (([AggregatorRecordType]='TRAN'))
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'chk_ArchiveSEIClientTransactionSecurityIdentifierType' AND xtype = 'c')
ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ADD CONSTRAINT [chk_ArchiveSEIClientTransactionSecurityIdentifierType] CHECK (([SecurityIdentifierType]='TICKER' OR [SecurityIdentifierType]='OTHER' OR [SecurityIdentifierType]='ISIN' OR [SecurityIdentifierType]='CUSIP' OR [SecurityIdentifierType]='SEDOL'))
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'DF_ArchiveSEIClientTransaction_Reversal' AND xtype = 'DF')
ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ADD CONSTRAINT [DF_ArchiveSEIClientTransaction_Reversal] DEFAULT ((0)) FOR [Reversal]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'DF_ArchiveSEIClientTransaction_SystemCreateDate' AND xtype = 'DF')
ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ADD CONSTRAINT [DF_ArchiveSEIClientTransaction_SystemCreateDate] DEFAULT (GETDATE()) FOR [SystemCreateDate]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'DF_ArchiveSEIClientTransaction_SystemCreateUser' AND xtype = 'DF')
ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ADD CONSTRAINT [DF_ArchiveSEIClientTransaction_SystemCreateUser] DEFAULT (SUSER_NAME()) FOR [SystemCreateUser]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'DF_ArchiveSEIClientTransaction_SystemUpdateDate' AND xtype = 'DF')
ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ADD CONSTRAINT [DF_ArchiveSEIClientTransaction_SystemUpdateDate] DEFAULT (GETDATE()) FOR [SystemUpdateDate]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'DF_ArchiveSEIClientTransaction_SystemUpdateUser' AND xtype = 'DF')
ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ADD CONSTRAINT [DF_ArchiveSEIClientTransaction_SystemUpdateUser] DEFAULT (SUSER_NAME()) FOR [SystemUpdateUser]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'DF_ArchiveSEIClientTransaction_ArchiveDate' AND xtype = 'DF')
ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ADD CONSTRAINT [DF_ArchiveSEIClientTransaction_ArchiveDate] DEFAULT (GETDATE()) FOR [ArchiveDate]
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Adding constraints to [dbo].[AggregatorFileAccount]'
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'UC_AggregatorFileAccount' AND xtype = 'UQ')
ALTER TABLE [dbo].[AggregatorFileAccount] ADD CONSTRAINT [UC_AggregatorFileAccount] UNIQUE NONCLUSTERED  ([AggregatorFileID], [CustodianAccountNumber], [CustodianID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Adding constraints to [dbo].[TradeFilterSource]'
GO
IF NOT EXISTS (SELECT 1 FROM sysobjects WHERE name = 'UC_TradeFilterSource_TradeFilterSourceName' AND xtype = 'UQ')
ALTER TABLE [dbo].[TradeFilterSource] ADD CONSTRAINT [UC_TradeFilterSource_TradeFilterSourceName] UNIQUE NONCLUSTERED  ([TradeFilterSourceName])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Adding foreign keys to [dbo].[AccountQueue]'
GO
IF (SELECT COUNT(1) FROM sysobjects WHERE name IN ('FK_AccountQueue_AccountID', 'FK_AccountQueue_AccountQueueStatusID') AND xtype = 'F') =0
ALTER TABLE [dbo].[AccountQueue] ADD
CONSTRAINT [FK_AccountQueue_AccountID] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([AccountID]),
CONSTRAINT [FK_AccountQueue_AccountQueueStatusID] FOREIGN KEY ([AccountQueueStatusID]) REFERENCES [dbo].[AccountQueueStatus] ([AccountQueueStatusID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Adding foreign keys to [dbo].[AggregatorFileAccount]'
GO
IF (SELECT COUNT(1) FROM sysobjects WHERE name IN ('FK_AggregatorFileAccount_AggregatorFileID', 'FK_AggregatorFileAccount_CustodianID') AND xtype = 'F') =0
ALTER TABLE [dbo].[AggregatorFileAccount] ADD
CONSTRAINT [FK_AggregatorFileAccount_AggregatorFileID] FOREIGN KEY ([AggregatorFileID]) REFERENCES [dbo].[AggregatorFile] ([AggregatorFileID]),
CONSTRAINT [FK_AggregatorFileAccount_CustodianID] FOREIGN KEY ([CustodianID]) REFERENCES [dbo].[Custodian] ([CustodianID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Adding foreign keys to [dbo].[ArchiveSEIClientTransaction]'
GO
IF (SELECT COUNT(1) FROM sysobjects WHERE name IN ('FK_ArchiveSEIClientTransaction_AccountID', 'FK_ArchiveSEIClientTransaction_AggregatorFileID'
,   'FK_ArchiveSEIClientTransaction_SEIClientTransactionStatusID', 'FK_ArchiveSEIClientTransaction_SEITransactionTypeID') AND xtype = 'F') =0
ALTER TABLE [dbo].[ArchiveSEIClientTransaction] ADD
CONSTRAINT [FK_ArchiveSEIClientTransaction_AccountID] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([AccountID]),
CONSTRAINT [FK_ArchiveSEIClientTransaction_AggregatorFileID] FOREIGN KEY ([AggregatorFileID]) REFERENCES [dbo].[AggregatorFile] ([AggregatorFileID]),
CONSTRAINT [FK_ArchiveSEIClientTransaction_SEIClientTransactionStatusID] FOREIGN KEY ([SEIClientTransactionStatusID]) REFERENCES [dbo].[SEIClientTransactionStatus] ([SEIClientTransactionStatusID]),
CONSTRAINT [FK_ArchiveSEIClientTransaction_SEITransactionTypeID] FOREIGN KEY ([SEITransactionTypeID]) REFERENCES [dbo].[SEITransactionType] ([SEITransactionTypeID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Adding foreign keys to [dbo].[ArchiveSEIClientTransactionMessageHistory]'
GO
IF (SELECT COUNT(1) FROM sysobjects WHERE name ='FK_ArchiveSEIClientTransactionMessageHistory_SEIClientTransactionID' AND xtype = 'F') =0
ALTER TABLE [dbo].[ArchiveSEIClientTransactionMessageHistory] ADD
CONSTRAINT [FK_ArchiveSEIClientTransactionMessageHistory_SEIClientTransactionID] FOREIGN KEY ([SEIClientTransactionID]) REFERENCES [dbo].[ArchiveSEIClientTransaction] ([SEIClientTransactionID]) ON DELETE CASCADE
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Adding foreign keys to [dbo].[BalanceResultComment]'
GO
IF (SELECT COUNT(1) FROM sysobjects WHERE name IN ('FK_BalanceResultComment_BalanceResultID', 'FK_BalanceResultComment_BalanceResultCommentTypeID') AND xtype = 'F') =0
ALTER TABLE [dbo].[BalanceResultComment] ADD
CONSTRAINT [FK_BalanceResultComment_BalanceResultID] FOREIGN KEY ([BalanceResultID]) REFERENCES [dbo].[BalanceResult] ([BalanceResultID]) ON DELETE CASCADE,
CONSTRAINT [FK_BalanceResultComment_BalanceResultCommentTypeID] FOREIGN KEY ([BalanceResultCommentTypeID]) REFERENCES [dbo].[BalanceResultCommentType] ([BalanceResultCommentTypeID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Adding foreign keys to [dbo].[BalanceResultTransaction]'
GO
IF (SELECT COUNT(1) FROM sysobjects WHERE name IN ('FK_BalanceResultTransaction_BalanceResultID', 'FK_BalanceResultTransaction_SEIClientTransactionID') AND xtype = 'F') =0
ALTER TABLE [dbo].[BalanceResultTransaction] ADD
CONSTRAINT [FK_BalanceResultTransaction_BalanceResultID] FOREIGN KEY ([BalanceResultID]) REFERENCES [dbo].[BalanceResult] ([BalanceResultID]) ON DELETE CASCADE,
CONSTRAINT [FK_BalanceResultTransaction_SEIClientTransactionID] FOREIGN KEY ([SEIClientTransactionID]) REFERENCES [dbo].[SEIClientTransaction] ([SEIClientTransactionID]) ON DELETE CASCADE
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Adding foreign keys to [dbo].[BalanceResult]'
GO
IF (SELECT COUNT(1) FROM sysobjects WHERE name IN ('FK_BalanceResult_PendingStatusID', 'FK_BalanceResult_LastPendingStatusID') AND xtype = 'F') =0
ALTER TABLE [dbo].[BalanceResult] ADD
CONSTRAINT [FK_BalanceResult_PendingStatusID] FOREIGN KEY ([PendingStatusID]) REFERENCES [dbo].[PendingStatus] ([PendingStatusID]),
CONSTRAINT [FK_BalanceResult_LastPendingStatusID] FOREIGN KEY ([LastPendingStatusID]) REFERENCES [dbo].[PendingStatus] ([PendingStatusID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Adding foreign keys to [dbo].[SEIClientTransactionMessageHistory]'
GO
IF (SELECT COUNT(1) FROM sysobjects WHERE name = 'FK_SEIClientTransactionMessageHistory_SEIClientTransactionID' AND xtype = 'F') =0
ALTER TABLE [dbo].[SEIClientTransactionMessageHistory] ADD
CONSTRAINT [FK_SEIClientTransactionMessageHistory_SEIClientTransactionID] FOREIGN KEY ([SEIClientTransactionID]) REFERENCES [dbo].[SEIClientTransaction] ([SEIClientTransactionID]) ON DELETE CASCADE
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Adding foreign keys to [dbo].[TargetAccountingSystemPosition]'
GO
IF (SELECT COUNT(1) FROM sysobjects WHERE name = 'FK_TargetAccountingSystemPosition_AccountID' AND xtype = 'F') =0
ALTER TABLE [dbo].[TargetAccountingSystemPosition] ADD
CONSTRAINT [FK_TargetAccountingSystemPosition_AccountID] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([AccountID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Adding foreign keys to [dbo].[TradeFilterClientTransaction]'
GO
IF (SELECT COUNT(1) FROM sysobjects WHERE name IN ('FK_TradeFilterClientTransaction_AccountID'
, 'FK_TradeFilterClientTransaction_TradeFilterSourceID', 'FK_TradeFilterClientTransaction_SEITransactionTypeID') AND xtype = 'F') =0
ALTER TABLE [dbo].[TradeFilterClientTransaction] ADD
CONSTRAINT [FK_TradeFilterClientTransaction_AccountID] FOREIGN KEY ([AccountID]) REFERENCES [dbo].[Account] ([AccountID]),
CONSTRAINT [FK_TradeFilterClientTransaction_TradeFilterSourceID] FOREIGN KEY ([TradeFilterSourceID]) REFERENCES [dbo].[TradeFilterSource] ([TradeFilterSourceID]),
CONSTRAINT [FK_TradeFilterClientTransaction_SEITransactionTypeID] FOREIGN KEY ([SEITransactionTypeID]) REFERENCES [dbo].[SEITransactionType] ([SEITransactionTypeID])
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering trigger [dbo].[ti_TargetAccountingSystemPosition] on [dbo].[TargetAccountingSystemPosition]'
GO
/* 
 * TRIGGER: dbo.ti_TargetAccountingSystemPosition 
 */


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER TRIGGER [dbo].[ti_TargetAccountingSystemPosition] ON [dbo].[TargetAccountingSystemPosition]
      FOR INSERT
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
      UPDATE    a
      SET       SystemCreateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
      FROM      TargetAccountingSystemPosition a
                INNER JOIN INSERTED i ON a.TargetAccountingSystemPositionID = i.TargetAccountingSystemPositionID


GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Altering trigger [dbo].[tu_TargetAccountingSystemPosition] on [dbo].[TargetAccountingSystemPosition]'
GO




/* 
 * TRIGGER: dbo.tu_TargetAccountingSystemPosition 
 */





------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER TRIGGER [dbo].[tu_TargetAccountingSystemPosition] ON [dbo].[TargetAccountingSystemPosition]
      FOR UPDATE
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
      UPDATE    a
      SET       SystemUpdateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
      FROM      TargetAccountingSystemPosition a
                INNER JOIN INSERTED i ON a.TargetAccountingSystemPositionID = i.TargetAccountingSystemPositionID


GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO


PRINT N'Creating trigger [dbo].[ti_AccountQueue] on [dbo].[AccountQueue]'
GO
/* 
 * TRIGGER: dbo.ti_AccountQueue 
 */
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ti_AccountQueue' AND xtype = 'tr' ) 
DROP TRIGGER dbo.ti_AccountQueue
go 
CREATE TRIGGER [dbo].[ti_AccountQueue] ON dbo.AccountQueue
       FOR INSERT
AS
       /***
================================================================================
Author : LRhoads  
Description : Trigger
===============================================================================
Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
================================================================================
***/
       UPDATE   a
       SET      SystemCreateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     AccountQueue a
                INNER JOIN INSERTED i ON a.AccountQueueID = i.AccountQueueID
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[tu_AccountQueue] on [dbo].[AccountQueue]'
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'tu_AccountQueue' AND xtype = 'tr' ) 
DROP TRIGGER dbo.tu_AccountQueue
GO
/* 
 * TRIGGER: dbo.tu_AccountQueue 
 */

CREATE TRIGGER [dbo].[tu_AccountQueue] ON dbo.AccountQueue
       FOR UPDATE
AS
       /***
================================================================================
Author : LRhoads 
Description : Trigger
===============================================================================
Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
================================================================================
***/
       UPDATE   a
       SET      SystemUpdateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     AccountQueue a
                INNER JOIN INSERTED i ON a.AccountQueueID = i.AccountQueueID
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[ti_AccountQueueStatus] on [dbo].[AccountQueueStatus]'
GO


IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ti_AccountQueueStatus' AND xtype = 'tr' ) 
DROP TRIGGER dbo.ti_AccountQueueStatus
GO


/* 
 * TRIGGER: dbo.ti_AccountQueueStatus 
 */

CREATE TRIGGER [dbo].[ti_AccountQueueStatus] ON [dbo].[AccountQueueStatus]
       FOR INSERT
AS
       /***
================================================================================
Author : LRhoads  
Description : Trigger
===============================================================================
Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
================================================================================
***/
       UPDATE   a
       SET      SystemCreateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     AccountQueueStatus a
                INNER JOIN INSERTED i ON a.AccountQueueStatusID = i.AccountQueueStatusID



GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[tu_AccountQueueStatus] on [dbo].[AccountQueueStatus]'
GO


IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'tu_AccountQueueStatus' AND xtype = 'tr' ) 
DROP TRIGGER dbo.tu_AccountQueueStatus
GO



/* 
 * TRIGGER: dbo.tu_AccountQueueStatus 
 */

CREATE TRIGGER [dbo].[tu_AccountQueueStatus] ON [dbo].[AccountQueueStatus]
       FOR UPDATE
AS
       /***
================================================================================
Author : LRhoads 
Description : Trigger
===============================================================================
Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
================================================================================
***/
       UPDATE   a
       SET      SystemUpdateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     AccountQueueStatus a
                INNER JOIN INSERTED i ON a.AccountQueueStatusID = i.AccountQueueStatusID



GO


IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[ti_AggregatorFileAccount] on [dbo].[AggregatorFileAccount]'
GO

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ti_AggregatorFileAccount' AND xtype = 'tr' ) 
DROP TRIGGER dbo.ti_AggregatorFileAccount
GO
CREATE TRIGGER [dbo].[ti_AggregatorFileAccount] ON [dbo].[AggregatorFileAccount]
       FOR INSERT
AS
       /***
================================================================================
Author : LRhoads 2011.04.15
Description : Trigger
===============================================================================
Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
================================================================================
***/
       UPDATE   a
       SET      SystemCreateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     AggregatorFileAccount a
                INNER JOIN INSERTED i ON a.AggregatorFileAccountID = i.AggregatorFileAccountID




GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[tu_AggregatorFileAccount] on [dbo].[AggregatorFileAccount]'
GO



IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'tu_AggregatorFileAccount' AND xtype = 'tr' ) 
DROP TRIGGER dbo.tu_AggregatorFileAccount
GO
CREATE TRIGGER [dbo].[tu_AggregatorFileAccount] ON [dbo].[AggregatorFileAccount]
       FOR UPDATE
AS
       /***
================================================================================
Author : LRhoads 2011.04.15
Description : Trigger
===============================================================================
Revisions :
--------------------------------------------------------------------------------
Ini| Date | Description
--------------------------------------------------------------------------------
================================================================================
***/
       UPDATE   a
       SET      SystemUpdateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     AggregatorFileAccount a
                INNER JOIN INSERTED i ON a.AggregatorFileAccountID = i.AggregatorFileAccountID




GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[ti_BalanceResult] on [dbo].[BalanceResult]'
GO

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ti_BalanceResult' AND xtype = 'tr' ) 
DROP TRIGGER dbo.ti_BalanceResult
GO
/* 
 * TRIGGER: dbo.ti_BalanceResult 
 */

CREATE TRIGGER [dbo].[ti_BalanceResult] ON [dbo].[BalanceResult]
       FOR INSERT
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
LLR  2011.05.24 table name change
================================================================================
***/
       UPDATE   a
       SET      SystemCreateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     BalanceResult a
                INNER JOIN INSERTED i ON a.BalanceResultID = i.BalanceResultID

GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[tu_BalanceResult] on [dbo].[BalanceResult]'
GO
/* 
 * TRIGGER: dbo.tu_BalanceResult 
 */

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'tu_BalanceResult' AND xtype = 'tr' ) 
DROP TRIGGER dbo.tu_BalanceResult
GO
CREATE TRIGGER [dbo].[tu_BalanceResult] ON [dbo].[BalanceResult]
       FOR UPDATE
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
LLR  2011.05.24 table name change
================================================================================
***/
       UPDATE   a
       SET      SystemUpdateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     BalanceResult a
                INNER JOIN INSERTED i ON a.BalanceResultID = i.BalanceResultID
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[ti_BalanceResultComment] on [dbo].[BalanceResultComment]'
GO
/* 
 * TRIGGER: dbo.ti_BalanceResult 
 */

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ti_BalanceResultComment' AND xtype = 'tr' ) 
DROP TRIGGER dbo.ti_BalanceResultComment
GO

CREATE TRIGGER [dbo].[ti_BalanceResultComment] ON [dbo].[BalanceResultComment]
       FOR INSERT
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
LLR  2011.05.24 table name change
================================================================================
***/
       UPDATE   a
       SET      SystemCreateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     BalanceResultComment a
                INNER JOIN INSERTED i ON a.BalanceResultCommentID = i.BalanceResultCommentID




GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[tu_BalanceResultComment] on [dbo].[BalanceResultComment]'
GO

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'tu_BalanceResultComment' AND xtype = 'tr' ) 
DROP TRIGGER dbo.tu_BalanceResultComment
GO
/* 
 * TRIGGER: dbo.tu_BalanceResultComment 
 */

CREATE TRIGGER [dbo].[tu_BalanceResultComment] ON [dbo].[BalanceResultComment]
       FOR UPDATE
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
LLR  2011.05.24 table name change
================================================================================
***/
       UPDATE   a
       SET      SystemUpdateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     BalanceResultComment a
                INNER JOIN INSERTED i ON a.BalanceResultCommentID = i.BalanceResultCommentID




GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[ti_BalanceResultCommentType] on [dbo].[BalanceResultCommentType]'
GO


IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ti_BalanceResultCommentType' AND xtype = 'tr' ) 
DROP TRIGGER dbo.ti_BalanceResultCommentType
GO

/* 
 * TRIGGER: dbo.ti_BalanceResultCommentType 
 */

CREATE TRIGGER [dbo].[ti_BalanceResultCommentType] ON [dbo].[BalanceResultCommentType]
       FOR INSERT
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
LLR  2011.05.24 table name change
================================================================================
***/
       UPDATE   a
       SET      SystemCreateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     BalanceResultCommentType a
                INNER JOIN INSERTED i ON a.BalanceResultCommentTypeID = i.BalanceResultCommentTypeID

GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[tu_BalanceResultCommentType] on [dbo].[BalanceResultCommentType]'
GO



IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'tu_BalanceResultCommentType' AND xtype = 'tr' ) 
DROP TRIGGER dbo.tu_BalanceResultCommentType
GO
/* 
 * TRIGGER: dbo.tu_BalanceResultCommentType 
 */

CREATE TRIGGER [dbo].[tu_BalanceResultCommentType] ON [dbo].[BalanceResultCommentType]
       FOR UPDATE
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
LLR  2011.05.24 table name change
================================================================================
***/
       UPDATE   a
       SET      SystemUpdateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     BalanceResultCommentType a
                INNER JOIN INSERTED i ON a.BalanceResultCommentTypeID = i.BalanceResultCommentTypeID

GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[tu_SEIClientTransaction] on [dbo].[SEIClientTransaction]'
GO


IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'tu_SEIClientTransaction' AND xtype = 'tr' ) 
DROP TRIGGER dbo.tu_SEIClientTransaction
GO
CREATE TRIGGER [dbo].[tu_SEIClientTransaction] ON [dbo].[SEIClientTransaction]
       FOR UPDATE
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
       UPDATE   a
       SET      SystemUpdateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     SEIClientTransaction a
                INNER JOIN INSERTED i ON a.SEIClientTransactionID = i.SEIClientTransactionID


GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[tUID_SEIClientTransaction_ForArchival] on [dbo].[SEIClientTransaction]'
GO

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'tUID_SEIClientTransaction_ForArchival' AND xtype = 'tr' ) 
DROP TRIGGER dbo.tUID_SEIClientTransaction_ForArchival
GO

-- =============================================
-- Author:		LRhoads
-- Create date: 2011.04.26
-- Description:	Trigger to move rows to ArchiveSEIClientTransaction
--              AND ArchiveSEIClientTransactionMessageHistory (ODT results)
--              Only rows still actively involved in PreBalance are 
--              retained all others are archived.
-- =============================================
CREATE TRIGGER [dbo].[tUID_SEIClientTransaction_ForArchival] ON [dbo].[SEIClientTransaction]
       AFTER INSERT, DELETE, UPDATE
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
                            SELECT  sct.SEIClientTransactionID
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
                            , MessageSourceNum
                            , MessageSourceTxt
                            , SystemCreateDate
                            , SystemCreateUser
                            , SystemUpdateDate
                            , SystemUpdateUser
                            )
                            SELECT  SEIClientTransactionMessageHistoryID
                                  , sctmh.SEIClientTransactionID
                                  , MessageSource
                                  , MessageSourceNum
                                  , MessageSourceTxt
                                  , SystemCreateDate
                                  , SystemCreateUser
                                  , SystemUpdateDate
                                  , SystemUpdateUser
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
            
                   DECLARE @errmsg VARCHAR(100)
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
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
EXEC sp_settriggerorder N'[dbo].[tUID_SEIClientTransaction_ForArchival]', 'last', 'update', NULL
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[ti_SEIClientTransactionMessageHistory] on [dbo].[SEIClientTransactionMessageHistory]'
GO

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ti_SEIClientTransactionMessageHistory' AND xtype = 'tr' ) 
DROP TRIGGER dbo.ti_SEIClientTransactionMessageHistory
GO
/* 
 * TRIGGER: dbo.ti_SEIClientTransactionMessageHistory
 */

CREATE TRIGGER [dbo].[ti_SEIClientTransactionMessageHistory] ON [dbo].[SEIClientTransactionMessageHistory]
       FOR INSERT
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
       UPDATE   a
       SET      SystemCreateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     SEIClientTransactionMessageHistory a
                INNER JOIN INSERTED i ON a.SEIClientTransactionMessageHistoryID = i.SEIClientTransactionMessageHistoryID





GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[tu_SEIClientTransactionMessageHistory] on [dbo].[SEIClientTransactionMessageHistory]'
GO


IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'tu_SEIClientTransactionMessageHistory' AND xtype = 'tr' ) 
DROP TRIGGER dbo.tu_SEIClientTransactionMessageHistory
GO

CREATE TRIGGER [dbo].[tu_SEIClientTransactionMessageHistory] ON [dbo].[SEIClientTransactionMessageHistory]
       FOR UPDATE
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
       UPDATE   a
       SET      SystemUpdateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     SEIClientTransactionMessageHistory a
                INNER JOIN INSERTED i ON a.SEIClientTransactionMessageHistoryID = i.SEIClientTransactionMessageHistoryID





GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[ti_TradeFilterClientTransaction] on [dbo].[TradeFilterClientTransaction]'
GO



IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ti_TradeFilterClientTransaction' AND xtype = 'tr' ) 
DROP TRIGGER dbo.ti_TradeFilterClientTransaction
GO



/* 
 * TRIGGER: dbo.ti_TradeFilterClientTransaction 
 */

CREATE TRIGGER [dbo].[ti_TradeFilterClientTransaction] ON [dbo].[TradeFilterClientTransaction]
       FOR INSERT
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
       UPDATE   a
       SET      SystemCreateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     TradeFilterClientTransaction a
                INNER JOIN INSERTED i ON a.TradeFilterClientTransactionID = i.TradeFilterClientTransactionID



GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[tu_TradeFilterClientTransaction] on [dbo].[TradeFilterClientTransaction]'
GO




IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'tu_TradeFilterClientTransaction' AND xtype = 'tr' ) 
DROP TRIGGER dbo.tu_TradeFilterClientTransaction
GO



/* 
 * TRIGGER: dbo.tu_TradeFilterClientTransaction 
 */

CREATE TRIGGER [dbo].[tu_TradeFilterClientTransaction] ON [dbo].[TradeFilterClientTransaction]
       FOR UPDATE
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
       UPDATE   a
       SET      SystemUpdateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     TradeFilterClientTransaction a
                INNER JOIN INSERTED i ON a.TradeFilterClientTransactionID = i.TradeFilterClientTransactionID



GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[ti_TradeFilterClientTransactionMatch] on [dbo].[TradeFilterClientTransactionMatch]'
GO

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ti_TradeFilterClientTransactionMatch' AND xtype = 'tr' ) 
DROP TRIGGER dbo.ti_TradeFilterClientTransactionMatch
GO

 

     
CREATE TRIGGER [dbo].[ti_TradeFilterClientTransactionMatch] ON [dbo].[TradeFilterClientTransactionMatch]
       FOR INSERT
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
================================================================================
***/
       UPDATE   a
       SET      SystemCreateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     TradeFilterClientTransactionMatch a
                INNER JOIN INSERTED i ON a.TradeFilterClientTransactionMatchID = i.TradeFilterClientTransactionMatchID



GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[tu_TradeFilterClientTransactionMatch] on [dbo].[TradeFilterClientTransactionMatch]'
GO


IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'tu_TradeFilterClientTransactionMatch' AND xtype = 'tr' ) 
DROP TRIGGER dbo.tu_TradeFilterClientTransactionMatch
GO


     
CREATE TRIGGER [dbo].[tu_TradeFilterClientTransactionMatch] ON [dbo].[TradeFilterClientTransactionMatch]
       FOR UPDATE
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
================================================================================
***/
       UPDATE   a
       SET      SystemUpdateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     TradeFilterClientTransactionMatch a
                INNER JOIN INSERTED i ON a.TradeFilterClientTransactionMatchID = i.TradeFilterClientTransactionMatchID



GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[ti_TradeFilterSource] on [dbo].[TradeFilterSource]'
GO


IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'ti_TradeFilterSource' AND xtype = 'tr' ) 
DROP TRIGGER dbo.ti_TradeFilterSource
GO

CREATE TRIGGER [dbo].[ti_TradeFilterSource] ON [dbo].[TradeFilterSource]
       FOR INSERT
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
       UPDATE   a
       SET      SystemCreateDate = CURRENT_TIMESTAMP
              , SystemCreateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemCreateUser
                                        ELSE SUSER_NAME()
                                   END
              , SystemUpdateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemCreateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     TradeFilterSource a
                INNER JOIN INSERTED i ON a.TradeFilterSourceID = i.TradeFilterSourceID
 
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
PRINT N'Creating trigger [dbo].[tu_TradeFilterSource] on [dbo].[TradeFilterSource]'
GO

IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'tu_TradeFilterSource' AND xtype = 'tr' ) 
DROP TRIGGER dbo.tu_TradeFilterSource
GO


CREATE TRIGGER [dbo].[tu_TradeFilterSource] ON [dbo].[TradeFilterSource]
       FOR UPDATE
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
       UPDATE   a
       SET      SystemUpdateDate = CURRENT_TIMESTAMP
              , SystemUpdateUser = CASE WHEN UPDATE(SystemUpdateUser) THEN i.SystemUpdateUser
                                        ELSE SUSER_NAME()
                                   END
       FROM     TradeFilterSource a
                INNER JOIN INSERTED i ON a.TradeFilterSourceID = i.TradeFilterSourceID


GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO


--Move data to ArchiveSEIClientTransaction
--delete existing data
DELETE  dbo.ArchiveSEIClientTransaction
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO

GO  
--now insert the ones that have been sent, etc...
INSERT  dbo.ArchiveSEIClientTransaction
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
        , ArchiveDate
        , TradeFilterClientTransactionMatchID
        , SystemCreateDate
        , SystemCreateUser
        , SystemUpdateDate
        , SystemUpdateUser
        )
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
              , sct.SEIClientTransactionStatusID
              , Reversal
              , AggregatorTransactionSubType
              , SentToTargetDate
              , CostBasisBase
              , CostBasisLocal
              , CURRENT_TIMESTAMP
              , NULL
              , sct.SystemCreateDate
              , sct.SystemCreateUser
              , sct.SystemUpdateDate
              , sct.SystemUpdateUser
        FROM    dbo.SEIClientTransaction sct
                INNER JOIN dbo.SEIClientTransactionStatus scts ON sct.SEIClientTransactionStatusID = scts.SEIClientTransactionStatusID
        WHERE   PreBalance = 0        
        
        
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
--now delete them:
DELETE sct
FROM dbo.SEIClientTransaction sct
                INNER JOIN dbo.ArchiveSEIClientTransaction asct ON sct.SEIClientTransactionID = asct.SEIClientTransactionID


GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO


GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO

GO
--AggregatorFileAccount -- need to do this before we purge the Stage tables

INSERT  dbo.AggregatorFileAccount
        (
          AggregatorFileID
        , CustodianAccountNumber
        , CustodianID
        )
        SELECT DISTINCT
                AggregatorFileID
              , a.ACCOUNT_NUMBER
              , c.CustodianID
        FROM    dbo.Stage_BAAPosition s
                INNER JOIN dbo.Stage_BAAAccount a ON a.ACCOUNT_NUMBER = s.ACCOUNT_NUMBER
                                                     AND a.DataDate = s.DataDate
                INNER JOIN dbo.AggregatorFile af ON af.SourceFileName = s.SourceFileName
                LEFT OUTER JOIN dbo.AggregatorCustodian c ON a.FINANCIAL_INSTITUTION_NAME = c.AggregatorCustodianIdentifier
        WHERE   c.AggregatorID = 2
        ORDER BY AggregatorFileID
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO

INSERT  dbo.AggregatorFileAccount
        (
          AggregatorFileID
        , CustodianAccountNumber
        , CustodianID
        )
        SELECT DISTINCT
                AggregatorFileID
              , a.ACCOUNT_NUMBER
              , c.CustodianID
        FROM    dbo.Stage_BAATransaction s
                INNER JOIN dbo.Stage_BAAAccount a ON a.ACCOUNT_NUMBER = s.ACCOUNT_NUMBER
                                                     AND a.DataDate = s.DataDate
                INNER JOIN dbo.AggregatorFile af ON af.SourceFileName = s.SourceFileName
                LEFT OUTER JOIN dbo.AggregatorCustodian c ON a.FINANCIAL_INSTITUTION_NAME = c.AggregatorCustodianIdentifier
        WHERE   c.AggregatorID = 2
        ORDER BY AggregatorFileID
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
                                                          
INSERT  dbo.AggregatorFileAccount
        (
          AggregatorFileID
        , CustodianAccountNumber
        , CustodianID
        )
        SELECT DISTINCT
                AggregatorFileID
              , s.AccountIdentifier
              , c.CustodianID
        FROM    dbo.Stage_EvarePosition s
                INNER JOIN dbo.AggregatorFile af ON af.SourceFileName = s.SourceFileName
                LEFT OUTER  JOIN dbo.AggregatorCustodian c ON s.Custodian = c.AggregatorCustodianIdentifier
        WHERE   c.AggregatorID = 1
        ORDER BY AggregatorFileID

GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO

UPDATE dbo.PASRuleType
SET RuleTypeName = 'Balance-Phase1'
WHERE PASRuleTypeID = 2
GO

IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO 
IF NOT EXISTS (SELECT 1 FROM dbo.PASRuleType prt WHERE RuleTypeName = 'Balance-Phase2')
INSERT dbo.PASRuleType
        (
          RuleTypeName
        )
VALUES  (
          'Balance-Phase2'
        )
        
        
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO

--

UPDATE dbo.PASRule
SET PASRuleTypeID = 4
WHERE PASRuleDescription = 'Create MM Sweep Transactions'
GO

IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
                      
INSERT  dbo.AggregatorFileAccount
        (
          AggregatorFileID
        , CustodianAccountNumber
        , CustodianID
        )
        SELECT DISTINCT
                AggregatorFileID
              , s.AccountIdentifier
              , c.CustodianID
        FROM    dbo.Stage_EvareTransaction s
                INNER JOIN dbo.AggregatorFile af ON af.SourceFileName = s.SourceFileName
                LEFT OUTER  JOIN dbo.AggregatorCustodian c ON s.Custodian = c.AggregatorCustodianIdentifier
        WHERE   c.AggregatorID = 1
        ORDER BY AggregatorFileID




GO
-- DELETE Stage
DELETE  dbo.Stage_BAAPosition
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO

DELETE  dbo.Stage_BAATransaction
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO

DELETE  dbo.Stage_EvarePosition
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO

DELETE  dbo.Stage_EvareTransaction
GO
IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO

DELETE  dbo.Stage_BAAAccount
WHERE   DataDate <> ( SELECT    MAX(DataDate)
                      FROM      dbo.Stage_BAAAccount
                    )




IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO



IF NOT EXISTS(SELECT 1 FROM SEIClientTransactionStatus WHERE StatusCode = 'Moxy')  
INSERT dbo.SEIClientTransactionStatus
        (
          StatusCode
        , StatusDescription
        , PreBalance
        , TradeFilter
        )
VALUES  ('Moxy'
        , 'Custodian transaction for MOXY trade'
        , 0
        , 0
        )

IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
        
IF NOT EXISTS(SELECT 1 FROM SEIClientTransactionStatus WHERE StatusCode = 'ODTFail')        
INSERT dbo.SEIClientTransactionStatus
        (
          StatusCode
        , StatusDescription
        , PreBalance
        , TradeFilter
        )
VALUES  ('ODTFail'
        , 'ODT Failure'
        , 1
        , 0
        )
 IF @@ERROR <> 0
   AND @@TRANCOUNT > 0 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT = 0 
   BEGIN
         INSERT INTO #tmpErrors
                ( Error )
                SELECT  1
         BEGIN TRANSACTION
   END
GO
       
        
PRINT N'Altering permissions on [dbo].[ArchiveSEIClientTransaction]'
GO
REVOKE INSERT ON  [dbo].[ArchiveSEIClientTransaction] TO [prole_PAS_APP]

PRINT N'Dropping index [UI_TradeFilterClientTransaction_AccountID] from [dbo].[TradeFilterClientTransaction]'
GO
DROP INDEX [UI_TradeFilterClientTransaction_AccountID] ON [dbo].[TradeFilterClientTransaction]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Dropping index [UI_TradeFilterClientTransaction_SEITransactionTypeID] from [dbo].[TradeFilterClientTransaction]'
GO
DROP INDEX [UI_TradeFilterClientTransaction_SEITransactionTypeID] ON [dbo].[TradeFilterClientTransaction]
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [NCI_AccountQueue_AccountQueueStatusID] on [dbo].[AccountQueue]'
GO
CREATE NONCLUSTERED INDEX [NCI_AccountQueue_AccountQueueStatusID] ON [dbo].[AccountQueue] ([AccountQueueStatusID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [NCI_TargetAccountingSystemPosition_AccountID] on [dbo].[TargetAccountingSystemPosition]'
GO
CREATE NONCLUSTERED INDEX [NCI_TargetAccountingSystemPosition_AccountID] ON [dbo].[TargetAccountingSystemPosition] ([AccountID]) INCLUDE ([CUSIP], [ISIN], [OtherSecurityType], [SEDOL])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [NCI_TradeFilterClientTransaction_AccountID] on [dbo].[TradeFilterClientTransaction]'
GO
CREATE NONCLUSTERED INDEX [NCI_TradeFilterClientTransaction_AccountID] ON [dbo].[TradeFilterClientTransaction] ([AccountID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [NCI_TradeFilterClientTransaction_SEITransactionTypeID] on [dbo].[TradeFilterClientTransaction]'
GO
CREATE NONCLUSTERED INDEX [NCI_TradeFilterClientTransaction_SEITransactionTypeID] ON [dbo].[TradeFilterClientTransaction] ([SEITransactionTypeID])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [NCI_TradeFilterClientTransactionMatch_AccountID] on [dbo].[TradeFilterClientTransactionMatch]'
GO
CREATE NONCLUSTERED INDEX [NCI_TradeFilterClientTransactionMatch_AccountID] ON [dbo].[TradeFilterClientTransactionMatch] ([AccountID]) INCLUDE ([SecurityIdentifier])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Adding constraints to [dbo].[TradeFilterClientTransaction]'
GO
ALTER TABLE [dbo].[TradeFilterClientTransaction] ADD CONSTRAINT [UC_TradeFilterClientTransaction_AccountIDPendingItemNum] UNIQUE NONCLUSTERED  ([AccountID], [PendingItemNum])
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

--Delete from SEIClientPosition -- now, we only keep the latest:
  ;WITH  FileDate
                          AS ( SELECT DISTINCT
                                        af.AggregatorFileID
                                      , afc.CustodianID
                                      , FileNameDataDate
                                      , RANK() OVER ( PARTITION BY af.AggregatorFileTypeID, afc.CustodianID ORDER BY FileNameDataDate DESC ) AS Rnk
                               FROM     dbo.AggregatorFile af
                                        INNER JOIN dbo.AggregatorFileCustodian afc ON afc.AggregatorFileID = af.AggregatorFileID
                                        INNER JOIN dbo.AggregatorFileType aft ON aft.AggregatorFileTypeID = af.AggregatorFileTypeID
                                                                                 AND SourceFileType = 'Pos'
                             )
                       DELETE   scp
                       FROM     dbo.SEIClientPosition scp
                                INNER JOIN FileDate fd ON scp.AggregatorFileID = fd.AggregatorFileID
                       WHERE    rnk > 1 
GO                       
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

PRINT N'Altering [dbo].[PasWebsiteLog]'
GO
ALTER TABLE [dbo].[PasWebsiteLog] ALTER COLUMN [RequestXml] [xml] NULL
GO
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO                       
                       
                       
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

SET IDENTITY_INSERT [dbo].[AccountQueueStatus] ON;
INSERT INTO [dbo].[AccountQueueStatus]([AccountQueueStatusID], [AccountQueueStatus])
SELECT 1, N'Pending'UNION ALL
SELECT 2, N'Running' UNION ALL
SELECT 3, N'Failed' UNION ALL
SELECT 4, N'PluckedQ'
IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO
PRINT N'Creating index [NCI_BalanceResult_SecurityIdentifier] on [dbo].[SecurityIdentifier]'
go 
IF NOT EXISTS(SELECT 1 FROM sysindexes WHERE name = 'NCI_BalanceResult_SecurityIdentifier')
CREATE NONCLUSTERED INDEX [NCI_BalanceResult_SecurityIdentifier] ON [dbo].[BalanceResult] ([SecurityIdentifier])

IF @@ERROR<>0 AND @@TRANCOUNT>0 ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT=0 BEGIN INSERT INTO #tmpErrors (Error) SELECT 1 BEGIN TRANSACTION END
GO

RAISERROR (N'[dbo].[AccountQueueStatus]: Insert Batch: 1.....Done!', 10, 1) WITH NOWAIT;
GO

SET IDENTITY_INSERT [dbo].[AccountQueueStatus] OFF;



GO
IF EXISTS ( SELECT  *
            FROM    #tmpErrors ) 
   ROLLBACK TRANSACTION
GO
IF @@TRANCOUNT > 0 
   BEGIN
         PRINT 'The database update succeeded'
         COMMIT TRANSACTION
   END
ELSE 
   PRINT 'The database update failed'
GO
DROP TABLE #tmpErrors
GO






COMMIT TRAN 

/* sp_rename generator:
SELECT 'EXEC sp_rename ''' + OBJECT_NAME(id)  + ''', ''' +  REPLACE(OBJECT_NAME(id), 'PreBalance', 'Balance') + ''''
FROM sysobjects 
 WHERE OBJECT_NAME(id) LIKE '%PreBalance%'  
ORDER BY type, OBJECT_NAME(id) 

SELECT 'EXEC sp_rename ''' + REPLACE(TABLE_NAME, 'PreBalance', 'Balance') + '.' + column_Name  + ''', ''' +  REPLACE(TABLE_NAME, 'PreBalance', 'Balance') + '.' +  REPLACE(column_Name, 'PreBalance', 'Balance') + ''', ''COLUMN'''
FROM INFORMATION_SCHEMA.COLUMNS
 WHERE COLUMN_NAME LIKE '%PreBalance%'  

SELECT * FROM INFORMATION_SCHEMA.COLUMNS 

*/ 


