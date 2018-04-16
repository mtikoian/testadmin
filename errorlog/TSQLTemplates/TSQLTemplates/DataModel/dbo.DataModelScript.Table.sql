USE [DBA]
GO
/****** Object:  Table [dbo].[DataModelScript]    Script Date: 12/30/2013 4:17:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DataModelScript](
	[DatabaseName] [nvarchar](255) NULL,
	[TableName] [nvarchar](255) NULL,
	[ColumnName] [nvarchar](255) NULL,
	[Datatype] [nvarchar](255) NULL,
	[IsAllowNull] [nvarchar](255) NULL,
	[DefaultValue] [float] NULL,
	[ChangeType] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL,
	[SchemaName] [nvarchar](30) NULL,
	[DatatypeOld] [varchar](100) NULL,
	[Script_Fl] [bit] NOT NULL,
	[DataModelScriptId] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[DataModelScript] ADD  DEFAULT ((0)) FOR [Script_Fl]
GO
