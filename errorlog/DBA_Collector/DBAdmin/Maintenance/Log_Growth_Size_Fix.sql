SELECT	d.name,
		mf1.name DataFileName,
		mf1.size * 8 / 1024 DataFileSize,
		mf2.name LogFileName,
		mf2.size * 8 / 1024 LogFileSize,
		(mf2.size * 8 / 1024) / (mf1.size * 8 / 1024) * 100 LogFilePercentOfDataFile,
		'USE ' + QUOTENAME(d.name) + '; DBCC SHRINKFILE (N''' + mf2.name + ''',0, TRUNCATEONLY)' ShrinkFile,
		'USE ' + QUOTENAME(d.name) + '; ALTER DATABASE ' 
			+ QUOTENAME(d.name) + ' MODIFY FILE (NAME = ''' + mf2.name + ''', SIZE = ' 
			+ CASE 
				WHEN (mf1.size * 8 / 1024 * 0.25) < (mf2.size * 8 / 1024) THEN CAST(CAST((mf2.size * 8 / 1024) AS INT) AS VARCHAR)
				ELSE CAST(CAST((mf1.size * 8 / 1024 * 0.25) AS INT) AS VARCHAR)
			  END + ' MB );' GrowCommand
FROM	sys.master_files mf1
			JOIN sys.master_files mf2
				ON mf1.database_id = mf2.database_id
				AND mf1.type = 0
				AND mf2.type = 1
			JOIN sys.databases d 
				ON mf1.database_id = d.database_id
				AND d.database_id > 4
				