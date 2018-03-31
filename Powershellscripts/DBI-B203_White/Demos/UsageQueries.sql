/* Get Usage History for Databases */
SELECT i.[Parent], d.[Name], u.[Size], u.[SpaceAvailable], u.[UsageDate]
FROM Analysis.Databases d
INNER JOIN Analysis.Instance i ON d.instance_id = i.instance_id
INNER JOIN Analysis.DatabaseUsage u ON d.database_id = d.database_id
ORDER BY i.instance_id, d.database_id, u.[UsageDate]
GO

/* Get Server Info */
SELECT c.[Name], c.[Model], c.[NumberOfProcessors], c.[TotalPhysicalMemory],
	o.[Version] AS OSVersion, d.[Name] AS [Drive],
	CONVERT(float,d.[Size]) / 1073741824 AS [SizeInGB],
	CONVERT(float,d.[FreeSpace]) / 1073741824 AS [FreeInGB]
FROM Analysis.ComputerSystem c
INNER JOIN Analysis.OperatingSystem o ON c.box_id = o.box_id
INNER JOIN Analysis.LogicalDisk d ON c.box_id = d.box_id
ORDER BY c.box_id, d.disk_id
GO

/* Get Instance Info */
SELECT i.[Parent], i.[Version], i.[Edition], i.[IsClustered], i.[Collation]
FROM Analysis.Instance i
ORDER BY i.instance_id
GO

/* Check Key Config Settings */
SELECT i.[Parent], c.[Name], c.[Config_Value], c.[Run_Value]
FROM Analysis.Instance i
INNER JOIN Analysis.Configuration c ON i.instance_id = c.instance_id
WHERE c.[Name] IN (
	'max server memory (MB)',
	'min server memory (MB)',
	'max degree of parallelism',
	'affinity mask')
ORDER BY c.[Name], i.[instance_id]
GO

/* Get Database Settings */
SELECT i.[Parent], d.[Name], d.[RecoveryModel], d.[CompatibilityLevel], d.[AutoShrink], d.[Collation]
FROM Analysis.Databases d
INNER JOIN Analysis.Instance i ON d.instance_id = i.instance_id
ORDER BY i.instance_id, d.database_id
GO
