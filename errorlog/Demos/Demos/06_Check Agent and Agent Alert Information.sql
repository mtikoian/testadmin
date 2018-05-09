-- Check Agent and Agent Alert Information 


-- Database Mirroring Event Notifications

-- Database Mirroring State Change event class
-- http://bit.ly/2ASbHnT

-- Database Mirroring States
-- 1 = Synchronized Principal with Witness
-- 2 = Synchronized Principal without Witness
-- 3 = Synchronized Mirror with Witness
-- 4 = Synchronized Mirror without Witness
-- 5 = Connection with Principal Lost
-- 6 = Connection with Mirror Lost
-- 7 = Manual Failover
-- 8 = Automatic Failover
-- 9 = Mirroring Suspended
-- 10 = No Quorum
-- 11 = Synchronizing Mirror
-- 12 = Principal Running Exposed



-- Get SQL Server Agent jobs and Category information
SELECT sj.name AS [JobName], [enabled], sj.category_id, 
sc.name AS [CategoryName], sj.[description]
FROM msdb.dbo.sysjobs AS sj
INNER JOIN msdb.dbo.syscategories AS sc
ON sj.category_id = sc.category_id
ORDER BY sc.name, sj.name;


-- Get SQL Server Agent Alert Information 
SELECT name, event_source, message_id, severity, 
       [enabled], has_notification, delay_between_responses, 
	   occurrence_count, last_occurrence_date, last_occurrence_time
FROM msdb.dbo.sysalerts 
ORDER BY name;


USE ServerMonitor;
GO

-- Get recent server metrics from ServerMonitor
SELECT TOP(20) AvgTaskCount, AvgRunnableTaskCount, AvgPendingIOCount, 
               SQLServerCPUUtilization, PageLifeExpectancy, MeasurementTime
FROM ServerMonitor.dbo.SQLServerInstanceMetricHistory
ORDER BY SQLServerInstanceMetricHistoryID DESC;


-- Audit Database Mirroring Login event class
-- SQL Server creates an Audit Database Mirroring Login event to report audit messages 
-- related to database mirroring transport security
-- http://bit.ly/2AA2rR0