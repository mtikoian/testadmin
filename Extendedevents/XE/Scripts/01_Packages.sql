SELECT *
	FROM sys.dm_xe_packages;
	
SELECT p.*
FROM sys.dm_xe_packages p
WHERE (p.capabilities IS NULL 
		OR p.capabilities_desc <> 'private');
		
/* to see what module has loaded the package */
SELECT
	    p.name,
	    p.description,
	    lm.name 
	FROM sys.dm_xe_packages p
	JOIN sys.dm_os_loaded_modules lm
	    ON p.module_address = lm.base_address
	WHERE (p.capabilities IS NULL OR p.capabilities & 1 = 0)