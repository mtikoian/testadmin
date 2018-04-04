
/****** Object:  BrokerService [//DBA/DataCollector/InitatorMonitorDBMSSQLAgentRunningService]    Script Date: 06/09/2012 22:26:17 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorMonitorDBMSSQLAgentRunningService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorMonitorDBMSSQLAgentRunningQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorMonitorDBMSSQLConnectionService]    Script Date: 06/09/2012 22:26:17 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorMonitorDBMSSQLConnectionService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorMonitorDBMSSQLConnectionQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorMonitorServerPingService]    Script Date: 06/09/2012 22:26:17 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorMonitorServerPingService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorMonitorServerPingQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLBackupSummaryService]    Script Date: 06/09/2012 22:26:17 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLBackupSummaryService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLBackupSummaryQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLDBMSConfigurationInfoService]    Script Date: 06/09/2012 22:26:17 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLDBMSConfigurationInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLDBMSConfigurationInfoQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLDBMSInfoService]    Script Date: 06/09/2012 22:26:17 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLDBMSInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLDBMSInfoQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLDatabaseMirroringInfoService]    Script Date: 06/09/2012 22:26:17 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLDatabaseMirroringInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLDatabaseMirroringInfoQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLDatabaseOptionsInfoService]    Script Date: 06/09/2012 22:26:17 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLDatabaseOptionsInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLDatabaseOptionsInfoQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLDatabaseSizeInfoService]    Script Date: 06/09/2012 22:26:18 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLDatabaseSizeInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLDatabaseSizeInfoQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLDriveInfoService]    Script Date: 06/09/2012 22:26:18 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLDriveInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLDriveInfoQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLGuardiumAuditReportService]    Script Date: 06/09/2012 22:26:18 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLGuardiumAuditReportService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLGuardiumAuditReportQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLJobScheduleInfoService]    Script Date: 06/09/2012 22:26:18 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLJobScheduleInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLJobScheduleInfoQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLJobSummaryService]    Script Date: 06/09/2012 22:26:18 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLJobSummaryService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLJobSummaryQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLLinkedServerInfoService]    Script Date: 06/09/2012 22:26:18 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLLinkedServerInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLLinkedServerInfoQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLLogShippingInfoService]    Script Date: 06/09/2012 22:26:18 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLLogShippingInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLLogShippingInfoQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLReplicationInfoService]    Script Date: 06/09/2012 22:26:18 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLReplicationInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLReplicationInfoQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLSecuritySummaryService]    Script Date: 06/09/2012 22:26:19 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLSecuritySummaryService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLSecuritySummaryQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLServicesInfoService]    Script Date: 06/09/2012 22:26:19 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLServicesInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLServicesInfoQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/InitatorSQLTSMBackupSummaryService]    Script Date: 06/09/2012 22:26:19 ******/
CREATE SERVICE [//DBA/DataCollector/InitatorSQLTSMBackupSummaryService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorInitiatorSQLTSMBackupSummaryQueue] 
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetMonitorDBMSSQLAgentRunningService]    Script Date: 06/09/2012 22:26:19 ******/
CREATE SERVICE [//DBA/DataCollector/TargetMonitorDBMSSQLAgentRunningService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetMonitorDBMSSQLAgentRunningQueue] ([//DBA/DataCollector/MonitorDBMSSQLAgentRunningContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetMonitorDBMSSQLConnectionService]    Script Date: 06/09/2012 22:26:19 ******/
CREATE SERVICE [//DBA/DataCollector/TargetMonitorDBMSSQLConnectionService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetMonitorDBMSSQLConnectionQueue] ([//DBA/DataCollector/MonitorDBMSSQLConnectionContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetMonitorServerPingService]    Script Date: 06/09/2012 22:26:19 ******/
CREATE SERVICE [//DBA/DataCollector/TargetMonitorServerPingService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetMonitorServerPingQueue] ([//DBA/DataCollector/MonitorServerPingContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLBackupSummaryService]    Script Date: 06/09/2012 22:26:19 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLBackupSummaryService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLBackupSummaryQueue] ([//DBA/DataCollector/SQLBackupSummaryContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLDBMSConfigurationInfoService]    Script Date: 06/09/2012 22:26:19 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLDBMSConfigurationInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLDBMSConfigurationInfoQueue] ([//DBA/DataCollector/SQLDBMSConfigurationInfoContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLDBMSInfoService]    Script Date: 06/09/2012 22:26:20 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLDBMSInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLDBMSInfoQueue] ([//DBA/DataCollector/SQLDBMSInfoContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLDatabaseMirroringInfoService]    Script Date: 06/09/2012 22:26:20 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLDatabaseMirroringInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLDatabaseMirroringInfoQueue] ([//DBA/DataCollector/SQLDatabaseMirroringInfoContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLDatabaseOptionsInfoService]    Script Date: 06/09/2012 22:26:20 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLDatabaseOptionsInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLDatabaseOptionsInfoQueue] ([//DBA/DataCollector/SQLDatabaseOptionsInfoContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLDatabaseSizeInfoService]    Script Date: 06/09/2012 22:26:20 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLDatabaseSizeInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLDatabaseSizeInfoQueue] ([//DBA/DataCollector/SQLDatabaseSizeInfoContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLDriveInfoService]    Script Date: 06/09/2012 22:26:20 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLDriveInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLDriveInfoQueue] ([//DBA/DataCollector/SQLDriveInfoContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLGuardiumAuditReportService]    Script Date: 06/09/2012 22:26:20 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLGuardiumAuditReportService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLGuardiumAuditReportQueue] ([//DBA/DataCollector/SQLGuardiumAuditReportContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLJobScheduleInfoService]    Script Date: 06/09/2012 22:26:20 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLJobScheduleInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLJobScheduleInfoQueue] ([//DBA/DataCollector/SQLJobScheduleInfoContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLJobSummaryService]    Script Date: 06/09/2012 22:26:20 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLJobSummaryService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLJobSummaryQueue] ([//DBA/DataCollector/SQLJobSummaryContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLLinkedServerInfoService]    Script Date: 06/09/2012 22:26:21 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLLinkedServerInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLLinkedServerInfoQueue] ([//DBA/DataCollector/SQLLinkedServerInfoContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLLogShippingInfoService]    Script Date: 06/09/2012 22:26:21 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLLogShippingInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLLogShippingInfoQueue] ([//DBA/DataCollector/SQLLogShippingInfoContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLReplicationInfoService]    Script Date: 06/09/2012 22:26:21 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLReplicationInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLReplicationInfoQueue] ([//DBA/DataCollector/SQLReplicationInfoContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLSecuritySummaryService]    Script Date: 06/09/2012 22:26:21 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLSecuritySummaryService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLSecuritySummaryQueue] ([//DBA/DataCollector/SQLSecuritySummaryContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLServicesInfoService]    Script Date: 06/09/2012 22:26:21 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLServicesInfoService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLServicesInfoQueue] ([//DBA/DataCollector/SQLServicesInfoContract])
GO

/****** Object:  BrokerService [//DBA/DataCollector/TargetSQLTSMBackupSummaryService]    Script Date: 06/09/2012 22:26:21 ******/
CREATE SERVICE [//DBA/DataCollector/TargetSQLTSMBackupSummaryService]  AUTHORIZATION [dbo]  ON QUEUE [dbo].[DBA_DataCollectorTargetSQLTSMBackupSummaryQueue] ([//DBA/DataCollector/SQLTSMBackupSummaryContract])
GO


