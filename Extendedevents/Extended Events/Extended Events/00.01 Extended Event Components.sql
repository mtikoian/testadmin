-- Packages  - Domains of information
-- NOTE: Ignore package 'SecAudit' it is for the Audit features.
SELECT xp.name, xp.description
FROM sys.dm_xe_packages xp

-- Event - think of as base tables
SELECT xo.object_type, xp.[name] as PackageName, xo.name AS EventName, xo.description
FROM sys.dm_xe_objects xo
    INNER JOIN sys.dm_xe_packages xp ON xp.[guid] = xo.[package_guid]
WHERE xo.[object_type] = 'event'
AND xp.[name] <>  'SecAudit'
ORDER BY 2, 3

-- Action - data to join
SELECT xo.object_type, xp.[name] as PackageName, xo.name AS ActionName, xo.description
FROM sys.dm_xe_objects xo
    INNER JOIN sys.dm_xe_packages xp ON xp.[guid] = xo.[package_guid]
WHERE xo.[object_type] = 'action'
ORDER BY xp.[name], xo.[name]

-- Predicate (Columns) - columns, where filters
SELECT xoc.object_name, xoc.name, xoc.description, xoc.type_name
FROM sys.dm_xe_object_columns xoc
WHERE [object_name] = 'wait_info'
ORDER BY 2

-- Target - destinations
SELECT xo.object_type, xp.[name] as PackageName, xo.name AS TargetName, xo.description
FROM sys.dm_xe_objects xo
    INNER JOIN sys.dm_xe_packages xp ON xp.[guid] = xo.[package_guid]
WHERE xo.[object_type] = 'target'
AND xp.[name] <>  'SecAudit'
ORDER BY xp.[name], xo.[name];

-- Type - data types
SELECT xo.object_type, xp.[name] as PackageName, xo.name AS TypeName, xo.description
FROM sys.dm_xe_objects xo
    INNER JOIN sys.dm_xe_packages xp ON xp.[guid] = xo.[package_guid]
WHERE xo.[object_type] = 'type'
ORDER BY xp.[name], xo.[name]

-- Map - mapping of values in XEvents 
SELECT xmv.name, xmv.map_key, xmv.map_value
FROM sys.dm_xe_map_values xmv
WHERE name = 'wait_types'
