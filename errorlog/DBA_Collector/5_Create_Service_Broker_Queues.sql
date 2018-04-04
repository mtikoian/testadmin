
/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorMonitorDBMSSQLAgentRunningQueue]    Script Date: 06/09/2012 22:25:47 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorMonitorDBMSSQLAgentRunningQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorMonitorDBMSSQLConnectionQueue]    Script Date: 06/09/2012 22:25:47 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorMonitorDBMSSQLConnectionQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorMonitorServerPingQueue]    Script Date: 06/09/2012 22:25:47 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorMonitorServerPingQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLBackupSummaryQueue]    Script Date: 06/09/2012 22:25:47 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLBackupSummaryQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLDatabaseMirroringInfoQueue]    Script Date: 06/09/2012 22:25:47 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLDatabaseMirroringInfoQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLDatabaseOptionsInfoQueue]    Script Date: 06/09/2012 22:25:47 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLDatabaseOptionsInfoQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLDatabaseSizeInfoQueue]    Script Date: 06/09/2012 22:25:47 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLDatabaseSizeInfoQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLDBMSConfigurationInfoQueue]    Script Date: 06/09/2012 22:25:47 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLDBMSConfigurationInfoQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLDBMSInfoQueue]    Script Date: 06/09/2012 22:25:47 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLDBMSInfoQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLDriveInfoQueue]    Script Date: 06/09/2012 22:25:47 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLDriveInfoQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLGuardiumAuditReportQueue]    Script Date: 06/09/2012 22:25:48 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLGuardiumAuditReportQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLJobScheduleInfoQueue]    Script Date: 06/09/2012 22:25:48 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLJobScheduleInfoQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLJobSummaryQueue]    Script Date: 06/09/2012 22:25:48 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLJobSummaryQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLLinkedServerInfoQueue]    Script Date: 06/09/2012 22:25:48 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLLinkedServerInfoQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLLogShippingInfoQueue]    Script Date: 06/09/2012 22:25:48 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLLogShippingInfoQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLReplicationInfoQueue]    Script Date: 06/09/2012 22:25:48 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLReplicationInfoQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLSecuritySummaryQueue]    Script Date: 06/09/2012 22:25:48 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLSecuritySummaryQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLServicesInfoQueue]    Script Date: 06/09/2012 22:25:48 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLServicesInfoQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorInitiatorSQLTSMBackupSummaryQueue]    Script Date: 06/09/2012 22:25:48 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorInitiatorSQLTSMBackupSummaryQueue] WITH STATUS = ON , RETENTION = OFF  ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetMonitorDBMSSQLAgentRunningQueue]    Script Date: 06/09/2012 22:25:48 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetMonitorDBMSSQLAgentRunningQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_MonitorDBMSSQLAgentRunning] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetMonitorDBMSSQLConnectionQueue]    Script Date: 06/09/2012 22:25:49 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetMonitorDBMSSQLConnectionQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_MonitorDBMSSQLConnection] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetMonitorServerPingQueue]    Script Date: 06/09/2012 22:25:49 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetMonitorServerPingQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_MonitorServerPing] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLBackupSummaryQueue]    Script Date: 06/09/2012 22:25:49 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLBackupSummaryQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLBackupSummary] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLDatabaseMirroringInfoQueue]    Script Date: 06/09/2012 22:25:49 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLDatabaseMirroringInfoQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLDatabaseMirroringInfo] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLDatabaseOptionsInfoQueue]    Script Date: 06/09/2012 22:25:49 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLDatabaseOptionsInfoQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLDatabaseOptionsInfo] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLDatabaseSizeInfoQueue]    Script Date: 06/09/2012 22:25:49 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLDatabaseSizeInfoQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLDatabaseSizeInfo] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLDBMSConfigurationInfoQueue]    Script Date: 06/09/2012 22:25:49 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLDBMSConfigurationInfoQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLDBMSConfigurationInfo] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLDBMSInfoQueue]    Script Date: 06/09/2012 22:25:49 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLDBMSInfoQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLDBMSInfo] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLDriveInfoQueue]    Script Date: 06/09/2012 22:25:49 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLDriveInfoQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLDriveInfo] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLGuardiumAuditReportQueue]    Script Date: 06/09/2012 22:25:49 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLGuardiumAuditReportQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLGuardiumAuditReport] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLJobScheduleInfoQueue]    Script Date: 06/09/2012 22:25:49 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLJobScheduleInfoQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLJobScheduleInfo] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLJobSummaryQueue]    Script Date: 06/09/2012 22:25:50 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLJobSummaryQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLJobSummary] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLLinkedServerInfoQueue]    Script Date: 06/09/2012 22:25:50 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLLinkedServerInfoQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLLinkedServerInfo] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLLogShippingInfoQueue]    Script Date: 06/09/2012 22:25:50 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLLogShippingInfoQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLLogShippingInfo] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLReplicationInfoQueue]    Script Date: 06/09/2012 22:25:50 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLReplicationInfoQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLReplicationInfo] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLSecuritySummaryQueue]    Script Date: 06/09/2012 22:25:50 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLSecuritySummaryQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLSecuritySummary] , MAX_QUEUE_READERS = 5 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLServicesInfoQueue]    Script Date: 06/09/2012 22:25:50 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLServicesInfoQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLServicesInfo] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO

/****** Object:  ServiceQueue [dbo].[DBA_DataCollectorTargetSQLTSMBackupSummaryQueue]    Script Date: 06/09/2012 22:25:50 ******/
CREATE QUEUE [dbo].[DBA_DataCollectorTargetSQLTSMBackupSummaryQueue] WITH STATUS = ON , RETENTION = OFF , ACTIVATION (  STATUS = ON , PROCEDURE_NAME = [dbo].[SB_CollectSQLTSMBackupSummary] , MAX_QUEUE_READERS = 10 , EXECUTE AS OWNER  ) ON [PRIMARY] 
GO


