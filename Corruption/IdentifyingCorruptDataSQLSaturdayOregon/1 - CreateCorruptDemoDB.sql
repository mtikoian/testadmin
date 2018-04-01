USE master;


IF DB_ID('CorruptDemoDB') IS NOT NULL
BEGIN

	ALTER DATABASE CorruptDemoDB
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

	DROP DATABASE [CorruptDemoDB];

END

CREATE DATABASE [CorruptDemoDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CorruptDemoDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.AGSQLSERVER\MSSQL\DATA\CorruptDemoDB.mdf' , SIZE = 102400KB , FILEGROWTH = 102400KB )
 LOG ON 
( NAME = N'CorruptDemoDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.AGSQLSERVER\MSSQL\DATA\CorruptDemoDB_log.ldf' , SIZE = 25600KB , FILEGROWTH = 25600KB )
GO
ALTER DATABASE [CorruptDemoDB] SET COMPATIBILITY_LEVEL = 120
GO
ALTER DATABASE [CorruptDemoDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET AUTO_CREATE_STATISTICS ON
GO
ALTER DATABASE [CorruptDemoDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CorruptDemoDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CorruptDemoDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [CorruptDemoDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CorruptDemoDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CorruptDemoDB] SET  READ_WRITE 
GO
ALTER DATABASE [CorruptDemoDB] SET RECOVERY FULL 
GO
ALTER DATABASE [CorruptDemoDB] SET  MULTI_USER 
GO
ALTER DATABASE [CorruptDemoDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CorruptDemoDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [CorruptDemoDB] SET DELAYED_DURABILITY = DISABLED 
GO
USE [CorruptDemoDB]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [CorruptDemoDB] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO
