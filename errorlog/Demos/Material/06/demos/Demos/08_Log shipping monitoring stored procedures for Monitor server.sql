-- Log shipping monitoring stored procedures for Monitor server

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


-- Returns information about the primary database
EXEC sp_help_log_shipping_monitor_primary @primary_server = N'LABDB03', 
                                          @primary_database = N'AdventureWorksLT2008R2';

-- sp_help_log_shipping_monitor_primary (Transact-SQL)
-- http://bit.ly/2yJ4KAS



-- Returns the job ID of the alert job 
EXEC sp_help_log_shipping_alert_job;

-- sp_help_log_shipping_alert_job (Transact-SQL)
-- http://bit.ly/2wXyCHg


