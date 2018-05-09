-- Log shipping monitoring stored procedures for Secondary server

-- Confirm server name
SELECT @@SERVERNAME AS [Server Name];

USE master;
GO

-- Returns information for registered primary and secondary databases 
-- on a primary, secondary, or monitor server
EXEC sp_help_log_shipping_monitor; 

-- sp_help_log_shipping_monitor (Transact-SQL)
-- http://bit.ly/2yHPe8l


-- Returns information about the secondary database
EXEC sp_help_log_shipping_monitor_secondary @secondary_server = N'LABDB04',
                                            @secondary_database = N'AdventureWorksLT2008R2';

-- sp_help_log_shipping_monitor_secondary (Transact-SQL)
-- http://bit.ly/2xGrgf9



-- Returns the job ID of the alert job (if you don't have a monitor instance)
EXEC sp_help_log_shipping_alert_job;

-- sp_help_log_shipping_alert_job (Transact-SQL)
-- http://bit.ly/2wXyCHg


-- Returns secondary database settings
EXEC sp_help_log_shipping_secondary_database @secondary_database = N'AdventureWorksLT2008R2';

-- sp_help_log_shipping_secondary_database (Transact-SQL)
-- http://bit.ly/2wkfdB5


-- Returns the settings for a given primary database on the secondary server
EXEC sp_help_log_shipping_secondary_primary @primary_server = N'LABDB03',
                                            @primary_database = N'AdventureWorksLT2008R2';  

-- sp_help_log_shipping_secondary_primary (Transact-SQL)
-- http://bit.ly/2hxFadI