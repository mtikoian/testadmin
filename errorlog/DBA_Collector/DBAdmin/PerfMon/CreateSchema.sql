DECLARE @SQL NVARCHAR(MAX);

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'PerfMon')
	EXEC('CREATE SCHEMA PerfMon');

IF OBJECT_ID('PerfMon.stgCounterData') IS NOT NULL
	DROP TABLE PerfMon.stgCounterData;

CREATE TABLE PerfMon.stgCounterData
(
	CounterDate DATETIME,
	CounterHour INT,
	CounterMinute INT,
	MachineName VARCHAR(255),
	ObjectName VARCHAR(255),
	InstanceName VARCHAR(255),
	CounterName VARCHAR(255),
	CounterValue FLOAT
);

IF OBJECT_ID('PerfMon.dimCounter') IS NOT NULL
	DROP TABLE PerfMon.dimCounter;

CREATE TABLE [PerfMon].[dimCounter](
	[CounterKey] [bigint] IDENTITY(1,1) NOT NULL,
	[MachineName] [varchar](1024) NOT NULL,
	[ObjectName] [varchar](1024) NOT NULL,
	[InstanceName] [varchar](1024),
	[CounterName] [varchar](1024) NOT NULL
) ON [PRIMARY];

IF OBJECT_ID('PerfMon.factCounterData') IS NOT NULL
	DROP TABLE PerfMon.factCounterData;

CREATE TABLE [PerfMon].[factCounterData](
	[CounterDate] [DATETIME] NOT NULL,
	[CounterHour] [INT] NOT NULL,
	[CounterMinute] [INT] NOT NULL,
	[CounterValue] [float] NOT NULL,
	[CounterKey] [bigint] NOT NULL
);

IF OBJECT_ID('PerfMon.p_LoadCounterData') IS NOT NULL
	DROP PROCEDURE PerfMon.p_LoadCounterData;

SELECT @SQL = 
'
CREATE PROCEDURE [PerfMon].[p_LoadCounterData]
AS
BEGIN

	INSERT	PerfMon.dimCounter
	(
		MachineName,
		ObjectName,
		InstanceName,
		CounterName
	)
	SELECT	DISTINCT
			MachineName,
			ObjectName,
			InstanceName,
			CounterName
	FROM	PerfMon.stgCounterData;
	
	INSERT	PerfMon.factCounterData
	(
		CounterDate,
		CounterHour,
		CounterMinute,
		CounterKey,
		CounterValue
	)
	SELECT	s.CounterDate,
			s.CounterHour,
			s.CounterMinute,
			dc.CounterKey,
			ISNULL(s.CounterValue,0)
	FROM	PerfMon.stgCounterData s 
				JOIN PerfMon.dimCounter dc
					ON s.MachineName = dc.MachineName
					AND s.ObjectName = dc.ObjectName
					AND ISNULL(s.InstanceName,''None'') = ISNULL(dc.InstanceName,''None'')
					AND s.CounterName = dc.CounterName;
					
END';
EXEC(@SQL);