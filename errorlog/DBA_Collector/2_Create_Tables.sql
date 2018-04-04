USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[BackupSummary]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[BackupSummary](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[DbName] [varchar](128) NOT NULL,
	[Type] [varchar](15) NOT NULL,
	[LastBackupStartDate] [datetime] NULL,
	[LastBackupFinishDate] [datetime] NULL,
	[LastBackupSize] [numeric](20, 0) NULL,
	[LastCompressedBackupSize] [numeric](20, 0) NULL,
	[DaysOld] [smallint] NULL,
	[TodaysBackupCount] [smallint] NULL,
	[YesterdaysBackupCount] [smallint] NULL,
	[TwoDaysAgoBackupCount] [smallint] NULL,
	[ThreeDaysAgoBackupCount] [smallint] NULL,
	[BackupUser] [varchar](128) NULL,
	[BackupSetName] [varchar](256) NULL,
	[BackupFilename] [varchar](512) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_BackupSummary] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[Configuration]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Configuration](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](255) NOT NULL,
	[Data] [varchar](2500) NOT NULL,
	[Notes] [varchar](500) NULL,
 CONSTRAINT [PK_Configuration] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [INDEX]
) ON [INDEX]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[DatabaseMirroringInfo]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DatabaseMirroringInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[DatabaseName] [varchar](128) NOT NULL,
	[Role] [varchar](60) NULL,
	[State] [varchar](60) NULL,
	[Sequence] [int] NULL,
	[SafteyLevel] [varchar](15) NULL,
	[PartnerName] [varchar](128) NULL,
	[PartnerInstance] [varchar](128) NULL,
	[PartnerWitness] [varchar](128) NULL,
	[WitnessState] [varchar](60) NULL,
	[ConnectionTimeout] [int] NULL,
	[RedoQueueType] [varchar](60) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DBMSMirroringInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[DatabaseOptionsInfo]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DatabaseOptionsInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[Name] [varchar](128) NOT NULL,
	[DbCreateDate] [datetime] NOT NULL,
	[Owner] [varchar](128) NOT NULL,
	[Collation] [varchar](128) NOT NULL,
	[CompatibilityLevel] [varchar](10) NOT NULL,
	[RecoveryModel] [varchar](20) NOT NULL,
	[AutoClose] [bit] NOT NULL,
	[AutoCreateStatistics] [bit] NOT NULL,
	[AutoShrink] [bit] NOT NULL,
	[AutoUpdateStatistics] [bit] NOT NULL,
	[CloseCursorOnCommitEnabled] [bit] NOT NULL,
	[ANSINullDefault] [bit] NOT NULL,
	[ANSINullsEnabled] [bit] NOT NULL,
	[ANSIPaddingEnabled] [bit] NOT NULL,
	[ANSIWarningsEnabled] [bit] NOT NULL,
	[ArithmeticAbortEnabled] [bit] NOT NULL,
	[ConcatenateNullYieldsNull] [bit] NOT NULL,
	[CrossDbOwnership] [bit] NOT NULL,
	[NumericRoundAbort] [bit] NOT NULL,
	[QuotedIdentifierEnabled] [bit] NOT NULL,
	[RecursiveTriggersEnabled] [bit] NOT NULL,
	[FullTextEnabled] [bit] NOT NULL,
	[Trustworthy] [bit] NOT NULL,
	[BrokerEnabled] [bit] NOT NULL,
	[ReadOnly] [bit] NOT NULL,
	[RestrictUserAccess] [varchar](25) NOT NULL,
	[Status] [varchar](25) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DatabaseOptionsInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[DatabaseSizeInfo]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DatabaseSizeInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[DbName] [varchar](128) NOT NULL,
	[Type] [varchar](5) NOT NULL,
	[Filegroup] [varchar](128) NULL,
	[LogicalName] [varchar](1024) NOT NULL,
	[FileSize_MB] [decimal](10, 2) NOT NULL,
	[UsedSpace_MB] [decimal](10, 2) NULL,
	[UnusedSpace_MB] [decimal](10, 2) NULL,
	[Growth] [int] NOT NULL,
	[GrowthType] [varchar](10) NOT NULL,
	[MaxSize_MB] [int] NOT NULL,
	[PhysicalName] [varchar](2048) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DatabaseSizeInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[DBMS]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DBMS](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [varchar](25) NOT NULL,
	[Name] [varchar](128) NOT NULL,
	[Instance] [varchar](128) NOT NULL,
	[IPAddress] [varchar](25) NOT NULL,
	[Port] [varchar](15) NULL,
	[Domain] [varchar](50) NULL,
	[Environment] [char](1) NULL,
	[HardwareType] [char](1) NOT NULL,
	[ServerType] [char](1) NOT NULL,
	[NamedPipesEnabled] [bit] NULL,
	[TcpIpEnabled] [bit] NULL,
	[DynamicPort] [varchar](15) NULL,
	[StaticPort] [varchar](15) NULL,
	[ForceProtocolEncryption] [bit] NULL,
	[SQLVersion] [varchar](25) NULL,
	[SQLEdition] [varchar](50) NULL,
	[SQLCollation] [varchar](50) NULL,
	[SQLSortOrder] [varchar](50) NULL,
	[RunningOnServer] [varchar](128) NULL,
	[WindowsVersion] [varchar](25) NULL,
	[Platform] [varchar](25) NULL,
	[PhysicalCPU] [tinyint] NULL,
	[LogicalCPU] [smallint] NULL,
	[PhysicalMemory] [int] NULL,
	[DotNetVersion] [varchar](25) NULL,
	[DBMailProfile] [varchar](128) NULL,
	[AgentMailProfile] [varchar](128) NULL,
	[LoginAuditLevel] [varchar](25) NULL,
	[ServerNameProperty] [varchar](128) NULL,
	[DateInstalled] [datetime] NULL,
	[DateRemoved] [datetime] NULL,
	[ApproxStartDate] [datetime] NULL,
	[ProgramDirectory] [varchar](256) NULL,
	[Path] [varchar](256) NULL,
	[BinaryDirectory] [varchar](256) NULL,
	[DefaultDataDirectory] [varchar](256) NULL,
	[DefaultLogDirectory] [varchar](256) NULL,
	[AbleToEmail] [bit] NOT NULL,
	[SupportedBy] [varchar](25) NULL,
	[TopologyActive] [bit] NULL,
	[TopologyKey] [int] NULL,
	[CollectInfo] [bit] NOT NULL,
	[PingByName] [bit] NULL,
	[PingDomainInfo] [varchar](128) NULL,
	[PingIPInfo] [varchar](25) NULL,
	[Disable] [bit] NOT NULL,
	[Notes] [varchar](500) NULL,
	[CreatedBy] [varchar](128) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastUpdate] [datetime] NULL,
 CONSTRAINT [PK_DBMS] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[DBMSConfigurationInfo]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DBMSConfigurationInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[ConfigId] [varchar](50) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Description] [varchar](256) NOT NULL,
	[Value] [varchar](256) NOT NULL,
	[ValueInUse] [varchar](256) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DBMSConfigurationInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[DriveSpaceInfo]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DriveSpaceInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[DriveLetter] [char](1) NOT NULL,
	[TotalSpace] [decimal](10, 2) NULL,
	[FreeSpace] [decimal](10, 2) NOT NULL,
	[Notes] [varchar](256) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DriveSpaceInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[FileHash]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[FileHash](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FilePath] [varchar](1000) NOT NULL,
	[HashValue] [varbinary](64) NULL,
 CONSTRAINT [PK_FileHash] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[GuardiumAuditReport]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[GuardiumAuditReport](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[TestId] [varchar](10) NOT NULL,
	[TestDescription] [varchar](512) NOT NULL,
	[DbName] [varchar](128) NOT NULL,
	[Description] [varchar](2048) NOT NULL,
	[FixScript] [varchar](2048) NOT NULL,
	[RollbackScript] [varchar](2048) NOT NULL,
	[CreateDate] [date] NOT NULL,
 CONSTRAINT [PK_GuardiumAuditReport] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [INDEX]
) ON [INDEX]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[JobScheduleInfo]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[JobScheduleInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[JobName] [varchar](128) NOT NULL,
	[JobOwner] [varchar](128) NULL,
	[ScheduleName] [varchar](128) NOT NULL,
	[ScheduleInfo] [varchar](2000) NOT NULL,
	[ScheduleType] [varchar](50) NOT NULL,
	[StartDate] [datetime] NULL,
	[StartTime] [varchar](10) NULL,
	[EndDate] [datetime] NULL,
	[EndTime] [varchar](10) NULL,
	[Frequency] [varchar](10) NULL,
	[Day] [int] NULL,
	[DayOfMonth] [varchar](25) NULL,
	[Every] [int] NULL,
	[DailyInterval] [int] NULL,
	[DailyIntervalType] [varchar](10) NULL,
	[Sunday] [bit] NOT NULL,
	[Monday] [bit] NOT NULL,
	[Tuesday] [bit] NOT NULL,
	[Wednesday] [bit] NOT NULL,
	[Thursday] [bit] NOT NULL,
	[Friday] [bit] NOT NULL,
	[Saturday] [bit] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_JobScheduleInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[JobSummary]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[JobSummary](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[Name] [varchar](128) NOT NULL,
	[Enabled] [bit] NOT NULL,
	[LastFailureDate] [datetime] NULL,
	[LastFailureDuration_Sec] [bigint] NULL,
	[LastSuccessDate] [datetime] NULL,
	[LastSuccessDuration_Sec] [int] NULL,
	[NextRunDate] [datetime] NULL,
	[Running] [bit] NOT NULL,
	[RunningDuration_Sec] [bigint] NOT NULL,
	[TodayErrorCount] [int] NOT NULL,
	[TodaySuccessCount] [int] NOT NULL,
	[YesterdayErrorCount] [int] NOT NULL,
	[YesterdaySuccessCount] [int] NOT NULL,
	[TwoDaysAgoErrorCount] [int] NOT NULL,
	[TwoDaysAgoSuccessCount] [int] NOT NULL,
	[ThreeDaysAgoErrorCount] [int] NOT NULL,
	[ThreeDaysAgoSuccessCount] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_JobSummary] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[LinkedServers]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[LinkedServers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[LinkedServer] [varchar](256) NOT NULL,
	[LocalLogin] [varchar](256) NOT NULL,
	[LoginType] [varchar](15) NOT NULL,
	[Impersonate] [bit] NOT NULL,
	[RemoteUser] [varchar](128) NULL,
	[LoginNotDefine] [varchar](500) NULL,
	[Provider] [varchar](256) NULL,
	[DataSource] [varchar](1024) NULL,
	[Location] [varchar](1024) NULL,
	[ProviderString] [varchar](1024) NULL,
	[Catalog] [varchar](256) NULL,
	[CollationCompatible] [bit] NOT NULL,
	[DataAccess] [bit] NOT NULL,
	[Rpc] [bit] NOT NULL,
	[RpcOut] [bit] NOT NULL,
	[UseRemoteCollation] [bit] NOT NULL,
	[CollationName] [varchar](256) NULL,
	[ConnectionTimeout] [int] NOT NULL,
	[QueryTimeout] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LinkedServers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[LogShippingInfo]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[LogShippingInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[Source] [varchar](15) NOT NULL,
	[SourceDBExist] [bit] NOT NULL,
	[PrimaryServer] [varchar](128) NOT NULL,
	[PrimaryDatabase] [varchar](128) NOT NULL,
	[SecondaryServer] [varchar](128) NOT NULL,
	[SecondaryDatabase] [varchar](128) NOT NULL,
	[MonitorServer] [varchar](128) NOT NULL,
	[BackupDirectory] [varchar](512) NOT NULL,
	[BackupShare] [varchar](512) NOT NULL,
	[LastBackupFile] [varchar](512) NULL,
	[LastBackupDate] [datetime] NULL,
	[LastCopiedFile] [varchar](512) NULL,
	[LastCopiedDate] [datetime] NULL,
	[LastRestoredFile] [varchar](512) NULL,
	[LastRestoredDate] [datetime] NULL,
	[BackupRetentionPeriod] [int] NOT NULL,
	[SQLTransBackupJob] [varchar](128) NULL,
	[SQLCopyJob] [varchar](128) NULL,
	[SQLRestoreJob] [varchar](128) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_LogShippingInfo] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[Monitor]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Monitor](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](128) NOT NULL,
	[Description] [varchar](1024) NULL,
	[Duration] [tinyint] NOT NULL,
	[AlertThreshold] [smallint] NOT NULL,
	[AlertThresholdDelay] [smallint] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Monitor] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[MonitorDBMSLog]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[MonitorDBMSLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[Monitor_Id] [int] NOT NULL,
	[LastSuccess] [datetime] NULL,
	[LastFailure] [datetime] NULL,
	[RaiseAlert] [tinyint] NOT NULL,
	[ThresholdDate] [datetime] NULL,
	[ThresholdCount] [int] NOT NULL,
	[IgnoreAlertUntil] [datetime] NULL,
	[Disable] [bit] NOT NULL,
	[Notes] [varchar](1024) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MonitorDBMSLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[MonitorDBMSLogDetail]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[MonitorDBMSLogDetail](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[MonitorDBMSLog_Id] [int] NOT NULL,
	[Status] [varchar](50) NOT NULL,
	[Description] [varchar](1024) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MonitorDBMSLogDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[MonitorServerLog]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[MonitorServerLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Server_Id] [int] NOT NULL,
	[Monitor_Id] [int] NOT NULL,
	[LastSuccess] [datetime] NULL,
	[LastFailure] [datetime] NULL,
	[RaiseAlert] [tinyint] NOT NULL,
	[ThresholdDate] [datetime] NULL,
	[ThresholdCount] [int] NOT NULL,
	[IgnoreAlertUntil] [datetime] NULL,
	[Disable] [bit] NOT NULL,
	[Notes] [varchar](1024) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MonitorServerLog] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[MonitorServerLogDetail]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[MonitorServerLogDetail](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[MonitorServerLog_Id] [int] NOT NULL,
	[Status] [varchar](50) NOT NULL,
	[Description] [varchar](1024) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_MonitorServerLogDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[ReplicationInfo]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ReplicationInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[PublicationServer] [varchar](128) NOT NULL,
	[PublicationDb] [varchar](128) NOT NULL,
	[Publication] [varchar](128) NOT NULL,
	[PublicationArticle] [varchar](128) NOT NULL,
	[DestinationObject] [varchar](128) NOT NULL,
	[SubscriptionServer] [varchar](128) NOT NULL,
	[SubscriberDb] [varchar](128) NOT NULL,
	[SubscriptionType] [varchar](15) NOT NULL,
	[SubscriberLogin] [varchar](128) NULL,
	[SubscriberSecurityMode] [varchar](25) NULL,
	[DistributionAgentSQLJob] [varchar](256) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ReplicationInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[ScheduledTaskInfo]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ScheduledTaskInfo](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Server_Id] [int] NOT NULL,
	[TaskName] [varchar](50) NULL,
	[NextRunTime] [varchar](30) NULL,
	[Status] [varchar](30) NULL,
	[LogonMode] [varchar](50) NULL,
	[LastRunTime] [varchar](30) NULL,
	[LastResults] [int] NULL,
	[Creator] [varchar](30) NULL,
	[TaskToRun] [varchar](512) NULL,
	[StartIn] [varchar](256) NULL,
	[Comment] [varchar](256) NULL,
	[ScheduleTaskState] [varchar](20) NULL,
	[IdleTime] [varchar](30) NULL,
	[PowerManagement] [varchar](200) NULL,
	[RunAsUser] [varchar](256) NULL,
	[DeleteTaskIfNotRescheduled] [varchar](100) NULL,
	[StopTaskIfRunsXHoursAndXMins] [varchar](100) NULL,
	[Schedule] [varchar](110) NULL,
	[ScheduleType] [varchar](40) NULL,
	[StartTime] [varchar](20) NULL,
	[StartDate] [varchar](25) NULL,
	[EndDate] [varchar](25) NULL,
	[Days] [varchar](100) NULL,
	[Months] [varchar](100) NULL,
	[RepeatEvery] [varchar](30) NULL,
	[RepeatUntilTime] [varchar](40) NULL,
	[RepeatUntilDuration] [varchar](30) NULL,
	[RepeatStopIfStillRunning] [varchar](30) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ScheduledTaskInfo] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[SecuritySummary]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[SecuritySummary](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[SecurityInfo] [varchar](256) NULL,
	[SecurityType] [varchar](256) NULL,
	[DatabaseName] [varchar](256) NULL,
	[ClassName] [varchar](128) NULL,
	[ObjectName] [varchar](256) NULL,
	[ObjectType] [varchar](256) NULL,
	[ColumnName] [varchar](256) NULL,
	[Permission] [varchar](256) NULL,
	[State] [varchar](60) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_SecuritySummary] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[Server]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Server](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](128) NOT NULL,
	[IPAddress] [varchar](25) NOT NULL,
	[Domain] [varchar](50) NULL,
	[Location] [varchar](128) NULL,
	[Address] [varchar](128) NULL,
	[City] [varchar](128) NULL,
	[State] [char](2) NULL,
	[Floor] [varchar](50) NULL,
	[Grid] [varchar](50) NULL,
	[HardwareType] [char](1) NULL,
	[ServerType] [char](1) NULL,
	[Manufactured] [varchar](25) NULL,
	[Model] [varchar](25) NULL,
	[WindowsVersion] [varchar](25) NULL,
	[Platform] [varchar](25) NULL,
	[PhysicalCPU] [tinyint] NULL,
	[LogicalCPU] [smallint] NULL,
	[PhysicalMemory] [int] NULL,
	[DateInstalled] [datetime] NULL,
	[DateRemoved] [datetime] NULL,
	[CollectInfo] [bit] NOT NULL,
	[TopologyActive] [bit] NULL,
	[SupportedBy] [varchar](25) NULL,
	[PingByName] [bit] NULL,
	[PingDomainInfo] [varchar](128) NULL,
	[PingIPInfo] [varchar](25) NULL,
	[Disable] [bit] NOT NULL,
	[Notes] [varchar](500) NULL,
	[CreatedBy] [varchar](128) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastUpdate] [datetime] NULL,
 CONSTRAINT [PK_Server] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[ServerDBMS]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ServerDBMS](
	[Server_Id] [int] NOT NULL,
	[DBMS_Id] [int] NOT NULL,
 CONSTRAINT [PK_ServerDBMS] PRIMARY KEY CLUSTERED 
(
	[Server_Id] ASC,
	[DBMS_Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[Services]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Services](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[DisplayName] [varchar](256) NULL,
	[BinaryPath] [varchar](1024) NULL,
	[ServiceAccount] [varchar](256) NOT NULL,
	[StartupType] [varchar](50) NOT NULL,
	[Status] [varchar](15) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Services] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

USE [DBA_DataCollector]
GO

/****** Object:  Table [dbo].[TSMBackupSummary]    Script Date: 06/09/2012 22:19:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[TSMBackupSummary](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DBMS_Id] [int] NOT NULL,
	[LogFile] [varchar](256) NOT NULL,
	[ScheduleName] [varchar](256) NULL,
	[ScheduleDate] [datetime] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[BackupPaths] [varchar](2048) NULL,
	[ObjectsInspected] [int] NULL,
	[ObjectsAssigned] [int] NULL,
	[ObjectsBackedUp] [int] NULL,
	[ObjectsUpdated] [int] NULL,
	[ObjectsRebound] [int] NULL,
	[ObjectsDeleted] [int] NULL,
	[ObjectsExpired] [int] NULL,
	[ObjectsFailed] [int] NULL,
	[SubfileObjects] [int] NULL,
	[BytesInspected] [varchar](25) NULL,
	[BytesTransferred] [varchar](25) NULL,
	[DataTransferTime] [varchar](25) NULL,
	[DataTransferRate] [varchar](25) NULL,
	[AggDataTransferRate] [varchar](25) NULL,
	[CompressPercentage] [varchar](25) NULL,
	[DataReductionRatio] [varchar](25) NULL,
	[SubfileObjectsReduceBy] [varchar](25) NULL,
	[ElapseProcessingTime] [varchar](25) NULL,
	[CreateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TSMBackupSummary] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[BackupSummary]  WITH CHECK ADD  CONSTRAINT [FK_BackupSummary_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[BackupSummary] CHECK CONSTRAINT [FK_BackupSummary_DBMS]
GO

ALTER TABLE [dbo].[BackupSummary] ADD  CONSTRAINT [DF_BackupSummary_Compressed]  DEFAULT ((0)) FOR [LastCompressedBackupSize]
GO

ALTER TABLE [dbo].[BackupSummary] ADD  CONSTRAINT [DF_BackupSummary_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[DatabaseMirroringInfo]  WITH CHECK ADD  CONSTRAINT [FK_DatabaseMirroringInfo_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[DatabaseMirroringInfo] CHECK CONSTRAINT [FK_DatabaseMirroringInfo_DBMS]
GO

ALTER TABLE [dbo].[DatabaseMirroringInfo] ADD  CONSTRAINT [DF_DatabaseMirroringInfo_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[DatabaseOptionsInfo]  WITH CHECK ADD  CONSTRAINT [FK_DatabaseInfo_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[DatabaseOptionsInfo] CHECK CONSTRAINT [FK_DatabaseInfo_DBMS]
GO

ALTER TABLE [dbo].[DatabaseOptionsInfo] ADD  CONSTRAINT [DF_DatabaseInfo_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[DatabaseSizeInfo]  WITH CHECK ADD  CONSTRAINT [FK_DatabaseSizeInfo_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[DatabaseSizeInfo] CHECK CONSTRAINT [FK_DatabaseSizeInfo_DBMS]
GO

ALTER TABLE [dbo].[DatabaseSizeInfo] ADD  CONSTRAINT [DF_DatabaseSizeInfo_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[DBMS]  WITH CHECK ADD  CONSTRAINT [CK_DBMS_Type] CHECK  (([Type]='SQL Server'))
GO

ALTER TABLE [dbo].[DBMS] CHECK CONSTRAINT [CK_DBMS_Type]
GO

ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_Type]  DEFAULT ('SQL Server') FOR [Type]
GO

ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_Instance]  DEFAULT ('Default') FOR [Instance]
GO

ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_HardwareType]  DEFAULT ('P') FOR [HardwareType]
GO

ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_ServerType]  DEFAULT ('S') FOR [ServerType]
GO

ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_AbleToEmail]  DEFAULT ((0)) FOR [AbleToEmail]
GO

ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_CollectInfo]  DEFAULT ((1)) FOR [CollectInfo]
GO

ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_Disable]  DEFAULT ((0)) FOR [Disable]
GO

ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_CreatedBy]  DEFAULT (suser_name()) FOR [CreatedBy]
GO

ALTER TABLE [dbo].[DBMS] ADD  CONSTRAINT [DF_DBMS_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[DBMSConfigurationInfo]  WITH CHECK ADD  CONSTRAINT [FK_DBMSConfigurationInfo_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[DBMSConfigurationInfo] CHECK CONSTRAINT [FK_DBMSConfigurationInfo_DBMS]
GO

ALTER TABLE [dbo].[DBMSConfigurationInfo] ADD  CONSTRAINT [DF_DBMSConfigurationInfo_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[DriveSpaceInfo]  WITH CHECK ADD  CONSTRAINT [FK_DriveSpaceInfo_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[DriveSpaceInfo] CHECK CONSTRAINT [FK_DriveSpaceInfo_DBMS]
GO

ALTER TABLE [dbo].[DriveSpaceInfo] ADD  CONSTRAINT [DF_DriveSpaceInfo_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[GuardiumAuditReport]  WITH CHECK ADD  CONSTRAINT [FK_GuardiumAuditReport_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[GuardiumAuditReport] CHECK CONSTRAINT [FK_GuardiumAuditReport_DBMS]
GO

ALTER TABLE [dbo].[GuardiumAuditReport] ADD  CONSTRAINT [DF_GuardiumAuditReport_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[JobScheduleInfo]  WITH CHECK ADD  CONSTRAINT [FK_JobScheduleInfo_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[JobScheduleInfo] CHECK CONSTRAINT [FK_JobScheduleInfo_DBMS]
GO

ALTER TABLE [dbo].[JobScheduleInfo] ADD  CONSTRAINT [DF_JobScheduleInfo_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[JobSummary]  WITH CHECK ADD  CONSTRAINT [FK_JobSummary_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[JobSummary] CHECK CONSTRAINT [FK_JobSummary_DBMS]
GO

ALTER TABLE [dbo].[JobSummary] ADD  CONSTRAINT [DF_SQLJobSummary_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[LinkedServers]  WITH CHECK ADD  CONSTRAINT [FK_LinkedServers_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[LinkedServers] CHECK CONSTRAINT [FK_LinkedServers_DBMS]
GO

ALTER TABLE [dbo].[LinkedServers] ADD  CONSTRAINT [DF_LinkedServers_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[LogShippingInfo]  WITH CHECK ADD  CONSTRAINT [FK_LogShippingInfo_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[LogShippingInfo] CHECK CONSTRAINT [FK_LogShippingInfo_DBMS]
GO

ALTER TABLE [dbo].[LogShippingInfo] ADD  CONSTRAINT [DF_LogShippingInfo_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[Monitor] ADD  CONSTRAINT [DF_Monitor_Duration]  DEFAULT ((5)) FOR [Duration]
GO

ALTER TABLE [dbo].[Monitor] ADD  CONSTRAINT [DF_Monitor_AlertThreshold]  DEFAULT ((15)) FOR [AlertThreshold]
GO

ALTER TABLE [dbo].[Monitor] ADD  CONSTRAINT [DF_Monitor_AlertThresholdDelay]  DEFAULT ((180)) FOR [AlertThresholdDelay]
GO

ALTER TABLE [dbo].[Monitor] ADD  CONSTRAINT [DF_Monitor_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[MonitorDBMSLog]  WITH CHECK ADD  CONSTRAINT [FK_MonitorDBMSLog_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[MonitorDBMSLog] CHECK CONSTRAINT [FK_MonitorDBMSLog_DBMS]
GO

ALTER TABLE [dbo].[MonitorDBMSLog]  WITH CHECK ADD  CONSTRAINT [FK_MonitorDBMSLog_Monitor] FOREIGN KEY([Monitor_Id])
REFERENCES [dbo].[Monitor] ([Id])
GO

ALTER TABLE [dbo].[MonitorDBMSLog] CHECK CONSTRAINT [FK_MonitorDBMSLog_Monitor]
GO

ALTER TABLE [dbo].[MonitorDBMSLog] ADD  CONSTRAINT [DF_MonitorDBMSLog_RaiseAlert]  DEFAULT ((0)) FOR [RaiseAlert]
GO

ALTER TABLE [dbo].[MonitorDBMSLog] ADD  CONSTRAINT [DF_MonitorDBMSLog_ThresholdCount]  DEFAULT ((0)) FOR [ThresholdCount]
GO

ALTER TABLE [dbo].[MonitorDBMSLog] ADD  CONSTRAINT [DF_MonitorDBMSLog_Disable]  DEFAULT ((0)) FOR [Disable]
GO

ALTER TABLE [dbo].[MonitorDBMSLog] ADD  CONSTRAINT [DF_MonitorDBMSLog_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[MonitorDBMSLogDetail]  WITH CHECK ADD  CONSTRAINT [FK_MonitorDBMSLogDetail_MonitorLog] FOREIGN KEY([MonitorDBMSLog_Id])
REFERENCES [dbo].[MonitorDBMSLog] ([Id])
GO

ALTER TABLE [dbo].[MonitorDBMSLogDetail] CHECK CONSTRAINT [FK_MonitorDBMSLogDetail_MonitorLog]
GO

ALTER TABLE [dbo].[MonitorDBMSLogDetail] ADD  CONSTRAINT [DF_MonitorDBMSLogDetail_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[MonitorServerLog]  WITH CHECK ADD  CONSTRAINT [FK_MonitorServerLog_Monitor] FOREIGN KEY([Monitor_Id])
REFERENCES [dbo].[Monitor] ([Id])
GO

ALTER TABLE [dbo].[MonitorServerLog] CHECK CONSTRAINT [FK_MonitorServerLog_Monitor]
GO

ALTER TABLE [dbo].[MonitorServerLog]  WITH CHECK ADD  CONSTRAINT [FK_MonitorServerLog_Server] FOREIGN KEY([Server_Id])
REFERENCES [dbo].[Server] ([Id])
GO

ALTER TABLE [dbo].[MonitorServerLog] CHECK CONSTRAINT [FK_MonitorServerLog_Server]
GO

ALTER TABLE [dbo].[MonitorServerLog] ADD  CONSTRAINT [DF_MonitorServerLog_RaiseAlert]  DEFAULT ((0)) FOR [RaiseAlert]
GO

ALTER TABLE [dbo].[MonitorServerLog] ADD  CONSTRAINT [DF_MonitorServerLog_ThresholdCount]  DEFAULT ((0)) FOR [ThresholdCount]
GO

ALTER TABLE [dbo].[MonitorServerLog] ADD  CONSTRAINT [DF_MonitorServerLog_Disable]  DEFAULT ((0)) FOR [Disable]
GO

ALTER TABLE [dbo].[MonitorServerLog] ADD  CONSTRAINT [DF_MonitorServerLog_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[MonitorServerLogDetail]  WITH CHECK ADD  CONSTRAINT [FK_MonitorServerLogDetail_MonitorLog] FOREIGN KEY([MonitorServerLog_Id])
REFERENCES [dbo].[MonitorServerLog] ([Id])
GO

ALTER TABLE [dbo].[MonitorServerLogDetail] CHECK CONSTRAINT [FK_MonitorServerLogDetail_MonitorLog]
GO

ALTER TABLE [dbo].[MonitorServerLogDetail] ADD  CONSTRAINT [DF_MonitorServerLogDetail_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[ReplicationInfo]  WITH CHECK ADD  CONSTRAINT [FK_ReplicationInfo_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[ReplicationInfo] CHECK CONSTRAINT [FK_ReplicationInfo_DBMS]
GO

ALTER TABLE [dbo].[ReplicationInfo] ADD  CONSTRAINT [DF_ReplicationInfo_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[ScheduledTaskInfo]  WITH CHECK ADD  CONSTRAINT [FK_ScheduledTaskInfo_Server] FOREIGN KEY([Server_Id])
REFERENCES [dbo].[Server] ([Id])
GO

ALTER TABLE [dbo].[ScheduledTaskInfo] CHECK CONSTRAINT [FK_ScheduledTaskInfo_Server]
GO

ALTER TABLE [dbo].[ScheduledTaskInfo] ADD  CONSTRAINT [DF_ScheduledTaskInfo_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[SecuritySummary]  WITH CHECK ADD  CONSTRAINT [FK_SecuritySummary_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[SecuritySummary] CHECK CONSTRAINT [FK_SecuritySummary_DBMS]
GO

ALTER TABLE [dbo].[SecuritySummary] ADD  CONSTRAINT [DF_SecuritySummary_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[Server] ADD  CONSTRAINT [DF_Server_HarwareType]  DEFAULT ('P') FOR [HardwareType]
GO

ALTER TABLE [dbo].[Server] ADD  CONSTRAINT [DF_Server_ServerType]  DEFAULT ('S') FOR [ServerType]
GO

ALTER TABLE [dbo].[Server] ADD  CONSTRAINT [DF_Server_CollectInfo]  DEFAULT ((1)) FOR [CollectInfo]
GO

ALTER TABLE [dbo].[Server] ADD  CONSTRAINT [DF_Server_Disable]  DEFAULT ((0)) FOR [Disable]
GO

ALTER TABLE [dbo].[Server] ADD  CONSTRAINT [DF_Server_CreatedBy]  DEFAULT (suser_name()) FOR [CreatedBy]
GO

ALTER TABLE [dbo].[Server] ADD  CONSTRAINT [DF_Server_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[ServerDBMS]  WITH CHECK ADD  CONSTRAINT [FK_ServerDBMS_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[ServerDBMS] CHECK CONSTRAINT [FK_ServerDBMS_DBMS]
GO

ALTER TABLE [dbo].[ServerDBMS]  WITH CHECK ADD  CONSTRAINT [FK_ServerDBMS_Server] FOREIGN KEY([Server_Id])
REFERENCES [dbo].[Server] ([Id])
GO

ALTER TABLE [dbo].[ServerDBMS] CHECK CONSTRAINT [FK_ServerDBMS_Server]
GO

ALTER TABLE [dbo].[Services]  WITH CHECK ADD  CONSTRAINT [FK_Services_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[Services] CHECK CONSTRAINT [FK_Services_DBMS]
GO

ALTER TABLE [dbo].[Services] ADD  CONSTRAINT [DF_Services_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO

ALTER TABLE [dbo].[TSMBackupSummary]  WITH CHECK ADD  CONSTRAINT [FK_TSMBackupSummary_DBMS] FOREIGN KEY([DBMS_Id])
REFERENCES [dbo].[DBMS] ([Id])
GO

ALTER TABLE [dbo].[TSMBackupSummary] CHECK CONSTRAINT [FK_TSMBackupSummary_DBMS]
GO

ALTER TABLE [dbo].[TSMBackupSummary] ADD  CONSTRAINT [DF_TSMBackupSummary_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO


