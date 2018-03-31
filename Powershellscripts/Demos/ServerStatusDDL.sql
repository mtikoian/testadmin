USE [master]
GO

IF  EXISTS (SELECT name FROM sys.databases WHERE name = N'ServerAnalysis')
DROP DATABASE [ServerAnalysis]
GO

USE [master]
GO

CREATE DATABASE [ServerAnalysis] ON  PRIMARY 
( NAME = N'ServerAnalysis', FILENAME = N'E:\MSSQL10.INST01\MSSQL\DATA\ServerAnalysis.mdf' , SIZE = 51200KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'ServerAnalysis_log', FILENAME = N'F:\MSSQL10.INST01\MSSQL\Data\ServerAnalysis_log.ldf' , SIZE = 10240KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [ServerAnalysis] SET COMPATIBILITY_LEVEL = 100
GO

USE [ServerAnalysis]
GO
CREATE SCHEMA [Analysis]
GO
CREATE TABLE Analysis.ComputerSystem (
	box_id			int IDENTITY NOT NULL,
	Name			varchar(30) NOT NULL,
	Model			varchar(30) NULL,
	Manufacturer		varchar(30) NULL,
	Description		varchar(30) NULL,
	DNSHostName		varchar(30) NULL,
	Domain			varchar(30) NULL,
	DomainRole		int NULL,
	PartOfDomain		varchar(10) NULL,
	NumberOfProcessors	int NULL,
	SystemType		varchar(30) NULL,
	TotalPhysicalMemory	bigint NULL,
	UserName		varchar(30) NULL,
	Workgroup		varchar(30) NULL,
	CONSTRAINT PK_CompSys PRIMARY KEY CLUSTERED (box_id)
	)
GO

CREATE TABLE Analysis.OperatingSystem (
	os_id			int IDENTITY NOT NULL,
	box_id			int NOT NULL,
	Name			varchar(256) NULL,
	Version			varchar(30) NULL,
	FreePhysicalMemory	int NULL,
	OSLanguage		int NULL,
	OSProductSuite		int NULL,
	OSType			int NULL,
	ServicePackMajorVersion	int NULL,
	ServicePackMinorVersion	int NULL,
	CONSTRAINT PK_OperSys PRIMARY KEY CLUSTERED (os_id),
	CONSTRAINT FX_OperSys FOREIGN KEY (box_id) REFERENCES Analysis.ComputerSystem (box_id)
	)
GO

CREATE TABLE Analysis.PhysicalMemory (
	memory_id		int IDENTITY NOT NULL,
	box_id			int NOT NULL,
	Name			varchar(30) NULL,
	Capacity		bigint NULL,
	DeviceLocator		varchar(30) NULL,
	Tag			varchar(30) NULL,
	CONSTRAINT PK_PhysMem PRIMARY KEY CLUSTERED (memory_id),
	CONSTRAINT FX_PhysMem FOREIGN KEY (box_id) REFERENCES Analysis.ComputerSystem (box_id)
	)
GO

CREATE TABLE Analysis.LogicalDisk (
	disk_id			int IDENTITY NOT NULL,
	box_id			int NOT NULL,
	Name			varchar(30) NULL,
	FreeSpace		bigint NULL,
	Size			bigint NULL,
	CONSTRAINT PK_LogDisk PRIMARY KEY CLUSTERED (disk_id),
	CONSTRAINT FX_LogDisk FOREIGN KEY (box_id) REFERENCES Analysis.ComputerSystem (box_id)
	)
GO

CREATE TABLE Analysis.Instance (
	instance_id		int IDENTITY NOT NULL,
	box_id			int NOT NULL,
	Parent			varchar(30) NULL,
	Version			varchar(30) NULL,
	EngineEdition		varchar(30) NULL,
	Collation		varchar(30) NULL,
	Edition			varchar(30) NULL,
	ErrorLogPath		varchar(250) NULL,
	IsCaseSensitive		varchar(10) NULL,
	IsClustered		varchar(10) NULL,
	IsFullTextInstalled	varchar(10) NULL,
	IsSingleUser		varchar(10) NULL,
	Language		varchar(30) NULL,
	MasterDBLogPath		varchar(250) NULL,
	MasterDBPath		varchar(250) NULL,
	MaxPrecision		int NULL,
	NetName			varchar(30) NULL,
	OSVersion		varchar(30) NULL,
	PhysicalMemory		int NULL,
	Platform		varchar(30) NULL,
	Processors		int NULL,
	Product			varchar(30) NULL,
	ProductLevel		varchar(30) NULL,
	RootDirectory		varchar(250) NULL,
	VersionString		varchar(30) NULL,
	Urn			varchar(250) NULL,
	Properties		varchar(250) NULL,
	UserData		varchar(250) NULL,
	State			varchar(10) NULL,
	CONSTRAINT PK_Instance PRIMARY KEY CLUSTERED (instance_id),
	CONSTRAINT FX_Instance FOREIGN KEY (box_id) REFERENCES Analysis.ComputerSystem (box_id)
	)
GO

CREATE TABLE Analysis.Configuration (
	config_id		int IDENTITY NOT NULL,
	instance_id		int NOT NULL,
	Name			varchar(100) NULL,
	Minimum			bigint NULL,
	Maximum			bigint NULL,
	Config_Value		bigint NULL,
	Run_Value		bigint NULL,
	CONSTRAINT PK_Config PRIMARY KEY CLUSTERED (config_id),
	CONSTRAINT FX_Config FOREIGN KEY (instance_id) REFERENCES Analysis.Instance (instance_id)
	)
GO

CREATE TABLE Analysis.Logins (
	login_id		int IDENTITY NOT NULL,
	instance_id		int NOT NULL,
	Name			varchar(100) NULL,
	DefaultDatabase		varchar(100) NULL,
	CONSTRAINT PK_Logins PRIMARY KEY CLUSTERED (login_id),
	CONSTRAINT FX_Logins FOREIGN KEY (instance_id) REFERENCES Analysis.Instance (instance_id)
	)
GO

CREATE TABLE Analysis.Databases (
	database_id		int IDENTITY NOT NULL,
	instance_id		int NOT NULL,
	Name			varchar(100) NULL,
	Collation		varchar(100) NULL,
	CompatibilityLevel	varchar(10) NULL,
	AutoShrink		varchar(10) NULL,
	RecoveryModel		varchar(10) NULL,
	Size			numeric(18,4) NULL,
	SpaceAvailable		numeric(18,4) NULL,
	CONSTRAINT PK_Databases PRIMARY KEY CLUSTERED (database_id),
	CONSTRAINT FX_Databases FOREIGN KEY (instance_id) REFERENCES Analysis.Instance (instance_id)
	)
GO

CREATE TABLE Analysis.Users (
	user_id			int IDENTITY NOT NULL,
	database_id		int NOT NULL,
	Name			varchar(100) NULL,
	Login			varchar(100) NULL,
	LoginType		varchar(100) NULL,
	UserType		varchar(100) NULL,
	CreateDate		datetime NULL,
	CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (user_id),
	CONSTRAINT FX_Users FOREIGN KEY (database_id) REFERENCES Analysis.Databases (database_id)
	)
GO

CREATE TABLE Analysis.Files (
	file_id			int IDENTITY NOT NULL,
	database_id		int NOT NULL,
	Name			varchar(250) NULL,
	FileName		varchar(500) NULL,
	Size			bigint NULL,
	UsedSpace		bigint NULL,
	CONSTRAINT PK_Files PRIMARY KEY CLUSTERED (file_id),
	CONSTRAINT FX_Files FOREIGN KEY (database_id) REFERENCES Analysis.Databases (database_id)
	)
GO
