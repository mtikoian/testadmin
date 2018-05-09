-- Log shipping monitoring queries for Secondary server

-- Confirm server name
SELECT @@SERVERNAME AS [Server Name];

-- Returns any log shipping errors
SELECT log_time, [message], [database_name], [source]
FROM msdb.dbo.log_shipping_monitor_error_detail
ORDER BY log_time DESC;


-- Returns recent log shipping history information
SELECT TOP (100) log_time, [message], [database_name]
FROM msdb.dbo.log_shipping_monitor_history_detail
ORDER BY log_time DESC;


-- Returns log shipping information from secondary server
SELECT secondary_server, secondary_database, primary_server, primary_database,
       last_copied_file, last_copied_date, last_restored_file, last_restored_date
FROM msdb.dbo.log_shipping_monitor_secondary;


-- Returns information about any secondary databases on the secondary server
SELECT secondary_database, restore_mode, last_restored_file, last_restored_date,
	   disconnect_users
FROM msdb.dbo.log_shipping_secondary_databases;


