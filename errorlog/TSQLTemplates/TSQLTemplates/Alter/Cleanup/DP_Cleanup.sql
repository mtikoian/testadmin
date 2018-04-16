USE [NetikDP]
GO

/****** Object:  StoredProcedure [dbo].[p_NETIKDP_Truncate_Table]    Script Date: 8/15/2013 11:06:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


/***
================================================================================
 Name        : [p_NETIKDP_Truncate_Table]
 Author      : MSohail - 05/21/2012
 Description : This scripts truncate all the records from designated staging tables
===============================================================================
 
--------------------------------------------------------------------------------

 Return Value: Return code
     Success : 0
     Failure : Error Message and Number
                   Error number and Description
     Usage:	 EXEC p_NETIKDP_Truncate_Table
 Revisions    :
--------------------------------------------------------------------------------
 Ini		|   Date		|	Description
 MS		   05/21/2012		Initial Version
--------------------------------------------------------------------------------
================================================================================
***/
SET NOCOUNT ON 

DECLARE @BEGININGFKEYCOUNT INT
DECLARE @ENDINGFKEYCOUNT INT
DECLARE @FKMESSAGE VARCHAR(150);
BEGIN TRY 

	SELECT @BEGININGFKEYCOUNT = COUNT(1) FROM SYS.FOREIGN_KEYS
	
	SELECT @FKMESSAGE = 'BEGINNING COUNT OF THE FOREIGN KEYS ARE '+ CAST(@BEGININGFKEYCOUNT AS VARCHAR(20));
	
	TRUNCATE TABLE dbo.INF_DP_T_PositionActivity

	TRUNCATE TABLE dbo.INF_DP_PI_U_PositionActivity

	TRUNCATE TABLE dbo.DP_PI_U_ActgPeriodsActivity

	IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DP_T_ActgPeriodsActivityStateHistory_DP_T_ActgPeriodsActivity]') AND parent_object_id = OBJECT_ID(N'[dbo].[DP_T_ActgPeriodsActivityStateHistory]'))
	BEGIN
		ALTER TABLE [dbo].[DP_T_ActgPeriodsActivityStateHistory] DROP CONSTRAINT [FK_DP_T_ActgPeriodsActivityStateHistory_DP_T_ActgPeriodsActivity]
	END

		TRUNCATE TABLE dbo.DP_T_ActgPeriodsActivity

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DP_T_ActgPeriodsActivityStateHistory_DP_T_ActgPeriodsActivity]') AND parent_object_id = OBJECT_ID(N'[dbo].[DP_T_ActgPeriodsActivityStateHistory]'))
	BEGIN
		ALTER TABLE [dbo].[DP_T_ActgPeriodsActivityStateHistory]  WITH NOCHECK ADD  CONSTRAINT [FK_DP_T_ActgPeriodsActivityStateHistory_DP_T_ActgPeriodsActivity] FOREIGN KEY([ActivityId])
		REFERENCES [dbo].[DP_T_ActgPeriodsActivity] ([Id])
	END

	IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DP_T_ActgPeriodsActivityTargetStateHistory_DP_T_ActgPeriodsActivityTarget]') AND parent_object_id = OBJECT_ID(N'[dbo].[DP_T_ActgPeriodsActivityTargetStateHistory]'))
	BEGIN
		ALTER TABLE [dbo].[DP_T_ActgPeriodsActivityTargetStateHistory] DROP CONSTRAINT [FK_DP_T_ActgPeriodsActivityTargetStateHistory_DP_T_ActgPeriodsActivityTarget]
	END

		TRUNCATE TABLE dbo.DP_T_ActgPeriodsActivityTarget

	IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_DP_T_ActgPeriodsActivityTargetStateHistory_DP_T_ActgPeriodsActivityTarget]') AND parent_object_id = OBJECT_ID(N'[dbo].[DP_T_ActgPeriodsActivityTargetStateHistory]'))
	BEGIN
		ALTER TABLE [dbo].[DP_T_ActgPeriodsActivityTargetStateHistory]  WITH NOCHECK ADD  CONSTRAINT [FK_DP_T_ActgPeriodsActivityTargetStateHistory_DP_T_ActgPeriodsActivityTarget] FOREIGN KEY([ActivityTargetId])
		REFERENCES [dbo].[DP_T_ActgPeriodsActivityTarget] ([Id])
	END
	
	TRUNCATE TABLE  dbo.DP_T_ActgPeriodsActivityTargetStateHistory

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_TransactionActivityTargetStateHistory_DP_T_TransactionActivityTarget' AND TABLE_NAME='DP_T_TransactionActivityTargetStateHistory')
	BEGIN
		ALTER TABLE dbo.DP_T_TransactionActivityTargetStateHistory DROP CONSTRAINT FK_DP_T_TransactionActivityTargetStateHistory_DP_T_TransactionActivityTarget
	END

		TRUNCATE TABLE DBO.DP_T_TransactionActivityTarget

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_TransactionActivityTargetStateHistory_DP_T_TransactionActivityTarget' AND TABLE_NAME='DP_T_TransactionActivityTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_TransactionActivityTargetStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_TransactionActivityTargetStateHistory_DP_T_TransactionActivityTarget FOREIGN KEY(ActivityTargetId) REFERENCES DP_T_TransactionActivityTarget(Id)
	END

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_TransactionActivityStateHistory_DP_T_TransactionActivity' AND TABLE_NAME='DP_T_TransactionActivityStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_TransactionActivityStateHistory DROP CONSTRAINT FK_DP_T_TransactionActivityStateHistory_DP_T_TransactionActivity
	END

		TRUNCATE TABLE DBO.DP_T_TransactionActivity

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_TransactionActivityStateHistory_DP_T_TransactionActivity' AND TABLE_NAME='DP_T_TransactionActivityStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_TransactionActivityStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_TransactionActivityStateHistory_DP_T_TransactionActivity FOREIGN KEY(ActivityId) REFERENCES DP_T_TransactionActivity(Id)
	END

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_AccountActivityTargetStateHistory_DP_T_AccountActivityTarget' AND TABLE_NAME='DP_T_AccountActivityTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_AccountActivityTargetStateHistory DROP CONSTRAINT FK_DP_T_AccountActivityTargetStateHistory_DP_T_AccountActivityTarget
	END

		TRUNCATE TABLE DBO.DP_T_AccountActivityTarget

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_AccountActivityTargetStateHistory_DP_T_AccountActivityTarget' AND TABLE_NAME='DP_T_AccountActivityTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_AccountActivityTargetStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_AccountActivityTargetStateHistory_DP_T_AccountActivityTarget FOREIGN KEY(ActivityTargetId) REFERENCES DP_T_AccountActivityTarget(Id)
	END

	TRUNCATE TABLE DBO.DP_PI_U_ShareClassNavHistory

	TRUNCATE TABLE DBO.DP_PI_U_ShareClass

	TRUNCATE TABLE DBO.DP_T_ShareClassTarget

	TRUNCATE TABLE DBO.DP_T_ShareClass

	TRUNCATE TABLE DBO.DP_PI_U_Fund

	TRUNCATE TABLE DBO.DP_T_Fund

	TRUNCATE TABLE DBO.DP_T_FundTarget

	TRUNCATE TABLE DBO.DP_PI_U_AccumShrClsPer

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_AccumShrClsPerTargetStateHistory_DP_T_AccumShrClsPerTarget' AND TABLE_NAME='DP_T_AccumShrClsPerTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_AccumShrClsPerTargetStateHistory DROP CONSTRAINT FK_DP_T_AccumShrClsPerTargetStateHistory_DP_T_AccumShrClsPerTarget
	END

	TRUNCATE TABLE DBO.DP_T_AccumShrClsPerTarget

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_AccumShrClsPerTargetStateHistory_DP_T_AccumShrClsPerTarget' AND TABLE_NAME='DP_T_AccumShrClsPerTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_AccumShrClsPerTargetStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_AccumShrClsPerTargetStateHistory_DP_T_AccumShrClsPerTarget FOREIGN KEY(ActivityTargetId) REFERENCES DP_T_AccumShrClsPerTarget(Id)
	END

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_AccumShrClsPerStateHistory_DP_T_AccumShrClsPer' AND TABLE_NAME='DP_T_AccumShrClsPerStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_AccumShrClsPerStateHistory DROP CONSTRAINT FK_DP_T_AccumShrClsPerStateHistory_DP_T_AccumShrClsPer
	END

	TRUNCATE TABLE DBO.DP_T_AccumShrClsPerStateHistory

	TRUNCATE TABLE DBO.DP_T_AccumShrClsPer

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_AccumShrClsPerStateHistory_DP_T_AccumShrClsPer' AND TABLE_NAME='DP_T_AccumShrClsPerStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_AccumShrClsPerStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_AccumShrClsPerStateHistory_DP_T_AccumShrClsPer FOREIGN KEY(ActivityId) REFERENCES DP_T_AccumShrClsPer(Id)
	END

	TRUNCATE TABLE DBO.DP_T_ShareClassNavHistoryTarget

	TRUNCATE TABLE DBO.DP_T_ShareClassNavHistory

	TRUNCATE TABLE DBO.DP_PI_U_AccountTotals

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_IssueActivityStateHistory_DP_T_IssueActivity' AND TABLE_NAME='DP_T_IssueActivityStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_IssueActivityStateHistory DROP CONSTRAINT FK_DP_T_IssueActivityStateHistory_DP_T_IssueActivity
	END

	TRUNCATE TABLE DBO.DP_T_IssueActivity

	--TRUNCATE TABLE DBO.DP_LogHistory

	TRUNCATE TABLE DBO.DP_PI_U_TransactionActivity

	TRUNCATE TABLE DBO.DP_T_LotActivityTarget

	TRUNCATE TABLE DBO.DP_T_LotActivity

	TRUNCATE TABLE DBO.DP_PI_U_LotActivity

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_AccountTotalsTargetStateHistory_DP_T_AccountTotalsTarget' AND TABLE_NAME='DP_T_AccountTotalsTargetStateHistory')
	BEGIN
		ALTER TABLE dbo.DP_T_AccountTotalsTargetStateHistory DROP CONSTRAINT FK_DP_T_AccountTotalsTargetStateHistory_DP_T_AccountTotalsTarget
	END

	TRUNCATE TABLE DBO.DP_T_AccountTotalsTarget

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_AccountTotalsStateHistory_DP_T_AccountTotals' AND TABLE_NAME='DP_T_AccountTotalsStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_AccountTotalsStateHistory DROP CONSTRAINT FK_DP_T_AccountTotalsStateHistory_DP_T_AccountTotals
	END

	TRUNCATE TABLE DBO.DP_T_AccountTotals

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_AccountActivityStateHistory_DP_T_AccountActivity' AND TABLE_NAME='DP_T_AccountActivityStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_AccountActivityStateHistory DROP CONSTRAINT FK_DP_T_AccountActivityStateHistory_DP_T_AccountActivity
	END

	TRUNCATE TABLE DBO.DP_T_AccountActivity

	TRUNCATE TABLE DBO.DP_PI_U_Customer

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_CustomerTargetStateHistory_DP_T_CustomerTarget' AND TABLE_NAME='DP_T_CustomerTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_CustomerTargetStateHistory DROP CONSTRAINT FK_DP_T_CustomerTargetStateHistory_DP_T_CustomerTarget
	END

	TRUNCATE TABLE DBO.DP_T_CustomerTarget

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_CustomerStateHistory_DP_T_Customer' AND TABLE_NAME='DP_T_CustomerStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_CustomerStateHistory DROP CONSTRAINT FK_DP_T_CustomerStateHistory_DP_T_Customer
	END

	TRUNCATE TABLE DBO.DP_T_Customer

	TRUNCATE TABLE DBO.DP_PI_U_PositionPLActivity

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_PositionPLActivityTargetStateHistory_DP_T_PositionPLActivityTarget' AND TABLE_NAME='DP_T_PositionPLActivityTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_PositionPLActivityTargetStateHistory DROP CONSTRAINT FK_DP_T_PositionPLActivityTargetStateHistory_DP_T_PositionPLActivityTarget
	END

	TRUNCATE TABLE DBO.DP_T_PositionPLActivityTarget

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_PositionPLActivityStateHistory_DP_T_PositionActivity' AND TABLE_NAME='DP_T_PositionPLActivityStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_PositionPLActivityStateHistory DROP CONSTRAINT FK_DP_T_PositionPLActivityStateHistory_DP_T_PositionActivity
	END

	TRUNCATE TABLE DBO.DP_T_PositionPLActivity

	TRUNCATE TABLE DBO.DP_PI_U_AccumPerfHist   

	TRUNCATE TABLE DBO.DP_PI_U_Acgp

	TRUNCATE TABLE DBO.DP_PI_U_BnchmrkSet

	TRUNCATE TABLE DBO.DP_PI_U_BnchmrkSetMemb

	TRUNCATE TABLE DBO.DP_T_AccumPerfHist

	TRUNCATE TABLE DBO.DP_T_AccumPerfHistTarget

	TRUNCATE TABLE DBO.DP_T_Acgp

	TRUNCATE TABLE DBO.DP_T_AcgpTarget

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_BnchmrkSetStateHistory_DP_T_BnchmrkSet' AND TABLE_NAME='DP_T_BnchmrkSetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_BnchmrkSetStateHistory DROP CONSTRAINT FK_DP_T_BnchmrkSetStateHistory_DP_T_BnchmrkSet
	END

	TRUNCATE TABLE DBO.DP_T_BnchmrkSet

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_BnchmrkSetStateHistory_DP_T_BnchmrkSet' AND TABLE_NAME='DP_T_BnchmrkSetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_BnchmrkSetStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_BnchmrkSetStateHistory_DP_T_BnchmrkSet FOREIGN KEY(ActivityId) REFERENCES DP_T_BnchmrkSet(Id)
	END

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_BnchmrkSetMembStateHistory_DP_T_BnchmrkSetMemb' AND TABLE_NAME='DP_T_BnchmrkSetMembStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_BnchmrkSetMembStateHistory DROP CONSTRAINT FK_DP_T_BnchmrkSetMembStateHistory_DP_T_BnchmrkSetMemb
	END

	TRUNCATE TABLE DBO.DP_T_BnchmrkSetMemb

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_BnchmrkSetMembStateHistory_DP_T_BnchmrkSetMemb' AND TABLE_NAME='DP_T_BnchmrkSetMembStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_BnchmrkSetMembStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_BnchmrkSetMembStateHistory_DP_T_BnchmrkSetMemb FOREIGN KEY(ActivityId) REFERENCES DP_T_BnchmrkSetMemb(Id)
	END

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_BnchmrkSetMembTargetStateHistory_DP_T_BnchmrkSetMembTarget' AND TABLE_NAME='DP_T_BnchmrkSetMembTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_BnchmrkSetMembTargetStateHistory DROP CONSTRAINT FK_DP_T_BnchmrkSetMembTargetStateHistory_DP_T_BnchmrkSetMembTarget
	END

	TRUNCATE TABLE DBO.DP_T_BnchmrkSetMembTarget

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_BnchmrkSetMembTargetStateHistory_DP_T_BnchmrkSetMembTarget' AND TABLE_NAME='DP_T_BnchmrkSetMembTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_BnchmrkSetMembTargetStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_BnchmrkSetMembTargetStateHistory_DP_T_BnchmrkSetMembTarget FOREIGN KEY(ActivityTargetId) REFERENCES DP_T_BnchmrkSetMembTarget(Id)
	END

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_BnchmrkSetTargetStateHistory_DP_T_BnchmrkSetTarget' AND TABLE_NAME='DP_T_BnchmrkSetTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_BnchmrkSetTargetStateHistory DROP CONSTRAINT FK_DP_T_BnchmrkSetTargetStateHistory_DP_T_BnchmrkSetTarget
	END

	TRUNCATE TABLE DBO.DP_T_BnchmrkSetTarget

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_BnchmrkSetTargetStateHistory_DP_T_BnchmrkSetTarget' AND TABLE_NAME='DP_T_BnchmrkSetTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_BnchmrkSetTargetStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_BnchmrkSetTargetStateHistory_DP_T_BnchmrkSetTarget FOREIGN KEY(ActivityTargetId) REFERENCES DP_T_BnchmrkSetTarget(Id)
	END

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_IssueActivityTargetStateHistory_DP_T_IssueActivityTarget' AND TABLE_NAME='DP_T_IssueActivityTargetStateHistory')
	BEGIN
	ALTER TABLE DBO.DP_T_IssueActivityTargetStateHistory DROP CONSTRAINT FK_DP_T_IssueActivityTargetStateHistory_DP_T_IssueActivityTarget
	END

	TRUNCATE TABLE DBO.DP_T_IssueActivityTarget

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_IssueActivityTargetStateHistory_DP_T_IssueActivityTarget' AND TABLE_NAME='DP_T_IssueActivityTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_IssueActivityTargetStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_IssueActivityTargetStateHistory_DP_T_IssueActivityTarget FOREIGN KEY(ActivityTargetId) REFERENCES DP_T_IssueActivityTarget(Id)
	END

	
	TRUNCATE TABLE DBO.DP_PI_U_MD_IssueMaster

	
	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_MD_IssueMasterTargetStateHistory_DP_T_MD_IssueMasterTarget' AND TABLE_NAME='DP_T_MD_IssueMasterTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_MD_IssueMasterTargetStateHistory DROP CONSTRAINT FK_DP_T_MD_IssueMasterTargetStateHistory_DP_T_MD_IssueMasterTarget
	END 

	TRUNCATE TABLE DBO.DP_T_MD_IssueMasterTarget

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_MD_IssueMasterStateHistory_DP_T_MD_IssueMaster' AND TABLE_NAME='DP_T_MD_IssueMasterStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_MD_IssueMasterStateHistory DROP CONSTRAINT FK_DP_T_MD_IssueMasterStateHistory_DP_T_MD_IssueMaster
	END

	TRUNCATE TABLE DBO.DP_T_MD_IssueMaster

	TRUNCATE TABLE DBO.DP_PI_U_IssueActivity

	TRUNCATE TABLE DBO.DP_PI_U_AccountActivity

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_BatchInterfaceControlLog_DP_EventSetLog' AND TABLE_NAME='DP_BatchInterfaceControlLog')
	BEGIN
		ALTER TABLE DBO.DP_BatchInterfaceControlLog DROP CONSTRAINT FK_DP_BatchInterfaceControlLog_DP_EventSetLog
	END

	TRUNCATE TABLE DBO.DP_BatchInterfaceControlLog

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_BatchInterfaceControlLog_DP_EventSetLog' AND TABLE_NAME='DP_BatchInterfaceControlLog')
	BEGIN
		ALTER TABLE [dbo].[DP_BatchInterfaceControlLog]  WITH CHECK ADD  CONSTRAINT [FK_DP_BatchInterfaceControlLog_DP_EventSetLog] FOREIGN KEY([EventSetLogId])
		REFERENCES [dbo].[DP_EventSetLog] ([Id])
	END

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_EventProfileLog_DP_EventSetLog' AND TABLE_NAME='DP_EventProfileLog')
	BEGIN
		ALTER TABLE DBO.DP_EventProfileLog DROP CONSTRAINT FK_DP_EventProfileLog_DP_EventSetLog
	END

	--TRUNCATE TABLE DBO.DP_EventProfileLog

	--DELETE  DBO.DP_EventSetLog

	--TRUNCATE TABLE DBO.DP_Log

	--TRUNCATE TABLE DBO.DP_BatchTargetStateHistory

	--TRUNCATE TABLE DBO.DP_Eventset_Rpt

	--TRUNCATE TABLE DBO.DP_EventProfileAggregated_Rpt

	--Long foreign constrain
	--DELETE  DBO.DP_BatchTarget

	--TRUNCATE TABLE DBO.DP_BatchStateHistory

	--TRUNCATE TABLE DBO.DP_BatchLink

	--long foregin constrain
	--DELETE  DBO.DP_Batch

	TRUNCATE TABLE DBO.DP_PI_U_PositionActivity

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_PositionActivityStateHistory_DP_T_PositionActivity' AND TABLE_NAME='DP_T_PositionActivityStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_PositionActivityStateHistory DROP CONSTRAINT FK_DP_T_PositionActivityStateHistory_DP_T_PositionActivity
	END

	TRUNCATE TABLE DBO.DP_T_PositionActivity

	IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_PositionActivityTargetStateHistory_DP_T_PositionActivityTarget' AND TABLE_NAME='DP_T_PositionActivityTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_PositionActivityTargetStateHistory DROP CONSTRAINT FK_DP_T_PositionActivityTargetStateHistory_DP_T_PositionActivityTarget
	END

	TRUNCATE TABLE DBO.DP_T_PositionActivityTarget

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_IssueActivityStateHistory_DP_T_IssueActivity' AND TABLE_NAME='DP_T_IssueActivityStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_IssueActivityStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_IssueActivityStateHistory_DP_T_IssueActivity FOREIGN KEY(ActivityId) REFERENCES DP_T_IssueActivity(Id)
	END

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_AccountTotalsTargetStateHistory_DP_T_AccountTotalsTarget' AND TABLE_NAME='DP_T_AccountTotalsTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_AccountTotalsTargetStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_AccountTotalsTargetStateHistory_DP_T_AccountTotalsTarget FOREIGN KEY(ActivityTargetId) REFERENCES DP_T_AccountTotalsTarget(Id)
	END

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_AccountTotalsStateHistory_DP_T_AccountTotals' AND TABLE_NAME='DP_T_AccountTotalsStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_AccountTotalsStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_AccountTotalsStateHistory_DP_T_AccountTotals FOREIGN KEY(ActivityId) REFERENCES DP_T_AccountTotals(Id)
	END

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_AccountActivityStateHistory_DP_T_AccountActivity' AND TABLE_NAME='DP_T_AccountActivityStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_AccountActivityStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_AccountActivityStateHistory_DP_T_AccountActivity FOREIGN KEY(ActivityId) REFERENCES DP_T_AccountActivity(Id)
	END

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_CustomerTargetStateHistory_DP_T_CustomerTarget' AND TABLE_NAME='DP_T_CustomerTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_CustomerTargetStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_CustomerTargetStateHistory_DP_T_CustomerTarget FOREIGN KEY(ActivityTargetId) REFERENCES DP_T_CustomerTarget(Id)
	END

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_CustomerStateHistory_DP_T_Customer' AND TABLE_NAME='DP_T_CustomerStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_CustomerStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_CustomerStateHistory_DP_T_Customer FOREIGN KEY(ActivityId) REFERENCES DP_T_Customer(Id)
	END

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_PositionPLActivityTargetStateHistory_DP_T_PositionPLActivityTarget' AND TABLE_NAME='DP_T_PositionPLActivityTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_PositionPLActivityTargetStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_PositionPLActivityTargetStateHistory_DP_T_PositionPLActivityTarget FOREIGN KEY(ActivityTargetId) REFERENCES DP_T_PositionPLActivityTarget(Id)
	END

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_PositionPLActivityStateHistory_DP_T_PositionActivity' AND TABLE_NAME='DP_T_PositionPLActivityStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_PositionPLActivityStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_PositionPLActivityStateHistory_DP_T_PositionActivity FOREIGN KEY(ActivityId) REFERENCES DP_T_PositionPLActivity(Id)
	END

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_PositionActivityTargetStateHistory_DP_T_PositionActivityTarget' AND TABLE_NAME='DP_T_PositionActivityTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_PositionActivityTargetStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_PositionActivityTargetStateHistory_DP_T_PositionActivityTarget FOREIGN KEY(ActivityTargetId) REFERENCES DP_T_PositionActivityTarget(Id)
	END

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_PositionActivityStateHistory_DP_T_PositionActivity' AND TABLE_NAME='DP_T_PositionActivityStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_PositionActivityStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_PositionActivityStateHistory_DP_T_PositionActivity FOREIGN KEY(ActivityId) REFERENCES DP_T_PositionActivity(Id)
	END

	--SEI SPECIFIC TABLE

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_MD_IssueMasterTargetStateHistory_DP_T_MD_IssueMasterTarget' AND TABLE_NAME='DP_T_MD_IssueMasterTargetStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_MD_IssueMasterTargetStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_MD_IssueMasterTargetStateHistory_DP_T_MD_IssueMasterTarget FOREIGN KEY(ActivityTargetId) REFERENCES DP_T_MD_IssueMasterTarget(Id)
	END

	IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='FK_DP_T_MD_IssueMasterStateHistory_DP_T_MD_IssueMaster' AND TABLE_NAME='DP_T_MD_IssueMasterStateHistory')
	BEGIN
		ALTER TABLE DBO.DP_T_MD_IssueMasterStateHistory WITH NOCHECK ADD CONSTRAINT FK_DP_T_MD_IssueMasterStateHistory_DP_T_MD_IssueMaster FOREIGN KEY(ActivityId) REFERENCES DP_T_MD_IssueMaster(Id)
	END
	
	SELECT @ENDINGFKEYCOUNT = COUNT(1) FROM SYS.FOREIGN_KEYS
	
	SELECT @FKMESSAGE = @FKMESSAGE + ' AND ENDING COUNT OF THE FOREIGN KEYS ARE '+ CAST(@BEGININGFKEYCOUNT AS VARCHAR(20));
	
	IF((@BEGININGFKEYCOUNT-@ENDINGFKEYCOUNT) <> 0)
		RAISERROR(@FKMESSAGE, 16,1) ;
		
END TRY
BEGIN CATCH	
	DECLARE @Error INTEGER;
	SET @Error = ERROR_NUMBER() ;	
	 SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage; 
        
        RAISERROR('Error encoutered in Truncating table', 16,1) ;
END CATCH;

SET NOCOUNT OFF 

GO

