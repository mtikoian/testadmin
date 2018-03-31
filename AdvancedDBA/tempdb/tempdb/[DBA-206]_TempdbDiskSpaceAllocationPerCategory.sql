-- Tempdb disk space allocation per category
SELECT FreePages = SUM(unallocated_extent_page_count),
	FreeSpaceMB = SUM(unallocated_extent_page_count)/128.0,
	VersionStorePages = SUM(version_store_reserved_page_count),
	VersionStoreMB = SUM(version_store_reserved_page_count)/128.0,
	InternalObjectPages = SUM(internal_object_reserved_page_count),
	InternalObjectsMB = SUM(internal_object_reserved_page_count)/128.0,
	UserObjectPages = SUM(user_object_reserved_page_count),
	UserObjectsMB = SUM(user_object_reserved_page_count)/128.0
FROM sys.dm_db_file_space_usage;
