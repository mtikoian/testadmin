/******************************************************************************
	Extended Events Wait Time Analysis

	Authors: Thomas Kejser (Microsoft), Mario Broodbakker (HP)
	Contributors: Jerome Hallmans (Microsoft), Raoul Illyes (MiracleAS), Sanjay Mishra (Microsoft)

	Description: Track waitstats for a specific session 
	
********************************************************************************/

USE [master]
GO

CREATE DATABASE [XEdb] ON  PRIMARY 
( NAME = N'XEdb', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\XEdb.mdf', SIZE = 50MB, MAXSIZE = UNLIMITED, FILEGROWTH = 1MB )
 LOG ON 
( NAME = N'XEdb_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL10.MSSQLSERVER\MSSQL\DATA\XEdb_log.ldf' , SIZE = 50MB , MAXSIZE = 60MB , FILEGROWTH = 1MB)
COLLATE SQL_Latin1_General_Cp1_CI_AI
GO

ALTER DATABASE [XEdb] SET RECOVERY SIMPLE
GO

