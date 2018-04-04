USE [master]
GO
/****** Object:  Database [Minion]    Script Date: 11/26/2015 18:47:04 ******/
CREATE DATABASE [Minion] ON  PRIMARY 
( NAME = N'Minion', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\Template Data\Minion.mdf' , SIZE = 33024KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'Minion_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\Template Data\Minion_log.LDF' , SIZE = 53248KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Minion] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Minion].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Minion] SET ANSI_NULL_DEFAULT OFF
GO
ALTER DATABASE [Minion] SET ANSI_NULLS OFF
GO
ALTER DATABASE [Minion] SET ANSI_PADDING OFF
GO
ALTER DATABASE [Minion] SET ANSI_WARNINGS OFF
GO
ALTER DATABASE [Minion] SET ARITHABORT OFF
GO
ALTER DATABASE [Minion] SET AUTO_CLOSE OFF
GO
ALTER DATABASE [Minion] SET AUTO_CREATE_STATISTICS ON
GO
ALTER DATABASE [Minion] SET AUTO_SHRINK OFF
GO
ALTER DATABASE [Minion] SET AUTO_UPDATE_STATISTICS ON
GO
ALTER DATABASE [Minion] SET CURSOR_CLOSE_ON_COMMIT OFF
GO
ALTER DATABASE [Minion] SET CURSOR_DEFAULT  GLOBAL
GO
ALTER DATABASE [Minion] SET CONCAT_NULL_YIELDS_NULL OFF
GO
ALTER DATABASE [Minion] SET NUMERIC_ROUNDABORT OFF
GO
ALTER DATABASE [Minion] SET QUOTED_IDENTIFIER OFF
GO
ALTER DATABASE [Minion] SET RECURSIVE_TRIGGERS OFF
GO
ALTER DATABASE [Minion] SET  ENABLE_BROKER
GO
ALTER DATABASE [Minion] SET AUTO_UPDATE_STATISTICS_ASYNC OFF
GO
ALTER DATABASE [Minion] SET DATE_CORRELATION_OPTIMIZATION OFF
GO
ALTER DATABASE [Minion] SET TRUSTWORTHY OFF
GO
ALTER DATABASE [Minion] SET ALLOW_SNAPSHOT_ISOLATION OFF
GO
ALTER DATABASE [Minion] SET PARAMETERIZATION SIMPLE
GO
ALTER DATABASE [Minion] SET READ_COMMITTED_SNAPSHOT OFF
GO
ALTER DATABASE [Minion] SET HONOR_BROKER_PRIORITY OFF
GO
ALTER DATABASE [Minion] SET  READ_WRITE
GO
ALTER DATABASE [Minion] SET RECOVERY FULL
GO
ALTER DATABASE [Minion] SET  MULTI_USER
GO
ALTER DATABASE [Minion] SET PAGE_VERIFY CHECKSUM
GO
ALTER DATABASE [Minion] SET DB_CHAINING OFF
GO
EXEC sys.sp_db_vardecimal_storage_format N'Minion', N'ON'
GO
USE [Minion]
GO
/****** Object:  Schema [Setup]    Script Date: 11/26/2015 18:47:04 ******/
CREATE SCHEMA [Setup] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [Servers]    Script Date: 11/26/2015 18:47:04 ******/
CREATE SCHEMA [Servers] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [Report]    Script Date: 11/26/2015 18:47:04 ******/
CREATE SCHEMA [Report] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [Portal]    Script Date: 11/26/2015 18:47:04 ******/
CREATE SCHEMA [Portal] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [Mgr]    Script Date: 11/26/2015 18:47:04 ******/
CREATE SCHEMA [Mgr] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [History]    Script Date: 11/26/2015 18:47:04 ******/
CREATE SCHEMA [History] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [Help]    Script Date: 11/26/2015 18:47:05 ******/
CREATE SCHEMA [Help] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [DM]    Script Date: 11/26/2015 18:47:05 ******/
CREATE SCHEMA [DM] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [DiskMgmt]    Script Date: 11/26/2015 18:47:05 ******/
CREATE SCHEMA [DiskMgmt] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [DBFile]    Script Date: 11/26/2015 18:47:05 ******/
CREATE SCHEMA [DBFile] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [Collector]    Script Date: 11/26/2015 18:47:05 ******/
CREATE SCHEMA [Collector] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [Backups]    Script Date: 11/26/2015 18:47:05 ******/
CREATE SCHEMA [Backups] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [BackupMgmt]    Script Date: 11/26/2015 18:47:05 ******/
CREATE SCHEMA [BackupMgmt] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [Audit]    Script Date: 11/26/2015 18:47:05 ******/
CREATE SCHEMA [Audit] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [Archive]    Script Date: 11/26/2015 18:47:05 ******/
CREATE SCHEMA [Archive] AUTHORIZATION [dbo]
GO
/****** Object:  Schema [Alert]    Script Date: 11/26/2015 18:47:05 ******/
CREATE SCHEMA [Alert] AUTHORIZATION [dbo]
GO
/****** Object:  Table [Collector].[SysObjects]    Script Date: 11/26/2015 18:47:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[SysObjects](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [bigint] NULL,
	[DBName] [sysname] NOT NULL,
	[ObjectName] [sysname] NOT NULL,
	[ObjectId] [int] NULL,
	[ParentName] [sysname] NOT NULL,
	[PrincipalId] [int] NULL,
	[SchemaName] [sysname] NOT NULL,
	[SchemaId] [int] NULL,
	[ParentObjectId] [int] NULL,
	[Type] [varchar](2) NULL,
	[TypeDesc] [nvarchar](120) NULL,
	[CreateDate] [datetime] NULL,
	[ModifyDate] [datetime] NULL,
	[IsMSShipped] [bit] NULL,
	[IsPublished] [bit] NULL,
	[IsSchemaPublished] [bit] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE CLUSTERED INDEX [clustID] ON [Collector].[SysObjects] 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nonExecDate] ON [Collector].[SysObjects] 
(
	[ExecutionDateTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SQLVersionstage]    Script Date: 11/26/2015 18:47:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [dbo].[SQLVersionstage](
	[Version] [varchar](50) NULL,
	[BUILD] [varchar](50) NULL,
	[BaseBuild] [varchar](50) NULL,
	[VersionName] [varchar](50) NULL,
	[KB] [varchar](50) NULL,
	[KBDescription] [varchar](500) NULL,
	[ReleaseDate] [varchar](50) NULL,
	[SupportLink] [varchar](500) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SQLVersions]    Script Date: 11/26/2015 18:47:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SQLVersions](
	[Version] [varchar](50) NULL,
	[BUILD] [varchar](50) NULL,
	[BaseBuild] [varchar](50) NULL,
	[VersionName] [varchar](50) NULL,
	[KB] [varchar](50) NULL,
	[KBDescription] [varchar](500) NULL,
	[ReleaseDate] [date] NULL,
	[SupportLink] [varchar](100) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[TableSize]    Script Date: 11/26/2015 18:47:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[TableSize](
	[ExecutionDateTime] [datetime] NOT NULL,
	[InstanceID] [int] NOT NULL,
	[DBName] [varchar](100) NULL,
	[TableName] [varchar](100) NULL,
	[DataSpaceUsed] [bigint] NULL,
	[IndexSpaceUsed] [bigint] NULL,
	[RowCount] [bigint] NULL,
	[FileGroup] [varchar](100) NULL,
	[Schema] [varchar](100) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE CLUSTERED INDEX [clustExecDateTime] ON [Collector].[TableSize] 
(
	[ExecutionDateTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nonDBNameExecDateTime] ON [Collector].[TableSize] 
(
	[DBName] ASC,
	[ExecutionDateTime] ASC
)
INCLUDE ( [InstanceID],
[DataSpaceUsed],
[IndexSpaceUsed]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nonInstanceID] ON [Collector].[TableSize] 
(
	[InstanceID] ASC,
	[ExecutionDateTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nonInstExecDate] ON [Collector].[TableSize] 
(
	[InstanceID] ASC
)
INCLUDE ( [ExecutionDateTime],
[DBName],
[DataSpaceUsed],
[IndexSpaceUsed]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [Portal].[spInputBuffer]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Portal].[spInputBuffer]
(
@spid INT
)

  
as

CREATE TABLE #InputBuffer
(
EventType VARCHAR(50),
[Parameters] VARCHAR(5),
EventInfo VARCHAR(1000)
)

DBCC InputBuffer(@spid)




;
GO
/****** Object:  Table [Collector].[WaitStats]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Collector].[WaitStats](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [bigint] NULL,
	[WaitType] [nvarchar](60) NOT NULL,
	[WaitingTasksCT] [bigint] NOT NULL,
	[MaxWaitTimeMS] [bigint] NOT NULL,
	[ResourceWaitTimeMS] [bigint] NULL,
	[PercentResourceWaitTime] [decimal](38, 17) NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [clustID] ON [Collector].[WaitStats] 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nonExecDate] ON [Collector].[WaitStats] 
(
	[ExecutionDateTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
/****** Object:  Table [Collector].[WindowsGroupsAndUsers]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[WindowsGroupsAndUsers](
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [bigint] NULL,
	[SQLGroup] [sysname] NOT NULL,
	[WindowsGroup] [sysname] NOT NULL,
	[TypeDesc] [varchar](10) NULL,
	[LoginName] [sysname] NOT NULL,
	[PermPath] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[SIDServer]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SIDServer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LoginName] [varchar](100) NULL,
	[SID] [varchar](150) NULL,
	[ConfigInstanceID] [int] NULL,
	[CreateCode] [varchar](500) NULL,
 CONSTRAINT [pk_SIDServer_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[spGetTable]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spGetTable]
(
	@QueryID int,
	@DataSet int = 0,
	@Type varchar(10),
	@InstanceID int = null,
	@ExecutionDateTime datetime = null,
	@WhereClause varchar(max) = null,
	@OrderBy varchar(max) = null
)

  
as

declare @Colid int
declare @ColName varchar(255)

declare @select varchar(max)
declare @join varchar(max)
declare @where varchar(max)

declare @prefix1 varchar(10)
declare @prefix2 varchar(10)
declare @place int

set @select = 'select a.ExecutionDateTime, a.InstanceType, a.InstanceID, a.QueryID, a.ResultSet, a.ResultRow, ' 
set @join	= 'into ##temp from QueryResult a left join ' 
set @where	= 'where a.InstanceType = ''' + @Type + '''' + 
	' and a.QueryID = '		+ cast(@QueryID as varchar(10)) + 
	' and a.ResultSet = '	+ cast(@DataSet as varchar(10)) + 
	case when @InstanceID is null			then '' else ' and a.InstanceID = '	+ cast(@InstanceID as varchar(10)) end + 
	case when @ExecutionDateTime is null	then '' else ' and a.ExecutionDateTime = ''' + convert(varchar(50), @ExecutionDateTime,121) + '''' end + 
	' and ' 


if @Type = 'SMO'
begin

	declare acursor cursor for 
		SELECT [ColID],[ColName]
		FROM [DBStats].[dbo].[SMOQueryDef]
		WHERE [SMOQueryID] = @QueryID AND [DSID] = @DataSet
	open acursor
	fetch acursor into @Colid, @ColName
	while @@fetch_status = 0
	begin 

		set @prefix2 = @prefix1
		set @place = ((@Colid)/ 26) + 1
		set @prefix1 = char(97 +  (@Colid - ((@place - 1) * 26)) )

	--select @place, @prefix1, @prefix2, @Colid, @ColName


		while @place > 1 
		begin
			set @prefix1 = @prefix1 + @prefix1
			set @place = @place - 1
		end

		select @select = @select + @prefix1 + '.ResultValue as [' + @ColName + '], '

		if @Colid > 0 
		begin
		select @join = @join + 'QueryResult ' +		@prefix1 + ' on ' +
			'a' /*@prefix2*/ + '.ExecutionDateTime = ' +	@prefix1 + '.ExecutionDateTime and ' + 
			'a' /*@prefix2*/ + '.InstanceType = ' +			@prefix1 + '.InstanceType and ' + 
			'a' /*@prefix2*/ + '.InstanceID = ' +			@prefix1 + '.InstanceID and ' + 
			'a' /*@prefix2*/ + '.QueryID = ' +				@prefix1 + '.QueryID and ' + 
			'a' /*@prefix2*/ + '.ResultSet = ' +			@prefix1 + '.ResultSet and ' + 
			'a' /*@prefix2*/ + '.ResultRow = ' +			@prefix1 + '.ResultRow left join '
		end

		select @where = @where + @prefix1 + '.ResultColumn = ' + cast(@Colid as varchar(10)) + ' and '

		fetch acursor into @Colid, @ColName

	end
	close acursor
	deallocate acursor

end


if @Type = 'WMI'
begin

	declare acursor cursor for 
		SELECT [ColID],[ColName]
		FROM [DBStats].[dbo].[WMIQueryDef]
		WHERE [WMIQueryID] = @QueryID AND [DSID] = @DataSet
	open acursor
	fetch acursor into @Colid, @ColName
	while @@fetch_status = 0
	begin 

		set @prefix2 = @prefix1
		set @place = ((@Colid)/ 26) + 1
		set @prefix1 = char(97 +  (@Colid - ((@place - 1) * 26)) )

	--select @place, @prefix1, @prefix2, @Colid, @ColName


		while @place > 1 
		begin
			set @prefix1 = @prefix1 + @prefix1
			set @place = @place - 1
		end

		select @select = @select + @prefix1 + '.ResultValue as [' + @ColName + '], '

		if @Colid > 0 
		begin
		select @join = @join + 'QueryResult ' +		@prefix1 + ' on ' +
			'a' /*@prefix2*/ + '.ExecutionDateTime = ' +	@prefix1 + '.ExecutionDateTime and ' + 
			'a' /*@prefix2*/ + '.InstanceType = ' +			@prefix1 + '.InstanceType and ' + 
			'a' /*@prefix2*/ + '.InstanceID = ' +			@prefix1 + '.InstanceID and ' + 
			'a' /*@prefix2*/ + '.QueryID = ' +				@prefix1 + '.QueryID and ' + 
			'a' /*@prefix2*/ + '.ResultSet = ' +			@prefix1 + '.ResultSet and ' + 
			'a' /*@prefix2*/ + '.ResultRow = ' +			@prefix1 + '.ResultRow left join '
		end

		select @where = @where + @prefix1 + '.ResultColumn = ' + cast(@Colid as varchar(10)) + ' and '

		fetch acursor into @Colid, @ColName

	end
	close acursor
	deallocate acursor

end

select @select	= substring(@select, 1, len(@select) - 1) + ' '
select @join	= substring(@join, 1, len(@join) - 10) + ' '


select @where	= substring(@where, 1, len(@where) - 4) + ' '

if @WhereClause is not null
select @where = @where + ' and ' + @WhereClause

if @OrderBy is not null
select @where = @where + ' ' + @OrderBy

--select @select 
--select @join 
--select @where 

if @Type = 'WMI' or @Type = 'SMO' 
begin
	exec(@select + @join + @where)
	select * from ##temp
	drop table ##temp
end




;
GO
/****** Object:  StoredProcedure [dbo].[spDumpStats]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spDumpStats]
(
	@QueryID int,
	@DataSet int,
	@Type varchar(10)
)

  
as

set nocount off

declare @Colid int
declare @ColName varchar(255)

declare @select varchar(max)
declare @join varchar(max)
declare @where varchar(max)

declare @prefix1 varchar(10)
declare @prefix2 varchar(10)
declare @place int

declare @tablename varchar(255)
set @tablename = 
	'STATS'							+ '_' +
	@Type							+ '_' +
	cast(@QueryID as varchar(10))	+ '_' +
	cast(@DataSet as varchar(10))





if exists (select name from sys.sysobjects where name = @tablename)
begin
	set @select = 'insert ' + @tablename + ' select a.ExecutionDateTime, a.InstanceType, a.InstanceID, a.QueryID, a.ResultSet, a.ResultRow, ' 
	set @join	= 'from QueryResult a left join ' 
	set @where	= 'where a.InstanceType = ''' + @Type + '''' + 
		' and a.QueryID = '		+ cast(@QueryID as varchar(10)) + 
		' and a.ResultSet = '	+ cast(@DataSet as varchar(10)) + 
		' and ' 
end
else
begin
	set @select = 'select a.ExecutionDateTime, a.InstanceType, a.InstanceID, a.QueryID, a.ResultSet, a.ResultRow, ' 
	set @join	= 'into ' + @tablename + ' from QueryResult a left join ' 
	set @where	= 'where a.InstanceType = ''' + @Type + '''' + 
		' and a.QueryID = '		+ cast(@QueryID as varchar(10)) + 
		' and a.ResultSet = '	+ cast(@DataSet as varchar(10)) + 
		' and ' 
end




if @Type = 'SMO'
begin

	declare acursor cursor for 
		SELECT [ColID],[ColName]
		FROM [DBStats].[dbo].[SMOQueryDef]
		WHERE [SMOQueryID] = @QueryID AND [DSID] = @DataSet
	open acursor
	fetch acursor into @Colid, @ColName
	while @@fetch_status = 0
	begin 

		set @prefix2 = @prefix1
		set @place = ((@Colid)/ 26) + 1
		set @prefix1 = char(97 +  (@Colid - ((@place - 1) * 26)) )

	--select @place, @prefix1, @prefix2, @Colid, @ColName


		while @place > 1 
		begin
			set @prefix1 = @prefix1 + @prefix1
			set @place = @place - 1
		end

		select @select = @select + @prefix1 + '.ResultValue as [' + @ColName + '], '

		if @Colid > 0 
		begin
		select @join = @join + 'QueryResult ' +		@prefix1 + ' on ' +
			'a' /*@prefix2*/ + '.ExecutionDateTime = ' +	@prefix1 + '.ExecutionDateTime and ' + 
			'a' /*@prefix2*/ + '.InstanceType = ' +			@prefix1 + '.InstanceType and ' + 
			'a' /*@prefix2*/ + '.InstanceID = ' +			@prefix1 + '.InstanceID and ' + 
			'a' /*@prefix2*/ + '.QueryID = ' +				@prefix1 + '.QueryID and ' + 
			'a' /*@prefix2*/ + '.ResultSet = ' +			@prefix1 + '.ResultSet and ' + 
			'a' /*@prefix2*/ + '.ResultRow = ' +			@prefix1 + '.ResultRow left join '
		end

		select @where = @where + @prefix1 + '.ResultColumn = ' + cast(@Colid as varchar(10)) + ' and '

		fetch acursor into @Colid, @ColName

	end
	close acursor
	deallocate acursor

end


if @Type = 'WMI'
begin

	declare acursor cursor for 
		SELECT [ColID],[ColName]
		FROM [DBStats].[dbo].[WMIQueryDef]
		WHERE [WMIQueryID] = @QueryID AND [DSID] = @DataSet
	open acursor
	fetch acursor into @Colid, @ColName
	while @@fetch_status = 0
	begin 

		set @prefix2 = @prefix1
		set @place = ((@Colid)/ 26) + 1
		set @prefix1 = char(97 +  (@Colid - ((@place - 1) * 26)) )

	--select @place, @prefix1, @prefix2, @Colid, @ColName


		while @place > 1 
		begin
			set @prefix1 = @prefix1 + @prefix1
			set @place = @place - 1
		end

		select @select = @select + @prefix1 + '.ResultValue as [' + @ColName + '], '

		if @Colid > 0 
		begin
		select @join = @join + 'QueryResult ' +		@prefix1 + ' on ' +
			'a' /*@prefix2*/ + '.ExecutionDateTime = ' +	@prefix1 + '.ExecutionDateTime and ' + 
			'a' /*@prefix2*/ + '.InstanceType = ' +			@prefix1 + '.InstanceType and ' + 
			'a' /*@prefix2*/ + '.InstanceID = ' +			@prefix1 + '.InstanceID and ' + 
			'a' /*@prefix2*/ + '.QueryID = ' +				@prefix1 + '.QueryID and ' + 
			'a' /*@prefix2*/ + '.ResultSet = ' +			@prefix1 + '.ResultSet and ' + 
			'a' /*@prefix2*/ + '.ResultRow = ' +			@prefix1 + '.ResultRow left join '
		end

		select @where = @where + @prefix1 + '.ResultColumn = ' + cast(@Colid as varchar(10)) + ' and '

		fetch acursor into @Colid, @ColName

	end
	close acursor
	deallocate acursor

end

select @select	= substring(@select, 1, len(@select) - 1) + ' '
select @join	= substring(@join, 1, len(@join) - 10) + ' '


select @where	= substring(@where, 1, len(@where) - 4) + ' '

--select @select 
--select @join 
--select @where 

if @Type = 'WMI' or @Type = 'SMO' 
begin
	exec(@select + @join + @where)
	-- exec('select * from ' + @tablename)
	exec(
	'DELETE	[dbo].[QueryResult]
	FROM	[dbo].[QueryResult] a
	join	[dbo].[' + @tablename + '] b 
		on	a.ExecutionDateTime =	b.ExecutionDateTime
		and a.InstanceType =		b.InstanceType
		and a.InstanceID =			b.InstanceID
		and a.QueryID =				b.QueryID
		and a.ResultSet =			b.ResultSet
		and a.ResultRow =			b.ResultRow
	')


end




;
GO
/****** Object:  Table [Collector].[ServiceAcct]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[ServiceAcct](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[ServiceName] [varchar](50) NULL,
	[StartName] [varchar](50) NULL,
 CONSTRAINT [pk_ServiceAcct_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerJobs]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerJobs](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[JobName] [varchar](100) NULL,
	[JobID] [varchar](100) NULL,
	[Descr] [nvarchar](512) NULL,
	[ENABLED] [bit] NULL,
	[OwnerSID] [varchar](100) NULL,
	[DateCreated] [datetime] NULL,
	[DateModified] [datetime] NULL,
	[ExecutionDateTime] [datetime] NULL,
 CONSTRAINT [pk_ServerJobs_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerSwingableDrive]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerSwingableDrive](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[DriveName] [varchar](200) NULL,
	[FriendlyName] [varchar](50) NULL,
	[IsSwingable] [bit] NULL,
 CONSTRAINT [pk_ServerSwingableDrive_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [History].[ServiceStatus]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [History].[ServiceStatus](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[ServerName] [varchar](100) NULL,
	[ServiceName] [varchar](50) NULL,
	[ServiceStartMode] [varchar](20) NULL,
	[ServiceStatus] [varchar](20) NULL,
	[ServiceLevel] [varchar](10) NULL,
	[AppName] [varchar](100) NULL,
 CONSTRAINT [pk_ServiceStatus_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[ServiceStatus]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[ServiceStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[ServiceName] [varchar](50) NULL,
	[Status] [varchar](20) NULL,
	[StartMode] [varchar](20) NULL,
 CONSTRAINT [pk_ServiceStatus_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[ServiceAlert]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[ServiceAlert](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[ServiceName] [varchar](100) NULL,
	[AlertSent] [bit] NULL,
 CONSTRAINT [pk_ServiceAlert_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerMgmtDB]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerMgmtDB](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[InstanceID] [bigint] NULL,
	[MgmtDB] [sysname] NOT NULL,
 CONSTRAINT [pk_ServerMgmtDB_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReplScenario]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReplScenario](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PublID] [int] NULL,
	[PublName] [varchar](100) NULL,
	[PublDBName] [varchar](100) NULL,
	[DistID] [int] NULL,
	[DistDBName] [varchar](100) NULL,
	[SubrID] [int] NULL,
	[SubrDBName] [varchar](100) NULL,
 CONSTRAINT [pk_ReplScenario_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerModule]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerModule](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[InstanceID] [bigint] NULL,
	[BackupManaged] [bit] NULL,
	[DiskManaged] [bit] NULL,
	[IndexManaged] [bit] NULL,
	[ServiceManaged] [bit] NULL,
	[SPConfigureManaged] [bit] NULL,
 CONSTRAINT [pk_ServerModule_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Collector].[ServersOSDetail]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[ServersOSDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[FreePhysicalMemory] [bigint] NULL,
	[FreeSpaceInPagingFiles] [bigint] NULL,
	[FreeVirtualMemory] [bigint] NULL,
	[InstallDate] [varchar](50) NULL,
	[LastBootUpTime] [varchar](50) NULL,
	[MaxNumberOfProcesses] [bigint] NULL,
	[MaxProcessMemorySize] [bigint] NULL,
	[Name] [varchar](500) NULL,
	[NumberOfLicensedUsers] [bigint] NULL,
	[NumberOfProcesses] [bigint] NULL,
	[NumberOfUsers] [bigint] NULL,
	[OSArchitecture] [varchar](50) NULL,
	[OSLanguage] [int] NULL,
	[PAEEnabled] [bit] NULL,
	[SerialNumber] [varchar](100) NULL,
	[ServicePackMajorVersion] [int] NULL,
	[ServicePackMinorVersion] [int] NULL,
	[SizeStoredInPagingFiles] [bigint] NULL,
	[Status] [varchar](20) NULL,
	[SystemDirectory] [varchar](100) NULL,
	[SystemDrive] [varchar](5) NULL,
	[TotalSwapSpaceSize] [bigint] NULL,
	[TotalVirtualMemorySize] [bigint] NULL,
	[TotalVisibleMemorySize] [bigint] NULL,
	[Version] [varchar](20) NULL,
	[WindowsDirectory] [varchar](50) NULL,
 CONSTRAINT [pk_ServersOSDetail_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReplPublisher]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReplPublisher](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[PublName] [varchar](100) NULL,
	[Descr] [varchar](1000) NULL,
	[SyncMethod] [tinyint] NULL,
	[SendAlert] [bit] NULL,
	[AlertMethod] [varchar](25) NULL,
	[AlertValue] [int] NULL,
	[PublisherType] [varchar](6) NULL,
	[OraclePublisher] [sysname] NULL,
	[CustomQuery] [nvarchar](max) NULL,
	[CustomAlertMethod] [varchar](50) NULL,
	[CustomAlertValue] [bigint] NULL,
 CONSTRAINT [pk_ReplPublisher_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerAppListFromAD]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerAppListFromAD](
	[Server_Name] [nvarchar](255) NULL,
	[IP Address] [nvarchar](255) NULL,
	[RowNumber] [nvarchar](255) NULL,
	[Cabinet] [nvarchar](255) NULL,
	[Serial Number] [nvarchar](255) NULL,
	[Engineer_Assigned] [nvarchar](255) NULL,
	[Prod] [nvarchar](255) NULL,
	[DataCenter] [nvarchar](255) NULL,
	[Operating_System] [nvarchar](255) NULL,
	[Manufactor] [nvarchar](255) NULL,
	[Model] [nvarchar](255) NULL,
	[RAC_RSA] [nvarchar](255) NULL,
	[Application_FromBCPList] [nvarchar](255) NULL,
	[Application_Contact] [nvarchar](255) NULL,
	[Director_Responsible] [nvarchar](255) NULL,
	[Category] [nvarchar](255) NULL,
	[Comments] [nvarchar](255) NULL,
	[Target_Refresh] [nvarchar](255) NULL,
	[Hardware_OS_Contact] [nvarchar](255) NULL,
	[Hardware_Support_Contract] [nvarchar](255) NULL,
	[PO_Number] [nvarchar](255) NULL,
	[PO_StartDate] [nvarchar](255) NULL,
	[PO_EndDate] [nvarchar](255) NULL,
	[Lease_StartDate] [nvarchar](255) NULL,
	[Lease_EndDate] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ServerApplicationEnvironmentXRef]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerApplicationEnvironmentXRef](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[AppID] [int] NULL,
	[AppEnvID] [int] NULL,
 CONSTRAINT [pk_ServerApplicationEnvironmentXRef_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uniNonInstanceIDAppID] ON [dbo].[ServerApplicationEnvironmentXRef] 
(
	[InstanceID] ASC,
	[AppID] ASC,
	[AppEnvID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SchemaVersion]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SchemaVersion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NOT NULL,
	[DBID] [int] NOT NULL,
	[Major] [int] NOT NULL,
	[Tables] [int] NOT NULL,
	[SPs] [int] NOT NULL,
	[Views] [int] NOT NULL,
	[Other] [int] NOT NULL,
	[Notes] [varchar](max) NULL,
	[Path] [varchar](max) NULL,
	[ImplDate] [smalldatetime] NOT NULL,
	[ImplBy] [varchar](100) NOT NULL,
 CONSTRAINT [pk_SchemaVersion_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RestoreItem]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RestoreItem](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[RestoreID] [int] NULL,
	[ObjectID] [int] NULL,
	[RestoreOrder] [decimal](8, 2) NULL,
 CONSTRAINT [PK_RestoreItem] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ServerDBBackupExclusions]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerDBBackupExclusions](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](255) NULL,
	[DBName] [nvarchar](255) NULL,
	[FullBackup] [bit] NULL,
	[LogBackup] [bit] NULL,
	[DiffBackup] [bit] NULL,
 CONSTRAINT [pk_ServerDBBackupExclusions_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ServerDBBackupExceptions]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerDBBackupExceptions](
	[InstanceID] [int] NULL,
	[DBId] [int] NULL,
	[FullBackup] [bit] NULL,
	[LogBackup] [bit] NULL,
	[DiffBackup] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Alert].[ReplLatencyDefer]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Alert].[ReplLatencyDefer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PublServerID] [int] NULL,
	[PublDBName] [varchar](100) NULL,
	[PublName] [varchar](100) NULL,
	[SubrServerID] [int] NULL,
	[SubrDBName] [varchar](100) NULL,
	[DeferDate] [date] NULL,
	[DeferEndDate] [date] NULL,
	[DeferEndTime] [time](7) NULL,
 CONSTRAINT [pk_ReplLatencyDefer_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReplLatency]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReplLatency](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ReplScenarioID] [int] NULL,
	[TracerID] [int] NULL,
	[PublCommit] [datetime] NULL,
	[DistLatency] [int] NULL,
	[SubrID] [int] NULL,
	[SubrLatency] [int] NULL,
	[OverallLatency] [int] NULL,
 CONSTRAINT [pk_ReplLatency_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Collector].[ReplLatency]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Collector].[ReplLatency](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [smalldatetime] NULL,
	[PublServerID] [int] NULL,
	[PublDB] [sysname] NOT NULL,
	[PublName] [sysname] NOT NULL,
	[SubrServerID] [int] NULL,
	[SubrDB] [sysname] NULL,
	[DistLatency] [int] NULL,
	[SubrLatency] [int] NULL,
	[TotalLatency] [int] NULL,
	[TracerID] [int] NULL,
	[PublisherCommit] [datetime] NULL,
	[CustomQueryResultPUBL] [nvarchar](100) NULL,
	[CustomQueryResultSUBR] [nvarchar](100) NULL,
	[CustomQuery] [nvarchar](max) NULL,
	[Complete] [bit] NULL,
 CONSTRAINT [pk_ReplLatency_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_ReplLatency_PublServerID] ON [Collector].[ReplLatency] 
(
	[PublServerID] ASC,
	[PublDB] ASC,
	[PublName] ASC,
	[SubrServerID] ASC,
	[SubrDB] ASC,
	[Complete] ASC,
	[DistLatency] ASC
)
INCLUDE ( [ExecutionDateTime]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PasswordDictionary]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PasswordDictionary](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Pword] [nvarchar](500) NULL,
	[PwordHash] [varbinary](max) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [DM].[spETLResetPackageList]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [DM].[spETLResetPackageList]

  
AS

UPDATE DM.PackageList
SET Status = 0 
WHERE Status = 1




;
GO
/****** Object:  Table [Alert].[ReplLatencyException]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Alert].[ReplLatencyException](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PublServerID] [int] NULL,
	[PublDBName] [varchar](100) NULL,
	[PublName] [varchar](100) NULL,
	[SubrServeID] [int] NULL,
	[SubrDBName] [varchar](100) NULL,
 CONSTRAINT [pk_ReplLatencyException_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[Logins]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[Logins](
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [bigint] NULL,
	[sid] [varbinary](85) NULL,
	[status] [smallint] NULL,
	[createdate] [datetime] NULL,
	[updatedate] [datetime] NULL,
	[accdate] [datetime] NULL,
	[totcpu] [int] NULL,
	[totio] [int] NULL,
	[spacelimit] [int] NULL,
	[timelimit] [int] NULL,
	[resultlimit] [int] NULL,
	[name] [sysname] NULL,
	[dbname] [sysname] NULL,
	[password] [varbinary](max) NULL,
	[language] [sysname] NULL,
	[denylogin] [int] NULL,
	[hasaccess] [int] NULL,
	[isntname] [int] NULL,
	[isntgroup] [int] NULL,
	[isntuser] [int] NULL,
	[sysadmin] [int] NULL,
	[securityadmin] [int] NULL,
	[serveradmin] [int] NULL,
	[setupadmin] [int] NULL,
	[processadmin] [int] NULL,
	[diskadmin] [int] NULL,
	[dbcreator] [int] NULL,
	[bulkadmin] [int] NULL,
	[loginname] [sysname] NULL,
	[BadPasswordCount] [int] NULL,
	[BadPasswordTime] [datetime] NULL,
	[HistoryLength] [datetime] NULL,
	[PasswordLastSetTime] [datetime] NULL,
	[PasswordHash] [varchar](50) NULL,
	[LoginType] [varchar](50) NULL,
	[DateLastModified] [datetime] NULL,
	[IsDisabled] [bit] NULL,
	[IsLocked] [bit] NULL,
	[IsPasswordExpired] [bit] NULL,
	[IsSystemObject] [bit] NULL,
	[LanguageAlias] [varchar](50) NULL,
	[MustChangePassword] [bit] NULL,
	[PasswordExpirationEnabled] [bit] NULL,
	[PasswordPolicyEnforced] [bit] NULL,
	[State] [varchar](50) NULL,
	[WindowsLoginAccessType] [varchar](50) NULL,
	[DefaultDatabase] [varchar](150) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE CLUSTERED INDEX [clustExecDateInstance] ON [Collector].[Logins] 
(
	[ExecutionDateTime] ASC,
	[InstanceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nonInstanceID] ON [Collector].[Logins] 
(
	[InstanceID] ASC
)
INCLUDE ( [ExecutionDateTime],
[name],
[hasaccess]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Table [Collector].[Logspace]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[Logspace](
	[ExecutionDateTime] [datetime] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[SIZE] [bigint] NULL,
	[UsedSpace] [bigint] NULL,
	[VolumeFreeSpace] [bigint] NULL,
	[Growth] [bigint] NULL,
	[GrowthType] [varchar](20) NULL,
	[MAXSIZE] [bigint] NULL,
 CONSTRAINT [pk_Logspace_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Servers]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Servers](
	[InstanceID] [int] IDENTITY(1,1) NOT NULL,
	[LocID] [int] NULL,
	[ServerName] [varchar](100) NULL,
	[DNS] [varchar](50) NULL,
	[IP] [char](15) NULL,
	[Port] [int] NULL,
	[Descr] [varchar](1000) NULL,
	[Role] [varchar](25) NULL,
	[ServiceLevel] [varchar](10) NULL,
	[IsSQL] [bit] NULL,
	[SQLVersion] [varchar](10) NULL,
	[SQLEdition] [varchar](5) NULL,
	[SQLServicePack] [varchar](10) NULL,
	[SQLBuild] [varchar](25) NULL,
	[IsCluster] [bit] NULL,
	[IsNew] [bit] NULL,
	[BackupManaged] [bit] NULL,
	[BackupProduct] [varchar](50) NULL,
	[BackupDefaultLoc] [varchar](1000) NULL,
	[DiskManaged] [bit] NULL,
	[IsServiceManaged] [bit] NULL,
	[SPConfigManaged] [bit] NULL,
	[IsActive] [bit] NULL,
	[IsActiveDate] [date] NULL,
	[InstanceMemInMB] [int] NULL,
	[OSVersion] [varchar](50) NULL,
	[OSServicePack] [varchar](10) NULL,
	[OSBuild] [varchar](25) NULL,
	[OSArchitecture] [tinyint] NULL,
	[CPUSockets] [tinyint] NULL,
	[CPUCores] [tinyint] NULL,
	[CPULogicalTotal] [int] NULL,
	[ServerMemInMB] [varchar](15) NULL,
	[Manufacturer] [nchar](100) NULL,
	[ServerModel] [varchar](50) NULL,
 CONSTRAINT [PK_Servers] PRIMARY KEY CLUSTERED 
(
	[InstanceID] ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Archive].[Servers]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Archive].[Servers](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[LocID] [int] NULL,
	[ServerName] [varchar](100) NULL,
	[DNS] [varchar](50) NULL,
	[IP] [char](15) NULL,
	[Port] [int] NULL,
	[Descr] [varchar](1000) NULL,
	[Role] [varchar](25) NULL,
	[ServiceLevel] [varchar](10) NULL,
	[IsSQL] [bit] NULL,
	[SQLVersion] [smallint] NULL,
	[SQLEdition] [varchar](5) NULL,
	[SQLServicePack] [varchar](10) NULL,
	[SQLBuild] [varchar](25) NULL,
	[IsCluster] [bit] NULL,
	[IsNew] [bit] NULL,
	[BackupManaged] [bit] NULL,
	[BackupProduct] [varchar](50) NULL,
	[BackupDefaultLoc] [varchar](1000) NULL,
	[DiskManaged] [bit] NULL,
	[IsServiceManaged] [bit] NULL,
	[SPConfigManaged] [bit] NULL,
	[IsActive] [bit] NULL,
	[IsActiveDate] [date] NULL,
	[InstanceMemInMB] [int] NULL,
	[OSVersion] [varchar](50) NULL,
	[OSServicePack] [varchar](10) NULL,
	[OSBuild] [varchar](25) NULL,
	[OSArchitecture] [tinyint] NULL,
	[CPUSockets] [tinyint] NULL,
	[CPUCores] [tinyint] NULL,
	[CPULogicalTotal] [int] NULL,
	[ServerMemInMB] [varchar](15) NULL,
	[Manufacturer] [nchar](100) NULL,
	[ServerModel] [varchar](50) NULL,
 CONSTRAINT [PK_Servers] PRIMARY KEY CLUSTERED 
(
	[InstanceID] ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[ServerRoleMember]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[ServerRoleMember](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[ServerRole] [varchar](50) NULL,
	[MemberName] [varchar](100) NULL,
 CONSTRAINT [pk_ServerRoleMember_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ServerRole]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ServerRole](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[AppID] [int] NULL,
	[ROLE] [varchar](25) NULL,
 CONSTRAINT [pk_ServerRole_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[DBProperties]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[DBProperties](
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[DBOwner] [varchar](100) NULL,
	[LastBackup] [datetime] NULL,
	[LastLogBackup] [datetime] NULL,
	[LastDiffBackup] [datetime] NULL,
	[AutoClose] [bit] NULL,
	[AutoShrink] [bit] NULL,
	[DBReadOnly] [bit] NULL,
	[Collation] [varchar](100) NULL,
	[CompatLevel] [varchar](10) NULL,
	[DefaultSchema] [varchar](100) NULL,
	[FullTxtEnabled] [bit] NULL,
	[RecoveryModel] [varchar](10) NULL,
	[CreateDate] [datetime] NULL,
	[CaseSensitive] [bit] NULL,
	[Status] [varchar](50) NULL,
	[ANSINullDefault] [bit] NULL,
	[ANSINullsEnabled] [bit] NULL,
	[ANSIPaddingEnabled] [bit] NULL,
	[ANSIWarningsEnabled] [bit] NULL,
	[ArithAbortEnabled] [bit] NULL,
	[AutoCreateIncrementalStatisticsEnabled] [bit] NULL,
	[AutoCreateStatisticsEnabled] [bit] NULL,
	[AutoUpdateStatisticsAsync] [bit] NULL,
	[AutoUpdateStatisticsEnabled] [bit] NULL,
	[AvailabilityDatabaseSynchronizationState] [bit] NULL,
	[AvailabilityGroupName] [bit] NULL,
	[BrokerEnabled] [bit] NULL,
	[ChangeTrackingAutoCleanUp] [bit] NULL,
	[ChangeTrackingEnabled] [bit] NULL,
	[ChangeTrackingRetentionPeriod] [int] NULL,
	[ChangeTrackingRetentionPeriodUnits] [varchar](20) NULL,
	[CloseCursorsOnCommitEnabled] [bit] NULL,
	[ConcatenateNullYieldsNull] [bit] NULL,
	[ContainmentType] [varchar](20) NULL,
	[DatabaseGuid] [uniqueidentifier] NULL,
	[DatabaseOwnershipChaining] [bit] NULL,
	[DatabaseSnapshotBaseName] [varchar](100) NULL,
	[DataSpaceUsage] [decimal](12, 2) NULL,
	[DateCorrelationOptimization] [bit] NULL,
	[DboLogin] [varchar](100) NULL,
	[DefaultFileGroup] [varchar](100) NULL,
	[DefaultFileStreamFileGroup] [varchar](100) NULL,
	[DefaultFullTextCatalog] [varchar](100) NULL,
	[DefaultFullTextLanguage] [varchar](100) NULL,
	[DefaultLanguage] [varchar](100) NULL,
	[DelayedDurability] [varchar](50) NULL,
	[EncryptionEnabled] [bit] NULL,
	[FilestreamDirectoryName] [varchar](100) NULL,
	[FilestreamNonTransactedAccess] [varchar](3) NULL,
	[HasFileInCloud] [bit] NULL,
	[HasMemoryOptimizedObjects] [bit] NULL,
	[HonorBrokerPriority] [bit] NULL,
	[IndexSpaceUsage] [decimal](12, 2) NULL,
	[IsAccessible] [bit] NULL,
	[IsDatabaseSnapshot] [bit] NULL,
	[IsDatabaseSnapshotBase] [bit] NULL,
	[IsFederationMember] [bit] NULL,
	[IsFullTextEnabled] [bit] NULL,
	[IsMailHost] [bit] NULL,
	[IsManagementDataWarehouse] [bit] NULL,
	[IsMirroringEnabled] [bit] NULL,
	[IsParameterizationForced] [bit] NULL,
	[IsReadCommittedSnapshotOn] [bit] NULL,
	[IsSystemObject] [bit] NULL,
	[IsUpdateable] [bit] NULL,
	[IsVarDecimalStorageFormatEnabled] [bit] NULL,
	[LocalCursorsDefault] [bit] NULL,
	[LogReuseWaitStatus] [varchar](50) NULL,
	[MemoryAllocatedToMemoryOptimizedObjectsInKB] [bigint] NULL,
	[MemoryUsedByMemoryOptimizedObjectsInKB] [bigint] NULL,
	[MirroringFailoverLogSequenceNumber] [decimal](25, 0) NULL,
	[MirroringID] [uniqueidentifier] NULL,
	[MirroringPartner] [sysname] NULL,
	[MirroringPartnerInstance] [sysname] NULL,
	[MirroringRedoQueueMaxSize] [bigint] NULL,
	[MirroringRoleSequence] [int] NULL,
	[MirroringSafetyLevel] [varchar](20) NULL,
	[MirroringSafetySequence] [int] NULL,
	[MirroringStatus] [varchar](10) NULL,
	[MirroringTimeout] [int] NULL,
	[MirroringWitness] [sysname] NULL,
	[MirroringWitnessStatus] [varchar](10) NULL,
	[NestedTriggersEnabled] [bit] NULL,
	[NumericRoundAbortEnabled] [bit] NULL,
	[PageVerify] [varchar](25) NULL,
	[PrimaryFilePath] [varchar](max) NULL,
	[QuotedIdentifiersEnabled] [bit] NULL,
	[ReadOnly] [bit] NULL,
	[RecoveryForkGuid] [uniqueidentifier] NULL,
	[RecursiveTriggersEnabled] [bit] NULL,
	[ServiceBrokerGuid] [uniqueidentifier] NULL,
	[SizeInMB] [decimal](12, 2) NULL,
	[SnapshotIsolationState] [varchar](100) NULL,
	[SpaceAvailableInKB] [decimal](12, 2) NULL,
	[State] [varchar](20) NULL,
	[TargetRecoveryTime] [int] NULL,
	[TransformNoiseWords] [bit] NULL,
	[Trustworthy] [bit] NULL,
	[TwoDigitYearCutoff] [smallint] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DBFilePropertiesConfig]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DBFilePropertiesConfig](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[DBFileID] [int] NULL,
	[DBFileName] [varchar](100) NULL,
	[FileType] [char](1) NULL,
	[IsAutoGrow] [bit] NULL,
	[AutoGrowType] [varchar](10) NULL,
	[AutoGrowValue] [bigint] NULL,
	[HasMaxSize] [bit] NULL,
	[MaxSizeType] [varchar](9) NULL,
	[MaxSizeValue] [bigint] NULL,
	[Push] [bit] NULL,
	[LastUpdate] [datetime] NULL,
 CONSTRAINT [pk_DBFilePropertiesConfig_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[DBFileProperties]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[DBFileProperties](
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[FileGroup] [varchar](100) NULL,
	[FileName] [varchar](100) NULL,
	[FullFileName] [varchar](100) NULL,
	[FileType] [char](1) NULL,
	[AvailableSpace] [bigint] NULL,
	[BytesReadFromDisk] [bigint] NULL,
	[BytesWrittenToDisk] [bigint] NULL,
	[Growth] [bigint] NULL,
	[GrowthType] [varchar](10) NULL,
	[FileID] [smallint] NULL,
	[IsOffline] [bit] NULL,
	[IsPrimaryFile] [bit] NULL,
	[IsReadOnly] [bit] NULL,
	[IsReadOnlyMedia] [bit] NULL,
	[IsSparse] [bit] NULL,
	[MaxSize] [bigint] NULL,
	[NumberOfDiskReads] [bigint] NULL,
	[NumberOfDiskWrites] [bigint] NULL,
	[Size] [bigint] NULL,
	[State] [varchar](50) NULL,
	[SpaceUsed] [bigint] NULL,
	[VolumeFreeSpace] [bigint] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DatabasesNew]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DatabasesNew](
	[DBId] [int] IDENTITY(1,1) NOT NULL,
	[DBName] [varchar](100) NULL,
	[InstanceID] [int] NULL,
	[Descr] [varchar](1000) NULL,
 CONSTRAINT [pk_DatabasesNew_DBId] PRIMARY KEY CLUSTERED 
(
	[DBId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BackupExclusionGlobal]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BackupExclusionGlobal](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DBName] [varchar](100) NULL,
	[Reason] [varchar](1000) NULL,
 CONSTRAINT [pk_BackupExclusionGlobal_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DBMaintTest]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DBMaintTest](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DBName] [varchar](100) NOT NULL,
	[InstanceID] [int] NOT NULL,
	[FullLocType] [varchar](20) NOT NULL,
	[FullPath] [varchar](1000) NOT NULL,
	[DiffLocType] [varchar](20) NOT NULL,
	[DiffPath] [varchar](1000) NOT NULL,
	[LogLocType] [varchar](20) NOT NULL,
	[LogPath] [varchar](1000) NOT NULL,
	[RetDays] [tinyint] NOT NULL,
	[Push] [bit] NOT NULL,
	[LastUpdate] [smalldatetime] NOT NULL,
	[BufferCount] [int] NOT NULL,
	[MaxTransferSize] [bigint] NOT NULL,
	[NumberOfFiles] [int] NOT NULL,
	[ExcludeFromBackup] [bit] NOT NULL,
	[ExcludeFromLogBackup] [bit] NOT NULL,
	[ExcludeFromCheckDB] [bit] NOT NULL,
	[CheckDBOptions] [varchar](100) NOT NULL,
	[BackupDeployedToServer] [date] NULL,
	[CheckDBDeployedToServer] [date] NULL,
 CONSTRAINT [pk_DBMaintTest_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DBMaintFuzzyLookup]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DBMaintFuzzyLookup](
	[InstanceID] [bigint] NULL,
	[Action] [varchar](10) NULL,
	[MaintType] [varchar](20) NULL,
	[Regex] [varchar](2000) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[DBMaintCT]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Collector].[DBMaintCT](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[CT] [int] NULL,
 CONSTRAINT [pk_DBMaintCT_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DBMaint]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DBMaint](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DBName] [varchar](100) NOT NULL,
	[InstanceID] [int] NOT NULL,
	[PrevFullLocType] [varchar](20) NULL,
	[PrevFullPath] [varchar](1000) NULL,
	[PrevFullDate] [datetime] NULL,
	[PrevFullMirrorLocType] [varchar](20) NULL,
	[PrevFullMirrorPath] [varchar](1000) NULL,
	[PrevFullMirrorDate] [datetime] NULL,
	[PrevDiffLocType] [varchar](20) NULL,
	[PrevDiffPath] [varchar](1000) NULL,
	[PrevDiffDate] [datetime] NULL,
	[PrevDiffMirrorLocType] [varchar](20) NULL,
	[PrevDiffMirrorPath] [varchar](1000) NULL,
	[PrevDiffMirrorDate] [datetime] NULL,
	[PrevLogLocType] [varchar](20) NULL,
	[PrevLogPath] [varchar](1000) NULL,
	[PrevLogDate] [datetime] NULL,
	[PrevLogMirrorLocType] [varchar](20) NULL,
	[PrevLogMirrorPath] [varchar](1000) NULL,
	[PrevLogMirrorDate] [datetime] NULL,
	[FullLocType] [varchar](20) NULL,
	[FullPath] [varchar](1000) NULL,
	[MirrorFullBackup] [bit] NULL,
	[FullMirrorLocType] [varchar](20) NULL,
	[FullMirrorPath] [varchar](100) NULL,
	[DiffLocType] [varchar](20) NULL,
	[DiffPath] [varchar](1000) NULL,
	[MirrorDiffBackup] [bit] NULL,
	[DiffMirrorLocType] [varchar](20) NULL,
	[DiffMirrorPath] [varchar](100) NULL,
	[LogLocType] [varchar](20) NULL,
	[LogPath] [varchar](1000) NULL,
	[MirrorLogBackup] [bit] NULL,
	[LogMirrorLocType] [varchar](20) NULL,
	[LogMirrorPath] [varchar](100) NULL,
	[BackupRetHrs] [tinyint] NULL,
	[BackupDelFileBefore] [bit] NOT NULL,
	[BackupDelFileBeforeAgree] [bit] NOT NULL,
	[BackupHIstoryRetDays] [int] NULL,
	[Push] [bit] NULL,
	[BufferCount] [int] NOT NULL,
	[MaxTransferSize] [bigint] NOT NULL,
	[NumberOfFiles] [int] NOT NULL,
	[NumberOfLogFiles] [int] NULL,
	[MultiDriveBackup] [bit] NULL,
	[ExcludeFromBackup] [bit] NOT NULL,
	[ExcludeFromDiffBackup] [bit] NOT NULL,
	[ExcludeFromLogBackup] [bit] NOT NULL,
	[ExcludeFromReindex] [bit] NULL,
	[ExcludeFromCheckDB] [bit] NOT NULL,
	[CheckDBOptions] [varchar](100) NOT NULL,
	[CheckDBRetWks] [smallint] NULL,
	[BackupGroupOrder] [tinyint] NULL,
	[BackupGroupDBOrder] [tinyint] NULL,
	[ReindexGroupOrder] [tinyint] NULL,
	[ReindexOrder] [int] NULL,
	[CheckDBGroupOrder] [tinyint] NULL,
	[CheckDBOrder] [int] NULL,
	[BackupLogging] [varchar](25) NULL,
	[ReindexLogging] [varchar](25) NULL,
	[BackupLoggingRetDays] [smallint] NULL,
	[ReindexLoggingRetDays] [smallint] NULL,
	[CheckDBLoggingRetDays] [smallint] NULL,
	[BackupLoggingPath] [varchar](1000) NULL,
	[ReindexLoggingPath] [varchar](1000) NULL,
	[CheckDBLoggingPath] [varchar](1000) NULL,
	[ReindexRecoveryModel] [varchar](12) NULL,
	[LastUpdate] [smalldatetime] NOT NULL,
	[BackupDeployedToServer] [date] NULL,
	[CheckDBDeployedToServer] [date] NULL,
	[BackupReport] [bit] NULL,
	[BackUpAlertThresholdHrs] [smallint] NULL,
	[LogBackupReport] [bit] NULL,
	[LogBackupAlertThresholdMins] [smallint] NULL,
	[IsTDE] [bit] NULL,
	[TDECertName] [varchar](100) NULL,
	[TDECertBackupLoc] [varchar](1000) NULL,
	[TDECertBackupPword] [varchar](100) NULL,
 CONSTRAINT [pk_DBMaint_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Archive].[DBMaint]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Archive].[DBMaint](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[DBName] [varchar](100) NOT NULL,
	[InstanceID] [int] NOT NULL,
	[PrevFullLocType] [varchar](20) NULL,
	[PrevFullPath] [varchar](1000) NULL,
	[PrevFullDate] [datetime] NULL,
	[PrevFullMirrorLocType] [varchar](20) NULL,
	[PrevFullMirrorPath] [varchar](1000) NULL,
	[PrevFullMirrorDate] [datetime] NULL,
	[PrevDiffLocType] [varchar](20) NULL,
	[PrevDiffPath] [varchar](1000) NULL,
	[PrevDiffDate] [datetime] NULL,
	[PrevDiffMirrorLocType] [varchar](20) NULL,
	[PrevDiffMirrorPath] [varchar](1000) NULL,
	[PrevDiffMirrorDate] [datetime] NULL,
	[PrevLogLocType] [varchar](20) NULL,
	[PrevLogPath] [varchar](1000) NULL,
	[PrevLogDate] [datetime] NULL,
	[PrevLogMirrorLocType] [varchar](20) NULL,
	[PrevLogMirrorPath] [varchar](1000) NULL,
	[PrevLogMirrorDate] [datetime] NULL,
	[FullLocType] [varchar](20) NULL,
	[FullPath] [varchar](1000) NULL,
	[MirrorFullBackup] [bit] NULL,
	[FullMirrorLocType] [varchar](20) NULL,
	[FullMirrorPath] [varchar](100) NULL,
	[DiffLocType] [varchar](20) NULL,
	[DiffPath] [varchar](1000) NULL,
	[MirrorDiffBackup] [bit] NULL,
	[DiffMirrorLocType] [varchar](20) NULL,
	[DiffMirrorPath] [varchar](100) NULL,
	[LogLocType] [varchar](20) NULL,
	[LogPath] [varchar](1000) NULL,
	[MirrorLogBackup] [bit] NULL,
	[LogMirrorLocType] [varchar](20) NULL,
	[LogMirrorPath] [varchar](100) NULL,
	[BackupRetHrs] [tinyint] NULL,
	[BackupDelFileBefore] [bit] NOT NULL,
	[BackupDelFileBeforeAgree] [bit] NOT NULL,
	[Push] [bit] NULL,
	[BufferCount] [int] NOT NULL,
	[MaxTransferSize] [bigint] NOT NULL,
	[NumberOfFiles] [int] NOT NULL,
	[NumberOfLogFiles] [int] NULL,
	[MultiDriveBackup] [bit] NULL,
	[ExcludeFromBackup] [bit] NOT NULL,
	[ExcludeFromDiffBackup] [bit] NOT NULL,
	[ExcludeFromLogBackup] [bit] NOT NULL,
	[ExcludeFromReindex] [bit] NULL,
	[ExcludeFromCheckDB] [bit] NOT NULL,
	[CheckDBOptions] [varchar](100) NOT NULL,
	[CheckDBRetWks] [smallint] NULL,
	[BackupGroupOrder] [tinyint] NULL,
	[BackupGroupDBOrder] [tinyint] NULL,
	[ReindexGroupOrder] [tinyint] NULL,
	[ReindexOrder] [int] NULL,
	[CheckDBGroupOrder] [tinyint] NULL,
	[CheckDBOrder] [int] NULL,
	[BackupLogging] [varchar](25) NULL,
	[ReindexLogging] [varchar](25) NULL,
	[BackupLoggingRetDays] [smallint] NULL,
	[ReindexLoggingRetDays] [smallint] NULL,
	[CheckDBLoggingRetDays] [smallint] NULL,
	[BackupLoggingPath] [varchar](1000) NULL,
	[ReindexLoggingPath] [varchar](1000) NULL,
	[CheckDBLoggingPath] [varchar](1000) NULL,
	[ReindexRecoveryModel] [varchar](12) NULL,
	[LastUpdate] [smalldatetime] NOT NULL,
	[BackupDeployedToServer] [date] NULL,
	[CheckDBDeployedToServer] [date] NULL,
	[BackupReport] [bit] NULL,
	[BackUpAlertThresholdHrs] [smallint] NULL,
	[LogBackupReport] [bit] NULL,
	[LogBackupAlertThresholdMins] [smallint] NULL,
	[IsTDE] [bit] NULL,
	[TDECertName] [varchar](100) NULL,
	[TDECertBackupLoc] [varchar](1000) NULL,
	[TDECertBackupPword] [varchar](100) NULL,
 CONSTRAINT [pk_DBMaint_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Archive].[ConfigLog]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Archive].[ConfigLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[TableName] [sysname] NOT NULL,
	[ArchiveDays] [int] NULL,
	[RowsInBatch] [int] NULL,
	[RowsDeleted] [bigint] NULL,
	[DeleteBeginDateTime] [datetime] NULL,
	[DeleteEndDateTime] [datetime] NULL,
	[DeleteRunTimeInSecs] [int] NULL,
 CONSTRAINT [pk_ConfigLog_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Archive].[Config]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Archive].[Config](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[TableName] [sysname] NOT NULL,
	[ArchiveDays] [int] NULL,
	[RowsInBatch] [int] NULL,
 CONSTRAINT [pk_Config_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ClusterNode]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ClusterNode](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[LocID] [int] NULL,
	[ServerName] [varchar](100) NULL,
	[DNS] [varchar](50) NULL,
	[IP] [char](15) NULL,
	[WinClusterName] [varchar](100) NULL,
	[WinClusterIP] [varchar](20) NULL,
 CONSTRAINT [PK_ClusterNode] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[CheckDBResult]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[CheckDBResult](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[ExecutionDateTime] [datetime] NULL,
	[DBName] [varchar](100) NULL,
	[BeginTime] [datetime] NULL,
	[EndTime] [datetime] NULL,
	[Error] [int] NULL,
	[Level] [int] NULL,
	[State] [int] NULL,
	[MessageText] [varchar](7000) NULL,
	[RepairLevel] [int] NULL,
	[Status] [int] NULL,
	[DbId] [int] NULL,
	[cId] [int] NULL,
	[IndId] [int] NULL,
	[PartitionId] [int] NULL,
	[AllocUnitId] [int] NULL,
	[File] [int] NULL,
	[Page] [int] NULL,
	[Slot] [int] NULL,
	[RefFile] [int] NULL,
	[RefPage] [int] NULL,
	[RefSlot] [int] NULL,
	[Allocation] [int] NULL,
	[Managed] [bit] NULL,
 CONSTRAINT [pk_CheckDBResult_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[Databases]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[Databases](
	[DBId] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[DBSizeOnDiskInMB] [decimal](12, 2) NULL,
	[Descr] [varchar](1000) NULL,
 CONSTRAINT [PK_Databases] PRIMARY KEY CLUSTERED 
(
	[DBId] ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[CertificateServer]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[CertificateServer](
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[name] [sysname] NOT NULL,
	[certificate_id] [int] NOT NULL,
	[principal_id] [int] NULL,
	[pvt_key_encryption_type] [char](2) NOT NULL,
	[pvt_key_encryption_type_desc] [nvarchar](60) NULL,
	[is_active_for_begin_dialog] [bit] NULL,
	[issuer_name] [nvarchar](442) NULL,
	[cert_serial_number] [nvarchar](64) NULL,
	[sid] [varbinary](85) NULL,
	[string_sid] [nvarchar](128) NULL,
	[subject] [nvarchar](4000) NULL,
	[expiry_date] [datetime] NULL,
	[start_date] [datetime] NULL,
	[thumbprint] [varbinary](32) NOT NULL,
	[attested_by] [nvarchar](260) NULL,
	[pvt_key_last_backup_date] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[CertificateDatabase]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[CertificateDatabase](
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[name] [sysname] NOT NULL,
	[certificate_id] [int] NOT NULL,
	[principal_id] [int] NULL,
	[pvt_key_encryption_type] [char](2) NOT NULL,
	[pvt_key_encryption_type_desc] [nvarchar](60) NULL,
	[is_active_for_begin_dialog] [bit] NULL,
	[issuer_name] [nvarchar](442) NULL,
	[cert_serial_number] [nvarchar](64) NULL,
	[sid] [varbinary](85) NULL,
	[string_sid] [nvarchar](128) NULL,
	[subject] [nvarchar](4000) NULL,
	[expiry_date] [datetime] NULL,
	[start_date] [datetime] NULL,
	[thumbprint] [varbinary](32) NOT NULL,
	[attested_by] [nvarchar](260) NULL,
	[pvt_key_last_backup_date] [datetime] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [History].[BackupLog]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [History].[BackupLog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[ServiceLevel] [varchar](10) NULL,
	[ServerName] [varchar](100) NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[LastLogBackup] [datetime] NULL,
	[DBReadOnly] [bit] NULL,
	[LogBackupAlertThresholdMins] [smallint] NULL,
	[PrevLogPath] [varchar](1000) NULL,
	[LogPath] [varchar](1000) NULL,
 CONSTRAINT [pk_BackupLog_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[BlockedProcessesHistory]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Collector].[BlockedProcessesHistory](
	[RowID] [bigint] NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
	[SPID] [int] NOT NULL,
	[BlockedBySPID] [int] NOT NULL,
	[LastBatchDate] [datetime] NOT NULL,
	[ExecutionDate] [datetime] NOT NULL,
	[PSrunDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [Collector].[BlockedProcesses]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Collector].[BlockedProcesses](
	[RowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ServerName] [nvarchar](128) NOT NULL,
	[SPID] [int] NOT NULL,
	[BlockedBySPID] [int] NOT NULL,
	[LastBatchDate] [datetime] NOT NULL,
	[ExecutionDate] [datetime] NOT NULL,
	[PSrunDate] [datetime] NOT NULL,
 CONSTRAINT [pk_BlockedProcesses_RowID] PRIMARY KEY CLUSTERED 
(
	[RowID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Collector].[ADGroupMember]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[ADGroupMember](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[GroupName] [nvarchar](200) NULL,
	[ObjectName] [nvarchar](200) NULL,
	[IsGroup] [bit] NULL,
	[GroupMember] [varchar](100) NULL,
	[LastLogon] [datetime] NULL,
	[BadLogonCount] [bigint] NULL,
	[PasswordNeverExpires] [bit] NULL,
	[PasswordNotRequired] [bit] NULL,
	[PermittedLogonTimes] [bigint] NULL,
	[PermittedWorkstations] [varchar](max) NULL,
	[LastPasswordSet] [datetime] NULL,
	[LastBadPasswordAttempt] [nchar](10) NULL,
	[UserCannotChangePassword] [nchar](10) NULL,
	[Description] [nvarchar](max) NULL,
	[DelegationPermitted] [bit] NULL,
	[AccountExpirationDate] [datetime] NULL,
	[AccountLockoutTime] [datetime] NULL,
	[EmailAddress] [nvarchar](500) NULL,
	[Enabled] [bit] NULL,
	[EmployeeID] [nvarchar](200) NULL,
	[VoiceTelephoneNumber] [varchar](100) NULL,
	[DistinguishedName] [nvarchar](2000) NULL,
	[DisplayName] [nvarchar](2000) NULL,
	[SurName] [nvarchar](100) NULL,
	[MiddleName] [nvarchar](100) NULL,
	[GivenName] [nvarchar](100) NULL,
	[Name] [nvarchar](200) NULL,
	[GUID] [varchar](200) NULL,
	[SID] [varchar](200) NULL,
	[SmartcardLogonRequired] [nchar](10) NULL,
	[HomeDirectory] [nvarchar](2000) NULL,
	[HomeDrive] [nvarchar](2000) NULL,
	[AllowReversiblePasswordEncryption] [bit] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE CLUSTERED INDEX [clustExecDateInstance] ON [Collector].[ADGroupMember] 
(
	[ExecutionDateTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nonGroupObject] ON [Collector].[ADGroupMember] 
(
	[GroupName] ASC,
	[ObjectName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nonObjectGroup] ON [Collector].[ADGroupMember] 
(
	[ObjectName] ASC,
	[GroupName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Table [Alert].[BackupDefer]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Alert].[BackupDefer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[BackupType] [varchar](10) NULL,
	[DeferDate] [date] NULL,
	[DeferEndDate] [date] NULL,
	[DeferEndTime] [time](7) NULL,
 CONSTRAINT [pk_BackupDefer_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[BackupHistory]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[BackupHistory](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [bigint] NULL,
	[DBName] [varchar](25) NULL,
	[BackupType] [varchar](10) NULL,
	[BatchDateTime] [datetime] NULL,
	[BackupStartTime] [datetime] NULL,
	[BackupEndTime] [datetime] NULL,
	[TotalTimeinSec] [numeric](15, 2) NULL,
	[BackupCmd] [varchar](4000) NULL,
	[SizeInMB] [numeric](15, 3) NULL,
 CONSTRAINT [pk_BackupHistory_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [History].[BackupFullorDiff]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [History].[BackupFullorDiff](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[ServiceLevel] [varchar](10) NULL,
	[ServerName] [varchar](100) NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[LastBackup] [datetime] NULL,
	[DBReadOnly] [bit] NULL,
	[BackupalertthresholdHrs] [smallint] NULL,
	[PrevFullPath] [varchar](1000) NULL,
	[FullPath] [varchar](1000) NULL,
 CONSTRAINT [pk_BackupFullorDiff_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AppOwner]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AppOwner](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AppID] [int] NULL,
	[SupportPersonID] [int] NULL,
 CONSTRAINT [pk_AppOwner_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ApplicationRole]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ApplicationRole](
	[AppRoleID] [int] IDENTITY(1,1) NOT NULL,
	[AppRoleName] [varchar](100) NULL,
 CONSTRAINT [PK_ApplicationRole] PRIMARY KEY CLUSTERED 
(
	[AppRoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ApplicationEnvironment]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ApplicationEnvironment](
	[AppEnvID] [int] IDENTITY(1,1) NOT NULL,
	[AppEnvName] [varchar](100) NULL,
 CONSTRAINT [PK_ApplicationEnvRole] PRIMARY KEY NONCLUSTERED 
(
	[AppEnvID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Application]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Application](
	[AppID] [int] IDENTITY(1,1) NOT NULL,
	[AppName] [varchar](100) NULL,
	[Desc] [varchar](2000) NULL,
	[ContactName] [varchar](100) NULL,
	[ManagerName] [varchar](100) NULL,
	[DirectorName] [varchar](100) NULL,
 CONSTRAINT [PK_Application] PRIMARY KEY CLUSTERED 
(
	[AppID] ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [History].[InstanceConfig]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [History].[InstanceConfig](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[ServerName] [varchar](100) NULL,
	[Name] [varchar](100) NULL,
	[DesiredValue] [int] NULL,
	[RunValue] [int] NULL,
	[ExecutionDateTime] [datetime] NULL,
	[ServiceLevel] [varchar](10) NULL,
	[Action] [varchar](25) NULL,
	[AppName] [varchar](100) NULL,
 CONSTRAINT [pk_InstanceConfig_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[InstanceConfig]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[InstanceConfig](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[Name] [varchar](50) NULL,
	[Minimum] [int] NULL,
	[Maximum] [int] NULL,
	[ConfigValue] [int] NULL,
	[RunValue] [int] NULL,
 CONSTRAINT [pk_InstanceConfig_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IndexSettingsTable]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IndexSettingsTable](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [bigint] NULL,
	[DBName] [sysname] NOT NULL,
	[SchemaName] [varchar](100) NOT NULL,
	[TableName] [sysname] NOT NULL,
	[Exclude] [bit] NULL,
	[ReindexGroupOrder] [int] NULL,
	[ReindexOrder] [int] NULL,
	[ReorgThreshold] [tinyint] NULL,
	[RebuildThreshold] [tinyint] NULL,
	[FILLFACTORopt] [tinyint] NULL,
	[PadIndex] [varchar](3) NULL,
	[ONLINEopt] [varchar](3) NULL,
	[SortInTempDB] [varchar](3) NULL,
	[MAXDOPopt] [tinyint] NULL,
	[DataCompression] [varchar](50) NULL,
	[GetRowCT] [bit] NULL,
	[GetPostFragLevel] [bit] NULL,
	[UpdateStatsOnDefrag] [bit] NULL,
	[StatScanOption] [varchar](25) NULL,
	[IgnoreDupKey] [varchar](3) NULL,
	[StatsNoRecompute] [varchar](3) NULL,
	[AllowRowLocks] [varchar](3) NULL,
	[AllowPageLocks] [varchar](3) NULL,
	[WaitAtLowPriority] [bit] NULL,
	[MaxDurationInMins] [int] NULL,
	[AbortAfterWait] [varchar](20) NULL,
	[PushToMinion] [bit] NULL,
	[LogIndexPhysicalStats] [bit] NULL,
	[IndexScanMode] [varchar](25) NULL,
	[TablePreCode] [varchar](max) NULL,
	[TablePostCode] [varchar](max) NULL,
	[LogProgress] [bit] NULL,
	[LogRetDays] [smallint] NULL,
	[PartitionReindex] [bit] NULL,
	[isLOB] [bit] NULL,
	[TableType] [char](1) NULL,
	[IncludeUsageDetails] [bit] NULL,
	[Push] [bit] NULL,
	[LastUpdate] [datetime] NULL,
 CONSTRAINT [pk_IndexSettingsTable_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE UNIQUE NONCLUSTERED INDEX [uninonInstanceDBSchemaTable] ON [dbo].[IndexSettingsTable] 
(
	[InstanceID] ASC,
	[DBName] ASC,
	[SchemaName] ASC,
	[TableName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InstanceConfigValue]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[InstanceConfigValue](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[Name] [varchar](50) NULL,
	[DesiredValue] [bigint] NULL,
	[IsAdvancedOption] [bit] NULL,
	[Push] [bit] NULL,
	[Action] [varchar](25) NOT NULL,
 CONSTRAINT [pk_InstanceConfigValue_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Location]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Location](
	[LocID] [int] IDENTITY(1,1) NOT NULL,
	[LocName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Location] PRIMARY KEY CLUSTERED 
(
	[LocID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[License]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[License](
	[KeyType] [varchar](50) NULL,
	[InstallDate] [date] NULL,
	[ExpireDate] [date] NULL,
	[TrialLength] [smallint] NULL,
	[DaysLeftInTrial] [int] NULL,
	[KeyHash] [nvarchar](500) NULL,
	[LicensedServers] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[IndexMaintLogDetails]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[IndexMaintLogDetails](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NOT NULL,
	[BatchExecutionDateTime] [datetime] NULL,
	[InstanceID] [bigint] NULL,
	[DBName] [sysname] NOT NULL,
	[Status] [varchar](500) NULL,
	[TableID] [bigint] NULL,
	[SchemaName] [sysname] NULL,
	[TableName] [sysname] NULL,
	[IndexID] [int] NULL,
	[IndexName] [sysname] NULL,
	[IndexTypeDesc] [varchar](50) NULL,
	[IndexScanMode] [varchar](25) NULL,
	[Op] [varchar](10) NULL,
	[ONLINEopt] [varchar](3) NULL,
	[ReorgThreshold] [tinyint] NULL,
	[RebuildThreshold] [tinyint] NULL,
	[FILLFACTORopt] [tinyint] NULL,
	[PadIndex] [varchar](3) NULL,
	[FragLevel] [tinyint] NULL,
	[Stmt] [nvarchar](1000) NULL,
	[ReindexGroupOrder] [int] NULL,
	[ReindexOrder] [int] NULL,
	[PreCode] [varchar](max) NULL,
	[PostCode] [varchar](max) NULL,
	[OpBeginDateTime] [datetime] NULL,
	[OpEndDateTime] [datetime] NULL,
	[OpRunTimeInSecs] [int] NULL,
	[TableRowCTBeginDateTime] [datetime] NULL,
	[TableRowCTEndDateTime] [datetime] NULL,
	[TableRowCTTimeInSecs] [int] NULL,
	[TableRowCT] [bigint] NULL,
	[PostFragBeginDateTime] [datetime] NULL,
	[PostFragEndDateTime] [datetime] NULL,
	[PostFragTimeInSecs] [int] NULL,
	[PostFragLevel] [tinyint] NULL,
	[UpdateStatsBeginDateTime] [datetime] NULL,
	[UpdateStatsEndDateTime] [datetime] NULL,
	[UpdateStatsTimeInSecs] [int] NULL,
	[UpdateStatsStmt] [varchar](1000) NULL,
	[PreCodeBeginDateTime] [datetime] NULL,
	[PreCodeEndDateTime] [datetime] NULL,
	[PreCodeRunTimeInSecs] [int] NULL,
	[PostCodeBeginDateTime] [datetime] NULL,
	[PostCodeEndDateTime] [datetime] NULL,
	[PostCodeRunTimeInSecs] [bigint] NULL,
	[UserSeeks] [bigint] NULL,
	[UserScans] [bigint] NULL,
	[UserLookups] [bigint] NULL,
	[UserUpdates] [bigint] NULL,
	[LastUserSeek] [datetime] NULL,
	[LastUserScan] [datetime] NULL,
	[LastUserLookup] [datetime] NULL,
	[LastUserUpdate] [datetime] NULL,
	[SystemSeeks] [bigint] NULL,
	[SystemScans] [bigint] NULL,
	[SystemLookups] [bigint] NULL,
	[SystemUpdates] [bigint] NULL,
	[LastSystemSeek] [datetime] NULL,
	[LastSystemScan] [datetime] NULL,
	[LastSystemLookup] [datetime] NULL,
	[LastSystemUpdate] [datetime] NULL,
	[Warnings] [varchar](max) NULL,
 CONSTRAINT [pk_IndexMaintLogDetails_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Alert].[IndexMaintReportSettingsServer]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Alert].[IndexMaintReportSettingsServer](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[InstanceID] [bigint] NULL,
	[IndexReport] [bit] NULL,
	[ReindexThresholdHrs] [int] NULL,
	[ExceededMins] [int] NULL,
 CONSTRAINT [pk_IndexMaintReportSettingsServer_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Alert].[IndexMaintReportSettingsDB]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Alert].[IndexMaintReportSettingsDB](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[InstanceID] [bigint] NULL,
	[IndexReport] [bit] NULL,
	[DBName] [sysname] NOT NULL,
	[ReindexThresholdHrs] [int] NULL,
	[ExceededMins] [int] NULL,
 CONSTRAINT [pk_IndexMaintReportSettingsDB_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IndexSettingsDB]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IndexSettingsDB](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [bigint] NOT NULL,
	[DBName] [sysname] NOT NULL,
	[Exclude] [bit] NULL,
	[ReindexGroupOrder] [tinyint] NULL,
	[ReindexOrder] [int] NULL,
	[ReorgThreshold] [tinyint] NULL,
	[RebuildThreshold] [tinyint] NULL,
	[FILLFACTORopt] [tinyint] NULL,
	[PadIndex] [varchar](3) NULL,
	[ONLINEopt] [varchar](3) NULL,
	[SortInTempDB] [varchar](3) NULL,
	[MAXDOPopt] [tinyint] NULL,
	[DataCompression] [varchar](50) NULL,
	[GetRowCT] [bit] NULL,
	[GetPostFragLevel] [bit] NULL,
	[UpdateStatsOnDefrag] [bit] NULL,
	[StatScanOption] [varchar](25) NULL,
	[IgnoreDupKey] [varchar](3) NULL,
	[StatsNoRecompute] [varchar](3) NULL,
	[AllowRowLocks] [varchar](3) NULL,
	[AllowPageLocks] [varchar](3) NULL,
	[WaitAtLowPriority] [bit] NULL,
	[MaxDurationInMins] [int] NULL,
	[AbortAfterWait] [varchar](20) NULL,
	[PushToMinion] [bit] NULL,
	[LogIndexPhysicalStats] [bit] NULL,
	[IndexScanMode] [varchar](25) NULL,
	[DBPreCode] [nvarchar](max) NULL,
	[DBPostCode] [nvarchar](max) NULL,
	[TablePreCode] [nvarchar](max) NULL,
	[TablePostCode] [nvarchar](max) NULL,
	[LogProgress] [bit] NULL,
	[LogRetDays] [smallint] NULL,
	[LogLoc] [varchar](25) NULL,
	[MinionTriggerPath] [varchar](1000) NULL,
	[RecoveryModel] [varchar](12) NULL,
	[IncludeUsageDetails] [bit] NULL,
	[Push] [bit] NULL,
	[LastUpdate] [datetime] NULL,
 CONSTRAINT [pk_IndexSettingsDB_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IndexSettingsDBDefault]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IndexSettingsDBDefault](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [bigint] NOT NULL,
	[DBName] [sysname] NOT NULL,
	[Exclude] [bit] NULL,
	[ReindexGroupOrder] [tinyint] NULL,
	[ReindexOrder] [int] NULL,
	[ReorgThreshold] [tinyint] NULL,
	[RebuildThreshold] [tinyint] NULL,
	[FILLFACTORopt] [tinyint] NULL,
	[PadIndex] [varchar](3) NULL,
	[ONLINEopt] [varchar](3) NULL,
	[SortInTempDB] [varchar](3) NULL,
	[MAXDOPopt] [tinyint] NULL,
	[DataCompression] [varchar](50) NULL,
	[GetRowCT] [bit] NULL,
	[GetPostFragLevel] [bit] NULL,
	[UpdateStatsOnDefrag] [bit] NULL,
	[StatScanOption] [varchar](25) NULL,
	[IgnoreDupKey] [varchar](3) NULL,
	[StatsNoRecompute] [varchar](3) NULL,
	[AllowRowLocks] [varchar](3) NULL,
	[AllowPageLocks] [varchar](3) NULL,
	[WaitAtLowPriority] [bit] NULL,
	[MaxDurationInMins] [int] NULL,
	[AbortAfterWait] [varchar](20) NULL,
	[PushToMinion] [bit] NULL,
	[LogIndexPhysicalStats] [bit] NULL,
	[IndexScanMode] [varchar](25) NULL,
	[DBPreCode] [nvarchar](max) NULL,
	[DBPostCode] [nvarchar](max) NULL,
	[TablePreCode] [nvarchar](max) NULL,
	[TablePostCode] [nvarchar](max) NULL,
	[LogProgress] [bit] NULL,
	[LogRetDays] [smallint] NULL,
	[LogLoc] [varchar](25) NULL,
	[MinionTriggerPath] [varchar](1000) NULL,
	[RecoveryModel] [varchar](12) NULL,
	[IncludeUsageDetails] [bit] NULL,
	[Push] [bit] NULL,
	[LastUpdate] [datetime] NULL,
 CONSTRAINT [pk_IndexSettingsDBDefault_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE UNIQUE NONCLUSTERED INDEX [uninonInstanceDBName] ON [dbo].[IndexSettingsDBDefault] 
(
	[InstanceID] ASC,
	[DBName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IndexMaint]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IndexMaint](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[SchemaName] [varchar](100) NULL,
	[TableName] [varchar](100) NULL,
	[ExcludeFromReindex] [bit] NULL,
	[ReorgThreshold] [tinyint] NULL,
	[ReindexThreshold] [tinyint] NULL,
	[FILLFACTORopt] [tinyint] NULL,
	[PadIndex] [varchar](3) NULL,
	[ONLINEopt] [varchar](3) NULL,
	[SortInTempDB] [varchar](3) NULL,
	[MAXDOPopt] [tinyint] NULL,
	[DataCompression] [varchar](4) NULL,
	[PartitionReindex] [bit] NULL,
	[isLOB] [bit] NULL,
	[TableType] [char](1) NULL,
	[GroupOrder] [int] NULL,
	[ReindexOrder] [int] NULL,
	[GetRowCount] [bit] NULL,
	[GetPostFragLevel] [bit] NULL,
	[UpdateStatsOnDefrag] [bit] NULL,
	[StatScanOption] [varchar](25) NULL,
	[Push] [bit] NULL,
	[LastUpdate] [datetime] NULL,
 CONSTRAINT [pk_IndexMaint_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[IndexMaintLog]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[IndexMaintLog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[BatchExecutionDateTime] [datetime] NULL,
	[InstanceID] [bigint] NULL,
	[DBName] [varchar](100) NULL,
	[Status] [varchar](500) NULL,
	[Tables] [varchar](7) NULL,
	[RunPrepped] [bit] NULL,
	[PrepOnly] [bit] NULL,
	[ReorgMode] [varchar](7) NULL,
	[NumTablesProcessed] [int] NULL,
	[NumIndexesProcessed] [int] NULL,
	[NumIndexesRebuilt] [int] NULL,
	[NumIndexesReorged] [int] NULL,
	[RecoveryModelChanged] [bit] NULL,
	[RecoveryModelCurrent] [varchar](12) NULL,
	[RecoveryModelReindex] [varchar](12) NULL,
	[SQLVersion] [varchar](20) NULL,
	[SQLEdition] [varchar](50) NULL,
	[DBPreCode] [nvarchar](max) NULL,
	[DBPostCode] [nvarchar](max) NULL,
	[DBPreCodeBeginDateTime] [datetime] NULL,
	[DBPreCodeEndDateTime] [datetime] NULL,
	[DBPostCodeBeginDateTime] [datetime] NULL,
	[DBPostCodeEndDateTime] [datetime] NULL,
	[DBPreCodeRunTimeInSecs] [int] NULL,
	[DBPostCodeRunTimeInSecs] [int] NULL,
	[ExecutionFinishTime] [datetime] NULL,
	[ExecutionRunTimeInSecs] [int] NULL,
	[IncludeDBs] [varchar](max) NULL,
	[ExcludeDBs] [varchar](max) NULL,
	[RegexDBsIncluded] [varchar](max) NULL,
	[RegexDBsExcluded] [varchar](max) NULL,
	[Warnings] [varchar](max) NULL,
 CONSTRAINT [pk_IndexMaintLog_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Alert].[IndexDefer]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Alert].[IndexDefer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[DBName] [sysname] NULL,
	[DeferEndDate] [date] NULL,
	[DeferEndTime] [time](7) NULL,
 CONSTRAINT [pk_IndexDefer_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GlobalDBBackupExceptions]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GlobalDBBackupExceptions](
	[DBName] [varchar](100) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[FileGrowthRate]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[FileGrowthRate](
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[FileGroup] [varchar](100) NULL,
	[FileName] [varchar](100) NULL,
	[Growth] [varchar](10) NULL,
	[GrowthType] [varchar](10) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [DM].[spGlobalInsertPackageRunStats]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [DM].[spGlobalInsertPackageRunStats]
(
@InstanceID int, 
@PackID int, 
@Region int, 
@ETLCycle smalldatetime, 
@RunStart smalldatetime, 
@RunEnd smalldatetime, 
@ElapsedTime int, 
@Result tinyint,
@Handler varchar(25)
)

  
AS

Insert DM.ETLGlobalDMStats (InstanceID, PackID, Region, ETLCycle, RunStart, RunEnd, ElapsedTime, Result, Handler)
values( @InstanceID, @PackID, @Region, @ETLCycle, @RunStart, @RunEnd, @ElapsedTime, @Result, @Handler)




;
GO
/****** Object:  StoredProcedure [DM].[spGlobalDMUpdatePackageStats]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [DM].[spGlobalDMUpdatePackageStats]
(
@InstanceID int,
@PackID int,
@Status int,
@ETLCycle smalldatetime,
@StartTime smalldatetime
)

  
AS

Update DM.ETLGlobalDMPackages
Set Status = @Status,
	StartTime = @StartTime,
	LastETLCycle = @ETLCycle

	where (InstanceID = @InstanceID
	and PackID = @PackID)




;
GO
/****** Object:  StoredProcedure [DM].[spGlobalDMSetEnv]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [DM].[spGlobalDMSetEnv]
(
@ETLCycle smalldatetime,
@InstanceID int
)

  
AS

UPDATE DM.ETLGlobalDMPackages
SET Status = 0,
	CurrentETLCycle = @ETLCycle
WHERE InstanceID = @InstanceID




;
GO
/****** Object:  Table [Collector].[Errors]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[Errors](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CollectionName] [varchar](1000) NULL,
	[StepName] [varchar](100) NULL,
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[TableName] [varchar](100) NULL,
	[StepDetail] [varchar](max) NULL,
	[Error] [varchar](max) NULL,
	[ScriptPath] [varchar](1000) NULL,
 CONSTRAINT [pk_Errors_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ErrorLogSearchServerExceptions]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ErrorLogSearchServerExceptions](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [bigint] NULL,
	[ErrorSearchID] [int] NULL,
 CONSTRAINT [pk_ErrorLogSearchServerExceptions_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [History].[DriveFreeSpace]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [History].[DriveFreeSpace](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ServerName] [varchar](100) NULL,
	[DriveName] [varchar](1) NULL,
	[SpaceFreeIn%] [decimal](9, 3) NULL,
	[FreeInGB] [decimal](9, 3) NULL,
	[ExecutionDateTime] [datetime] NULL,
	[ServiceLevel] [varchar](10) NULL,
	[AlertThreshold] [decimal](9, 3) NULL,
 CONSTRAINT [pk_DriveFreeSpace_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [DM].[DMCurrentStatusRollup]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DM Stats:
Pull back rollup stats for running DM status.
Region, run status, % complete, current run duration, avg run duration, packages finished/total packages,
current errors.

Consider graying out regions that have finished.

Consider doing deviations from avg, and maybe max and min too... these deviations can help with
projections and error reporting.

*/

CREATE Procedure [DM].[DMCurrentStatusRollup]
(
@Days int
)

  
AS

SET NOCOUNT ON

--------------------------
--------------------------

DECLARE @CurrentRunTime varchar(10)





--------------------------
--------------------------
--Get Regions that are currently running.

Select E.InstanceID, 
(
select count(*) from DM.ETLGlobalDMPackages 
	where Active = 1 AND Status = 0 or Status = 1
	AND InstanceID = E.InstanceID
) AS Running,--this is actually running or waiting to run.
(
select count(*) from DM.ETLGlobalDMPackages 
	where Active = 1 AND Status > 1
	AND InstanceID = E.InstanceID
) AS Finished,--these are just finished packages.  currently running packages don't count.
(
select count(*) from DM.ETLGlobalDMPackages 
	where Active = 1 AND Status = 3
	AND InstanceID = E.InstanceID
) AS Errors,
(
select count(*) from DM.ETLGlobalDMPackages 
	where Active = 1
	AND InstanceID = E.InstanceID
) AS Total
INTO #CurrentRunningRegions
from DM.ETLGlobalDMPackages E
GROUP BY InstanceID


--------------------------
--Get run times for given period.  

Select InstanceID, ETLCycle, DateDiff(mi,MIN(RunStart),MAX(RunEnd)) AS [AVGTime]
INTO #AVGTime
 from DM.ETLGlobalDMStats E 
where 
 E.RunStart BETWEEN convert(varchar(10), GetDate() - @Days, 101) 
					AND convert(varchar(10), GetDate(), 101)
Group By InstanceID, ETLCycle
ORDER BY InstanceID ASC, ETLCycle DESC

--select * from #avgtime
---------------------------

---------------------------
------Main Query-----------
---------------------------

---ETLCycle Durations
select ES.Region, convert(varchar(10), ETLCycle, 101) AS ETLCycle,

--Current Status
CASE --Checking for 4 conditions
	WHEN (E.Running > 0 AND E.Errors = 0) THEN 'Good' --Currently running w/o errors.
	WHEN (E.Running > 0 AND E.Errors > 0) THEN 'Error' --Currently running w/ errors.
	WHEN (E.Running = 0 AND E.Errors = 0) THEN 'Done' --Finished w/o errors.
	WHEN (E.Running = 0 AND E.Errors > 0) THEN 'DoneError' --Finished w errors.
END AS Status,

		--Current Runtime

	CASE
		WHEN E.Running > 0 THEN 
							(
							select DateDiff(mi,MIN(RunStart),GetDate())
							from DM.ETLGlobalDMStats where InstanceID = P.InstanceID
							) 
		ELSE '-'
	END
 AS 'CurrentRunTime(Mins)',

--% Time. 
(
(select DateDiff(mi,MIN(RunStart),GetDate())from DM.ETLGlobalDMStats where InstanceID = P.InstanceID)
/														 
(Select MAX(AvgTime) from #AVGTime where convert(varchar(10), AvgTime, 101) NOT IN (Select convert(varchar(10), CurrentETLCycle, 101) from DM.ETLGlobalDMPackages)
)*100
--AND InstanceID = P.InstanceID
)
 as [% Complete],


-- # Packages run so far.

CAST(E.Finished AS varchar(5)) + '/' + CAST(E.Total as varchar(5)) AS Pkg,

--Last RunTime. 
(Select MAX(AvgTime) from #AVGTime where convert(varchar(10), AvgTime, 101) NOT IN (Select convert(varchar(10), CurrentETLCycle, 101) from DM.ETLGlobalDMPackages)
--AND InstanceID = P.InstanceID
)
 as [LastRunTime(Mins)],

		--Avg RunTime.
	(
	Select AVG(AVGTime) 
	 from #AVGTime A 
	where A.InstanceID = P.InstanceID 
	 AND A.ETLCycle BETWEEN convert(varchar(10), GetDate() - @Days, 101) 
						AND convert(varchar(10), GetDate(), 101)
	) AS [AVGRunTime(Mins)]--,

--		--Min RunTime.
--	(
--	Select MIN(AVGTime) 
--	 from #AVGTime A 
--	where A.InstanceID = P.InstanceID 
--	 AND A.ETLCycle BETWEEN convert(varchar(10), GetDate() - @Days, 101) 
--						AND convert(varchar(10), GetDate(), 101)
--	) AS [MinRunTime(Mins)],
--
--		--Max RunTime.
--	(
--	Select MAX(AVGTime) 
--	 from #AVGTime A 
--	where A.InstanceID = P.InstanceID 
--	 AND A.ETLCycle BETWEEN convert(varchar(10), GetDate() - @Days, 101) 
--						AND convert(varchar(10), GetDate(), 101)
--	) AS [MaxRunTime(Mins)]



from DM.ETLGlobalDMStats S
Inner Join DM.ETLGlobalDMPackages P
ON S.PackID = P.PackID
Inner Join #CurrentRunningRegions E
ON P.InstanceID = E.InstanceID
Inner Join DM.ETLGlobalDMServers ES
ON P.InstanceID = ES.InstanceID
WHERE ETLCycle IN (Select MAX(ETLCycle) from DM.ETLGlobalDMStats where InstanceID = P.InstanceID)
Group By ES.Region, P.InstanceID, ETLCycle, E.Running, E.Errors, E.Finished, E.Total
ORDER BY ES.Region, ETLCycle Desc

Drop table #AVGTime
drop table #CurrentRunningRegions




;
GO
/****** Object:  Table [dbo].[ErrorLogSearch]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ErrorLogSearch](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LogNumber] [tinyint] NULL,
	[LogType] [tinyint] NULL,
	[Class] [varchar](50) NULL,
	[Search1] [varchar](100) NULL,
	[Search2] [varchar](100) NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[SortOrder] [varchar](4) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[DriveSpace]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[DriveSpace](
	[ExecutionDateTime] [datetime] NOT NULL,
	[InstanceID] [int] NOT NULL,
	[Name] [varchar](255) NULL,
	[Caption] [varchar](255) NULL,
	[DriveLetter] [varchar](255) NULL,
	[DriveType] [varchar](255) NULL,
	[FileSystem] [varchar](255) NULL,
	[Label] [varchar](255) NULL,
	[Capacity] [bigint] NULL,
	[FreeSpace] [bigint] NULL,
	[%Free] [decimal](4, 2) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE CLUSTERED INDEX [clustExecutionDateTime] ON [Collector].[DriveSpace] 
(
	[ExecutionDateTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Table [Collector].[DBSize]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[DBSize](
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[DataSpaceUsageKB] [int] NULL,
	[DBSizeMB] [float] NULL,
	[SpaceAvailKB] [int] NULL,
	[LastBackupDate] [datetime2](7) NULL,
	[LastDiffBackupDate] [datetime2](7) NULL,
	[LastLogBackupDate] [datetime2](7) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[DBPropertiesorig]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[DBPropertiesorig](
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[DBOwner] [varchar](100) NULL,
	[LastBackup] [datetime] NULL,
	[LastLogBackup] [datetime] NULL,
	[LastDiffBackup] [datetime] NULL,
	[AutoClose] [bit] NULL,
	[AutoShrink] [bit] NULL,
	[DBReadOnly] [bit] NULL,
	[Collation] [varchar](100) NULL,
	[CompatLevel] [varchar](10) NULL,
	[DefaultSchema] [varchar](100) NULL,
	[FullTxtEnabled] [bit] NULL,
	[RecoveryModel] [varchar](10) NULL,
	[SizeOnDiskInMB] [decimal](12, 2) NULL,
	[CreateDate] [datetime] NULL,
	[CaseSensitive] [bit] NULL,
	[Status] [varchar](50) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[DBUsers]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[DBUsers](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[CollectionDateTime] [datetime] NULL,
	[InstanceID] [int] NULL,
	[DBName] [varchar](100) NULL,
	[UserName] [varchar](100) NULL,
	[CreateDate] [datetime] NULL,
	[DateLastModified] [datetime] NULL,
	[DefaultLanguage] [varchar](50) NULL,
	[DefaultSchema] [varchar](50) NULL,
	[HasDBAccess] [bit] NULL,
	[IsSystemObject] [bit] NULL,
	[Login] [varchar](100) NULL,
	[LoginType] [varchar](50) NULL,
	[SID] [varchar](150) NULL,
	[State] [varchar](50) NULL,
 CONSTRAINT [pk_DBUsers_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Alert].[DiskSpaceDefer]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Alert].[DiskSpaceDefer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[DriveLetter] [varchar](255) NULL,
	[Caption] [varchar](255) NULL,
	[DeferDate] [date] NULL,
	[DeferEndDate] [date] NULL,
	[DeferEndTime] [time](7) NULL,
 CONSTRAINT [pk_DiskSpaceDefer_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [History].[DBsNewRetired]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [History].[DBsNewRetired](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[ServiceLevel] [varchar](10) NULL,
	[InstanceID] [int] NULL,
	[ServerName] [varchar](100) NULL,
	[DBName] [varchar](200) NULL,
	[Status] [varchar](10) NULL,
 CONSTRAINT [pk_DBsNewRetired_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [Collector].[ErrorLog]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [Collector].[ErrorLog](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[ExecutionDateTime] [datetime] NULL,
	[InstanceID] [bigint] NULL,
	[LogDate] [datetime] NULL,
	[ProcessInfo] [varchar](50) NULL,
	[Text] [varchar](max) NULL,
	[LogNumber] [tinyint] NULL,
	[LogType] [tinyint] NULL,
	[Search1] [varchar](100) NULL,
	[Search2] [varchar](100) NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[SortOrder] [varchar](4) NULL,
	[SearchID] [int] NULL,
 CONSTRAINT [pk_ErrorLog_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EmailNotification]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmailNotification](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EmailAddress] [varchar](1024) NOT NULL,
	[Comment] [varchar](1024) NOT NULL,
 CONSTRAINT [pk_EmailNotification_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DriveSpaceThresholdServer]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DriveSpaceThresholdServer](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[AlertMethod] [varchar](10) NULL,
	[AlertValue] [int] NULL,
 CONSTRAINT [pk_DriveSpaceThresholdServer_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [Setup].[DiskSpaceThresholdDelete]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Setup].[DiskSpaceThresholdDelete] 
(
@InstanceID int,
@Caption varchar(255)
)

  
AS

SET NOCOUNT ON

DELETE FROM [dbo].[DriveSpaceThresholds]
WHERE InstanceID = @InstanceID
	  AND Caption = @Caption

SELECT 'Deleted', @InstanceID, @Caption




;
GO
/****** Object:  Table [dbo].[DriveSpaceThresholdDrive]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DriveSpaceThresholdDrive](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[DriveLetter] [varchar](255) NULL,
	[Caption] [varchar](255) NULL,
	[Label] [varchar](255) NULL,
	[AlertMethod] [varchar](10) NULL,
	[AlertValue] [int] NULL,
 CONSTRAINT [pk_DriveSpaceThresholdDrive_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DriveSpaceExceptions]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DriveSpaceExceptions](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[DriveLetter] [varchar](255) NULL,
	[Caption] [varchar](255) NULL,
	[Label] [varchar](255) NULL,
 CONSTRAINT [pk_DriveSpaceExceptions_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [Collector].[DriveSpaceCurrent]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[DriveSpaceCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            D.Name AS DriveName,
			D.Caption,
			D.DriveLetter,
			D.Label,
			D.Capacity AS CapacityBytes,
			D.Capacity/1024/1024 AS CapacityMB,
			D.Capacity/1024/1024/1024 AS CapacityGB,
			D.FreeSpace AS FreeSpaceBytes,
			D.FreeSpace/1024/1024 AS FreeSpaceMB,
			D.FreeSpace/1024/1024/1024 AS FreeSpaceGB,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion AS Version,
			S.SQLEdition AS Edition,
			S.Descr,
			'This view shows the latest collection time for disks on all the servers. It has all the info you should need to easily build your own custom queries.' AS ViewDesc
    FROM    Collector.DriveSpace D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.DriveSpace D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL



;
GO
/****** Object:  StoredProcedure [Setup].[DiskSpaceDefer]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Setup].[DiskSpaceDefer]
(
@ServerName varchar(100),
@DriveLetter varchar(255),
@DeferDate date,
@DeferEndDate date,
@DeferEndTime time(7)
)

  
AS

SET NOCOUNT ON

--SELECT * FROM Collector.DriveSpace

DECLARE @InstanceID INT,
		@AlreadyExists bit,
		@Caption varchar(1000)


SET @InstanceID = (SELECT InstanceID FROM dbo.Servers
WHERE ServerName = @ServerName)

--- Get the value from the DriveSpace table.
---This is the best way to make sure you've got the proper entry that's being
---reported on.  
---This also takes the data from the last collection period to make sure it's
---the most accurate.

If @DriveLetter NOT LIKE '%\%'
BEGIN
	SET @DriveLetter = @DriveLetter + '\'
END

SELECT  
@DriveLetter = DriveLetter,
@Caption = Caption
FROM Collector.DriveSpace
WHERE InstanceID = @InstanceID
AND Name = @DriveLetter
AND ExecutionDateTime IN (SELECT MAX(ExecutionDateTime) FROM Collector.DriveSpace WHERE InstanceID = @InstanceID)


SELECT @AlreadyExists = (SELECT COUNT(1) FROM Alert.DiskSpaceDefer
WHERE (InstanceID = @InstanceID
AND Caption = @DriveLetter
AND CAST(GETDATE() AS DATE) < DeferEndDate)
)

--SET @AlreadyExists = 0
---Only insert a new row if it doesn't already exist.
IF @AlreadyExists = 0
BEGIN 

	INSERT Alert.DiskSpaceDefer(InstanceID, DriveLetter, Caption, DeferDate, DeferEndDate, DeferEndTime)
	SELECT @InstanceID, @DriveLetter, @Caption, @DeferDate, @DeferEndDate, @DeferEndTime

END

---If it exists, then update it instead.
IF @AlreadyExists = 1
BEGIN 

	UPDATE Alert.DiskSpaceDefer
	SET
	  DriveLetter = @DriveLetter,
	  DeferEndDate = @DeferEndDate,
	  DeferEndTime = @DeferEndTime

	WHERE InstanceID = @InstanceID
	AND Caption = @Caption
	

END

SELECT 'Inserted Row',
	   @InstanceID AS InstanceID, 
	   @DriveLetter AS DriveLetter

DECLARE @CT TINYINT

--SET @CT = (SELECT COUNT(*) FROM dbo.DriveSpaceThresholds
--WHERE InstanceID = @InstanceID
--	  AND Caption = @Caption)

--IF @CT > 0
--	BEGIN	

--		SELECT 'Logic problem.  Check messages for more info.'
--		PRINT 'This server/disk also has a threshold in [dbo].[DriveSpaceThresholds].'
--		PRINT 'This is a logical inconsistency because you cannot have and exception'
--		PRINT 'to not report on the drive, and have a threshold for when it should be reported.'
--		PRINT 'To remove the Threshold, run this command:'
--		PRINT ''
--		PRINT 'Setup.DiskSpaceThresholdDelete ' + CAST(@InstanceID AS VARCHAR(10)) + ', ''' + @Caption + '''' 

--	END
--EXEC servers.byname @ServerName



;
GO
/****** Object:  View [Collector].[DBFilePropertiesCurrent]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[DBFilePropertiesCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion as Version,
			S.SQLEdition as Edition,
			S.Descr,
			D.FileGroup,
			D.FileName,
			D.FullFileName,
			D.FileType,
			D.AvailableSpace,
			D.BytesReadFromDisk,
			D.BytesWrittenToDisk,
			D.Growth,
			D.GrowthType,
			D.FileID,
			D.IsOffline,
			D.IsPrimaryFile,
			D.IsReadOnly,
			D.IsReadOnlyMedia,
			D.IsSparse,
			D.MaxSize,
			D.NumberOfDiskReads,
			D.NumberOfDiskWrites,
			D.Size,
			D.State,
			D.SpaceUsed,
			D.VolumeFreeSpace,
			'This view shows the latest collection for DB file properties. You can filter by FileType ''D'' or ''L'' to get data or logs.  Get to know this view; it has lots of good data.' AS ViewDesc
    FROM    Collector.DBFileProperties D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.DBFileProperties D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL


;
GO
/****** Object:  StoredProcedure [Alert].[DBsNewRetired]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Alert].[DBsNewRetired] 
(
	@EmailProfile	varchar(1024), 
	@Servicelevel Varchar(10)
 )
 
AS

--  [Alert].[DBsNewRetired] 'DatabaseInfoProfile', 'Gold'
SET NOCOUNT ON

/***********************************************************************************

Created By: Sean McCown
Creation Date: 3/6/2012


Purpose: This procedure alerts and reports on failed backups. 

Walkthrough:
      1. Get list of all managed servers and databases
      2. Get latest backup dates
	  3. Filter out exceptions.
	  4. Filter out read-only DBs.
	  5. Filter out deferred DBs.
      6. Send alert email only if there are records to send.

Conventions:

Parameters:
-----------
@EmailProfile - DBmail profile to be used for emailing the report

@ServiceLevel - 3 services levels in the order of importance 'Gold', 'Silver', 'Bronze' 

@Debug - when 1, dumps all tables to console for debug purposes

@Distrib - Email addresses to be alerted on missing backups

@CurrentSubject - Email subject line

@tableHTML - Missing Backup report table in HTML Format

@RowCount - Number of missing backups to be added to the subject line


Tables:
--------
#ServerList - holds a list of all servers at a given service level 

#DBlistMaint - Holds a list of databases for the servers into dblistmaint 

#DBBkupListByDate - Holds a list of all databases and the last backup date

#DBBKListRanked = Holds a list of databases partitioned by server with ranked backup dates. The latest backup rank is 1 
and the oldest backup date is rank N

#DBBKListTopRanked - Holds a list of databases partitioned by server with their "latest" backup date

#Final - Holds final resultset.  Everything has been deleted out of here by now and the email process does just
		 a simple query to get the records.  The reason it was done this way is because there are multiple places
		 where the logic is queried from and if the logic ever changes, this minimizes mistakes.
		 Take for example that you have to query the table 2 times.  Once to see if there are any records
		 to see if the email needs to be sent.  And a 2nd time to query the actual records for the detail that
		 goes into the alert email itself.  If the logic changes when you'll have to change it in both locations
		 so that the count and the details are both correct.  By handling that higher up in the code and letting
		 the email process just query this table in a simple manner, you reduce the complexity of making changes.
Revision History:

***********************************************************************************/


Declare	@CurrentSubject varchar(100), 
		@tableHTML		NVARCHAR(MAX),
		@Distribn		varchar(4000),
		@Execution		datetime,
		@RowCount		Smallint;
		
		         
Set @RowCount = 0 
Set @Distribn = ''

select @Distribn = @Distribn + EmailAddress + '; ' from  dbo.EmailNotification 
order by EmailAddress

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

---Get list of DBs from the last run for all servers of the service level passed in.
Select DM.InstanceID, DM.DBName, ExecutionDateTime 
, ROW_NUMBER() over(partition by DM.InstanceId, DM.dbname order by DM.dbname, DM.ExecutionDateTime desc) as RowNum
INTO #DBListRanked
from Collector.DBProperties DM
INNER JOIN dbo.Servers S
ON  DM.InstanceID = S.[InstanceID]
Where 
ExecutionDateTime IN (SELECT MAX(DM2.ExecutionDateTime) FROM Collector.DBProperties DM2
						WHERE DM2.InstanceID = DM.InstanceID
						)
AND S.ServiceLevel = @ServiceLevel
and S.IsSQL = 1
and S.IsActive = 1
AND S.BackupManaged = 1

---------------------------------------------------------------
---Get only DBs that are new and need to be added to DBMaint.
---------------------------------------------------------------
SELECT InstanceID, DBName, CAST('New' AS VARCHAR(7)) AS Status
INTO #DBListPruned
FROM #DBListRanked
WHERE RowNum = 1

	EXCEPT

Select DM.InstanceID, DM.DBName, CAST('New' AS VARCHAR(7)) AS Status 
from dbo.DBMaint DM
INNER JOIN dbo.Servers S
ON  DM.InstanceID = S.[InstanceID]
Where S.ServiceLevel = @ServiceLevel
and S.IsSQL = 1
and S.IsActive = 1
AND S.BackupManaged = 1



--------------------------------------------------------
----Get retired DBs.
--------------------------------------------------------
INSERT #DBListPruned 
Select DM.InstanceID, DM.DBName, 'Retired' AS Status 
from dbo.DBMaint DM
INNER JOIN dbo.Servers S
ON  DM.InstanceID = S.[InstanceID]
Where S.ServiceLevel = @ServiceLevel
and S.IsSQL = 1
and S.IsActive = 1
AND S.BackupManaged = 1

	EXCEPT

SELECT InstanceID, DBName, 'Retired' AS Status
FROM #DBListRanked
WHERE RowNum = 1

--select '#DBListPruned', * from #DBListPruned
-----Now put them all into the #Final table. It's not strictly necessary, but it's
-----nice to not have to change the rest of the SP from one alert from the next.

SELECT S.ServerName, D.*
INTO #Final
FROM #DBListPruned D
INNER JOIN Servers S
ON S.[InstanceID] = D.InstanceID

DELETE #Final
WHERE DBName = 'pubs'
OR DBName = 'northwind'


----------------------------------------------------------------------------
----------------------------------------------------------------------------
-------------------------BEGIN Fuzzy Lookups--------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------

-- Get unique list of InstanceID, Regex.  An instance can have more than one
-- regex criteria if there are several sets of DBs on that server that have fuzzy lookups.
-- So here, if there's more than 1, this will cycle through them.
-- Normally we'd look for a specific MaintType but here we're interested in New/Retired DBs no matter
-- what the function so we're going to take all of them.


create table #FuzzyLookup
(
InstanceID bigint,
DBName sysname NULL,
Action varchar(10)
)

DECLARE @currUser varchar(100),
		@SQL nvarchar(200),
		@InstanceID bigint,
		@Regex varchar(200),
		@Action varchar(10),
		@FuzzyCMD varchar(2000);

DECLARE DBs CURSOR
READ_ONLY
FOR 
SELECT DISTINCT DFL.InstanceID, DFL.Regex, DFL.Action
FROM dbo.DBMaintFuzzyLookup DFL
INNER JOIN #Final F
ON DFL.InstanceID = F.InstanceID

OPEN DBs

	FETCH NEXT FROM DBs INTO @InstanceID, @Regex, @Action
	WHILE (@@fetch_status <> -1)
	BEGIN


SET @FuzzyCMD = 
'Powershell "C:\MinionByMidnightDBA\SPPowershellScripts\DBNameFuzzyLookup.ps1 ' + CAST(@InstanceID as varchar(10)) + ' ''' + @Regex + '''"' 

 INSERT #FuzzyLookup(DBName)     
            EXEC xp_cmdshell @FuzzyCMD 

UPDATE #FuzzyLookup
SET InstanceID = @InstanceID,
	Action = @Action
WHERE InstanceID IS NULL

	FETCH NEXT FROM DBs INTO @InstanceID, @Regex, @Action
	END

CLOSE DBs
DEALLOCATE DBs

--Get rid of any rows that aren't actually DBNames.  The cmdshell gives us back some crap with our results.-
DELETE #FuzzyLookup
WHERE 
--DBName NOT IN (SELECT DBName FROM Collector.DBProperties DM2
--						WHERE InstanceID = DM2.InstanceID
--						AND DM2.ExecutionDateTime = (SELECT MAX(DM3.ExecutionDateTime) from Collector.DBProperties DM3 where DM2.InstanceID = DM3.InstanceID)
--						)
DBName IS NULL


--Delete DBs that are meant to be excluded off of the fuzzy search.
DELETE #Final
WHERE DBName IN (SELECT DBName FROM #FuzzyLookup FL
WHERE InstanceID = FL.InstanceID AND DBName = FL.DBName
AND FL.Action = 'Exclude')

--SELECT '#Final', * FROM #Final
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-------------------------END Fuzzy Lookups----------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------


-- /************************************************************************************
-- Run the report.
 
-- *************************************************************************************/
 
-- -- Count the # of items.
 
 Select @RowCount = COUNT(*) 
 	From #Final
 SET @Execution = GETDATE()
 
 Insert History.DBsNewRetired (ExecutionDateTime, ServiceLevel, InstanceID, ServerName, DBName, Status)
 select @Execution,@Servicelevel, InstanceID, ServerName, DBName, Status
 from #Final
-- -- Set the subject header.
 
set @CurrentSubject = 'New/Retired DBs ' + CAST(@rowcount as Varchar(4)) + ' (' + @ServiceLevel + ')' 

---- Body of the report.
 
SET @tableHTML =              
N'<H2>'+ @CurrentSubject + '</H2>' +              
N'<table border="1">' +              
N'<tr>
	<th>InstanceID</th> 
	<th>Server Name</th>   
	<th>DB Name</th>          
	<th>Status</th>
</tr>' +           
CAST ( (Select 
		td = InstanceID, '',
		td = Servername, '',
		td = DBName, '',
		td = Status, ''
		From #Final
		order by Status, ServerName, DBName
		FOR XML PATH('tr'), TYPE               
 ) AS NVARCHAR(MAX)) +              
N'</table>' ;              
set @tableHTML =@tableHTML+'<BR>'              
--set @tableHTML =@tableHTML+'***Please do NOT reply to the sender; Automated Report***'   

 --Email 

IF @RowCount > 0
BEGIN
	EXEC msdb.dbo.sp_send_dbmail              
	@profile_name = @EmailProfile,              
	@recipients = @Distribn,              
	@subject = @CurrentSubject,              
	@body = @tableHTML,              
	@body_format = 'HTML'; 
END

;
GO
/****** Object:  View [Collector].[DBUsersCurrent]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[DBUsersCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion as Version,
			S.SQLEdition as Edition,
			S.Descr,
			D.CollectionDateTime,
			D.DBName,
			D.UserName,
			D.CreateDate,
			D.DateLastModified,
			D.DefaultLanguage,
			D.DefaultSchema,
			D.HasDBAccess,
			D.IsSystemObject,
			D.Login,
			D.LoginType,
			D.SID,
			D.State,
			'This view shows the latest collection for DB users. You can use this to tell when users are added and deleted from specific DBs.' AS ViewDesc
    FROM    Collector.DBUsers D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.DBUsers D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL


;
GO
/****** Object:  View [dbo].[DBSpaceForCube]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DBSpaceForCube] 
as
SELECT  ExecutionDateTime,
        DATEPART(yyyy, ExecutionDateTime) AS ExecYear,
        DATEPART(qq, ExecutionDateTime) AS ExecQuarter,
        DATEPART(mm, ExecutionDateTime) AS ExecMonth,
        DATEPART(dy, ExecutionDateTime) AS ExecDOY,
        DATEPART(dd, ExecutionDateTime) AS ExecDay,
        DATEPART(wk, ExecutionDateTime) AS ExecWeek,
        DATEPART(dw, ExecutionDateTime) AS ExecWeekday,
        DATEPART(hh, ExecutionDateTime) AS ExecHour,
        DATEPART(mi, ExecutionDateTime) AS ExecMinute,
        DATEPART(ss, ExecutionDateTime) AS ExecSecond,
        InstanceID,
        DBName,
        TableName,
        CAST(DataSpaceUsed AS BIGINT) AS DataSpaceUsed,
        CAST(IndexSpaceUsed AS BIGINT) AS IndexSpaceUsed,
        CAST(DataSpaceUsed AS BIGINT) + CAST(IndexSpaceUsed AS BIGINT) AS SpaceUsed,
        [RowCount],
        FileGroup
FROM    Collector.TableSize AS a




;
GO
/****** Object:  StoredProcedure [Collector].[DBPropertiesInsert]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collector].[DBPropertiesInsert]
(
@ExecutionDateTime DATETIME,
@InstanceID INT,
@DBName VARCHAR(100),
@DBOwner VARCHAR(100),
@LastBackup DATETIME,
@LastLogBackup DATETIME,
@LastDiffBackup DATETIME,
@AutoClose BIT,
@AutoShrink BIT,
@DBReadOnly BIT,
@Collation VARCHAR(100),
@CompatLevel VARCHAR(10),
@DefaultSchema VARCHAR(100),
@FullTxtEnabled BIT,
@RecoveryModel VARCHAR(10),
@CreateDate DATETIME,
@CaseSensitive BIT,
@Status VARCHAR(50),
@ANSINullDefault BIT,
@ANSINullsEnabled BIT,
@ANSIPaddingEnabled BIT,
@ANSIWarningsEnabled BIT,
@ArithAbortEnabled BIT,
@AutoCreateIncrementalStatisticsEnabled BIT,
@AutoCreateStatisticsEnabled BIT,
@AutoUpdateStatisticsAsync bit,
@AutoUpdateStatisticsEnabled bit,
@AvailabilityDatabaseSynchronizationState bit,
@AvailabilityGroupName bit,
@BrokerEnabled bit,
@ChangeTrackingAutoCleanUp bit,
@ChangeTrackingEnabled bit,
@ChangeTrackingRetentionPeriod int,
@ChangeTrackingRetentionPeriodUnits varchar(20),
@CloseCursorsOnCommitEnabled bit,
@ConcatenateNullYieldsNull bit,
@ContainmentType varchar(20),
@DatabaseGuid UNIQUEIDENTIFIER,
@DatabaseOwnershipChaining bit,
@DatabaseSnapshotBaseName varchar(100),
@DataSpaceUsage DECIMAL(12,2),
@DateCorrelationOptimization bit,
@DboLogin varchar(100),
@DefaultFileGroup varchar(100),
@DefaultFileStreamFileGroup varchar(100),
@DefaultFullTextCatalog varchar(100),
@DefaultFullTextLanguage varchar(100),
@DefaultLanguage varchar(100),
@DelayedDurability varchar(50),
@EncryptionEnabled bit,
@FilestreamDirectoryName varchar(100),
@FilestreamNonTransactedAccess varchar(3),
@HasFileInCloud BIT,
@HasMemoryOptimizedObjects bit,
@HonorBrokerPriority bit,
@IndexSpaceUsage DECIMAL(12,2),
@IsAccessible bit,
@IsDatabaseSnapshot bit, 
@IsDatabaseSnapshotBase bit,
@IsFederationMember BIT,
@IsFullTextEnabled bit,
@IsMailHost bit,
@IsManagementDataWarehouse bit,
@IsMirroringEnabled bit,
@IsParameterizationForced bit,
@IsReadCommittedSnapshotOn bit,
@IsSystemObject bit,
@IsUpdateable BIT,
@IsVarDecimalStorageFormatEnabled BIT,
@LocalCursorsDefault BIT,
@LogReuseWaitStatus varchar(50),
@MemoryAllocatedToMemoryOptimizedObjectsInKB BIGINT,
@MemoryUsedByMemoryOptimizedObjectsInKB BIGINT,
@MirroringFailoverLogSequenceNumber decimal(25,0),
@MirroringID UNIQUEIDENTIFIER,
@MirroringPartner sysname,
@MirroringPartnerInstance sysname,
@MirroringRedoQueueMaxSize bigint,
@MirroringRoleSequence INT,
@MirroringSafetyLevel VARCHAR(20),
@MirroringSafetySequence int,
@MirroringStatus VARCHAR(10),
@MirroringTimeout int,
@MirroringWitness sysname,
@MirroringWitnessStatus VARCHAR(10),
@NestedTriggersEnabled bit,
@NumericRoundAbortEnabled bit,
@PageVerify varchar(25),
@PrimaryFilePath varchar(max),
@QuotedIdentifiersEnabled bit,
@ReadOnly bit,
@RecoveryForkGuid uniqueidentifier,
@RecursiveTriggersEnabled bit,
@ServiceBrokerGuid uniqueidentifier,
@SizeInMB DECIMAL(12,2),
@SnapshotIsolationState varchar(100),
@SpaceAvailableInKB DECIMAL(12,2),
@State VARCHAR(20),
@TargetRecoveryTime INT,
@TransformNoiseWords BIT,
@Trustworthy BIT,
@TwoDigitYearCutoff smallint
)

   
AS

INSERT Collector.DBProperties
(
ExecutionDateTime,
InstanceID,
DBName,
DBOwner,
LastBackup,
LastLogBackup,
LastDiffBackup,
AutoClose,
AutoShrink,
DBReadOnly,
Collation,
CompatLevel,
DefaultSchema,
FullTxtEnabled,
RecoveryModel,
CreateDate,
CaseSensitive,
Status,
ANSINullDefault,
ANSINullsEnabled,
ANSIPaddingEnabled,
ANSIWarningsEnabled,
ArithAbortEnabled,
AutoCreateIncrementalStatisticsEnabled,
AutoCreateStatisticsEnabled,
AutoUpdateStatisticsAsync,
AutoUpdateStatisticsEnabled,
AvailabilityDatabaseSynchronizationState,
AvailabilityGroupName,
BrokerEnabled,
ChangeTrackingAutoCleanUp,
ChangeTrackingEnabled,
ChangeTrackingRetentionPeriod,
ChangeTrackingRetentionPeriodUnits,
CloseCursorsOnCommitEnabled,
ConcatenateNullYieldsNull,
ContainmentType,
DatabaseGuid,
DatabaseOwnershipChaining,
DatabaseSnapshotBaseName,
DataSpaceUsage,
DateCorrelationOptimization,
DboLogin,
DefaultFileGroup,
DefaultFileStreamFileGroup,
DefaultFullTextCatalog,
DefaultFullTextLanguage,
DefaultLanguage,
DelayedDurability,
EncryptionEnabled,
FilestreamDirectoryName,
FilestreamNonTransactedAccess,
HasFileInCloud,
HasMemoryOptimizedObjects,
HonorBrokerPriority,
IndexSpaceUsage,
IsAccessible,
IsDatabaseSnapshot, 
IsDatabaseSnapshotBase,
IsFederationMember,
IsFullTextEnabled,
IsMailHost,
IsManagementDataWarehouse,
IsMirroringEnabled,
IsParameterizationForced,
IsReadCommittedSnapshotOn,
IsSystemObject,
IsUpdateable,
IsVarDecimalStorageFormatEnabled,
LocalCursorsDefault,
LogReuseWaitStatus,
MemoryAllocatedToMemoryOptimizedObjectsInKB,
MemoryUsedByMemoryOptimizedObjectsInKB,
MirroringFailoverLogSequenceNumber,
MirroringID,
MirroringPartner,
MirroringPartnerInstance,
MirroringRedoQueueMaxSize,
MirroringRoleSequence,
MirroringSafetyLevel,
MirroringSafetySequence,
MirroringStatus,
MirroringTimeout,
MirroringWitness,
MirroringWitnessStatus,
NestedTriggersEnabled,
NumericRoundAbortEnabled,
PageVerify,
PrimaryFilePath,
QuotedIdentifiersEnabled,
ReadOnly,
RecoveryForkGuid,
RecursiveTriggersEnabled,
ServiceBrokerGuid,
SizeInMB,
SnapshotIsolationState,
SpaceAvailableInKB,
State,
TargetRecoveryTime,
TransformNoiseWords,
Trustworthy,
TwoDigitYearCutoff
)

SELECT
@ExecutionDateTime,
@InstanceID,
@DBName,
@DBOwner,
@LastBackup,
@LastLogBackup,
@LastDiffBackup,
@AutoClose,
@AutoShrink,
@DBReadOnly,
@Collation,
@CompatLevel,
@DefaultSchema,
@FullTxtEnabled,
@RecoveryModel,
@CreateDate,
@CaseSensitive,
@Status,
@ANSINullDefault,
@ANSINullsEnabled,
@ANSIPaddingEnabled,
@ANSIWarningsEnabled,
@ArithAbortEnabled,
@AutoCreateIncrementalStatisticsEnabled,
@AutoCreateStatisticsEnabled,
@AutoUpdateStatisticsAsync,
@AutoUpdateStatisticsEnabled,
@AvailabilityDatabaseSynchronizationState,
@AvailabilityGroupName,
@BrokerEnabled,
@ChangeTrackingAutoCleanUp,
@ChangeTrackingEnabled,
@ChangeTrackingRetentionPeriod,
@ChangeTrackingRetentionPeriodUnits,
@CloseCursorsOnCommitEnabled,
@ConcatenateNullYieldsNull,
@ContainmentType,
@DatabaseGuid,
@DatabaseOwnershipChaining,
@DatabaseSnapshotBaseName,
@DataSpaceUsage,
@DateCorrelationOptimization,
@DboLogin,
@DefaultFileGroup,
@DefaultFileStreamFileGroup,
@DefaultFullTextCatalog,
@DefaultFullTextLanguage,
@DefaultLanguage,
@DelayedDurability,
@EncryptionEnabled,
@FilestreamDirectoryName,
@FilestreamNonTransactedAccess,
@HasFileInCloud,
@HasMemoryOptimizedObjects,
@HonorBrokerPriority,
@IndexSpaceUsage,
@IsAccessible,
@IsDatabaseSnapshot, 
@IsDatabaseSnapshotBase,
@IsFederationMember,
@IsFullTextEnabled,
@IsMailHost,
@IsManagementDataWarehouse,
@IsMirroringEnabled,
@IsParameterizationForced,
@IsReadCommittedSnapshotOn,
@IsSystemObject,
@IsUpdateable,
@IsVarDecimalStorageFormatEnabled,
@LocalCursorsDefault,
@LogReuseWaitStatus,
@MemoryAllocatedToMemoryOptimizedObjectsInKB,
@MemoryUsedByMemoryOptimizedObjectsInKB,
@MirroringFailoverLogSequenceNumber,
@MirroringID,
@MirroringPartner,
@MirroringPartnerInstance,
@MirroringRedoQueueMaxSize,
@MirroringRoleSequence,
@MirroringSafetyLevel,
@MirroringSafetySequence,
@MirroringStatus,
@MirroringTimeout,
@MirroringWitness,
@MirroringWitnessStatus,
@NestedTriggersEnabled,
@NumericRoundAbortEnabled,
@PageVerify,
@PrimaryFilePath,
@QuotedIdentifiersEnabled,
@ReadOnly,
@RecoveryForkGuid,
@RecursiveTriggersEnabled,
@ServiceBrokerGuid,
@SizeInMB,
@SnapshotIsolationState,
@SpaceAvailableInKB,
@State,
@TargetRecoveryTime,
@TransformNoiseWords,
@Trustworthy,
@TwoDigitYearCutoff
;
GO
/****** Object:  StoredProcedure [Archive].[DriveSpace]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Archive].[DriveSpace]

   
AS

DECLARE @ArchiveInDays INT
		


CREATE TABLE #ServerList
(
InstanceID INT,
ArchiveInDays INT
)

INSERT #ServerList
(ArchiveInDays)
SELECT DISTINCT InstanceID 
FROM Collector.DriveSpace
ORDER BY InstanceID


----Get default for all servers. InstanceID 0 means 'all servers'.
SELECT @ArchiveInDays = ArchiveInDays
FROM Archive.DriveSpaceMaster
WHERE InstanceID = 0;

----Set Archive params to the default.
UPDATE #ServerList
SET ArchiveInDays = @ArchiveInDays

----Set Archive params for any specific servers there may be.
UPDATE S
SET S.ArchiveInDays = DSM.ArchiveInDays
FROM #ServerList S
INNER JOIN Archive.DriveSpaceMaster DSM
ON S.InstanceID = DSM.InstanceID


SELECT * FROM #ServerList


--------------------------------------------------
----------BEGIN Delete----------------------------
--------------------------------------------------

set nocount on

while 1=1

begin

		DELETE TOP(10000) FROM DS
		FROM Collector.DriveSpace DS
		INNER JOIN #ServerList S
		ON DS.InstanceID = S.InstanceID
		WHERE DS.ExecutionDateTime > S.ArchiveInDays

if @@rowcount = 0
break
end

--------------------------------------------------
----------END Delete------------------------------
--------------------------------------------------
;
GO
/****** Object:  StoredProcedure [Collector].[ErrorLogInsert]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[ErrorLogInsert]
(
@ExecutionDateTime datetime,
@InstanceID bigint,
@LogDate datetime,
@ProcessInfo varchar(50),
@Text varchar(max),
@LogNumber tinyint,
@LogType tinyint,
@Search1 varchar(100),
@Search2 varchar(100),
@BeginDate datetime,
@EndDate datetime,
@SortOrder varchar(4),
@SearchID int
)

   
AS 
INSERT Collector.ErrorLog (ExecutionDateTime, InstanceID, LogDate, ProcessInfo, Text, LogNumber, LogType, Search1, Search2, BeginDate, EndDate, SortOrder, SearchID)
SELECT
@ExecutionDateTime,
@InstanceID,
@LogDate,
@ProcessInfo,
@Text,
@LogNumber,
@LogType,
@Search1,
@Search2,
@BeginDate,
@EndDate,
@SortOrder,
@SearchID

;
GO
/****** Object:  View [Collector].[ErrorLogCurrent]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[ErrorLogCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion as Version,
			S.SQLEdition as Edition,
			S.Descr,
			D.LogDate,
			D.ProcessInfo,
			D.Text,
			D.LogNumber,
			D.LogType,
			D.Search1,
			D.Search2,
			D.BeginDate,
			D.EndDate,
			D.SortOrder,
			D.SearchID,
			'This view shows the latest collection for the SQL error log searches.' AS ViewDesc
    FROM    Collector.ErrorLog D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.ErrorLog D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL



;
GO
/****** Object:  StoredProcedure [dbo].[ErrorLogSearchQuery]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ErrorLogSearchQuery] --'Gold'
(
@ServiceLevel varchar(10)
)

  
AS

select S.InstanceID, RTRIM(LTRIM(S.ServerName)) AS ServerName, S.SQLVersion, SM.MgmtDB, ELS.ID as SearchID, 
EL.LogDate, 
ELS.LogNumber, ELS.LogType, ELS.Search1, ELS.Search2, ELS.BeginDate, ELS.EndDate, ELS.SortOrder
INTO #ServerList
from dbo.Servers S (nolock) 
INNER JOIN dbo.ServerMgmtDB SM with(NOLOCK) 
ON S.InstanceID = SM.InstanceID
LEFT OUTER JOIN Collector.ErrorLog EL
ON S.InstanceID = EL.InstanceID
AND EL.LogDate = (SELECT MAX(EL2.LogDate) from Collector.ErrorLog EL2 where EL2.InstanceID = S.InstanceID)
INNER JOIN dbo.ErrorLogSearch ELS
ON 1=1
where S.ServiceLevel = @ServiceLevel 
and 
S.IsSQL = 1 
AND S.IsActive = 1
AND ELS.IsActive = 1
ORDER BY S.ServerName, ELS.LogNumber DESC

-------------------------------------------------------
-------------BEGIN Delete Servers----------------------
-------------------------------------------------------
---Delete servers that have the entire collection turned off.
DELETE SL
from #ServerList SL
INNER JOIN dbo.ServerModule SM
ON SL.InstanceID = SM.InstanceID
WHERE SM.ErrorLogManaged = 0;

---Delete SQL2K boxes.
DELETE #ServerList
WHERE SQLVersion = 2000 OR SQLVersion IS NULL

---Delete individual collections that any servers have excluded.
DELETE SL
from #ServerList SL
INNER JOIN dbo.ErrorLogSearchServerExceptions ELE
ON SL.InstanceID = ELE.InstanceID AND SL.SearchID = ELE.ErrorSearchID

-------------------------------------------------------
-------------END Delete Servers------------------------
-------------------------------------------------------

SELECT DISTINCT ServerName, SQLVersion, MgmtDB, SearchID, 
LogDate, LogNumber, LogType, Search1, Search2, BeginDate, EndDate, SortOrder 
from #ServerList


;
GO
/****** Object:  View [Collector].[FileGrowthRateCurrent]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[FileGrowthRateCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion AS Version,
			S.SQLEdition AS Edition,
			S.Descr,
			D.DBName,
			D.FileGroup,
			D.FileName,
			D.Growth,
			D.GrowthType,
			'This view shows the latest collection for file growth.' AS ViewDesc
    FROM    Collector.FileGrowthRate D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.FileGrowthRate D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL



;
GO
/****** Object:  StoredProcedure [Collector].[IndexMaintLOBUpdate]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collector].[IndexMaintLOBUpdate]

@InstanceID int,
@DBName varchar(100),
@SchemaName varchar(100),
@TableName varchar(100)

   
AS

/*
This SP updates the IndexMaint table with the LOB tables and sets them to not reindex them
online.  The tables need to already be in the table as the process won't insert new records.

It is called by the Collector.LOBTablesGet.ps1 script.
*/



UPDATE dbo.IndexMaint
SET IsLOB = 1,
ONLINEopt = 0
WHERE InstanceID = @InstanceID
AND   DBName = @DBName
AND   SchemaName = @SchemaName
AND   TableName = @TableName



;
GO
/****** Object:  StoredProcedure [Alert].[IndexMaint]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Alert].[IndexMaint] 
(@EmailProfile	varchar(1024), 
 @Servicelevel Varchar(10), 
 @IncludeDefer bit = 1,
 @IncludeException bit = 1,
 @IncludeChange bit = 1,
 @debug bit = 0)
 
   
AS

--  [Alert].[IndexMaint] 'BackupAlertProfile', 'Gold'
SET NOCOUNT ON

/***********************************************************************************

Created By: Sean McCown
Creation Date: 3/6/2012


Purpose: This procedure alerts and reports on failed backups. 

Walkthrough:
      1. Get list of all managed servers and databases
      2. Get latest backup dates
	  3. Filter out exceptions.
	  4. Filter out read-only DBs.
	  5. Filter out deferred DBs.
      6. Send alert email only if there are records to send.

Conventions:

Parameters:
-----------
@EmailProfile - DBmail profile to be used for emailing the report

@ServiceLevel - 3 services levels in the order of importance 'Gold', 'Silver', 'Bronze' 

@Debug - when 1, dumps all tables to console for debug purposes

@Distrib - Email addresses to be alerted on missing backups

@CurrentSubject - Email subject line

@tableHTML - Missing Backup report table in HTML Format

@RowCount - Number of missing backups to be added to the subject line


Tables:
--------
#ServerList - holds a list of all servers at a given service level 

#DBlistMaint - Holds a list of databases for the servers into dblistmaint 

#DBBkupListByDate - Holds a list of all databases and the last backup date

#DBBKListRanked = Holds a list of databases partitioned by server with ranked backup dates. The latest backup rank is 1 
and the oldest backup date is rank N

#DBBKListTopRanked - Holds a list of databases partitioned by server with their "latest" backup date

#Final - Holds final resultset.  Everything has been deleted out of here by now and the email process does just
		 a simple query to get the records.  The reason it was done this way is because there are multiple places
		 where the logic is queried from and if the logic ever changes, this minimizes mistakes.
		 Take for example that you have to query the table 2 times.  Once to see if there are any records
		 to see if the email needs to be sent.  And a 2nd time to query the actual records for the detail that
		 goes into the alert email itself.  If the logic changes when you'll have to change it in both locations
		 so that the count and the details are both correct.  By handling that higher up in the code and letting
		 the email process just query this table in a simple manner, you reduce the complexity of making changes.
Revision History:

***********************************************************************************/

Declare	@CurrentSubject varchar(100), 
		@tableHTML		NVARCHAR(MAX),
		@Distribn		varchar(4000),
		@ExecutionDateTime DATETIME,
		@RowCount		Smallint;
		
		         
Set @RowCount = 0 
Set @Distribn = ''
SET @ExecutionDateTime = GETDATE();

select @Distribn = @Distribn + EmailAddress + '; ' from  dbo.EmailNotification 
order by EmailAddress


/**********************************************************************
Check and delete temp objects if they exist
***********************************************************************/

If OBJECT_ID ('Tempdb..#ServerList') is not null
 Drop table #Serverlist
 
If OBJECT_ID ('Tempdb..#DBlistMaint') is not null
 Drop table #DBListMaint
 
If OBJECT_ID ('Tempdb..#DBBkupListByDate') is not null
 Drop table #DBBkupListByDate
 
If OBJECT_ID ('Tempdb..#DBBKListRanked') is not null
 Drop table #DBBKListRanked

If OBJECT_ID ('Tempdb..#DBBKListTopRanked') is not null
 Drop table #DBBKListTopRanked
 
/************************************************************************************
Get a list of all servers that are sql, active and  with the correct service level
put the result set into the #serverlist table 
**************************************************************************************/

Select S.ServerName, S.InstanceID 
into #ServerList
from dbo.Servers S
INNER JOIN dbo.ServerModule SM
ON S.InstanceID = SM.InstanceID
Where S.ServiceLevel = @ServiceLevel
and S.IsSQL = 1
and S.IsActive = 1
And SM.IndexManaged = 1

/**********************************************************************************************
Collect each servername, InstanceID and the databases on that server into a temp database list 
************************************************************************************************/

Select SL.InstanceID, SL.Servername, DBName, IMS.ReindexThresholdHrs
into #DBListMaint
From Collector.DBProperties DM  
Inner join #ServerList SL 
ON SL.InstanceID = DM.InstanceID
INNER JOIN [Alert].[IndexMaintReportSettingsServer] IMS
ON DM.InstanceID = IMS.InstanceID
WHERE IMS.IndexReport = 1 -- Only get DBs that are flagged to be reported on.
AND DM.ExecutionDateTime IN (SELECT MAX(ExecutionDateTime) FROM Collector.DBProperties D WHERE D.InstanceID = DM.InstanceID )
ORDER BY DM.DBName


 ---Delete DBs excluded from reporting.
 DELETE DM
 FROM #DBListMaint DM
 INNER JOIN [Alert].[IndexMaintReportSettingsDB] IMD
 ON DM.InstanceID = IMD.InstanceID
	AND DM.DBName = IMD.DBName
Where IMD.IndexReport = 0;

 
 -- Rank each reindex entry by date so we can see which is the latest one.
 
Select IL.BatchExecutionDateTime, IL.InstanceID, IL.DBName, 
IL.Status, DLM.ReindexThresholdHrs,
ROW_NUMBER() over(partition by IL.Instanceid, IL.DBName order by IL.DBName, IL.BatchExecutionDateTime desc) as RowNum
Into #IndexMaintLogRanked 
from Collector.IndexMaintLog IL(Nolock)
INNER JOIN #DBListMaint DLM
ON IL.InstanceID = DLM.InstanceID
AND IL.DBName = DLM.DBName; -- Here again looking at only the DBs we're concerned about.

----Get only the latest collections
Select * into #IndexMaintLogTOPRanked
From #IndexMaintLogRanked
Where RowNum = 1;

---Add DBs that don't have entries in the IndexMaintLog table.
---These aren't in the Log table cause they don't have any reindexing entries and maybe
---they failed in a way that didn't log to the table.
INSERT #IndexMaintLogTOPRanked (InstanceID, DBName, Status)
SELECT InstanceID, DBName, 'Missing'
FROM Collector.DBProperties CD
WHERE DBName IN(
SELECT DBName
FROM #DBListMaint
EXCEPT
SELECT DBName  
FROM #IndexMaintLogTOPRanked
)
AND CD.ExecutionDateTime IN (SELECT MAX(ExecutionDateTime) FROM Collector.DBProperties D WHERE D.InstanceID = CD.InstanceID )

---------------------------------------------------------
---------------------------------------------------------
---------------BEGIN Delete Read-only DBs----------------
---------------------------------------------------------
---------------------------------------------------------

DELETE IMR
FROM #IndexMaintLogTOPRanked IMR
INNER JOIN Collector.DBProperties D
ON IMR.InstanceID = D.InstanceID
	AND IMR.DBName = D.DBName
WHERE D.ExecutionDateTime IN (SELECT MAX(ExecutionDateTime) FROM Collector.DBProperties D WHERE D.InstanceID = IMR.InstanceID)
AND D.Status <> ''
---------------------------------------------------------
---------------------------------------------------------
---------------END Delete Read-only DBs------------------
---------------------------------------------------------
---------------------------------------------------------

SELECT '#IndexMaintLogTOPRanked', * FROM #IndexMaintLogTOPRanked




/*********************************************************************************************
Get all servers and databases that have not been reindexed up for greater than the last report period in hours
**********************************************************************************************/

SELECT  
		SL.ServerName,
		DB.InstanceID,
        DB.DBName,
        DB.ReindexThresholdHrs
INTO #Final
FROM #IndexMaintLogTOPRanked DB
INNER JOIN #ServerList SL
ON DB.InstanceID = SL.InstanceID
WHERE DATEDIFF (HH, DB.BatchExecutionDateTime, Getdate()) >  DB.ReindexThresholdHrs
ORDER BY DB.InstanceID, DB.DBName



---- Delete deferred DBs.  If you have a known issue that you think will work itself
---- out in a day or 2 then you can put an entry into Alert.BackupDefer.  This will
---- let you filter it out of the alert for a specified time so it doesn't bother you.

DELETE F
FROM #Final F
INNER JOIN Alert.IndexDefer B
ON F.InstanceID = B.InstanceID
	AND F.DBName = B.DBName
WHERE CAST(GETDATE() AS DATE) < B.DeferEndDate
AND CAST(GETDATE() AS TIME) < B.DeferEndTime


----Delete deferred DBs at the server level.  If there are too many DBs to defer at once,
----then it's easier to defer the entire server until it's worked out.
----This is a hack put in at the last min and can prob be done better.
----Since it's not run that often though the perf really isn't that important.
DELETE F
FROM #Final F
INNER JOIN Alert.IndexDefer B
ON F.InstanceID = B.InstanceID
WHERE CAST(GETDATE() AS DATE) < B.DeferEndDate
AND CAST(GETDATE() AS TIME) < B.DeferEndTime
AND B.DBName = 'All'


----------------------------------------------------------------------------
----------------------------------------------------------------------------
-------------------------BEGIN Fuzzy Lookups--------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------

-- Get unique list of InstanceID, Regex.  An instance can have more than one
-- regex criteria if there are several sets of DBs on that server that have fuzzy lookups.
-- So here, if there's more than 1, this will cycle through them.
-- Normally we'd look for a specific MaintType but here we're interested in New/Retired DBs no matter
-- what the function so we're going to take all of them.


create table #FuzzyLookup
(
InstanceID bigint,
DBName sysname NULL,
Action varchar(10)
)

DECLARE @currUser varchar(100),
		@SQL nvarchar(200),
		@InstanceID bigint,
		@Regex varchar(200),
		@Action varchar(10),
		@FuzzyCMD varchar(2000);

DECLARE DBs CURSOR
READ_ONLY
FOR 
SELECT DISTINCT DFL.InstanceID, DFL.Regex, DFL.Action
FROM dbo.DBMaintFuzzyLookup DFL
INNER JOIN #Final F
ON DFL.InstanceID = F.InstanceID
WHERE DFL.MaintType = 'Reindex'
OR DFL.MaintType = 'All';

OPEN DBs

	FETCH NEXT FROM DBs INTO @InstanceID, @Regex, @Action
	WHILE (@@fetch_status <> -1)
	BEGIN


SET @FuzzyCMD = 
'Powershell "C:\MinionByMidnightDBA\SPPowershellScripts\DBNameFuzzyLookup.ps1 ' + CAST(@InstanceID as varchar(10)) + ' ''' + @Regex + '''"' 

 INSERT #FuzzyLookup(DBName)     
            EXEC xp_cmdshell @FuzzyCMD 

UPDATE #FuzzyLookup
SET InstanceID = @InstanceID,
	Action = @Action
WHERE InstanceID IS NULL

	FETCH NEXT FROM DBs INTO @InstanceID, @Regex, @Action
	END

CLOSE DBs
DEALLOCATE DBs

--Get rid of any rows that aren't actually DBNames.  The cmdshell gives us back some crap with our results.-
DELETE #FuzzyLookup
WHERE 
--DBName NOT IN (SELECT DBName FROM Collector.DBProperties DM2
--						WHERE InstanceID = DM2.InstanceID
--						AND DM2.ExecutionDateTime = (SELECT MAX(DM3.ExecutionDateTime) from Collector.DBProperties DM3 where DM2.InstanceID = DM3.InstanceID)
--						)
DBName IS NULL


--Delete DBs that are meant to be excluded off of the fuzzy search.
DELETE #Final
WHERE DBName IN (SELECT DBName FROM #FuzzyLookup FL
WHERE InstanceID = FL.InstanceID AND DBName = FL.DBName
AND FL.Action = 'Exclude')


----------------------------------------------------------------------------
----------------------------------------------------------------------------
-------------------------END Fuzzy Lookups----------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------



 -----------Save to history

--INSERT History.BackupFullorDiff
--SELECT @ExecutionDateTime, @ServiceLevel,  * 
--FROM #Final;


-- /************************************************************************************
-- Report on the missing reindexes.
 
-- *************************************************************************************/
 
-- -- Count the # of missing reindexes
 
 Select @RowCount = COUNT(*) 
 	From #Final
 
-- -- Set the subject header to report on the # of missing backups
 
set @CurrentSubject = 'Missing ' + CAST(@rowcount as Varchar(4)) + ' Reindex (' + @ServiceLevel + ')' 

SELECT * FROM #Final

---- Put the missing databases table into HTML format
 
--SET @tableHTML =              
--N'<H2>'+ @CurrentSubject + '</H2>' +              
--N'<table border="1">' +              
--N'<tr>
--	<th>ExecutionDate<th>
--	<th>ID</th> 	
--	<th>ServerName</th>   
--	<th>DBName</th>          
--	<th>Table</th>
--	<th>ThresholdHrs</th>
--	<th>Index</th>
--	<th>Status</th>
--</tr>' +           
--CAST ( (Select 
--		td = ExecutionDateTime, '',
--		td = InstanceID, '',
--		td = ServerName, '',
--		td = DBName, '',
--		td = TableName, '',
--		td = ReindexThresholdHrs, '',
--		td = IndexName, '',
--		td = Status, ''
--		From #Final
--		order by ServerName
--		FOR XML PATH('tr'), TYPE               
-- ) AS NVARCHAR(MAX)) +              
--N'</table>' ;              
--set @tableHTML =@tableHTML+'<BR>'    
          


-- DECLARE @ChangeSQL nvarchar(max)
-- If @IncludeChange = 1
-- Begin

--	SET @ChangeSQL = 
--	N'<H2>Change SQL</H2>' +                
-- N'<table border="0">' +                
--    N'<tr>        
--     <th>Run this to change the reporting threshold:</th>                
--</tr>' +  

--CAST ( ( SELECT           
--   td = 'EXEC Setup.BackupReportThreshold ' + '''' + ServerName + '''' + ', ' + '''' + DBName + '''', ''
--   + '' + ', ''' + 'FullDiff'+ '''' + ', ' + 'ThresholdHrs' + '  -- Use ''All'' for DBName to set value for all DBs.'   
--   from         
--  #Final         
--  order by ServerName, DBName                    
-- FOR XML PATH('tr'), TYPE                 
-- ) AS NVARCHAR(MAX) ) +                
-- N'</table>' ;       

--SET @tableHTML = @tableHTML + @ChangeSQL

-- END

-- ----------------------------------------------------------------------


-- DECLARE @ExcludeSQL nvarchar(max)
-- If @IncludeException = 1
-- Begin

--	SET @ExcludeSQL = 
--	N'<H2>Exclude SQL</H2>' +                
-- N'<table border="0">' +                
--    N'<tr>        
--     <th>Run this to exclude backups from report:</th>                
--</tr>' +  

--CAST ( ( SELECT           
--   td = 'EXEC Setup.BackupReportException ' + '''' + ServerName + '''' + ', ' + '''' + DBName + '''', ''
--    + '' + ', ''' + 'FullDiff' + '''' + ', ' + CAST(0 AS varchar(5)) + '  -- Use ''All'' instead of ''FullDiff'' to set value for all DBs.'      
--   from         
--  #Final         
--  order by ServerName, DBName                     
-- FOR XML PATH('tr'), TYPE                 
-- ) AS NVARCHAR(MAX) ) +                
-- N'</table>' ;       

--SET @tableHTML = @tableHTML + @ExcludeSQL

-- END


--  DECLARE @DeferSQL nvarchar(max)
-- If @IncludeDefer = 1
-- Begin

--	SET @DeferSQL = 
--	N'<H2>Defer SQL</H2>' +                
-- N'<table border="0">' +                
--    N'<tr>        
--     <th>Run this to defer backups from report:</th>                
--</tr>' +  

--CAST ( ( SELECT           
--   td = 'EXEC Setup.BackupDefer ' + '''' + ServerName + '''' + ', ' + '''' + DBName + ''', ' + '''' + 'FullDiff' + ''', ' + '''' + CONVERT(varchar(15), GetDate(), 101) + '''' + ', ' + '''' + CONVERT(varchar(15), GetDate() + 1, 101) + ''', ' + '''06:00'''
--    + '  -- Use ''All'' for DBName to set value for all DBs.'   
--   from         
--  #Final         
--  order by ServerName, DBName                    
-- FOR XML PATH('tr'), TYPE                 
-- ) AS NVARCHAR(MAX) ) +                
-- N'</table>' ;       

--SET @tableHTML = @tableHTML + @DeferSQL

-- END
 

--SELECT * FROM #Final

--set @tableHTML =@tableHTML+'***Do NOT reply to the sender; Automated Report***'   

-- --Email 

--IF @RowCount > 0
--BEGIN
--	EXEC msdb.dbo.sp_send_dbmail              
--	@profile_name = @EmailProfile,              
--	@recipients = @Distribn, --             
--	@subject = @CurrentSubject,              
--	@body = @tableHTML,              
--	@body_format = 'HTML'; 
--END


;
GO
/****** Object:  StoredProcedure [Setup].[DiskSpaceExceptionDelete]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Setup].[DiskSpaceExceptionDelete] 
(
@InstanceID int,
@Caption varchar(255)
)

  
AS

SET NOCOUNT ON

DELETE FROM dbo.DriveSpaceExceptions
WHERE InstanceID = @InstanceID
	  AND Caption = @Caption

SELECT 'Deleted', @InstanceID, @Caption



;
GO
/****** Object:  StoredProcedure [dbo].[IndexSettingsDBChoose]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[IndexSettingsDBChoose]

  
AS

/*

This gets the servers that have index settings to push.

Called from IndexSettingsPush.
*/

;WITH cteServersToPush
AS
(SELECT 
S.MgmtDB, I.InstanceID, S1.ServerName, S1.Port
FROM dbo.IndexSettingsDBDefault I
INNER JOIN dbo.ServerMgmtDB S
ON I.InstanceID = S.InstanceID
INNER JOIN dbo.Servers S1
ON I.InstanceID = S1.InstanceID
WHERE I.Push = 1
UNION
SELECT 
S.MgmtDB, I.InstanceID, S1.ServerName, S1.Port
FROM dbo.IndexSettingsDB I
INNER JOIN dbo.ServerMgmtDB S
ON I.InstanceID = S.InstanceID
INNER JOIN dbo.Servers S1
ON I.InstanceID = S1.InstanceID
WHERE I.Push = 1
UNION
SELECT 
S.MgmtDB, I.InstanceID, S1.ServerName, S1.Port
FROM dbo.IndexSettingsTable I
INNER JOIN dbo.ServerMgmtDB S
ON I.InstanceID = S.InstanceID
INNER JOIN dbo.Servers S1
ON I.InstanceID = S1.InstanceID
WHERE I.Push = 1)

SELECT DISTINCT MgmtDB, InstanceID, ServerName, Port FROM cteServersToPush
;
GO
/****** Object:  StoredProcedure [dbo].[IndexMaintSettingsTableInsert]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[IndexMaintSettingsTableInsert]
(
@InstanceID bigint,
@DBName sysname,
@SchemaName varchar(140),
@TableName varchar(140),
@Exclude bit,
@ReindexGroupOrder tinyint,
@ReindexOrder int,
@ReorgThreshold tinyint,
@RebuildThreshold tinyint,
@FILLFACTORopt tinyint,
@PadIndex varchar(3),
@ONLINEopt varchar(3),
@SortInTempDB varchar(3),
@MAXDOPopt tinyint,
@DataCompression varchar(50),
@GetRowCT bit,
@GetPostFragLevel bit,
@UpdateStatsOnDefrag bit,
@StatScanOption varchar(25),
@IgnoreDupKey varchar(3),
@StatsNoRecompute varchar(3),
@AllowRowLocks varchar(3),
@AllowPageLocks varchar(3),
@WaitAtLowPriority bit,
@MaxDurationInMins int,
@AbortAfterWait varchar(20),
@PushToMinion bit,
@LogIndexPhysicalStats bit,
@IndexScanMode varchar(25),
@TablePreCode nvarchar(max),
@TablePostCode nvarchar(max),
@LogProgress bit,
@LogRetDays smallint,
@PartitionReindex bit,
@IsLOB bit,
@TableType bit,
@IncludeUsageDetails bit
)

  
AS

/*
This inserts settings for SettingsTable.
*/

DECLARE @Push bit;
SET @Push = 0;


----You can have only 1 row for each instance so delete the existing ones first.
DELETE dbo.IndexSettingsTable
WHERE InstanceID = @InstanceID
AND	  DBName = @DBName
AND	  SchemaName = @SchemaName
AND	  TableName = @TableName


Insert dbo.IndexSettingsTable 
(
InstanceID,
DBName,
SchemaName,
TableName,
Exclude,
ReindexGroupOrder,
ReindexOrder,
ReorgThreshold,
RebuildThreshold,
FILLFACTORopt,
PadIndex,
ONLINEopt,
SortInTempDB,
MAXDOPopt,
DataCompression,
GetRowCT,
GetPostFragLevel,
UpdateStatsOnDefrag,
StatScanOption,
IgnoreDupKey,
StatsNoRecompute,
AllowRowLocks,
AllowPageLocks,
WaitAtLowPriority,
MaxDurationInMins,
AbortAfterWait,
PushToMinion,
LogIndexPhysicalStats,
IndexScanMode,
TablePreCode,
TablePostCode,
LogProgress,
LogRetDays,
PartitionReindex,
IsLOB,
TableType,
IncludeUsageDetails,
Push,
LastUpdate
)  
VALUES 
(
@InstanceID,
@DBName,
@SchemaName,
@TableName,
@Exclude,
@ReindexGroupOrder,
@ReindexOrder,
@ReorgThreshold,
@RebuildThreshold,
@FILLFACTORopt,
@PadIndex,
@ONLINEopt,
@SortInTempDB,
@MAXDOPopt,
@DataCompression,
@GetRowCT,
@GetPostFragLevel,
@UpdateStatsOnDefrag,
@StatScanOption,
@IgnoreDupKey,
@StatsNoRecompute,
@AllowRowLocks,
@AllowPageLocks,
@WaitAtLowPriority,
@MaxDurationInMins,
@AbortAfterWait,
@PushToMinion,
@LogIndexPhysicalStats,
@IndexScanMode,
@TablePreCode,
@TablePostCode,
@LogProgress,
@LogRetDays,
@PartitionReindex,
@IsLOB,
@TableType,
@IncludeUsageDetails,
@Push,
GETDATE()
)









;
GO
/****** Object:  StoredProcedure [dbo].[IndexMaintSettingsDBInsert]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[IndexMaintSettingsDBInsert]
(
@InstanceID bigint,
@DBName sysname,
@Exclude bit,
@ReindexGroupOrder tinyint,
@ReindexOrder int,
@ReorgThreshold tinyint,
@RebuildThreshold tinyint,
@FILLFACTORopt tinyint,
@PadIndex varchar(3),
@ONLINEopt varchar(3),
@SortInTempDB varchar(3),
@MAXDOPopt tinyint,
@DataCompression varchar(50),
@GetRowCT bit,
@GetPostFragLevel bit,
@UpdateStatsOnDefrag bit,
@StatScanOption varchar(25),
@IgnoreDupKey varchar(3),
@StatsNoRecompute varchar(3),
@AllowRowLocks varchar(3),
@AllowPageLocks varchar(3),
@WaitAtLowPriority bit,
@MaxDurationInMins int,
@AbortAfterWait varchar(20),
@PushToMinion bit,
@LogIndexPhysicalStats bit,
@IndexScanMode varchar(25),
@DBPreCode nvarchar(max),
@DBPostCode nvarchar(max),
@TablePreCode nvarchar(max),
@TablePostCode nvarchar(max),
@LogProgress bit,
@LogRetDays smallint,
@LogLoc varchar(25),
@MinionTriggerPath varchar(1000),
@RecoveryModel varchar(12),
@IncludeUsageDetails bit
)

  
AS

/*
This inserts settings for both SettingsDB and SettingsDBDefault.
*/

DECLARE @Push bit;
SET @Push = 1;

If @DBName = 'MinionDefault'
BEGIN

----You can have only 1 row for each instance so delete the existing ones first.
DELETE dbo.IndexSettingsDBDefault 
WHERE InstanceID = @InstanceID


Insert dbo.IndexSettingsDBDefault 
(
InstanceID,
DBName,
Exclude,
ReindexGroupOrder,
ReindexOrder,
ReorgThreshold,
RebuildThreshold,
FILLFACTORopt,
PadIndex,
ONLINEopt,
SortInTempDB,
MAXDOPopt,
DataCompression,
GetRowCT,
GetPostFragLevel,
UpdateStatsOnDefrag,
StatScanOption,
IgnoreDupKey,
StatsNoRecompute,
AllowRowLocks,
AllowPageLocks,
WaitAtLowPriority,
MaxDurationInMins,
AbortAfterWait,
PushToMinion,
LogIndexPhysicalStats,
IndexScanMode,
DBPreCode,
DBPostCode,
TablePreCode,
TablePostCode,
LogProgress,
LogRetDays,
LogLoc,
MinionTriggerPath,
RecoveryModel,
IncludeUsageDetails,
Push,
LastUpdate
)  
VALUES 
(
@InstanceID,
@DBName,
@Exclude,
@ReindexGroupOrder,
@ReindexOrder,
@ReorgThreshold,
@RebuildThreshold,
@FILLFACTORopt,
@PadIndex,
@ONLINEopt,
@SortInTempDB,
@MAXDOPopt,
@DataCompression,
@GetRowCT,
@GetPostFragLevel,
@UpdateStatsOnDefrag,
@StatScanOption,
@IgnoreDupKey,
@StatsNoRecompute,
@AllowRowLocks,
@AllowPageLocks,
@WaitAtLowPriority,
@MaxDurationInMins,
@AbortAfterWait,
@PushToMinion,
@LogIndexPhysicalStats,
@IndexScanMode,
@DBPreCode,
@DBPostCode,
@TablePreCode,
@TablePostCode,
@LogProgress,
@LogRetDays,
@LogLoc,
@MinionTriggerPath,
@RecoveryModel,
@IncludeUsageDetails,
@Push,
GETDATE()
)
END

If @DBName <> 'MinionDefault'
BEGIN

DELETE dbo.IndexSettingsDBDefault 
WHERE InstanceID = @InstanceID
AND   DBName = @DBName

Insert dbo.IndexSettingsDB
(
InstanceID,
DBName,
Exclude,
ReindexGroupOrder,
ReindexOrder,
ReorgThreshold,
RebuildThreshold,
FILLFACTORopt,
PadIndex,
ONLINEopt,
SortInTempDB,
MAXDOPopt,
DataCompression,
GetRowCT,
GetPostFragLevel,
UpdateStatsOnDefrag,
StatScanOption,
IgnoreDupKey,
StatsNoRecompute,
AllowRowLocks,
AllowPageLocks,
WaitAtLowPriority,
MaxDurationInMins,
AbortAfterWait,
PushToMinion,
LogIndexPhysicalStats,
IndexScanMode,
DBPreCode,
DBPostCode,
TablePreCode,
TablePostCode,
LogProgress,
LogRetDays,
LogLoc,
MinionTriggerPath,
RecoveryModel,
IncludeUsageDetails,
Push,
LastUpdate
)  
VALUES 
(
@InstanceID,
@DBName,
@Exclude,
@ReindexGroupOrder,
@ReindexOrder,
@ReorgThreshold,
@RebuildThreshold,
@FILLFACTORopt,
@PadIndex,
@ONLINEopt,
@SortInTempDB,
@MAXDOPopt,
@DataCompression,
@GetRowCT,
@GetPostFragLevel,
@UpdateStatsOnDefrag,
@StatScanOption,
@IgnoreDupKey,
@StatsNoRecompute,
@AllowRowLocks,
@AllowPageLocks,
@WaitAtLowPriority,
@MaxDurationInMins,
@AbortAfterWait,
@PushToMinion,
@LogIndexPhysicalStats,
@IndexScanMode,
@DBPreCode,
@DBPostCode,
@TablePreCode,
@TablePostCode,
@LogProgress,
@LogRetDays,
@LogLoc,
@MinionTriggerPath,
@RecoveryModel,
@IncludeUsageDetails,
@Push,
GETDATE()
)
END







;
GO
/****** Object:  StoredProcedure [Collector].[IndexmaintLogInsert]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collector].[IndexmaintLogInsert]
(
	@ExecutionDateTime datetime,
	@BatchExecutionDateTime datetime,
	@ServerName sysname,
	@DBName varchar(100),
	@Status VARCHAR(500),
	@Tables varchar(7),
	@RunPrepped bit,
	@PrepOnly bit,
	@ReorgMode varchar(7),
	@NumTablesProcessed int,
	@NumIndexesProcessed int,
	@NumIndexesRebuilt int,
	@NumIndexesReorged int,
	@RecoveryModelChanged bit,
	@RecoveryModelCurrent varchar(12),
	@RecoveryModelReindex varchar(12),
	@SQLVersion varchar(20),
	@SQLEdition varchar(50),
	@DBPreCode nvarchar(max),
	@DBPostCode nvarchar(max),
	@DBPreCodeBeginDateTime datetime,
	@DBPreCodeEndDateTime datetime,
	@DBPostCodeBeginDateTime datetime,
	@DBPostCodeEndDateTime datetime,
	@DBPreCodeRunTimeInSecs int,
	@DBPostCodeRunTimeInSecs int,
	@ExecutionFinishTime datetime,
	@ExecutionRunTimeInSecs int 
)

   
AS


    DECLARE @InstanceID INT  
    
    SET @InstanceID = ( SELECT  InstanceID  
                        FROM    dbo.Servers  with(nolock)
                        WHERE   ServerName = @ServerName  
                      )  


INSERT Collector.IndexmaintLog 
(ExecutionDateTime, BatchExecutionDateTime, InstanceID, DBName, Status, Tables, RunPrepped, PrepOnly, ReorgMode, NumTablesProcessed, NumIndexesProcessed, NumIndexesRebuilt, NumIndexesReorged, RecoveryModelChanged, RecoveryModelCurrent, RecoveryModelReindex, SQLVersion, SQLEdition, DBPreCode, DBPostCode, DBPreCodeBeginDateTime, DBPreCodeEndDateTime, DBPostCodeBeginDateTime, DBPostCodeEndDateTime, DBPreCodeRunTimeInSecs, DBPostCodeRunTimeInSecs, ExecutionFinishTime, ExecutionRunTimeInSecs)
SELECT
@ExecutionDateTime, @BatchExecutionDateTime, @InstanceID, @DBName, @Status, @Tables, @RunPrepped, @PrepOnly, @ReorgMode, @NumTablesProcessed, @NumIndexesProcessed, @NumIndexesRebuilt, @NumIndexesReorged, @RecoveryModelChanged, @RecoveryModelCurrent, @RecoveryModelReindex, @SQLVersion, @SQLEdition, @DBPreCode, @DBPostCode, @DBPreCodeBeginDateTime, @DBPreCodeEndDateTime, @DBPostCodeBeginDateTime, @DBPostCodeEndDateTime, @DBPreCodeRunTimeInSecs, @DBPostCodeRunTimeInSecs, @ExecutionFinishTime, @ExecutionRunTimeInSecs


;
GO
/****** Object:  View [Collector].[IndexMaintLogDetailsCurrent]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[IndexMaintLogDetailsCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion as Version,
			S.SQLEdition as Edition,
			S.Descr,
			D.BatchExecutionDateTime,
			D.DBName,
			D.Status,
			D.TableID,
			D.SchemaName,
			D.TableName,
			D.IndexID,
			D.IndexName,
			D.IndexTypeDesc,
			D.IndexScanMode,
			D.Op,
			D.ONLINEopt,
			D.ReorgThreshold,
			D.RebuildThreshold,
			D.FILLFACTORopt,
			D.PadIndex,
			D.FragLevel,
			D.Stmt,
			D.ReindexGroupOrder,
			D.ReindexOrder,
			D.PreCode,
			D.PostCode,
			D.OpBeginDateTime,
			D.OpEndDateTime,
			D.OpRunTimeInSecs,
			D.TableRowCTBeginDateTime,
			D.TableRowCTEndDateTime,
			D.TableRowCTTimeInSecs,
			D.TableRowCT,
			D.PostFragBeginDateTime,
			D.PostFragEndDateTime,
			D.PostFragTimeInSecs,
			D.PostFragLevel,
			D.UpdateStatsBeginDateTime,
			D.UpdateStatsEndDateTime,
			D.UpdateStatsTimeInSecs,
			D.UpdateStatsStmt,
			D.PreCodeBeginDateTime,
			D.PreCodeEndDateTime,
			D.PreCodeRunTimeInSecs,
			D.PostCodeBeginDateTime,
			D.PostCodeEndDateTime,
			D.PostCodeRunTimeInSecs,
			D.UserSeeks,
			D.UserScans,
			D.UserLookups,
			D.UserUpdates,
			D.LastUserSeek,
			D.LastUserScan,
			D.LastUserLookup,
			D.LastUserUpdate,
			D.SystemSeeks,
			D.SystemScans,
			D.SystemLookups,
			D.SystemUpdates,
			D.LastSystemSeek,
			D.LastSystemScan,
			D.LastSystemLookup,
			D.LastSystemUpdate,
			D.Warnings,
			'This view shows the latest index maintenance results from Minion Reindex. There''s so much excellent info in this table we can''t even begin to talk about it.' AS ViewDesc
    FROM    Collector.IndexMaintLogDetails D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.IndexMaintLogDetails D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL



;
GO
/****** Object:  View [Collector].[IndexMaintLogCurrent]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[IndexMaintLogCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion as Version,
			S.SQLEdition as Edition,
			S.Descr,
			D.BatchExecutionDateTime,
			D.DBName,
			D.Status,
			D.Tables,
			D.RunPrepped,
			D.PrepOnly,
			D.ReorgMode,
			D.NumTablesProcessed,
			D.NumIndexesProcessed,
			D.NumIndexesRebuilt,
			D.NumIndexesReorged,
			D.RecoveryModelChanged,
			D.RecoveryModelCurrent,
			D.RecoveryModelReindex,
			D.SQLVersion,
			D.SQLEdition,
			D.DBPreCode,
			D.DBPostCode,
			D.DBPreCodeBeginDateTime,
			D.DBPreCodeEndDateTime,
			D.DBPostCodeBeginDateTime,
			D.DBPostCodeEndDateTime,
			D.DBPreCodeRunTimeInSecs,
			D.DBPostCodeRunTimeInSecs,
			D.ExecutionFinishTime,
			D.ExecutionRunTimeInSecs,
			D.IncludeDBs,
			D.ExcludeDBs,
			D.RegexDBsIncluded,
			D.RegexDBsExcluded,
			D.Warnings,
			'This view shows the latest index maintenance results from Minion Reindex. There''s so much excellent info in this table we can''t even begin to talk about it.' AS ViewDesc
    FROM    Collector.IndexMaintLog D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.IndexMaintLog D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL



;
GO
/****** Object:  StoredProcedure [dbo].[InstanceConfigValueInsert]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[InstanceConfigValueInsert]
(
@ID int,
@Name varchar(50),
@RunValue bigint
)

  
as

/*
This gets called from InstanceConfigDefaultValuesGET.ps1.
*/

Insert dbo.InstanceConfigValue
(InstanceID, Name, DesiredValue, [Action])
Values
(

@ID,
@Name,
@RunValue,
'Alert'
)

--The default action is 'Alert'.  This is so keep the system from
--changing values on servers w/o the DBA knowing about it.
--So I made it so you have to explicitly set it in order to have it
--enforce the setting.


;
GO
/****** Object:  StoredProcedure [Collector].[InstanceConfigInsert]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[InstanceConfigInsert]
(
@ID int,
@ExecutionDateTime datetime,
@Name varchar(50),
@Minimum bigint,
@Maximum bigint,
@ConfigValue bigint,
@RunValue bigint
)
   
as

Insert Collector.InstanceConfig
(ExecutionDateTime, InstanceID, Name, Minimum, Maximum, ConfigValue, RunValue)
Values
(
@ExecutionDateTime,
@ID,
@Name,
@Minimum,
@Maximum,
@ConfigValue,
@RunValue
)


;
GO
/****** Object:  View [Collector].[InstanceConfigCurrent]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[InstanceConfigCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion as Version,
			S.SQLEdition as Edition,
			S.Descr,
			D.Name,
			D.Minimum,
			D.Maximum,
			D.ConfigValue,
			D.RunValue,
			'This view shows the latest collection for sp_configure values.' AS ViewDesc
    FROM    Collector.InstanceConfig D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.InstanceConfig D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL


;
GO
/****** Object:  StoredProcedure [dbo].[IndexSettingsDBPush]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[IndexSettingsDBPush]
(
@InstanceID BIGINT
)

  
AS

/*

This gets the servers that have index settings to push.
It pushes both defaults and individual DB settings.

Called from IndexSettingsPush.
*/

SELECT 
S.MgmtDB, I.InstanceID, I.DBName, I.Exclude, I.ReindexGroupOrder, I.ReindexOrder, I.ReorgThreshold, I.RebuildThreshold, I.FILLFACTORopt, I.PadIndex, I.ONLINEopt, I.SortInTempDB, I.MAXDOPopt, I.DataCompression, I.GetRowCT, I.GetPostFragLevel, I.UpdateStatsOnDefrag, I.StatScanOption, I.IgnoreDupKey, I.StatsNoRecompute, I.AllowRowLocks, I.AllowPageLocks, I.WaitAtLowPriority, I.MaxDurationInMins, I.AbortAfterWait, I.PushToMinion, I.LogIndexPhysicalStats, I.IndexScanMode, I.DBPreCode, I.DBPostCode, I.TablePreCode, I.TablePostCode, I.LogProgress, I.LogRetDays, I.LogLoc, I.MinionTriggerPath, I.RecoveryModel, I.IncludeUsageDetails, I.Push
FROM dbo.IndexSettingsDBDefault I
INNER JOIN dbo.ServerMgmtDB S
ON I.InstanceID = S.InstanceID
WHERE I.InstanceID = @InstanceID
AND I.Push = 1
UNION
SELECT 
S.MgmtDB, I.InstanceID, I.DBName, I.Exclude, I.ReindexGroupOrder, I.ReindexOrder, I.ReorgThreshold, I.RebuildThreshold, I.FILLFACTORopt, I.PadIndex, I.ONLINEopt, I.SortInTempDB, I.MAXDOPopt, I.DataCompression, I.GetRowCT, I.GetPostFragLevel, I.UpdateStatsOnDefrag, I.StatScanOption, I.IgnoreDupKey, I.StatsNoRecompute, I.AllowRowLocks, I.AllowPageLocks, I.WaitAtLowPriority, I.MaxDurationInMins, I.AbortAfterWait, I.PushToMinion, I.LogIndexPhysicalStats, I.IndexScanMode, I.DBPreCode, I.DBPostCode, I.TablePreCode, I.TablePostCode, I.LogProgress, I.LogRetDays, I.LogLoc, I.MinionTriggerPath, I.RecoveryModel, I.IncludeUsageDetails, I.Push
FROM dbo.IndexSettingsDB I
INNER JOIN dbo.ServerMgmtDB S
ON I.InstanceID = S.InstanceID
WHERE I.InstanceID = @InstanceID
AND I.Push = 1
;
GO
/****** Object:  StoredProcedure [Collector].[ADGroupMemberInsert]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collector].[ADGroupMemberInsert]
(
@ExecutionDateTime	datetime,
@GroupName varchar(200),
@ObjectName	varchar(200),
@IsGroup BIT,
@GroupMember	varchar(100),
@LastLogon	datetime,
@BadLogonCount	bigint,
@PasswordNeverExpires	bit,
@PasswordNotRequired	bit,
@PermittedLogonTimes	bigint,
@PermittedWorkstations	varchar(MAX),
@LastPasswordSet	datetime,
@LastBadPasswordAttempt	nchar(10),
@UserCannotChangePassword	nchar(10),
@Description	nvarchar(MAX),
@DelegationPermitted	bit,
@AccountExpirationDate	datetime,
@AccountLockoutTime	datetime,
@EmailAddress	nvarchar(500),
@Enabled	bit,
@EmployeeID	nvarchar(200),
@VoiceTelephoneNumber	varchar(100),
@DistinguishedName	nvarchar(2000),
@DisplayName	nvarchar(2000),
@SurName	nvarchar(100),
@MiddleName	nvarchar(100),
@GivenName	nvarchar(100),
@Name	nvarchar(200),
@GUID	varchar(200),
@SID	varchar(200),
@SmartcardLogonRequired	nchar(10),
@HomeDirectory	nvarchar(2000),
@HomeDrive	nvarchar(2000),
@AllowReversiblePasswordEncryption	bit
)

   
AS 

INSERT Collector.ADGroupMember(ExecutionDateTime, GroupName, ObjectName, IsGroup, GroupMember, LastLogon, BadLogonCount, PasswordNeverExpires, PasswordNotRequired, PermittedLogonTimes, PermittedWorkstations, LastPasswordSet, LastBadPasswordAttempt, UserCannotChangePassword, Description, DelegationPermitted, AccountExpirationDate, AccountLockoutTime, EmailAddress, Enabled, EmployeeID, VoiceTelephoneNumber, DistinguishedName, DisplayName, SurName, MiddleName, GivenName, Name, GUID, SID, SmartcardLogonRequired, HomeDirectory, HomeDrive, AllowReversiblePasswordEncryption)
SELECT
@ExecutionDateTime,
@GroupName,
@ObjectName,
@IsGroup,
@GroupMember,
@LastLogon,
@BadLogonCount,
@PasswordNeverExpires,
@PasswordNotRequired,
@PermittedLogonTimes,
@PermittedWorkstations,
@LastPasswordSet,
@LastBadPasswordAttempt,
@UserCannotChangePassword,
@Description,
@DelegationPermitted,
@AccountExpirationDate,
@AccountLockoutTime,
@EmailAddress,
@Enabled,
@EmployeeID,
@VoiceTelephoneNumber,
@DistinguishedName,
@DisplayName,
@SurName,
@MiddleName,
@GivenName,
@Name,
@GUID,
@SID,
@SmartcardLogonRequired,
@HomeDirectory,
@HomeDrive,
@AllowReversiblePasswordEncryption
	

;
GO
/****** Object:  StoredProcedure [Alert].[BackupFullorDiff]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Alert].[BackupFullorDiff] 
(@EmailProfile	varchar(1024), 
 @Servicelevel Varchar(10), 
 @IncludeDefer bit = 1,
 @IncludeException bit = 1,
 @IncludeChange bit = 1,
 @debug bit = 0)

  
AS

--  [Alert].[BackupFullorDiff] 'BackupAlertProfile', 'Gold'
SET NOCOUNT ON

/***********************************************************************************

Created By: Sean McCown
Creation Date: 3/6/2012


Purpose: This procedure alerts and reports on failed backups. 

Walkthrough:
      1. Get list of all managed servers and databases
      2. Get latest backup dates
	  3. Filter out exceptions.
	  4. Filter out read-only DBs.
	  5. Filter out deferred DBs.
      6. Send alert email only if there are records to send.

Conventions:

Parameters:
-----------
@EmailProfile - DBmail profile to be used for emailing the report

@ServiceLevel - 3 services levels in the order of importance 'Gold', 'Silver', 'Bronze' 

@Debug - when 1, dumps all tables to console for debug purposes

@Distrib - Email addresses to be alerted on missing backups

@CurrentSubject - Email subject line

@tableHTML - Missing Backup report table in HTML Format

@RowCount - Number of missing backups to be added to the subject line


Tables:
--------
#ServerList - holds a list of all servers at a given service level 

#DBlistMaint - Holds a list of databases for the servers into dblistmaint 

#DBBkupListByDate - Holds a list of all databases and the last backup date

#DBBKListRanked = Holds a list of databases partitioned by server with ranked backup dates. The latest backup rank is 1 
and the oldest backup date is rank N

#DBBKListTopRanked - Holds a list of databases partitioned by server with their "latest" backup date

#Final - Holds final resultset.  Everything has been deleted out of here by now and the email process does just
		 a simple query to get the records.  The reason it was done this way is because there are multiple places
		 where the logic is queried from and if the logic ever changes, this minimizes mistakes.
		 Take for example that you have to query the table 2 times.  Once to see if there are any records
		 to see if the email needs to be sent.  And a 2nd time to query the actual records for the detail that
		 goes into the alert email itself.  If the logic changes when you'll have to change it in both locations
		 so that the count and the details are both correct.  By handling that higher up in the code and letting
		 the email process just query this table in a simple manner, you reduce the complexity of making changes.
Revision History:

***********************************************************************************/

Declare	@CurrentSubject varchar(100), 
		@tableHTML		NVARCHAR(MAX),
		@Distribn		varchar(4000),
		@ExecutionDateTime DATETIME,
		@RowCount		Smallint;
		
		         
Set @RowCount = 0 
Set @Distribn = ''
SET @ExecutionDateTime = GETDATE();

select @Distribn = @Distribn + EmailAddress + '; ' from  dbo.EmailNotification 
order by EmailAddress


/**********************************************************************
Check and delete temp objects if they exist
***********************************************************************/

If OBJECT_ID ('Tempdb..#ServerList') is not null
 Drop table #Serverlist
 
If OBJECT_ID ('Tempdb..#DBlistMaint') is not null
 Drop table #DBListMaint
 
If OBJECT_ID ('Tempdb..#DBBkupListByDate') is not null
 Drop table #DBBkupListByDate
 
If OBJECT_ID ('Tempdb..#DBBKListRanked') is not null
 Drop table #DBBKListRanked

If OBJECT_ID ('Tempdb..#DBBKListTopRanked') is not null
 Drop table #DBBKListTopRanked
 
/************************************************************************************
Get a list of all servers that are sql, active and  with the correct service level
put the result set into the #serverlist table 
**************************************************************************************/

Select ServerName, InstanceID 
into #ServerList
from dbo.Servers
Where ServiceLevel = @ServiceLevel
and IsSQL = 1
and IsActive = 1
And BackupManaged = 1

If @debug = 1
 Select * from #ServerList order by InstanceID
 
/**********************************************************************************************
Collect each servername, instanceid and the databases on that server into a temp database list 
************************************************************************************************/

Select SL.Servername, SL.InstanceID, DM.DBname, DM.BackupalertthresholdHrs, DM.FullPath, DM.PrevFullPath, DM.FullLocType, DM.PrevFullLocType
into #DBListMaint
From DBMaint DM  
Inner join #ServerList SL on SL.InstanceID = DM.InstanceID
WHERE BackupReport = 1 -- Only get DBs that are flagged to be reported on.


--if @debug = 1
-- Begin
--	Select 'Backup list Before GlobalException deletion.'
--	select * from #DBListMaint
-- End

 ---Delete global exceptions.
 DELETE FROM #DBListMaint
Where DBName in (Select DBName from dbo.GlobalDBBackupExceptions)

if @debug = 1
 Begin
	Select 'Backup list after GlobalException deletion.'
	select * from #DBListMaint
 End
 
/******************************************************************************** 
 Get last backup date of each database on a given server into  #DBBkupListByDate
 ********************************************************************************/
 
 -- Rank each backup entry by date
 
Select DP.instanceid, DP.dbname, 
CASE WHEN DP.LastBackup >= DP.LastDiffBackup THEN DP.LastBackup
	 WHEN DP.LastDiffBackup > DP.LastBackup THEN DP.LastDiffBackup
END AS LastBackup, 
DP.DBReadOnly,
DP.Status,
ROW_NUMBER() over(partition by DP.Instanceid, DP.dbname order by DP.dbname, DP.ExecutionDateTime desc) as RowNum
,DLM.BackupalertthresholdHrs, FullPath, PrevFullPath, FullLocType, PrevFullLocType 
Into #DBBKListRanked 
from Collector.DBProperties DP(Nolock)
INNER JOIN #DBListMaint DLM
ON DP.InstanceID = DLM.InstanceID
AND DP.DBName = DLM.DBName; -- Here again looking at only the DBs we're concerned about.


----Delete ReadOnly DBs because they won't be backed up often enough to be determined by this process.
DELETE FROM #DBBKListRanked
WHERE DBReadOnly = 1

----Delete OFFLINE DBs.
DELETE FROM #DBBKListRanked
WHERE Status LIKE '%Offline%'

Select * into #DBBKListTopRanked
From #DBBKListRanked
Where RowNum = 1

--select * from #DBBKListTopRanked where instanceid = 3

 If @debug = 1
  Begin
   Select 'Top ranked backup DBs and Backup Dates with RO DBs deleted.'
   Select * From #DBBKListTopRanked
  End 

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
----Set location paths so local backup locations paths are turned into UNC.
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--Current path
UPDATE DL
SET FullPath = '\\' + SL.ServerName + '\' + REPLACE(FullPath, ':', '$') + SL.ServerName + '\' + DL.DBName
from #DBBKListTopRanked DL
INNER JOIN #ServerList SL
ON DL.InstanceID = SL.InstanceID
WHERE FullLocType = 'Local'

--Previous path
UPDATE DL
SET PrevFullPath = '\\' + SL.ServerName + '\' + REPLACE(PrevFullPath, ':', '$') + SL.ServerName + '\' + DL.DBName
from #DBBKListTopRanked DL
INNER JOIN #ServerList SL
ON DL.InstanceID = SL.InstanceID
WHERE PrevFullLocType = 'Local'

--Current path NAS
UPDATE DL
SET FullPath = FullPath + '\' + SL.ServerName + '\' + DL.DBName
from #DBBKListTopRanked DL
INNER JOIN #ServerList SL
ON DL.InstanceID = SL.InstanceID
WHERE FullLocType = 'NAS'

--Previous path NAS 
UPDATE DL
SET PrevFullPath = PrevFullPath + '\' + SL.ServerName + '\' + DL.DBName
from #DBBKListTopRanked DL
INNER JOIN #ServerList SL
ON DL.InstanceID = SL.InstanceID
WHERE PrevFullLocType = 'NAS'

/*********************************************************************************************
Get all servers and databases that have not been backed up for greater than the last report period in hours
**********************************************************************************************/

SELECT  
		SL.ServerName,
		DB.InstanceID ,
        DB.DBName ,
        DB.LastBackup ,
        DB.DBReadOnly ,
        DB.BackupalertthresholdHrs ,
		DB.FullPath ,
		DB.PrevFullPath
INTO #Final
FROM #DBBKListTopRanked DB
INNER JOIN #ServerList SL
ON DB.InstanceID = SL.InstanceID
WHERE DATEDIFF (HH, DB.Lastbackup, Getdate()) >  DB.BackupalertthresholdHrs
ORDER BY DB.InstanceID, DB.DBName



If @debug = 1 
Begin
	Select 'Get a list of servers that are affected by failing backups based on filtered criteria' 
	 
SELECT * FROM #Final

END

---- Delete deferred DBs.  If you have a known issue that you think will work itself
---- out in a day or 2 then you can put an entry into Alert.BackupDefer.  This will
---- let you filter it out of the alert for a specified time so it doesn't bother you.

DELETE F
FROM #Final F
INNER JOIN Alert.BackupDefer B
ON F.InstanceID = B.InstanceID
	AND F.DBName = B.DBName
WHERE CAST(GETDATE() AS DATE) < B.DeferEndDate
AND B.BackupType = 'FullDiff'


----Delete deferred DBs at the server level.  If there are too many DBs to defer at once,
----then it's easier to defer the entire server until it's worked out.
----This is a hack put in at the last min and can prob be done better.
----Since it's not run that often though the perf really isn't that important.
DELETE F
FROM #Final F
INNER JOIN Alert.BackupDefer B
ON F.InstanceID = B.InstanceID
WHERE CAST(GETDATE() AS DATE) < B.DeferEndDate
AND B.BackupType = 'FullDiff'
AND B.DBName = 'All'


----------------------------------------------------------------------------
----------------------------------------------------------------------------
-------------------------BEGIN Fuzzy Lookups--------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------

-- Get unique list of InstanceID, Regex.  An instance can have more than one
-- regex criteria if there are several sets of DBs on that server that have fuzzy lookups.
-- So here, if there's more than 1, this will cycle through them.
-- Normally we'd look for a specific MaintType but here we're interested in New/Retired DBs no matter
-- what the function so we're going to take all of them.


create table #FuzzyLookup
(
InstanceID bigint,
DBName sysname NULL,
Action varchar(10)
)

DECLARE @currUser varchar(100),
		@SQL nvarchar(200),
		@InstanceID bigint,
		@Regex varchar(200),
		@Action varchar(10),
		@FuzzyCMD varchar(2000);

DECLARE DBs CURSOR
READ_ONLY
FOR 
SELECT DISTINCT DFL.InstanceID, DFL.Regex, DFL.Action
FROM dbo.DBMaintFuzzyLookup DFL
INNER JOIN #Final F
ON DFL.InstanceID = F.InstanceID
WHERE DFL.MaintType = 'Backup'
OR DFL.MaintType = 'All';

OPEN DBs

	FETCH NEXT FROM DBs INTO @InstanceID, @Regex, @Action
	WHILE (@@fetch_status <> -1)
	BEGIN


SET @FuzzyCMD = 
'Powershell "C:\MinionByMidnightDBA\SPPowershellScripts\DBNameFuzzyLookup.ps1 ' + CAST(@InstanceID as varchar(10)) + ' ''' + @Regex + '''"' 

 INSERT #FuzzyLookup(DBName)     
            EXEC xp_cmdshell @FuzzyCMD 

UPDATE #FuzzyLookup
SET InstanceID = @InstanceID,
	Action = @Action
WHERE InstanceID IS NULL

	FETCH NEXT FROM DBs INTO @InstanceID, @Regex, @Action
	END

CLOSE DBs
DEALLOCATE DBs

--Get rid of any rows that aren't actually DBNames.  The cmdshell gives us back some crap with our results.-
DELETE #FuzzyLookup
WHERE 
--DBName NOT IN (SELECT DBName FROM Collector.DBProperties DM2
--						WHERE InstanceID = DM2.InstanceID
--						AND DM2.ExecutionDateTime = (SELECT MAX(DM3.ExecutionDateTime) from Collector.DBProperties DM3 where DM2.InstanceID = DM3.InstanceID)
--						)
DBName IS NULL


--Delete DBs that are meant to be excluded off of the fuzzy search.
DELETE #Final
WHERE DBName IN (SELECT DBName FROM #FuzzyLookup FL
WHERE InstanceID = FL.InstanceID AND DBName = FL.DBName
AND FL.Action = 'Exclude')


----------------------------------------------------------------------------
----------------------------------------------------------------------------
-------------------------END Fuzzy Lookups----------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------






If @debug = 1
 Begin 
	 Select 'Get a list of servers that are affected by failing backups with filteration'
	 Select distinct servername from #Final
 End
 

 -----------Save to history

INSERT History.BackupFullorDiff
SELECT @ExecutionDateTime, @ServiceLevel,  * 
FROM #Final;


-- /************************************************************************************
-- Report on the missing backups
 
-- *************************************************************************************/
 
-- -- Count the # of missing backups
 
 Select @RowCount = COUNT(*) 
 	From #Final
 
-- -- Set the subject header to report on the # of missing backups
 
set @CurrentSubject = 'Missing ' + CAST(@rowcount as Varchar(4)) + ' F/D Backups (' + @ServiceLevel + ')' 

---- Put the missing databases table into HTML format
 
SET @tableHTML =              
N'<H2>'+ @CurrentSubject + '</H2>' +              
N'<table border="1">' +              
N'<tr>
	<th>ID</th> 	
	<th>Server Name</th>   
	<th>DB Name</th>          
	<th>Last Backup</th>
	<th>BackupPath</th>
	<th>PrevPath</th>
</tr>' +           
CAST ( (Select 
		td = InstanceID, '',
		td = Servername, '',
		td = DBname, '',
		td = CAST(LastBackup AS Date), '',
		td = FullPath, '',
		td = PrevFullPath, ''
		From #Final
		order by ServerName
		FOR XML PATH('tr'), TYPE               
 ) AS NVARCHAR(MAX)) +              
N'</table>' ;              
set @tableHTML =@tableHTML+'<BR>'    
          


 DECLARE @ChangeSQL nvarchar(max)
 If @IncludeChange = 1
 Begin

	SET @ChangeSQL = 
	N'<H2>Change SQL</H2>' +                
 N'<table border="0">' +                
    N'<tr>        
     <th>Run this to change the reporting threshold:</th>                
</tr>' +  

CAST ( ( SELECT           
   td = 'EXEC Setup.BackupReportThreshold ' + '''' + ServerName + '''' + ', ' + '''' + DBName + '''', ''
   + '' + ', ''' + 'FullDiff'+ '''' + ', ' + 'ThresholdHrs' + '  -- Use ''All'' for DBName to set value for all DBs.'   
   from         
  #Final         
  order by ServerName, DBName                    
 FOR XML PATH('tr'), TYPE                 
 ) AS NVARCHAR(MAX) ) +                
 N'</table>' ;       

SET @tableHTML = @tableHTML + @ChangeSQL

 END

 ----------------------------------------------------------------------


 DECLARE @ExcludeSQL nvarchar(max)
 If @IncludeException = 1
 Begin

	SET @ExcludeSQL = 
	N'<H2>Exclude SQL</H2>' +                
 N'<table border="0">' +                
    N'<tr>        
     <th>Run this to exclude backups from report:</th>                
</tr>' +  

CAST ( ( SELECT           
   td = 'EXEC Setup.BackupReportException ' + '''' + ServerName + '''' + ', ' + '''' + DBName + '''', ''
    + '' + ', ''' + 'FullDiff' + '''' + ', ' + CAST(0 AS varchar(5)) + '  -- Use ''All'' instead of ''FullDiff'' to set value for all DBs.'      
   from         
  #Final         
  order by ServerName, DBName                     
 FOR XML PATH('tr'), TYPE                 
 ) AS NVARCHAR(MAX) ) +                
 N'</table>' ;       

SET @tableHTML = @tableHTML + @ExcludeSQL

 END


  DECLARE @DeferSQL nvarchar(max)
 If @IncludeDefer = 1
 Begin

	SET @DeferSQL = 
	N'<H2>Defer SQL</H2>' +                
 N'<table border="0">' +                
    N'<tr>        
     <th>Run this to defer backups from report:</th>                
</tr>' +  

CAST ( ( SELECT           
   td = 'EXEC Setup.BackupDefer ' + '''' + ServerName + '''' + ', ' + '''' + DBName + ''', ' + '''' + 'FullDiff' + ''', ' + '''' + CONVERT(varchar(15), GetDate(), 101) + '''' + ', ' + '''' + CONVERT(varchar(15), GetDate() + 1, 101) + ''', ' + '''06:00'''
    + '  -- Use ''All'' for DBName to set value for all DBs.'   
   from         
  #Final         
  order by ServerName, DBName                    
 FOR XML PATH('tr'), TYPE                 
 ) AS NVARCHAR(MAX) ) +                
 N'</table>' ;       

SET @tableHTML = @tableHTML + @DeferSQL

 END
 

SELECT * FROM #Final

set @tableHTML =@tableHTML+'***Do NOT reply to the sender; Automated Report***'   

 --Email 

IF @RowCount > 0
BEGIN
	EXEC msdb.dbo.sp_send_dbmail              
	@profile_name = @EmailProfile,              
	@recipients = @Distribn, --             
	@subject = @CurrentSubject,              
	@body = @tableHTML,              
	@body_format = 'HTML'; 
END


;
GO
/****** Object:  StoredProcedure [Alert].[BackupFullDiffCT]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Alert].[BackupFullDiffCT] 
 (
 @Servicelevel Varchar(10), 
 @debug bit = 0)

   

AS

SET NOCOUNT ON

/***********************************************************************************

Created By: Sean McCown
Creation Date: 3/6/2012


Purpose: This procedure alerts and reports on failed backups. 

Walkthrough:
      1. Get list of all managed servers and databases
      2. Get latest backup dates
      3. Report on missing backup based on backup thresholds of each database

Conventions:

Parameters:
-----------
@EmailProfile - DBmail profile to be used for emailing the report

@ServiceLevel - 3 services levels in the order of importance 'Gold', 'Silver', 'Bronze' 

@Debug - when 1, dumps all tables to console for debug purposes

@Distrib - Email addresses to be alterted on missing backups

@CurrentSubject - Email subject line

@tableHTML - Missing Backup report table in HTML Format

@RowCount - Number of missing backups to be added to the subject line


Tables:
--------
#ServerList - holds a list of all servers at a given service level 

#DBlistMaint - Holds a list of databases for the servers into dblistmaint 

#DBBkupListByDate - Holds a list of all databases and the last backup date

#DBBKListRanked = Holds a list of databases partitioned by server with ranked backup dates. The latest backup rank is 1 
and the oldest backup date is rank N

#DBBKListTopRanked - Holds a list of databases partitioned by server with their "latest" backup date

Revision History:

***********************************************************************************/

Declare	@CurrentSubject varchar(100), 
		@tableHTML		NVARCHAR(MAX),
		@Distribn		varchar(4000),
		@RowCount		Smallint;
		
		         
	Set @RowCount = 0 
	Set @Distribn = 'sean.mccown@baylorhealth.edu' 


/**********************************************************************
Check and delete temp objects if they exist
***********************************************************************/

If OBJECT_ID ('Tempdb..#ServerList') is not null
 Drop table #Serverlist
 
If OBJECT_ID ('Tempdb..#DBlistMaint') is not null
 Drop table #DBListMaint
 
If OBJECT_ID ('Tempdb..#DBBkupListByDate') is not null
 Drop table #DBBkupListByDate
 
If OBJECT_ID ('Tempdb..#DBBKListRanked') is not null
 Drop table #DBBKListRanked

If OBJECT_ID ('Tempdb..#DBBKListTopRanked') is not null
 Drop table #DBBKListTopRanked
 
/************************************************************************************
Get a list of all servers that are sql, active and  with the correct service level
put the result set into the #serverlist table 
**************************************************************************************/

Select ServerName, [InstanceID] as InstanceID 
into #ServerList
from dbo.Servers
Where ServiceLevel = @ServiceLevel
and IsSQL = 1
and IsActive = 1
And BackupManaged = 1

If @debug = 1
 Select * from #ServerList order by InstanceID
 
/**********************************************************************************************
Collect each servername, instanceid and the databases on that server into a temp database list 
************************************************************************************************/

Select SL.Servername, SL.InstanceID, DM.DBname, DM.BackupAlertThresholdHrs 
into #DBListMaint
From DBMaint DM  
Inner join #ServerList SL on SL.InstanceID = DM.InstanceID
WHERE BackupReport = 1 -- Only get DBs that are flagged to be reported on.


--if @debug = 1
-- Begin
--	Select 'Backup list Before GlobalException deletion.'
--	select * from #DBListMaint
-- End

 ---Delete global exceptions.
 DELETE FROM #DBListMaint
Where DBName in (Select DBName from dbo.GlobalDBBackupExceptions)

if @debug = 1
 Begin
	Select 'Backup list after GlobalException deletion.'
	select * from #DBListMaint
 End
 
/******************************************************************************** 
 Get last backup date of each database on a given server into  #DBBkupListByDate
 ********************************************************************************/
 
-- Rank each backup entry by date
 
Select DP.instanceid, DP.dbname, DP.LastBackup, DP.DBReadOnly, 
ROW_NUMBER() over(partition by DP.Instanceid, DP.dbname order by DP.dbname, DP.ExecutionDateTime desc) as RowNum
,DLM.BackupAlertThresholdHrs
Into #DBBKListRanked 
from Collector.DBProperties DP(Nolock)
INNER JOIN #DBListMaint DLM
ON DP.InstanceID = DLM.InstanceID
AND DP.DBName = DLM.DBName; -- Here again looking at only the DBs we're concerned about.

----Delete ReadOnly DBs because they won't be backed up often enough to be determined by this process.
DELETE FROM #DBBKListRanked
WHERE DBReadOnly = 1


Select * into #DBBKListTopRanked
From #DBBKListRanked
Where RowNum = 1

 If @debug = 1
  Begin
   Select 'Top ranked backup DBs and Backup Dates with RO DBs deleted.'
   Select * From #DBBKListTopRanked
  End 


/*********************************************************************************************
Get all servers and databases that have not been backed up for greater than the last 24 hours
**********************************************************************************************/

SELECT  
		SL.ServerName,
		DB.InstanceID ,
        DB.DBName ,
        DB.LastBackup ,
        DB.DBReadOnly ,
        DB.BackupAlertThresholdHrs 
INTO #Final
FROM #DBBKListTopRanked DB
INNER JOIN #ServerList SL
ON DB.InstanceID = SL.InstanceID
WHERE DATEDIFF (HH, DB.Lastbackup, Getdate()) >  DB.BackupAlertThresholdHrs
ORDER BY DB.InstanceID, DB.DBName


If @debug = 1 
Begin
	Select 'Get a list of servers that are affected by failing backups based on filtered criteria' 
	 
SELECT * FROM #Final

End
---- Get unique server names to see how many servers are affected

If @debug = 1
 Begin 
	 Select 'Get a list of servers that are affected by failing backups with filteration'
	 Select distinct servername from #Final
 End
 
 SELECT ServerName, COUNT(*) AS CT
 FROM #Final
 GROUP BY ServerName
 ORDER BY CT DESC



;
GO
/****** Object:  StoredProcedure [Alert].[BackupAlertWork]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Alert].[BackupAlertWork] 
 (
 @Servicelevel Varchar(10), 
 @debug bit = 0)

  

AS

SET NOCOUNT ON

/***********************************************************************************

Created By: Sean McCown
Creation Date: 3/6/2012


Purpose: This procedure alerts and reports on failed backups. 

Walkthrough:
      1. Get list of all managed servers and databases
      2. Get latest backup dates
      3. Report on missing backup based on backup thresholds of each database

Conventions:

Parameters:
-----------
@EmailProfile - DBmail profile to be used for emailing the report

@ServiceLevel - 3 services levels in the order of importance 'Gold', 'Silver', 'Bronze' 

@Debug - when 1, dumps all tables to console for debug purposes

@Distrib - Email addresses to be alterted on missing backups

@CurrentSubject - Email subject line

@tableHTML - Missing Backup report table in HTML Format

@RowCount - Number of missing backups to be added to the subject line


Tables:
--------
#ServerList - holds a list of all servers at a given service level 

#DBlistMaint - Holds a list of databases for the servers into dblistmaint 

#DBBkupListByDate - Holds a list of all databases and the last backup date

#DBBKListRanked = Holds a list of databases partitioned by server with ranked backup dates. The latest backup rank is 1 
and the oldest backup date is rank N

#DBBKListTopRanked - Holds a list of databases partitioned by server with their "latest" backup date

Revision History:

***********************************************************************************/

Declare	@CurrentSubject varchar(100), 
		@tableHTML		NVARCHAR(MAX),
		@Distribn		varchar(4000),
		@RowCount		Smallint;
		
		         
	Set @RowCount = 0 
	Set @Distribn = 'sean.mccown@baylorhealth.edu' 


/**********************************************************************
Check and delete temp objects if they exist
***********************************************************************/

If OBJECT_ID ('Tempdb..#ServerList') is not null
 Drop table #Serverlist
 
If OBJECT_ID ('Tempdb..#DBlistMaint') is not null
 Drop table #DBListMaint
 
If OBJECT_ID ('Tempdb..#DBBkupListByDate') is not null
 Drop table #DBBkupListByDate
 
If OBJECT_ID ('Tempdb..#DBBKListRanked') is not null
 Drop table #DBBKListRanked

If OBJECT_ID ('Tempdb..#DBBKListTopRanked') is not null
 Drop table #DBBKListTopRanked
 
/************************************************************************************
Get a list of all servers that are sql, active and  with the correct service level
put the result set into the #serverlist table 
**************************************************************************************/

Select ServerName, [InstanceID] as InstanceID 
into #ServerList
from dbo.Servers
Where ServiceLevel = @ServiceLevel
and IsSQL = 1
and IsActive = 1
And BackupManaged = 1

If @debug = 1
 Select * from #ServerList order by InstanceID
 
/**********************************************************************************************
Collect each servername, instanceid and the databases on that server into a temp database list 
************************************************************************************************/

Select SL.Servername, SL.InstanceID, DM.DBname, DM.BackupAlertThreshold 
into #DBListMaint
From DBMaint DM  
Inner join #ServerList SL on SL.InstanceID = DM.InstanceID
WHERE BackupReport = 1 -- Only get DBs that are flagged to be reported on.


--if @debug = 1
-- Begin
--	Select 'Backup list Before GlobalException deletion.'
--	select * from #DBListMaint
-- End

 ---Delete global exceptions.
 DELETE FROM #DBListMaint
Where DBName in (Select DBName from dbo.GlobalDBBackupExceptions)

if @debug = 1
 Begin
	Select 'Backup list after GlobalException deletion.'
	select * from #DBListMaint
 End
 
/******************************************************************************** 
 Get last backup date of each database on a given server into  #DBBkupListByDate
 ********************************************************************************/
 
-- Rank each backup entry by date
 
Select DP.instanceid, DP.dbname, DP.LastBackup, DP.DBReadOnly, 
ROW_NUMBER() over(partition by DP.Instanceid, DP.dbname order by DP.dbname, DP.ExecutionDateTime desc) as RowNum
,DLM.BackupAlertThreshold
Into #DBBKListRanked 
from Collector.DBProperties DP(Nolock)
INNER JOIN #DBListMaint DLM
ON DP.InstanceID = DLM.InstanceID
AND DP.DBName = DLM.DBName; -- Here again looking at only the DBs we're concerned about.

----Delete ReadOnly DBs because they won't be backed up often enough to be determined by this process.
DELETE FROM #DBBKListRanked
WHERE DBReadOnly = 1


Select * into #DBBKListTopRanked
From #DBBKListRanked
Where RowNum = 1

 If @debug = 1
  Begin
   Select 'Top ranked backup DBs and Backup Dates with RO DBs deleted.'
   Select * From #DBBKListTopRanked
  End 


/*********************************************************************************************
Get all servers and databases that have not been backed up for greater than the last 24 hours
**********************************************************************************************/

SELECT  
		SL.ServerName,
		DB.InstanceID ,
        DB.DBName ,
        DB.LastBackup ,
        DB.DBReadOnly ,
        DB.BackUpAlertThreshold 
INTO #Final
FROM #DBBKListTopRanked DB
INNER JOIN #ServerList SL
ON DB.InstanceID = SL.InstanceID
WHERE DATEDIFF (HH, DB.Lastbackup, Getdate()) >  DB.BackUpAlertThreshold
ORDER BY DB.InstanceID, DB.DBName


If @debug = 1 
Begin
	Select 'Get a list of servers that are affected by failing backups based on filtered criteria' 
	 
SELECT * FROM #Final

End
---- Get unique server names to see how many servers are affected

If @debug = 1
 Begin 
	 Select 'Get a list of servers that are affected by failing backups with filteration'
	 Select distinct servername from #Final
 End
 
 SELECT ServerName, COUNT(*) AS CT
 FROM #Final
 GROUP BY ServerName
 ORDER BY CT DESC



;
GO
/****** Object:  StoredProcedure [Alert].[BackupAlertCT]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Alert].[BackupAlertCT] 
 (
 @Servicelevel Varchar(10), 
 @debug bit = 0)

  

AS

SET NOCOUNT ON

/***********************************************************************************

Created By: Sean McCown
Creation Date: 3/6/2012


Purpose: This procedure alerts and reports on failed backups. 

Walkthrough:
      1. Get list of all managed servers and databases
      2. Get latest backup dates
      3. Report on missing backup based on backup thresholds of each database

Conventions:

Parameters:
-----------
@EmailProfile - DBmail profile to be used for emailing the report

@ServiceLevel - 3 services levels in the order of importance 'Gold', 'Silver', 'Bronze' 

@Debug - when 1, dumps all tables to console for debug purposes

@Distrib - Email addresses to be alterted on missing backups

@CurrentSubject - Email subject line

@tableHTML - Missing Backup report table in HTML Format

@RowCount - Number of missing backups to be added to the subject line


Tables:
--------
#ServerList - holds a list of all servers at a given service level 

#DBlistMaint - Holds a list of databases for the servers into dblistmaint 

#DBBkupListByDate - Holds a list of all databases and the last backup date

#DBBKListRanked = Holds a list of databases partitioned by server with ranked backup dates. The latest backup rank is 1 
and the oldest backup date is rank N

#DBBKListTopRanked - Holds a list of databases partitioned by server with their "latest" backup date

Revision History:

***********************************************************************************/

Declare	@CurrentSubject varchar(100), 
		@tableHTML		NVARCHAR(MAX),
		@Distribn		varchar(4000),
		@RowCount		Smallint;
		
		         
	Set @RowCount = 0 
	Set @Distribn = 'sean.mccown@baylorhealth.edu' 


/**********************************************************************
Check and delete temp objects if they exist
***********************************************************************/

If OBJECT_ID ('Tempdb..#ServerList') is not null
 Drop table #Serverlist
 
If OBJECT_ID ('Tempdb..#DBlistMaint') is not null
 Drop table #DBListMaint
 
If OBJECT_ID ('Tempdb..#DBBkupListByDate') is not null
 Drop table #DBBkupListByDate
 
If OBJECT_ID ('Tempdb..#DBBKListRanked') is not null
 Drop table #DBBKListRanked

If OBJECT_ID ('Tempdb..#DBBKListTopRanked') is not null
 Drop table #DBBKListTopRanked
 
/************************************************************************************
Get a list of all servers that are sql, active and  with the correct service level
put the result set into the #serverlist table 
**************************************************************************************/

Select ServerName, [InstanceID] as InstanceID 
into #ServerList
from dbo.Servers
Where ServiceLevel = @ServiceLevel
and IsSQL = 1
and IsActive = 1
And BackupManaged = 1

If @debug = 1
 Select * from #ServerList order by InstanceID
 
/**********************************************************************************************
Collect each servername, instanceid and the databases on that server into a temp database list 
************************************************************************************************/

Select SL.Servername, SL.InstanceID, DM.DBname, DM.BackupAlertThresholdHrs 
into #DBListMaint
From DBMaint DM  
Inner join #ServerList SL on SL.InstanceID = DM.InstanceID
WHERE BackupReport = 1 -- Only get DBs that are flagged to be reported on.


--if @debug = 1
-- Begin
--	Select 'Backup list Before GlobalException deletion.'
--	select * from #DBListMaint
-- End

 ---Delete global exceptions.
 DELETE FROM #DBListMaint
Where DBName in (Select DBName from dbo.GlobalDBBackupExceptions)

if @debug = 1
 Begin
	Select 'Backup list after GlobalException deletion.'
	select * from #DBListMaint
 End
 
/******************************************************************************** 
 Get last backup date of each database on a given server into  #DBBkupListByDate
 ********************************************************************************/
 
-- Rank each backup entry by date
 
Select DP.instanceid, DP.dbname, DP.LastBackup, DP.DBReadOnly, 
ROW_NUMBER() over(partition by DP.Instanceid, DP.dbname order by DP.dbname, DP.ExecutionDateTime desc) as RowNum
,DLM.BackupAlertThresholdHrs
Into #DBBKListRanked 
from Collector.DBProperties DP(Nolock)
INNER JOIN #DBListMaint DLM
ON DP.InstanceID = DLM.InstanceID
AND DP.DBName = DLM.DBName; -- Here again looking at only the DBs we're concerned about.

----Delete ReadOnly DBs because they won't be backed up often enough to be determined by this process.
DELETE FROM #DBBKListRanked
WHERE DBReadOnly = 1


Select * into #DBBKListTopRanked
From #DBBKListRanked
Where RowNum = 1

 If @debug = 1
  Begin
   Select 'Top ranked backup DBs and Backup Dates with RO DBs deleted.'
   Select * From #DBBKListTopRanked
  End 


/*********************************************************************************************
Get all servers and databases that have not been backed up for greater than the last 24 hours
**********************************************************************************************/

SELECT  
		SL.ServerName,
		DB.InstanceID ,
        DB.DBName ,
        DB.LastBackup ,
        DB.DBReadOnly ,
        DB.BackupAlertThresholdHrs 
INTO #Final
FROM #DBBKListTopRanked DB
INNER JOIN #ServerList SL
ON DB.InstanceID = SL.InstanceID
WHERE DATEDIFF (HH, DB.Lastbackup, Getdate()) >  DB.BackupAlertThresholdHrs
ORDER BY DB.InstanceID, DB.DBName


If @debug = 1 
Begin
	Select 'Get a list of servers that are affected by failing backups based on filtered criteria' 
	 
SELECT * FROM #Final

End
---- Get unique server names to see how many servers are affected

If @debug = 1
 Begin 
	 Select 'Get a list of servers that are affected by failing backups with filteration'
	 Select distinct servername from #Final
 End
 
 SELECT ServerName, COUNT(*) AS CT
 FROM #Final
 GROUP BY ServerName
 ORDER BY CT DESC



;
GO
/****** Object:  StoredProcedure [DBFile].[AutoGrowChange]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [DBFile].[AutoGrowChange]
(
@InstanceID int = NULL,
@ServerName varchar(100) = NULL,
@DBName varchar(100),
@DBFileID int = NULL,
@DBFileName varchar(100) = NULL,
@IsAutoGrow bit,
@AutoGrowType varchar(10),
@AutoGrowValue bigint
)

  
AS


Declare @ID int;

---Get the ServerName if it wasn't passed in.
If @ServerName IS NULL
	BEGIN
	SET @ServerName = (SELECT ServerName from dbo.Servers
					WHERE InstanceID = @InstanceID );
	END	
	
---Get the InstanceID if it wasn't passed in.
If @InstanceID IS NULL
	BEGIN
	SET @InstanceID = (SELECT InstanceID from dbo.Servers
					WHERE ServerName = @ServerName );
	END	

---Get the FileID if it wasn't passed in.
If @DBFileID IS NULL
	BEGIN
	SET @DBFileID = (SELECT DBFileID from dbo.DBFilePropertiesConfig
					WHERE InstanceID = @InstanceID and DBName = @DBName and DBFileName = @DBFileName);
	END					

---Get the FileName if it wasn't passed in.
If @DBFileName IS NULL
	BEGIN
	SET @DBFileName = (SELECT DBFileName from dbo.DBFilePropertiesConfig
					WHERE InstanceID = @InstanceID and DBName = @DBName and DBFileID = @DBFileID);
	END	

---Get the ID of the File being changed.

	SET @ID = (SELECT ID from dbo.DBFilePropertiesConfig
					WHERE InstanceID = @InstanceID and DBName = @DBName and DBFileID = @DBFileID  and DBFileName = @DBFileName);


If @IsAutoGrow = 0
BEGIN
	SET @AutoGrowType = 'NONE';
	SET @AutoGrowValue = 0;
END

-------Convert everything to KB to make it uniform	
--If @IsAutoGrow = 1
--BEGIN
--	If @AutoGrowType = 'MB'
--	Begin
--		SET @AutoGrowValue = dbo.MBtoKB(@AutoGrowValue)
--		SET @AutoGrowType = 'KB'
--	End
	
--	If @AutoGrowType = 'GB'
--	Begin
--		SET @AutoGrowValue = dbo.GBtoKB(@AutoGrowValue);
--		SET @AutoGrowType = 'KB'
--	End
	
--	If @AutoGrowType = 'TB'
--	Begin
--		SET @AutoGrowValue = dbo.TBtoKB(@AutoGrowValue);
--		SET @AutoGrowType = 'KB'
--	End	
-----End Convert to KB	
	
--END


UPDATE dbo.DBFilePropertiesConfig
SET IsAutoGrow = @IsAutoGrow,
	AutoGrowType = @AutoGrowType,
	AutoGrowValue = @AutoGrowValue,
	Push = 1
WHERE ID = @ID

SELECT S.ServerName, DC.* 
from dbo.DBFilePropertiesConfig DC
Inner Join dbo.Servers S
ON DC.InstanceID = S.InstanceID
WHERE DC.ID = @ID



;
GO
/****** Object:  StoredProcedure [Collector].[ADGroupListGet]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[ADGroupListGet] 
(
@ExecutionDateTime DATETIME = NULL
)

   
AS

/*
This SP is used by ADGroupsGet to get a list of logins on each server that is a windows group.
This will be used to get the members of that group and put them into Collector.ADGroupMember
*/

--This is the first collection.  This query returns the top-level list of groups.  These are the groups that are the actual logins in SQL.
IF @ExecutionDateTime IS NULL
BEGIN
	select distinct 
	name from Collector.Logins L1
	where isntgroup = 1
	and name not like '%mssqlserver%' 
	and name not like '%builtin\%' 
	and name not like '%NT SERVICE\%' 
	and name not like '%NT Authority\%' and name <> ''
	AND ExecutionDateTime in (select max(ExecutionDateTime) FROM Collector.Logins L2 WHERE L1.InstanceID = L2.InstanceID)
END

--This query returns the sub-groups.
--As the routine iterates through the groups, it doesn't do it with recursion so we get to see the groups inside the groups.
--It then calls this query for every group inside those groups so it can fill in the users for those groups.
--It keeps doing this until there are no more groups that haven't been processed.
IF @ExecutionDateTime IS NOT NULL
BEGIN
	SELECT ObjectName AS name
	FROM Collector.ADGroupMember
	WHERE IsGroup = 1 AND ObjectName NOT IN(SELECT GroupName FROM Collector.ADGroupMember WHERE ExecutionDateTime = @ExecutionDateTime)
	AND ExecutionDateTime = @ExecutionDateTime
	AND ObjectName <> 'Minion: Empty Group'
END









;
GO
/****** Object:  StoredProcedure [Alert].[BackupTshootServer]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Alert].[BackupTshootServer] 
 (
 @ServerName Varchar(100))
 
   
AS

SET NOCOUNT ON


Declare	@CurrentSubject varchar(100), 
		@tableHTML		NVARCHAR(MAX),
		@Distribn		varchar(4000),
		@RowCount		Smallint;
		
		         
	Set @RowCount = 0 
	Set @Distribn = 'sean.mccown@baylorhealth.edu' 


/**********************************************************************
Check and delete temp objects if they exist
***********************************************************************/

If OBJECT_ID ('Tempdb..#ServerList') is not null
 Drop table #Serverlist
 
If OBJECT_ID ('Tempdb..#DBlistMaint') is not null
 Drop table #DBListMaint
 
If OBJECT_ID ('Tempdb..#DBBkupListByDate') is not null
 Drop table #DBBkupListByDate
 
If OBJECT_ID ('Tempdb..#DBBKListRanked') is not null
 Drop table #DBBKListRanked

If OBJECT_ID ('Tempdb..#DBBKListTopRanked') is not null
 Drop table #DBBKListTopRanked
 
/************************************************************************************
Get a list of all servers that are sql, active and  with the correct service level
put the result set into the #serverlist table 
**************************************************************************************/

Select ServerName, [InstanceID] as InstanceID 
into #ServerList
from dbo.Servers
Where ServerName = @ServerName
and IsSQL = 1
and IsActive = 1
And BackupManaged = 1

 
/**********************************************************************************************
Collect each servername, instanceid and the databases on that server into a temp database list 
************************************************************************************************/

Select SL.Servername, SL.InstanceID, DM.DBname, DM.BackupAlertThresholdHrs 
into #DBListMaint
From DBMaint DM  
Inner join #ServerList SL on SL.InstanceID = DM.InstanceID
WHERE BackupReport = 1 -- Only get DBs that are flagged to be reported on.


--if @debug = 1
-- Begin
--	Select 'Backup list Before GlobalException deletion.'
--	select * from #DBListMaint
-- End

 ---Delete global exceptions.
 DELETE FROM #DBListMaint
Where DBName in (Select DBName from dbo.GlobalDBBackupExceptions)

/******************************************************************************** 
 Get last backup date of each database on a given server into  #DBBkupListByDate
 ********************************************************************************/
 
-- Rank each backup entry by date
 
Select DP.instanceid, DP.dbname, DP.LastBackup, DP.DBReadOnly, 
ROW_NUMBER() over(partition by DP.Instanceid, DP.dbname order by DP.dbname, DP.ExecutionDateTime desc) as RowNum
,DLM.BackupAlertThresholdHrs
Into #DBBKListRanked 
from Collector.DBProperties DP(Nolock)
INNER JOIN #DBListMaint DLM
ON DP.InstanceID = DLM.InstanceID
AND DP.DBName = DLM.DBName; -- Here again looking at only the DBs we're concerned about.

----Delete ReadOnly DBs because they won't be backed up often enough to be determined by this process.
DELETE FROM #DBBKListRanked
WHERE DBReadOnly = 1


Select * into #DBBKListTopRanked
From #DBBKListRanked
Where RowNum = 1


/*********************************************************************************************
Get all servers and databases that have not been backed up for greater than the last 24 hours
**********************************************************************************************/

SELECT  
		SL.ServerName,
		DB.InstanceID ,
        DB.DBName ,
        DB.LastBackup ,
        DB.DBReadOnly ,
        DB.BackupAlertThresholdHrs 
INTO #Final
FROM #DBBKListTopRanked DB
INNER JOIN #ServerList SL
ON DB.InstanceID = SL.InstanceID
WHERE DATEDIFF (HH, DB.Lastbackup, Getdate()) >  DB.BackupAlertThresholdHrs
ORDER BY DB.InstanceID, DB.DBName

---- Get unique server names to see how many servers are affected

 SELECT *
 FROM #Final



;
GO
/****** Object:  StoredProcedure [Alert].[BackupTshootLog]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Alert].[BackupTshootLog] 
(
@ServerName varchar(100)
)

   
AS


/***********************************************************************************

Created By: Sean McCown
Creation Date: 3/6/2012


Purpose: This procedure alerts and reports on failed backups. 

Walkthrough:
      1. Get list of all managed servers and databases
      2. Get latest backup dates
      3. Report on missing backup based on backup thresholds of each database

Conventions:

Parameters:
-----------
@EmailProfile - DBmail profile to be used for emailing the report

@ServiceLevel - 3 services levels in the order of importance 'Gold', 'Silver', 'Bronze' 

@Debug - when 1, dumps all tables to console for debug purposes

@Distrib - Email addresses to be alterted on missing backups

@CurrentSubject - Email subject line

@tableHTML - Missing Backup report table in HTML Format

@RowCount - Number of missing backups to be added to the subject line


Tables:
--------
#ServerList - holds a list of all servers at a given service level 

#DBlistMaint - Holds a list of databases for the servers into dblistmaint 

#DBBkupListByDate - Holds a list of all databases and the last backup date

#DBBKListRanked = Holds a list of databases partitioned by server with ranked backup dates. The latest backup rank is 1 
and the oldest backup date is rank N

#DBBKListTopRanked - Holds a list of databases partitioned by server with their "latest" backup date

Revision History:

***********************************************************************************/


/**********************************************************************
Check and delete temp objects if they exist
***********************************************************************/

If OBJECT_ID ('Tempdb..#ServerList') is not null
 Drop table #Serverlist
 
If OBJECT_ID ('Tempdb..#DBlistMaint') is not null
 Drop table #DBListMaint
 
If OBJECT_ID ('Tempdb..#DBBkupListByDate') is not null
 Drop table #DBBkupListByDate
 
If OBJECT_ID ('Tempdb..#DBBKListRanked') is not null
 Drop table #DBBKListRanked

If OBJECT_ID ('Tempdb..#DBBKListTopRanked') is not null
 Drop table #DBBKListTopRanked
 
/************************************************************************************
Get a list of all servers that are sql, active and  with the correct service level
put the result set into the #serverlist table 
**************************************************************************************/

Select ServerName, [InstanceID] as InstanceID 
into #ServerList
from dbo.Servers
Where ServerName = @ServerName
and IsSQL = 1
and IsActive = 1
And BackupManaged = 1
 
/**********************************************************************************************
Collect each servername, instanceid and the databases on that server into a temp database list 
************************************************************************************************/

Select SL.Servername, SL.InstanceID, DM.DBname, DM.LogBackupAlertThresholdMins 
into #DBListMaint
From DBMaint DM  
Inner join #ServerList SL on SL.InstanceID = DM.InstanceID
WHERE LogBackupReport = 1 -- Only get DBs that are flagged to be reported on.


 ---Delete global exceptions.
DELETE FROM #DBListMaint
Where DBName in (Select DBName from dbo.GlobalDBBackupExceptions)

/******************************************************************************** 
 Get last backup date of each database on a given server into  #DBBkupListByDate
 ********************************************************************************/
 
 -- Rank each backup entry by date
 
Select DP.instanceid, DP.dbname, DP.LastLogBackup, DP.DBReadOnly, DP.Recoverymodel,
ROW_NUMBER() over(partition by DP.Instanceid, DP.dbname order by DP.dbname, DP.executionDateTime desc) as RowNum
,DLM.LogBackupAlertThresholdMins
Into #DBBKListRanked 
from Collector.DBProperties DP(Nolock)
INNER JOIN #DBListMaint DLM
ON DP.InstanceID = DLM.InstanceID
AND DP.DBName = DLM.DBName; -- Here again looking at only the DBs we're concerned about.

----Delete ReadOnly DBs because they won't be backed up often enough to be determined by this process.
DELETE FROM #DBBKListRanked
WHERE DBReadOnly = 1

Select * into #DBBKListTopRanked
From #DBBKListRanked
Where RowNum = 1

-- Delete all DBs that are simple (No log backups for simple dbs)
DELETE FROM #DBBKListTopRanked
WHERE RecoveryModel = 'Simple'



/*********************************************************************************************
Get all servers and databases that have not been backed up for greater than the last 60 Mins
**********************************************************************************************/

SELECT  
		SL.ServerName,
		DB.InstanceID ,
        DB.DBName ,
        DB.LastLogBackup ,
        DB.DBReadOnly ,
        DB.LogBackupAlertThresholdMins INTO #Final
FROM #DBBKListTopRanked DB
INNER JOIN #ServerList SL
ON DB.InstanceID = SL.InstanceID
WHERE DATEDIFF (MI, DB.LastLogBackup, Getdate()) >  DB.LogBackupAlertThresholdMins
ORDER BY DB.InstanceID, DB.DBName

 
-- /************************************************************************************
-- Report on the missing backups
 
-- *************************************************************************************/
 
SELECT * FROM #Final



;
GO
/****** Object:  StoredProcedure [Setup].[BackupReportThreshold]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Setup].[BackupReportThreshold]
(
@ServerName varchar(100),
@DBName varchar(100),
@BackupType varchar(10),
@ThresholdHrs smallint
)

  
AS

DECLARE @InstanceID int;

SET @InstanceID = (SELECT InstanceID FROM dbo.Servers
WHERE ServerName = @ServerName)

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------Single DB---------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

If @BackupType = 'FullDiff'
		BEGIN

		If @DBName <> 'All'

			Begin	
				UPDATE Minion.dbo.DBMaint
				SET [BackUpAlertThresholdHrs] = @ThresholdHrs
				WHERE InstanceID = @InstanceID
				AND   DBName = @DBName
			End

		END

If @BackupType = 'Log'
		BEGIN

		If @DBName <> 'All'

			Begin	
				UPDATE Minion.dbo.DBMaint
				SET  [LogBackupAlertThresholdMins] = @ThresholdHrs
				WHERE InstanceID = @InstanceID
				AND   DBName = @DBName
			End

		END

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------All DBs-----------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

If @BackupType = 'FullDiff'
		BEGIN

		If @DBName = 'All'

			Begin	
				UPDATE Minion.dbo.DBMaint
				SET [BackUpAlertThresholdHrs] = @ThresholdHrs
				WHERE InstanceID = @InstanceID

			End

		END

If @BackupType = 'Log'
		BEGIN

		If @DBName = 'All'

			Begin	
				UPDATE Minion.dbo.DBMaint
				SET  [LogBackupAlertThresholdMins] = @ThresholdHrs
				WHERE InstanceID = @InstanceID

			End

		END

;
GO
/****** Object:  StoredProcedure [Setup].[BackupReportException]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Setup].[BackupReportException]
(
@ServerName varchar(100),
@DBName varchar(100),
@BackupType varchar(10),
@IncludeInReport bit
)

  
AS

DECLARE @InstanceID int;

SET @InstanceID = (SELECT InstanceID FROM dbo.Servers
WHERE ServerName = @ServerName)

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------Single DB---------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

If @BackupType = 'FullDiff'
		BEGIN

		If @DBName <> 'All'

			Begin	
				UPDATE Minion.dbo.DBMaint
				SET [BackupReport] = @IncludeInReport
				WHERE InstanceID = @InstanceID
				AND   DBName = @DBName
			End

		END

If @BackupType = 'Log'
		BEGIN

		If @DBName <> 'All'

			Begin	
				UPDATE Minion.dbo.DBMaint
				SET [BackupReport] = @IncludeInReport
				WHERE InstanceID = @InstanceID
				AND   DBName = @DBName
			End

		END

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------All DBs-----------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

If @BackupType = 'FullDiff'
		BEGIN

		If @DBName = 'All'

			Begin	
				UPDATE Minion.dbo.DBMaint
				SET [BackupReport] = @IncludeInReport
				WHERE InstanceID = @InstanceID

			End

		END

If @BackupType = 'Log'
		BEGIN

		If @DBName = 'All'

			Begin	
				UPDATE Minion.dbo.DBMaint
				SET [BackupReport] = @IncludeInReport
				WHERE InstanceID = @InstanceID

			End

		END

;
GO
/****** Object:  StoredProcedure [Alert].[BackupLogCT]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Alert].[BackupLogCT] 
(
 @Servicelevel Varchar(10), 
 @debug bit = 0
 )
 
   
AS


/***********************************************************************************

Created By: Sean McCown
Creation Date: 3/6/2012


Purpose: This procedure alerts and reports on failed backups. 

Walkthrough:
      1. Get list of all managed servers and databases
      2. Get latest backup dates
      3. Report on missing backup based on backup thresholds of each database

Conventions:

Parameters:
-----------
@EmailProfile - DBmail profile to be used for emailing the report

@ServiceLevel - 3 services levels in the order of importance 'Gold', 'Silver', 'Bronze' 

@Debug - when 1, dumps all tables to console for debug purposes

@Distrib - Email addresses to be alterted on missing backups

@CurrentSubject - Email subject line

@tableHTML - Missing Backup report table in HTML Format

@RowCount - Number of missing backups to be added to the subject line


Tables:
--------
#ServerList - holds a list of all servers at a given service level 

#DBlistMaint - Holds a list of databases for the servers into dblistmaint 

#DBBkupListByDate - Holds a list of all databases and the last backup date

#DBBKListRanked = Holds a list of databases partitioned by server with ranked backup dates. The latest backup rank is 1 
and the oldest backup date is rank N

#DBBKListTopRanked - Holds a list of databases partitioned by server with their "latest" backup date

Revision History:

***********************************************************************************/

Declare	@CurrentSubject varchar(100), 
		@tableHTML		NVARCHAR(MAX),
		@Distribn		varchar(4000),
		@RowCount		Smallint;
		
	         
Set @RowCount = 0 


/********************************************************************************
Set the email distribution list
*********************************************************************************/
Set @Distribn = ''
select @Distribn = @Distribn + EmailAddress + '; ' from  dbo.EmailNotification 
order by EmailAddress




/**********************************************************************
Check and delete temp objects if they exist
***********************************************************************/

If OBJECT_ID ('Tempdb..#ServerList') is not null
 Drop table #Serverlist
 
If OBJECT_ID ('Tempdb..#DBlistMaint') is not null
 Drop table #DBListMaint
 
If OBJECT_ID ('Tempdb..#DBBkupListByDate') is not null
 Drop table #DBBkupListByDate
 
If OBJECT_ID ('Tempdb..#DBBKListRanked') is not null
 Drop table #DBBKListRanked

If OBJECT_ID ('Tempdb..#DBBKListTopRanked') is not null
 Drop table #DBBKListTopRanked
 
/************************************************************************************
Get a list of all servers that are sql, active and  with the correct service level
put the result set into the #serverlist table 
**************************************************************************************/

Select ServerName, [InstanceID] as InstanceID 
into #ServerList
from dbo.Servers
Where ServiceLevel = @ServiceLevel
and IsSQL = 1
and IsActive = 1
And BackupManaged = 1

If @debug = 1
 Select * from #ServerList order by InstanceID
 
/**********************************************************************************************
Collect each servername, instanceid and the databases on that server into a temp database list 
************************************************************************************************/

Select SL.Servername, SL.InstanceID, DM.DBname, DM.LogBackupAlertThresholdMins 
into #DBListMaint
From DBMaint DM  
Inner join #ServerList SL on SL.InstanceID = DM.InstanceID
WHERE LogBackupReport = 1 -- Only get DBs that are flagged to be reported on.


--if @debug = 1
-- Begin
--	Select 'Backup list Before GlobalException deletion.'
--	select * from #DBListMaint
-- End

 ---Delete global exceptions.
DELETE FROM #DBListMaint
Where DBName in (Select DBName from dbo.GlobalDBBackupExceptions)

if @debug = 1
 Begin
	Select 'Log Backup list after GlobalException deletion.'
	select * from #DBListMaint
 End
 
/******************************************************************************** 
 Get last backup date of each database on a given server into  #DBBkupListByDate
 ********************************************************************************/
 
 -- Rank each backup entry by date
 
Select DP.instanceid, DP.dbname, DP.LastLogBackup, DP.DBReadOnly, DP.Recoverymodel,
ROW_NUMBER() over(partition by DP.Instanceid, DP.dbname order by DP.dbname, DP.executionDateTime desc) as RowNum
,DLM.LogBackupAlertThresholdMins
Into #DBBKListRanked 
from Collector.DBProperties DP(Nolock)
INNER JOIN #DBListMaint DLM
ON DP.InstanceID = DLM.InstanceID
AND DP.DBName = DLM.DBName; -- Here again looking at only the DBs we're concerned about.

----Delete ReadOnly DBs because they won't be backed up often enough to be determined by this process.
DELETE FROM #DBBKListRanked
WHERE DBReadOnly = 1

Select * into #DBBKListTopRanked
From #DBBKListRanked
Where RowNum = 1

-- Delete all DBs that are simple (No log backups for simple dbs)
DELETE FROM #DBBKListTopRanked
WHERE RecoveryModel = 'Simple'

 If @debug = 1
  Begin
   Select 'Top ranked backup DBs and Log Backup Dates with RO DBs deleted.'
   Select * From #DBBKListTopRanked
  End 


/*********************************************************************************************
Get all servers and databases that have not been backed up for greater than the last 60 Mins
**********************************************************************************************/

SELECT  
		SL.ServerName,
		DB.InstanceID ,
        DB.DBName ,
        DB.LastLogBackup ,
        DB.DBReadOnly ,
        DB.LogBackupAlertThresholdMins INTO #Final
FROM #DBBKListTopRanked DB
INNER JOIN #ServerList SL
ON DB.InstanceID = SL.InstanceID
WHERE DATEDIFF (MI, DB.LastLogBackup, Getdate()) >  DB.LogBackupAlertThresholdMins
ORDER BY DB.InstanceID, DB.DBName


If @debug = 1 
Begin
	Select 'Get a list of servers that are affected by failing backups based on filtered criteria' 
	 
SELECT * FROM #Final

End
---- Get unique server names to see how many servers are affected

If @debug = 1
 Begin 
	 Select 'Get a list of servers that are affected by failing backups with filteration'
	 Select distinct servername from #Final
 End
 
-- /************************************************************************************
-- Report on the missing backups
 
-- *************************************************************************************/
 

/***************************************************************************************
If row count > 0 i.e. there are missing backup to report, then email the team
****************************************************************************************/

 SELECT ServerName, COUNT(*) AS CT
 FROM #Final
 GROUP BY ServerName
 ORDER BY CT DESC



;
GO
/****** Object:  StoredProcedure [Alert].[BackupLog]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Alert].[BackupLog] 
(@EmailProfile	varchar(1024), 
 @Servicelevel Varchar(10), 
 @IncludeDefer bit,
 @IncludeException bit,
 @IncludeChange bit,
 @debug bit = 0)

   
AS

--EXEC [Alert].[BackupLog] @EmailProfile='BackupAlertProfile', @ServiceLevel='Gold', @IncludeDefer = 1, @IncludeException = 1, @IncludeChange = 1
SET NOCOUNT ON

/***********************************************************************************

Created By: Sean McCown
Creation Date: 3/6/2012


Purpose: This procedure alerts and reports on failed backups. 

Walkthrough:
      1. Get list of all managed servers and databases
      2. Get latest backup dates
	  3. Filter out exceptions.
	  4. Filter out read-only DBs.
	  5. Filter out deferred DBs.
      6. Send alert email only if there are records to send.

Conventions:

Parameters:
-----------
@EmailProfile - DBmail profile to be used for emailing the report

@ServiceLevel - 3 services levels in the order of importance 'Gold', 'Silver', 'Bronze' 

@Debug - when 1, dumps all tables to console for debug purposes

@Distrib - Email addresses to be alerted on missing backups

@CurrentSubject - Email subject line

@tableHTML - Missing Backup report table in HTML Format

@RowCount - Number of missing backups to be added to the subject line


Tables:
--------
#ServerList - holds a list of all servers at a given service level 

#DBlistMaint - Holds a list of databases for the servers into dblistmaint 

#DBBkupListByDate - Holds a list of all databases and the last backup date

#DBBKListRanked = Holds a list of databases partitioned by server with ranked backup dates. The latest backup rank is 1 
and the oldest backup date is rank N

#DBBKListTopRanked - Holds a list of databases partitioned by server with their "latest" backup date

#Final - Holds final resultset.  Everything has been deleted out of here by now and the email process does just
		 a simple query to get the records.  The reason it was done this way is because there are multiple places
		 where the logic is queried from and if the logic ever changes, this minimizes mistakes.
		 Take for example that you have to query the table 2 times.  Once to see if there are any records
		 to see if the email needs to be sent.  And a 2nd time to query the actual records for the detail that
		 goes into the alert email itself.  If the logic changes when you'll have to change it in both locations
		 so that the count and the details are both correct.  By handling that higher up in the code and letting
		 the email process just query this table in a simple manner, you reduce the complexity of making changes.
Revision History:

***********************************************************************************/

Declare	@CurrentSubject varchar(100), 
		@tableHTML		NVARCHAR(MAX),
		@Distribn		varchar(4000),
		@ExecutionDateTime DATETIME,
		@RowCount		Smallint;
		
		         
Set @RowCount = 0 
Set @Distribn = ''
SET @ExecutionDateTime = GETDATE();

select @Distribn = @Distribn + EmailAddress + '; ' from  dbo.EmailNotification 
order by EmailAddress


/**********************************************************************
Check and delete temp objects if they exist
***********************************************************************/

If OBJECT_ID ('Tempdb..#ServerList') is not null
 Drop table #Serverlist
 
If OBJECT_ID ('Tempdb..#DBlistMaint') is not null
 Drop table #DBListMaint
 
If OBJECT_ID ('Tempdb..#DBBkupListByDate') is not null
 Drop table #DBBkupListByDate
 
If OBJECT_ID ('Tempdb..#DBBKListRanked') is not null
 Drop table #DBBKListRanked

If OBJECT_ID ('Tempdb..#DBBKListTopRanked') is not null
 Drop table #DBBKListTopRanked
 
/************************************************************************************
Get a list of all servers that are sql, active and  with the correct service level
put the result set into the #serverlist table 
**************************************************************************************/

Select ServerName, InstanceID 
into #ServerList
from dbo.Servers
Where ServiceLevel = @ServiceLevel
and IsSQL = 1
and IsActive = 1
And BackupManaged = 1

If @debug = 1
 Select * from #ServerList order by InstanceID
 
/**********************************************************************************************
Collect each servername, instanceid and the databases on that server into a temp database list 
************************************************************************************************/

Select SL.Servername, SL.InstanceID, DM.DBname, DM.LogBackupAlertThresholdMins, DM.LogPath, DM.PrevLogPath, DM.LogLocType, DM.PrevLogLocType
into #DBListMaint
From DBMaint DM  
Inner join #ServerList SL on SL.InstanceID = DM.InstanceID
WHERE LogBackupReport = 1 -- Only get DBs that are flagged to be reported on.


--if @debug = 1
-- Begin
--	Select 'Backup list Before GlobalException deletion.'
--	select * from #DBListMaint
-- End

 ---Delete global exceptions.
 DELETE FROM #DBListMaint
Where DBName in (Select DBName from dbo.GlobalDBBackupExceptions)

if @debug = 1
 Begin
	Select 'Backup list after GlobalException deletion.'
	select * from #DBListMaint
 End
 
/******************************************************************************** 
 Get last backup date of each database on a given server into  #DBBkupListByDate
 ********************************************************************************/
 
 -- Rank each backup entry by date
 
Select DP.instanceid, DP.DBName, 
DP.LastLogBackup AS LastBackup, 
DP.DBReadOnly, 
ROW_NUMBER() over(partition by DP.Instanceid, DP.DBName order by DP.dbname, DP.ExecutionDateTime desc) as RowNum,
DP.Recoverymodel, DLM.LogBackupAlertThresholdMins, LogPath, PrevLogPath, LogLocType, PrevLogLocType 
Into #DBBKListRanked 
from Collector.DBProperties DP(Nolock)
INNER JOIN #DBListMaint DLM
ON DP.InstanceID = DLM.InstanceID
AND DP.DBName = DLM.DBName; -- Here again looking at only the DBs we're concerned about.

----Delete ReadOnly DBs because they won't be backed up often enough to be determined by this process.
DELETE FROM #DBBKListRanked
WHERE DBReadOnly = 1


Select * into #DBBKListTopRanked
From #DBBKListRanked
Where RowNum = 1


-- Delete all DBs that are simple (No log backups for simple dbs)
DELETE FROM #DBBKListTopRanked
WHERE RecoveryModel = 'Simple'

 If @debug = 1
  Begin
   Select 'Top ranked backup DBs and Backup Dates with RO DBs deleted.'
   Select * From #DBBKListTopRanked
  End 

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
----Set location paths so local backup locations paths are turned into UNC.
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--Current path
UPDATE DL
SET LogPath = '\\' + SL.ServerName + '\' + REPLACE(LogPath, ':', '$') + SL.ServerName + '\' + DL.DBName
from #DBBKListTopRanked DL
INNER JOIN #ServerList SL
ON DL.InstanceID = SL.InstanceID
WHERE LogLocType = 'Local'

--Previous path
UPDATE DL
SET PrevLogPath = '\\' + SL.ServerName + '\' + REPLACE(PrevLogPath, ':', '$') + SL.ServerName + '\' + DL.DBName
from #DBBKListTopRanked DL
INNER JOIN #ServerList SL
ON DL.InstanceID = SL.InstanceID
WHERE PrevLogLocType = 'Local'

--Current path NAS
UPDATE DL
SET LogPath = LogPath + '\' + SL.ServerName + '\' + DL.DBName
from #DBBKListTopRanked DL
INNER JOIN #ServerList SL
ON DL.InstanceID = SL.InstanceID
WHERE LogLocType = 'NAS'

--Previous path NAS 
UPDATE DL
SET PrevLogPath = PrevLogPath + '\' + SL.ServerName + '\' + DL.DBName
from #DBBKListTopRanked DL
INNER JOIN #ServerList SL
ON DL.InstanceID = SL.InstanceID
WHERE PrevLogLocType = 'NAS'

/*********************************************************************************************
Get all servers and databases that have not been backed up for greater than the last report period in hours
**********************************************************************************************/

SELECT  
		SL.ServerName,
		DB.InstanceID ,
        DB.DBName ,
        DB.LastBackup ,
        DB.DBReadOnly ,
        DB.LogBackupAlertThresholdMins ,
		DB.LogPath ,
		DB.PrevLogPath
INTO #Final
FROM #DBBKListTopRanked DB
INNER JOIN #ServerList SL
ON DB.InstanceID = SL.InstanceID
WHERE DATEDIFF (HH, DB.LastBackup, Getdate()) >  DB.LogBackupAlertThresholdMins
ORDER BY DB.InstanceID, DB.DBName



If @debug = 1 
Begin
	Select 'Get a list of servers that are affected by failing backups based on filtered criteria' 
	 
SELECT * FROM #Final

END

---- Delete deferred DBs.  If you have a known issue that you think will work itself
---- out in a day or 2 then you can put an entry into Alert.BackupDefer.  This will
---- let you filter it out of the alert for a specified time so it doesn't bother you.

DELETE F
FROM #Final F
INNER JOIN Alert.BackupDefer B
ON F.InstanceID = B.InstanceID
	AND F.DBName = B.DBName
WHERE CAST(GETDATE() AS DATE) < B.DeferEndDate
AND B.BackupType = 'Log'


----Delete deferred DBs at the server level.  If there are too many DBs to defer at once,
----then it's easier to defer the entire server until it's worked out.
----This is a hack put in at the last min and can prob be done better.
----Since it's not run that often though the perf really isn't that important.
DELETE F
FROM #Final F
INNER JOIN Alert.BackupDefer B
ON F.InstanceID = B.InstanceID
WHERE CAST(GETDATE() AS DATE) < B.DeferEndDate
AND B.BackupType = 'Log'
AND B.DBName = 'All'

SELECT * FROM #Final


----------------------------------------------------------------------------
----------------------------------------------------------------------------
-------------------------BEGIN Fuzzy Lookups--------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------

-- Get unique list of InstanceID, Regex.  An instance can have more than one
-- regex criteria if there are several sets of DBs on that server that have fuzzy lookups.
-- So here, if there's more than 1, this will cycle through them.
-- Normally we'd look for a specific MaintType but here we're interested in New/Retired DBs no matter
-- what the function so we're going to take all of them.


create table #FuzzyLookup
(
InstanceID bigint,
DBName sysname NULL,
Action varchar(10)
)

DECLARE @currUser varchar(100),
		@SQL nvarchar(200),
		@InstanceID bigint,
		@Regex varchar(200),
		@Action varchar(10),
		@FuzzyCMD varchar(2000);

DECLARE DBs CURSOR
READ_ONLY
FOR 
SELECT DISTINCT DFL.InstanceID, DFL.Regex, DFL.Action
FROM dbo.DBMaintFuzzyLookup DFL
INNER JOIN #Final F
ON DFL.InstanceID = F.InstanceID
WHERE DFL.MaintType = 'Backup'
OR DFL.MaintType = 'All';

OPEN DBs

	FETCH NEXT FROM DBs INTO @InstanceID, @Regex, @Action
	WHILE (@@fetch_status <> -1)
	BEGIN


SET @FuzzyCMD = 
'Powershell "C:\MinionByMidnightDBA\SPPowershellScripts\DBNameFuzzyLookup.ps1 ' + CAST(@InstanceID as varchar(10)) + ' ''' + @Regex + '''"' 

 INSERT #FuzzyLookup(DBName)     
            EXEC xp_cmdshell @FuzzyCMD 

UPDATE #FuzzyLookup
SET InstanceID = @InstanceID,
	Action = @Action
WHERE InstanceID IS NULL

	FETCH NEXT FROM DBs INTO @InstanceID, @Regex, @Action
	END

CLOSE DBs
DEALLOCATE DBs

--Get rid of any rows that aren't actually DBNames.  The cmdshell gives us back some crap with our results.-
DELETE #FuzzyLookup
WHERE 
--DBName NOT IN (SELECT DBName FROM Collector.DBProperties DM2
--						WHERE InstanceID = DM2.InstanceID
--						AND DM2.ExecutionDateTime = (SELECT MAX(DM3.ExecutionDateTime) from Collector.DBProperties DM3 where DM2.InstanceID = DM3.InstanceID)
--						)
DBName IS NULL


--Delete DBs that are meant to be excluded off of the fuzzy search.
DELETE #Final
WHERE DBName IN (SELECT DBName FROM #FuzzyLookup FL
WHERE InstanceID = FL.InstanceID AND DBName = FL.DBName
AND FL.Action = 'Exclude')


----------------------------------------------------------------------------
----------------------------------------------------------------------------
-------------------------END Fuzzy Lookups----------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------






If @debug = 1
 Begin 
	 Select 'Get a list of servers that are affected by failing backups with filteration'
	 Select distinct servername from #Final
 End
 

 -----------Save to history

 INSERT History.BackupLog (ExecutionDateTime, ServiceLevel, ServerName, InstanceID, DBName, LastLogBackup, DBReadOnly, LogBackupAlertThresholdMins)
 SELECT @ExecutionDateTime, @ServiceLevel, ServerName, InstanceID, DBName, LastBackup, DBReadOnly, LogBackupAlertThresholdMins
 FROM #Final; 


-- /************************************************************************************
-- Report on the missing backups
 
-- *************************************************************************************/
 
-- -- Count the # of missing backups
 
 Select @RowCount = COUNT(*) 
 	From #Final
 
-- -- Set the subject header to report on the # of missing backups
 
set @CurrentSubject = 'Missing ' + CAST(@rowcount as Varchar(4)) + ' F/D Backups (' + @ServiceLevel + ')' 

---- Put the missing databases table into HTML format
 
SET @tableHTML =              
N'<H2>'+ @CurrentSubject + '</H2>' +              
N'<table border="1">' +              
N'<tr>
	<th>ID</th> 	
	<th>Server Name</th>   
	<th>DB Name</th>          
	<th>Last Backup</th>
	<th>BackupPath</th>
	<th>PrevPath</th>
</tr>' +           
CAST ( (Select 
		td = InstanceID, '',
		td = Servername, '',
		td = DBname, '',
		td = CAST(LastBackup AS Date), '',
		td = LogPath, '',
		td = PrevLogPath, ''
		From #Final
		order by ServerName
		FOR XML PATH('tr'), TYPE               
 ) AS NVARCHAR(MAX)) +              
N'</table>' ;              
set @tableHTML =@tableHTML+'<BR>'    
          


 DECLARE @ChangeSQL nvarchar(max)
 If @IncludeChange = 1
 Begin

	SET @ChangeSQL = 
	N'<H2>Change SQL</H2>' +                
 N'<table border="0">' +                
    N'<tr>        
     <th>Run this to change the reporting threshold:</th>                
</tr>' +  

CAST ( ( SELECT           
   td = 'EXEC Setup.BackupReportThreshold ' + '''' + ServerName + '''' + ', ' + '''' + DBName + '''', ''
   + '' + ', ''' + 'Log'+ '''' + ', ' + 'ThresholdMins' + '  -- Use ''All'' for DBName to set value for all DBs.'   
   from         
  #Final         
  order by ServerName, DBName                    
 FOR XML PATH('tr'), TYPE                 
 ) AS NVARCHAR(MAX) ) +                
 N'</table>' ;       

SET @tableHTML = @tableHTML + @ChangeSQL

 END

 ----------------------------------------------------------------------


 DECLARE @ExcludeSQL nvarchar(max)
 If @IncludeException = 1
 Begin

	SET @ExcludeSQL = 
	N'<H2>Exclude SQL</H2>' +                
 N'<table border="0">' +                
    N'<tr>        
     <th>Run this to exclude backups from report:</th>                
</tr>' +  

CAST ( ( SELECT           
   td = 'EXEC Setup.BackupReportException ' + '''' + ServerName + '''' + ', ' + '''' + DBName + '''', ''
    + '' + ', ''' + 'Log' + '''' + ', ' + CAST(0 AS varchar(5)) + '  -- Use ''All'' instead of DBName to set value for all DBs.'      
   from         
  #Final         
  order by ServerName, DBName                     
 FOR XML PATH('tr'), TYPE                 
 ) AS NVARCHAR(MAX) ) +                
 N'</table>' ;       

SET @tableHTML = @tableHTML + @ExcludeSQL

 END


  DECLARE @DeferSQL nvarchar(max)
 If @IncludeDefer = 1
 Begin

	SET @DeferSQL = 
	N'<H2>Defer SQL</H2>' +                
 N'<table border="0">' +                
    N'<tr>        
     <th>Run this to defer backups from report:</th>                
</tr>' +  

CAST ( ( SELECT           
   td = 'EXEC Setup.BackupDefer ' + '''' + ServerName + '''' + ', ' + '''' + DBName + ''', ' + '''' + 'Log' + ''', ' + '''' + CONVERT(varchar(15), GetDate(), 101) + '''' + ', ' + '''' + CONVERT(varchar(15), GetDate() + 1, 101) + ''', ' + '''06:00'''
    + '  -- Use ''All'' for DBName to set value for all DBs.'   
   from         
  #Final         
  order by ServerName, DBName                    
 FOR XML PATH('tr'), TYPE                 
 ) AS NVARCHAR(MAX) ) +                
 N'</table>' ;       

SET @tableHTML = @tableHTML + @DeferSQL

 END
 



set @tableHTML =@tableHTML+'***Do NOT reply to the sender; Automated Report***'   

 --Email 

IF @RowCount > 0
BEGIN
	EXEC msdb.dbo.sp_send_dbmail              
	@profile_name = @EmailProfile,              
	@recipients = @Distribn, --             
	@subject = @CurrentSubject,              
	@body = @tableHTML,              
	@body_format = 'HTML'; 
END


;
GO
/****** Object:  StoredProcedure [Alert].[BackupInfo]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Alert].[BackupInfo]

@InstanceName varchar(100)

  
AS

/*
This gets collected backup info to allow you to investigate why a DB is showing up
in the backup report.
It's also called from a powershell script that merges it with realtime backup info.
*/



DECLARE	
@InstanceID INT,
@MaxProps datetime
		
SET @InstanceID = (SELECT [InstanceID] FROM dbo.Servers WHERE ServerName = @InstanceName)

SET @MaxProps = (SELECT MAX(ExecutionDateTime)
					FROM Collector.DBProperties
					WHERE InstanceID = @InstanceID)

SELECT DBP.InstanceID, DBM.DBName
, DBM.BackUpAlertThresholdHrs AS ThreshholdHrs
,DATEDIFF(hh, DBP.LastBackup, DBP.ExecutionDateTime) AS BackupCollDiffHrs, 
DBP.ExecutionDateTime AS CollectionTime
, DBP.LastBackup, 
DBP.LastLogBackup, DBP.RecoveryModel 
FROM Collector.DBProperties DBP
INNER JOIN dbo.DBMaint DBM
ON DBP.InstanceID = DBM.InstanceID AND DBP.DBName = DBM.DBName
WHERE ExecutionDateTime = @MaxProps	
AND DBM.ExcludeFromBackup = 0
AND DBM.DBName <> 'tempdb'
ORDER BY DBP.DBName



;
GO
/****** Object:  StoredProcedure [Collector].[BackupHistoryInsert]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--sp_helptext 'Collector.CheckDBResultInsert'

  
  
CREATE PROCEDURE [Collector].[BackupHistoryInsert]  
	@ExecutionDateTime datetime,
	@ServerName varchar(100),
	@DBName varchar(25),
	@BackupType varchar(10),
	@BatchDateTime datetime,
	@BackupStartTime datetime,
	@BackupEndTime datetime,
	@TotalTimeinSec numeric(15, 2),
	@BackupCmd varchar(4000),
	@SizeInMB numeric(15, 3)
	
   
AS 
/*  
  
Explain here.  
  
*/  
  
    DECLARE @InstanceID INT  
    
    SET @InstanceID = ( SELECT  InstanceID  
                        FROM    dbo.Servers  
                        WHERE   ServerName = @ServerName  
                      )  
  
    INSERT  Collector.BackupHistory  
    (ExecutionDateTime, InstanceID, DBName, BackupType, BatchDateTime, BackupStartTime, BackupEndTime, TotalTimeinSec, BackupCmd, SizeInMB)
    
SELECT
	@ExecutionDateTime,
	@InstanceID,
	@DBName,
	@BackupType,
	@BatchDateTime,
	@BackupStartTime,
	@BackupEndTime,
	@TotalTimeinSec,
	@BackupCmd,
	@SizeInMB


;
GO
/****** Object:  StoredProcedure [Archive].[Data]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Archive].[Data]
    @ArchiveLogRetentionDays INT = 366
	
   
AS 
/***********************************************************************************
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
------------------Minion Enterprise------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Created By: MinionWare LLC

Minion Enterprise is a very big routine with many nuances.  Our documentation is 
complete, but if you prefer, we also have videos that show you how to use each of 
the features. You can find them at http://www.MinionWare.net

Minion Enterprise is an enterprise management solution for centralized
SQL Server management and alerting. This solution allows your
database administrator to manage an enterprise of one, hundreds,
or even thousands of SQL Servers from one central location. Minion
Enterprise provides not just alerting and reporting, but backups,
maintenance, configuration, and enforcement.

* By running this software you are agreeing to the terms of the license agreement.
* You can find a copy of the license agreement here: http://www.MinionWare.net/license
--------------------------------------------------------------------------------

Purpose: Cycles through all tables listed in Archive.Config, and deletes data
		 in those tables. 

Features:
	* 

Limitations:
	*  ___

Notes:
	* ___

Walkthrough: 
	1. Pulls table, archive retention, and batch data from Archive.Config.
	2. Loops through the results: 
		a. Builds the delete statement.
		b. Logs archive process data to Archive.ConfigLog.
		c. Runs the delete statement (looped by batch size).
		d. Logs post-delete data.

	3. Delete old Archive.ConfigLog data

Conventions:

Parameters:
-----------

  @ArchiveLogRetentionDays		Number of days to retain the log of archival activity (in 
									the Archive.ConfigLog table).

Tables: 
--------
	None.

Example Executions:
    EXEC Archive.Data;
    
	EXEC Archive.Data @ArchiveLogRetentionDays = 731; -- Two year retention.
	

Revision History:
	

***********************************************************************************/
    SET nocount OFF;


---------------------------------
-- Declare variables and cursor
---------------------------------
    DECLARE @ExecDateTime DATETIME;
    DECLARE @SchemaName SYSNAME ,
        @TableName SYSNAME ,
        @ArchiveDays INT ,
        @RowsInBatch INT,
		@Rowcount INT,
		@TotalRowsDeleted BIGINT;

    DECLARE @query NVARCHAR(4000);
    DECLARE @ConfigLogID INT;

    SET @ExecDateTime = GETDATE();
	


    DECLARE myCursor CURSOR
    FOR
        SELECT  SchemaName ,
                TableName ,
                ArchiveDays ,
                RowsInBatch
        FROM    Archive.Config;

    OPEN myCursor
	
    FETCH NEXT FROM myCursor INTO @SchemaName, @TableName, @ArchiveDays,
        @RowsInBatch
	
---------------------------------
-- Cycle through tables, delete data
---------------------------------

    WHILE @@FETCH_STATUS = 0 
        BEGIN
		      
			-- 1. Build statement
			-- if exists (TableName) DELETE FROM [TableName] TOP @batchsize

            SET @query = 'IF EXISTS (SELECT * FROM sys.objects where schema_name(schema_id) = '''
			+ @SchemaName + ''' AND [name] = ''' + @TableName 
			+ ''' AND type =''u'')
			DELETE TOP (' + CAST(@RowsInBatch AS VARCHAR(100))
                + ') FROM [' + ISNULL(@SchemaName, 'dbo') + '].[' + @TableName
                + '] WHERE ExecutionDateTime < '''
                + CAST(CAST(DATEADD(DAY, -1 * @ArchiveDays, GETDATE()) AS DATE) AS VARCHAR(100))
				+ ''';';
				
			-- 2. Insert data and start time into Archive.ConfigLog
            INSERT  INTO Archive.ConfigLog
                    ( ExecutionDateTime ,
                      SchemaName ,
                      TableName ,
                      ArchiveDays ,
                      RowsInBatch ,
                      [DeleteBeginDateTime]
                    )
                    SELECT  @ExecDateTime ,
                            @SchemaName ,
                            @TableName ,
                            @ArchiveDays ,
                            @RowsInBatch ,
                            GETDATE();
			
            SELECT  @ConfigLogID = SCOPE_IDENTITY();
			SET @TotalRowsDeleted = 0;

			-- 3. Run statement in a loop (to accomodate for batches)
            WHILE 1 = 1 
                BEGIN
                    -- run batched delete loop
					EXEC (@query);
					SET @Rowcount = @@ROWCOUNT;

					IF @Rowcount = 0
						BREAK;	
					
					SELECT @TotalRowsDeleted = @TotalRowsDeleted  + @Rowcount;
                END          
			
            --PRINT @query;	-- For troubleshooting

			-- 4. Update Archive.ConfigLog entry with operation end time and rows deleted
            UPDATE  Archive.ConfigLog
            SET     [DeleteEndDateTime] = GETDATE() ,
                    [DeleteRunTimeInSecs] = DATEDIFF(SECOND,
                                                     DeleteBeginDateTime,
                                                     GETDATE()),
					[RowsDeleted] = @TotalRowsDeleted
            WHERE   ID = @ConfigLogID;

			-- 5. Next iteration:
            FETCH NEXT FROM myCursor INTO @SchemaName, @TableName,
                @ArchiveDays, @RowsInBatch;
        END

---------------------------------
-- Close cursor
---------------------------------
    CLOSE myCursor;
    DEALLOCATE myCursor;



---------------------------------
-- Delete old Archive.ConfigLog data
---------------------------------

    DELETE  FROM Archive.ConfigLog
    WHERE   ExecutionDateTime < DATEADD(DAY, -1 * @ArchiveLogRetentionDays, GETDATE());


;
GO
/****** Object:  StoredProcedure [Alert].[CheckDBErrors]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Alert].[CheckDBErrors]

@EmailProfile	varchar(1024)

   
AS

Declare	@CurrentSubject varchar(100), 
		@tableHTML		NVARCHAR(MAX),
		@Distribn		varchar(4000),
		@RowCount		Smallint;
		
		         
Set @RowCount = 0 
Set @Distribn = ''

select @Distribn = @Distribn + EmailAddress + '; ' 
from  dbo.EmailNotification 
order by EmailAddress


Select CB.instanceid, S.ServerName, CB.DBName,CB.ExecutionDateTime, CB.BeginTime, CB.EndTime, CB.MessageText,
ROW_NUMBER() over(partition by CB.Instanceid, CB.DBName order by CB.DBName, CB.ExecutionDateTime desc) as RowNum
Into #DBListRanked 
from Collector.CheckDBResult CB WITH(Nolock)
INNER JOIN dbo.Servers S
ON CB.InstanceID = S.[InstanceID]
WHERE CB.Managed < 1 --Only look through DBs that haven't been managed yet.

----Put all DBs with CheckDB errors into the #Final table.  It's not strictly necessary
----to put them in another table, but it makes it much easier when having to make changes
----because you won't have to change the email portion when you need to change the logic
----of the process.
SELECT * 
INTO #Final
FROM #DBListRanked
WHERE RowNum = 1
AND MessageText NOT LIKE '%CHECKDB found 0 allocation errors and 0 consistency errors%'

----You have to set the non-error DBs to Managed so the process won't search through
----them every time it runs.  If there are any error DBs then they'll be set to
----Managed manually as they're handled.  This is to ensure that you keep getting emails
----about CheckDB errors until you deal with them.
UPDATE CB
SET Managed = 1
FROM Collector.CheckDBResult CB
INNER JOIN #DBListRanked DB
ON CB.InstanceID = DB.InstanceID
AND CB.DBName = DB.DBName
AND CB.ExecutionDateTime = DB.ExecutionDateTime
WHERE DB.RowNum = 1
AND CB.Managed = 0

DROP TABLE #DBListRanked


-- /************************************************************************************
-- Report on the CheckDB errors.
 
-- *************************************************************************************/
 
-- -- Count the # of CheckDB errors.
 
 Select @RowCount = COUNT(*) 
 	From #Final
 
-- -- Set the subject header to report on the # of CheckDB errors.
 
set @CurrentSubject = 'CheckDB Errors (' + CAST(@rowcount as Varchar(4)) + ')'

---- Put the CheckDB errors table into HTML format
 
SET @tableHTML =              
N'<H2>'+ @CurrentSubject + '</H2>' +              
N'<table border="1">' +              
N'<tr>
	<th>Server Name</th>   
	<th>DB Name</th>          
	<th>BeginTime</th>
</tr>' +           
CAST ( (Select 
		td = Servername, '',
		td = DBname, '',
		td = CAST(BeginTime AS Date), ''
		From #Final
		order by ServerName
		FOR XML PATH('tr'), TYPE               
 ) AS NVARCHAR(MAX)) +              
N'</table>' ;              
set @tableHTML =@tableHTML+'<BR>'              
set @tableHTML =@tableHTML+'***Please do NOT reply to the sender; Automated Report***'   

 --Email 

IF @RowCount > 0
BEGIN
	EXEC msdb.dbo.sp_send_dbmail              
	@profile_name = @EmailProfile,              
	@recipients = @Distribn,              
	@subject = @CurrentSubject,              
	@body = @tableHTML,              
	@body_format = 'HTML'; 
END



;
GO
/****** Object:  StoredProcedure [BackupMgmt].[ChangeReportStatus]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [BackupMgmt].[ChangeReportStatus]
@ServerName varchar(100),
@BackupReport bit,
@BackupAlertthresholdHrs smallint,
@LogBackupReport bit,
@LogBackupAlertThresholdMins smallint,
@DBName varchar(100) = NULL

   

as 

/*
Changes backup report status for all DBs on a server, or for a single DB.

*/

declare @InstanceID int,
		@ExecutionDateTime datetime
		 
set @InstanceID = (select [InstanceID] from dbo.Servers where ServerName = @ServerName)
set @ExecutionDateTime = getdate()

--- First put current settings into trash to be saved for later.
Insert Trash.DBMaint
select @ExecutionDateTime, *
from dbo.DBMaint
where InstanceID = @InstanceID

----All Params BEGIN-------


If @DBName is NULL
Begin

UPDATE dbo.DBMaint
SET 
[BackupReport] = @BackupReport,
[BackUpAlertThresholdHrs] = @BackupAlertthresholdHrs,
[LogBackupReport] = @LogBackupReport,
[LogBackupAlertThresholdMins] = @LogBackupAlertThresholdMins
where InstanceID = @InstanceID

END

----All Params END-------

----Single DB Params BEGIN-------


If @DBName is NOT NULL
Begin

UPDATE dbo.DBMaint
SET 
[BackupReport] = @BackupReport,
[BackUpAlertThresholdHrs] = @BackupAlertthresholdHrs,
[LogBackupReport] = @LogBackupReport,
[LogBackupAlertThresholdMins] = @LogBackupAlertThresholdMins
where InstanceID = @InstanceID
and DBName = @DBName

END

----Single DB Params END-------



;
GO
/****** Object:  StoredProcedure [BackupMgmt].[ChangeParams]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [BackupMgmt].[ChangeParams]

@ServerName varchar(100),
@DBName varchar(100) = NULL,
@BufferCount int = 0,
@MaxTransferSize bigint = 0,
@NumberOfFiles int = 1,
@NumberOfLogFiles int = 1

   

as 

/*
Changes backup perf params for all DBs on a server, or for a single DB
*/

declare @InstanceID int,
		@ExecutionDateTime datetime
		 
set @InstanceID = (select [InstanceID] from dbo.Servers where ServerName = @ServerName)
set @ExecutionDateTime = getdate()

--- First put current settings into trash to be saved for later.
Insert Trash.DBMaint
select @ExecutionDateTime, *
from dbo.DBMaint
where InstanceID = @InstanceID

----All Params BEGIN-------


If @DBName is NULL
Begin

UPDATE dbo.DBMaint
SET 
[BufferCount] = @BufferCount,
[MaxTransferSize] = @MaxTransferSize,
NumberOfFiles = @NumberOfFiles,
@NumberOfLogFiles = @NumberOfLogFiles,
Push = 1
where InstanceID = @InstanceID

END

----All Params END-------

----Single DB Params BEGIN-------


If @DBName is NOT NULL
Begin

UPDATE dbo.DBMaint
SET 
[BufferCount] = @BufferCount,
[MaxTransferSize] = @MaxTransferSize,
NumberOfFiles = @NumberOfFiles,
@NumberOfLogFiles = @NumberOfLogFiles,
Push = 1
where InstanceID = @InstanceID
and DBName = @DBName

END

----Single DB Params END-------



;
GO
/****** Object:  StoredProcedure [BackupMgmt].[ChangeLocByServer]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--CREATE SCHEMA BackupMgmt

CREATE procedure [BackupMgmt].[ChangeLocByServer]

@ServerName varchar(100),
@FullPath varchar(1000) = NULL,
@FullPathType varchar(20)  = NULL,
@DiffPath varchar(1000) = NULL,
@DiffPathType varchar(20)  = NULL,
@LogPath varchar(1000) = NULL,
@LogPathType varchar(20)  = NULL,
@All bit,
@AllPath varchar(100),
@AllPathType varchar(20)

   
as 

/*
Changes all backup locations for a DB or a server.
*/

declare @InstanceID int,
		@ExecutionDateTime datetime
		 
set @InstanceID = (select [InstanceID] from dbo.Servers where ServerName = @ServerName)
set @ExecutionDateTime = getdate()

--- First put current settings into trash to be saved for later.
Insert Trash.DBMaint
select @ExecutionDateTime, *
from dbo.DBMaint
where InstanceID = @InstanceID

----All backup locations BEGIN-------
If @All = 1 
Begin

If @AllPath is NULL
Begin
	PRINT '@AllPath can''t be NULL'
	RETURN
End

If @AllPathType is NULL
Begin
	PRINT '@AllPathType can''t be NULL.  Valid values are Local, NAS, Remote, etc.'
	RETURN
End

UPDATE dbo.DBMaint
SET 
PrevFullPath = FullPath,
PrevFullLocType = FullLocType,
PrevDiffPath = DiffPath,
PrevDiffLocType = DiffLocType,
PrevLogPath = LOGPath,
PrevLogLocType = LogLocType,
FullPath = @AllPath,
FullLocType = @AllPathType, 
DiffPath = @AllPath,
DiffLocType = @AllPathType, 
LogPath = @AllPath,
LogLocType = @AllPathType, 
Push = 1
where InstanceID = @InstanceID

END

----All backup locations BEGIN-------



----Full backup location BEGIN-------
If @FullPath is NOT NULL
Begin

If @FullPathType is NULL
Begin
	PRINT '@FullPathType can''t be NULL.  Valid values are Local, NAS, Remote, etc.'
	RETURN
End

UPDATE dbo.DBMaint
SET 
PrevFullPath = FullPath,
PrevFullLocType = FullLocType,
FullPath = @FullPath,
FullLocType = @FullPathType,
Push = 1
where InstanceID = @InstanceID

END

----Full backup location BEGIN-------



----Diff backup location BEGIN-------
If @DiffPath is NOT NULL
Begin

If @DiffPathType is NULL
Begin
	PRINT '@DiffPathType can''t be NULL.  Valid values are Local, NAS, Remote, etc.'
	RETURN
End

UPDATE dbo.DBMaint
SET 
PrevDiffPath = DiffPath,
PrevDiffLocType = DiffLocType,
DiffPath = @DiffPath,
DiffLocType = @DiffPathType,
Push = 1
where InstanceID = @InstanceID

END

---- Diff backup location BEGIN-------


----Log backup location BEGIN-------
If @LogPath is NOT NULL
Begin

If @LogPathType is NULL
Begin
	PRINT '@LogPathType can''t be NULL.  Valid values are Local, NAS, Remote, etc.'
	RETURN
End

UPDATE dbo.DBMaint
SET 
PrevLogPath = LogPath,
PrevLogLocType = LogLocType,
LogPath = @LogPath,
LogLocType = @LogPathType,
Push = 1
where InstanceID = @InstanceID

END

---- Log backup location BEGIN-------



;
GO
/****** Object:  StoredProcedure [Collector].[CheckDBResultInsert]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collector].[CheckDBResultInsert]
    @ExecutionDateTime DATETIME ,
    @ServerName VARCHAR(100) ,
    @DBName VARCHAR(100) ,
    @BeginTime DATETIME ,
    @EndTime DATETIME ,
    @Error INT ,
    @Level INT ,
    @State INT ,
    @MessageText VARCHAR(7000) ,
    @RepairLevel INT ,
    @Status INT ,
    @DbId INT ,
    @Id INT ,
    @IndId INT ,
    @PartitionId INT ,
    @AllocUnitId INT ,
    @File INT ,
    @Page INT ,
    @Slot INT ,
    @RefFile INT ,
    @RefPage INT ,
    @RefSlot INT ,
    @Allocation INT
	
   
AS 
/*

Explain here.

*/



    DECLARE @InstanceID INT



    SET @instanceID = ( SELECT  InstanceID
                        FROM    dbo.Servers
                        WHERE   ServerName = @ServerName
                      )







    INSERT  Collector.CheckDBResult
            SELECT  @InstanceID ,
                    @ExecutionDateTime ,
                    @DBName ,
                    @BeginTime ,
                    @EndTime ,
                    @Error ,
                    @Level ,
                    @State ,
                    @MessageText ,
                    @RepairLevel ,
                    @Status ,
                    @DbId ,
                    @Id ,
                    @IndId ,
                    @PartitionId ,
                    @AllocUnitId ,
                    @File ,
                    @Page ,
                    @Slot ,
                    @RefFile ,
                    @RefPage ,
                    @RefSlot ,
                    @Allocation,
					0 -- Managed is set to 0 because it's just been inserted. 










;
GO
/****** Object:  View [Collector].[DBPropertiesCurrent]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[DBPropertiesCurrent]
AS 
SELECT  D.ExecutionDateTime ,
		S.InstanceID,
        S.ServerName ,
        S.ServiceLevel AS ServiceLevel,
		S.SQLVersion as Version,
		S.SQLEdition as Edition,
		S.Descr,
        D.DBName ,
        D.DBOwner ,
        D.LastBackup ,
        D.LastLogBackup ,
        D.LastDiffBackup ,
        D.AutoClose ,
        D.AutoShrink ,
        D.DBReadOnly ,
        D.Collation ,
        D.CompatLevel ,
        D.DefaultSchema ,
        D.FullTxtEnabled ,
        D.RecoveryModel ,
        D.CreateDate ,
        D.CaseSensitive ,
        D.Status ,
        D.ANSINullDefault ,
        D.ANSINullsEnabled ,
        D.ANSIPaddingEnabled ,
        D.ANSIWarningsEnabled ,
        D.ArithAbortEnabled ,
        D.AutoCreateIncrementalStatisticsEnabled ,
        D.AutoCreateStatisticsEnabled ,
        D.AutoUpdateStatisticsAsync ,
        D.AutoUpdateStatisticsEnabled ,
        D.AvailabilityDatabaseSynchronizationState ,
        D.AvailabilityGroupName ,
        D.BrokerEnabled ,
        D.ChangeTrackingAutoCleanUp ,
        D.ChangeTrackingEnabled ,
        D.ChangeTrackingRetentionPeriod ,
        D.ChangeTrackingRetentionPeriodUnits ,
        D.CloseCursorsOnCommitEnabled ,
        D.ConcatenateNullYieldsNull ,
        D.ContainmentType ,
        D.DatabaseGuid ,
        D.DatabaseOwnershipChaining ,
        D.DatabaseSnapshotBaseName ,
        D.DataSpaceUsage ,
        D.DateCorrelationOptimization ,
        D.DboLogin ,
        D.DefaultFileGroup ,
        D.DefaultFileStreamFileGroup ,
        D.DefaultFullTextCatalog ,
        D.DefaultFullTextLanguage ,
        D.DefaultLanguage ,
        D.DelayedDurability ,
        D.EncryptionEnabled ,
        D.FilestreamDirectoryName ,
        D.FilestreamNonTransactedAccess ,
        D.HasFileInCloud ,
        D.HasMemoryOptimizedObjects ,
        D.HonorBrokerPriority ,
        D.IndexSpaceUsage ,
        D.IsAccessible ,
        D.IsDatabaseSnapshot ,
        D.IsDatabaseSnapshotBase ,
        D.IsFederationMember ,
        D.IsFullTextEnabled ,
        D.IsMailHost ,
        D.IsManagementDataWarehouse ,
        D.IsMirroringEnabled ,
        D.IsParameterizationForced ,
        D.IsReadCommittedSnapshotOn ,
        D.IsSystemObject ,
        D.IsUpdateable ,
        D.IsVarDecimalStorageFormatEnabled ,
        D.LocalCursorsDefault ,
        D.LogReuseWaitStatus ,
        D.MemoryAllocatedToMemoryOptimizedObjectsInKB ,
        D.MemoryUsedByMemoryOptimizedObjectsInKB ,
        D.MirroringFailoverLogSequenceNumber ,
        D.MirroringID ,
        D.MirroringPartner ,
        D.MirroringPartnerInstance ,
        D.MirroringRedoQueueMaxSize ,
        D.MirroringRoleSequence ,
        D.MirroringSafetyLevel ,
        D.MirroringSafetySequence ,
        D.MirroringStatus ,
        D.MirroringTimeout ,
        D.MirroringWitness ,
        D.MirroringWitnessStatus ,
        D.NestedTriggersEnabled ,
        D.NumericRoundAbortEnabled ,
        D.PageVerify ,
        D.PrimaryFilePath ,
        D.QuotedIdentifiersEnabled ,
        D.ReadOnly ,
        D.RecoveryForkGuid ,
        D.RecursiveTriggersEnabled ,
        D.ServiceBrokerGuid ,
        D.SizeInMB ,
        D.SnapshotIsolationState ,
        D.SpaceAvailableInKB ,
        D.State ,
        D.TargetRecoveryTime ,
        D.TransformNoiseWords ,
        D.Trustworthy ,
        D.TwoDigitYearCutoff ,
		'This view shows the latest collection for database properties.' AS ViewDesc
FROM    Collector.DBProperties AS D
        INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
		ON D.InstanceID = S.[InstanceID]
        WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                        FROM   Collector.DBProperties D2  WITH (NOLOCK)
                        WHERE D2.InstanceID = D.InstanceID
                    ) 
		AND s.IsActive = 1
        AND s.ServiceLevel IS NOT NULL;
;
GO
/****** Object:  StoredProcedure [Archive].[DBMaintInsert]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Archive].[DBMaintInsert]

   
AS

DECLARE @ExecutionDateTime datetime

SET @ExecutionDateTime = GETDATE()

INSERT Archive.DBMaint (ExecutionDateTime, DBName, InstanceID, PrevFullLocType, PrevFullPath, PrevFullDate, PrevFullMirrorLocType, PrevFullMirrorPath, PrevFullMirrorDate, PrevDiffLocType, PrevDiffPath, PrevDiffDate, PrevDiffMirrorLocType, PrevDiffMirrorPath, PrevDiffMirrorDate, PrevLogLocType, PrevLogPath, PrevLogDate, PrevLogMirrorLocType, PrevLogMirrorPath, PrevLogMirrorDate, FullLocType, FullPath, MirrorFullBackup, FullMirrorLocType, FullMirrorPath, DiffLocType, DiffPath, MirrorDiffBackup, DiffMirrorLocType, DiffMirrorPath, LogLocType, LogPath, MirrorLogBackup, LogMirrorLocType, LogMirrorPath, BackupRetHrs, BackupDelFileBefore, BackupDelFileBeforeAgree, Push, BufferCount, MaxTransferSize, NumberOfFiles, NumberOfLogFiles, MultiDriveBackup, ExcludeFromBackup, ExcludeFromDiffBackup, ExcludeFromLogBackup, ExcludeFromReindex, ExcludeFromCheckDB, CheckDBOptions, CheckDBRetWks, BackupGroupOrder, BackupGroupDBOrder, ReindexGroupOrder, ReindexOrder, CheckDBGroupOrder, CheckDBOrder, BackupLogging, ReindexLogging, BackupLoggingRetDays, ReindexLoggingRetDays, CheckDBLoggingRetDays, BackupLoggingPath, ReindexLoggingPath, CheckDBLoggingPath, ReindexRecoveryModel, LastUpdate, BackupDeployedToServer, CheckDBDeployedToServer, BackupReport, BackUpAlertThresholdHrs, LogBackupReport, LogBackupAlertThresholdMins, IsTDE, TDECertName, TDECertBackupLoc, TDECertBackupPword)
SELECT @ExecutionDateTime, DBName, InstanceID, PrevFullLocType, PrevFullPath, PrevFullDate, PrevFullMirrorLocType, PrevFullMirrorPath, PrevFullMirrorDate, PrevDiffLocType, PrevDiffPath, PrevDiffDate, PrevDiffMirrorLocType, PrevDiffMirrorPath, PrevDiffMirrorDate, PrevLogLocType, PrevLogPath, PrevLogDate, PrevLogMirrorLocType, PrevLogMirrorPath, PrevLogMirrorDate, FullLocType, FullPath, MirrorFullBackup, FullMirrorLocType, FullMirrorPath, DiffLocType, DiffPath, MirrorDiffBackup, DiffMirrorLocType, DiffMirrorPath, LogLocType, LogPath, MirrorLogBackup, LogMirrorLocType, LogMirrorPath, BackupRetHrs, BackupDelFileBefore, BackupDelFileBeforeAgree, Push, BufferCount, MaxTransferSize, NumberOfFiles, NumberOfLogFiles, MultiDriveBackup, ExcludeFromBackup, ExcludeFromDiffBackup, ExcludeFromLogBackup, ExcludeFromReindex, ExcludeFromCheckDB, CheckDBOptions, CheckDBRetWks, BackupGroupOrder, BackupGroupDBOrder, ReindexGroupOrder, ReindexOrder, CheckDBGroupOrder, CheckDBOrder, BackupLogging, ReindexLogging, BackupLoggingRetDays, ReindexLoggingRetDays, CheckDBLoggingRetDays, BackupLoggingPath, ReindexLoggingPath, CheckDBLoggingPath, ReindexRecoveryModel, LastUpdate, BackupDeployedToServer, CheckDBDeployedToServer, BackupReport, BackUpAlertThresholdHrs, LogBackupReport, LogBackupAlertThresholdMins, IsTDE, TDECertName, TDECertBackupLoc, TDECertBackupPword
FROM dbo.DBMaint




;
GO
/****** Object:  StoredProcedure [Setup].[BackupDefer]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Setup].[BackupDefer]
(
@ServerName varchar(100),
@DBName varchar(100),
@BackupType varchar(10),
@DeferDate date,
@DeferEndDate date,
@DeferEndTime time(7)
)

  
AS

SET NOCOUNT ON

--SELECT * FROM Collector.DriveSpace

DECLARE @InstanceID INT,
		@AlreadyExists bit,
		@Caption varchar(1000)


SET @InstanceID = (SELECT InstanceID FROM dbo.Servers
WHERE ServerName = @ServerName)




SELECT @AlreadyExists = (SELECT COUNT(1) FROM Alert.BackupDefer
WHERE (InstanceID = @InstanceID
AND DBName = @DBName
and BackupType = @BackupType
AND CAST(GETDATE() AS DATE) < DeferEndDate)
)

--SET @AlreadyExists = 0
---Only insert a new row if it doesn't already exist.
IF @AlreadyExists = 0
BEGIN 

	INSERT Alert.BackupDefer(InstanceID, DBName, BackupType, DeferDate, DeferEndDate, DeferEndTime)
	SELECT @InstanceID, @DBName, @BackupType, @DeferDate, @DeferEndDate, @DeferEndTime

END

---If it exists, then update it instead.
IF @AlreadyExists = 1
BEGIN 

	UPDATE Alert.BackupDefer
	SET
	  DeferDate = @DeferDate,
	  DeferEndDate = @DeferEndDate,
	  DeferEndTime = @DeferEndTime

	WHERE InstanceID = @InstanceID
	AND DBName = @DBName
	AND BackupType = @BackupType
	

END

SELECT 'Inserted Row',
	   @InstanceID AS InstanceID, 
	   @DBName AS DBName, 
	   @BackupType AS BackupType, 
	   @DeferDate AS DeferDate, 
	   @DeferEndDate AS DeferEndDate, 
	   @DeferEndTime AS DeferEndTime





;
GO
/****** Object:  View [Collector].[DatabasesCurrent]    Script Date: 11/26/2015 18:47:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[DatabasesCurrent]
AS
SELECT  D.DBId ,
        D.ExecutionDateTime ,
		S.InstanceID,
		S.ServerName ,
		S.ServiceLevel AS ServiceLevel,
		S.SQLVersion as Version,
		S.SQLEdition as Edition,
		S.Descr,
        D.DBName ,
        D.DBSizeOnDiskInMB ,
        D.Descr AS DBDescr,
		'This view shows the latest collection for databases.' AS ViewDesc
FROM    Collector.Databases D
        INNER JOIN dbo.Servers S WITH ( NOLOCK ) ON D.InstanceID = S.[InstanceID]
WHERE   D.ExecutionDateTime = ( SELECT  MAX(ExecutionDateTime) AS ExecutionDateTime
                                FROM    Collector.Databases D2 WITH ( NOLOCK )
                                WHERE   D2.InstanceID = D.InstanceID
                              )
        AND S.IsActive = 1
        AND S.ServiceLevel IS NOT NULL;
;
GO
/****** Object:  UserDefinedFunction [dbo].[ServerName]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ServerName] (@ServerID int)
RETURNS varchar(100)
 
AS
-- place the body of the function here
BEGIN
     declare @ServerName varchar(100)
     
    SET @ServerName = (select ServerName from dbo.Servers with (NOLOCK) where InstanceID = @ServerID)
     
     RETURN @ServerName
END



;
GO
/****** Object:  View [Collector].[LoginsCurrent]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[LoginsCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion as Version,
			S.SQLEdition as Edition,
			S.Descr,
			D.sid,
			D.status,
			D.createdate,
			D.updatedate,
			D.accdate,
			D.totcpu,
			D.totio,
			D.spacelimit,
			D.timelimit,
			D.resultlimit,
			D.name,
			D.dbname,
			D.password,
			D.language,
			D.denylogin,
			D.hasaccess,
			D.isntname,
			D.isntgroup,
			D.isntuser,
			D.sysadmin,
			D.securityadmin,
			D.serveradmin,
			D.setupadmin,
			D.processadmin,
			D.diskadmin,
			D.dbcreator,
			D.bulkadmin,
			D.loginname,
			D.BadPasswordCount,
			D.BadPasswordTime,
			D.HistoryLength,
			D.PasswordLastSetTime,
			D.PasswordHash,
			D.LoginType,
			D.DateLastModified,
			D.IsDisabled,
			D.IsLocked,
			D.IsPasswordExpired,
			D.IsSystemObject,
			D.LanguageAlias,
			D.MustChangePassword,
			D.PasswordExpirationEnabled,
			D.PasswordPolicyEnforced,
			D.State,
			D.WindowsLoginAccessType,
			D.DefaultDatabase,
			'This view shows the latest collection for logins. You can use this to tell when logins are added and deleted.  As well you can use this to tell when they''re added and removed from server-level groups.' AS ViewDesc
    FROM    Collector.Logins D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.Logins D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL

;
GO
/****** Object:  StoredProcedure [Setup].[ReplLatencyDefer]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Setup].[ReplLatencyDefer]
(
@PublServerName varchar(100),
@PublDBName varchar(100),
@PublName varchar(100),
@SubrServerID int,
@SubrDBName varchar(100),
@DeferDate date,
@DeferEndDate date,
@DeferEndTime time(7)
)

  
AS

SET NOCOUNT ON


DECLARE @PublServerID INT,
		@AlreadyExists bit


SET @PublServerID = (SELECT InstanceID FROM dbo.Servers
WHERE ServerName = @PublServerName)

--- Get the value from the DriveSpace table.
---This is the best way to make sure you've got the proper entry that's being
---reported on.  
---This also takes the data from the last collection period to make sure it's
---the most accurate.




SELECT @AlreadyExists = (SELECT COUNT(1) FROM Alert.ReplLatencyDefer
WHERE (PublServerID = @PublServerID
AND PublDBName = @PublDBName
AND PublName = @PublName
AND SubrServerID = @SubrServerID
AND SubrDBName = @SubrDBName
AND CAST(GETDATE() AS DATE) < DeferEndDate)
)

--SET @AlreadyExists = 0
---Only insert a new row if it doesn't already exist.
IF @AlreadyExists = 0
BEGIN 

	INSERT Alert.ReplLatencyDefer(PublServerID, PublDBName, PublName, SubrServerID, SubrDBName, DeferDate, DeferEndDate, DeferEndTime)
	SELECT @PublServerID, @PublDBName, @PublName, @SubrServerID, @SubrDBName, @DeferDate, @DeferEndDate, @DeferEndTime

END

---If it exists, then update it instead.
IF @AlreadyExists = 1
BEGIN 

	UPDATE Alert.ReplLatencyDefer
	SET
	  DeferEndDate = @DeferEndDate,
	  DeferEndTime = @DeferEndTime

WHERE PublServerID = @PublServerID
AND PublDBName = @PublDBName
AND PublName = @PublName
AND SubrServerID = @SubrServerID
AND SubrDBName = @SubrDBName
	

END

SELECT 'Inserted Row', @PublServerID, @PublDBName, @PublName, @SubrServerID, @SubrDBName, @DeferDate, @DeferEndDate, @DeferEndTime





;
GO
/****** Object:  StoredProcedure [Collector].[IndexTriggerPathGet]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collector].[IndexTriggerPathGet]

   
AS
SELECT MinionTriggerPath 
FROM dbo.IndexSettingsDB 
WHERE MinionTriggerPath IS NOT NULL 
UNION
SELECT MinionTriggerPath 
FROM dbo.IndexSettingsDBDefault
WHERE MinionTriggerPath IS NOT NULL
;
GO
/****** Object:  StoredProcedure [dbo].[IndexSettingsTablePush]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[IndexSettingsTablePush]
(
@InstanceID BIGINT
)

  
AS

/*

This gets the servers that have index settings to push.
It pushes individual table settings.

Called from IndexSettingsPush.
*/

SELECT 
InstanceID, DBName, SchemaName, TableName, Exclude, ReindexGroupOrder, ReindexOrder, ReorgThreshold, RebuildThreshold, FILLFACTORopt, PadIndex, ONLINEopt, SortInTempDB, MAXDOPopt, DataCompression, GetRowCT, GetPostFragLevel, UpdateStatsOnDefrag, StatScanOption, IgnoreDupKey, StatsNoRecompute, AllowRowLocks, AllowPageLocks, WaitAtLowPriority, MaxDurationInMins, AbortAfterWait, PushToMinion, LogIndexPhysicalStats, IndexScanMode, TablePreCode, TablePostCode, LogProgress, LogRetDays, PartitionReindex, isLOB, TableType, IncludeUsageDetails
FROM dbo.IndexSettingsTable
WHERE InstanceID = @InstanceID
AND Push = 1


;
GO
/****** Object:  StoredProcedure [DBFile].[MaxSizeChange]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [DBFile].[MaxSizeChange]
(
@InstanceID int = NULL,
@ServerName varchar(100) = NULL,
@DBName varchar(100),
@DBFileID int = NULL,
@DBFileName varchar(100) = NULL,
@HasMaxSize bit,
@MaxSizeType varchar(10),
@MaxSizeValue bigint
)

  
AS


Declare @ID int;

---Get the ServerName if it wasn't passed in.
If @ServerName IS NULL
	BEGIN
	SET @ServerName = (SELECT ServerName from dbo.Servers
					WHERE InstanceID = @InstanceID );
	END	
	
---Get the InstanceID if it wasn't passed in.
If @InstanceID IS NULL
	BEGIN
	SET @InstanceID = (SELECT InstanceID from dbo.Servers
					WHERE ServerName = @ServerName );
	END	

---Get the FileID if it wasn't passed in.
If @DBFileID IS NULL
	BEGIN
	SET @DBFileID = (SELECT DBFileID from dbo.DBFilePropertiesConfig
					WHERE InstanceID = @InstanceID and DBName = @DBName and DBFileName = @DBFileName);
	END					

---Get the FileName if it wasn't passed in.
If @DBFileName IS NULL
	BEGIN
	SET @DBFileName = (SELECT DBFileName from dbo.DBFilePropertiesConfig
					WHERE InstanceID = @InstanceID and DBName = @DBName and DBFileID = @DBFileID);
	END	

---Get the ID of the File being changed.

	SET @ID = (SELECT ID from dbo.DBFilePropertiesConfig
					WHERE InstanceID = @InstanceID and DBName = @DBName and DBFileID = @DBFileID  and DBFileName = @DBFileName);


If @HasMaxSize = 0
BEGIN
	SET @MaxSizeValue = 2147483648;
	SET @MaxSizeType = 'KB';
END

-----Convert everything to KB to make it uniform	
If @HasMaxSize = 1
BEGIN
--	If @MaxSizeType = 'MB'
--	Begin
--		SET @MaxSizeValue = dbo.MBtoKB(@MaxSizeValue)
--		SET @MaxSizeType = 'KB'
--	End
	
--	If @MaxSizeType = 'GB'
--	Begin
--		SET @MaxSizeValue = dbo.GBtoKB(@MaxSizeValue);
--		SET @MaxSizeType = 'KB'
--	End
	
	If @MaxSizeType = 'TB'
	Begin
	
		If @MaxSizeValue > 2
			SET @MaxSizeValue = 2;
		--SET @MaxSizeValue = dbo.TBtoKB(@MaxSizeValue);
		--SET @MaxSizeType = 'KB'
		
	End	
-------End Convert to KB	
	
END


BEGIN TRY
	UPDATE dbo.DBFilePropertiesConfig
	SET HasMaxSize = @HasMaxSize,
		MaxSizeType = @MaxSizeType,
		MaxSizeValue = @MaxSizeValue,
		Push = 1
	WHERE ID = @ID

	SELECT S.ServerName, DC.* 
	from dbo.DBFilePropertiesConfig DC
	Inner Join dbo.Servers S
	ON DC.InstanceID = S.InstanceID
	WHERE DC.ID = @ID

END TRY

BEGIN CATCH
	Begin
		select 'Error: ' + CAST(ERROR_NUMBER() as varchar(10)) + '-- MaxSizeValue cannot be above 2TB.  This is a SQL Server limitation.'
	End

END CATCH





;
GO
/****** Object:  View [Collector].[LogspaceCurrent]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[LogspaceCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion as Version,
			S.SQLEdition as Edition,
			S.Descr,
			D.DBName,
			D.SIZE,
			D.UsedSpace,
			D.VolumeFreeSpace,
			D.Growth,
			D.GrowthType,
			D.MAXSIZE,
			'This view shows the latest size of all the logs. To see the growth rate of all the logs just query the base table (Collector.LogSpace) and graph it in Excel.' AS ViewDesc
    FROM    Collector.Logspace D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.Logspace D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL
;
GO
/****** Object:  Table [dbo].[ServerAppRoleApp]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ServerAppRoleApp](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InstanceID] [int] NULL,
	[AppID] [int] NULL,
	[AppRoleID] [int] NULL,
 CONSTRAINT [pk_ServerAppRoleApp_ID] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uniNonInstanceIDAppID] ON [dbo].[ServerAppRoleApp] 
(
	[InstanceID] ASC,
	[AppID] ASC,
	[AppRoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[RestoreFromBackupTEST]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[RestoreFromBackupTEST] (@Server varchar(30), @DBName Varchar(256), @ForceSimpleRestore Bit = 0, @PutinStandby bit = 0, @Debug bit = 0)

  
 AS

	Declare @BackUpFolder1			VarChar(4000),
			@BackupFolder2			VarChar(4000),
			@BackupFileFolder		VarChar(4000),
			@FullLocType			VarChar(5),
			@LogLocType				VarChar(5),
			@LogBackupFileFolder	VarChar(4000),
			@LogBackupFolder1		VarChar(4000),
			@logBackupFolder2		VarChar(4000),
			@InstanceID				SmallInt,
			@NumOfFiles				TinyInt,
			@BackupFileCount		TinyInt,
			@CurrBackupFileName		VarChar(4000),
			@CurrLogBackupFileName	VarChar(4000),  
			@DBRestoreString		VarChar(8000),
			@LogRestoreString		VarChar(8000),
			@RecoveryModel			VarChar(50),
			@NewLine				Char(2),
			@SqlCmd					VarChar(4000),
			@CurrLogicalName		NVarchar(128), 
			@CurrPhysicalName		NVarchar(260),
			@Cntr					Tinyint


--Declare @server		VarChar(30),
--		@DBName		VarChar(256),
--		@DaysOld	TinyInt,
--		@Debug		bit

--Set @Debug = 1

--Drop table #BackupFiles
--Drop table #BackupRestoreProcess
--Drop table #LogBackupRestoreProcess 
--Drop table #LogBackupFiles 

Set NoCount ON
/*********************************************************************************************************/
/* 1. Collect .Bak  files using a UNC path convention from the network location from the SQLAdmin server */
/*********************************************************************************************************/




create table #Results
(col1 nvarchar(max))


/************************************************************************/
/* Setup the backup folder where full backups will be reterieved from.  */
/************************************************************************/

-- Initialize all the large varchar strings

	Set @backupfilefolder		= ''
	Set @BackupFolder1			= ''
	Set @BackupFolder2			= ''
	Set @LogBackupFileFolder	= ''
	Set @LogBackupFolder1		= ''
	Set @logBackupFolder2		= ''
	Set @SqlCmd					= ''
	Set @NewLine = Char(13) + Char(10)
	Set @Cntr	 = 0

-- Get the instanceid from the servers table in DBStats

	If exists (Select 1 from Dbo.Servers 
			   Where	ServerName = @server)
	  Begin 
		Select	@Instanceid = InstanceID
		From	Dbo.Servers 
		Where	ServerName = @server
	  End
	Else
	 Begin
		INSERT #Results SELECT  'Invalid server name. Please provide a valid server name'
		Return;
	 End

If @Debug = 1
  Begin
   Select 'Server Name = ' + @Server
   Select 'Instance ID = ' + Cast (@InstanceID as varchar(10))
   Select 'DBName= '	   + @DBName
  End

-- Get the number of files, location and full & Log backup path from the master DBMaint table
-- in DBStats


	If exists (Select 1 from Dbo.DBMaint Where  InstanceID = @instanceid
												 And	DBName = @DBName)
		Begin

			Select	@NumOfFiles			= NumberOfFiles,
					@FullLocType		= FullLocType,
					@BackUpFolder1		= FullPath,
					@LogLocType			= LogLocType,
					@LogBackupFolder1	= LogPath
			From	Dbo.DBMaint
			Where	InstanceID = @instanceid
			And		DBName = @DBName
		End
	Else 
	   Begin
			INSERT #Results SELECT  'Server/Instanceid and/or DBname is not present in the DBMaint table'
			Return;
	   End	 

-- Collect the recovery model of the database

	Select	@RecoveryModel = RecoveryModel
	From	Collector.DBProperties
	Where	InstanceID = @InstanceID
	And		DBName = @DBName


   If @FullLoctype = 'Local'
	  Set @BackupFolder2 = '\\' + @Server + '\'

If @Debug = 1
  Begin
   Select 'Backupfolder 1 before processing:' + @BackupFolder2
   Select 'Backupfolder 2 before processing:' + @BackupFolder1
   Select 'RecoveryModel'			+ @RecoveryModel
   Select 'InstanceID '				+ Cast (@InstanceID as varchar(10))
   Select 'Databases Name '			+ @Dbname
   Select 'Server Name '			+ @Server
   Select 'Number of files: '		+ Cast (@NumOfFiles as varchar(10))
  End

	-- Make sure the backup folder ends in a '\'

	if (Substring(@BackUpFolder1, LEN(Rtrim(@BackUpFolder1)),1) <> '\')
		Set @BackUpFolder1 = @BackUpFolder1 + '\'	   
		
		
	Set @BackUpFolder2 = @BackUpFolder2 + @Backupfolder1 + @Server+ '\' + @Dbname + '\'

	Set @BackUpFolder2 = Replace (@BackUpFolder2, ':', '$')


If @Debug = 1
  Begin
   Select 'Backupfolder 1 after processing:'		+ @BackupFolder1
   Select 'Backupfolder 2 after processing:'		+ @BackupFolder2
  End

		  create table #BackupFiles  
		  (  
		  Ident  int identity (1,1) not null,  
		  Col1	 varchar(1000) null,  
		  ) 
		  -- The folder needs to come from DBmaint table for the database in question
		  --Set @DBName = 'Test'
		  --Set @BackUpFolder ='C:\DBBTIS800LBS1\Test\' 

		  Set @BackUpFileFolder = 'dir /B ' + @BackupFolder2 + '*.Bak'
		  insert into #BackupFiles  
		  Exec master..xp_cmdshell @BackUpFileFolder  

If @Debug = 1
  Begin		  
	Select '# Backup files as on disk:'	
	Select Count(*) from #BackupFiles 
	Select * from #BackupFiles
  End
	  

	  If (select 1 from #BackupFiles 
	      where Col1 Like '%The system%'  or 
		        Col1 Like '%The network%' or
				Col1 Like '%File not%') > 0
	   Begin
	    INSERT #Results SELECT  '.Bak path is invalid cannot proceed with restore'
		Return;
	   End
	    
	  /*************************************************  
	  Parse date and time out of filenames and place into another temp table that holds both  
	  the filename, and the date, ordered by datetime.  this puts the files in order from earliest  
	  to latest to make the cursor easier for the restore.  
	  **************************************************/  
		    
		  select Col1 as FName,   
		  Convert(DateTime,  
		  substring(right(col1, 14), 1, 2) + '/' + --Month  
		  substring(right(col1, 12), 1, 2) + '/' + --Day  
		  substring(right(col1, 18), 1, 4) + ' ' + --Year  
		  substring(right(col1, 10), 1, 2) + ':' + --Hrs  
		  substring(right(col1, 8), 1, 2)  + ':' + --Mins  
		  substring(right(col1, 6), 1, 2)          --Secs  
		  ) AS DateAndTime   
		  into #BackupRestoreProcess from #backupfiles   
		  where Col1 is NOT NULL  
		  Order by Fname, DateAndTime Desc  
	  


		Delete #BackupRestoreProcess where DateAndTime < (Select Max(DateAndTime) from #BackupRestoreProcess)

If @Debug = 1
  Begin
    Select 'Backup files after deleting "non-current" files'			  
	Select * from #BackupRestoreProcess 
  End	   

   -- If the number of files don't match quit the SP as we have missing backup files

-- This is for testing
	-- Setup the initial recovery srting
	--Set @DBRestoreString = ''



/*****************************************************************************************************/
/* 2. Generate a backup restore statement with or without recovery based on the DB recovery model    */
/*****************************************************************************************************/

	--Set @DBRestoreString = 'Restore database [' + @DBName + '] From ';
	  INSERT #Results SELECT  'Restore database [' + @DBName + '] From ';

	 If @NumOfFiles > 1
	   BEGIN
   
		If @debug = 1 
		 Select 'in .bak restore cursor block'

		 If (Select Count(*) from #BackupRestoreProcess) < @NumOfFiles  
			 BEGIN
					INSERT #Results SELECT  ('Missing Backup files. Cannot proceed with database recovery')
					Return
			 END
		
			Set @Cntr = @NumOfFiles

			DECLARE RestoreDBs CURSOR  
			READ_ONLY FOR  
			SELECT FName from #BackupRestoreProcess


			-- Add the backup file locations to the recovery string 

			OPEN RestoreDBs  
  
			FETCH NEXT FROM RestoreDBs INTO @CurrBackupFileName  
			WHILE (@@fetch_status <> -1)  
			BEGIN

			--Set @DBRestoreString = @DBRestoreString + 'Disk = ' + Char(39) + @BackUpFolder2 + @CurrBackupFileName +  Char(39) + ', ' 
				If @Cntr > 1
				  INSERT #Results SELECT  'Disk = ' + Char(39) + @BackUpFolder2 + @CurrBackupFileName +  Char(39) + ','
				Else
				  INSERT #Results SELECT  'Disk = ' + Char(39) + @BackUpFolder2 + @CurrBackupFileName +  Char(39)
				Set @Cntr = @Cntr - 1

				FETCH NEXT FROM RestoreDBs INTO @CurrBackupFileName   
			End

			--Delete the last ',' from the string

			--Set @DBRestoreString = Substring (@DBRestoreString, 1, Len(Rtrim(@DBRestoreString)) - 1) 
			CLOSE RestoreDBs  
			DEALLOCATE RestoreDBs 
			If @debug = 1
				Select 'End of DB Restore Cursor'
		END
	Else   
	   BEGIN
	     Select @CurrBackupFileName = [FName]
		 From #BackupRestoreProcess
		 --Set @DBRestoreString = @DBRestoreString + 'Disk = ' + Char(39) + @BackUpFolder2 + @CurrBackupFileName +  Char(39) 
		 INSERT #Results SELECT  'Disk = ' + Char(39) + @BackUpFolder2 + @CurrBackupFileName +  Char(39)
	   END

	
	--INSERT #Results SELECT  @DBRestoreString + @NewLine
	INSERT #Results SELECT  'With '


/************************************************************************************
-- get the logical and physical file names from the .bak file.
************************************************************************************/
	Create table #BakFileDetails (
	LogicalName				NVarchar(128),
	PhysicalName			NVarchar(260),
	[Type]					Char(1),
	FileGroupName			NVarchar(128),
	Size					Numeric(20,0),
	MaxSize					Numeric(20,0),
	Fileid					BigInt,
	CreateLsn				Numeric(25,0),
	DropLSN					Numeric(25,0),
	UniqueID				UniqueIdentifier,
	ReadonlyLSN				Numeric(25,0),
	ReadWriteLSN			Numeric(25,0),
	BackupSizeInBytes		BigInt,
	SourceBlockSize			Int,
	Filegroupid				Int,
	LogGroupGUID			UniqueIdentifier,
	DifferentialBaseLSN		Numeric(25,0),
	DifferentialBaseGUID	UniqueIdentifier,
	IsReadOnly				Bit,
	IsPresent				Bit,
	TDEThumbPRINT			VarBinary(32))


	--	Initialize File variables
	Set @CurrLogicalName = ''
	Set @CurrPhysicalName  = ''

	Set @SqlCmd = 'Restore filelistonly from disk = ' + Char(39) +  @BackUpFolder2 + @CurrBackupFileName + Char(39)
    
	If @debug = 1
	  Select 'restore filelistonly command : ' + @sqlcmd

	Insert into #BakFileDetails  
	Exec (@sqlcmd)

	DECLARE WithMoveDBFiles CURSOR  
	READ_ONLY FOR  
	SELECT Logicalname, Physicalname from #BakFileDetails 

	OPEN  WithMoveDBFiles
  
	FETCH NEXT FROM WithMoveDBFiles INTO @CurrLogicalName, @CurrPhysicalName  
	WHILE (@@fetch_status <> -1)  
	BEGIN
		INSERT #Results SELECT  'Move ' + Char(39) + @CurrLogicalName +  Char(39) + ' to ' + 
						Char(39) + @CurrPhysicalName + Char(39) + ',' + @Newline
		FETCH NEXT FROM WithMoveDBFiles INTO @CurrLogicalName, @CurrPhysicalName
	End

	--If @debug = 1
	--  Select 'Past with move recovery cursor. Restore with move string: ' + @DBRestoreString

-- Put database in Standby mode (for logshipping)
-- Note 
	If @PutinStandby = 1
	  Begin
		INSERT #Results SELECT  ''
		INSERT #Results SELECT  '--If the database is replacing an existing database please uncomment the line below'
		INSERT #Results SELECT  'Replace,'
		INSERT #Results SELECT  '-- Note that D: is being used a file standard if D: does not exist on the current system'
		INSERT #Results SELECT  '-- please use C: or any other directory that is feasable'
		INSERT #Results SELECT  'Standby = D:\Rollback_Undo_' + @DBname + '.Bak'
		Return ;
	  End


-- Note: 
-- Forcing a full recovery database to restore as in a simple recovery model

	If @ForceSimpleRestore  = 1 
	  Set @RecoveryModel = 'Simple'


-- If recovery model is Simple set the restore string to recovery and exit the sp. Log restore process is not needed.

	If @RecoveryModel = 'Simple'
	  Begin 
	    If @debug = 1
	      Select 'In recovery model Simple'
		INSERT #Results SELECT  '--If the database is replacing an existing database please uncomment the line below'
		INSERT #Results SELECT  'Replace,'
		INSERT #Results SELECT  'Recovery,' 
		INSERT #Results SELECT  'Stats=10'
		INSERT #Results SELECT  'Go'
		Return;
	  End
	Else
	  Begin 
	    If @debug = 1
	      Select 'In recovery model Full'
		INSERT #Results SELECT  '--If the database is replacing an existing database please uncomment the line below'
		INSERT #Results SELECT  'Replace,'
		INSERT #Results SELECT  'NoRecovery,'
		INSERT #Results SELECT  'Stats=10'
		INSERT #Results SELECT  'Go' 
		INSERT #Results SELECT  ''
	  End

		  
/****************************************************************************************************************/
/* Log restore process starts from here																			*/
/* 3. If Full recovery collect .Log backup files using a UNC path convention from the network location from the */ 
/*	  SQLAdmin server																		                    */
/****************************************************************************************************************/


  	create table #LogBackupFiles  
	(  
	Ident int identity (1,1) not null,  
	col1 varchar(1000) null,  
	) 

	  --Set @LogBackupFolder = 'C:\DBBTIS800LBS1\Test\'
		  


   If @LogLocType = 'Local'
	  Set @logBackupFolder2 = '\\' + @Server + '\'
  

	If @Debug = 1
	Begin
		Select 'Log backup folder 1 pre processing:' + @Logbackupfolder1
		Select 'Log backup folder 2 pre processing:' + @Logbackupfolder2
	End

	-- Make sure the backup folder ends in a '\'
	if (Substring(@LogBackupFolder1, LEN(Rtrim(@LogBackupFolder1)),1) <> '\')
		Set @LogBackupFolder1 = @LogBackupFolder1 + '\'	   
		
		
	Set @logBackupFolder2 = @logBackupFolder2 + @LogBackupFolder1 + @Server+ '\' + @Dbname + '\'

	Set @logBackupFolder2 = Replace (@logBackupFolder2, ':', '$')

	If @Debug = 1
	Begin
		Select 'Log backup folder 1 post processing:' + @Logbackupfolder1
		Select 'Log backup folder 2 post processing:' + @Logbackupfolder2
	End

	Set @LogRestoreString = ''

	Set @LogBackupFileFolder = 'dir /B ' + @logBackupFolder2 + '*.Trn'

	insert into #LogBackupFiles  
	Exec master..xp_cmdshell @LogBackUpFileFolder  

	If @Debug = 1
	 Begin
	   Select 'Log backup files pre processing:'
	   Select * from #LogBackupFiles
	 End


	  If (select 1 from #LogBackupFiles 
	      where col1 like '%The system%' or 
		        col1 like '%The network%') > 0
	   Begin
	    INSERT #Results SELECT  '.Trn path is invalid cannot proceed with restore'
		Return;
	   End


	select col1 AS FName,   
	Convert(DateTime,  
	substring(right(col1, 14), 1, 2) + '/' + --Month  
	substring(right(col1, 12), 1, 2) + '/' + --Day  
	substring(right(col1, 18), 1, 4) + ' ' + --Year  
	substring(right(col1, 10), 1, 2) + ':' + --Hrs  
	substring(right(col1, 8), 1, 2)  + ':' + --Mins  
	substring(right(col1, 6), 1, 2)          --Secs  
	) AS DateAndTime   
	into #LogBackupRestoreProcess from #LogBackupFiles   
	where col1 is NOT NULL  
	Order by DateAndTime asc  
  
  -- See if there are any log backups after the last full backup
  	If @Debug = 1
	 Begin
	   Select '.Trn files that have dates after the most current .bak'
	   Select * from #LogBackupRestoreProcess
	   where  DateAndTime > (Select top 1 DateAndTime from #BackupRestoreProcess) 
     End
  --delete all log backup files which are earlier than the last full backup
   
   Delete from #LogBackupRestoreProcess where  DateAndTime < (Select top 1 DateAndTime from #BackupRestoreProcess) 
   If @Debug = 1
	 Begin  
	    Select '.Trn files after the delete operation and files should have dates > most current .bak'
		Select * from #LogBackupRestoreProcess
	 End
  
/**************************************************************************************************/
/* 4. Generate log restore with no recovery statement(s) for each .Trn file based on the number   */
/*    of .Trn backups post the full backup                                                        */
/**************************************************************************************************/

   
   If (Select count(*) from #LogBackupRestoreProcess) >= 1  
     Begin 
		DECLARE RestoreLogs CURSOR  
		READ_ONLY FOR  
		SELECT FName from #LogBackupRestoreProcess

		-- Add the backup file locations to the recovery string 

		OPEN RestoreLogs  
  
		FETCH NEXT FROM RestoreLogs INTO @CurrLogBackupFileName  
		WHILE (@@fetch_status <> -1)  
		BEGIN
			If @debug = 1
			  Begin
				Select 'in .Trn restore cursor block'
				Select @CurrLogBackupFileName
			  End
			--Set @LogRestoreString = 'Restore Log ' + @DBName + 'From '
			--Set @LogRestoreString = @LogRestoreString + 'Disk = ' + Char(39) + @logBackupFolder2 + @CurrLogBackupFileName +  Char(39) + @Newline + 
			INSERT #Results SELECT  'Restore Log ' + @DBName + ' From ' + 'Disk = ' + Char(39) + @logBackupFolder2 + @CurrLogBackupFileName +  Char(39) + @Newline
			INSERT #Results SELECT  'With Norecovery,'
			INSERT #Results SELECT  'Stats=10' 
			INSERT #Results SELECT  'Go'
			INSERT #Results SELECT  '' 
			--Select @LogRestoreString
			FETCH NEXT FROM RestoreLogs INTO @CurrLogBackupFileName   
		End

	End
	CLOSE RestoreLogs  
	DEALLOCATE RestoreLogs 
	If @Debug = 1
	  INSERT #Results SELECT ('End of Log restore Cursor')

/*******************************************************************************************/
/* 5. Generate a DB recovery statement                                                      */
/*******************************************************************************************/

	--Set @DBRestoreString = 'Restore database [' + @DBName + '] with Recovery'
	--Select @DBRestoreString
	INSERT #Results SELECT  'Restore database [' + @DBName + '] with Recovery'
	Set NoCount Off

SELECT * FROM #Results








;
GO
/****** Object:  StoredProcedure [dbo].[RestoreFromBackup]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***********************************************************************************
procedure RestoreFromBackup
Created By: Sean McCown
Creation Date: 7/02/2012

Purpose: This procedure creates a database restore statment based on the db recovery model

Features: Types of restores that can be accomplished
 1. Restore of a database in simple recovery
 2. Restore of a database in Full recovery but can be restored as if the database is in simple recovery
 3. Restore of a database in Full recovery with i.e., restore of backup(s) and logs
 4. Restore of database in standby mode. 


Walkthrough:
 1. Collect .Bak  files using a UNC path convention from the network location from the SQLAdmin server
 2. Generate a backup restore statement with or without recovery based on the DB recovery model
 3. If Full recovery collect .Log backup files using a UNC path convention from the network location from the SQLAdmin server
 4. Generate log restore with no recovery statement(s) for each .Trn file based on the number 
    of .Trn backups post the full backup
 5. Generate a DB revoery statement 
 6. NOTE: Use the generated statement(s) to manually run the restore on the box the DB need to be restored on. 

Conventions:

Parameters:
-----------
--The folowing parameters are passed to the SP
@Server varchar(30) - Server Name passed to SP 
@DBName Varchar(256) - Database name passed to SP
@ForceSimpleRestore Bit - (0-off/1 -On) Force a database that is in full recovery to restore in simple mode
@PutinStandby Bit - (0-off/1 -On) ot be used with logshipping restores. Restores DB in Standby mode
@Debug bit - Debug state (0-off/1 -On) if on then all tables and parameters are dumped to console

-- The following parameters are local to the sp

@BackUpFolder1			VarChar(1000), - This holds the extra layer of "UNC redirect" if the backup path is 
										 local to the server itself

@BackupFolder2			VarChar(1000),	- UNC path to the backup folder
@BackupFileFolder		VarChar(1000),	- Need this to append the "dir" command to read the directory contents
@FullLocType			VarChar(5),		- Type of backup folder "Local" or "NAS"
@LogLocType				VarChar(5),		- Type of log backup folder  "Local" or "NAS"
@LogBackupFileFolder	VarChar(1000),	- Need this to append the "dir" command to read the directory contents
@LogBackupFolder1		VarChar(1000),	- This holds the extra layer of "UNC "redirect" if the log backup path is 
										 local to the server itself
@logBackupFolder2		VarChar(1000),	- UNC path to the log backup folder
@InstanceID				SmallInt,		- Server/Instance id of the server passed to the routine
@NumOfFiles				TinyInt,		- Number of .bak backup files 
@BackupFileCount		TinyInt,		- Number of .backup files to collected
@CurrBackupFileName		VarChar(1000),	- Cursor varible to pick up the .bak file name per iteration
@CurrLogBackupFileName	VarChar(1000),	- Cursor varible to pick up the .trn file name per iteration
@DBRestoreString		VarChar(8000),	- DB restore statement from .bak
@LogRestoreString		VarChar(8000),	- Log restore statement from .trn
@RecoveryModel			VarChar(50),	- DB recovery model 
@NewLine				Char(2)			- New line characters for restore statements
@SqlCmd					VarChar(4000),	- Command string to executing filelistonly on the backup set
@CurrLogicalName		NVarchar(128),	- Logical DB name of the DB to be restored
@CurrPhysicalName		NVarchar(260)	- Physical location of the DB files

Tables:
--------
#BackupFiles				- Initial table for .bak files collected from disk
#BackupRestoreProcess		- Final table post elimination of .bak files that are not "current" 
#LogBackupRestoreProcess	- Initial table for .Trn files collected from disk
#LogBackupFiles				- Final table post elimination of .Trn files that are not "current" 

Revision History:

***********************************************************************************/


CREATE procedure [dbo].[RestoreFromBackup] (@Server varchar(30), @DBName Varchar(256), @ForceSimpleRestore Bit = 0, @PutinStandby bit = 0, @Debug bit = 0)

  
 AS
 
	Declare @BackUpFolder1			VarChar(4000),
			@BackupFolder2			VarChar(4000),
			@BackupFileFolder		VarChar(4000),
			@FullLocType			VarChar(5),
			@LogLocType				VarChar(5),
			@LogBackupFileFolder	VarChar(4000),
			@LogBackupFolder1		VarChar(4000),
			@logBackupFolder2		VarChar(4000),
			@InstanceID				SmallInt,
			@NumOfFiles				TinyInt,
			@BackupFileCount		TinyInt,
			@CurrBackupFileName		VarChar(4000),
			@CurrLogBackupFileName	VarChar(4000),  
			@DBRestoreString		VarChar(8000),
			@LogRestoreString		VarChar(8000),
			@RecoveryModel			VarChar(50),
			@NewLine				Char(2),
			@SqlCmd					VarChar(4000),
			@CurrLogicalName		NVarchar(128), 
			@CurrPhysicalName		NVarchar(260),
			@Cntr					Tinyint


--Declare @server		VarChar(30),
--		@DBName		VarChar(256),
--		@DaysOld	TinyInt,
--		@Debug		bit

--Set @Debug = 1

--Drop table #BackupFiles
--Drop table #BackupRestoreProcess
--Drop table #LogBackupRestoreProcess 
--Drop table #LogBackupFiles 

Set NoCount ON
/*********************************************************************************************************/
/* 1. Collect .Bak  files using a UNC path convention from the network location from the SQLAdmin server */
/*********************************************************************************************************/




create table #Results
(col1 nvarchar(max))


/************************************************************************/
/* Setup the backup folder where full backups will be reterieved from.  */
/************************************************************************/

-- Initialize all the large varchar strings

	Set @backupfilefolder		= ''
	Set @BackupFolder1			= ''
	Set @BackupFolder2			= ''
	Set @LogBackupFileFolder	= ''
	Set @LogBackupFolder1		= ''
	Set @logBackupFolder2		= ''
	Set @SqlCmd					= ''
	Set @NewLine = Char(13) + Char(10)
	Set @Cntr	 = 0

-- Get the instanceid from the servers table in DBStats

	If exists (Select 1 from Dbo.Servers 
			   Where	ServerName = @server)
	  Begin 
		Select	@Instanceid = InstanceID
		From	Dbo.Servers 
		Where	ServerName = @server
	  End
	Else
	 Begin
		INSERT #Results SELECT  'Invalid server name. Please provide a valid server name'
		Return;
	 End

If @Debug = 1
  Begin
   Select 'Server Name = ' + @Server
   Select 'Instance ID = ' + Cast (@InstanceID as varchar(10))
   Select 'DBName= '	   + @DBName
  End

-- Get the number of files, location and full & Log backup path from the master DBMaint table
-- in DBStats


	If exists (Select 1 from Dbo.DBMaint Where  InstanceID = @instanceid
												 And	DBName = @DBName)
		Begin

			Select	@NumOfFiles			= NumberOfFiles,
					@FullLocType		= FullLocType,
					@BackUpFolder1		= FullPath,
					@LogLocType			= LogLocType,
					@LogBackupFolder1	= LogPath
			From	Dbo.DBMaint
			Where	InstanceID = @instanceid
			And		DBName = @DBName
		End
	Else 
	   Begin
			INSERT #Results SELECT  'Server/Instanceid and/or DBname is not present in the DBMaint table'
			Return;
	   End	 

-- Collect the recovery model of the database

	Select	@RecoveryModel = RecoveryModel
	From	Collector.DBProperties
	Where	InstanceID = @InstanceID
	And		DBName = @DBName


   If @FullLoctype = 'Local'
	  Set @BackupFolder2 = '\\' + @Server + '\'

If @Debug = 1
  Begin
   Select 'Backupfolder 1 before processing:' + @BackupFolder2
   Select 'Backupfolder 2 before processing:' + @BackupFolder1
   Select 'RecoveryModel'			+ @RecoveryModel
   Select 'InstanceID '				+ Cast (@InstanceID as varchar(10))
   Select 'Databases Name '			+ @Dbname
   Select 'Server Name '			+ @Server
   Select 'Number of files: '		+ Cast (@NumOfFiles as varchar(10))
  End

	-- Make sure the backup folder ends in a '\'

	if (Substring(@BackUpFolder1, LEN(Rtrim(@BackUpFolder1)),1) <> '\')
		Set @BackUpFolder1 = @BackUpFolder1 + '\'	   
		
		
	Set @BackUpFolder2 = @BackUpFolder2 + @Backupfolder1 + @Server+ '\' + @Dbname + '\'

	Set @BackUpFolder2 = Replace (@BackUpFolder2, ':', '$')


If @Debug = 1
  Begin
   Select 'Backupfolder 1 after processing:'		+ @BackupFolder1
   Select 'Backupfolder 2 after processing:'		+ @BackupFolder2
  End

		  create table #BackupFiles  
		  (  
		  Ident  int identity (1,1) not null,  
		  Col1	 varchar(1000) null,  
		  ) 
		  -- The folder needs to come from DBmaint table for the database in question
		  --Set @DBName = 'Test'
		  --Set @BackUpFolder ='C:\DBBTIS800LBS1\Test\' 

		  Set @BackUpFileFolder = 'dir /B ' + @BackupFolder2 + '*.Bak'
		  insert into #BackupFiles  
		  Exec master..xp_cmdshell @BackUpFileFolder  

If @Debug = 1
  Begin		  
	Select '# Backup files as on disk:'	
	Select Count(*) from #BackupFiles 
	Select * from #BackupFiles
  End
	  

	  If (select 1 from #BackupFiles 
	      where Col1 Like '%The system%'  or 
		        Col1 Like '%The network%' or
				Col1 Like '%File not%') > 0
	   Begin
	    INSERT #Results SELECT  '.Bak path is invalid cannot proceed with restore'
		Return;
	   End
	    
	  /*************************************************  
	  Parse date and time out of filenames and place into another temp table that holds both  
	  the filename, and the date, ordered by datetime.  this puts the files in order from earliest  
	  to latest to make the cursor easier for the restore.  
	  **************************************************/  
		    
		  select Col1 as FName,   
		  Convert(DateTime,  
		  substring(right(col1, 14), 1, 2) + '/' + --Month  
		  substring(right(col1, 12), 1, 2) + '/' + --Day  
		  substring(right(col1, 18), 1, 4) + ' ' + --Year  
		  substring(right(col1, 10), 1, 2) + ':' + --Hrs  
		  substring(right(col1, 8), 1, 2)  + ':' + --Mins  
		  substring(right(col1, 6), 1, 2)          --Secs  
		  ) AS DateAndTime   
		  into #BackupRestoreProcess from #backupfiles   
		  where Col1 is NOT NULL  
		  Order by Fname, DateAndTime Desc  
	  


		Delete #BackupRestoreProcess where DateAndTime < (Select Max(DateAndTime) from #BackupRestoreProcess)

If @Debug = 1
  Begin
    Select 'Backup files after deleting "non-current" files'			  
	Select * from #BackupRestoreProcess 
  End	   

   -- If the number of files don't match quit the SP as we have missing backup files

-- This is for testing
	-- Setup the initial recovery srting
	--Set @DBRestoreString = ''



/*****************************************************************************************************/
/* 2. Generate a backup restore statement with or without recovery based on the DB recovery model    */
/*****************************************************************************************************/

	--Set @DBRestoreString = 'Restore database [' + @DBName + '] From ';
	  INSERT #Results SELECT  'Restore database [' + @DBName + '] From ';

	 If @NumOfFiles > 1
	   BEGIN
   
		If @debug = 1 
		 Select 'in .bak restore cursor block'

		 If (Select Count(*) from #BackupRestoreProcess) < @NumOfFiles  
			 BEGIN
					INSERT #Results SELECT  ('Missing Backup files. Cannot proceed with database recovery')
					Return
			 END
		
			Set @Cntr = @NumOfFiles

			DECLARE RestoreDBs CURSOR  
			READ_ONLY FOR  
			SELECT FName from #BackupRestoreProcess


			-- Add the backup file locations to the recovery string 

			OPEN RestoreDBs  
  
			FETCH NEXT FROM RestoreDBs INTO @CurrBackupFileName  
			WHILE (@@fetch_status <> -1)  
			BEGIN

			--Set @DBRestoreString = @DBRestoreString + 'Disk = ' + Char(39) + @BackUpFolder2 + @CurrBackupFileName +  Char(39) + ', ' 
				If @Cntr > 1
				  INSERT #Results SELECT  'Disk = ' + Char(39) + @BackUpFolder2 + @CurrBackupFileName +  Char(39) + ','
				Else
				  INSERT #Results SELECT  'Disk = ' + Char(39) + @BackUpFolder2 + @CurrBackupFileName +  Char(39)
				Set @Cntr = @Cntr - 1

				FETCH NEXT FROM RestoreDBs INTO @CurrBackupFileName   
			End

			--Delete the last ',' from the string

			--Set @DBRestoreString = Substring (@DBRestoreString, 1, Len(Rtrim(@DBRestoreString)) - 1) 
			CLOSE RestoreDBs  
			DEALLOCATE RestoreDBs 
			If @debug = 1
				Select 'End of DB Restore Cursor'
		END
	Else   
	   BEGIN
	     Select @CurrBackupFileName = [FName]
		 From #BackupRestoreProcess
		 --Set @DBRestoreString = @DBRestoreString + 'Disk = ' + Char(39) + @BackUpFolder2 + @CurrBackupFileName +  Char(39) 
		 INSERT #Results SELECT  'Disk = ' + Char(39) + @BackUpFolder2 + @CurrBackupFileName +  Char(39)
	   END

	
	--INSERT #Results SELECT  @DBRestoreString + @NewLine
	INSERT #Results SELECT  'With '


/************************************************************************************
-- get the logical and physical file names from the .bak file.
************************************************************************************/
	Create table #BakFileDetails (
	LogicalName				NVarchar(128),
	PhysicalName			NVarchar(260),
	[Type]					Char(1),
	FileGroupName			NVarchar(128),
	Size					Numeric(20,0),
	MaxSize					Numeric(20,0),
	Fileid					BigInt,
	CreateLsn				Numeric(25,0),
	DropLSN					Numeric(25,0),
	UniqueID				UniqueIdentifier,
	ReadonlyLSN				Numeric(25,0),
	ReadWriteLSN			Numeric(25,0),
	BackupSizeInBytes		BigInt,
	SourceBlockSize			Int,
	Filegroupid				Int,
	LogGroupGUID			UniqueIdentifier,
	DifferentialBaseLSN		Numeric(25,0),
	DifferentialBaseGUID	UniqueIdentifier,
	IsReadOnly				Bit,
	IsPresent				Bit,
	TDEThumbPRINT			VarBinary(32))


	--	Initialize File variables
	Set @CurrLogicalName = ''
	Set @CurrPhysicalName  = ''

	Set @SqlCmd = 'Restore filelistonly from disk = ' + Char(39) +  @BackUpFolder2 + @CurrBackupFileName + Char(39)
    
	If @debug = 1
	  Select 'restore filelistonly command : ' + @sqlcmd

	Insert into #BakFileDetails  
	Exec (@sqlcmd)

	DECLARE WithMoveDBFiles CURSOR  
	READ_ONLY FOR  
	SELECT Logicalname, Physicalname from #BakFileDetails 

	OPEN  WithMoveDBFiles
  
	FETCH NEXT FROM WithMoveDBFiles INTO @CurrLogicalName, @CurrPhysicalName  
	WHILE (@@fetch_status <> -1)  
	BEGIN
		INSERT #Results SELECT  'Move ' + Char(39) + @CurrLogicalName +  Char(39) + ' to ' + 
						Char(39) + @CurrPhysicalName + Char(39) + ',' + @Newline
		FETCH NEXT FROM WithMoveDBFiles INTO @CurrLogicalName, @CurrPhysicalName
	End

	--If @debug = 1
	--  Select 'Past with move recovery cursor. Restore with move string: ' + @DBRestoreString

-- Put database in Standby mode (for logshipping)
-- Note 
	If @PutinStandby = 1
	  Begin
		INSERT #Results SELECT  ''
		INSERT #Results SELECT  '--If the database is replacing an existing database please uncomment the line below'
		INSERT #Results SELECT  'Replace,'
		INSERT #Results SELECT  '-- Note that D: is being used a file standard if D: does not exist on the current system'
		INSERT #Results SELECT  '-- please use C: or any other directory that is feasable'
		INSERT #Results SELECT  'Standby = D:\Rollback_Undo_' + @DBname + '.Bak'
		Return ;
	  End


-- Note: 
-- Forcing a full recovery database to restore as in a simple recovery model

	If @ForceSimpleRestore  = 1 
	  Set @RecoveryModel = 'Simple'


-- If recovery model is Simple set the restore string to recovery and exit the sp. Log restore process is not needed.

	If @RecoveryModel = 'Simple'
	  Begin 
	    If @debug = 1
	      Select 'In recovery model Simple'
		INSERT #Results SELECT  '--If the database is replacing an existing database please uncomment the line below'
		INSERT #Results SELECT  'Replace,'
		INSERT #Results SELECT  'Recovery,' 
		INSERT #Results SELECT  'Stats=10'
		INSERT #Results SELECT  'Go'
		Return;
	  End
	Else
	  Begin 
	    If @debug = 1
	      Select 'In recovery model Full'
		INSERT #Results SELECT  '--If the database is replacing an existing database please uncomment the line below'
		INSERT #Results SELECT  'Replace,'
		INSERT #Results SELECT  'NoRecovery,'
		INSERT #Results SELECT  'Stats=10'
		INSERT #Results SELECT  'Go' 
		INSERT #Results SELECT  ''
	  End

		  
/****************************************************************************************************************/
/* Log restore process starts from here																			*/
/* 3. If Full recovery collect .Log backup files using a UNC path convention from the network location from the */ 
/*	  SQLAdmin server																		                    */
/****************************************************************************************************************/


  	create table #LogBackupFiles  
	(  
	Ident int identity (1,1) not null,  
	col1 varchar(1000) null,  
	) 

	  --Set @LogBackupFolder = 'C:\DBBTIS800LBS1\Test\'
		  


   If @LogLocType = 'Local'
	  Set @logBackupFolder2 = '\\' + @Server + '\'
  

	If @Debug = 1
	Begin
		Select 'Log backup folder 1 pre processing:' + @Logbackupfolder1
		Select 'Log backup folder 2 pre processing:' + @Logbackupfolder2
	End

	-- Make sure the backup folder ends in a '\'
	if (Substring(@LogBackupFolder1, LEN(Rtrim(@LogBackupFolder1)),1) <> '\')
		Set @LogBackupFolder1 = @LogBackupFolder1 + '\'	   
		
		
	Set @logBackupFolder2 = @logBackupFolder2 + @LogBackupFolder1 + @Server+ '\' + @Dbname + '\'

	Set @logBackupFolder2 = Replace (@logBackupFolder2, ':', '$')

	If @Debug = 1
	Begin
		Select 'Log backup folder 1 post processing:' + @Logbackupfolder1
		Select 'Log backup folder 2 post processing:' + @Logbackupfolder2
	End

	Set @LogRestoreString = ''

	Set @LogBackupFileFolder = 'dir /B ' + @logBackupFolder2 + '*.Trn'

	insert into #LogBackupFiles  
	Exec master..xp_cmdshell @LogBackUpFileFolder  

	If @Debug = 1
	 Begin
	   Select 'Log backup files pre processing:'
	   Select * from #LogBackupFiles
	 End


	  If (select 1 from #LogBackupFiles 
	      where col1 like '%The system%' or 
		        col1 like '%The network%') > 0
	   Begin
	    INSERT #Results SELECT  '.Trn path is invalid cannot proceed with restore'
		Return;
	   End


	select col1 AS FName,   
	Convert(DateTime,  
	substring(right(col1, 14), 1, 2) + '/' + --Month  
	substring(right(col1, 12), 1, 2) + '/' + --Day  
	substring(right(col1, 18), 1, 4) + ' ' + --Year  
	substring(right(col1, 10), 1, 2) + ':' + --Hrs  
	substring(right(col1, 8), 1, 2)  + ':' + --Mins  
	substring(right(col1, 6), 1, 2)          --Secs  
	) AS DateAndTime   
	into #LogBackupRestoreProcess from #LogBackupFiles   
	where col1 is NOT NULL  
	Order by DateAndTime asc  
  
  -- See if there are any log backups after the last full backup
  	If @Debug = 1
	 Begin
	   Select '.Trn files that have dates after the most current .bak'
	   Select * from #LogBackupRestoreProcess
	   where  DateAndTime > (Select top 1 DateAndTime from #BackupRestoreProcess) 
     End
  --delete all log backup files which are earlier than the last full backup
   
   Delete from #LogBackupRestoreProcess where  DateAndTime < (Select top 1 DateAndTime from #BackupRestoreProcess) 
   If @Debug = 1
	 Begin  
	    Select '.Trn files after the delete operation and files should have dates > most current .bak'
		Select * from #LogBackupRestoreProcess
	 End
  
/**************************************************************************************************/
/* 4. Generate log restore with no recovery statement(s) for each .Trn file based on the number   */
/*    of .Trn backups post the full backup                                                        */
/**************************************************************************************************/

   
   If (Select count(*) from #LogBackupRestoreProcess) >= 1  
     Begin 
		DECLARE RestoreLogs CURSOR  
		READ_ONLY FOR  
		SELECT FName from #LogBackupRestoreProcess

		-- Add the backup file locations to the recovery string 

		OPEN RestoreLogs  
  
		FETCH NEXT FROM RestoreLogs INTO @CurrLogBackupFileName  
		WHILE (@@fetch_status <> -1)  
		BEGIN
			If @debug = 1
			  Begin
				Select 'in .Trn restore cursor block'
				Select @CurrLogBackupFileName
			  End
			--Set @LogRestoreString = 'Restore Log ' + @DBName + 'From '
			--Set @LogRestoreString = @LogRestoreString + 'Disk = ' + Char(39) + @logBackupFolder2 + @CurrLogBackupFileName +  Char(39) + @Newline + 
			INSERT #Results SELECT  'Restore Log ' + @DBName + ' From ' + 'Disk = ' + Char(39) + @logBackupFolder2 + @CurrLogBackupFileName +  Char(39) + @Newline
			INSERT #Results SELECT  'With Norecovery,'
			INSERT #Results SELECT  'Stats=10' 
			INSERT #Results SELECT  'Go'
			INSERT #Results SELECT  '' 
			--Select @LogRestoreString
			FETCH NEXT FROM RestoreLogs INTO @CurrLogBackupFileName   
		End

	End
	CLOSE RestoreLogs  
	DEALLOCATE RestoreLogs 
	If @Debug = 1
	  INSERT #Results SELECT ('End of Log restore Cursor')

/*******************************************************************************************/
/* 5. Generate a DB recovery statement                                                      */
/*******************************************************************************************/

	--Set @DBRestoreString = 'Restore database [' + @DBName + '] with Recovery'
	--Select @DBRestoreString
	INSERT #Results SELECT  'Restore database [' + @DBName + '] with Recovery'
	Set NoCount Off

SELECT * FROM #Results








;
GO
/****** Object:  StoredProcedure [dbo].[ReportTest]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[ReportTest]
(
@ID int
)

  
as


select TableName, DataSpaceUsed
from collector.tablesize
where InstanceID = @ID
and ExecutionDateTime in (select max(executiondatetime) 
							from collector.tablesize
							where InstanceID = @ID)




;
GO
/****** Object:  StoredProcedure [Collector].[ReplLatencyUpdate]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[Collector].[ReplLatencyUpdate]
--'2014-11-24 18:10:00',
--'dfw-sql-util',
--'Davinci',
--'DaVinci_Transactional',
--'DFW-012-DB01\ERS',
--'Davinci_repl',
---2147228689,
--NULL,
--NULL,
--NULL,
--NULL,
--NULL,
--NULL

CREATE procedure [Collector].[ReplLatencyUpdate]
(
@ExecutionDateTime smalldatetime,
@PublServer sysname,
@PublDB sysname,
@PublName sysname,
@SubrServer sysname,
@SubrDB sysname,
@TracerID int,
@DistLatency int,
@SubrLatency int,
@TotalLatency int,
@CustomQueryResultPUBL nvarchar(100) = NULL,
@CustomQueryResultSUBR nvarchar(100) = NULL,
@CustomQuery nvarchar(max) = NULL
)

   
AS

/*
Updates the ReplLatency table.
It gets called from ReplTracerTokenHistory.ps1 script.

Since there can be a number of subrs for each publ this needs to have some special handling.
The issue is that when you post the token initially, you post it for the entire publ, and you can't specify a subr.
So it just gives you a single token for the entire publ.
But when you query the history it gives you the history for each subr.  
So there'll be a single row in the table already, but there won't be one for all the subrs.
Therefore, you can update the 1st row that comes in, but for the rest of the subrs you'll need to insert instead.
*/

    DECLARE @PublServerID INT,
			@SubrServerID int,
			@CT int,
			@Updated bit = 0,
			@CurrentSubrServerID int,
			@CurrentSubrDB sysname,
			@LastDistLatencyDateTime datetime,
			@LastSubrLatencyDateTime datetime,
			@CurrentDistLatency int,
			@CurrentSubrLatency int,
			@Complete bit;

    SET @PublServerID = ( SELECT  InstanceID
                        FROM    dbo.Servers
                        WHERE   ServerName = @PublServer
                        )
    SET @SubrServerID = ( SELECT  InstanceID
                        FROM    dbo.Servers
                        WHERE   ServerName = @SubrServer
                      )


--SET @CurrentSubrServerID = (SELECT SubrServerID
--	FROM Collector.ReplLatency
--	WHERE
--	ExecutionDateTime = @ExecutionDateTime
--	AND PublServerID = @PublServerID
--	AND PublName = @PublName
--	AND PublDB =  @PublDB
--	AND TracerID = @TracerID
--	AND SubrServerID IS NOT NULL)
--select @CurrentSubrServerID as CurrentSubrServerID

--SET @CurrentSubrDB = (SELECT SubrDB
--	FROM Collector.ReplLatency
--	WHERE
--	ExecutionDateTime = @ExecutionDateTime
--	AND PublServerID = @PublServerID
--	AND PublName = @PublName
--	AND PublDB =  @PublDB
--	AND TracerID = @TracerID
--	AND SubrServerID IS NOT NULL);
--select @CurrentSubrDB as CurrentSubrDB

--If the token hasn't even made it to the dist yet then there's no point in updating the row.
----If @DistLatency IS NULL
----RETURN

--Token has made it to the dist but not the subr...


If @DistLatency IS NOT NULL AND @SubrLatency IS NOT NULL

	BEGIN
--Both of these values being NOT NULL means the token made it through and we can close the record by setting this flag.
--If this block were moved lower @DistLatency and @SubrLatency would be populated by one of the conditions and a record
--would always be marked complete whether it is or not.  So if you make any changes keep this at the top.

SET @Complete = 1;

	END


If @DistLatency IS NULL -- OR @SubrLatency IS NULL

	BEGIN

		SET @LastDistLatencyDateTime =
			 (SELECT MAX(ExecutionDateTime) FROM Collector.ReplLatency 
				WHERE PublServerID = @PublServerID
				AND PublDB = @PublDB
				AND PublName = @PublName
				--AND TracerID = @TracerID
				AND SubrServerID = @SubrServerID
				AND SubrDB = @SubrDB
				AND DistLatency IS NOT NULL
				AND Complete = 1) --This is your anchor.  If you always compare the current NULL value with the last one marked complete then the time should climb like it's supposed to.

SET @DistLatency = DATEDIFF(ss, @LastDistLatencyDateTime, GETDATE());
SET @SubrLatency = DATEDIFF(ss, @LastDistLatencyDateTime, GETDATE());
SET @TotalLatency = @DistLatency + @SubrLatency;
SET @Complete = 0;

	END

If @DistLatency IS NOT NULL AND @SubrLatency IS NULL -- OR @SubrLatency IS NULL

	BEGIN

		SET @LastDistLatencyDateTime =
	 (SELECT MAX(ExecutionDateTime) FROM Collector.ReplLatency 
				WHERE PublServerID = @PublServerID
				AND PublDB = @PublDB
				AND PublName = @PublName
				--AND TracerID = @TracerID
				AND SubrServerID = @SubrServerID
				AND SubrDB = @SubrDB
				AND DistLatency IS NOT NULL
				AND Complete = 1) --This is your anchor.  If you always compare the current NULL value with the last one marked complete then the time should climb like it's supposed to.

SET @SubrLatency = DATEDIFF(ss, @LastDistLatencyDateTime, GETDATE())
SET @TotalLatency = @DistLatency + @SubrLatency
SET @Complete = 0;
	END

BEGIN

	UPDATE Collector.ReplLatency
	SET

	--SubrServerID = @SubrServerID,
	--SubrDB = @SubrDB,
	DistLatency = @DistLatency,
	SubrLatency = @SubrLatency,
	TotalLatency = @TotalLatency,
	Complete = @Complete
	--CustomQueryResultPUBL = @CustomQueryResultPUBL,
	--CustomQueryResultSUBR = @CustomQueryResultSUBR,
	--CustomQuery = @CustomQuery
	WHERE
	--ExecutionDateTime = @ExecutionDateTime AND 
	PublServerID = @PublServerID
	AND PublDB = @PublDB
	AND PublName = @PublName
	AND TracerID = @TracerID
	AND SubrServerID = @SubrServerID
	AND SubrDB = @SubrDB;	


	PRINT 'UPDATE Collector.ReplLatency
	SET
	DistLatency = ' + CAST(@DistLatency as varchar(25)) + ',
	SubrLatency = ' + CAST(@SubrLatency as varchar(25)) + ',
	TotalLatency = ' + CAST(@TotalLatency as varchar(25)) + ',
	Complete = ' + CAST(@Complete as varchar(25)) + '
	WHERE
	PublServerID = ' + CAST(@PublServerID as varchar(25)) + '
	AND PublDB = ' + CAST(@PublDB as varchar(25)) + '
	AND PublName = ' + CAST(@PublName as varchar(25)) + '
	AND TracerID = ' + CAST(@TracerID as varchar(25)) + '
	AND SubrServerID = ' + CAST(@SubrServerID as varchar(25)) + '
	AND SubrDB = ' + CAST(@SubrDB as varchar(25))

END



----Insert a new row for another subr if one already exists in the table and there's another one to log.
----We're getting a count of the rows that already exist for the current token.
----If the PublServerID is there, and the SubrServerID isn't, then a row will be inserted.


----BEGIN --@Updated
----SET @CT = (
----	SELECT count(*)
----	FROM Collector.ReplLatency
----	WHERE
----	ExecutionDateTime = @ExecutionDateTime
----	AND PublServerID = @PublServerID
----	AND TracerID = @TracerID
----	AND SubrServerID IS NOT NULL
----	--AND SubrDB <> @SubrDB	
----)

----If @CT > 0
----BEGIN


------!-- Here's your problem; you can't = or <> a NULL value. @CurrentSubServerID and @CurrentSubrDB are NULL because that row doesn't exist yet.
------!--		If @CurrentSubrServerID <> @SubrServerID OR @CurrentSubrDB <> @SubrDB

----------!-- Solution:
--------If ISNULL(@CurrentSubrServerID,-9999) <> @SubrServerID OR ISNULL(@CurrentSubrDB, '') <> @SubrDB 
--------BEGIN -- Insert
----------Insert new row.
--------INSERT Collector.ReplLatency (ExecutionDateTime, PublServerID, PublDB, PublName, SubrServerID, SubrDB, DistLatency, SubrLatency, TotalLatency, TracerID, PublisherCommit, CustomQueryResultPUBL, CustomQueryResultSUBR, CustomQuery)
--------SELECT
--------@ExecutionDateTime,
--------@PublServerID,
--------@PublDB,
--------@PublName,
--------@SubrServerID,
--------@SubrDB,
--------@DistLatency,
--------@SubrLatency,
--------@TotalLatency,
--------@TracerID,
--------@ExecutionDateTime,
--------@CustomQueryResultPUBL,
--------@CustomQueryResultSUBR,
--------@CustomQuery

--------END -- Insert
----END
----END --@Updated




--Token has made it through to the subr...
----If @DistLatency IS NOT NULL and @SubrLatency IS NOT NULL
----	BEGIN

----	If @Updated < 1
----	BEGIN

----	--If @CurrentSubrServerID = @SubrServerID AND @CurrentSubrDB = @SubrDB
----	--Begin -- Update
----		UPDATE Collector.ReplLatency
----		SET

----		SubrServerID = @SubrServerID,
----		SubrDB = @SubrDB,
----		DistLatency = @DistLatency,
----		SubrLatency = @SubrLatency,
----		TotalLatency = @TotalLatency,
----		CustomQueryResultPUBL = @CustomQueryResultPUBL,
----		CustomQueryResultSUBR = @CustomQueryResultSUBR,
----		CustomQuery = @CustomQuery
----		WHERE
----		(ExecutionDateTime = @ExecutionDateTime
----		AND PublServerID = @PublServerID
----		AND TracerID = @TracerID
----		AND PublName = @PublName
----		AND SubrLatency IS NULL)
----	--End --Update
----END
------select 2
----SET @Updated = 1
----	END




;
GO
/****** Object:  StoredProcedure [Archive].[ServersInsert]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Archive].[ServersInsert]

   
AS

DECLARE @ExecutionDateTime datetime

SET @ExecutionDateTime = GETDATE()

INSERT Archive.Servers (InstanceID, ExecutionDateTime, LocID, ServerName, DNS, IP, Port, Descr, Role, ServiceLevel, IsSQL, SQLVersion, SQLEdition, SQLServicePack, SQLBuild, IsCluster, IsNew, BackupManaged, BackupProduct, BackupDefaultLoc, DiskManaged, IsServiceManaged, SPConfigManaged, IsActive, IsActiveDate, InstanceMemInMB, OSVersion, OSServicePack, OSBuild, OSArchitecture, CPUSockets, CPUCores, CPULogicalTotal, ServerMemInMB, Manufacturer, ServerModel)
SELECT                 InstanceID, @ExecutionDateTime, LocID, ServerName, DNS, IP, Port, Descr, Role, ServiceLevel, IsSQL, SQLVersion, SQLEdition, SQLServicePack, SQLBuild, IsCluster, IsNew, BackupManaged, BackupProduct, BackupDefaultLoc, DiskManaged, IsServiceManaged, SPConfigManaged, IsActive, IsActiveDate, InstanceMemInMB, OSVersion, OSServicePack, OSBuild, OSArchitecture, CPUSockets, CPUCores, CPULogicalTotal, ServerMemInMB, Manufacturer, ServerModel
FROM dbo.Servers




;
GO
/****** Object:  StoredProcedure [Collector].[ServerMgmtDBGet]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collector].[ServerMgmtDBGet]
(
@ServerName sysname
)

   
AS

    DECLARE @InstanceID INT  
    
    SET @InstanceID = ( SELECT  InstanceID  
                        FROM    dbo.Servers  with(nolock)
                        WHERE   ServerName = @ServerName  
                      )  

DECLARE @CT int;

SET @CT = (SELECT COUNT(*)
FROM dbo.ServerMgmtDB
WHERE InstanceID = @InstanceID)

If @CT = 0
BEGIN
	SELECT 'master' as MgmtDB
END

If @CT > 0
BEGIN
	SELECT ISNULL(MgmtDB, 'master') AS MgmtDB
	FROM dbo.ServerMgmtDB
	WHERE InstanceID = @InstanceID
END

;
GO
/****** Object:  StoredProcedure [Collector].[ReplPublisherInsert]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[ReplPublisherInsert]
(
@ServerName varchar(100),
@DBName varchar(100),
@PublName varchar(100),
@Desc varchar(1000),
@SyncMethod tinyint
)

   
AS

DECLARE @SendAlert bit = 1,
		@AlertMethod varchar(25) = 'Secs',
		@AlertValue int = 30


    DECLARE @InstanceID INT
    SET @instanceID = ( SELECT  InstanceID
                        FROM    dbo.Servers
                        WHERE   ServerName = @ServerName
                      )
INSERT dbo.ReplPublisher (InstanceID, DBName, PublName, Descr, SyncMethod, SendAlert, AlertMethod, AlertValue)
SELECT @InstanceID, @DBName, @PublName, @Desc, @SyncMethod, @SendAlert, @AlertMethod, @AlertValue


;
GO
/****** Object:  StoredProcedure [Collector].[ReplLatencyInsert]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[ReplLatencyInsert]
(
@ExecutionDateTime smalldatetime,
@PublServer sysname,
@PublDB sysname,
@PublName sysname,
@TracerID int,
@PublCommit smalldatetime
)

   
AS

/*

The Complete col is used as a control so we can tell where the last good row is.
This way if you have a latency that's getting higher and higher it has an anchor to be compared to
so the latency will climb properly.  Without this anchor it's difficult to tell where the issue began since there could be
dozens of collections stacked up in the queue.

The Complete col gets set to 1 in the ReplLatencyUpdate sp when the DistLatency and SubrLatency being passed in are both populated.
This means that the token has made it all the way through.  That is a complete token push.

*/


--A TracerID of 0 means there are no subrs so there's no need to insert the row.
If @TracerID = 0
Begin
	RETURN
END

    DECLARE @PublServerID INT,
			@SubrServerID int	

    SET @PublServerID = ( SELECT  InstanceID
                        FROM    dbo.Servers
                        WHERE   ServerName = @PublServer
                        )
    --SET @SubrServerID = ( SELECT  InstanceID
    --                    FROM    dbo.Servers
    --                    WHERE   ServerName = @ServerName
    --                  )

INSERT Collector.ReplLatency (ExecutionDateTime, PublServerID, PublDB, PublName, SubrServerID, SubrDB, TracerID, PublisherCommit, Complete)
SELECT
@ExecutionDateTime,
PublServerID, PublDB, PublName, SubrServerID, SubrDB,
@TracerID,
@PublCommit,
0 --Set Complete to 0 initially since nothing has been updated yet.
FROM dbo.ReplSubscriber
WHERE PublServerID = @PublServerID
AND	  PublDB = @PublDB
AND	  PublName = @PublName


;
GO
/****** Object:  StoredProcedure [DBFile].[PropertyChange]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [DBFile].[PropertyChange]
(
@InstanceID int = NULL,
@ServerName varchar(100) = NULL,
@DBName varchar(100),
@DBFileID int = NULL,
@DBFileName varchar(100) = NULL,
@IsAutoGrow bit = NULL,
@AutoGrowType varchar(10) = NULL,
@AutoGrowValue bigint = NULL,
@HasMaxSize bit = NULL,
@MaxSizeType varchar(10) = NULL,
@MaxSizeValue bigint = NULL
)

  
AS


Declare @ID int;

---Get the ServerName if it wasn't passed in.
If @ServerName IS NULL
	BEGIN
	SET @ServerName = (SELECT ServerName from dbo.Servers
					WHERE InstanceID = @InstanceID );
	END	
	
---Get the InstanceID if it wasn't passed in.
If @InstanceID IS NULL
	BEGIN
	SET @InstanceID = (SELECT InstanceID from dbo.Servers
					WHERE ServerName = @ServerName );
	END	

---Get the FileID if it wasn't passed in.
If @DBFileID IS NULL
	BEGIN
	SET @DBFileID = (SELECT DBFileID from dbo.DBFilePropertiesConfig
					WHERE InstanceID = @InstanceID and DBName = @DBName and DBFileName = @DBFileName);
	END					

---Get the FileName if it wasn't passed in.
If @DBFileName IS NULL
	BEGIN
	SET @DBFileName = (SELECT DBFileName from dbo.DBFilePropertiesConfig
					WHERE InstanceID = @InstanceID and DBName = @DBName and DBFileID = @DBFileID);
	END	

---Get the ID of the File being changed.

	SET @ID = (SELECT ID from dbo.DBFilePropertiesConfig
					WHERE InstanceID = @InstanceID and DBName = @DBName and DBFileID = @DBFileID  and DBFileName = @DBFileName);


-------Get values of NULL params.  This is to keep from having to write dynamic sql.  This way if you don't pass in
-------some values, there's still only 1 update to run cause I just set the parmas to the current values.

If @IsAutoGrow IS NULL
	SET @IsAutoGrow = (SELECT IsAutoGrow from dbo.DBFilePropertiesConfig where ID = @ID)

If @AutoGrowType IS NULL
	SET @AutoGrowType = (SELECT AutoGrowType from dbo.DBFilePropertiesConfig where ID = @ID)

If @AutoGrowValue IS NULL
	SET @AutoGrowValue = (SELECT AutoGrowValue from dbo.DBFilePropertiesConfig where ID = @ID)

If @HasMaxSize IS NULL
	SET @HasMaxSize = (SELECT HasMaxSize from dbo.DBFilePropertiesConfig where ID = @ID)

If @MaxSizeType IS NULL
	SET @MaxSizeType = (SELECT MaxSizeType from dbo.DBFilePropertiesConfig where ID = @ID)

If @MaxSizeValue IS NULL
	SET @MaxSizeValue = (SELECT MaxSizeValue from dbo.DBFilePropertiesConfig where ID = @ID)


---Turn AutoGrow off properly.
If @IsAutoGrow = 0
BEGIN
	SET @AutoGrowType = 'NONE';
	SET @AutoGrowValue = 0;
END

If @IsAutoGrow = 1
BEGIN
	If @AutoGrowType = 'NONE'
		Begin
		PRINT 'If @AutoGrow = 1, then @AutoGrowType cannot be ''NONE'' and @AutoGrowValue must be non-zero.'
		return
		End
	If (@AutoGrowValue = 0 OR @AutoGrowValue IS NULL)
		Begin
		PRINT 'If @AutoGrow = 1, then @AutoGrowType cannot be ''NONE'' and @AutoGrowValue must be non-zero.'
		return
		End		

END


---Turn MaxSize off properly.
If @HasMaxSize = 0
BEGIN
	SET @MaxSizeValue = 2147483648;
	SET @MaxSizeType = 'KB';
END
	
--END


--------------------------------BEGIN Single DB Update--------------------------------
IF @DBName IS NOT NULL

Begin
Begin Tran
UPDATE dbo.DBFilePropertiesConfig
SET IsAutoGrow = @IsAutoGrow,
	AutoGrowType = @AutoGrowType,
	AutoGrowValue = @AutoGrowValue,
	HasMaxSize = @HasMaxSize,
	MaxSizeType = @MaxSizeType,
	MaxSizeValue = @MaxSizeValue,
	Push = 1
WHERE ID = @ID
commit Tran

SELECT S.ServerName, DC.* 
from dbo.DBFilePropertiesConfig DC
Inner Join dbo.Servers S
ON DC.InstanceID = S.InstanceID
WHERE DC.ID = @ID
End
--------------------------------END Single DB Update--------------------------------


--------------------------------BEGIN All DBs Update--------------------------------
IF @DBName IS NULL

Begin
Begin Tran
UPDATE dbo.DBFilePropertiesConfig
SET IsAutoGrow = @IsAutoGrow,
	AutoGrowType = @AutoGrowType,
	AutoGrowValue = @AutoGrowValue,
	HasMaxSize = @HasMaxSize,
	MaxSizeType = @MaxSizeType,
	MaxSizeValue = @MaxSizeValue,
	Push = 1
WHERE InstanceID = @InstanceID
commit Tran

SELECT S.ServerName, DC.* 
from dbo.DBFilePropertiesConfig DC
Inner Join dbo.Servers S
ON DC.InstanceID = S.InstanceID
WHERE DC.ID = @ID
End
--------------------------------END All DBs Update--------------------------------



;
GO
/****** Object:  View [Collector].[ServiceAcctCurrent]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[ServiceAcctCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion as Version,
			S.SQLEdition as Edition,
			S.Descr,
			ServiceName, 
			StartName,
			'This view shows the latest service start-up accts. This is an excellent way to see the impact you''re going to incur if you change a password.' AS ViewDesc
    FROM    Collector.ServiceAcct D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.ServiceAcct D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL


;
GO
/****** Object:  StoredProcedure [Collector].[ServersOSDetailInsert]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[ServersOSDetailInsert]

(
@ExecutionDateTime datetime,
@InstanceID int,
@FreePhysicalMemory bigint,
@FreeSpaceInPagingFiles bigint,
@FreeVirtualMemory bigint,
@InstallDate varchar(50),
@LastBootUpTime varchar(50),
@MaxNumberOfProcesses bigint,
@MaxProcessMemorySize bigint,
@Name varchar(500),
@NumberOfLicensedUsers bigint,
@NumberOfProcesses bigint,
@NumberOfUsers bigint,
@OSArchitecture varchar(50),
@OSLanguage int,
@PAEEnabled bit,
@SerialNumber varchar(100),
@ServicePackMajorVersion int,
@ServicePackMinorVersion int,
@SizeStoredInPagingFiles bigint,
@Status varchar(20),
@SystemDirectory varchar(100),
@SystemDrive varchar(5),
@TotalSwapSpaceSize bigint,
@TotalVirtualMemorySize bigint,
@TotalVisibleMemorySize bigint,
@Version varchar(20),
@WindowsDirectory varchar(50)
)

   
AS


/*

Gets called from OSDetailsGet.ps1

*/



INSERT Collector.ServersOSDetail
SELECT
@ExecutionDateTime,
@InstanceID,
@FreePhysicalMemory,
@FreeSpaceInPagingFiles,
@FreeVirtualMemory,
@InstallDate,
@LastBootUpTime,
@MaxNumberOfProcesses,
@MaxProcessMemorySize,
@Name,
@NumberOfLicensedUsers,
@NumberOfProcesses,
@NumberOfUsers,
@OSArchitecture,
@OSLanguage,
@PAEEnabled,
@SerialNumber,
@ServicePackMajorVersion,
@ServicePackMinorVersion,
@SizeStoredInPagingFiles,
@Status,
@SystemDirectory,
@SystemDrive,
@TotalSwapSpaceSize,
@TotalVirtualMemorySize,
@TotalVisibleMemorySize,
@Version,
@WindowsDirectory




;
GO
/****** Object:  View [Collector].[ServersOSDetailCurrent]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[ServersOSDetailCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion as Version,
			S.SQLEdition as Edition,
			S.Descr,
			D.FreePhysicalMemory,
			D.FreeSpaceInPagingFiles,
			D.FreeVirtualMemory,
			D.InstallDate,
			D.LastBootUpTime,
			D.MaxNumberOfProcesses,
			D.MaxProcessMemorySize,
			D.Name,
			D.NumberOfLicensedUsers,
			D.NumberOfProcesses,
			D.NumberOfUsers,
	
		D.OSArchitecture,
			D.OSLanguage,
			D.PAEEnabled,
			D.SerialNumber,
			D.ServicePackMajorVersion,
			D.ServicePackMinorVersion,
			D.SizeStoredInPagingFiles,
			D.Status,
			D.SystemDirectory,
			D.SystemDrive,
			D.TotalSwapSpaceSize,
			D.TotalVirtualMemorySize,
			D.TotalVisibleMemorySize,
			D.Version AS WindowsVersion,
			D.WindowsDirectory,
			'This view displays the latest OS level information for all the servers.' AS ViewDesc
    FROM    Collector.ServersOSDetail D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.ServersOSDetail D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL
;
GO
/****** Object:  StoredProcedure [dbo].[ServerInfo]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ServerInfo]
(
@ServerName VARCHAR(100)
)

  
AS


SELECT * FROM dbo.Servers
WHERE ServerName = @ServerName

DECLARE @IsClustered BIT,
		@InstanceID int

 SELECT @IsClustered = IsCluster ,
 @InstanceID = InstanceID
 FROM dbo.Servers
WHERE ServerName = @ServerName

IF @IsClustered = 1

BEGIN
	SELECT * FROM dbo.ClusterNode
	WHERE InstanceID = @InstanceID
	
	IF @@ROWCOUNT = 0
	SELECT 'No node info recorded.'
END




;
GO
/****** Object:  StoredProcedure [Alert].[SIDvariantGet2]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Alert].[SIDvariantGet2]

   
AS -- This is how you tell which [name]-[logintype] pair has more than one distinct SID in the table:
    SELECT  ROW_NUMBER() OVER ( PARTITION BY name, logintype ORDER BY Name, SID ) rownum ,
            name ,
            SID ,
            loginType ,
            InstanceID
    INTO    #tmp
    FROM    collector.logins;

    WITH    CTE2
              AS ( SELECT   name ,
                            logintype
                   FROM     #tmp
                   GROUP BY name ,
                            logintype
                   HAVING   MAX(rowNum) > 1
                 )
        SELECT  CTE2.NAME ,
                CTE2.logintype ,
                CTE.InstanceID
        FROM    CTE2
                JOIN #tmp CTE ON CTE.NAME = CTE2.NAME
        ORDER BY name;


-- dbo.sidserver - master table for logins, script checks against this table for the right SID


;
GO
/****** Object:  StoredProcedure [Alert].[SIDvariantGet]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Alert].[SIDvariantGet]

   
AS
-- This is how you tell which [name]-[logintype] pair has more than one distinct SID in the table:
WITH    CTE
          AS ( SELECT   ROW_NUMBER() OVER ( PARTITION BY name, logintype ORDER BY Name, SID ) rownum ,
                        name ,
                        SID ,
                        loginType
               FROM     collector.logins
             )
    SELECT  MAX(rownum) AS NumberOfDifferentSIDs ,
            name ,
            logintype
    FROM    CTE
    GROUP BY name ,
            logintype
    HAVING  MAX(rowNum) > 1
    ORDER BY name;


;
GO
/****** Object:  StoredProcedure [dbo].[SIDServerInsert]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SIDServerInsert]
(
@ServerName varchar(100),
@LoginName varchar(100),
@SID varchar(150)
)

  
AS

/*
This gets called from /ManualScripts/SIDServer/AddSQLLoginAndUserToDB.ps1.
You may also call it manually and there are scripts in the same folder to 
assist you with this.
*/



--Set the CreateCode.
DECLARE @CreateCode varchar(500),
		@Password varchar(100)

--We've made it easy to generate your own password.  If you have
--a password generator that you typically use it's easy enough to
--set this variable to the generated password.
SET @Password = '***PutYOUROWNStrongPwordHERE!!!'

--This is the default CREATE LOGIN script.
--There are many options missing because there's no way of
--knowing what you'll want.  Add your own options here to complete
--your security solution.
SET @CreateCode = 'CREATE LOGIN [' + @LoginName + ']' +
				' WITH PASSWORD = ''' + @Password + ''', ' +
				'SID = ' + @SID

    DECLARE @InstanceID INT
    SET @instanceID = ( SELECT  InstanceID
                        FROM    dbo.Servers
                        WHERE   ServerName = @ServerName
                      )

INSERT dbo.SIDServer(LoginName, SID, ConfigInstanceID, CreateCode)
SELECT @LoginName, @SID, @InstanceID, @CreateCode


;
GO
/****** Object:  StoredProcedure [Alert].[SIDorphanedUsers]    Script Date: 11/26/2015 18:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Alert].[SIDorphanedUsers]

   
AS 
    SELECT  u.username ,
            u.[login] ,
            u.logintype ,
            u.dbname ,
            u.InstanceID ,
            u.sid
    FROM    collector.dbusers u
            LEFT OUTER JOIN collector.logins l ON u.SID = l.sid
    WHERE   l.sid IS NULL
    ORDER BY username;



;
GO
/****** Object:  View [Collector].[ServiceStatusCurrent]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[ServiceStatusCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion as Version,
			S.SQLEdition as Edition,
			S.Descr,
			D.ServiceName, 
			D.Status, 
			D.StartMode,
			'This view shows the latest size of all the tables. To see the growth rate of all the tables just query the base table (Collector.TableSize) and graph it in Excel.' AS ViewDesc
    FROM    Collector.ServiceStatus D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.ServiceStatus D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL
;
GO
/****** Object:  StoredProcedure [Collector].[spDBFilePropertiesInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[spDBFilePropertiesInsert]
(
	@ExecutionDateTime datetime ,
	@InstanceID int ,
	@DBName varchar(100),
	@FileGroup varchar(100),
	@FileName varchar(100),
	@FullFileName varchar(1000),
	@FileType char(1),
	@AvailableSpace bigint,
	@BytesReadFromDisk bigint,
	@BytesWrittenToDisk bigint,
	@Growth bigint,
	@GrowthType varchar(10),
	@FileID smallint,
	@IsOffline bit,
	@IsPrimaryFile bit,
	@IsReadOnly bit,
	@IsReadOnlyMedia bit,
	@IsSparse bit,
	@MaxSize bigint,
	@NumberOfDiskReads bigint,
	@NumberOfDiskWrites bigint,
	@Size bigint,
	@State varchar(50),
	@SpaceUsed bigint,
	@VolumeFreeSpace bigint
)

   
AS


/*
This sp is called by the CollectorFileGrowthRateGET PS script.
*/

Insert Collector.DBFileProperties
Select
	@ExecutionDateTime,
	@InstanceID,
	@DBName,
	@FileGroup,
	@FileName,
	@FullFileName,
	@FileType,
	@AvailableSpace,
	@BytesReadFromDisk,
	@BytesWrittenToDisk,
	@Growth,
	@GrowthType,
	@FileID small,
	@IsOffline,
	@IsPrimaryFile,
	@IsReadOnly,
	@IsReadOnlyMedia,
	@IsSparse,
	@MaxSize,
	@NumberOfDiskReads,
	@NumberOfDiskWrites,
	@Size,
	@State,
	@SpaceUsed,
	@VolumeFreeSpace 




;
GO
/****** Object:  StoredProcedure [Collector].[spCPUInfoInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[spCPUInfoInsert]
(
@InstanceID INT,
@Sockets int,
@Cores int,
@LogicalCPUs int,
@TotalPhysicalMemory bigint,
@Caption varchar(100)
)
 

AS

/*
Gets called from CPUInfoGet.ps1 and fills in cpu info for the servers table.

*/

SET @Caption = REPLACE(@Caption, 'Microsoft Windows', '');
SET @Caption = REPLACE(@Caption, 'Microsoft(R) Windows(R)', '');
SET @Caption = REPLACE(@Caption, 'Server', '');
SET @Caption = REPLACE(@Caption, 'Microsoft? Windows ?', '');
SET @Caption = REPLACE(@Caption, 'Edition', '');

update dbo.Servers
set CPUSockets = @Sockets,
CPUCores = @Cores,
CPULogicalTotal = @LogicalCPUs,
ServerMemInMB = @TotalPhysicalMemory,
OSVersion = @Caption
where InstanceID = @InstanceID
;
GO
/****** Object:  StoredProcedure [dbo].[spBackupLastGet]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spBackupLastGet] 
(
@ServerName varchar(100)
)

  
AS

Declare @InstanceID int
Set @InstanceID = (Select InstanceID from dbo.Servers where ServerName = @ServerName)

select S.ServerName, s.ServiceLevel, DP.ExecutionDateTime, DP.DBName, CONVERT(VARCHAR(25), DP.LastBackup, 100) AS LastFullBackup,
        CONVERT(VARCHAR(25), DP.LastLogBackup, 100) AS LastLogBackup,
        CONVERT(VARCHAR(25), DP.LastDiffBackup, 100) AS LastDiffBackup 
        from collector.DBpropertiesGOLD DP
INNER JOIN dbo.Servers S
ON DP.InstanceID = s.InstanceID
WHERE ExecutionDateTime = (Select max(ExecutionDateTime) from collector.DBpropertiesGOLD Where InstanceID = @InstanceID)

;
GO
/****** Object:  StoredProcedure [dbo].[spDBStatusNotify]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDBStatusNotify]

  
AS

IF EXISTS(SELECT NAME FROM SYS.DATABASES 
		WHERE user_access = 0)

BEGIN

DECLARE @ProfileName NVARCHAR(100);
DECLARE @tableHTML  NVARCHAR(MAX) ;
DECLARE @SubjectLine NVARCHAR(100);
SET @SubjectLine = 'Databases are in restricted access mode in DW Server'
SET @tableHTML = --CAST((SELECT NAME FROM SYS.DATABASES WHERE user_access = 0) AS NVARCHAR(MAX))
    N'<table border="1">' +
    N'<tr><th>Server Name</th><th>DB Name</th>' +
    CAST ( ( SELECT td = @@SERVERNAME, '', td = NAME FROM master.sys.databases WHERE user_access = 0
			 FOR XML PATH('tr')
    ) AS NVARCHAR(MAX) ) +
    N'</table>' ;

--print @tableHTML;
set @ProfileName = (select top 1 name from msdb.dbo.sysmail_profile)
EXEC msdb.dbo.sp_send_dbmail @profile_name = @ProfileName,
	@recipients= 'smccown@firstam.com,eeasley@firstam.com,psdas@firstam.com',
	--@copy_recipients = @cc,
	--@blind_copy_recipients = @bcc,
    @subject = @SubjectLine,
    @body = @tableHTML,
    @body_format = 'HTML' ;

END

else 

print 'no records'




;
GO
/****** Object:  StoredProcedure [Collector].[spDBSizeInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[spDBSizeInsert]
(
@ExecutionDateTime Datetime,
@InstanceID int,
@DBName varchar(100),
@DataSpaceUsageKB int,
@DBSizeMB float,
@SpaceAvailKB int,
@LastBackupDate Datetime2,
@LastDiffBackupDate Datetime2,
@LastLogBackupDate Datetime2
)

   
AS

/*
This sp is called by the CollectorDBSizeGET PS script.
*/

Insert Collector.DBSize
Select
@ExecutionDateTime ,
@InstanceID ,
@DBName ,
@DataSpaceUsageKB ,
@DBSizeMB ,
@SpaceAvailKB ,
@LastBackupDate ,
@LastDiffBackupDate ,
@LastLogBackupDate 
	



;
GO
/****** Object:  StoredProcedure [Collector].[spDBListInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collector].[spDBListInsert]
(
@ExecutionDateTime DATETIME,
@InstanceID int,
@DBName varchar(100),
@DBSizeOnDiskInMB DECIMAL(12,2)
)

   
AS

INSERT Collector.Databases (ExecutionDateTime, InstanceID, DBName, DBSizeOnDiskInMB)
VALUES (@ExecutionDateTime, @InstanceID, @DBName, @DBSizeOnDiskInMB)






;
GO
/****** Object:  StoredProcedure [Collector].[spDriveSpaceInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Collector].[spDriveSpaceInsert]
(
@ExecDateTime datetime,
@InstanceID int,
@Name	varchar(255),
@Caption	varchar(255),
@DriveLetter	varchar(255),
@DriveType	varchar(255),
@FileSystem	varchar(255),
@Label	varchar(255),
@Capacity	varchar(255),
@FreeSpace	varchar(255),
@PctFree	varchar(255)
)

   
AS

--set xact_abort off

--create table DriveSpaceErrors
--(
--ExecDateTime datetime,
--InstanceID int,
--Name varchar(50),
--Caption varchar(10),
--DriveLetter varchar(5),
--DriveType varchar(25),
--FileSystem varchar(20),
--Label varchar(50),
--Capacity varchar(50),
--FreeSpace varchar(50),
--ErrorNum varchar(10),
--ErrorMessage varchar(2000)
--)



BEGIN TRY
Set @PctFree = CAST((ROUND(@FreeSpace, 2)*100/ROUND(@Capacity, 2)) AS decimal(4,2)) 

Insert Collector.DriveSpace
Select 
@ExecDateTime,
@InstanceID,
@Name,
@Caption,
@DriveLetter,
@DriveType,
@FileSystem,
@Label,
@Capacity,
@FreeSpace,
@PctFree
END TRY

BEGIN CATCH

Insert DriveSpaceErrors
Select 
@ExecDateTime,
@InstanceID,
@Name,
@Caption,
@DriveLetter,
@DriveType,
@FileSystem,
@Label,
@Capacity,
@FreeSpace,
Error_Number(),
Error_Message()

END CATCH




;
GO
/****** Object:  StoredProcedure [Collector].[spFileGrowthRateInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[spFileGrowthRateInsert]
(
	@ExecutionDateTime datetime ,
	@InstanceID int ,
	@DBName varchar(100),
	@FileGroup varchar(100),
	@FileName varchar(100),
	@Growth varchar(10),
	@GrowthType varchar(10)
)

  
AS


/*
This sp is called by the CollectorFileGrowthRateGET PS script.
*/

Insert Collector.FileGrowthRate
Select
	@ExecutionDateTime ,
	@InstanceID ,
	@DBName ,
	@FileGroup ,
	@FileName ,
	@Growth ,
	@GrowthType 
	



;
GO
/****** Object:  StoredProcedure [Collector].[spEmailLogSpaceAlert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[spEmailLogSpaceAlert] 
(@EmailProfile varchar(1024), @Distro varchar(4000))  

               
as               
            
	--Sean McCown              
--EXEC [Collector].[spEmailLogSpaceAlert] @EmailProfile='SQLfailedJobsEmailProfileName',@Distro='Sean.McCown@baylorhealth.edu' 

	Declare 
	
			@DBName VARCHAR(100),
			@GroupName varchar(10), 
			@CurrentSubject varchar(100),
			@MaxSize BIGINT, -- Size of log at the end of sample period.
			@MinSize BIGINT, -- Size of log at the beginning of sample period.
			@Delta FLOAT, -- Total diff in size of log from beginning of sample period to the end of the sample period.
			@1minDelta FLOAT, -- Change of log size in only 1 min of the sample period.
			@MinToFull INT, -- Minutes till the drive fills up.
			@NumberOfPeriods tinyint, -- Number of periods to measure.
			@TimePeriod TINYINT, -- Number of minutes between each collection.
			@TotalTime INT, -- Total time to be measured.
			@VolumeSpace BIGINT, --Space left after VolumeFreeSpace/@Delta.
			@DriveRunOutMins INT, -- Number of mins before drive runs out of space at current growth rate.  
			@PctFree TINYINT
	
	SET @DBName = ''	            
	SET @Distro =  @Distro +','+ ''              
	set @GroupName = ''
	set @CurrentSubject = 'Log file for ' + @GroupName + '.'	
	SET @NumberOfPeriods = 3
	SET @TimePeriod = 10
	
	
	
/* BEGIN drive fill calculation*/
----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
-- This is where I'm calculating how long it'll take the drive to fill up given the growth rate of the past few samples.
-- First I get the top 3 most recent exec times from the logspace table.
-- Then i get the size from the min and max execution times.  This gives the start and end log size.
-- Next I calculate the delta from the min and max sizes.  This tells me how much the log has grown during this sample period.
-- Now I multiply the number of collections with the time between collections to get the total number of minutes in the sample period.
-- Then I divide the delta from above by the total mins in the collection to get the delta for a single min.
-- And finally, dividing the volume free space by the 1minDelta above will give me the mins until the drive fills up.
	
SELECT TOP 3 executiondatetime
INTO #Times
FROM collector.logspace 
WHERE dbname = @DBName 
ORDER BY ExecutionDateTime DESC

--Get time periods to sample.  This is the period used to measure how much the log has grown.
--A simple delta between the 2 will give a good calc on how much the log will grow if it continues on its current path.
SET @MinSize =  (SELECT UsedSpace FROM Collector.Logspace WHERE dbname = @DBName AND ExecutionDateTime IN (SELECT MIN(executiondatetime)
FROM #Times))

SET @MaxSize =  (SELECT UsedSpace FROM Collector.Logspace WHERE dbname = @DBName AND ExecutionDateTime IN (SELECT MAX(executiondatetime)
FROM #Times))
----------------


SET @Delta = CAST(@MinSize AS float) - CAST(@MaxSize AS float)
SET @TotalTime = @NumberOfPeriods*@TimePeriod
SET @1minDelta = @Delta/@TotalTime -- This is the log growth for 1min during the collection period.


SET @VolumeSpace =  (SELECT VolumeFreeSpace FROM Collector.Logspace WHERE dbname = @DBName AND ExecutionDateTime IN (SELECT MIN(executiondatetime)
FROM #Times))

SET @DriveRunOutMins = (@VolumeSpace/@1minDelta)

--DROP TABLE #Times


----------------------------------------------------
----------------------------------------------------
----------------------------------------------------
/*END drive fill calculation*/

SET @PctFree = (SELECT CAST(100-((CAST(UsedSpace AS FLOAT)/CAST(SIZE AS FLOAT))*100) AS INT) AS PctFree
				FROM collector.logspace WHERE dbname = @DBName AND ExecutionDateTime IN (SELECT MAX(executiondatetime) FROM #Times))
	

-- Alert of the log has less than 15% free space, and the disk only has 10GB left.
--IF @PctFree <= 15 AND @VolumeSpace <= 10485760 -- in KB
--BEGIN



DECLARE @HTMLbody NVARCHAR(MAX)

SET @HTMLbody = '<html><head>'
SET @HTMLbody = @HTMLbody + '<style>TH {background-color: gray; font-weight: bold; border: 1; border-style: solid;} TD{border: 1; border-style: solid;}</style>'
SET @HTMLbody = @HTMLbody + '<title>' + @CurrentSubject + '</html></head></title>'
SET @HTMLbody = @HTMLbody + '<center><h1>' + @CurrentSubject + '</h1></center>'

SET @HTMLbody = @HTMLbody + '<center><table>'
SET @HTMLbody = @HTMLbody + '<TH>Time</TH><TH>DB</TH><TH>Size(GB)</TH><TH>Used(GB)</TH><TH>%Free</TH><TH>DiskFree(GB)</TH>'

DECLARE 
		@Time TIME(0),
		@SizeInGB VARCHAR(10),
		@UsedInGB VARCHAR(10),
		@currPctFree VARCHAR(5),
		@DiskFreeInGB VARCHAR(50),
		@SQL NVARCHAR(MAX)
SET @SQL = ''
		

DECLARE DataTable CURSOR
READ_ONLY
FOR
	SELECT TOP 3
	CAST(ExecutionDateTime AS TIME(0)) AS [Time],
	DBName, 
	Size/1024/1024 AS SizeInGB, 
CAST(CAST(UsedSpace AS float)/1024/1024 AS DECIMAL(10, 2)) AS UsedInGB,
CAST(100-((CAST(UsedSpace AS FLOAT)/CAST(SIZE AS FLOAT))*100) AS INT) AS PctFree,
VolumeFreeSpace/1024/1024 AS DiskSpaceFreeInGB 
FROM Collector.Logspace
WHERE dbname = @DBName 
ORDER BY ExecutionDateTime DESC

OPEN DataTable 
FETCH NEXT FROM DataTable INTO @Time, @DBName, @SizeInGB, @UsedInGB, @currPctFree, @DiskFreeInGB
WHILE @@FETCH_STATUS <> -1

	BEGIN
	
	SET @SQL = @SQL + '<TR><TD>' + CAST(@Time AS VARCHAR(20)) +'</TD><TD>' + @DBName + '</TD><TD>' + @SizeInGB + '</TD><TD>' + @UsedInGB + '</TD><TD>' + 
	@currPctFree + '</TD><TD>' + @DiskFreeInGB + '</TD></TR>'
	
	
FETCH NEXT FROM DataTable INTO @Time, @DBName, @SizeInGB, @UsedInGB, @currPctFree, @DiskFreeInGB
	
	END

CLOSE DataTable
DEALLOCATE DataTable

SET @HTMLbody = @HTMLbody + @SQL
SET @HTMLbody = @HTMLbody + '</table></center>'

SET @HTMLbody = @HTMLbody + '<br><center>At the current rate of growth the disk will be full in ' + CAST(@DriveRunOutMins AS VARCHAR(10)) + ' minutes.'
SET @HTMLbody = @HTMLbody + '<br>Click <a href="http://localhost/Reports/Pages/Report.aspx?ItemPath=%2fDBA+Reports%2fLogUsageDaily">here</a> to view today''s log growth graph.'
SET @HTMLbody = @HTMLbody + '<br><br>** As a precautionary measure the log will be expanded to a different drive once it reaches 5% free space.'

SET @HTMLbody = @HTMLbody + '</body></html>'


SELECT @HTMLbody
--	SELECT 
--	DBName, 
--	Size/1024/1024 AS SizeInGB, 
--CAST(CAST(UsedSpace AS float)/1024/1024 AS DECIMAL(10, 2)) AS UsedInGB,
--CAST(100-((CAST(UsedSpace AS FLOAT)/CAST(SIZE AS FLOAT))*100) AS INT) AS PctFree,
--VolumeFreeSpace/1024/1024 AS DiskSpaceFreeInGB 
--FROM Collector.Logspace
--WHERE dbname = 'BHCSECLPPRD'           
	                   
	   
	     
	EXEC msdb.dbo.sp_send_dbmail                
	@profile_name = @EmailProfile,              
	@recipients = 'Sean.McCown@baylorhealth.edu;',              
	--@recipients = @Distro,              
	@subject = @CurrentSubject,              
	@body = @HTMLbody,              
	@body_format = 'HTML';              


--END 





            
return 




;
GO
/****** Object:  StoredProcedure [Collector].[WaitStatsInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collector].[WaitStatsInsert]
(
    @ExecutionDateTime datetime,
	@InstanceID BIGINT,
    @WaitType nvarchar(60),
    @WaitingTasksCT bigint,
    @MaxWaitTimeMS bigint,
    @ResourceWaitTimeMS bigint,
    @PercentResourceWaitTime decimal(38, 17)
)
 
AS

INSERT Collector.WaitStats
SELECT 
@ExecutionDateTime,
@InstanceID,
@WaitType,
@WaitingTasksCT,
@MaxWaitTimeMS,
@ResourceWaitTimeMS,
@PercentResourceWaitTime

;
GO
/****** Object:  View [Collector].[WaitStatsCurrent]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[WaitStatsCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion as Version,
			S.SQLEdition as Edition,
			S.Descr,
			D.WaitType,
			D.WaitingTasksCT, 
			D.MaxWaitTimeMS, 
			D.ResourceWaitTimeMS, 
			D.PercentResourceWaitTime,
			'This view shows the latest WaitStats.  Use the PercenResourceWaitTime column to see the percentage of the WaitType for each collection period.  It is a good column to use when alerting for conditions.  If a performance condition arises, a spscific waitType is likely to increase in percentage.  So look for those increases.' AS ViewDesc
    FROM    Collector.WaitStats D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.WaitStats D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL

;
GO
/****** Object:  View [Collector].[TableSizeForCube]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[TableSizeForCube]
AS
SELECT  
S.InstanceID, S.ServerName, S.ServiceLevel, S.SQLVersion, S.SQLEdition,
		T.ExecutionDateTime,
        DATEPART(yyyy, T.ExecutionDateTime) AS ExecYear,
		CAST(T.ExecutionDateTime AS DATE) AS ExecDate,
        DATEPART(qq, T.ExecutionDateTime) AS ExecQuarter,
        DATEPART(mm, T.ExecutionDateTime) AS ExecMonth,
        DATEPART(dy, T.ExecutionDateTime) AS ExecDOY,
        DATEPART(dd, T.ExecutionDateTime) AS ExecDay,
        DATEPART(wk, T.ExecutionDateTime) AS ExecWeek,
        DATEPART(dw, T.ExecutionDateTime) AS ExecWeekday,
        DATEPART(hh, T.ExecutionDateTime) AS ExecHour,
        DATEPART(mi, T.ExecutionDateTime) AS ExecMinute,
        DATEPART(ss, T.ExecutionDateTime) AS ExecSecond,
        T.DBName,
        T.TableName,
        T.DataSpaceUsed/1024 AS DataSpaceUsedInMB,
        T.IndexSpaceUsed/1024 AS IndexSpaceUsedInMB,
        (T.DataSpaceUsed + T.IndexSpaceUsed)/1024.0 AS TotalSpaceUsedInMB,
        T.[RowCount],
        T.FileGroup
FROM    Collector.TableSize AS T
Inner Join dbo.Servers S
	ON T.InstanceID = T.InstanceID
    AND 
                S.IsActive = 1



;
GO
/****** Object:  View [Collector].[TableSizeCurrent]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[TableSizeCurrent]
AS
    SELECT DISTINCT
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion as Version,
			S.SQLEdition as Edition,
			S.Descr,
			D.DBName,
			D.TableName,
			D.DataSpaceUsed,
			D.IndexSpaceUsed,
			D.[RowCount],
			D.[FileGroup],
			D.[Schema],
			'This view shows the latest size of all the tables. To see the growth rate of all the tables just query the base table (Collector.TableSize) and graph it in Excel.' AS ViewDesc
    FROM    Collector.TableSize D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.TableSize D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL


;
GO
/****** Object:  StoredProcedure [dbo].[spSchemaVersionInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[spSchemaVersionInsert]
(
@Servername varchar(50),
@Tables int,
@SPs int,
@Views int,
@Other int,
@Notes varchar(max),
@Path varchar(max),
@ImplDate smalldatetime,
@ImplBy varchar(50)
)

  
AS

Declare @InstanceID int
Set @InstanceID = (Select InstanceID from dbo.Servers where ServerName = @Servername)


--INSERT INTO [DBStats].[dbo].[SchemaVersion]
--           ([InstanceID]
--           ,[DBID]
--           ,[Major]
--           ,[Tables]
--           ,[SPs]
--           ,[Views]
--           ,[Other]
--           ,[Notes]
--           ,[Path]
--           ,[ImplDate]
--           ,[ImplBy])
--     VALUES
--           (<@InstanceID
--           ,<DBID, int,>
--           ,<Major, int,>
--           ,<Tables, int,>
--           ,<SPs, int,>
--           ,<Views, int,>
--           ,<Other, int,>
--           ,<Notes, varchar,>
--           ,<Path, varchar,>
--           ,<ImplDate, smalldatetime,>
--           ,<ImplBy, varchar(100),>)




;
GO
/****** Object:  StoredProcedure [Collector].[spLogSpaceReportQuery]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collector].[spLogSpaceReportQuery]
(
@InstanceID INT,
@DBName VARCHAR(100)
)

  
AS

SELECT DBName, Size/1024/1024 AS SizeInGB, 
CAST(CAST(UsedSpace AS float)/1024/1024 AS DECIMAL(10, 2)) AS UsedInGB,
CAST(100-((CAST(UsedSpace AS FLOAT)/CAST(SIZE AS FLOAT))*100) AS INT) AS PctFree,
VolumeFreeSpace/1024/1024 AS DiskSpaceFreeInGB,
CAST(ExecutionDatetime as DATE) as [Date], 
CAST(ExecutionDatetime as Time(0)) as [Time]
FROM Collector.Logspace
WHERE dbname = @DBName
AND InstanceID = @InstanceID
AND CAST(ExecutionDateTime AS DATE) IN (SELECT TOP 1 CAST(MAX(ExecutionDateTime) AS DATE) 
										FROM Collector.Logspace
										WHERE InstanceID = @InstanceID)
order by executiondatetime DESC



;
GO
/****** Object:  StoredProcedure [Collector].[spLogspaceInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collector].[spLogspaceInsert]
(
@ExecutionDateTime datetime,
@InstanceID INT, 
@DBName VARCHAR(100),
@SIZE BIGINT,
@UsedSpace BIGINT,
@VolumeFreeSpace BIGINT,
@Growth BIGINT,
@GrowthType VARCHAR(20),
@MAXSIZE BIGINT
)

  
AS

INSERT Collector.Logspace 
SELECT 
@ExecutionDatetime,
@InstanceID, 
@DBName,
@SIZE,
@UsedSpace,
@VolumeFreeSpace,
@Growth,
@GrowthType,
@MAXSIZE



;
GO
/****** Object:  StoredProcedure [dbo].[spIsDBRestricted]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spIsDBRestricted]

  
AS

IF ((SELECT COUNT(1) FROM SYS.DATABASES 
		WHERE user_access = 2)= 0)

BEGIN

DECLARE @ProfileName NVARCHAR(100);
DECLARE @tableHTML  NVARCHAR(100) ;
DECLARE @SubjectLine NVARCHAR(100);
SET @SubjectLine = 'Database Status'
SET @tableHTML = 'There is no Database in RESTRICTED USER access mode in server '+ @@SERVERNAME 

/*N'<table border="1">' +
    N'<tr><th>Server Name</th><th>DB Name</th>' +
    CAST ( ( SELECT td = @@SERVERNAME, '', td = NAME FROM master.sys.databases WHERE user_access = 0
			 FOR XML PATH('tr')
    ) AS NVARCHAR(MAX) ) +
    N'</table>' ;*/

print @tableHTML;
set @ProfileName = (select top 1 name from msdb.dbo.sysmail_profile)
EXEC msdb.dbo.sp_send_dbmail @profile_name = @ProfileName,
	@recipients = 'smccown@firstam.com,eeasley@firstam.com,psdas@firstam.com',
	--@copy_recipients = @cc,
	--@blind_copy_recipients = @bcc,
    @subject = @SubjectLine,
    @body = @tableHTML,
    @body_format = 'TEXT' ;

END
ELSE
PRINT 'Do not send mail.'




;
GO
/****** Object:  StoredProcedure [Collector].[spIPAddrInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[spIPAddrInsert]
(
@InstanceID INT,
@IP varchar(15),
@DNS VARCHAR(50)
)

  

AS
/*
Sets the IP address in the dbo.Servers table.
This gets called from CollectorIPAddressGET.ps1
*/

Update dbo.Servers
SET IP = @IP,
	DNS = @DNS
WHERE InstanceID = @InstanceID




;
GO
/****** Object:  StoredProcedure [Collector].[spServiceAlertInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[spServiceAlertInsert]
(
@ExecutionDateTime datetime,
@InstanceID int,
@ServiceName varchar(100)
)

  
AS

Insert Collector.ServiceAlert
(ExecutionDateTime, InstanceID, ServiceName)
Select @ExecutionDateTime, @InstanceID, @ServiceName




;
GO
/****** Object:  StoredProcedure [Collector].[spServiceAcctInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Gets the startup accts for all SQL services.
CREATE procedure [Collector].[spServiceAcctInsert]
(
@ExecutionDateTime datetime,
@InstanceID int,
@ServiceName varchar(50),
@StartName varchar(50)
)

  
AS

Insert Collector.ServiceAcct
Select
@ExecutionDateTime,
@InstanceID,
@ServiceName,
@StartName
;
GO
/****** Object:  StoredProcedure [Portal].[spServersDistinct]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Portal].[spServersDistinct]

  
as
SELECT distinct 
	   s.[InstanceID],
	   s.[LocID],
	   s.[ServerName],
	   s.[DNS],
	   CASE WHEN s.[IP] is NULL THEN '127.0.0.1' 
	   ELSE s.[IP]
	   END AS IP,   
	   s.[Port],
	   s.[Descr],
	   s.[Role],
	   s.[IsSQL],
	   s.[IsCluster]
FROM dbo.[Servers] AS s
ORDER BY s.[ServerName]




;
GO
/****** Object:  StoredProcedure [Collector].[spServerRoleMemberInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collector].[spServerRoleMemberInsert]
(
@ExecutionDatetime datetime,
@InstanceID int,
@ServerRole varchar(50),
@MemberName varchar(100)--,
--@MemberSID VARCHAR(100)
)

  
AS

INSERT Collector.ServerRoleMember
SELECT @ExecutionDatetime, @InstanceID, @ServerRole, @MemberName--, @MemberSID




;
GO
/****** Object:  StoredProcedure [Collector].[spServerJobsInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collector].[spServerJobsInsert]
(
@ExecutionDateTime datetime,
@InstanceID INT,
@JobName VARCHAR(100),
@JobID varchar(100),
@Descr NVARCHAR(512),
@ENABLED BIT,
@OwnerSID varchar(100),
@DateCreated DATETIME,
@DateModified DATETIME
)

  
AS


INSERT dbo.ServerJobs
SELECT
@InstanceID,
@JobName,
@JobID,
@Descr,
@ENABLED,
@OwnerSID,
@DateCreated,
@DateModified,
@ExecutionDateTime



;
GO
/****** Object:  StoredProcedure [Collector].[spTableSizeInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[spTableSizeInsert]
(
	@ExecutionDateTime datetime ,
	@InstanceID int ,
	@DBName varchar(100),
	@TableName varchar(100),
	@DataSpaceUsed bigint,
	@IndexSpaceUsed bigint,
	@RowCount bigint,
	@FileGroup varchar(100),
	@Schema varchar(100)
)

  
AS

Insert Collector.TableSize
Select
	@ExecutionDateTime,
	@InstanceID,
	@DBName,
	@TableName,
	@DataSpaceUsed,
	@IndexSpaceUsed,
	@RowCount,
	@FileGroup,
	@Schema




;
GO
/****** Object:  StoredProcedure [Collector].[spSQLVersionInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[spSQLVersionInsert]
(
@InstanceID INT,
@Edition varchar(30),
@SP varchar(10),
@Build varchar(25),
@IsClustered bit
)
--collector.spSQLVersionInsert 1, 'Enterprise Edition', 'SP6', '8.0.2531', 0

  
AS

declare @Version varchar(5)

IF @Build like '8.%'
	BEGIN
	SET @Version = 2000
	END
	
	IF @Build like '9.%'
	BEGIN
	SET @Version = 2005
	END
	
	IF @Build like '10.%'
	BEGIN
	SET @Version = 2008
	END

	IF @Build like '10.5%'
	BEGIN
	SET @Version = '2008 R2'
	END
  
  	IF @Build like '11.%'
	BEGIN
	SET @Version = 2012
	END  

  	IF @Build like '12.%'
	BEGIN
	SET @Version = 2012
	END  

IF @Edition like 'Enterprise%'
	BEGIN
	SET @Edition = 'Ent'
	END
IF @Edition like 'Standard%'
	BEGIN
	SET @Edition = 'Std'
	END
IF @Edition like 'Data%'
	BEGIN
	SET @Edition = 'Dtc'
	END
IF @Edition like 'Workgroup%'
	BEGIN
	SET @Edition = 'Wkg'
	END
	IF @Edition like 'Express%'
	BEGIN
	SET @Edition = 'Exp'
	END

Update dbo.Servers
SET IsSQL = 1,
	SQLVersion = @Version,
	SQLEdition = @Edition,
	SQLServicePack = @SP,
	SQLBuild = 
				CASE WHEN @Version = '2008 R2' THEN LEFT(@Build, 10)
				ELSE  LEFT(@Build, 9)
				END,
	IsCluster = @IsClustered
WHERE InstanceID = @InstanceID





;
GO
/****** Object:  StoredProcedure [Collector].[spServiceStatusInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[spServiceStatusInsert]
(
@ExecutionDateTime datetime,
@InstanceID int,
@ServiceName varchar(50),
@Status varchar(20),
@StartMode varchar(20)
)

  
AS

Insert Collector.ServiceStatus
Select
@ExecutionDateTime,
@InstanceID,
@ServiceName,
@Status,
@StartMode



;
GO
/****** Object:  StoredProcedure [Archive].[TableSize]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Archive].[TableSize]

   
AS

DECLARE @ArchiveInDays INT
		


CREATE TABLE #ServerList
(
InstanceID INT,
ArchiveInDays INT
)

INSERT #ServerList
(ArchiveInDays)
SELECT DISTINCT InstanceID 
FROM Collector.TableSize
ORDER BY InstanceID


----Get default for all servers. InstanceID 0 means 'all servers'.
SELECT @ArchiveInDays = ArchiveInDays
FROM Archive.TableSizeMaster
WHERE InstanceID = 0;

----Set Archive params to the default.
UPDATE #ServerList
SET ArchiveInDays = @ArchiveInDays

----Set Archive params for any specific servers there may be.
UPDATE S
SET S.ArchiveInDays = DSM.ArchiveInDays
FROM #ServerList S
INNER JOIN Archive.TableSizeMaster DSM
ON S.InstanceID = DSM.InstanceID


SELECT * FROM #ServerList


--------------------------------------------------
----------BEGIN Delete----------------------------
--------------------------------------------------

set nocount on

while 1=1

begin

		DELETE TOP(10000) FROM DS
		FROM Collector.TableSize DS
		INNER JOIN #ServerList S
		ON DS.InstanceID = S.InstanceID
		WHERE DS.ExecutionDateTime > S.ArchiveInDays

if @@rowcount = 0
break
end

--------------------------------------------------
----------END Delete------------------------------
--------------------------------------------------
;
GO
/****** Object:  StoredProcedure [Collector].[SysObjectsInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collector].[SysObjectsInsert]
(
@ExecutionDateTime datetime,
@InstanceID bigint,
@DBName sysname,
@ObjectName sysname,
@ObjectId int,
@ParentName sysname,
@PrincipalId int,
@SchemaName sysname,
@SchemaId int,
@ParentObjectId int,
@Type char(2),
@TypeDesc nvarchar(120),
@CreateDate datetime,
@ModifyDate datetime,
@IsMSShipped bit,
@IsPublished bit,
@IsSchemaPublished bit
)
 
AS

INSERT Collector.SysObjects
(
ExecutionDateTime,
InstanceID,
DBName,
ObjectName,
ObjectId,
ParentName,
PrincipalId,
SchemaName,
SchemaId,
ParentObjectId,
Type,
TypeDesc,
CreateDate ,
ModifyDate,
IsMSShipped,
IsPublished ,
IsSchemaPublished
)
SELECT
@ExecutionDateTime,
@InstanceID,
@DBName,
@ObjectName,
@ObjectId,
@ParentName,
@PrincipalId,
@SchemaName,
@SchemaId,
@ParentObjectId,
@Type,
@TypeDesc,
@CreateDate ,
@ModifyDate,
@IsMSShipped,
@IsPublished ,
@IsSchemaPublished

/****** Object:  StoredProcedure [Report].[DBGrowthChartDataGet]    Script Date: 5/11/2015 3:22:27 PM ******/
SET ANSI_NULLS ON
;
GO
/****** Object:  View [Collector].[SysObjectsCurrent]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collector].[SysObjectsCurrent]
AS
    SELECT DISTINCT
			D.ID,
            D.ExecutionDateTime ,
			S.InstanceID,
            S.ServerName ,
            S.ServiceLevel AS ServiceLevel,
			S.SQLVersion as Version,
			S.SQLEdition as Edition,
			S.Descr,
			D.DBName,
			D.ObjectName,
			D.ObjectId,
			D.ParentName,
			D.PrincipalId,
			D.SchemaName,
			D.SchemaId,
			D.ParentObjectId,
			D.Type,
			D.TypeDesc,
			D.CreateDate,
			D.ModifyDate,
			D.IsMSShipped,
			D.IsPublished,
			D.IsSchemaPublished,
			'This view shows the latest SysObjects from each DB. This is best used to see when objects come and go from DBs, and to investigate when an object might be missing from certain servers, or DBs.' AS ViewDesc
    FROM    Collector.SysObjects D WITH ( NOLOCK )
            INNER JOIN dbo.Servers S WITH ( NOLOCK ) 
			ON D.InstanceID = S.[InstanceID]
            WHERE D.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) AS ExecutionDateTime                                
                         FROM   Collector.SysObjects D2  WITH (NOLOCK)
                         WHERE D2.InstanceID = D.InstanceID
                       ) 
    AND 
                s.IsActive = 1
            AND s.ServiceLevel IS NOT NULL
;
GO
/****** Object:  View [dbo].[SQLVersionLevelsGet]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[SQLVersionLevelsGet]
AS

----Get Latest SQL Patches compared to the installed ones.
----You often need to know how many of your boxes aren't on the latest patches.
----This view compares your current patch levels with the latest patch levels so you can see which ones aren't up to date.
----If you have need of further analysis, you can either use this view as a base for further queries, or use this code as a base 
----to write your own code.  Either way you have all the versions of your entire shop right here.
----MinionWare will send out updates to the version table as new patches come out.

WITH Patches AS
(
select ROW_NUMBER() OVER (partition by Version ORDER BY Version, ReleaseDate DESC, Build DESC) AS RowNum,
Version, VersionName, Build, BaseBuild, ReleaseDate, SupportLink
from SQLVersions WITH (NOLOCK)
WHERE VersionName <> 'Hotfix'
	  AND BaseBuild NOT LIKE 'CTP%'
)


select 
	S.InstanceID, S.ServerName, S.SQLBuild AS SQLBuild, 
	S.SQLVersion AS VersionName,
	(SELECT BaseBuild FROM dbo.SQLVersions SV2 where S.SQLBuild = SV2.Build) AS BaseBuild, 

	--(SELECT VersionName FROM dbo.SQLVersions SV2 where S.SQLBuild = SV2.Build) AS CurrentPatch,
	SV.VersionName as LatestPatch ,
	SV.[ReleaseDate] AS LatestPatchReleaseDate, 

	--(SELECT ReleaseDate FROM Patches SV2 where S.SQLBuild = SV2.Build) AS LatestPatchReleaseDate,

	SV2.VersionName as CurrentPatch,
	SV2.[ReleaseDate] as CurrentPatchReleaseDate,

SV.SupportLink AS LatestPatchURL,
S.ServiceLevel,
S.SQLEdition,
'This view shows you the latest service pack and how far out of date your servers are. It only includes CUs and SPs, so hotfixes are excluded. You typically don''t care about hotfixes in an investigation like this.' AS ViewDesc
from dbo.servers S
--- Give me the latest released patch
LEFT OUTER JOIN Patches SV
ON CAST(S.SQLVersion AS varchar(10)) = CAST(SV.Version AS varchar(10))
	AND SV.RowNum = 1
--- Give me the Server's actual current patch
LEFT OUTER JOIN Patches SV2
	ON S.SQLBuild = SV2.Build
	


;
GO
/****** Object:  StoredProcedure [Report].[SQLServerInventoryServersGET]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Report].[SQLServerInventoryServersGET]
 
AS

SELECT  
S.ServerName, S.IP, S.ServiceLevel, S.SQLVersion, S.SQLEdition, S.IsCluster, S.OSVersion, 
SVG.SQLBuild, SVG.VersionName, SVG.BaseBuild, SVG.CurrentPatch,
CONVERT(varchar(10), SVG.CurrentPatchReleaseDate, 110) AS CurrentPatchReleaseDate, 
SVG.LatestPatch, 
CONVERT(varchar(10), SVG.LatestPatchReleaseDate, 110) AS LatestPatchReleaseDate, 
--SVG.LatestPatchName
SVG.LatestPatchURL,
CASE WHEN S.CPULogicalTotal = 0 THEN S.CPUSockets 
	 WHEN S.CPULogicalTotal > 0 THEN S.CPULogicalTotal
END AS CPULogicalTotal, S.ServerMemInMB
FROM dbo.Servers S
LEFT OUTER JOIN dbo.SQLVersionLevelsGet SVG
ON S.InstanceID = SVG.InstanceID
WHERE S.IsSQL = 1 
AND S.IsActive = 1
ORDER BY S.ServerName

;
GO
/****** Object:  StoredProcedure [dbo].[spViewServersByRole]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spViewServersByRole]
(
@AppRoleID int
)

  
AS

SELECT RTRIM( L.LocName) as LocName, S.InstanceID, S.LocID, RTRIM(S.ServerName) AS ServerName,
 RTRIM(S.Role) AS Role, 
RTRIM(S.DNS) AS DNS, 
RTRIM(S.IP) AS IP, 
RTRIM(S.Port) AS Port, 
RTRIM(S.Descr) AS Descr  from Servers S
Inner Join ServerAppRoleApp SAA
ON S.InstanceID = SAA.InstanceID
Inner Join ApplicationRole A
ON SAA.AppRoleID = A.AppRoleID
Inner Join Location L
ON L.LocID = S.LocID
WHERE A.AppRoleID = @AppRoleID




;
GO
/****** Object:  StoredProcedure [dbo].[spViewServersByApp]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spViewServersByApp]
(
@AppID int
)

  
AS

SELECT RTRIM( L.LocName) as LocName, S.InstanceID, S.LocID, RTRIM(S.ServerName) AS ServerName,
 RTRIM(S.Role) AS Role, 
RTRIM(S.DNS) AS DNS, 
RTRIM(S.IP) AS IP, 
RTRIM(S.Port) AS Port, 
RTRIM(S.Descr) AS Descr  from Servers S
Inner Join ServerAppRoleApp SAA
ON S.InstanceID = SAA.InstanceID
Inner Join Application A
ON SAA.AppID = A.AppID
Inner Join Location L
ON L.LocID = S.LocID
WHERE A.AppID = @AppID




;
GO
/****** Object:  StoredProcedure [dbo].[spViewServerAppDetails]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spViewServerAppDetails]
(
@InstanceID int
)

  
AS


Select S.InstanceID, A.AppName, AR.AppRoleName from Servers S
Inner Join dbo.ServerAppRoleApp SA
ON S.InstanceID = SA.InstanceID
Inner Join dbo.Application A
ON A.AppID = SA.AppID
Inner Join dbo.ApplicationRole AR
ON AR.AppRoleID = SA.AppRoleID

Where S.InstanceID = @InstanceID




;
GO
/****** Object:  StoredProcedure [Alert].[spServiceStatus]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Alert].[spServiceStatus] 
(
@EmailProfile varchar(1024), @ServiceLevel varchar(10) 
)
                     
as                   

DECLARE @Distro varchar(4000),
		@ExecutionDateTime datetime;                                
 
 SET @ExecutionDateTime = GETDATE();                  
--  EXEC [Alert].[spServiceStatus] @EmailProfile='ServiceStatusProfile' ,@ServiceLevel='Gold'     
   
 select @Distro =''    
 select @Distro=@Distro+EmailAddress+'; ' from  dbo.EmailNotification  a   
 order by EmailAddress     

                                                         
 DECLARE @CurrentSubject varchar(100)                  
 set @CurrentSubject = 'Services Not-Running (' + @ServiceLevel + ')'        
                
                  
 --Generate email string                  
 DECLARE @tableHTML  NVARCHAR(MAX) ;   
 
 
 SELECT 
  a.InstanceID,            
  a.ServerName,                  
  a.ServiceName,
  a.Status,  
  a.StartMode,                
  isnull(c.AppName, 'unknown') AS AppName  
INTO #Final          
FROM           
[Collector].[ServiceStatusCurrent]  a(nolock)          
 Left join ServerAppRoleApp b (nolock)          
 on a.InstanceID = b.InstanceID          
 Left join Application c(nolock)          
 on b.AppID  = c.AppID          
 where a.StartMode = 'Auto' and a.Status not in ('Running', 'Unknown')  
 AND a.ServiceName LIKE '%SQL%'
 AND ServiceLevel = @ServiceLevel        
 order by AppName, ServerName                             
 
                
 SET @tableHTML =                  
 N'<H2>'+@CurrentSubject +'</H2>' +                  
 N'<table border="1">' +                  
    N'<tr> 
     <th>InstanceID</th>	         
     <th>ServerName</th>                  
     <th>ServiceName</th>          
     <th>Status</th> 
     <th>StartMode</th> 
     <th>ApplicationName</th></tr>' +           
                      
 CAST ( ( SELECT    
   td = InstanceID, '',          
   td = ServerName, '',                  
  td = ServiceName, '', 
   td = Status, '',  
   td = StartMode, '',                     
  td = AppName, ''          
   from           
#Final     
 order by AppName, InstanceID                             
 FOR XML PATH('tr'), TYPE                   
 ) AS NVARCHAR(MAX) ) +                  
 N'</table>' ;                  
 set @tableHTML =@tableHTML+'<BR>'                  
 set @tableHTML =@tableHTML+'***Automated Report-Do not reply.***'                  

 
 INSERT History.ServiceStatus (ExecutionDateTime, InstanceID, ServerName, ServiceName, ServiceStartMode, ServiceStatus, ServiceLevel, AppName)
 SELECT @ExecutionDateTime, InstanceID, ServerName, ServiceName, StartMode, Status, @ServiceLevel, AppName
 FROM #Final
 
             
 --Send Email                  
 IF  ( SELECT  COUNT(*) FROM #Final) > 0            
                  
 EXEC msdb.dbo.sp_send_dbmail                    
     @profile_name = @EmailProfile,                                  
     @recipients = @Distro,                  
     @subject = @CurrentSubject,                  
     @body = @tableHTML,                  
     @body_format = 'HTML';                  
                
return 

;
GO
/****** Object:  StoredProcedure [Portal].[spServerApps]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Portal].[spServerApps]

  
as
SELECT s.[InstanceID],
sara.[AppID],
sara.[AppRoleID],
ar.[AppName],
ar2.[AppRoleName],
	   s.[LocID],
	   s.[ServerName],
	   s.[DNS],
	   CASE WHEN s.[IP] is NULL THEN '127.0.0.1' 
	   ELSE s.[IP]
	   END AS IP,
	   
	   s.[Port],
	   s.[Descr],
	   sr.[Role],
	   s.[IsSQL]
FROM dbo.[Servers] AS s
LEFT Outer JOIN dbo.[ServerAppRoleApp] AS sara
ON s.[InstanceID] = sara.[InstanceID]
LEFT Outer JOIN dbo.[Application] AS ar
ON sara.[AppID] = ar.[AppID]
LEFT Outer JOIN dbo.[ApplicationRole] AS ar2
ON sara.[AppRoleID] = ar2.[AppRoleID]
LEFT OUTER JOIN dbo.ServerRole sr
ON s.InstanceID = sr.InstanceID

ORDER BY ar.[AppName], ar2.[AppRoleName], s.[ServerName]




;
GO
/****** Object:  StoredProcedure [dbo].[spGetServersByGroup]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spGetServersByGroup]
(
@AppName varchar(50)
)

  
AS

Declare @AppID int

Set @AppID = (Select AppID from dbo.Application WHERE AppName = @AppName)

Select S.ServerName, S.DNS
from Servers S
inner join ServerAppRoleApp SA
on S.InstanceID = SA.InstanceID
where SA.AppID = @AppID
--and S.DNS not like '%cert%'
--AND S.DNS not like '%dev%'




;
GO
/****** Object:  StoredProcedure [dbo].[spGetAppsAndCounts]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spGetAppsAndCounts]

  
AS

Select A.AppName, count(*) as 'Count'
from Servers S
inner join ServerAppRoleApp SA
on S.InstanceID = SA.InstanceID
inner join Application A
on SA.AppID = A.AppID
group by A.AppName




;
GO
/****** Object:  StoredProcedure [Alert].[spDriveFreeSpace]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--sp_helptext 'alert.spdrivefreespace'

--Text
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--

CREATE PROCEDURE [Alert].[spDriveFreeSpace]
    (
      @EmailProfile VARCHAR(1024) ,
      @ServiceLevel VARCHAR(10) ,
      @DefaultThreshold TINYINT ,
      @IncludeDefer BIT ,
      @IncludeException BIT ,
      @IncludeChange BIT
    )
	
   
AS 
/*
Minion by MidnightDBA

Purpose:
	Sends an alert email for all drives in a service level that are below threshold. E.g., if the 
	Gold level "ProdSvr" drive D: has less than 15% free space, it will be included in an alert for
	Gold level servers.

Called from: 
	SQL Agent jobs "AlertDriveFreeSpaceGold", "AlertDriveFreeSpaceSilver", "AlertDriveFreeSpaceBronze".

Parameter definitions:
		@EmailProfile		Profile to use for emailing alerts.
		@ServiceLevel		Service level to alert on, e.g. Gold, Silver, Bronze.
		@DefaultThreshold	Default threshold in percent to alert on (for servers without defined thresholds)
		@IncludeDefer		Include SQL commands in the email for deferring alerts on a drive. 
		@IncludeException 	Include SQL commands in the email for excepting alerts on a drive.
		@IncludeChange 		Include SQL commands in the email for changing alerts on a drive.

Example execution:
	EXEC [Alert].[spDriveFreeSpace] 
		@EmailProfile = 'DriveSpaceProfile',
		@ServiceLevel = 'Silver', 
		@DefaultThreshold = 15, 
		@IncludeDefer = 1,
		@IncludeException = 1, 
		@IncludeChange = 1;

Modification log: 
	8/10/2014 J.M. Added semicolons, expanded SELET *s.
*/    
--------------------------------------------------------------------
    DECLARE @Distro VARCHAR(MAX);

----Get master list of servers and disks.
    SELECT DISTINCT
			--RecentDate.*,
            s.[InstanceID] ,
            s.ServerName ,
            Caption AS DriveName ,
            [%Free] AS [SpaceFreeIn%] ,
            CONVERT(DECIMAL(20, 2), FreeSpace) AS [FreeSpace] ,
            a.ExecutionDateTime ,
            s.ServiceLevel AS ServiceLevel
    INTO    #ServerList
    FROM    Collector.DriveSpace a ( NOLOCK )
            INNER JOIN dbo.Servers s ( NOLOCK ) ON a.InstanceID = s.[InstanceID]
            LEFT JOIN ServerAppRoleApp b ( NOLOCK ) ON a.InstanceID = b.InstanceID
            LEFT JOIN Application c ( NOLOCK ) ON b.AppID = c.AppID
            INNER JOIN ( SELECT InstanceID ,
                                MAX(ExecutionDateTime) AS ExecutionDateTime
                         FROM   Collector.DriveSpace  (NOLOCK)
                         GROUP BY InstanceID
                       ) AS RecentDate ON a.InstanceID = RecentDate.InstanceID
                                          AND a.ExecutionDateTime = RecentDate.ExecutionDateTime
    WHERE   s.IsSQL = 1
            AND s.IsActive = 1
            AND s.DiskManaged = 1
            AND s.ServiceLevel IS NOT NULL;
        
-----Delete ServiceLevels you don't need.

    DELETE  #ServerList
    WHERE   ServiceLevel <> @ServiceLevel;
       
--select 'Before Server Exceptions', * from #ServerList  

        
-----Delete disk exceptions on a per server basis.
-----These are drives you don't want to alert on at all.  So for example you know the C: on a server is full and there's nothing you
-----can do about it then you can put an entry into the dbo.DriveSpaceExceptions table and filter it out here.
    DELETE  SL
    FROM    #ServerList SL
            INNER JOIN dbo.DriveSpaceExceptions DE ON ( SL.[InstanceID] = DE.InstanceID
                                                        AND SL.DriveName = DE.Caption
                                                      );
      

-----Create new #Table with the thresholds.  
-----!!!!!The most important thing here is that the cols in the ON condition are equal.  
-----!!!!!This could be the reason some drives don't get reported correctly.        
    SELECT  SL.InstanceID ,
			SL.ServerName ,
			SL.DriveName ,
			SL.[SpaceFreeIn%] ,
			SL.FreeSpace ,
			SL.ExecutionDateTime ,
			SL.ServiceLevel ,
            DE.AlertMethod ,
            DE.AlertValue
    INTO    #Final
    FROM    #ServerList SL
            LEFT OUTER JOIN dbo.DriveSpaceThresholdServer DE ON SL.[InstanceID] = DE.InstanceID; 
			--(SL.InstanceID = DE.InstanceID AND SL.DriveName = DE.Caption)  


-----Test individual server.    
--WHERE [InstanceID] = 175

---select 'Server Exceptions', * from #Final

--SELECT * FROM #Final
--WHERE InstanceID = 370

-----Set the drive-specific alert thresholds.
    UPDATE  F
    SET     AlertMethod = DE.AlertMethod ,
            AlertValue = DE.AlertValue
    FROM    #Final F 
	--INNER JOIN #ServerList SL
	--ON SL.InstanceID = F.InstanceID
            INNER JOIN dbo.DriveSpaceThresholdDrive DE ON ( F.[InstanceID] = DE.InstanceID
                                                            AND F.DriveName = DE.Caption
                                                          ); 

 

-----We're done with this table now.
    DROP TABLE #ServerList;


-----Set AlertThreshold to default where it's NULL.  This is the default passed into the SP.  The default is always percent.
    UPDATE  #Final
    SET     AlertMethod = 'Percent' ,
            AlertValue = @DefaultThreshold
    WHERE   AlertValue IS NULL;

--Select 'Final', * from #Final
--where [InstanceID] = 144

--SELECT 'Defer' as Defer, F.*, B.* FROM #Final F
--INNER JOIN Alert.DiskSpaceDefer B
--ON 
--(F.[InstanceID] = B.InstanceID AND F.DriveName = B.Caption) 
--WHERE CAST(GETDATE() AS DATE) < B.DeferEndDate


    DELETE  F
    FROM    #Final F
            INNER JOIN Alert.DiskSpaceDefer B ON ( F.[InstanceID] = B.InstanceID
                                                   AND F.DriveName = B.Caption
                                                 )
    WHERE   CAST(GETDATE() AS DATE) < B.DeferEndDate;


-----Make sure all the values in the AlertValue are the same measure as the FreeSpace col.
-----Convert them all to byte to make the comparison below really easy.

    UPDATE  #Final
    SET     AlertValue = CASE WHEN AlertMethod = 'GB'
                              THEN ( AlertValue * 1024.0 * 102.04 * 1024.0 )
                              WHEN AlertMethod = 'MB'
                              THEN ( AlertValue * 1024.0 * 1024.0 )
                              WHEN AlertMethod = 'KB'
                              THEN ( AlertValue * 1024.0 )
                         END
    WHERE   AlertMethod <> 'Percent';

--select 'Drive Exceptions', * from #Final

-----Delete percent drives that don't belong in the report.
    DELETE  F
    FROM    #Final F
    WHERE   f.[SpaceFreeIn%] >= f.AlertValue
            AND f.AlertMethod = 'Percent';

--SELECT * FROM #Final
--WHERE [InstanceID] = 370
   
-----Delete size drives that don't belong in the report.
    DELETE  F
    FROM    #Final F
    WHERE   f.[FreeSpace] >= f.AlertValue
            AND f.AlertMethod <> 'Percent';
--------------------------------------------------------------------
-----Convert values back for the report. This way users see the value that is set as the threshold value.

 

    UPDATE  #Final
    SET     AlertValue = CASE WHEN AlertMethod = 'GB'
                              THEN ( AlertValue / 1024.0 / 1024.0 / 1024.0 )
                              WHEN AlertMethod = 'MB'
                              THEN ( AlertValue / 1024.0 / 1024.0 )
                              WHEN AlertMethod = 'KB'
                              THEN ( AlertValue / 1024.0 )
                         END ,
            FreeSpace = CASE WHEN AlertMethod = 'GB'
                             THEN ( FreeSpace / 1024.0 / 1024.0 / 1024.0 )
                             WHEN AlertMethod = 'MB'
                             THEN ( FreeSpace / 1024.0 / 1024.0 )
                             WHEN AlertMethod = 'KB'
                             THEN ( FreeSpace / 1024.0 )
                        END
    WHERE   AlertMethod <> 'Percent';

----- Update the FreeSpace col for the Percent cols.  At the beginning of the SP it was left as byte but that's too long for the report.
----- So just convert it to GB for ease.



    UPDATE  #Final
    SET     FreeSpace = FreeSpace / 1024.0 / 1024.0 / 1024.0
    WHERE   AlertMethod = 'Percent';

    SELECT  'Final' ,
            *
    FROM    #Final;


    SELECT  @Distro = ''    
    SELECT  @Distro = @Distro + EmailAddress + '; '
    FROM    dbo.EmailNotification a
    ORDER BY EmailAddress;   
 --select @Distro = left(@Distro, len(@Distro)-1)    
 --print @Distro      
            
    DECLARE @count INT                 
    DECLARE @CurrentSubject VARCHAR(1000)                
    SELECT  @count = COUNT(*)
    FROM    #Final
    SET @CurrentSubject = CAST(@count AS VARCHAR(50)) + ' Drive Space Issues('
        + @ServiceLevel + ')' ;       
 --select @CurrentSubject  
               
              
 --Generate email string                
    DECLARE @tableHTML NVARCHAR(MAX);                
    SET @tableHTML = N'<H2>' + @CurrentSubject + '</H2>'
        + N'<table border="1">' + N'<tr>        
     <th>ServerName</th>                
     <th>DriveName</th>        
     <th>SpaceFree%</th>                
     <th>FreeSpace</th>           
     <th>Metric</th>
     <th>SpaceThreshold</th>
     <th>ApplicationName</th></tr>'
        + CAST(( SELECT td = a.ServerName ,
                        '' ,
                        td = a.DriveName ,
                        '' ,
                        td = a.[SpaceFreeIn%] ,
                        '' ,
                        td = a.FreeSpace ,
                        '' ,
                        td = a.AlertMethod ,
                        '' ,
                        td = a.AlertValue ,
                        '' ,
                        td = ISNULL(c.AppName, 'unknown') ,
                        ''
                 FROM   #Final a WITH ( NOLOCK )
                        LEFT JOIN dbo.ServerAppRoleApp b WITH ( NOLOCK ) ON a.[InstanceID] = b.InstanceID
                        LEFT JOIN dbo.Application c WITH ( NOLOCK ) ON b.AppID = c.AppID        
--  where  a.[SpaceFreeIn%] <= a.AlertThreshold       
                 ORDER BY c.AppName ,
                        a.ServerName ,
                        a.DriveName ,
                        a.[SpaceFreeIn%]
               FOR
                 XML PATH('tr') ,
                     TYPE
               ) AS NVARCHAR(MAX)) + N'</table>';                
    SET @tableHTML = @tableHTML + '<BR>';          
 

    DECLARE @ChangeSQL NVARCHAR(MAX);
    IF @IncludeChange = 1 
        BEGIN

            SET @ChangeSQL = N'<H2>Change SQL</H2>' + N'<table border="0">'
                + N'<tr>        
     <th>Run this to change the disk threshold:</th>                
</tr>'
                + CAST(( SELECT td = 'EXEC Setup.DiskSpaceThreshold ' + ''''
                                + ServerName + '''' + ', ' + '''' + DriveName
                                + '''' ,
                                '' + '' + ', ''' + AlertMethod + '''' + ', '
                                + CAST(AlertValue AS VARCHAR(15))
                         FROM   #Final
                         ORDER BY ServerName ,
                                DriveName
                       FOR
                         XML PATH('tr') ,
                             TYPE
                       ) AS NVARCHAR(MAX)) + N'</table>';       

            SET @tableHTML = @tableHTML + @ChangeSQL;

        END

 ----------------------------------------------------------------------






    DECLARE @ExcludeSQL NVARCHAR(MAX);
    IF @IncludeException = 1 
        BEGIN

            SET @ExcludeSQL = N'<H2>Exclude SQL</H2>' + N'<table border="0">'
                + N'<tr>        
     <th>Run this to exclude drives from report:</th>                
</tr>'
                + CAST(( SELECT td = 'EXEC Setup.DiskSpaceException ' + ''''
                                + ServerName + '''' + ', ' + '''' + DriveName
                                + '''' ,
                                ''
                         FROM   #Final
                         ORDER BY ServerName ,
                                DriveName
                       FOR
                         XML PATH('tr') ,
                             TYPE
                       ) AS NVARCHAR(MAX)) + N'</table>';       

            SET @tableHTML = @tableHTML + @ExcludeSQL;

        END


    DECLARE @DeferSQL NVARCHAR(MAX);
    IF @IncludeDefer = 1 
        BEGIN

            SET @DeferSQL = N'<H2>Defer SQL</H2>' + N'<table border="0">'
                + N'<tr>        
     <th>Run this to defer drives from report:</th>                
</tr>'
                + CAST(( SELECT td = 'EXEC Setup.DiskSpaceDefer ' + ''''
                                + ServerName + '''' + ', ' + '''' + DriveName
                                + ''', ' ,
                                '''' + CONVERT(VARCHAR(15), GETDATE(), 101)
                                + '''' + ', ' + ''''
                                + CONVERT(VARCHAR(15), GETDATE(), 101)
                                + ''', ' + '''06:00'''
                         FROM   #Final
                         ORDER BY ServerName ,
                                DriveName
                       FOR
                         XML PATH('tr') ,
                             TYPE
                       ) AS NVARCHAR(MAX)) + N'</table>';       

            SET @tableHTML = @tableHTML + @DeferSQL;

        END
 
       
    SET @tableHTML = @tableHTML
        + '<BR><BR><BR> ***This is an automated report.  Do not reply.***';                

             
 --Send email only if there's something to report.                
    IF @count >= 1      
 /*Left join ServerAppRoleApp b (nolock)        
 on a.InstanceID = b.InstanceID        
 Left join Application c(nolock)        
 on b.AppID  = c.AppID      
  where  [SpaceFreeIn%] <= AlertThreshold) > 0   */
       
--SELECT  COUNT(*) 
-- FROM #Final  a(nolock)        
-- Left join ServerAppRoleApp b (nolock)        
-- on a.InstanceID = b.InstanceID        
-- Left join Application c(nolock)        
-- on b.AppID  = c.AppID        
--  where  a.[SpaceFreeIn%] <= a.AlertThreshold       
        BEGIN         
                
            EXEC msdb.dbo.sp_send_dbmail @profile_name = @EmailProfile,
                @recipients = @Distro, -- 'mmccown@medassets.com', --              
                @subject = @CurrentSubject, @body = @tableHTML,
                @body_format = 'HTML';                
        END                
    RETURN





;
GO
/****** Object:  StoredProcedure [Collector].[spDiskTest]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[spDiskTest] 
(@EmailProfile varchar(1024), @ServiceLevel varchar(10), @DefaultThreshold int=10)       

              
as                 
Begin                
      
--------------------------------------------------------------------
DECLARE @Distro varchar(4000)
--DECLARE @ServiceLevel VARCHAR(10),
--		@DefaultThreshold TINYINT
		
--SET @ServiceLevel = 'Gold'
--SET @DefaultThreshold = 15
----Get master list of servers and disks.
SELECT DISTINCT
        s.InstanceID ,
        s.ServerName ,
        DriveLetterWithLabel = CASE WHEN LEN(Label) > 0
                                    THEN a.Name + Label
                                    ELSE a.Name
                               END ,
        [%Free] AS [SpaceFreeIn%] ,
        CONVERT(DECIMAL(9, 3), FreeSpace / 1024. / 1024. / 1024.) AS [FreeInGB] ,
        a.ExecutionDateTime ,
        s.ServiceLevel AS ServiceLevel
        
INTO #ServerList        
FROM    Collector.DriveSpace a ( NOLOCK )
        INNER JOIN dbo.Servers s ( NOLOCK ) ON a.InstanceID = s.InstanceID
        LEFT JOIN ServerAppRoleApp b ( NOLOCK ) ON a.InstanceID = b.InstanceID
        LEFT JOIN Application c ( NOLOCK ) ON b.AppID = c.AppID
        INNER JOIN ( SELECT InstanceID ,
                            MAX(ExecutionDateTime) AS ExecutionDateTime
                     FROM   Collector.DriveSpace  (NOLOCK)
                     GROUP BY InstanceID
                   ) AS RecentDate ON a.InstanceID = RecentDate.InstanceID
                                      AND a.ExecutionDateTime = RecentDate.ExecutionDateTime
WHERE   s.IsSQL = 1
        AND s.DiskManaged = 1
        AND s.ServiceLevel IS NOT NULL
        
-----Delete ServiceLevels you don't need.
DELETE #ServerList
WHERE ServiceLevel <> @ServiceLevel
        
        
-----Delete disk exceptions on a per server basis.
DELETE SL 
FROM #ServerList SL
INNER JOIN Collector.DriveSpaceExceptions DE
ON (SL.InstanceID = DE.InstanceID AND SL.DriveLetterWithLabel = DE.Caption + DE.Label)      
      

-----Create new #Table with the thresholds.  
-----!!!!!The most important thing here is that the cols in the ON condition are equal.  
-----!!!!!This could be the reason some drives don't get reported correctly.        
SELECT SL.*, DE.AlertThreshold  
INTO #Final
FROM #ServerList SL
left JOIN Collector.DriveSpaceThresholds DE
ON (SL.InstanceID = DE.InstanceID AND SL.DriveLetterWithLabel = DE.Caption + DE.Label)  
-----Test individual server.    
--WHERE InstanceID = 20

-----We're done with this table now.
DROP TABLE #ServerList
-----Set AlertThreshold to default where it's NULL.
UPDATE #Final
SET AlertThreshold = @DefaultThreshold
WHERE AlertThreshold IS NULL

--SELECT * FROM #Final
   

--------------------------------------------------------------------


 select @Distro =''    
 select @Distro=@Distro+EmailAddress+'; ' from  dbo.EmailNotification  a   
 order by EmailAddress   
 --select @Distro = left(@Distro, len(@Distro)-1)    
 print @Distro      
            
                  
 DECLARE @CurrentSubject varchar(100)                
 set @CurrentSubject = 'TEST: Drive Free Space (' + @ServiceLevel + ') with the Threshold '+ convert(varchar(10),@DefaultThreshold)  +'%'        
 select @CurrentSubject                
                
 --Generate email string                
 DECLARE @tableHTML  NVARCHAR(MAX) ;                
 SET @tableHTML =                
 N'<H2>'+@CurrentSubject +'</H2>' +                
 N'<table border="1">' +                
    N'<tr>        
     <th>ServerName</th>                
     <th>DriveLetterWithLabel</th>        
     <th>SpaceFreeIn%</th>                
     <th>FreeInGB</th>           
     <th>ApplicationName</th></tr>' +         
                    
 CAST ( ( SELECT           
   td = ServerName, '',              
  td = DriveLetterWithLabel, '',                
  td = [SpaceFreeIn%], '',                
  td = FreeInGB, '',                
  td = isnull(c.AppName, 'unknown'), ''        
   from         
  #Final  a(nolock)        
 Left join ServerAppRoleApp b (nolock)        
 on a.InstanceID = b.InstanceID        
 Left join Application c(nolock)        
 on b.AppID  = c.AppID        
  where  a.[SpaceFreeIn%] <= a.AlertThreshold       
 order by c.AppName, a.ServerName, a.DriveLetterWithLabel,a.[SpaceFreeIn%]        
         
                   
 FOR XML PATH('tr'), TYPE                 
 ) AS NVARCHAR(MAX) ) +                
 N'</table>' ;                
 set @tableHTML =@tableHTML+'<BR>'                
 set @tableHTML =@tableHTML+'***Please do NOT reply to the sender; Automated Report***'                
 PRINT @tableHTML                
 --Email out to the distro..                
 IF  ( SELECT  COUNT(*) FROM #Final)  >0        
         
         
 print @Distro    
                
 EXEC msdb.dbo.sp_send_dbmail                  
     @profile_name = @EmailProfile,                              
     @recipients = @Distro,                
     @subject = @CurrentSubject,                
     @body = @tableHTML,                
     @body_format = 'HTML';                
end                
return 





;
GO
/****** Object:  StoredProcedure [Collector].[spDBGrowthProjection]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collector].[spDBGrowthProjection]
(
		 @BeginDate DateTime, 
		 @EndDate DateTime,
		 @ProjTime int
)

   
AS

--Collector.spDBGrowthProjection '1/1/2011', '5/30/2012', 6
/*
This sp calculates a linear data growth for DBs.  If you require a compound or geometric growth then just alter the equation to suit your needs.
The date params passed into this are the sample rate you want to take to base your projections on.  So if you pass in 1/1/2008 and 7/1/2008
then those are the collection ranges the sp will use to calculate your average growth rates.  The @ProjTime param is how far out you want to 
project the growth.  So if you want to project out 6mos, then pass in a 6.  The sp automatically doubles it and gives you an extended projection as well.
So if you pass in a 6, then you'll automatically get a space projection for 6mos and 12 mos.  This too can be changed in the final query.

So far this sp just takes your initial date and your final date and does a diff between them.  It's not concerned with what happens in between.
This method, like many others becomes more accurate with more data you use to calculate the average.  
*/

SET NOCOUNT ON


			
DECLARE @currInstanceiD int,
		@currDBName nvarchar(200)

					SELECT 
					 InstanceID, DBName,
					 ExecutionDateTime 
					, SUM(SpaceUsed) as SpaceUsedinKB 
					, SUM(DataSpaceUsed) as DataSpaceUsedinKB 
					
					INTO #Work
					
					FROM dbo.DBSpaceForCube
					WHERE 
					ExecutionDateTime Between @BeginDate AND @EndDate
					group by InstanceID, ExecutionDateTime, DBName
					Order by InstanceID ASC, DBName ASC, ExecutionDateTime

					Create clustered index clust1 on #Work(InstanceID, DBName, ExecutionDateTime)
--Select * from #Work

-----Get SpaceUsed for first month from #Work.  This couldn't be done before because of grouping.
select instanceid, dbname, min(ExecutionDateTime) as ExecutionDateTime
INTO #First
from #Work Group by InstanceID, DBName
order by Instanceid, dbname
--select * from #First

-----Get SpaceUsed from #Work.  This couldn't be done before because of grouping.
select instanceid, dbname, max(ExecutionDateTime) as ExecutionDateTime
INTO #Last
from #Work Group by InstanceID, DBName
order by Instanceid, dbname
--select * from #Last

select f.*, w.SpaceUsedinKB
INTO #FirstFinal
from #First f
inner join #Work w
ON (w.ExecutionDateTime = f.ExecutionDateTime AND f.instanceid = w.instanceid and f.dbname = w.dbname)
--select * from #FirstFinal

select L.*, w.SpaceUsedinKB
INTO #LastFinal
from #Last L
inner join #Work w
ON (w.ExecutionDateTime = L.ExecutionDateTime AND L.instanceid = w.instanceid and L.dbname = w.dbname)

select F.InstanceID, F.DBName, F.ExecutionDateTime AS FirstDate, 
L.ExecutionDateTime AS LastDate, 
F.SpaceUsedinKB AS BeginSpace,
L.SpaceUsedinKB AS EndSpace, 
DateDiff(m, F.ExecutionDateTime, L.ExecutionDateTime) AS [Time] 
INTO #Space
from #FirstFinal F
INNER JOIN #LastFinal L
ON (L.instanceid = F.instanceid and L.dbname = F.dbname) 

--Select * from #Space

-----Get rid of all the unused tables.
drop table #First
drop table #FirstFinal
drop table #Last
drop table #LastFinal
drop table #Work


----Some of the DBs don't really have enough collection to have a full time period.  So in order to keep from having
----a divide by 0 error, set them to 1 here and use the current size as the projection.  It won't be accurate but it won't fail either.
----And since the report should show how long the period is for, then you'll be able to look at it and make a decision.
UPDATE #Space
SET [Time] = 1
WHERE [Time] < 1

Select InstanceID, DBName
, FirstDate
, LastDate
, [Time]
, BeginSpace
, EndSpace,
CASE WHEN (EndSpace-BeginSpace)/[Time] = 0 THEN 1 --Again, don't allow divide by 0.
	 ELSE (EndSpace-BeginSpace)/[Time]
END
 AS MonthlyDeltaInKB
INTO #SpaceFinal
From #Space

--SELECT * FROM #SpaceFinal
drop table #Space

Select S.ServerName, DBName 
, Convert(varchar(20),FirstDate, 101) AS FirstDate
, Convert(varchar(20), LastDate, 101) AS LastDate
, [Time] AS Months
, BeginSpace AS BeginSpaceInKB
, EndSpace AS EndSpaceInKB


, MonthlyDeltaInKB
--- Amount the DB will actually grow for the defined periods.
, MonthlyDeltaInKB * @ProjTime AS InitialGrowthInKB
, MonthlyDeltaInKB * (@ProjTime * 2) AS ExtendedGrowthInKB

, (MonthlyDeltaInKB * @ProjTime)/1024 AS InitialGrowthInMB
, (MonthlyDeltaInKB * (@ProjTime * 2))/1024 AS ExtendedGrowthInMB

, (MonthlyDeltaInKB * @ProjTime)/1024/1024 AS InitialGrowthInGB
, (MonthlyDeltaInKB * (@ProjTime * 2))/1024/1024 AS ExtendedGrowthInGB

---The projected final size of the DB in various conversions.
, EndSpace + (MonthlyDeltaInKB * @ProjTime) AS InitialProjectionInKB
, EndSpace + (MonthlyDeltaInKB * (@ProjTime * 2)) AS ExtendedProjectionInKB

, (EndSpace + (MonthlyDeltaInKB * @ProjTime))/1024 AS InitialProjectionInMB
, (EndSpace + (MonthlyDeltaInKB * (@ProjTime * 2)))/1024 AS ExtendedProjectionInMB

, (EndSpace + (MonthlyDeltaInKB * @ProjTime))/1024/1024 AS InitialProjectionInGB
, (EndSpace + (MonthlyDeltaInKB * (@ProjTime * 2)))/1024/1024 AS ExtendedProjectionInGB

From #SpaceFinal SF
INNER JOIN dbo.Servers S
ON SF.InstanceID = S.InstanceID
ORDER BY S.ServerName, SF.DBName
--drop table #SpaceFinal



;
GO
/****** Object:  StoredProcedure [dbo].[spAppInsert]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spAppInsert] --'Data Mart', 'SQL Server', 41
(
@AppName varchar(100),
@AppRoleName varchar(100),
@InstanceID int
)

  
AS

Set Nocount ON

Declare @NewAppID int,
		@NewAppRoleID int


-- Create new Application ID if it doesnt exist.
IF NOT EXISTS (Select AppName from dbo.Application where AppName = @AppName)
	BEGIN
		Insert dbo.Application(AppName)
		Select @AppName
		Set @NewAppID = Scope_identity()
	END
-- Get AppID that matches the one passed in if it already exists.
ELSE
	BEGIN
		Set @NewAppID = (Select AppID from dbo.Application where AppName = @AppName)
	END


--Create new Application Role if it doesnt exist.
IF NOT EXISTS (Select AppRoleName from dbo.ApplicationRole where AppRoleName = @AppRoleName)
	BEGIN
		Insert dbo.ApplicationRole
		Select @AppRoleName
		Set @NewAppRoleID = Scope_identity()
	END

--Get AppRoleID that matches the one passed in if it already exists.
ELSE
	BEGIN
		Set @NewAppRoleID = (Select AppRoleID from dbo.ApplicationRole where AppRoleName = @AppRoleName)		
	END


--Finally, insert the record into the lookup table.  This is what associates the app with the server.

IF NOT EXISTS (Select InstanceID, AppID, AppRoleID from dbo.ServerAppRoleApp 
				where (InstanceID = @InstanceID AND AppID = @NewAppID AND AppRoleID = @NewAppRoleID))

	BEGIN
		Insert dbo.ServerAppRoleApp
		Select @InstanceID, @NewAppID, @NewAppRoleID
	END




;
GO
/****** Object:  StoredProcedure [Setup].[ServerToApplication]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Setup].[ServerToApplication]
(
@ServerName varchar(100),
@AppName varchar(255),
@AppRole varchar(100),
@AppEnv varchar(100) 
)

  
AS

---Assigns a server to an app and gives it a role.


SET NOCOUNT ON

DECLARE @InstanceID int,
		@AppID int,
		@AppRoleID INT,
		@AppEnvID INT,
		@Error bit


SET @InstanceID = (SELECT InstanceID FROM dbo.Servers
WHERE ServerName = @ServerName)

SET @AppID = (SELECT AppID FROM dbo.APPLICATION 
WHERE AppName = @AppName)

SET @AppRoleID = (SELECT AppRoleID FROM dbo.ApplicationRole
WHERE AppRoleName = @AppRole)

---------------------------------------------
---I thought about putting a like query here so you can just guess at a portion
---of the Environment name, but there could be many environments with the same
---patterns in them and a server could get mis-classified.
---For example, if you wanted to call this SP with the AppEnv of 'Dev'.
---There could be more than 1 environment with those letters in it and it's
---impossible to guess which one the server would get.  Not to mention that
---it would return more than 1 row and fail the stmt below.
---So the user will have to lookup in the ApplicationEnvironment table the exact
---name of the environment he wants to put the server into and call the SP
---with that.
SET @AppEnvID = (SELECT AppEnvID FROM dbo.ApplicationEnvironment
WHERE AppEnvName = @AppEnv)
---------------------------------------------

----Assign server to the app.
BEGIN TRY
INSERT [dbo].[ServerAppRoleApp]
SELECT @InstanceID, @AppID, @AppRoleID
END TRY
BEGIN CATCH
SET @Error = 1
SELECT 'App assignment already exists.  It will not be duplicated.'
END CATCH


----Put the server into an environment (prod, dev, etc).
BEGIN TRY
INSERT dbo.ServerApplicationEnvironmentXRef
SELECT @InstanceID, @AppID, @AppEnvID
END TRY
BEGIN CATCH
SET @Error = 1
SELECT 'Server is already in app and environment.  It will not be duplicated.'
END CATCH	

IF @Error = 0
BEGIN
SELECT 'Inserted', @InstanceID, @AppID, @AppRoleID, @AppEnvID
END



;
GO
/****** Object:  StoredProcedure [Report].[ServerListByAppGet]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[ServerListByAppGet]
(
@AppID int
)

  
AS

SELECT DISTINCT S.ServerName, S.InstanceID 
FROM dbo.Servers S
INNER JOIN dbo.ServerAppRoleApp SA
ON S.InstanceID = SA.InstanceID
INNER JOIN dbo.Application A
ON SA.AppID = A.AppID
WHERE A.appID = @AppID
ORDER BY ServerName asc



;
GO
/****** Object:  StoredProcedure [Report].[ReplLatencyPublServers]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Report].[ReplLatencyPublServers]

  
AS


SELECT DISTINCT dbo.ServerName(InstanceID) as PublServer 
from dbo.ReplPublisher
ORDER BY dbo.ServerName(InstanceID)



;
GO
/****** Object:  StoredProcedure [Report].[ReplLatencyPubls]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Report].[ReplLatencyPubls]
(
@PublServerName sysname
)

  
AS

Select 'All' as PublName
Union
SELECT PublName 
from dbo.ReplPublisher
where dbo.ServerName(InstanceID) = @PublServerName
ORDER BY PublName


;
GO
/****** Object:  StoredProcedure [Report].[ReplLatencyPublDBs]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Report].[ReplLatencyPublDBs]
(
@PublServerName sysname,
@PublName sysname
)

  
AS

If @PublName = 'All'
Begin

SELECT 'All' as DBName
UNION
SELECT DISTINCT DBName as DBName
from dbo.ReplPublisher
WHERE dbo.ServerName(InstanceID) = @PublServerName
ORDER BY DBName

End

If @PublName <> 'All'
Begin

SELECT DISTINCT DBName as PublDB
from dbo.ReplPublisher
WHERE dbo.ServerName(InstanceID) = @PublServerName
AND   PublName = @PublName
ORDER BY DBName

End


;
GO
/****** Object:  StoredProcedure [Alert].[ReplLatency]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--   EXEC [Alert].[ReplLatency] @EmailProfile='ReplProfile', @DefaultThreshold=500, @IncludeDefer = 1, @IncludeException = 1, @IncludeChange = 1

CREATE procedure [Alert].[ReplLatency] 
(
@EmailProfile varchar(1024),
 --@ServiceLevel varchar(10), 
 @DefaultThreshold int,
 @IncludeDefer bit,
 @IncludeException bit,
 @IncludeChange bit
)   

                  
as                            
 
--  EXEC [Alert].[ReplLatency] @EmailProfile='ReplProfile', @DefaultThreshold=500, @IncludeDefer = 1, @IncludeException = 1, @IncludeChange = 1
      
--------------------------------------------------------------------
DECLARE @Distro varchar(4000)

----Get master list of servers and disks.


SELECT DISTINCT
--RecentDate.*,
		a.ExecutionDateTime,
        s.[InstanceID] ,
        s.ServerName ,
		RP.DBName,
		RP.PublName,
		a.SubrServerID,
		a.SubrDB,
		a.DistLatency,
		a.SubrLatency,
		a.TotalLatency,

		RP.SyncMethod,
		RP.AlertMethod,
		RP.AlertValue --1 as AlertValue--
		
        
INTO #ServerList        
FROM    Collector.ReplLatency a ( NOLOCK )
		INNER JOIN dbo.ReplPublisher RP ON a.PublServerID = RP.InstanceID AND a.PublDB = RP.DBName AND a.PublName = RP.PublName
        INNER JOIN dbo.Servers s ( NOLOCK ) ON a.PublServerID = s.[InstanceID]
        LEFT JOIN ServerAppRoleApp b ( NOLOCK ) ON a.PublServerID = b.InstanceID
        LEFT JOIN Application c ( NOLOCK ) ON b.AppID = c.AppID
        INNER JOIN ( SELECT PublServerID, PublDB, PublName,
                            MAX(ExecutionDateTime) AS ExecutionDateTime
                     FROM   Collector.ReplLatency  (NOLOCK)
                     GROUP BY PublServerID, PublDB, PublName
                   ) AS RecentDate ON 
									  a.ExecutionDateTime = RecentDate.ExecutionDateTime
									  AND a.PublServerID = RecentDate.PublServerID
                                      AND a.PublDB = RecentDate.PublDB
									  AND a.PublName = RecentDate.PublName
WHERE  
RP.SendAlert = 1
Order by InstanceID, DBName, PublName


--select 'ServerList' as ServerList, * from #ServerList
-- s.IsSQL = 1
--		AND s.IsActive = 1
--        AND s.DiskManaged = 1
--        AND s.ServiceLevel IS NOT NULL
        
-----Delete ServiceLevels you don't need.

--DELETE #ServerList
--WHERE ServiceLevel <> @ServiceLevel
       

----Put values into #Final table.
----Currently this isn't being used really, but this needs to go into the #Final table to match what all the other alerts do.
----This will come in handy later when we modify the report and we need extra steps.

select * 
INTO #Final
FROM #ServerList
 

--select 'Final', * from #Final

 -----We're done with this table now.
DROP TABLE #ServerList

--Get rid of NULL values.  Perhaps in the future this can be avoided, but for now it should only get the ones that haven't had a chance to return any
--token info yet.  With any luck this would only be the last collection.
DELETE FROM  #Final
WHERE TotalLatency IS NULL

-----Set AlertThreshold to default where it's NULL.  This is the default passed into the SP.  The default is always 'Secs'.
UPDATE #Final
SET 
AlertMethod = 'Secs',
AlertValue = @DefaultThreshold
WHERE AlertValue IS NULL



----Update TotalLatency if DistLatency is NULL.  If it's NULL that means the token hasn't made its way to the dist yet so it could be stuck on the publ side.
----If this is the case then we'll compare the insert datetime with the current datetime and use that value instead.  This allows us to get the value on 
----a scenario that is stuck and won't progress.


--UPDATE #Final
--SET 
--DistLatency = 0,
--TotalLatency = DATEDIFF(ss, ExecutionDatetime, GETDATE())
--WHERE DistLatency IS NULL

----select 'Dist' as Dist, * from #Final
------Now do the same for SubrLatency.  If the token has made it to the dist but is hung at the subr then compare the SubrLatency datetime with getdate() to find out how long it's been.
--UPDATE #Final
--SET 
--SubrLatency = TotalLatency,
--TotalLatency = (DATEDIFF(ss, ExecutionDatetime, GETDATE())) + DistLatency
--WHERE SubrLatency IS NULL
--	  AND DistLatency IS NOT NULL

--select 'Subr' as Dist, * from #Final


DELETE F
FROM #Final F
INNER JOIN Alert.ReplLatencyDefer B
ON 
(F.InstanceID = B.PublServerID AND F.DBName = B.PublDBName
 AND F.PublName = B.PublName AND F.SubrServerID = B.SubrServerID AND F.SubrDB = B.SubrDBName) 
WHERE CAST(GETDATE() AS DATE) < B.DeferEndDate


-----Make sure all the values in the AlertValue are the same measure as the FreeSpace col.
-----Convert them all to byte to make the comparison below really easy.

--UPDATE #Final
--SET AlertValue =
--				CASE 
--					WHEN AlertMethod = 'GB'THEN (AlertValue*1024.0*102.04*1024.0)
--					WHEN AlertMethod = 'MB'THEN (AlertValue*1024.0*1024.0)
--					WHEN AlertMethod = 'KB'THEN (AlertValue*1024.0)
--					END
--WHERE AlertMethod <> 'Percent'

--select 'Drive Exceptions', * from #Final

-----Delete percent drives that don't belong in the report.
DELETE F
FROM #Final F
where  f.[TotalLatency] < f.AlertValue
AND f.AlertMethod = 'Secs'

   
--DELETE from #Final
--WHERE SubrServerID IS NULL
-----Delete size drives that don't belong in the report.
--DELETE F
--FROM #Final F
--where  f.[FreeSpace] >= f.AlertValue
--AND f.AlertMethod <> 'Percent'
--------------------------------------------------------------------
-----Convert values back for the report. This way users see the value that is set as the threshold value.

 

--UPDATE #Final
--SET AlertValue =
--				CASE 
--					WHEN AlertMethod = 'GB'THEN (AlertValue/1024.0/1024.0/1024.0)
--					WHEN AlertMethod = 'MB'THEN (AlertValue/1024.0/1024.0)
--					WHEN AlertMethod = 'KB'THEN (AlertValue/1024.0)
--					END,
--	FreeSpace =
--				CASE 
--					WHEN AlertMethod = 'GB'THEN (FreeSpace/1024.0/1024.0/1024.0)
--					WHEN AlertMethod = 'MB'THEN (FreeSpace/1024.0/1024.0)
--					WHEN AlertMethod = 'KB'THEN (FreeSpace/1024.0)
--					END
--WHERE AlertMethod <> 'Percent'


--select 'Final', * from #Final 
Set @Distro = ''
 --select @Distro ='sean@midnightdba.com'    
select @Distro = @Distro + EmailAddress + '; ' from  dbo.EmailNotification 
--order by EmailAddress 
 select @Distro = left(@Distro, len(@Distro)-1)    
 print @Distro      
select @Distro    
	
	          
 DECLARE @count int                 
 DECLARE @CurrentSubject varchar(1000)                
 select @count = COUNT(*) from #Final
 set @CurrentSubject = Cast(@count as varchar(50)) +' Repl Latency Issues' --(' + @ServiceLevel + ')'        
 --select @CurrentSubject  
          
              
 --Generate email string                
 DECLARE @tableHTML  NVARCHAR(MAX) ;                
 SET @tableHTML =                
 N'<H2>'+@CurrentSubject +'</H2>' +                
 N'<table border="1">' +                
    N'<tr>   
	 <th>ExecutionDateTime</th>
	 <th>ID</th>     
     <th>ServerName</th>                
     <th>DBName</th>        
     <th>PublName</th>                
     <th>SubrName</th>           
     <th>SubrDB</th>
     <th>DistLat</th>
     <th>SubrLat</th>
     <th>TotalLat</th>
     <th>ApplicationName</th>
     <th>AlertMethod</th>
	 <th>AlertValue</th></tr>' +    
	      
                    
 CAST ( ( SELECT  
  td = a.ExecutionDateTime, '',  
  td = a.InstanceID, '',        
  td = a.ServerName, '',              
  td = a.DBName, '',                
  td = a.PublName, '',                
  td = ISNULL(dbo.ServerName(a.SubrServerID), 'N/A'), '',
  td = ISNULL(a.SubrDB, 'N/A'), '', 
  td = a.DistLatency, '', 
  td = a.SubrLatency, '', 
  td = a.TotalLatency, '',
  td = isnull(c.AppName, 'unknown'), '' ,   
  td = a.AlertMethod, '',   
  td = a.AlertValue, ''              
       
   from         
  #Final  a with (nolock)        
 Left join dbo.ServerAppRoleApp b with (nolock)        
 on a.[InstanceID] = b.InstanceID        
 Left join dbo.Application c with (nolock)        
 on b.AppID  = c.AppID        
--  where  a.[SpaceFreeIn%] <= a.AlertThreshold       
 order by c.AppName, a.ServerName, a.DBName,a.PublName        
                     
 FOR XML PATH('tr'), TYPE                 
 ) AS NVARCHAR(MAX) ) +                
 N'</table>' ;                
 set @tableHTML =@tableHTML+'<BR>'          
 

--  DECLARE @ChangeSQL nvarchar(max)
-- If @IncludeChange = 1
-- Begin

--	SET @ChangeSQL = 
--	N'<H2>Change SQL</H2>' +                
-- N'<table border="0">' +                
--    N'<tr>        
--     <th>Run this to change the alert threshold:</th>                
--</tr>' +  

--CAST ( ( SELECT           
--   td = 'EXEC Setup.ReplLatencyThreshold ' + '''' 
--   + ServerName + '''' + ', ' + '''' 
--   + DBName + '''' + ', ' 
--   + '''' + PublName + '''' +  ', '
--   + CAST(SubrServerID AS varchar(10)) +  ', ' 
--   + '''' + SubrDB + '''' +  ', ' 
--   + '''' + SubrDB + '''' +  ', '
--   + AlertMethod + '''' + ', ' 
--   + CAST(AlertValue as varchar(15))       
--   from         
--  #Final         
--  order by ServerName, DBName, PublName                     
-- FOR XML PATH('tr'), TYPE                 
-- ) AS NVARCHAR(MAX) ) +                
-- N'</table>' ;       

--SET @tableHTML = @tableHTML + @ChangeSQL

-- END

-- ----------------------------------------------------------------------






-- DECLARE @ExcludeSQL nvarchar(max)
-- If @IncludeException = 1
-- Begin

--	SET @ExcludeSQL = 
--	N'<H2>Exclude SQL</H2>' +                
-- N'<table border="0">' +                
--    N'<tr>        
--     <th>Run this to exclude drives from report:</th>                
--</tr>' +  

--CAST ( ( SELECT           
--   td = 'EXEC Setup.DiskSpaceException ' + '''' + ServerName + '''' + ', ' + '''' + DriveName + '''', ''       
--   from         
--  #Final         
--  order by ServerName, DriveName                     
-- FOR XML PATH('tr'), TYPE                 
-- ) AS NVARCHAR(MAX) ) +                
-- N'</table>' ;       

--SET @tableHTML = @tableHTML + @ExcludeSQL

-- END


  DECLARE @DeferSQL nvarchar(max)
 If @IncludeDefer = 1
 Begin

	SET @DeferSQL = 
	N'<H2>Defer SQL</H2>' +                
 N'<table border="0">' +                
    N'<tr>        
     <th>Run this to defer the alert:</th>                
</tr>' +  

CAST ( ( SELECT           
   td = 'EXEC Setup.ReplLatencyDefer ' + '''' 
   + ServerName + '''' + ', ' + '''' 
   + DBName + '''' + ', ' 
   + '''' + PublName + '''' +  ', '
   + CAST(SubrServerID AS varchar(10)) +  ', ' 
   + '''' + SubrDB + '''' +  ', ' 
  -- + '''' + SubrDB + '''' +  ', '
   + '''' + CONVERT(varchar(15), GetDate(), 101) + '''' + ', ' 
   + '''' + CONVERT(varchar(15), GetDate(), 101) + ''', ' + '''06:00'''     
   from         
  #Final         
  order by ServerName, DBName, PublName                     
 FOR XML PATH('tr'), TYPE                 
 ) AS NVARCHAR(MAX) ) +                
 N'</table>' ;    

SET @tableHTML = @tableHTML + @DeferSQL

 END
 
       
-- set @tableHTML =@tableHTML+'<BR><BR><BR> ***This is an automated report.  Do not reply.***'                

             
-- --Send email only if there's something to report.                
-- IF  @count >= 1      
-- /*Left join ServerAppRoleApp b (nolock)        
-- on a.InstanceID = b.InstanceID        
-- Left join Application c(nolock)        
-- on b.AppID  = c.AppID      
--  where  [SpaceFreeIn%] <= AlertThreshold) > 0   */
       
----SELECT  COUNT(*) 
---- FROM #Final  a(nolock)        
---- Left join ServerAppRoleApp b (nolock)        
---- on a.InstanceID = b.InstanceID        
---- Left join Application c(nolock)        
---- on b.AppID  = c.AppID        
----  where  a.[SpaceFreeIn%] <= a.AlertThreshold       
    
If @count > 0
BEGIN         
                
 EXEC msdb.dbo.sp_send_dbmail                  
     @profile_name = @EmailProfile,                            
     @recipients = @Distro,             
     @subject = @CurrentSubject,                
     @body = @tableHTML,                
     @body_format = 'HTML';                
END                
return


;
GO
/****** Object:  StoredProcedure [Audit].[LoginPermAccessMethod]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Audit].[LoginPermAccessMethod]
(
@Acct varchar(100) = NULL,
@ServerName varchar(100) = NULL
)

   
AS

/*
This SP is used to see a user's access across all instances of SQL and how the access is granted.
You'll get a list of the Servers the user has a login on and the method that is used to grant it.
Here, the method is whether the access is granted through a SQL acct, or a Windows group.
If it's a Windows group then all the Windows groups that the user has access to the instance through will be listed.

This is an excellent way to tell:
1. How many servers the user has rights on.
2. If they're given rights via multiple methods.  i.e. Do they get perms from mult. AD groups, or a combination of SQL and AD?
3. Do they have AD and SQL accts on the same box?

To call this SP, use the username WITHOUT the domain.
Therefore to call this SP for MyDomain\SMcCown you would do this:
Audit.LoginPermAccessMethod 'sean'
*/
DECLARE @AcctFuzzy varchar(100);
SET @AcctFuzzy = '%' + @Acct;

If @Acct IS NULL AND @ServerName IS NULL
BEGIN
---All Servers and all Accts
select dbo.ServerName(InstanceID) as ServerName, Name 
from collector.Logins
UNION ALL
select dbo.ServerName(L.InstanceID) as ServerName, L.Name 
from collector.Logins L
INNER JOIN collector.ADGroupMember AM
ON L.Name = AM.GroupName
WHERE 
L.isntgroup = 1
ORDER BY ServerName

END

If @Acct IS NOT NULL and @ServerName IS NULL
BEGIN
---Single Acct on All Servers
select dbo.ServerName(InstanceID) as ServerName, Name 
from collector.Logins
where name like @AcctFuzzy
UNION ALL
select dbo.ServerName(L.InstanceID) as ServerName, L.Name 
from collector.Logins L
INNER JOIN collector.ADGroupMember AM
ON L.Name = AM.GroupName
WHERE 
L.isntgroup = 1
AND AM.GroupMember = @Acct
ORDER BY ServerName

END

If @Acct IS NOT NULL and @ServerName IS NOT NULL
BEGIN
---Single Acct on Single Server
select dbo.ServerName(InstanceID) as ServerName, Name 
from collector.Logins
where name like @AcctFuzzy
UNION ALL
select dbo.ServerName(L.InstanceID) as ServerName, L.Name 
from collector.Logins L
INNER JOIN collector.ADGroupMember AM
ON L.Name = AM.GroupName
AND dbo.ServerName(InstanceID) = @ServerName
WHERE 
L.isntgroup = 1
AND AM.GroupMember = @Acct
AND dbo.ServerName(InstanceID) = @ServerName
ORDER BY ServerName

END




;
GO
/****** Object:  StoredProcedure [Alert].[LoginPasswordStrength]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Alert].[LoginPasswordStrength]

   
AS

/*
This SP gets the login password strength to test agasint weak logins.
The Collector.Logins table must be populated.
The PassWordDictionary table should also be populated with password strings to test.
This is a simple dictionary attack so each password should also have the hash value in order to easily compare with the password
col in Collector.Logins.  

Minion comes with about 110,000 passwords to test against by default.  Some are common string passwords, but the bulk of them
are dates in different formats.  Minion comes with every date between 1/1/1900 and 12/31/2050.
This is to prevent anyone from using a birthdate as a password.  There are 2 date formats tested: yyyymmdd and ddmmyyyy.

You're free, and even encouraged to add your own passwords to the PasswordDictionary table.
In order to do so you must use the provided SP so that the hash also gets created.

This process uses a login on the Minion server called MinionLoginPasswordHash.  By default, this login is denied connect perms.
The sole purpose for this login is to hash the password value in order to put it in the table.
The hash SP just changes the password for this account and then puts the hash in the table.

If you don't use the provided SP for this then you must manually compare the hashes with PWDCOMPARE().  
There's nothing wrong with using that method except it can be extremely slow.

There are actually 2 checks done here and they're unioned together into a single result.
The first one we've already talked about... weak passwords out of the dictionary table.
The 2nd one is a test to make sure the password isn't the login name itself.

In any case, the password is returned with the username and the ServerName so you can fix any weak password issues.
You're also free to turn this SP into an SSRS report if you like.
Our advice though is that if you go that route, you secure the report from anyone not trusted as the report will contain clear text passwords
to your SQL environment.  So don't let just anyone see that report.
It's for this reason that Minion doesn't come with this report pre-defined.
*/

select dbo.ServerName(InstanceID) as ServerName, sid, name, PD.Pword
FROM Collector.Logins L
INNER JOIN dbo.PasswordDictionary PD
ON L.password = PD.PwordHash--PWDCOMPARE(PD.Pword, convert(varbinary(max), L.password)) = 1
WHERE L.password IS NOT NULL
UNION
select dbo.ServerName(InstanceID) as ServerName, sid, name, name as Pword
FROM Collector.Logins 
WHERE PWDCOMPARE(name, convert(varbinary(max), password)) = 1
;
GO
/****** Object:  StoredProcedure [Report].[DBNamesLatestGet]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[DBNamesLatestGet]
(
@InstanceID bigint
)
 
AS


SELECT '(All)' AS DBName
UNION
SELECT DISTINCT DBName 
FROM Collector.DBPropertiesCurrent 
WHERE InstanceID = @InstanceID
ORDER BY DBName;
;
GO
/****** Object:  StoredProcedure [Report].[DBGrowthChartDataGet]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[DBGrowthChartDataGet] 
(
@InstanceID bigint,
@DBName sysname,
@BeginDate DATE,
@EndDate DATE
)
 
AS 

IF @DBName = '(All)'
BEGIN
	SELECT ServerName, T.ExecDate, T.InstanceID, T.DBName, SUM(TotalSpaceUsedInMB) AS SumTotalSpaceUsedInMB, T.ExecutionDateTime
	FROM Collector.TableSizeForCube T
	WHERE InstanceID = @InstanceID
		AND T.ExecDate BETWEEN @BeginDate AND @EndDate
		AND T.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) FROM Collector.TableSizeForCube T2 WHERE T.ExecDate = T2.ExecDate AND T.InstanceID = T2.InstanceID)
				AND T.DBName IN (SELECT DISTINCT DBName 
								FROM Collector.DBPropertiesCurrent 
								WHERE InstanceID = @InstanceID AND DBName IS NOT NULL)
	GROUP BY ServerName, T.ExecDate, T.InstanceID, T.DBName, T.ExecutionDateTime
	ORDER BY T.ExecutionDateTime

END

IF @DBName <> '(All)'
BEGIN
	SELECT ServerName, T.ExecDate, T.InstanceID, T.DBName, SUM(TotalSpaceUsedInMB) AS SumTotalSpaceUsedInMB, T.ExecutionDateTime
	FROM Collector.TableSizeForCube T
	WHERE InstanceID = @InstanceID
		AND T.ExecDate BETWEEN @BeginDate AND @EndDate
		AND T.ExecutionDateTime = (SELECT MAX(ExecutionDateTime) FROM Collector.TableSizeForCube T2 WHERE T.ExecDate = T2.ExecDate AND T.InstanceID = T2.InstanceID)
			AND T.DBName = @DBName
	GROUP BY ServerName, T.ExecDate, T.InstanceID, T.DBName, T.ExecutionDateTime
	ORDER BY T.ExecutionDateTime
END

;
GO
/****** Object:  StoredProcedure [Servers].[BySLA]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Servers].[BySLA]
(
    @SLA VARCHAR(100)
	)
	 
AS

SELECT DISTINCT
s.InstanceID,
ar.AppRoleName AS ServerRole ,
ae.AppEnvName AS Environment ,
a.AppName ,
ar.AppRoleName,
a.[ContactName],
a.[DirectorName],
a.[ManagerName],
s.LocID,
s.ServerName,
s.DNS,
s.IP,
s.Port,
s.Descr,
s.Role,
s.ServiceLevel,
s.IsSQL,
s.SQLVersion,
s.SQLEdition,
s.SQLServicePack,
s.SQLBuild,
s.IsCluster,
s.IsNew,
s.BackupManaged,
s.BackupProduct,
s.BackupDefaultLoc,
s.DiskManaged,
s.IsServiceManaged,
s.SPConfigManaged,
s.IsActive,
s.IsActiveDate,
s.InstanceMemInMB,
s.OSVersion,
s.OSServicePack,
s.OSBuild,
s.OSArchitecture,
s.CPUSockets,
s.CPUCores,
s.CPULogicalTotal,
s.ServerMemInMB,
s.Manufacturer,
s.ServerModel
FROM    dbo.Servers s
        INNER JOIN dbo.ServerAppRoleApp sa ON s.InstanceID = sa.InstanceID
        INNER JOIN dbo.Application a ON a.AppID = sa.AppID
        INNER JOIN dbo.ApplicationRole ar ON sa.AppRoleID = ar.AppRoleID
        LEFT OUTER JOIN dbo.ServerApplicationEnvironmentXRef sax ON s.InstanceID = sax.InstanceID
                        AND a.AppID = sax.AppID
        LEFT OUTER JOIN dbo.ApplicationEnvironment ae ON sax.AppEnvID = ae.AppEnvID
WHERE   s.ServiceLevel = @SLA
ORDER BY s.ServerName;

;
GO
/****** Object:  StoredProcedure [Servers].[ByName]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Servers].[ByName]
(
@ServerName VARCHAR(100),
@Fuzzy BIT = 0 -- Allows for a fuzzy lookup if you don't know the entire servername.
)
 
AS

/*

This SP does a server search by name.  You can either search for an entire name or on a partial name.
It first searches the Servers table, and if nothing is there, it searches the ClusterNodes table.
That's because the server could be a cluster VI or a node, or a freestanding box.  So you have to look
in both locations for a complete search.
Servers.ByName 'Server1'


The @Fuzzy param turns on the partial name search.
Servers.ByName 'scm', 1
There's no need to supply a % in the param.  The fuzzy query fills it in for you.

*/




DECLARE @rowcount tinyint,
		@IsClustered BIT,
		@InstanceID INT
		
	
IF @Fuzzy = 1
BEGIN
DECLARE @SQL VARCHAR(200)

SET @SQL = 'select * from dbo.Servers where servername like ''%' + @ServerName + '%'''
EXEC (@SQL)
RETURN 
end	
		
--See if the server is in the Servers table and count the rows that are returned.
--If none, then it'll look in the ClusterNode table.		
SET @rowcount = (SELECT COUNT(*) FROM dbo.Servers
WHERE ServerName = @ServerName)


----If the server is in the main servers table, return that data along with the cluster nodes if there are any.
IF @rowcount > 0

BEGIN

--SELECT * FROM dbo.Servers
SELECT 
s.InstanceID,
ar.AppRoleName AS ServerRole ,
ae.AppEnvName AS Environment ,
a.AppName ,
ar.AppRoleName,
a.[ContactName],
a.[DirectorName],
a.[ManagerName],
s.LocID,
s.ServerName,
s.DNS,
s.IP,
s.Port,
s.Descr,
s.Role,
s.ServiceLevel,
s.IsSQL,
s.SQLVersion,
s.SQLEdition,
s.SQLServicePack,
s.SQLBuild,
s.IsCluster,
s.IsNew,
s.BackupManaged,
s.BackupProduct,
s.BackupDefaultLoc,
s.DiskManaged,
s.IsServiceManaged,
s.SPConfigManaged,
s.IsActive,
s.IsActiveDate,
s.InstanceMemInMB,
s.OSVersion,
s.OSServicePack,
s.OSBuild,
s.OSArchitecture,
s.CPUSockets,
s.CPUCores,
s.CPULogicalTotal,
s.ServerMemInMB,
s.Manufacturer,
s.ServerModel
FROM    dbo.Servers s
        LEFT OUTER JOIN dbo.ServerAppRoleApp sa ON s.InstanceID = sa.InstanceID
        LEFT OUTER JOIN dbo.Application a ON a.AppID = sa.AppID
        LEFT OUTER JOIN dbo.ApplicationRole ar ON sa.AppRoleID = ar.AppRoleID
        LEFT OUTER JOIN dbo.ServerApplicationEnvironmentXRef sax ON s.InstanceID = sax.InstanceID
                                                    AND a.AppID = sax.AppID
        LEFT OUTER JOIN dbo.ApplicationEnvironment ae ON sax.AppEnvID = ae.AppEnvID
WHERE s.ServerName = @ServerName

		 SELECT @IsClustered = IsCluster ,
		 @InstanceID = InstanceID
		 FROM dbo.Servers
		WHERE ServerName = @ServerName

		IF @IsClustered = 1

				BEGIN --Return the cluster nodes too... it's the only human thing to do.
					SELECT * FROM dbo.ClusterNode
					WHERE InstanceID = @InstanceID

				END
END

-----If there's no row in the servers table, check the clusternodes table to see if it's a cluster node.
-----If so, then return the cluster node along with it's virtual server from the servers table.
IF @rowcount = 0

BEGIN
		
			
		 SELECT 
		 @InstanceID = InstanceID
		 FROM dbo.ClusterNode
		WHERE ServerName = @ServerName


		SELECT * FROM dbo.ClusterNode
			WHERE InstanceID = @InstanceID
			
			
			SELECT * FROM dbo.Servers
			WHERE InstanceID = @InstanceID

END






;
GO
/****** Object:  StoredProcedure [Servers].[ByID]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Servers].[ByID]
(
@InstanceID INT
)
 
AS

/*

This SP does a server search by ID.  
It first searches the Servers table, and if nothing is there, it searches the ClusterNodes table.
That's because the server could be a cluster VI or a node, or a freestanding box.  So you have to look
in both locations for a complete search.
Servers.ByID 273

*/




DECLARE @rowcount tinyint,
		@IsClustered BIT
		
	
		
--See if the server is in the Servers table and count the rows that are returned.
--If none, then it'll look in the ClusterNode table.		
SET @rowcount = (SELECT COUNT(*) FROM dbo.Servers
WHERE InstanceID = @InstanceID)


----If the server is in the main servers table, return that data along with the cluster nodes if there are any.
IF @rowcount > 0

BEGIN

SELECT 
s.InstanceID,
ar.AppRoleName AS ServerRole ,
ae.AppEnvName AS Environment ,
a.AppName ,
ar.AppRoleName,
a.[ContactName],
a.[DirectorName],
a.[ManagerName],
s.LocID,
s.ServerName,
s.DNS,
s.IP,
s.Port,
s.Descr,
s.Role,
s.ServiceLevel,
s.IsSQL,
s.SQLVersion,
s.SQLEdition,
s.SQLServicePack,
s.SQLBuild,
s.IsCluster,
s.IsNew,
s.BackupManaged,
s.BackupProduct,
s.BackupDefaultLoc,
s.DiskManaged,
s.IsServiceManaged,
s.SPConfigManaged,
s.IsActive,
s.IsActiveDate,
s.InstanceMemInMB,
s.OSVersion,
s.OSServicePack,
s.OSBuild,
s.OSArchitecture,
s.CPUSockets,
s.CPUCores,
s.CPULogicalTotal,
s.ServerMemInMB,
s.Manufacturer,
s.ServerModel
FROM    dbo.Servers s
        LEFT OUTER JOIN dbo.ServerAppRoleApp sa ON s.InstanceID = sa.InstanceID
        LEFT OUTER JOIN dbo.Application a ON a.AppID = sa.AppID
        LEFT OUTER JOIN dbo.ApplicationRole ar ON sa.AppRoleID = ar.AppRoleID
        LEFT OUTER JOIN dbo.ServerApplicationEnvironmentXRef sax ON s.InstanceID = sax.InstanceID
                                                    AND a.AppID = sax.AppID
        LEFT OUTER JOIN dbo.ApplicationEnvironment ae ON sax.AppEnvID = ae.AppEnvID
WHERE  s.InstanceID = @InstanceID

		 SELECT @IsClustered = IsCluster ,
		 @InstanceID = InstanceID
		 FROM dbo.Servers s
WHERE s.InstanceID = @InstanceID

--SELECT * FROM dbo.Servers
--WHERE InstanceID = @InstanceID

		 SELECT @IsClustered = IsCluster ,
		 @InstanceID = InstanceID
		 FROM dbo.Servers
		WHERE InstanceID = @InstanceID

		IF @IsClustered = 1

				BEGIN --Return the cluster nodes too... it's the only human thing to do.
					SELECT * FROM dbo.ClusterNode
					WHERE InstanceID = @InstanceID

				END
END

-----If there's no row in the servers table, check the clusternodes table to see if it's a cluster node.
-----If so, then return the cluster node along with it's virtual server from the servers table.
IF @rowcount = 0

BEGIN
		
			
		 SELECT 
		 @InstanceID = InstanceID
		 FROM dbo.ClusterNode
		WHERE ID = @InstanceID


		SELECT * FROM dbo.ClusterNode
			WHERE ID = @InstanceID
			
			
			SELECT * FROM dbo.Servers
			WHERE InstanceID = @InstanceID

END





;
GO
/****** Object:  StoredProcedure [Servers].[ByEnviro]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Servers].[ByEnviro]
(
    @Enviro VARCHAR(100)
	)
	 
AS

SELECT DISTINCT
s.InstanceID,
ar.AppRoleName AS ServerRole ,
ae.AppEnvName AS Environment ,
a.AppName ,
ar.AppRoleName,
a.[ContactName],
a.[DirectorName],
a.[ManagerName],
s.LocID,
s.ServerName,
s.DNS,
s.IP,
s.Port,
s.Descr,
s.Role,
s.ServiceLevel,
s.IsSQL,
s.SQLVersion,
s.SQLEdition,
s.SQLServicePack,
s.SQLBuild,
s.IsCluster,
s.IsNew,
s.BackupManaged,
s.BackupProduct,
s.BackupDefaultLoc,
s.DiskManaged,
s.IsServiceManaged,
s.SPConfigManaged,
s.IsActive,
s.IsActiveDate,
s.InstanceMemInMB,
s.OSVersion,
s.OSServicePack,
s.OSBuild,
s.OSArchitecture,
s.CPUSockets,
s.CPUCores,
s.CPULogicalTotal,
s.ServerMemInMB,
s.Manufacturer,
s.ServerModel
FROM    dbo.Servers s
        INNER JOIN dbo.ServerAppRoleApp sa ON s.InstanceID = sa.InstanceID
        INNER JOIN dbo.Application a ON a.AppID = sa.AppID
        INNER JOIN dbo.ApplicationRole ar ON sa.AppRoleID = ar.AppRoleID
        LEFT OUTER JOIN dbo.ServerApplicationEnvironmentXRef sax ON s.InstanceID = sax.InstanceID
                        AND a.AppID = sax.AppID
        LEFT OUTER JOIN dbo.ApplicationEnvironment ae ON sax.AppEnvID = ae.AppEnvID
WHERE   ae.AppEnvName = @Enviro
ORDER BY s.ServerName;

;
GO
/****** Object:  StoredProcedure [Servers].[ByApp]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Servers].[ByApp]
(
    @AppName VARCHAR(100) ,
    @Enviro VARCHAR(100) = 'All' ,
    @Role VARCHAR(100) = NULL
)
	 
AS
    DECLARE @AppID INT;  
  
	--Get the appId to be used in the rest of the queries.  
    SET @AppID = ( SELECT   AppID
                   FROM     dbo.Application
                   WHERE    AppName = @AppName
                 );  
  
------Get all boxes for an app.
    IF ( @Enviro = 'All'
         AND @Role IS NULL
       )
        BEGIN

            SELECT DISTINCT
                    ar.AppRoleName AS ServerRole ,
                    ae.AppEnvName AS Environment ,
                    a.AppName ,
                    s.InstanceID ,
                    s.ServerName ,
                    s.DNS ,
                    s.IP ,
                    s.Port ,
                    s.ServiceLevel ,
                    s.IsSQL ,
                    s.IsActive ,
                    s.IsCluster AS Cluster ,
                    s.SQLVersion ,
                    s.SQLEdition ,
                    s.SQLServicePack ,
                    s.SQLBuild ,
                    s.IsServiceManaged AS ServiceManaged ,
                    s.SPConfigManaged AS ConfigManaged ,
                    s.BackupManaged ,
                    s.DiskManaged ,
                    s.OSVersion ,
                    s.OSArchitecture ,
                    s.CPUSockets ,
                    s.CPUCores ,
                    s.CPULogicalTotal ,
                    s.InstanceMemInMB ,
                    s.ServerMemInMB ,
                    a.ContactName ,
                    a.ManagerName ,
                    a.DirectorName
            FROM    dbo.Servers s
                    INNER JOIN dbo.ServerAppRoleApp sa ON s.InstanceID = sa.InstanceID
                    INNER JOIN dbo.Application a ON a.AppID = sa.AppID
                    INNER JOIN dbo.ApplicationRole ar ON sa.AppRoleID = ar.AppRoleID
                    LEFT OUTER JOIN dbo.ServerApplicationEnvironmentXRef sax ON s.InstanceID = sax.InstanceID
                                                              AND a.AppID = sax.AppID
                    LEFT OUTER JOIN dbo.ApplicationEnvironment ae ON sax.AppEnvID = ae.AppEnvID
            WHERE   a.AppName = @AppName
            ORDER BY s.ServerName;

        END;

    IF ( @Enviro <> 'All'
         AND @Role IS NULL
       )

-----Get all boxes for a specific environment
        BEGIN

            SELECT DISTINCT
                    ar.AppRoleName AS ServerRole ,
                    ae.AppEnvName AS Environment ,
                    a.AppName ,
                    s.InstanceID ,
                    s.ServerName ,
                    s.DNS ,
                    s.IP ,
                    s.Port ,
                    s.ServiceLevel ,
                    s.IsSQL ,
                    s.IsActive ,
                    s.IsCluster AS Cluster ,
                    s.SQLVersion ,
                    s.SQLEdition ,
                    s.SQLServicePack ,
                    s.SQLBuild ,
                    s.IsServiceManaged AS ServiceManaged ,
                    s.SPConfigManaged AS ConfigManaged ,
                    s.BackupManaged ,
                    s.DiskManaged ,
                    s.OSVersion ,
                    s.OSArchitecture ,
                    s.CPUSockets ,
                    s.CPUCores ,
                    s.CPULogicalTotal ,
                    s.InstanceMemInMB ,
                    s.ServerMemInMB ,
                    a.ContactName ,
                    a.ManagerName ,
                    a.DirectorName
            FROM    dbo.Servers s
                    INNER JOIN dbo.ServerAppRoleApp sa ON s.InstanceID = sa.InstanceID
                    INNER JOIN dbo.Application a ON a.AppID = sa.AppID
                    INNER JOIN dbo.ApplicationRole ar ON sa.AppRoleID = ar.AppRoleID
                    LEFT OUTER JOIN dbo.ServerApplicationEnvironmentXRef sax ON s.InstanceID = sax.InstanceID
                                                              AND a.AppID = sax.AppID
                    LEFT OUTER JOIN dbo.ApplicationEnvironment ae ON sax.AppEnvID = ae.AppEnvID
            WHERE   a.AppName = @AppName
                    AND ae.AppEnvName = @Enviro
            ORDER BY s.ServerName;

        END;



    IF ( @Enviro = 'All'
         AND @Role IS NOT NULL
       )

-----Get a specific role for a all environment
        BEGIN

            SELECT DISTINCT
                    ar.AppRoleName AS ServerRole ,
                    ae.AppEnvName AS Environment ,
                    a.AppName ,
                    s.InstanceID ,
                    s.ServerName ,
                    s.DNS ,
                    s.IP ,
                    s.Port ,
                    s.ServiceLevel ,
                    s.IsSQL ,
                    s.IsActive ,
                    s.IsCluster AS Cluster ,
                    s.SQLVersion ,
                    s.SQLEdition ,
                    s.SQLServicePack ,
                    s.SQLBuild ,
                    s.IsServiceManaged AS ServiceManaged ,
                    s.SPConfigManaged AS ConfigManaged ,
                    s.BackupManaged ,
                    s.DiskManaged ,
                    s.OSVersion ,
                    s.OSArchitecture ,
                    s.CPUSockets ,
                    s.CPUCores ,
                    s.CPULogicalTotal ,
                    s.InstanceMemInMB ,
                    s.ServerMemInMB ,
                    a.ContactName ,
                    a.ManagerName ,
                    a.DirectorName
            FROM    dbo.Servers s
                    INNER JOIN dbo.ServerAppRoleApp sa ON s.InstanceID = sa.InstanceID
                    INNER JOIN dbo.Application a ON a.AppID = sa.AppID
                    INNER JOIN dbo.ApplicationRole ar ON sa.AppRoleID = ar.AppRoleID
                    LEFT OUTER JOIN dbo.ServerApplicationEnvironmentXRef sax ON s.InstanceID = sax.InstanceID
                                                              AND a.AppID = sax.AppID
                    LEFT OUTER JOIN dbo.ApplicationEnvironment ae ON sax.AppEnvID = ae.AppEnvID
            WHERE   a.AppName = @AppName
                    AND ar.AppRoleName = @Role
            ORDER BY s.ServerName;

        END;


    IF ( @Enviro <> 'All'
         AND @Role IS NOT NULL
       )

-----Get a specific role for a all environment
        BEGIN

            SELECT DISTINCT
                    ar.AppRoleName AS ServerRole ,
                    ae.AppEnvName AS Environment ,
                    a.AppName ,
                    s.InstanceID ,
                    s.ServerName ,
                    s.DNS ,
                    s.IP ,
                    s.Port ,
                    s.ServiceLevel ,
                    s.IsSQL ,
                    s.IsActive ,
                    s.IsCluster AS Cluster ,
                    s.SQLVersion ,
                    s.SQLEdition ,
                    s.SQLServicePack ,
                    s.SQLBuild ,
                    s.IsServiceManaged AS ServiceManaged ,
                    s.SPConfigManaged AS ConfigManaged ,
                    s.BackupManaged ,
                    s.DiskManaged ,
                    s.OSVersion ,
                    s.OSArchitecture ,
                    s.CPUSockets ,
                    s.CPUCores ,
                    s.CPULogicalTotal ,
                    s.InstanceMemInMB ,
                    s.ServerMemInMB ,
                    a.ContactName ,
                    a.ManagerName ,
                    a.DirectorName
            FROM    dbo.Servers s
                    INNER JOIN dbo.ServerAppRoleApp sa ON s.InstanceID = sa.InstanceID
                    INNER JOIN dbo.Application a ON a.AppID = sa.AppID
                    INNER JOIN dbo.ApplicationRole ar ON sa.AppRoleID = ar.AppRoleID
                    LEFT OUTER JOIN dbo.ServerApplicationEnvironmentXRef sax ON s.InstanceID = sax.InstanceID
                                                              AND a.AppID = sax.AppID
                    LEFT OUTER JOIN dbo.ApplicationEnvironment ae ON sax.AppEnvID = ae.AppEnvID
            WHERE   a.AppName = @AppName
                    AND ae.AppEnvName = @Enviro
                    AND ar.AppRoleName = @Role
            ORDER BY s.ServerName;

        END;





;
GO
/****** Object:  StoredProcedure [Report].[ADAcctsInSQLBySLA]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[ADAcctsInSQLBySLA] 
(
@SLA varchar(10)
)
 
AS

/*
This SP gets an expanded list of AD groups for a specific Server by ServerName.
If you have a Windows group as a login in SQL, you have no idea who's in there because
you can't see in the AD groups.  Now you can, and quite easily.

Just enter the InstanceID you're interested in and you'll get a full list of all the expanded AD groups.
To limit the resultset by any criteria, say by sysadmins, then use the manual script in
\ManualScripts\Logins\Report.ADAcctsInSQLByServerName.sql
*/

WITH    CTE
          AS ( SELECT  

AD.ExecutionDateTime,
L.InstanceID AS SQLAcctInstanceID,
AD.GroupName AS ADAcctGroupName,
AD.ObjectName AS ADAcctObjectName,
AD.IsGroup AS ADAcctIsGroup,
AD.GroupMember AS ADAcctGroupMember,
AD.LastLogon AS ADAcctLastLogon,
AD.BadLogonCount AS ADAcctBadLogonCount,
AD.PasswordNeverExpires AS ADAcctPasswordNeverExpires,
AD.PasswordNotRequired AS ADAcctPasswordNotRequired,
AD.PermittedLogonTimes AS ADAcctPermittedLogonTimes,
AD.PermittedWorkstations AS ADAcctPermittedWorkstations,
AD.LastPasswordSet AS ADAcctLastPasswordSet,
AD.LastBadPasswordAttempt AS ADAcctLastBadPasswordAttempt,
AD.UserCannotChangePassword AS ADAcctUserCannotChangePassword,
AD.Description AS ADAcctDescription,
AD.DelegationPermitted AS ADAcctDelegationPermitted,
AD.AccountExpirationDate AS ADAcctAccountExpirationDate,
AD.AccountLockoutTime AS ADAcctAccountLockoutTime,
AD.EmailAddress AS ADAcctEmailAddress,
AD.Enabled AS ADAcctEnabled,
AD.EmployeeID AS ADAcctEmployeeID,
AD.VoiceTelephoneNumber AS ADAcctVoiceTelephoneNumber,
AD.DistinguishedName AS ADAcctDistinguishedName,
AD.DisplayName AS ADAcctDisplayName,
AD.SurName AS ADAcctSurName,
AD.MiddleName AS ADAcctMiddleName,
AD.GivenName AS ADAcctGivenName,
AD.Name AS ADAcctName,
AD.GUID AS ADAcctGUID,
AD.SID AS ADAcctSID,
AD.SmartcardLogonRequired AS ADAcctSmartcardLogonRequired,
AD.HomeDirectory AS ADAcctHomeDirectory,
AD.HomeDrive AS ADAcctHomeDrive,
AD.AllowReversiblePasswordEncryption AS ADAcctAllowReversiblePasswordEncryption,

L.sid AS SQLAcctSID,
L.status AS SQLAcctstatus,
L.createdate AS SQLAcctcreatedate,
L.updatedate AS SQLAcctupdatedate,
L.accdate AS SQLAcctaccdate,
L.totcpu AS SQLAccttotcpu,
L.totio AS SQLAccttotio,
L.spacelimit AS SQLAcctspacelimit,
L.timelimit AS SQLAccttimelimit,
L.resultlimit AS SQLAcctresultlimit,
L.name AS SQLAcctname,
L.dbname AS SQLAcctdbname,
L.password AS SQLAcctpassword,
L.language AS SQLAcctlanguage,
L.denylogin AS SQLAcctdenylogin,
L.hasaccess AS SQLAccthasaccess,
L.isntname AS SQLAcctisntname,
L.isntgroup AS SQLAcctisntgroup,
L.isntuser AS SQLAcctisntuser,
L.sysadmin AS SQLAcctsysadmin,
L.securityadmin AS SQLAcctsecurityadmin,
L.serveradmin AS SQLAcctserveradmin,
L.setupadmin AS SQLAcctsetupadmin,
L.processadmin AS SQLAcctprocessadmin,
L.diskadmin AS SQLAcctdiskadmin,
L.dbcreator AS SQLAcctdbcreator,
L.bulkadmin AS SQLAcctbulkadmin,
L.loginname AS SQLAcctloginname,
L.BadPasswordCount AS SQLAcctBadPasswordCount,
L.BadPasswordTime AS SQLAcctBadPasswordTime,
L.HistoryLength AS SQLAcctHistoryLength,
L.PasswordLastSetTime AS SQLAcctPasswordLastSetTime,
L.PasswordHash AS SQLAcctPasswordHash,
L.LoginType AS SQLAcctLoginType,
L.DateLastModified AS SQLAcctDateLastModified,
L.IsDisabled AS SQLAcctIsDisabled,
L.IsLocked AS SQLAcctIsLocked,
L.IsPasswordExpired AS SQLAcctIsPasswordExpired,
L.IsSystemObject AS SQLAcctIsSystemObject,
L.LanguageAlias AS SQLAcctLanguageAlias,
L.MustChangePassword AS SQLAcctMustChangePassword,
L.PasswordExpirationEnabled AS SQLAcctPasswordExpirationEnabled,
L.PasswordPolicyEnforced AS SQLAcctPasswordPolicyEnforced,
L.State AS SQLAcctState,
L.WindowsLoginAccessType AS SQLAcctWindowsLoginAccessType,
L.DefaultDatabase AS SQLAcctDefaultDatabase
						
               FROM     Collector.ADGroupMemberCurrent AD
                        JOIN Collector.LoginsCurrent L ON AD.GroupName = L.name
                                         AND L.hasaccess = 1
                        JOIN dbo.Servers S ON S.InstanceID = L.InstanceID
                        WHERE S.ServiceLevel = @SLA
               UNION ALL
               SELECT  

AD.ExecutionDateTime,
L.InstanceID AS SQLAcctInstanceID,
AD.GroupName AS ADAcctGroupName,
AD.ObjectName AS ADAcctObjectName,
AD.IsGroup AS ADAcctIsGroup,
AD.GroupMember AS ADAcctGroupMember,
AD.LastLogon AS ADAcctLastLogon,
AD.BadLogonCount AS ADAcctBadLogonCount,
AD.PasswordNeverExpires AS ADAcctPasswordNeverExpires,
AD.PasswordNotRequired AS ADAcctPasswordNotRequired,
AD.PermittedLogonTimes AS ADAcctPermittedLogonTimes,
AD.PermittedWorkstations AS ADAcctPermittedWorkstations,
AD.LastPasswordSet AS ADAcctLastPasswordSet,
AD.LastBadPasswordAttempt AS ADAcctLastBadPasswordAttempt,
AD.UserCannotChangePassword AS ADAcctUserCannotChangePassword,
AD.Description AS ADAcctDescription,
AD.DelegationPermitted AS ADAcctDelegationPermitted,
AD.AccountExpirationDate AS ADAcctAccountExpirationDate,
AD.AccountLockoutTime AS ADAcctAccountLockoutTime,
AD.EmailAddress AS ADAcctEmailAddress,
AD.Enabled AS ADAcctEnabled,
AD.EmployeeID AS ADAcctEmployeeID,
AD.VoiceTelephoneNumber AS ADAcctVoiceTelephoneNumber,
AD.DistinguishedName AS ADAcctDistinguishedName,
AD.DisplayName AS ADAcctDisplayName,
AD.SurName AS ADAcctSurName,
AD.MiddleName AS ADAcctMiddleName,
AD.GivenName AS ADAcctGivenName,
AD.Name AS ADAcctName,
AD.GUID AS ADAcctGUID,
AD.SID AS ADAcctSID,
AD.SmartcardLogonRequired AS ADAcctSmartcardLogonRequired,
AD.HomeDirectory AS ADAcctHomeDirectory,
AD.HomeDrive AS ADAcctHomeDrive,
AD.AllowReversiblePasswordEncryption AS ADAcctAllowReversiblePasswordEncryption,

L.sid AS SQLAcctSID,
L.status AS SQLAcctstatus,
L.createdate AS SQLAcctcreatedate,
L.updatedate AS SQLAcctupdatedate,
L.accdate AS SQLAcctaccdate,
L.totcpu AS SQLAccttotcpu,
L.totio AS SQLAccttotio,
L.spacelimit AS SQLAcctspacelimit,
L.timelimit AS SQLAccttimelimit,
L.resultlimit AS SQLAcctresultlimit,
L.name AS SQLAcctname,
L.dbname AS SQLAcctdbname,
L.password AS SQLAcctpassword,
L.language AS SQLAcctlanguage,
L.denylogin AS SQLAcctdenylogin,
L.hasaccess AS SQLAccthasaccess,
L.isntname AS SQLAcctisntname,
L.isntgroup AS SQLAcctisntgroup,
L.isntuser AS SQLAcctisntuser,
L.sysadmin AS SQLAcctsysadmin,
L.securityadmin AS SQLAcctsecurityadmin,
L.serveradmin AS SQLAcctserveradmin,
L.setupadmin AS SQLAcctsetupadmin,
L.processadmin AS SQLAcctprocessadmin,
L.diskadmin AS SQLAcctdiskadmin,
L.dbcreator AS SQLAcctdbcreator,
L.bulkadmin AS SQLAcctbulkadmin,
L.loginname AS SQLAcctloginname,
L.BadPasswordCount AS SQLAcctBadPasswordCount,
L.BadPasswordTime AS SQLAcctBadPasswordTime,
L.HistoryLength AS SQLAcctHistoryLength,
L.PasswordLastSetTime AS SQLAcctPasswordLastSetTime,
L.PasswordHash AS SQLAcctPasswordHash,
L.LoginType AS SQLAcctLoginType,
L.DateLastModified AS SQLAcctDateLastModified,
L.IsDisabled AS SQLAcctIsDisabled,
L.IsLocked AS SQLAcctIsLocked,
L.IsPasswordExpired AS SQLAcctIsPasswordExpired,
L.IsSystemObject AS SQLAcctIsSystemObject,
L.LanguageAlias AS SQLAcctLanguageAlias,
L.MustChangePassword AS SQLAcctMustChangePassword,
L.PasswordExpirationEnabled AS SQLAcctPasswordExpirationEnabled,
L.PasswordPolicyEnforced AS SQLAcctPasswordPolicyEnforced,
L.State AS SQLAcctState,
L.WindowsLoginAccessType AS SQLAcctWindowsLoginAccessType,
L.DefaultDatabase AS SQLAcctDefaultDatabase

               FROM     Collector.ADGroupMemberCurrent AD
                        JOIN CTE ON AD.GroupName = CTE.ADAcctObjectName
                        JOIN Collector.LoginsCurrent L ON CTE.ADAcctGroupName = L.name
                                         --AND L.hasaccess = 1
                        JOIN dbo.Servers S ON S.InstanceID = L.InstanceID
                        WHERE S.ServiceLevel = @SLA
             )
    SELECT DISTINCT CTE.*, 'If you need to limit the results by any other criteria, use the manual script: \ManualScripts\Logins\Report.ADAcctsInSQLBySLA.sql. You will find it very helpful in helping you merge this data with other tables as well as limiting by say sysadmins, etc.' AS MoreInfo
	FROM    CTE
    WHERE   CTE.ADAcctObjectName NOT IN ( SELECT  ADAcctGroupName
                                    FROM    CTE )
    ORDER BY 1 ,
            2 ,
            3 ,
            4;


;
GO
/****** Object:  StoredProcedure [Report].[ADAcctsInSQLByServerName]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[ADAcctsInSQLByServerName] 
(
@ServerName sysname
)
 
AS

/*
This SP gets an expanded list of AD groups for a specific Server by ServerName.
If you have a Windows group as a login in SQL, you have no idea who's in there because
you can't see in the AD groups.  Now you can, and quite easily.

Just enter the InstanceID you're interested in and you'll get a full list of all the expanded AD groups.
To limit the resultset by any criteria, say by sysadmins, then use the manual script in
\ManualScripts\Logins\Report.ADAcctsInSQLByServerName.sql
*/

WITH    CTE
          AS ( SELECT  

AD.ExecutionDateTime,
L.InstanceID AS SQLAcctInstanceID,
AD.GroupName AS ADAcctGroupName,
AD.ObjectName AS ADAcctObjectName,
AD.IsGroup AS ADAcctIsGroup,
AD.GroupMember AS ADAcctGroupMember,
AD.LastLogon AS ADAcctLastLogon,
AD.BadLogonCount AS ADAcctBadLogonCount,
AD.PasswordNeverExpires AS ADAcctPasswordNeverExpires,
AD.PasswordNotRequired AS ADAcctPasswordNotRequired,
AD.PermittedLogonTimes AS ADAcctPermittedLogonTimes,
AD.PermittedWorkstations AS ADAcctPermittedWorkstations,
AD.LastPasswordSet AS ADAcctLastPasswordSet,
AD.LastBadPasswordAttempt AS ADAcctLastBadPasswordAttempt,
AD.UserCannotChangePassword AS ADAcctUserCannotChangePassword,
AD.Description AS ADAcctDescription,
AD.DelegationPermitted AS ADAcctDelegationPermitted,
AD.AccountExpirationDate AS ADAcctAccountExpirationDate,
AD.AccountLockoutTime AS ADAcctAccountLockoutTime,
AD.EmailAddress AS ADAcctEmailAddress,
AD.Enabled AS ADAcctEnabled,
AD.EmployeeID AS ADAcctEmployeeID,
AD.VoiceTelephoneNumber AS ADAcctVoiceTelephoneNumber,
AD.DistinguishedName AS ADAcctDistinguishedName,
AD.DisplayName AS ADAcctDisplayName,
AD.SurName AS ADAcctSurName,
AD.MiddleName AS ADAcctMiddleName,
AD.GivenName AS ADAcctGivenName,
AD.Name AS ADAcctName,
AD.GUID AS ADAcctGUID,
AD.SID AS ADAcctSID,
AD.SmartcardLogonRequired AS ADAcctSmartcardLogonRequired,
AD.HomeDirectory AS ADAcctHomeDirectory,
AD.HomeDrive AS ADAcctHomeDrive,
AD.AllowReversiblePasswordEncryption AS ADAcctAllowReversiblePasswordEncryption,

L.sid AS SQLAcctSID,
L.status AS SQLAcctstatus,
L.createdate AS SQLAcctcreatedate,
L.updatedate AS SQLAcctupdatedate,
L.accdate AS SQLAcctaccdate,
L.totcpu AS SQLAccttotcpu,
L.totio AS SQLAccttotio,
L.spacelimit AS SQLAcctspacelimit,
L.timelimit AS SQLAccttimelimit,
L.resultlimit AS SQLAcctresultlimit,
L.name AS SQLAcctname,
L.dbname AS SQLAcctdbname,
L.password AS SQLAcctpassword,
L.language AS SQLAcctlanguage,
L.denylogin AS SQLAcctdenylogin,
L.hasaccess AS SQLAccthasaccess,
L.isntname AS SQLAcctisntname,
L.isntgroup AS SQLAcctisntgroup,
L.isntuser AS SQLAcctisntuser,
L.sysadmin AS SQLAcctsysadmin,
L.securityadmin AS SQLAcctsecurityadmin,
L.serveradmin AS SQLAcctserveradmin,
L.setupadmin AS SQLAcctsetupadmin,
L.processadmin AS SQLAcctprocessadmin,
L.diskadmin AS SQLAcctdiskadmin,
L.dbcreator AS SQLAcctdbcreator,
L.bulkadmin AS SQLAcctbulkadmin,
L.loginname AS SQLAcctloginname,
L.BadPasswordCount AS SQLAcctBadPasswordCount,
L.BadPasswordTime AS SQLAcctBadPasswordTime,
L.HistoryLength AS SQLAcctHistoryLength,
L.PasswordLastSetTime AS SQLAcctPasswordLastSetTime,
L.PasswordHash AS SQLAcctPasswordHash,
L.LoginType AS SQLAcctLoginType,
L.DateLastModified AS SQLAcctDateLastModified,
L.IsDisabled AS SQLAcctIsDisabled,
L.IsLocked AS SQLAcctIsLocked,
L.IsPasswordExpired AS SQLAcctIsPasswordExpired,
L.IsSystemObject AS SQLAcctIsSystemObject,
L.LanguageAlias AS SQLAcctLanguageAlias,
L.MustChangePassword AS SQLAcctMustChangePassword,
L.PasswordExpirationEnabled AS SQLAcctPasswordExpirationEnabled,
L.PasswordPolicyEnforced AS SQLAcctPasswordPolicyEnforced,
L.State AS SQLAcctState,
L.WindowsLoginAccessType AS SQLAcctWindowsLoginAccessType,
L.DefaultDatabase AS SQLAcctDefaultDatabase
						
               FROM     Collector.ADGroupMemberCurrent AD
                        JOIN Collector.LoginsCurrent L ON AD.GroupName = L.name
                                         AND L.hasaccess = 1
                        JOIN dbo.Servers S ON S.InstanceID = L.InstanceID
                        WHERE S.ServerName = @ServerName
               UNION ALL
               SELECT  

AD.ExecutionDateTime,
L.InstanceID AS SQLAcctInstanceID,
AD.GroupName AS ADAcctGroupName,
AD.ObjectName AS ADAcctObjectName,
AD.IsGroup AS ADAcctIsGroup,
AD.GroupMember AS ADAcctGroupMember,
AD.LastLogon AS ADAcctLastLogon,
AD.BadLogonCount AS ADAcctBadLogonCount,
AD.PasswordNeverExpires AS ADAcctPasswordNeverExpires,
AD.PasswordNotRequired AS ADAcctPasswordNotRequired,
AD.PermittedLogonTimes AS ADAcctPermittedLogonTimes,
AD.PermittedWorkstations AS ADAcctPermittedWorkstations,
AD.LastPasswordSet AS ADAcctLastPasswordSet,
AD.LastBadPasswordAttempt AS ADAcctLastBadPasswordAttempt,
AD.UserCannotChangePassword AS ADAcctUserCannotChangePassword,
AD.Description AS ADAcctDescription,
AD.DelegationPermitted AS ADAcctDelegationPermitted,
AD.AccountExpirationDate AS ADAcctAccountExpirationDate,
AD.AccountLockoutTime AS ADAcctAccountLockoutTime,
AD.EmailAddress AS ADAcctEmailAddress,
AD.Enabled AS ADAcctEnabled,
AD.EmployeeID AS ADAcctEmployeeID,
AD.VoiceTelephoneNumber AS ADAcctVoiceTelephoneNumber,
AD.DistinguishedName AS ADAcctDistinguishedName,
AD.DisplayName AS ADAcctDisplayName,
AD.SurName AS ADAcctSurName,
AD.MiddleName AS ADAcctMiddleName,
AD.GivenName AS ADAcctGivenName,
AD.Name AS ADAcctName,
AD.GUID AS ADAcctGUID,
AD.SID AS ADAcctSID,
AD.SmartcardLogonRequired AS ADAcctSmartcardLogonRequired,
AD.HomeDirectory AS ADAcctHomeDirectory,
AD.HomeDrive AS ADAcctHomeDrive,
AD.AllowReversiblePasswordEncryption AS ADAcctAllowReversiblePasswordEncryption,

L.sid AS SQLAcctSID,
L.status AS SQLAcctstatus,
L.createdate AS SQLAcctcreatedate,
L.updatedate AS SQLAcctupdatedate,
L.accdate AS SQLAcctaccdate,
L.totcpu AS SQLAccttotcpu,
L.totio AS SQLAccttotio,
L.spacelimit AS SQLAcctspacelimit,
L.timelimit AS SQLAccttimelimit,
L.resultlimit AS SQLAcctresultlimit,
L.name AS SQLAcctname,
L.dbname AS SQLAcctdbname,
L.password AS SQLAcctpassword,
L.language AS SQLAcctlanguage,
L.denylogin AS SQLAcctdenylogin,
L.hasaccess AS SQLAccthasaccess,
L.isntname AS SQLAcctisntname,
L.isntgroup AS SQLAcctisntgroup,
L.isntuser AS SQLAcctisntuser,
L.sysadmin AS SQLAcctsysadmin,
L.securityadmin AS SQLAcctsecurityadmin,
L.serveradmin AS SQLAcctserveradmin,
L.setupadmin AS SQLAcctsetupadmin,
L.processadmin AS SQLAcctprocessadmin,
L.diskadmin AS SQLAcctdiskadmin,
L.dbcreator AS SQLAcctdbcreator,
L.bulkadmin AS SQLAcctbulkadmin,
L.loginname AS SQLAcctloginname,
L.BadPasswordCount AS SQLAcctBadPasswordCount,
L.BadPasswordTime AS SQLAcctBadPasswordTime,
L.HistoryLength AS SQLAcctHistoryLength,
L.PasswordLastSetTime AS SQLAcctPasswordLastSetTime,
L.PasswordHash AS SQLAcctPasswordHash,
L.LoginType AS SQLAcctLoginType,
L.DateLastModified AS SQLAcctDateLastModified,
L.IsDisabled AS SQLAcctIsDisabled,
L.IsLocked AS SQLAcctIsLocked,
L.IsPasswordExpired AS SQLAcctIsPasswordExpired,
L.IsSystemObject AS SQLAcctIsSystemObject,
L.LanguageAlias AS SQLAcctLanguageAlias,
L.MustChangePassword AS SQLAcctMustChangePassword,
L.PasswordExpirationEnabled AS SQLAcctPasswordExpirationEnabled,
L.PasswordPolicyEnforced AS SQLAcctPasswordPolicyEnforced,
L.State AS SQLAcctState,
L.WindowsLoginAccessType AS SQLAcctWindowsLoginAccessType,
L.DefaultDatabase AS SQLAcctDefaultDatabase

               FROM     Collector.ADGroupMemberCurrent AD
                        JOIN CTE ON AD.GroupName = CTE.ADAcctObjectName
                        JOIN Collector.LoginsCurrent L ON CTE.ADAcctGroupName = L.name
                                         AND L.hasaccess = 1
                        JOIN dbo.Servers S ON S.InstanceID = L.InstanceID
                        WHERE S.ServerName = @ServerName
             )
    SELECT DISTINCT CTE.*, 'If you need to limit the results by any other criteria, use the manual script: \ManualScripts\Logins\Report.ADAcctsInSQLByServerName.sql. You will find it very helpful in helping you merge this data with other tables as well as limiting by say sysadmins, etc.' AS MoreInfo
	FROM    CTE
    WHERE   CTE.ADAcctObjectName NOT IN ( SELECT  ADAcctGroupName
                                    FROM    CTE )
    ORDER BY 1 ,
            2 ,
            3 ,
            4;


;
GO
/****** Object:  StoredProcedure [Report].[ADAcctsInSQLByID]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[ADAcctsInSQLByID]
(
@InstanceID bigint
)
 
AS

/*
This SP gets an expanded list of AD groups for a specific Server by InstanceID.
If you have a Windows group as a login in SQL, you have no idea who's in there because
you can't see in the AD groups.  Now you can, and quite easily.

Just enter the InstanceID you're interested in and you'll get a full list of all the expanded AD groups.
To limit the resultset by any criteria, say by sysadmins, then use the manual script in
\ManualScripts\Logins\Report.ADAcctsInSQLByID.sql
*/

WITH    CTE
          AS ( SELECT  

AD.ExecutionDateTime,
L.InstanceID AS SQLAcctInstanceID,
AD.GroupName AS ADAcctGroupName,
AD.ObjectName AS ADAcctObjectName,
AD.IsGroup AS ADAcctIsGroup,
AD.GroupMember AS ADAcctGroupMember,
AD.LastLogon AS ADAcctLastLogon,
AD.BadLogonCount AS ADAcctBadLogonCount,
AD.PasswordNeverExpires AS ADAcctPasswordNeverExpires,
AD.PasswordNotRequired AS ADAcctPasswordNotRequired,
AD.PermittedLogonTimes AS ADAcctPermittedLogonTimes,
AD.PermittedWorkstations AS ADAcctPermittedWorkstations,
AD.LastPasswordSet AS ADAcctLastPasswordSet,
AD.LastBadPasswordAttempt AS ADAcctLastBadPasswordAttempt,
AD.UserCannotChangePassword AS ADAcctUserCannotChangePassword,
AD.Description AS ADAcctDescription,
AD.DelegationPermitted AS ADAcctDelegationPermitted,
AD.AccountExpirationDate AS ADAcctAccountExpirationDate,
AD.AccountLockoutTime AS ADAcctAccountLockoutTime,
AD.EmailAddress AS ADAcctEmailAddress,
AD.Enabled AS ADAcctEnabled,
AD.EmployeeID AS ADAcctEmployeeID,
AD.VoiceTelephoneNumber AS ADAcctVoiceTelephoneNumber,
AD.DistinguishedName AS ADAcctDistinguishedName,
AD.DisplayName AS ADAcctDisplayName,
AD.SurName AS ADAcctSurName,
AD.MiddleName AS ADAcctMiddleName,
AD.GivenName AS ADAcctGivenName,
AD.Name AS ADAcctName,
AD.GUID AS ADAcctGUID,
AD.SID AS ADAcctSID,
AD.SmartcardLogonRequired AS ADAcctSmartcardLogonRequired,
AD.HomeDirectory AS ADAcctHomeDirectory,
AD.HomeDrive AS ADAcctHomeDrive,
AD.AllowReversiblePasswordEncryption AS ADAcctAllowReversiblePasswordEncryption,

L.sid AS SQLAcctSID,
L.status AS SQLAcctstatus,
L.createdate AS SQLAcctcreatedate,
L.updatedate AS SQLAcctupdatedate,
L.accdate AS SQLAcctaccdate,
L.totcpu AS SQLAccttotcpu,
L.totio AS SQLAccttotio,
L.spacelimit AS SQLAcctspacelimit,
L.timelimit AS SQLAccttimelimit,
L.resultlimit AS SQLAcctresultlimit,
L.name AS SQLAcctname,
L.dbname AS SQLAcctdbname,
L.password AS SQLAcctpassword,
L.language AS SQLAcctlanguage,
L.denylogin AS SQLAcctdenylogin,
L.hasaccess AS SQLAccthasaccess,
L.isntname AS SQLAcctisntname,
L.isntgroup AS SQLAcctisntgroup,
L.isntuser AS SQLAcctisntuser,
L.sysadmin AS SQLAcctsysadmin,
L.securityadmin AS SQLAcctsecurityadmin,
L.serveradmin AS SQLAcctserveradmin,
L.setupadmin AS SQLAcctsetupadmin,
L.processadmin AS SQLAcctprocessadmin,
L.diskadmin AS SQLAcctdiskadmin,
L.dbcreator AS SQLAcctdbcreator,
L.bulkadmin AS SQLAcctbulkadmin,
L.loginname AS SQLAcctloginname,
L.BadPasswordCount AS SQLAcctBadPasswordCount,
L.BadPasswordTime AS SQLAcctBadPasswordTime,
L.HistoryLength AS SQLAcctHistoryLength,
L.PasswordLastSetTime AS SQLAcctPasswordLastSetTime,
L.PasswordHash AS SQLAcctPasswordHash,
L.LoginType AS SQLAcctLoginType,
L.DateLastModified AS SQLAcctDateLastModified,
L.IsDisabled AS SQLAcctIsDisabled,
L.IsLocked AS SQLAcctIsLocked,
L.IsPasswordExpired AS SQLAcctIsPasswordExpired,
L.IsSystemObject AS SQLAcctIsSystemObject,
L.LanguageAlias AS SQLAcctLanguageAlias,
L.MustChangePassword AS SQLAcctMustChangePassword,
L.PasswordExpirationEnabled AS SQLAcctPasswordExpirationEnabled,
L.PasswordPolicyEnforced AS SQLAcctPasswordPolicyEnforced,
L.State AS SQLAcctState,
L.WindowsLoginAccessType AS SQLAcctWindowsLoginAccessType,
L.DefaultDatabase AS SQLAcctDefaultDatabase
						
               FROM     Collector.ADGroupMemberCurrent AD
                        JOIN Collector.LoginsCurrent L ON AD.GroupName = L.name
                                         AND L.hasaccess = 1
                        JOIN dbo.Servers S ON S.InstanceID = L.InstanceID
                        WHERE S.InstanceID = @InstanceID
               UNION ALL
               SELECT  

AD.ExecutionDateTime,
L.InstanceID AS SQLAcctInstanceID,
AD.GroupName AS ADAcctGroupName,
AD.ObjectName AS ADAcctObjectName,
AD.IsGroup AS ADAcctIsGroup,
AD.GroupMember AS ADAcctGroupMember,
AD.LastLogon AS ADAcctLastLogon,
AD.BadLogonCount AS ADAcctBadLogonCount,
AD.PasswordNeverExpires AS ADAcctPasswordNeverExpires,
AD.PasswordNotRequired AS ADAcctPasswordNotRequired,
AD.PermittedLogonTimes AS ADAcctPermittedLogonTimes,
AD.PermittedWorkstations AS ADAcctPermittedWorkstations,
AD.LastPasswordSet AS ADAcctLastPasswordSet,
AD.LastBadPasswordAttempt AS ADAcctLastBadPasswordAttempt,
AD.UserCannotChangePassword AS ADAcctUserCannotChangePassword,
AD.Description AS ADAcctDescription,
AD.DelegationPermitted AS ADAcctDelegationPermitted,
AD.AccountExpirationDate AS ADAcctAccountExpirationDate,
AD.AccountLockoutTime AS ADAcctAccountLockoutTime,
AD.EmailAddress AS ADAcctEmailAddress,
AD.Enabled AS ADAcctEnabled,
AD.EmployeeID AS ADAcctEmployeeID,
AD.VoiceTelephoneNumber AS ADAcctVoiceTelephoneNumber,
AD.DistinguishedName AS ADAcctDistinguishedName,
AD.DisplayName AS ADAcctDisplayName,
AD.SurName AS ADAcctSurName,
AD.MiddleName AS ADAcctMiddleName,
AD.GivenName AS ADAcctGivenName,
AD.Name AS ADAcctName,
AD.GUID AS ADAcctGUID,
AD.SID AS ADAcctSID,
AD.SmartcardLogonRequired AS ADAcctSmartcardLogonRequired,
AD.HomeDirectory AS ADAcctHomeDirectory,
AD.HomeDrive AS ADAcctHomeDrive,
AD.AllowReversiblePasswordEncryption AS ADAcctAllowReversiblePasswordEncryption,

L.sid AS SQLAcctSID,
L.status AS SQLAcctstatus,
L.createdate AS SQLAcctcreatedate,
L.updatedate AS SQLAcctupdatedate,
L.accdate AS SQLAcctaccdate,
L.totcpu AS SQLAccttotcpu,
L.totio AS SQLAccttotio,
L.spacelimit AS SQLAcctspacelimit,
L.timelimit AS SQLAccttimelimit,
L.resultlimit AS SQLAcctresultlimit,
L.name AS SQLAcctname,
L.dbname AS SQLAcctdbname,
L.password AS SQLAcctpassword,
L.language AS SQLAcctlanguage,
L.denylogin AS SQLAcctdenylogin,
L.hasaccess AS SQLAccthasaccess,
L.isntname AS SQLAcctisntname,
L.isntgroup AS SQLAcctisntgroup,
L.isntuser AS SQLAcctisntuser,
L.sysadmin AS SQLAcctsysadmin,
L.securityadmin AS SQLAcctsecurityadmin,
L.serveradmin AS SQLAcctserveradmin,
L.setupadmin AS SQLAcctsetupadmin,
L.processadmin AS SQLAcctprocessadmin,
L.diskadmin AS SQLAcctdiskadmin,
L.dbcreator AS SQLAcctdbcreator,
L.bulkadmin AS SQLAcctbulkadmin,
L.loginname AS SQLAcctloginname,
L.BadPasswordCount AS SQLAcctBadPasswordCount,
L.BadPasswordTime AS SQLAcctBadPasswordTime,
L.HistoryLength AS SQLAcctHistoryLength,
L.PasswordLastSetTime AS SQLAcctPasswordLastSetTime,
L.PasswordHash AS SQLAcctPasswordHash,
L.LoginType AS SQLAcctLoginType,
L.DateLastModified AS SQLAcctDateLastModified,
L.IsDisabled AS SQLAcctIsDisabled,
L.IsLocked AS SQLAcctIsLocked,
L.IsPasswordExpired AS SQLAcctIsPasswordExpired,
L.IsSystemObject AS SQLAcctIsSystemObject,
L.LanguageAlias AS SQLAcctLanguageAlias,
L.MustChangePassword AS SQLAcctMustChangePassword,
L.PasswordExpirationEnabled AS SQLAcctPasswordExpirationEnabled,
L.PasswordPolicyEnforced AS SQLAcctPasswordPolicyEnforced,
L.State AS SQLAcctState,
L.WindowsLoginAccessType AS SQLAcctWindowsLoginAccessType,
L.DefaultDatabase AS SQLAcctDefaultDatabase

               FROM     Collector.ADGroupMemberCurrent AD
                        JOIN CTE ON AD.GroupName = CTE.ADAcctObjectName
                        JOIN Collector.LoginsCurrent L ON CTE.ADAcctGroupName = L.name
                                        -- AND L.hasaccess = 1
                        JOIN dbo.Servers S ON S.InstanceID = L.InstanceID
                        WHERE S.InstanceID = @InstanceID
             )
    SELECT DISTINCT CTE.*, 'If you need to limit the results by any other criteria, use the manual script: \ManualScripts\Logins\Report.ADAcctsInSQLByID.sql. You will find it very helpful in helping you merge this data with other tables as well as limiting by say sysadmins, etc.' AS MoreInfo
    FROM    CTE
    WHERE   CTE.ADAcctObjectName NOT IN ( SELECT  ADAcctGroupName
                                    FROM    CTE )
    ORDER BY 1 ,
            2 ,
            3 ,
            4;


;
GO
/****** Object:  StoredProcedure [Report].[ADAcctsInSQLAll]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[ADAcctsInSQLAll] 
 
AS

/*
This SP gets an expanded list of AD groups for a specific Server by ServerName.
If you have a Windows group as a login in SQL, you have no idea who's in there because
you can't see in the AD groups.  Now you can, and quite easily.

Just enter the InstanceID you're interested in and you'll get a full list of all the expanded AD groups.
To limit the resultset by any criteria, say by sysadmins, then use the manual script in
\ManualScripts\Logins\Report.ADAcctsInSQLAll.sql
*/

WITH    CTE
          AS ( SELECT  

AD.ExecutionDateTime,
L.InstanceID AS SQLAcctInstanceID,
AD.GroupName AS ADAcctGroupName,
AD.ObjectName AS ADAcctObjectName,
AD.IsGroup AS ADAcctIsGroup,
AD.GroupMember AS ADAcctGroupMember,
AD.LastLogon AS ADAcctLastLogon,
AD.BadLogonCount AS ADAcctBadLogonCount,
AD.PasswordNeverExpires AS ADAcctPasswordNeverExpires,
AD.PasswordNotRequired AS ADAcctPasswordNotRequired,
AD.PermittedLogonTimes AS ADAcctPermittedLogonTimes,
AD.PermittedWorkstations AS ADAcctPermittedWorkstations,
AD.LastPasswordSet AS ADAcctLastPasswordSet,
AD.LastBadPasswordAttempt AS ADAcctLastBadPasswordAttempt,
AD.UserCannotChangePassword AS ADAcctUserCannotChangePassword,
AD.Description AS ADAcctDescription,
AD.DelegationPermitted AS ADAcctDelegationPermitted,
AD.AccountExpirationDate AS ADAcctAccountExpirationDate,
AD.AccountLockoutTime AS ADAcctAccountLockoutTime,
AD.EmailAddress AS ADAcctEmailAddress,
AD.Enabled AS ADAcctEnabled,
AD.EmployeeID AS ADAcctEmployeeID,
AD.VoiceTelephoneNumber AS ADAcctVoiceTelephoneNumber,
AD.DistinguishedName AS ADAcctDistinguishedName,
AD.DisplayName AS ADAcctDisplayName,
AD.SurName AS ADAcctSurName,
AD.MiddleName AS ADAcctMiddleName,
AD.GivenName AS ADAcctGivenName,
AD.Name AS ADAcctName,
AD.GUID AS ADAcctGUID,
AD.SID AS ADAcctSID,
AD.SmartcardLogonRequired AS ADAcctSmartcardLogonRequired,
AD.HomeDirectory AS ADAcctHomeDirectory,
AD.HomeDrive AS ADAcctHomeDrive,
AD.AllowReversiblePasswordEncryption AS ADAcctAllowReversiblePasswordEncryption,

L.sid AS SQLAcctSID,
L.status AS SQLAcctstatus,
L.createdate AS SQLAcctcreatedate,
L.updatedate AS SQLAcctupdatedate,
L.accdate AS SQLAcctaccdate,
L.totcpu AS SQLAccttotcpu,
L.totio AS SQLAccttotio,
L.spacelimit AS SQLAcctspacelimit,
L.timelimit AS SQLAccttimelimit,
L.resultlimit AS SQLAcctresultlimit,
L.name AS SQLAcctname,
L.dbname AS SQLAcctdbname,
L.password AS SQLAcctpassword,
L.language AS SQLAcctlanguage,
L.denylogin AS SQLAcctdenylogin,
L.hasaccess AS SQLAccthasaccess,
L.isntname AS SQLAcctisntname,
L.isntgroup AS SQLAcctisntgroup,
L.isntuser AS SQLAcctisntuser,
L.sysadmin AS SQLAcctsysadmin,
L.securityadmin AS SQLAcctsecurityadmin,
L.serveradmin AS SQLAcctserveradmin,
L.setupadmin AS SQLAcctsetupadmin,
L.processadmin AS SQLAcctprocessadmin,
L.diskadmin AS SQLAcctdiskadmin,
L.dbcreator AS SQLAcctdbcreator,
L.bulkadmin AS SQLAcctbulkadmin,
L.loginname AS SQLAcctloginname,
L.BadPasswordCount AS SQLAcctBadPasswordCount,
L.BadPasswordTime AS SQLAcctBadPasswordTime,
L.HistoryLength AS SQLAcctHistoryLength,
L.PasswordLastSetTime AS SQLAcctPasswordLastSetTime,
L.PasswordHash AS SQLAcctPasswordHash,
L.LoginType AS SQLAcctLoginType,
L.DateLastModified AS SQLAcctDateLastModified,
L.IsDisabled AS SQLAcctIsDisabled,
L.IsLocked AS SQLAcctIsLocked,
L.IsPasswordExpired AS SQLAcctIsPasswordExpired,
L.IsSystemObject AS SQLAcctIsSystemObject,
L.LanguageAlias AS SQLAcctLanguageAlias,
L.MustChangePassword AS SQLAcctMustChangePassword,
L.PasswordExpirationEnabled AS SQLAcctPasswordExpirationEnabled,
L.PasswordPolicyEnforced AS SQLAcctPasswordPolicyEnforced,
L.State AS SQLAcctState,
L.WindowsLoginAccessType AS SQLAcctWindowsLoginAccessType,
L.DefaultDatabase AS SQLAcctDefaultDatabase
						
               FROM     Collector.ADGroupMemberCurrent AD
                        JOIN Collector.LoginsCurrent L ON AD.GroupName = L.name
                                         AND L.hasaccess = 1
                        JOIN dbo.Servers S ON S.InstanceID = L.InstanceID
                        
               UNION ALL
               SELECT  

AD.ExecutionDateTime,
L.InstanceID AS SQLAcctInstanceID,
AD.GroupName AS ADAcctGroupName,
AD.ObjectName AS ADAcctObjectName,
AD.IsGroup AS ADAcctIsGroup,
AD.GroupMember AS ADAcctGroupMember,
AD.LastLogon AS ADAcctLastLogon,
AD.BadLogonCount AS ADAcctBadLogonCount,
AD.PasswordNeverExpires AS ADAcctPasswordNeverExpires,
AD.PasswordNotRequired AS ADAcctPasswordNotRequired,
AD.PermittedLogonTimes AS ADAcctPermittedLogonTimes,
AD.PermittedWorkstations AS ADAcctPermittedWorkstations,
AD.LastPasswordSet AS ADAcctLastPasswordSet,
AD.LastBadPasswordAttempt AS ADAcctLastBadPasswordAttempt,
AD.UserCannotChangePassword AS ADAcctUserCannotChangePassword,
AD.Description AS ADAcctDescription,
AD.DelegationPermitted AS ADAcctDelegationPermitted,
AD.AccountExpirationDate AS ADAcctAccountExpirationDate,
AD.AccountLockoutTime AS ADAcctAccountLockoutTime,
AD.EmailAddress AS ADAcctEmailAddress,
AD.Enabled AS ADAcctEnabled,
AD.EmployeeID AS ADAcctEmployeeID,
AD.VoiceTelephoneNumber AS ADAcctVoiceTelephoneNumber,
AD.DistinguishedName AS ADAcctDistinguishedName,
AD.DisplayName AS ADAcctDisplayName,
AD.SurName AS ADAcctSurName,
AD.MiddleName AS ADAcctMiddleName,
AD.GivenName AS ADAcctGivenName,
AD.Name AS ADAcctName,
AD.GUID AS ADAcctGUID,
AD.SID AS ADAcctSID,
AD.SmartcardLogonRequired AS ADAcctSmartcardLogonRequired,
AD.HomeDirectory AS ADAcctHomeDirectory,
AD.HomeDrive AS ADAcctHomeDrive,
AD.AllowReversiblePasswordEncryption AS ADAcctAllowReversiblePasswordEncryption,

L.sid AS SQLAcctSID,
L.status AS SQLAcctstatus,
L.createdate AS SQLAcctcreatedate,
L.updatedate AS SQLAcctupdatedate,
L.accdate AS SQLAcctaccdate,
L.totcpu AS SQLAccttotcpu,
L.totio AS SQLAccttotio,
L.spacelimit AS SQLAcctspacelimit,
L.timelimit AS SQLAccttimelimit,
L.resultlimit AS SQLAcctresultlimit,
L.name AS SQLAcctname,
L.dbname AS SQLAcctdbname,
L.password AS SQLAcctpassword,
L.language AS SQLAcctlanguage,
L.denylogin AS SQLAcctdenylogin,
L.hasaccess AS SQLAccthasaccess,
L.isntname AS SQLAcctisntname,
L.isntgroup AS SQLAcctisntgroup,
L.isntuser AS SQLAcctisntuser,
L.sysadmin AS SQLAcctsysadmin,
L.securityadmin AS SQLAcctsecurityadmin,
L.serveradmin AS SQLAcctserveradmin,
L.setupadmin AS SQLAcctsetupadmin,
L.processadmin AS SQLAcctprocessadmin,
L.diskadmin AS SQLAcctdiskadmin,
L.dbcreator AS SQLAcctdbcreator,
L.bulkadmin AS SQLAcctbulkadmin,
L.loginname AS SQLAcctloginname,
L.BadPasswordCount AS SQLAcctBadPasswordCount,
L.BadPasswordTime AS SQLAcctBadPasswordTime,
L.HistoryLength AS SQLAcctHistoryLength,
L.PasswordLastSetTime AS SQLAcctPasswordLastSetTime,
L.PasswordHash AS SQLAcctPasswordHash,
L.LoginType AS SQLAcctLoginType,
L.DateLastModified AS SQLAcctDateLastModified,
L.IsDisabled AS SQLAcctIsDisabled,
L.IsLocked AS SQLAcctIsLocked,
L.IsPasswordExpired AS SQLAcctIsPasswordExpired,
L.IsSystemObject AS SQLAcctIsSystemObject,
L.LanguageAlias AS SQLAcctLanguageAlias,
L.MustChangePassword AS SQLAcctMustChangePassword,
L.PasswordExpirationEnabled AS SQLAcctPasswordExpirationEnabled,
L.PasswordPolicyEnforced AS SQLAcctPasswordPolicyEnforced,
L.State AS SQLAcctState,
L.WindowsLoginAccessType AS SQLAcctWindowsLoginAccessType,
L.DefaultDatabase AS SQLAcctDefaultDatabase

               FROM     Collector.ADGroupMemberCurrent AD
                        JOIN CTE ON AD.GroupName = CTE.ADAcctObjectName
                        JOIN Collector.LoginsCurrent L ON CTE.ADAcctGroupName = L.name
                                         --AND L.hasaccess = 1
                        JOIN dbo.Servers S ON S.InstanceID = L.InstanceID
                        
             )
    SELECT DISTINCT CTE.*, 'If you need to limit the results by any other criteria, use the manual script: \ManualScripts\Logins\Report.ADAcctsInSQLAll.sql. You will find it very helpful in helping you merge this data with other tables as well as limiting by say sysadmins, etc.' AS MoreInfo
	FROM    CTE
    WHERE   CTE.ADAcctObjectName NOT IN ( SELECT  ADAcctGroupName
                                    FROM    CTE )
    ORDER BY 1 ,
            2 ,
            3 ,
            4;


;
GO
/****** Object:  StoredProcedure [Alert].[InstanceConfig]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Alert].[InstanceConfig] 
(@EmailProfile varchar(1024), @ServiceLevel varchar(10))       

              
as                            
 
--EXEC [Alert].[InstanceConfig] @EmailProfile='DriveSpaceProfile',@ServiceLevel='Gold'
      
--------------------------------------------------------------------
DECLARE @Distro varchar(4000),
		@ExecutionDateTime datetime
		
SET @ExecutionDateTime = GETDATE()		

----Get master list of servers and disks.
SELECT DISTINCT
        s.[InstanceID] ,
        s.ServerName ,
        a.Name,
		ICV.DesiredValue,
		a.RunValue,
        --a.ExecutionDateTime ,
        s.ServiceLevel AS ServiceLevel,
        ICV.[Action],
        c.AppName
        
INTO #ServerList        
FROM    Collector.InstanceConfig a ( NOLOCK )
        INNER JOIN dbo.Servers s ( NOLOCK ) 
        ON a.InstanceID = s.[InstanceID]
        INNER JOIN dbo.InstanceConfigValue ICV
        ON (a.InstanceID = ICV.InstanceID and a.Name = ICV.Name)
        LEFT JOIN ServerAppRoleApp b ( NOLOCK ) ON a.InstanceID = b.InstanceID
        LEFT JOIN Application c ( NOLOCK ) ON b.AppID = c.AppID

WHERE   s.IsSQL = 1
		AND s.IsActive = 1
        AND s.SPConfigManaged = 1
        AND s.ServiceLevel IS NOT NULL
        AND a.ExecutionDateTime = 
        (select Max(ICV2.ExecutionDateTime) from Collector.InstanceConfig ICV2 where 
        ICV2.InstanceID = ICV.InstanceID)
  
  select * from #ServerList     
-----Delete ServiceLevels you don't need.
DELETE #ServerList
WHERE ServiceLevel <> @ServiceLevel
        
        
-----Delete values that are the same.  There's nothing to do if the values are the same.
DELETE SL 
FROM #ServerList SL
WHERE DesiredValue = RunValue   
      
-----Put the data into the typical #Final table used everywhere.

Select * 
into #Final 
from #ServerList

-----We're done with this table now.
DROP TABLE #ServerList

select * from #Final
   
--------------------------------------------------------------------

--------------- Enforce config value for those that have it set.
----------The Push job will send the change to the servers.
UPDATE ICV
SET Push = 1
FROM dbo.InstanceConfigValue ICV
INNER JOIN #Final F
on ICV.InstanceID = F.[InstanceID] AND ICV.Name = F.Name
WHERE F.[Action] = 'Enforce'

---------------------------------------------
------------- Log the history of the alert.--
---------------------------------------------
Insert into History.InstanceConfig
select
        [InstanceID] ,
        ServerName ,
        Name,
		DesiredValue,
		RunValue,
        @ExecutionDateTime ,
        ServiceLevel,
        [Action],
        AppName
FROM #Final        

 select @Distro =''    
 select @Distro=@Distro+EmailAddress+'; ' from  dbo.EmailNotification  a   
 order by EmailAddress   
 --select @Distro = left(@Distro, len(@Distro)-1)    
 --print @Distro      
            
 DECLARE @count tinyint                 
 DECLARE @CurrentSubject varchar(100)                
 select @count = COUNT(*) from #Final
 set @CurrentSubject = Cast(@count as varchar(10)) +' SpConfig Violations(' + @ServiceLevel + ')'        
 --select @CurrentSubject  
               
                
-- --Generate email string                
 DECLARE @tableHTML  NVARCHAR(MAX) ;                
 SET @tableHTML =                
 N'<H2>'+@CurrentSubject +'</H2>' +                
 N'<table border="1">' +                
    N'<tr>        
     <th>ServerName</th>                
     <th>Name</th>        
     <th>DesiredValue</th>                
     <th>RunValue</th>           
     <th>Action</th>
     <th>AppName</th></tr>' +         
                    
 CAST ( ( SELECT           
   td = ServerName, '',              
  td = Name, '',                
  td = DesiredValue, '',                
  td = RunValue, '',
  td = Action, '',                
  td = isnull(AppName, 'unknown'), ''        
   from         
  #Final  a(nolock)        
                     
 FOR XML PATH('tr'), TYPE                 
 ) AS NVARCHAR(MAX) ) +                
 N'</table>' ;                
 set @tableHTML =@tableHTML+'<BR>'                
 set @tableHTML =@tableHTML+'***Automated Report--Do NOT reply.***'                
-- PRINT @tableHTML    
 
--Send email only if there's something to report.                
 IF  @count >= 1      
     
    
 BEGIN         
                
 EXEC msdb.dbo.sp_send_dbmail                  
     @profile_name = @EmailProfile,                            
     @recipients = @Distro,                
     @subject = @CurrentSubject,                
     @body = @tableHTML,                
     @body_format = 'HTML';                
END                
return



;
GO
/****** Object:  StoredProcedure [Setup].[DiskSpaceException]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Setup].[DiskSpaceException]
(
@ServerName varchar(100),
@DriveName varchar(255)
)

  
AS

SET NOCOUNT ON

--SELECT * FROM Collector.DriveSpace

DECLARE @InstanceID INT,
		@DriveLetter VARCHAR(255),
		@Caption VARCHAR(255),
		@Label varchar(255),
		@AlreadyExists bit


SET @InstanceID = (SELECT InstanceID FROM dbo.Servers
WHERE ServerName = @ServerName)

--- Get the value from the DriveSpace table.
---This is the best way to make sure you've got the proper entry that's being
---reported on.  
---This also takes the data from the last collection period to make sure it's
---the most accurate.
SELECT  
@DriveLetter = DriveLetter,
@Caption = Caption,
@Label = Label
FROM Collector.DriveSpace
WHERE InstanceID = @InstanceID
AND Name = @DriveName
AND ExecutionDateTime IN (SELECT MAX(ExecutionDateTime) FROM Collector.DriveSpace WHERE InstanceID = @InstanceID)


SELECT @AlreadyExists = (SELECT COUNT(1) FROM dbo.DriveSpaceExceptions
WHERE InstanceID = @InstanceID
AND Caption = @DriveName)

---Only insert a new row if it doesn't already exist.
IF @AlreadyExists = 0
BEGIN 

	INSERT dbo.DriveSpaceExceptions(InstanceID, DriveLetter, Caption, Label)
	SELECT @InstanceID, @DriveLetter, @Caption, @Label

END

---If it exists, then update it instead.
IF @AlreadyExists = 1
BEGIN 

	UPDATE dbo.DriveSpaceExceptions
	SET
	  DriveLetter = @DriveLetter
	, Caption = @Caption
	, Label = @Label
	WHERE InstanceID = @InstanceID
	AND Caption = @Caption
	

END

SELECT 'Inserted Row',
	   @InstanceID AS InstanceID, 
	   @DriveLetter AS DriveLetter,
	   @Caption AS Caption,
	   @Label as Label

DECLARE @CT TINYINT

SET @CT = (SELECT COUNT(*) FROM dbo.DriveSpaceThresholds
WHERE InstanceID = @InstanceID
	  AND Caption = @Caption)

IF @CT > 0
	BEGIN	

		SELECT 'Logic problem.  Check messages for more info.'
		PRINT 'This server/disk also has a threshold in [dbo].[DriveSpaceThresholds].'
		PRINT 'This is a logical inconsistency because you cannot have and exception'
		PRINT 'to not report on the drive, and have a threshold for when it should be reported.'
		PRINT 'To remove the Threshold, run this command:'
		PRINT ''
		PRINT 'Setup.DiskSpaceThresholdDelete ' + CAST(@InstanceID AS VARCHAR(10)) + ', ''' + @Caption + '''' 

	END
EXEC servers.byname @ServerName





;
GO
/****** Object:  StoredProcedure [Setup].[DiskSpaceThreshold]    Script Date: 11/26/2015 18:47:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Setup].[DiskSpaceThreshold]

(

@ServerName varchar(100),
@DriveName varchar(255),
@AlertMethod varchar(10),
@AlertValue DECIMAL(4,2)

)

  
AS

SET NOCOUNT ON

--SELECT * FROM Collector.DriveSpace

DECLARE @InstanceID INT,
		@DriveLetter VARCHAR(255),
		@Caption VARCHAR(255),
		@Label varchar(255),
		@AlreadyExists bit

SET @InstanceID = (SELECT InstanceID FROM dbo.Servers
WHERE ServerName = @ServerName)

--- Get the value from the DriveSpace table.
---This is the best way to make sure you've got the proper entry that's being
---reported on.  
---This also takes the data from the last collection period to make sure it's
---the most accurate.

SELECT  

@DriveLetter = DriveLetter,
@Caption = Caption,
@Label = Label
FROM Collector.DriveSpace
WHERE InstanceID = @InstanceID
AND Name = @DriveName
AND ExecutionDateTime IN (SELECT MAX(ExecutionDateTime) FROM Collector.DriveSpace WHERE InstanceID = @InstanceID)


SELECT @AlreadyExists = (SELECT COUNT(1) FROM [dbo].[DriveSpaceThresholdDrive]
WHERE InstanceID = @InstanceID
AND Caption = @DriveName)

---Only insert a new row if it doesn't already exist.

IF @AlreadyExists = 0

BEGIN 

	INSERT dbo.DriveSpaceThresholdDrive(InstanceID, DriveLetter, Caption, Label, AlertMethod, AlertValue)
	SELECT @InstanceID, @DriveLetter, @Caption, @Label, @AlertMethod, @AlertValue

END

---If it exists, then update it instead.

IF @AlreadyExists = 1

BEGIN 



	UPDATE dbo.DriveSpaceThresholdDrive

	SET
	  DriveLetter = @DriveLetter
	, Caption = @Caption
	, Label = @Label
	, AlertMethod = @AlertMethod
	, AlertValue = @AlertValue
	WHERE InstanceID = @InstanceID
	AND Caption = @Caption

END

SELECT 'Inserted Row',
	   @InstanceID AS InstanceID, 
	   @DriveLetter AS DriveLetter,
	   @Caption AS Caption,
	   @Label as Label,
	   @AlertValue AS AlertValue

DECLARE @CT TINYINT

SET @CT = (SELECT COUNT(*) FROM dbo.DriveSpaceExceptions
WHERE InstanceID = @InstanceID
	  AND Caption = @Caption)



IF @CT > 0

	BEGIN	

		SELECT 'Logic problem.  Check messages for more info.'
		PRINT 'This server/disk also has an exception in [dbo].[DriveSpaceExceptions].'
		PRINT 'This is a logical inconsistency because you cannot have and exception'
		PRINT 'to not report on the drive, and have a threshold for when it should be reported.'
		PRINT 'To remove the exception, run this command:'
		PRINT ''
		PRINT 'Setup.DiskSpaceExceptionDelete ' + CAST(@InstanceID AS VARCHAR(10)) + ', ''' + @Caption + '''' 

	END

EXEC servers.byname @ServerName



;
GO
/****** Object:  Check [TBLimit]    Script Date: 11/26/2015 18:47:06 ******/
ALTER TABLE [dbo].[DBFilePropertiesConfig]  WITH CHECK ADD  CONSTRAINT [TBLimit] CHECK  (([MaxSizeValue]<=(2147483648.)))
GO
ALTER TABLE [dbo].[DBFilePropertiesConfig] CHECK CONSTRAINT [TBLimit]
GO
/****** Object:  Check [ckRbuildGTReorgTable]    Script Date: 11/26/2015 18:47:06 ******/
ALTER TABLE [dbo].[IndexSettingsTable]  WITH CHECK ADD  CONSTRAINT [ckRbuildGTReorgTable] CHECK  (([RebuildThreshold]>[ReorgThreshold]))
GO
ALTER TABLE [dbo].[IndexSettingsTable] CHECK CONSTRAINT [ckRbuildGTReorgTable]
GO
/****** Object:  Check [ckRebuildGTReorg]    Script Date: 11/26/2015 18:47:06 ******/
ALTER TABLE [dbo].[IndexSettingsDB]  WITH CHECK ADD  CONSTRAINT [ckRebuildGTReorg] CHECK  (([RebuildThreshold]>[ReorgThreshold]))
GO
ALTER TABLE [dbo].[IndexSettingsDB] CHECK CONSTRAINT [ckRebuildGTReorg]
GO
/****** Object:  ForeignKey [FK_ServerAppRoleApp_Application]    Script Date: 11/26/2015 18:47:07 ******/
ALTER TABLE [dbo].[ServerAppRoleApp]  WITH CHECK ADD  CONSTRAINT [FK_ServerAppRoleApp_Application] FOREIGN KEY([AppID])
REFERENCES [dbo].[Application] ([AppID])
GO
ALTER TABLE [dbo].[ServerAppRoleApp] CHECK CONSTRAINT [FK_ServerAppRoleApp_Application]
GO
/****** Object:  ForeignKey [FK_ServerAppRoleApp_ApplicationRole]    Script Date: 11/26/2015 18:47:07 ******/
ALTER TABLE [dbo].[ServerAppRoleApp]  WITH CHECK ADD  CONSTRAINT [FK_ServerAppRoleApp_ApplicationRole] FOREIGN KEY([AppRoleID])
REFERENCES [dbo].[ApplicationRole] ([AppRoleID])
GO
ALTER TABLE [dbo].[ServerAppRoleApp] CHECK CONSTRAINT [FK_ServerAppRoleApp_ApplicationRole]
GO
/****** Object:  ForeignKey [FK_ServerAppRoleApp_Servers]    Script Date: 11/26/2015 18:47:07 ******/
ALTER TABLE [dbo].[ServerAppRoleApp]  WITH NOCHECK ADD  CONSTRAINT [FK_ServerAppRoleApp_Servers] FOREIGN KEY([InstanceID])
REFERENCES [dbo].[Servers] ([InstanceID])
GO
ALTER TABLE [dbo].[ServerAppRoleApp] CHECK CONSTRAINT [FK_ServerAppRoleApp_Servers]
GO
