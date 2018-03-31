
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DataModelScript]') AND type in (N'U'))
DROP TABLE [dbo].[DataModelScript]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DataModelScript]') AND type in (N'U'))
BEGIN
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
END
GO

SET ANSI_PADDING OFF
GO

IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DF__DataModel__Scrip__117F9D94]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[DataModelScript] ADD  DEFAULT ((0)) FOR [Script_Fl]
END
GO


