/****** Object:  StoredProcedure [Analysis].[insComputerSystem]    Script Date: 08/11/2009 21:21:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Analysis].[insComputerSystem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [Analysis].[insComputerSystem]
           (@box_id		int OUTPUT
           ,@Name		varchar(30) = NULL
           ,@Model		varchar(30) = NULL
           ,@Manufacturer	varchar(30) = NULL
           ,@Description	varchar(30) = NULL
           ,@DNSHostName	varchar(30) = NULL
           ,@Domain		varchar(30) = NULL
           ,@DomainRole		int = NULL
           ,@PartOfDomain	varchar(10) = NULL
           ,@NumberOfProcessors	int = NULL
           ,@SystemType		varchar(30) = NULL
           ,@TotalPhysicalMemory	bigint = NULL
           ,@UserName		varchar(30) = NULL
           ,@Workgroup		varchar(30) = NULL)
AS
	SET NOCOUNT ON
	
	DECLARE @BoxOut table( box_id int);

	INSERT INTO [Analysis].[ComputerSystem]
		   ([Name]
		   ,[Model]
		   ,[Manufacturer]
		   ,[Description]
		   ,[DNSHostName]
		   ,[Domain]
		   ,[DomainRole]
		   ,[PartOfDomain]
		   ,[NumberOfProcessors]
		   ,[SystemType]
		   ,[TotalPhysicalMemory]
		   ,[UserName]
		   ,[Workgroup])
	     OUTPUT INSERTED.box_id INTO @BoxOut
	     VALUES
		   (@Name
		   ,@Model
		   ,@Manufacturer
		   ,@Description
		   ,@DNSHostName
		   ,@Domain
		   ,@DomainRole
		   ,@PartOfDomain
		   ,@NumberOfProcessors
		   ,@SystemType
		   ,@TotalPhysicalMemory
		   ,@UserName
		   ,@Workgroup)

	SELECT @box_id = box_id FROM @BoxOut
	
	RETURN
' 
END
GO
/****** Object:  StoredProcedure [Analysis].[insLogicalDisk]    Script Date: 08/11/2009 21:21:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Analysis].[insLogicalDisk]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [Analysis].[insLogicalDisk]
		   (@box_id	int=NULL
		   ,@Name	varchar(30)=NULL
		   ,@FreeSpace	bigint=NULL
		   ,@Size	bigint=NULL)
AS
	SET NOCOUNT ON
	
	INSERT INTO [Analysis].[LogicalDisk]
		   ([box_id]
		   ,[Name]
		   ,[FreeSpace]
		   ,[Size])
	     VALUES
		   (@box_id
		   ,@Name
		   ,@FreeSpace
		   ,@Size)
	
	RETURN
' 
END
GO
/****** Object:  StoredProcedure [Analysis].[insInstance]    Script Date: 08/11/2009 21:21:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Analysis].[insInstance]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [Analysis].[insInstance]
           (@instance_id	int OUTPUT
	   ,@box_id		int = NULL
	   ,@Parent		varchar(30) = NULL
	   ,@Version		varchar(30) = NULL
	   ,@EngineEdition	varchar(30) = NULL
	   ,@Collation		varchar(30) = NULL
	   ,@Edition		varchar(30) = NULL
	   ,@ErrorLogPath	varchar(250) = NULL
	   ,@IsCaseSensitive	varchar(10) = NULL
	   ,@IsClustered	varchar(10) = NULL
	   ,@IsFullTextInstalled	varchar(10) = NULL
	   ,@IsSingleUser	varchar(10) = NULL
	   ,@Language		varchar(30) = NULL
	   ,@MasterDBLogPath	varchar(250) = NULL
	   ,@MasterDBPath	varchar(250) = NULL
	   ,@MaxPrecision	int = NULL
	   ,@NetName		varchar(30) = NULL
	   ,@OSVersion		varchar(30) = NULL
	   ,@PhysicalMemory	int = NULL
	   ,@Platform		varchar(30) = NULL
	   ,@Processors		int = NULL
	   ,@Product		varchar(30) = NULL
	   ,@ProductLevel	varchar(30) = NULL
	   ,@RootDirectory	varchar(250) = NULL
	   ,@VersionString	varchar(30) = NULL
	   ,@Urn		varchar(250) = NULL
	   ,@Properties		varchar(250) = NULL
	   ,@UserData		varchar(250) = NULL
	   ,@State		varchar(10) = NULL)
AS
	SET NOCOUNT ON
	
	DECLARE @InstOut table( instance_id int);

	INSERT INTO [Analysis].[Instance]
		   ([box_id]
		   ,[Parent]
		   ,[Version]
		   ,[EngineEdition]
		   ,[Collation]
		   ,[Edition]
		   ,[ErrorLogPath]
		   ,[IsCaseSensitive]
		   ,[IsClustered]
		   ,[IsFullTextInstalled]
		   ,[IsSingleUser]
		   ,[Language]
		   ,[MasterDBLogPath]
		   ,[MasterDBPath]
		   ,[MaxPrecision]
		   ,[NetName]
		   ,[OSVersion]
		   ,[PhysicalMemory]
		   ,[Platform]
		   ,[Processors]
		   ,[Product]
		   ,[ProductLevel]
		   ,[RootDirectory]
		   ,[VersionString]
		   ,[Urn]
		   ,[Properties]
		   ,[UserData]
		   ,[State])
	     OUTPUT INSERTED.instance_id INTO @InstOut
	     VALUES
		   (@box_id
		   ,@Parent
		   ,@Version
		   ,@EngineEdition
		   ,@Collation
		   ,@Edition
		   ,@ErrorLogPath
		   ,@IsCaseSensitive
		   ,@IsClustered
		   ,@IsFullTextInstalled
		   ,@IsSingleUser
		   ,@Language
		   ,@MasterDBLogPath
		   ,@MasterDBPath
		   ,@MaxPrecision
		   ,@NetName
		   ,@OSVersion
		   ,@PhysicalMemory
		   ,@Platform
		   ,@Processors
		   ,@Product
		   ,@ProductLevel
		   ,@RootDirectory
		   ,@VersionString
		   ,@Urn
		   ,@Properties
		   ,@UserData
		   ,@State)
	SELECT @instance_id = instance_id FROM @InstOut
	
	RETURN
' 
END
GO
/****** Object:  StoredProcedure [Analysis].[insPhysicalMemory]    Script Date: 08/11/2009 21:21:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Analysis].[insPhysicalMemory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [Analysis].[insPhysicalMemory]
		   (@box_id		int=NULL
		   ,@Name		varchar(30)=NULL
		   ,@Capacity		bigint=NULL
		   ,@DeviceLocator	varchar(30)=NULL
		   ,@Tag		varchar(30)=NULL)
AS
	SET NOCOUNT ON
	
	INSERT INTO [Analysis].[PhysicalMemory]
		   ([box_id]
		   ,[Name]
		   ,[Capacity]
		   ,[DeviceLocator]
		   ,[Tag])
	     VALUES
		   (@box_id
		   ,@Name
		   ,@Capacity
		   ,@DeviceLocator
		   ,@Tag)
	
	RETURN
' 
END
GO
/****** Object:  StoredProcedure [Analysis].[insOperatingSystem]    Script Date: 08/11/2009 21:21:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Analysis].[insOperatingSystem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [Analysis].[insOperatingSystem]
		   (@box_id			int=NULL
		   ,@Name			varchar(256)=NULL
		   ,@Version			varchar(30)=NULL
		   ,@FreePhysicalMemory		int=NULL
		   ,@OSLanguage			int=NULL
		   ,@OSProductSuite		int=NULL
		   ,@OSType			int=NULL
		   ,@ServicePackMajorVersion	int=NULL
		   ,@ServicePackMinorVersion	int=NULL)
AS
	SET NOCOUNT ON
	
	INSERT INTO [Analysis].[OperatingSystem]
		   ([box_id]
		   ,[Name]
		   ,[Version]
		   ,[FreePhysicalMemory]
		   ,[OSLanguage]
		   ,[OSProductSuite]
		   ,[OSType]
		   ,[ServicePackMajorVersion]
		   ,[ServicePackMinorVersion])
	     VALUES
		   (@box_id
		   ,@Name
		   ,@Version
		   ,@FreePhysicalMemory
		   ,@OSLanguage
		   ,@OSProductSuite
		   ,@OSType
		   ,@ServicePackMajorVersion
		   ,@ServicePackMinorVersion)
	
	RETURN
' 
END
GO
/****** Object:  StoredProcedure [Analysis].[insLogins]    Script Date: 08/11/2009 21:21:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Analysis].[insLogins]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [Analysis].[insLogins]
		   (@instance_id	int=NULL
		   ,@Name		varchar(100)=NULL
		   ,@DefaultDatabase	varchar(100)=NULL)
AS
	SET NOCOUNT ON
	
	INSERT INTO [Analysis].[Logins]
		   ([instance_id]
		   ,[Name]
		   ,[DefaultDatabase])
	     VALUES
		   (@instance_id
		   ,@Name
		   ,@DefaultDatabase)

	RETURN
' 
END
GO
/****** Object:  StoredProcedure [Analysis].[insDatabases]    Script Date: 08/11/2009 21:21:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Analysis].[insDatabases]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [Analysis].[insDatabases]
		   (@dbid		int OUTPUT
		   ,@instance_id	int=NULL
		   ,@Name		varchar(100)=NULL
		   ,@Collation		varchar(100)=NULL
		   ,@CompatibilityLevel	varchar(10)=NULL
		   ,@AutoShrink		varchar(10)=NULL
		   ,@RecoveryModel	varchar(10)=NULL
		   ,@Size		numeric(10,4)=NULL
		   ,@SpaceAvailable	numeric(10,4)=NULL)
AS
	SET NOCOUNT ON

	DECLARE @DBOut table( database_id int);
	
	INSERT INTO [Analysis].[Databases]
		   ([instance_id]
		   ,[Name]
		   ,[Collation]
		   ,[CompatibilityLevel]
		   ,[AutoShrink]
		   ,[RecoveryModel]
		   ,[Size]
		   ,[SpaceAvailable])
	     OUTPUT INSERTED.database_id INTO @DBOut
	     VALUES
		   (@instance_id
		   ,@Name
		   ,@Collation
		   ,@CompatibilityLevel
		   ,@AutoShrink
		   ,@RecoveryModel
		   ,@Size
		   ,@SpaceAvailable)

	SELECT @dbid = database_id FROM @DBOut

	RETURN
' 
END
GO
/****** Object:  StoredProcedure [Analysis].[insConfiguration]    Script Date: 08/11/2009 21:21:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Analysis].[insConfiguration]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [Analysis].[insConfiguration]
		   (@instance_id	int=NULL
		   ,@Name		varchar(100)=NULL
		   ,@Minimum		bigint=NULL
		   ,@Maximum		bigint=NULL
		   ,@Config_Value	bigint=NULL
		   ,@Run_Value		bigint=NULL)
AS
	SET NOCOUNT ON
	
	INSERT INTO [Analysis].[Configuration]
		   ([instance_id]
		   ,[Name]
		   ,[Minimum]
		   ,[Maximum]
		   ,[Config_Value]
		   ,[Run_Value])
	     VALUES
		   (@instance_id
		   ,@Name
		   ,@Minimum
		   ,@Maximum
		   ,@Config_Value
		   ,@Run_Value)
	
	RETURN
' 
END
GO
/****** Object:  StoredProcedure [Analysis].[insUsers]    Script Date: 08/11/2009 21:21:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Analysis].[insUsers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [Analysis].[insUsers]
		   (@database_id	int=NULL
		   ,@Name		varchar(256)=NULL
		   ,@Login		varchar(100)=NULL
		   ,@LoginType		varchar(100)=NULL
		   ,@UserType		varchar(100)=NULL
		   ,@CreateDate		datetime=NULL)
AS
	SET NOCOUNT ON
	
	INSERT INTO [Analysis].[Users]
		   ([database_id]
		   ,[Name]
		   ,[Login]
		   ,[LoginType]
		   ,[UserType]
		   ,[CreateDate])
	     VALUES
		   (@database_id
		   ,@Name
		   ,@Login
		   ,@LoginType
		   ,@UserType
		   ,@CreateDate)
	
	RETURN
' 
END
GO
/****** Object:  StoredProcedure [Analysis].[insFiles]    Script Date: 08/11/2009 21:21:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Analysis].[insFiles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROCEDURE [Analysis].[insFiles]
		   (@database_id	int=NULL
		   ,@Name		varchar(250)=NULL
		   ,@FileName		varchar(500)=NULL
		   ,@Size		bigint=NULL
		   ,@UsedSpace		bigint=NULL)
AS
	SET NOCOUNT ON
	
	INSERT INTO [Analysis].[Files]
		   ([database_id]
		   ,[Name]
		   ,[FileName]
		   ,[Size]
		   ,[UsedSpace])
	     VALUES
		   (@database_id
		   ,@Name
		   ,@FileName
		   ,@Size
		   ,@UsedSpace)
	
	RETURN
' 
END
GO
