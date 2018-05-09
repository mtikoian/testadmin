-- Log shipping monitoring stored procedures for Primary server

-- Confirm server name
SELECT @@SERVERNAME AS [Server Name];

USE master;
GO

-- Returns information for registered primary and secondary databases 
-- on a primary, secondary, or monitor server
EXEC sp_help_log_shipping_monitor; 

-- sp_help_log_shipping_monitor (Transact-SQL)
-- http://bit.ly/2yHPe8l


-- Returns information about the primary database
EXEC sp_help_log_shipping_monitor_primary @primary_server = N'LABDB03', 
                                          @primary_database = N'AdventureWorksLT2008R2';

-- sp_help_log_shipping_monitor_primary (Transact-SQL)
-- http://bit.ly/2yJ4KAS


-- Returns the job ID of the alert job (if you don't have a monitor instance)
EXEC sp_help_log_shipping_alert_job;

-- sp_help_log_shipping_alert_job (Transact-SQL)
-- http://bit.ly/2wXyCHg

-- Returns primary database settings
EXEC sp_help_log_shipping_primary_database @database = N'AdventureWorksLT2008R2';

-- sp_help_log_shipping_primary_database (Transact-SQL)
-- http://bit.ly/2y9F5nI


-- Returns information for all secondary databases for this primary database
EXEC sp_help_log_shipping_primary_secondary @primary_database = N'AdventureWorksLT2008R2';

-- sp_help_log_shipping_primary_secondary (Transact-SQL)
-- http://bit.ly/2wW8KR8