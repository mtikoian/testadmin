-- Log shipping monitoring queries for Monitor server

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


-- Returns log shipping information from primary server
SELECT primary_server, primary_database, backup_threshold, threshold_alert, 
       threshold_alert_enabled, last_backup_file, last_backup_date, history_retention_period
FROM msdb.dbo.log_shipping_monitor_primary;


-- Returns log shipping information from secondary server
SELECT secondary_server, secondary_database, primary_server, primary_database,
       last_copied_file, last_copied_date, last_restored_file, last_restored_date
FROM msdb.dbo.log_shipping_monitor_secondary;


