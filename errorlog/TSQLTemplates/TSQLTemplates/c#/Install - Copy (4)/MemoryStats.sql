SELECT  [type],
        single_pages_kb,
        multi_pages_kb,
        virtual_memory_committed_kb,
        virtual_memory_reserved_kb,
        shared_memory_committed_kb,
        shared_memory_reserved_kb
FROM    sys.dm_os_memory_clerks
ORDER BY virtual_memory_reserved_kb + shared_memory_reserved_kb DESC;

SELECT  [name],
        [type],
        single_pages_kb + multi_pages_kb AS total_kb,
        entries_count
FROM    sys.dm_os_memory_cache_counters
ORDER BY total_kb DESC;

SELECT  objtype,
        usecounts,
        COUNT(1) countofplans,
        SUM(size_in_bytes)/1024 sumofsize
FROM    sys.dm_exec_cached_plans
WHERE   usecounts < 5
GROUP BY objtype, usecounts
ORDER BY sumofsize DESC;

-- DBCC FREESYSTEMCACHE('SQL Plans')