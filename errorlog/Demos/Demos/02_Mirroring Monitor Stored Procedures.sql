-- Database Mirroring Monitor Stored Procedures

-- Creates a database mirroring monitor job that periodically updates 
-- the mirroring status for every mirrored database on the server instance, with update interval
EXEC sp_dbmmonitoraddmonitoring 1;

-- sp_dbmmonitoraddmonitoring (Transact-SQL)
-- http://bit.ly/2yFyv4a


-- Adds or changes warning threshold for a specified mirroring performance metric
EXEC sp_dbmmonitorchangealert N'AdventureWorks', 1, 15, 1;		-- 15 minutes (Oldest unsent transaction)
EXEC sp_dbmmonitorchangealert N'AdventureWorks', 2, 100000, 1;	-- 100,000 KB (Unsent log) 
EXEC sp_dbmmonitorchangealert N'AdventureWorks', 3, 100000, 1;	-- 100,000 KB (Unrestored log)
EXEC sp_dbmmonitorchangealert N'AdventureWorks', 4, 1000, 1;	-- 1000 ms	  (Mirror commit overhead)
EXEC sp_dbmmonitorchangealert N'AdventureWorks', 5, 24, 1;		-- 24 hours   (Retention period)

-- sp_dbmmonitorchangealert (Transact-SQL)
-- http://bit.ly/2BuxYHE

-- Alert ID Information
-- Value	Performance metric
-- 1		Oldest unsent transaction (minutes)
-- 2		Unsent log (KB)
-- 3		Unrestored log (KB)
-- 4		Mirror commit overhead (ms) (Only relevant in high safety and high availability modes)
-- 5		Retention period (hours)	

-- Values that exceed the warning threshold generate an entry in the Windows Application Event Log
-- Performance metric			Event ID
-- Oldest unsent transaction	32040 
-- Unsent log					32042 
-- Unrestored log				32043 
-- Mirror commit overhead		32044 


-- Drops the warning for a specified performance metric, by setting the threshold to NULL
EXEC sp_dbmmonitordropalert N'AdventureWorks', 5;

-- sp_dbmmonitordropalert (Transact-SQL)
-- http://bit.ly/2AQQRVM


-- Returns information about warning thresholds on one or 
-- all of several key database mirroring monitor performance metrics
EXEC sp_dbmmonitorhelpalert N'AdventureWorks', 1;
EXEC sp_dbmmonitorhelpalert N'AdventureWorks', 2;
EXEC sp_dbmmonitorhelpalert N'AdventureWorks', 3;
EXEC sp_dbmmonitorhelpalert N'AdventureWorks', 4;
EXEC sp_dbmmonitorhelpalert N'AdventureWorks', 5;

-- sp_dbmmonitorhelpalert (Transact-SQL)
-- http://bit.ly/2zefSHW   


-- Updates the database mirroring monitor status table
-- If you specify a database name, it only updates the table for that database 
USE msdb;  
EXEC sp_dbmmonitorupdate N'AdventureWorks';

-- sp_dbmmonitorupdate (Transact-SQL)
-- http://bit.ly/2CAnVhR


-- Returns status rows for a monitored database from the status table 
USE msdb;  
EXEC sp_dbmmonitorresults N'AdventureWorks', 2, 1; -- Last four hours, update status

-- sp_dbmmonitorresults (Transact-SQL)
-- http://bit.ly/2kuxZAW  

-- Mode Information 
-- 0 = Last row  
-- 1 = Rows last two hours  
-- 2 = Rows last four hours   
-- 3 = Rows last eight hours  
-- 4 = Rows last day  
-- 5 = Rows last two days  
-- 6 = Last 100 rows  
-- 7 = Last 500 rows  
-- 8 = Last 1,000 rows  
-- 9 = Last 1,000,000 rows 





-- Drops all database mirroring monitoring from this instance
EXEC sp_dbmmonitordropmonitoring;

-- sp_dbmmonitordropmonitoring (Transact-SQL)
-- http://bit.ly/2kwwTEM
 