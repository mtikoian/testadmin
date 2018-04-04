
/****** Object:  View [dbo].[Monitor_DBMSSQLLogDetails]    Script Date: 06/09/2012 22:19:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[Monitor_DBMSSQLLogDetails]
AS

SELECT		A.Id AS [DBMS_Id]
			,A.Name AS [SQLServer]
			,A.Instance
			,A.IPAddress
			,A.Port
			,A.Name +			
					CASE 
						WHEN [Instance] IS NULL THEN '' 
						WHEN [Instance] = 'Default' THEN ''
						WHEN [Instance] = 'MSSQLServer' THEN ''
						ELSE '\' + [Instance] 
					END + CASE WHEN LTRIM(ISNULL(A.Port, '')) = '' 
							THEN ''
							ELSE ',' + A.Port
						 END AS [SQLServerConnection]
			,A.IPAddress +
					CASE 
						WHEN [Instance] IS NULL THEN '' 
						WHEN [Instance] = 'Default' THEN ''
						WHEN [Instance] = 'MSSQLServer' THEN ''
						ELSE '\' + [Instance] 
					END + CASE WHEN LTRIM(ISNULL(A.Port, '')) = '' 
							THEN ''
							ELSE ',' + A.Port
						 END AS [SQLServerConnectionByIP] 			
			,A.SQLVersion
			,A.SQLEdition
			,A.Environment
			,D.Name
			,C.Status       AS [Status]
			,C.Description  AS [Description]
			,C.CreateDate   AS [DetailDate]
FROM        dbo.DBMS A
                JOIN dbo.MonitorDBMSLog B ON A.Id = B.DBMS_Id
                JOIN dbo.MonitorDBMSLogDetail C ON B.Id = C.MonitorDBMSLog_Id
                JOIN dbo.Monitor D ON B.Monitor_Id = D.Id
WHERE       A.Type = 'SQL Server'
  AND       A.CollectInfo = 1
  AND       A.Disable = 0

GO

/****** Object:  View [dbo].[Monitor_DBMSSQLLogInfo]    Script Date: 06/09/2012 22:19:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[Monitor_DBMSSQLLogInfo]
AS

SELECT		A.Id AS [DBMS_Id]
			,A.Name AS [SQLServer]
			,A.Instance
			,A.IPAddress
			,A.Port
			,A.Name +			
					CASE 
						WHEN [Instance] IS NULL THEN '' 
						WHEN [Instance] = 'Default' THEN ''
						WHEN [Instance] = 'MSSQLServer' THEN ''
						ELSE '\' + [Instance] 
					END + CASE WHEN LTRIM(ISNULL(A.Port, '')) = '' 
							THEN ''
							ELSE ',' + A.Port
						 END AS [SQLServerConnection]
			,A.IPAddress +
					CASE 
						WHEN [Instance] IS NULL THEN '' 
						WHEN [Instance] = 'Default' THEN ''
						WHEN [Instance] = 'MSSQLServer' THEN ''
						ELSE '\' + [Instance] 
					END + CASE WHEN LTRIM(ISNULL(A.Port, '')) = '' 
							THEN ''
							ELSE ',' + A.Port
						 END AS [SQLServerConnectionByIP] 			
			,A.SQLVersion
			,A.SQLEdition
			,A.Environment
			,D.Name
			,D.Duration
			,D.AlertThreshold
			,D.AlertThresholdDelay
			,B.LastSuccess
			,B.LastFailure
			,B.ThresholdDate
			,B.ThresholdCount
			,B.IgnoreAlertUntil
			,B.RaiseAlert
FROM        dbo.DBMS A
                JOIN dbo.MonitorDBMSLog B ON A.Id = B.DBMS_Id
                JOIN dbo.Monitor D ON B.Monitor_Id = D.Id
WHERE       A.Type = 'SQL Server'
  AND       A.CollectInfo = 1
  AND       A.Disable = 0






GO

/****** Object:  View [dbo].[Monitor_ServerLogDetails]    Script Date: 06/09/2012 22:19:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[Monitor_ServerLogDetails]
AS

SELECT		A.Id AS [Server_Id]
			,A.Name AS [SQLServer]
			,A.IPAddress
			,D.Name
			,C.Status       AS [Status]
			,C.Description  AS [Description]
			,C.CreateDate   AS [DetailDate]
FROM        dbo.Server A
                JOIN dbo.MonitorServerLog B ON A.Id = B.Server_Id
                JOIN dbo.MonitorServerLogDetail C ON B.Id = C.MonitorServerLog_Id
                JOIN dbo.Monitor D ON B.Monitor_Id = D.Id
WHERE       A.CollectInfo = 1
  AND       A.Disable = 0


GO

/****** Object:  View [dbo].[Monitor_ServerLogInfo]    Script Date: 06/09/2012 22:19:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Monitor_ServerLogInfo]
AS

SELECT		A.Id AS [Server_Id]
			,A.Name AS [SQLServer]
			,A.IPAddress
			,D.Name
			,D.Duration
			,D.AlertThreshold
			,D.AlertThresholdDelay
			,B.LastSuccess
			,B.LastFailure
			,B.ThresholdDate
			,B.ThresholdCount
			,B.IgnoreAlertUntil
			,B.RaiseAlert
FROM        dbo.Server A
                JOIN dbo.MonitorServerLog B ON A.Id = B.Server_Id
                JOIN dbo.Monitor D ON B.Monitor_Id = D.Id
WHERE       A.CollectInfo = 1
  AND       A.Disable = 0

GO

/****** Object:  View [dbo].[Servers_WithDBMSNotIdentified]    Script Date: 06/09/2012 22:19:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Servers_WithDBMSNotIdentified]
AS

SELECT		A.Id AS [Server_Id]
			,A.Name AS [Server]
			,A.HardwareType
			,A.PhysicalCPU
			,A.PhysicalMemory
			,A.WindowsVersion
			,A.Platform
			,A.CollectInfo 
			,A.Disable
FROM		dbo.Server A
				LEFT JOIN dbo.ServerDBMS B ON A.Id = B.Server_Id
WHERE       B.DBMS_Id IS NULL

GO

/****** Object:  View [dbo].[ServerScheduleTaskInfo]    Script Date: 06/09/2012 22:19:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[ServerScheduleTaskInfo]
AS

SELECT		S.Id AS [Server_Id]
            ,S.Name AS [Server]
            ,S.IPAddress
			,S.[Domain]
			,T.[TaskName]			
			,CASE 
				WHEN ISDATE(T.NextRunTime) = 0 THEN NULL
				ELSE CAST(T.NextRunTime AS datetime)
			END AS [NextRunDate]			
			,T.[Status]
			,T.[LogonMode]
			,CASE 
				WHEN ISDATE(T.LastRunTime) = 0 THEN NULL
				ELSE CAST(T.LastRunTime AS datetime)
			END AS [LastRunDate]			
			,T.[LastResults]
			,T.[Creator]
			,T.[TaskToRun]
			,T.[StartIn]
			,T.[Comment]
			,T.[ScheduleTaskState]
			,T.[IdleTime]
			,T.[PowerManagement]
			,T.[RunAsUser]
			,T.[DeleteTaskIfNotRescheduled]
			,T.[StopTaskIfRunsXHoursAndXMins]
			,T.[Schedule]
			,T.[ScheduleType]
			,T.[StartTime]
			,T.[StartDate]
			,T.[EndDate]
			,T.[Days]
			,T.[Months]
			,T.[RepeatEvery]
			,T.[RepeatUntilTime]
			,T.[RepeatUntilDuration]
			,T.[RepeatStopIfStillRunning]
			,T.[CreateDate]
FROM		[dbo].[Server]					S WITH (NOLOCK)                
				JOIN [ScheduledTaskInfo]	T WITH (NOLOCK)	ON S.Id = T.Server_Id
WHERE		S.[Disable] = 0


GO

/****** Object:  View [dbo].[SQLAbleToCollectInfoOn]    Script Date: 06/09/2012 22:19:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[SQLAbleToCollectInfoOn]
AS

SELECT		[Id]
			,[Name]
			,[Instance]
            ,[Name] + 
                CASE 
                    WHEN [Instance] IS NULL THEN '' 
                    WHEN [Instance] = 'Default' THEN ''
                    WHEN [Instance] = 'MSSQLServer' THEN ''
                    ELSE '\' + [Instance] 
                END										AS [SQLServer]			
			,[IPAddress]
			,[Port]
			,[Domain]
			,[HardwareType]
			,[Environment]
			,[ServerType]
			,[SQLVersion]
			,[SQLEdition]
            ,[Name] + 
                CASE 					
                    WHEN [Instance] IS NULL THEN '' 
                    WHEN [Instance] = 'Default' THEN ''
                    WHEN [Instance] = 'MSSQLServer' THEN ''
                    ELSE '\' + [Instance] 
                 END +
	                    CASE WHEN [Port] IS NULL
		                    THEN ''
		                    ELSE ',' + CAST([Port] AS varchar(10))
	                    END	 AS [SQLConnection]			            
            ,[IPAddress] + 
                    CASE 					
                        WHEN [Instance] IS NULL THEN '' 
                        WHEN [Instance] = 'Default' THEN ''
                        WHEN [Instance] = 'MSSQLServer' THEN ''
                        ELSE '\' + [Instance] 
                     END +
	                        CASE WHEN [Port] IS NULL
		                        THEN ''
		                        ELSE ',' + CAST([Port] AS varchar(10))
	                        END	 AS [SQLConnectionViaIP]			
            ,[IPAddress] + 
                    CASE 					
                        WHEN [Instance] IS NULL THEN '' 
                        WHEN [Instance] = 'Default' THEN ''
                        WHEN [Instance] = 'MSSQLServer' THEN ''
                        ELSE '\' + [Instance] 
                     END +
	                        CASE WHEN [Port] IS NULL
		                        THEN ''
		                        ELSE ',' + CAST([Port] AS varchar(10))
	                        END	 AS [DataCollectorConnectString]			
FROM		DBMS
WHERE		CollectInfo = 1
  AND		Disable = 0
  AND		Type = 'SQL Server'



GO

/****** Object:  View [dbo].[SQLBackupSummary]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW  [dbo].[SQLBackupSummary]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,B.DbName
			,B.Type
			,B.LastBackupStartDate
			,B.LastBackupFinishDate
			,B.DaysOld
			,B.BackupUser
			,B.BackupSetName
			,B.BackupFilename
			,B.LastBackupSize AS LastBackupSize_Bytes			
			,CAST(B.LastBackupSize/1024.0 AS NUMERIC(20, 5)) AS LastBackupSize_KB
			,CAST(B.LastBackupSize/(1024.0 * 1024) AS NUMERIC(20, 5)) AS LastBackupSize_MB
			,CAST(B.LastBackupSize/(1024.0 * 1024 * 1024) AS NUMERIC(20, 5)) AS LastBackupSize_GB
			,B.LastCompressedBackupSize AS LastCompressBackupSize_Bytes			
			,CAST(B.LastCompressedBackupSize/1024.0 AS NUMERIC(20, 5)) AS LastCompressBackupSize_KB
			,CAST(B.LastCompressedBackupSize/(1024.0 * 1024) AS NUMERIC(20, 5)) AS LastCompressBackupSize_MB
			,CAST(B.LastCompressedBackupSize/(1024.0 * 1024 * 1024) AS NUMERIC(20, 5)) AS LastCompressBackupSize_GB
			,CASE 
				WHEN ISNULL(B.LastCompressedBackupSize, 0) = 0 THEN 0
				WHEN (B.LastCompressedBackupSize / B.LastBackupSize) = 1 THEN 0
				ELSE 100 - ((B.LastCompressedBackupSize / B.LastBackupSize) * 100)
			 END AS CompressionRatio
			,CASE 
				WHEN ISNULL(B.LastCompressedBackupSize, 0) = 0 THEN 0
				WHEN B.LastCompressedBackupSize / B.LastBackupSize = 1 THEN 0 
				ELSE 1
			 END AS Compressed
			,CAST(B.LastBackupSize / CASE WHEN DATEDIFF(ss, B.LastBackupStartDate, B.LastBackupFinishDate) = 0 
										THEN 1
										ELSE  DATEDIFF(ss, B.LastBackupStartDate, B.LastBackupFinishDate)
								END / (1024 * 1024) AS NUMERIC(10, 5)) AS Speed_MB_Per_Sec
			,B.TodaysBackupCount
			,B.YesterdaysBackupCount
			,B.TwoDaysAgoBackupCount
			,B.ThreeDaysAgoBackupCount
			,B.CreateDate
			,DATEDIFF(d, B.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN B.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[DBMS]					        S WITH (NOLOCK)
				LEFT JOIN [BackupSummary]	B WITH (NOLOCK)	ON S.Id = B.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'








GO

/****** Object:  View [dbo].[SQLDatabaseMirroringInfo]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW  [dbo].[SQLDatabaseMirroringInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,B.[DatabaseName]
			,B.[Role]
			,B.[State]
			,B.[Sequence]
			,B.[SafteyLevel]
			,B.[PartnerName]
			,B.[PartnerInstance]
			,B.[PartnerWitness]
			,B.[WitnessState]
			,B.[ConnectionTimeout]
			,B.[RedoQueueType]
			,B.[CreateDate]			
			,DATEDIFF(d, B.CreateDate, GETDATE()) AS [Info_DaysOld]
FROM		[dbo].[DBMS]					            S WITH (NOLOCK)
				JOIN [dbo].[DatabaseMirroringInfo]	B WITH (NOLOCK)	ON S.Id = B.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'



GO

/****** Object:  View [dbo].[SQLDatabaseOptionsInfo]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[SQLDatabaseOptionsInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,D.[Name] AS [DbName]
			,D.[DbCreateDate]
			,D.[Owner]
			,D.[Collation]
			,D.[CompatibilityLevel]
			,D.[RecoveryModel]
			,D.[AutoClose]
			,D.[AutoCreateStatistics]
			,D.[AutoShrink]
			,D.[AutoUpdateStatistics]
			,D.[CloseCursorOnCommitEnabled]
			,D.[ANSINullDefault]
			,D.[ANSINullsEnabled]
			,D.[ANSIPaddingEnabled]
			,D.[ANSIWarningsEnabled]
			,D.[ArithmeticAbortEnabled]
			,D.[ConcatenateNullYieldsNull]
			,D.[CrossDbOwnership]
			,D.[NumericRoundAbort]
			,D.[QuotedIdentifierEnabled]
			,D.[RecursiveTriggersEnabled]
			,D.[FullTextEnabled]
			,D.[Trustworthy]
			,D.[BrokerEnabled]
			,D.[ReadOnly]
			,D.[RestrictUserAccess]
			,D.[Status]
			,D.[CreateDate]
			,DATEDIFF(d, D.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN D.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]		                        S WITH (NOLOCK)
				LEFT JOIN [dbo].[DatabaseOptionsInfo]	D WITH (NOLOCK)	ON S.Id = D.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'






GO

/****** Object:  View [dbo].[SQLDatabaseSizeInfo]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[SQLDatabaseSizeInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
            ,D.DbName
            ,D.Type
            ,D.Filegroup
            ,D.LogicalName
            ,D.FileSize_MB
            ,D.UsedSpace_MB
            ,D.UnusedSpace_MB
            ,D.MaxSize_MB
            ,D.Growth
            ,D.GrowthType
            ,D.PhysicalName
            ,D.CreateDate
			,DATEDIFF(d, D.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN D.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM        dbo.DBMS                            AS S WITH (NOLOCK)
                LEFT JOIN dbo.DatabaseSizeInfo  AS D WITH (NOLOCK) ON S.Id = D.DBMS_Id
WHERE     (S.Disable = 0)
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'








GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "S"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 20
         End
         Begin Table = "D"
            Begin Extent = 
               Top = 6
               Left = 282
               Bottom = 121
               Right = 448
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SQLDatabaseSizeInfo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SQLDatabaseSizeInfo'
GO

/****** Object:  View [dbo].[SQLDatabaseSpaceSummary]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[SQLDatabaseSpaceSummary] 
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,D.[DbName]
			,D.[Type]
			,(SUM(D.[FileSize_MB])/1024) AS TotalDBFileSize_GB
			,(SUM(D.[UsedSpace_MB])/1024) AS TotalDBUsedSpace_GB
			,(SUM(D.[UnusedSpace_MB])/1024) AS TotalDBUnusedSpace_GB
			,CASE WHEN D.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]				        S WITH (NOLOCK)
				LEFT JOIN [DatabaseSizeInfo]	D WITH (NOLOCK)	ON S.Id = D.DBMS_Id
WHERE		S.Disable = 0
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'
GROUP BY	S.Id 
            ,S.Name
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,D.[DbName]
			,D.[Type]
			,CASE WHEN D.DBMS_Id IS NULL THEN 0 ELSE 1 END 







GO

/****** Object:  View [dbo].[SQLDBMSConfigurationInfo]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[SQLDBMSConfigurationInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,S.[PhysicalCPU]
			,S.[LogicalCPU]
			,S.[PhysicalMemory]
			,D.[ConfigId]
			,D.[Name] AS [ConfigName]
			,D.[Description] 
			,D.Value
			,D.ValueInUse
			,D.[CreateDate]
			,DATEDIFF(d, D.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN D.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]		                        S WITH (NOLOCK)
				LEFT JOIN [dbo].[DBMSConfigurationInfo]	D WITH (NOLOCK)	ON S.Id = D.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'








GO

/****** Object:  View [dbo].[SQLDriveSpaceInfo]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [dbo].[SQLDriveSpaceInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,D.[DriveLetter]
			,D.[TotalSpace]
			,D.[FreeSpace]
			,D.[Notes]
			,D.[CreateDate]
			,DATEDIFF(d, D.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN D.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]					    S WITH (NOLOCK)	
				LEFT JOIN [DriveSpaceInfo]		D WITH (NOLOCK)	ON S.Id = D.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.[CollectInfo] = 1
  AND       S.[Type] = 'SQL Server'











GO

/****** Object:  View [dbo].[SQLGuardiumAuditReport]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[SQLGuardiumAuditReport]
AS

SELECT		A.Id AS [DBMS_Id]
            ,A.Name AS SQLServer
			,A.IPAddress
            ,A.Instance
            ,A.Port
            ,A.SQLVersion
			,A.SQLEdition
			,A.[Domain]
			,A.[Environment]
			,B.TestId
			,B.TestDescription
			,B.DbName
			,B.Description
			,B.FixScript
			,B.RollbackScript
			,B.CreateDate
			,DATEDIFF(d, B.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN B.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		dbo.DBMS	                            A WITH (NOLOCK)
				LEFT JOIN dbo.GuardiumAuditReport   B WITH (NOLOCK) ON A.Id = B.DBMS_Id
WHERE		A.[Disable] = 0
  AND       A.[CollectInfo] = 1
  AND       A.[Type] = 'SQL Server'










GO

/****** Object:  View [dbo].[SQLJobScheduleInfo]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[SQLJobScheduleInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
            ,J.JobName
            ,J.JobOwner
            ,J.ScheduleName
            ,J.ScheduleInfo
            ,J.ScheduleType
            ,J.StartDate
            ,J.StartTime
            ,J.EndDate
            ,J.EndTime
            ,J.Frequency
            ,J.Day
            ,J.DayOfMonth
            ,J.Every
            ,J.DailyInterval
            ,J.DailyIntervalType
            ,J.Sunday
            ,J.Monday
            ,J.Tuesday
            ,J.Wednesday
            ,J.Thursday
            ,J.Friday
            ,J.Saturday
            ,J.CreateDate
			,DATEDIFF(d, J.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN J.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM        dbo.DBMS                            AS S WITH (NOLOCK) 
                LEFT JOIN dbo.JobScheduleInfo   AS J WITH (NOLOCK) ON S.Id = J.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.[CollectInfo] = 1
  AND       S.[Type] = 'SQL Server'









GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[35] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "S"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "J"
            Begin Extent = 
               Top = 6
               Left = 282
               Bottom = 121
               Right = 448
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SQLJobScheduleInfo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SQLJobScheduleInfo'
GO

/****** Object:  View [dbo].[SQLJobSummary]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[SQLJobSummary]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,J.[Name]
			,J.[Enabled]
			,J.[Running]
			,J.[RunningDuration_Sec]
			,J.[LastFailureDate]
			,J.[LastFailureDuration_Sec]
			,J.[LastSuccessDate]
			,J.[LastSuccessDuration_Sec]
			,J.[NextRunDate]
			,J.[TodayErrorCount]
			,J.[TodaySuccessCount]
			,J.[YesterdayErrorCount]
			,J.[YesterdaySuccessCount]
			,J.[TwoDaysAgoErrorCount]
			,J.[TwoDaysAgoSuccessCount]
			,J.[ThreeDaysAgoErrorCount]
			,J.[ThreeDaysAgoSuccessCount]	
			,J.[CreateDate]	 
			,DATEDIFF(d, J.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN J.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]			    S WITH (NOLOCK)
				LEFT JOIN [JobSummary]	J WITH (NOLOCK)	ON S.Id = J.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.[CollectInfo] = 1
  AND       S.[Type] = 'SQL Server'





GO

/****** Object:  View [dbo].[SQLLinkedServerInfo]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[SQLLinkedServerInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
            ,L.LinkedServer
            ,L.LocalLogin
            ,L.LoginType
            ,L.Impersonate
            ,L.RemoteUser
            ,L.LoginNotDefine
            ,L.Provider
            ,L.DataSource
            ,L.Location
            ,L.ProviderString
            ,L.Catalog
            ,L.CollationCompatible
            ,L.DataAccess
            ,L.Rpc
            ,L.RpcOut
            ,L.UseRemoteCollation
            ,L.CollationName
            ,L.ConnectionTimeout
            ,L.QueryTimeout 
            ,L.CreateDate
			,DATEDIFF(d, L.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN L.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM        dbo.DBMS                        AS S WITH (NOLOCK) 
                LEFT JOIN dbo.LinkedServers AS L WITH (NOLOCK) ON S.Id = L.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.[CollectInfo] = 1
  AND       S.[Type] = 'SQL Server'










GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "S"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "L"
            Begin Extent = 
               Top = 6
               Left = 282
               Bottom = 121
               Right = 459
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SQLLinkedServerInfo'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'SQLLinkedServerInfo'
GO

/****** Object:  View [dbo].[SQLLogShippingInfo]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW  [dbo].[SQLLogShippingInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,B.[Source]
			,B.[SourceDBExist]
			,B.[PrimaryServer]
			,B.[PrimaryDatabase]
			,B.[SecondaryServer]
			,B.[SecondaryDatabase]
			,B.[MonitorServer]
			,B.[BackupDirectory]
			,B.[BackupShare]
			,B.[LastBackupFile]
			,B.[LastBackupDate]
			,B.[LastCopiedFile]
			,B.[LastCopiedDate]
			,B.[LastRestoredFile]
			,B.[LastRestoredDate]
			,B.[BackupRetentionPeriod]
			,B.[SQLTransBackupJob]
			,B.[SQLCopyJob]
			,B.[SQLRestoreJob]
			,B.[CreateDate]
			,DATEDIFF(d, B.CreateDate, GETDATE()) AS [Info_DaysOld]
FROM		[dbo].[DBMS]					        S WITH (NOLOCK)
				JOIN [dbo].[LogShippingInfo]	B WITH (NOLOCK)	ON S.Id = B.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'



GO

/****** Object:  View [dbo].[SQLReplicationInfo]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW  [dbo].[SQLReplicationInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,B.[PublicationServer]
			,B.[PublicationDb]
			,B.[Publication]
			,B.[PublicationArticle]
			,B.[DestinationObject]
			,B.[SubscriptionServer]
			,B.[SubscriberDb]
			,B.[SubscriptionType]
			,B.[SubscriberLogin]
			,B.[SubscriberSecurityMode]
			,B.[DistributionAgentSQLJob]
			,B.[CreateDate]			
			,DATEDIFF(d, B.CreateDate, GETDATE()) AS [Info_DaysOld]
FROM		[dbo].[DBMS]					        S WITH (NOLOCK)
				JOIN [dbo].[ReplicationInfo]	B WITH (NOLOCK)	ON S.Id = B.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.CollectInfo = 1
  AND       S.Type = 'SQL Server'












GO

/****** Object:  View [dbo].[SQLSecuritySummary]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[SQLSecuritySummary]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,T.[SecurityInfo]	AS [SecurityPrincipal]
			,T.[SecurityType]	AS [Type]
			,T.[DatabaseName]	
			,T.[ClassName]
			,T.[ObjectName]
			,T.[ObjectType]
			,T.[ColumnName]
			,T.[Permission]
			,T.[State]
			,T.[CreateDate]			
			,DATEDIFF(d, T.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN T.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]				    S WITH (NOLOCK)
				LEFT JOIN [SecuritySummary]	T WITH (NOLOCK)	ON S.Id = T.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.[CollectInfo] = 1
  AND       S.[Type] = 'SQL Server'









GO

/****** Object:  View [dbo].[SQLServerDBMSInfo]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [dbo].[SQLServerDBMSInfo]
AS

SELECT      [Id]
            ,[Name]
            ,[Instance]
            ,[IPAddress]
            ,[Port]
			,[Name] +			
					CASE 
						WHEN [Instance] IS NULL THEN '' 
						WHEN [Instance] = 'Default' THEN ''
						WHEN [Instance] = 'MSSQLServer' THEN ''
						ELSE '\' + [Instance] 
					END + CASE WHEN LTRIM(ISNULL(Port, '')) = '' 
							THEN ''
							ELSE ',' + Port
						 END AS [SQLServerConnection]
			,[IPAddress] +
					CASE 
						WHEN [Instance] IS NULL THEN '' 
						WHEN [Instance] = 'Default' THEN ''
						WHEN [Instance] = 'MSSQLServer' THEN ''
						ELSE '\' + [Instance] 
					END + CASE WHEN LTRIM(ISNULL(Port, '')) = '' 
							THEN ''
							ELSE ',' + Port
						 END AS [SQLServerConnectionByIP] 			
            ,[Domain]
            ,[Environment]
            ,[HardwareType]
            ,[ServerType]
            ,[NamedPipesEnabled]
            ,[TcpIpEnabled]
            ,[DynamicPort]
            ,[StaticPort]
            ,[ForceProtocolEncryption]
            ,[SQLVersion]
            ,[SQLEdition]
            ,[SQLCollation]
            ,[SQLSortOrder]
            ,[RunningOnServer]
            ,[WindowsVersion]
            ,[Platform]
            ,[PhysicalCPU]
            ,[LogicalCPU]
            ,[PhysicalMemory]
            ,[DotNetVersion]
            ,[DBMailProfile]
            ,[AgentMailProfile]
            ,[LoginAuditLevel]
            ,[ServerNameProperty]
            ,[DateInstalled]
            ,[DateRemoved]
            ,[ApproxStartDate]
            ,[ProgramDirectory]
            ,[Path]
            ,[BinaryDirectory]
            ,[DefaultDataDirectory]
            ,[DefaultLogDirectory]
            ,[AbleToEmail]
            ,[SupportedBy]
            ,[TopologyActive]
            ,[TopologyKey]
            ,[CollectInfo]
            ,[Disable]
            ,[Notes]
            ,[CreatedBy]
            ,[CreateDate]
            ,[LastUpdate]           
			,DATEDIFF(d, [LastUpdate], GETDATE()) AS [Info_DaysOld]
FROM        [dbo].[DBMS]
WHERE       [Type] = 'SQL Server'








GO

/****** Object:  View [dbo].[SQLServerServers]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SQLServerServers]
AS

SELECT		A.Id AS [DBMS_Id]
			,A.Name AS [SQLServer]
			,A.Instance
			,A.IPAddress 
			,A.Port
			,A.SQLVersion
			,A.SQLEdition
			,A.Domain
			,A.Environment
			,A.HardwareType			
			,A.ServerType
			,A.CollectInfo AS [SQLCollectInfo]
			,A.Disable AS [SQLDisable]
			,C.Id AS [Server_Id]
			,C.Name AS [Server]
			,C.IPAddress AS [ServerIP]
			,C.Location
			,C.Address
			,C.City
			,C.State
			,C.Floor
			,C.Grid
			,C.Manufactured
			,C.Model
			,C.PhysicalCPU
			,C.LogicalCPU
			,C.PhysicalMemory
			,C.WindowsVersion
			,C.Platform
			,C.CollectInfo AS [ServerCollectInfo]
			,C.Disable AS ServerDisable
FROM		dbo.DBMS A
				LEFT JOIN dbo.ServerDBMS B ON A.Id = B.DBMS_Id
				LEFT JOIN dbo.Server C ON B.Server_Id = C.Id
WHERE       A.Type = 'SQL Server'

GO

/****** Object:  View [dbo].[SQLServiceBrokerServicesInQueue]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[SQLServiceBrokerServicesInQueue]
AS

-- SQL AGENT 
SELECT      'SQL Agent Running' AS [Service]
            ,COUNT(*)           AS [InQueue]
FROM        WDBSDataCollectorTargetMonitorDBMSSQLAgentRunningQueue
UNION ALL
-- SQL CONNECTION
SELECT      'SQL Connection'
            ,COUNT(*)
FROM        WDBSDataCollectorTargetMonitorDBMSSQLConnectionQueue
UNION ALL
-- SERVER PINGS
SELECT      'Server Pings'
            ,COUNT(*)
FROM        WDBSDataCollectorTargetMonitorServerPingQueue
UNION ALL                     
-- BACKUP SUMMARY
SELECT      'Backup Summary'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLBackupSummaryQueue
UNION ALL
-- DATABASE MIRRORING
SELECT      'Database Mirroring'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLDatabaseMirroringInfoQueue
UNION ALL
-- DATABASE OPTIONS
SELECT      'Database Options'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLDatabaseOptionsInfoQueue
UNION ALL
-- DATABASE SIZE
SELECT      'Database Size'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLDatabaseSizeInfoQueue
UNION ALL
-- DBMS
SELECT      'DBMS'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLDBMSInfoQueue
UNION ALL
-- DBMS CONFIGURATION
SELECT      'DBMS Configuration'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLDBMSConfigurationInfoQueue
UNION ALL
-- DRIVE SPACE
SELECT      'Drive Space'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLDriveInfoQueue
UNION ALL
-- GUARDIUM AUDIT REPORT
SELECT      'Guardium Audit Report'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLGuardiumAuditReportQueue
UNION ALL
-- JOB SCHEDULE INFO
SELECT      'Job Schedule'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLJobScheduleInfoQueue
UNION ALL
-- JOB SUMMARY
SELECT      'Job Summary'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLJobSummaryQueue
UNION ALL
-- LINKED SERVERS
SELECT      'Linked Servers'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLLinkedServerInfoQueue
UNION ALL
-- LOG SHIPPING
SELECT      'Log Shipping'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLLogShippingInfoQueue
UNION ALL
-- REPLICATION INFO
SELECT      'Replication Info'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLReplicationInfoQueue
UNION ALL
-- SECURITY SUMMARY
SELECT      'Security Summary'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLSecuritySummaryQueue
UNION ALL
-- SERVICES
SELECT      'Services'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLServicesInfoQueue
UNION ALL
-- TSM BACKUP SUMMARY
SELECT      'TSM Backup'
            ,COUNT(*) 
FROM        WDBSDataCollectorTargetSQLTSMBackupSummaryQueue

GO

/****** Object:  View [dbo].[SQLServicesInfo]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[SQLServicesInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,B.[Name]				AS [ServiceName]
			,B.[DisplayName]		AS [DisplayName]
			,B.[BinaryPath]
			,B.[ServiceAccount]
			,B.[StartupType]
			,B.[Status]
			,B.[CreateDate]
			,DATEDIFF(d, B.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN B.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]					    S WITH (NOLOCK)
				LEFT JOIN [dbo].[Services]		B WITH (NOLOCK)	ON S.Id = B.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.[CollectInfo] = 1
  AND       S.[Type] = 'SQL Server'






GO

/****** Object:  View [dbo].[SQLTSMBackupSummaryInfo]    Script Date: 06/09/2012 22:20:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW  [dbo].[SQLTSMBackupSummaryInfo]
AS

SELECT		S.Id AS [DBMS_Id]
            ,S.Name AS SQLServer
			,S.IPAddress
            ,S.Instance
            ,S.Port
            ,S.SQLVersion
			,S.SQLEdition
			,S.[Domain]
			,S.[Environment]
			,B.[LogFile]
			,B.[ScheduleName]
			,B.[ScheduleDate]
			,B.[StartDate]
			,B.[EndDate]
			,B.[BackupPaths]
			,B.[ObjectsInspected]
			,B.[ObjectsAssigned]
			,B.[ObjectsBackedUp]
			,B.[ObjectsUpdated]
			,B.[ObjectsRebound]
			,B.[ObjectsDeleted]
			,B.[ObjectsExpired]
			,B.[ObjectsFailed]
			,B.[SubfileObjects]
			,B.[BytesInspected]
			,B.[BytesTransferred]
			,B.[DataTransferTime]
			,B.[DataTransferRate]
			,B.[AggDataTransferRate]
			,B.[CompressPercentage]
			,B.[DataReductionRatio]
			,B.[SubfileObjectsReduceBy]
			,B.[ElapseProcessingTime]
			,B.[CreateDate]
			,DATEDIFF(d, B.CreateDate, GETDATE()) AS [Info_DaysOld]
			,CASE WHEN B.DBMS_Id IS NULL THEN 0 ELSE 1 END AS DataCollected
FROM		[dbo].[DBMS]				        S WITH (NOLOCK)
				LEFT JOIN [TSMBackupSummary]	B WITH (NOLOCK)	ON S.Id = B.DBMS_Id
WHERE		S.[Disable] = 0
  AND       S.[CollectInfo] = 1
  AND       S.[Type] = 'SQL Server'






GO


