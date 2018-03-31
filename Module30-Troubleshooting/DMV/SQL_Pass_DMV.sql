USE [master]
GO

--/****** Object:  Database [DMVDemo]    Script Date: 2015-08-13 10:59:28 AM ******/
--CREATE DATABASE [DMVDemo]
-- CONTAINMENT = NONE
-- ON  PRIMARY 
--( NAME = N'DMVDemo', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\DMVDemo.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
-- LOG ON 
--( NAME = N'DMVDemo_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\DMVDemo_log.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
--GO

--ALTER DATABASE [DMVDemo] SET COMPATIBILITY_LEVEL = 110;
--GO

/****************************/
/*** Lets see a full list ***/
/****************************/
--use a case like a switch

SELECT  name ,         
		    CASE type           
		      WHEN 'V' THEN 'DMV'           
		      WHEN 'IF' THEN 'DMF'         
		    END AS DMO_Type
FROM master.sys.sysobjects
WHERE name LIKE 'dm_%' 
ORDER BY name;


USE AdventureWorks2012;
GO


/*************************************/
/*** Dont forget to open a new TAB ***/
/*************************************/ 

SELECT spid ,         
       cmd ,         
       sql_handle 
FROM  sys.sysprocesses 
WHERE   DB_NAME(dbid) = 'AdventureWorks2012'
  AND spid >= @@SPID;
GO
SELECT session_id ,         
       command ,         
       sql_handle FROM    
       sys.dm_exec_requests 
WHERE  DB_NAME(database_id) = 'AdventureWorks2012'
  AND session_id >= @@SPID;
GO

/*** FYI  this poses a big probelm as if it is not currently executing we will not see it
     This includes a modification that is not committed or rolled back ***/


/****************************************************/
/*** Lets take a Look At Connections and sessions ***/
/****************************************************/
/****************************/
/*** sys.dm_exec_sessions ***/
/****************************/

/***
SELECT * FROM sys.dm_exec_connections WHERE session_id >= @@SPID;
SELECT * FROM sys.dm_exec_sessions WHERE session_id >= @@SPID;
SELECT * FROM sys.dm_exec_requests WHERE session_id >= @@SPID;
sys.dm_exec_sql_text
sys.dm_exec_query_plan
***/

Select * from sysprocesses

SELECT * 
FROM sys.dm_exec_sessions

/**************************************************/
/*** Lets look at the nature of our connections ***/
/**************************************************/
SELECT  des.text_size,         
		des.language,         
		des.date_format,         
		des.date_first,         
		des.quoted_identifier,         
		des.arithabort,         
		des.ansi_null_dflt_on,         
		des.ansi_defaults,         
		des.ansi_warnings,         
		des.ansi_padding,         
		des.ansi_nulls,         
		des.concat_null_yields_null,         
		CASE 
		  WHEN des.transaction_isolation_level = 0 THEN 'Unspecified'
		  WHEN des.transaction_isolation_level = 1 THEN 'ReadUncomitted'
		  WHEN des.transaction_isolation_level = 2 THEN 'ReadCommitted'
		  WHEN des.transaction_isolation_level = 3 THEN 'Repeatable'
		  WHEN des.transaction_isolation_level = 4 THEN 'Serializable'
		  WHEN des.transaction_isolation_level = 5 THEN 'Snapshot'
		END as [transaction_isolation_level], 
		des.lock_timeout,       
		des.deadlock_priority 
FROM sys.dm_exec_sessions des 
WHERE Host_name IS NOT NULL

/*****************************************************/
/*** Get a count of SQL connections by IP address  ***/
/*****************************************************/
SELECT dec.client_net_address ,         
       des.program_name ,         
       des.host_name ,       
       des.login_name ,         
       COUNT(dec.session_id) AS connection_count 
FROM sys.dm_exec_sessions AS des  INNER JOIN sys.dm_exec_connections AS dec                        
ON des.session_id = dec.session_id 
-- WHERE   LEFT(des.host_name, 2) = 'WK' 
GROUP BY dec.client_net_address ,          
         des.program_name ,          
         des.host_name ,       
         des.login_name 
-- HAVING COUNT(dec.session_id) > 1 
ORDER BY des.program_name,          
         dec.client_net_address ;


/*******************************************/
/*** You can check Counnts               ***/
/*** Awesome Filter with is_User_Process ***/
/*******************************************/

SELECT login_name ,         
       COUNT(*) AS Sessioncount 
FROM sys.dm_exec_sessions 
WHERE is_user_process = 1 
GROUP BY login_name 
ORDER BY login_name


/************************************/
/*** What are the Chops Runniing  ***/
/************************************/
SELECT  dec.client_net_address ,         
        des.host_name ,         
        dest.text 
FROM sys.dm_exec_sessions des JOIN sys.dm_exec_connections dec                      
  ON des.session_id = dec.session_id         
  CROSS APPLY sys.dm_exec_sql_text(dec.most_recent_sql_handle) dest 
WHERE des.program_name LIKE 'Microsoft SQL Server Management Studio%' 
ORDER BY des.program_name ,         
         dec.client_net_address;

/***************************/
/*** Context Switching  ***/
/**************************/
SELECT session_id ,         
       login_name ,         
       original_login_name 
FROM sys.dm_exec_sessions 
WHERE is_user_process = 1         
  AND login_name      <> original_login_name


/**************************************/
/*** Checking for inactive Sessions ***/
/**************************************/
DECLARE @InactiveDuration INT = 5  --Working in Sesonds !!

SELECT  des.session_id ,         
  des.login_time ,         
  des.last_request_start_time ,         
  des.last_request_end_time ,         
  des.[status] ,         
  des.[program_name] ,         
  des.cpu_time ,         
  des.total_elapsed_time ,         
  des.memory_usage ,         
  des.total_scheduled_time ,         
  des.total_elapsed_time ,         
  des.reads ,         
  des.writes ,         
  des.logical_reads ,         
  des.row_count ,         
  des.is_user_process 
FROM sys.dm_exec_sessions des INNER JOIN sys.dm_tran_session_transactions dtst                        
  ON des.session_id = dtst.session_id 
WHERE des.is_user_process = 1         
  AND DATEDIFF(ss, des.last_request_end_time, GETDATE()) > @InactiveDuration         
  AND des.status != 'Running' 
ORDER BY des.last_request_end_time

/*************************************************************/
/*** Checking for idle Sessions with orphaned transactions ***/
/*************************************************************/

SELECT des.session_id ,         
       des.login_time ,         
       des.last_request_start_time ,         
       des.last_request_end_time ,         
       des.host_name ,         
       des.login_name 
FROM sys.dm_exec_sessions des INNER JOIN sys.dm_tran_session_transactions dtst                        
  ON des.session_id = dtst.session_id         
  LEFT JOIN sys.dm_exec_requests der                        
  ON dtst.session_id = der.session_id 
WHERE   der.session_id IS NULL ORDER BY des.session_id

/***  Go back to the Slides Dummy! ***/

/****************************/
/*** sys.dm_exec_requests ***/
/***********************************************/
/*** Lets find the SQL text of Adhoc Queries ***/
/***********************************************/

SELECT dest.text ,         
       dest.dbid ,         
       dest.objectid 
FROM sys.dm_exec_requests der CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) dest 
WHERE session_id = @@spid ;

/************************************/
/*** Retrieve queries for a Batch ***/
/************************************/
-- Dont forget tab 2

SELECT  dest.text 
FROM    sys.dm_exec_requests der CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) dest 
WHERE   text LIKE '%UserName%' 

/***************************************/ 
/*** Finding where we are in a batch ***/
/*** One of my favourite things!!!   ***/
/***************************************/ 

SELECT der.statement_start_offset ,         
       der.statement_end_offset ,         
       SUBSTRING(dest.text, der.statement_start_offset / 2, ( CASE 
                                                                WHEN der.statement_end_offset = -1 THEN DATALENGTH(dest.text)                          
                                                              ELSE der.statement_end_offset                     
                                                              END - der.statement_start_offset ) / 2) AS statement_executing ,         
       dest.text AS [full statement code] 
FROM sys.dm_exec_requests der JOIN sys.dm_exec_sessions des                        
  ON des.session_id = der.session_id         
  CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) dest 
WHERE des.is_user_process = 1         
  AND der.session_id <> @@spid ORDER BY der.session_id ;

/***********************************/
/*** Taking it to the next level ***/
/***********************************/

SELECT der.session_id ,         
       DB_NAME(der.database_id) AS database_name ,         
       deqp.query_plan ,         
       SUBSTRING(dest.text, der.statement_start_offset / 2, ( CASE 
                                                                WHEN der.statement_end_offset = -1 THEN DATALENGTH(dest.text)                          
                                                              ELSE der.statement_end_offset 
                                                              END - der.statement_start_offset ) / 2) AS [statement executing] ,         
       der.cpu_time       
       --der.granted_query_memory       
       --der.wait_time       
       --der.total_elapsed_time       
       --der.reads  
FROM sys.dm_exec_requests der JOIN sys.dm_exec_sessions des 
  ON des.session_id = der.session_id CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) dest 
  CROSS APPLY sys.dm_exec_query_plan(der.plan_handle) deqp 
WHERE des.is_user_process = 1         
  AND der.session_id <> @@spid 
ORDER BY der.cpu_time DESC ; 
-- ORDER BY der.granted_query_memory DESC ; 
-- ORDER BY der.wait_time DESC; 
-- ORDER BY der.total_elapsed_time DESC; 
-- ORDER BY der.reads DESC;

/*** Lets get a better version of sp _Who ***/
SELECT des.session_id ,         
       des.status ,         
       des.login_name ,         
       des.[HOST_NAME] ,         
       der.blocking_session_id ,         
       DB_NAME(der.database_id) AS database_name ,         
       der.command ,         
       des.cpu_time ,         
       des.reads ,         
       des.writes ,         
       dec.last_write ,         
       des.[program_name] ,         
       der.wait_type ,         
       der.wait_time ,         
       der.last_wait_type ,         
       der.wait_resource ,         
       CASE des.transaction_isolation_level           
         WHEN 0 THEN 'Unspecified'           
         WHEN 1 THEN 'ReadUncommitted'           
         WHEN 2 THEN 'ReadCommitted'           
         WHEN 3 THEN 'Repeatable'           
         WHEN 4 THEN 'Serializable'           
         WHEN 5 THEN 'Snapshot'         
       END AS transaction_isolation_level ,         
       OBJECT_NAME(dest.objectid, der.database_id) AS OBJECT_NAME ,         
       SUBSTRING(dest.text, der.statement_start_offset / 2,  ( CASE 
                                                               WHEN der.statement_end_offset = -1 THEN DATALENGTH(dest.text)
                                                               ELSE der.statement_end_offset                     
                                                               END - der.statement_start_offset ) / 2) AS [executing statement] ,         
       deqp.query_plan 
FROM sys.dm_exec_sessions des LEFT JOIN sys.dm_exec_requests der 
  ON des.session_id = der.session_id 
  LEFT JOIN sys.dm_exec_connections dec 
  ON des.session_id = dec.session_id 
  CROSS APPLY sys.dm_exec_sql_text(der.sql_handle) dest
  CROSS APPLY sys.dm_exec_query_plan(der.plan_handle) deqp 
WHERE des.session_id <> @@SPID 
ORDER BY des.session_id



/******************************************/
/*** Query Plan Metadata and Statistics ***/
/******************************************/

SELECT * FROM sys.dm_exec_query_stats 
SELECT * FROM sys.dm_exec_procedure_stats
SELECT * FROM sys.dm_exec_cached_plans  
SELECT * FROM sys.dm_exec_query_optimizer_info 

/***************************************************/
/***  Getting the Query Plan Back and some Stats ***/
/***************************************************/
/*** Display the clearing of stats when procedure changes ***/

CREATE PROCEDURE dbo.LetsMakeSomeStats
as
BEGIN
  
  SELECT * FROM sys.all_columns  
  SELECT * FROM sys.all_parameters
  --SELECT * FROM sys.all_objects

END;

EXEC dbo.LetsMakeSomeStats

SELECT deqp.dbid ,         
       deqp.objectid ,         
       deqp.encrypted ,         
       deqp.query_plan ,
       deqs.execution_count,
       deqs.creation_time,
       deqs.last_execution_time
FROM sys.dm_exec_query_stats deqs CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp 
WHERE   objectid = OBJECT_ID('LetsMakeSomeStats', 'p') ;

SELECT deqs.plan_handle ,         
       deqs.sql_handle ,         
       execText.text,
       deqs.query_hash,
       deqs.query_plan_hash 
FROM sys.dm_exec_query_stats deqs CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS execText 
WHERE execText.text LIKE 'CREATE PROCEDURE dbo.LetsMakeSomeStats%'

/****************************************************************************/
/*** Just like before we can try and find the individual queries in Batch ***/
/****************************************************************************/

SELECT  CHAR(13) + CHAR(10) + CASE 
                                WHEN deqs.statement_start_offset = 0 AND deqs.statement_end_offset = -1 THEN '-- see objectText column--'
                              ELSE 
                                '-- query --' + CHAR(13) + CHAR(10) 
                                + SUBSTRING(execText.text, deqs.statement_start_offset / 2,  
                                ( ( CASE 
                                      WHEN deqs.statement_end_offset = -1 THEN DATALENGTH(execText.text) 
                                    ELSE 
                                      deqs.statement_end_offset  
                                    END ) - deqs.statement_start_offset ) / 2) 
                               END AS queryText ,         
deqp.query_plan 
FROM sys.dm_exec_query_stats deqs CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS execText         
CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) deqp 
WHERE   execText.text LIKE 'CREATE PROCEDURE dbo.LetsMakeSomeStats%'

/*** Lets Step it up, I want Single statement plan ***/

SELECT  deqp.dbid ,         
        deqp.objectid ,         
        CAST(detqp.query_plan AS XML) AS singleStatementPlan ,         
        deqp.query_plan AS batch_query_plan ,         
        --this won't actually work in all cases because nominal plans aren't         
        -- cached, so you won't see a plan for waitfor if you uncomment it         
        ROW_NUMBER() OVER ( ORDER BY Statement_Start_offset ) AS query_position ,         
        CASE 
          WHEN deqs.statement_start_offset = 0 AND deqs.statement_end_offset = -1  THEN '-- see objectText column--'              
        ELSE '-- query --' + CHAR(13) + CHAR(10) + SUBSTRING(execText.text, deqs.statement_start_offset / 2, 
             ( ( CASE 
                   WHEN deqs.statement_end_offset = -1 THEN DATALENGTH(execText.text) 
                 ELSE 
                   deqs.statement_end_offset   
                 END ) - deqs.statement_start_offset ) / 2)         
        END AS queryText 
FROM sys.dm_exec_query_stats deqs  CROSS APPLY sys.dm_exec_text_query_plan(deqs.plan_handle, 
                                                                          deqs.statement_start_offset, 
                                                                          deqs.statement_end_offset) AS detqp         
    CROSS APPLY sys.dm_exec_query_plan(deqs.plan_handle) AS deqp 
    CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS execText 
WHERE deqp.objectid = OBJECT_ID('LetsMakeSomeStats', 'p') ;

/**********************************/
/*** Lets dig into Cached Plans ***/
/**********************************/

SELECT refcounts ,         
       usecounts ,         
       size_in_bytes ,         
       cacheobjtype ,         
       objtype 
--SELECT *
FROM sys.dm_exec_cached_plans 
WHERE objtype IN ( 'proc', 'prepared' ) ;               

SELECT --TOP 5 
        decp.usecounts ,         
        decp.cacheobjtype ,         
        decp.objtype ,         
        deqp.query_plan ,         
        dest.text 
FROM sys.dm_exec_cached_plans decp CROSS APPLY sys.dm_exec_query_plan(decp.plan_handle) AS deqp         
CROSS APPLY sys.dm_exec_sql_text(decp.plan_handle) AS dest 
WHERE deqp.query_plan IS NOT NULL
ORDER BY usecounts DESC ;

/*** Find an individual proc ***/
SELECT usecounts ,         
       cacheobjtype ,         
       objtype ,         
       OBJECT_NAME(dest.objectid) 
FROM sys.dm_exec_cached_plans decp CROSS APPLY sys.dm_exec_sql_text(decp.plan_handle) AS dest 
WHERE dest.objectid = OBJECT_ID('LetsMakeSomeStats') 
  AND dest.dbid = DB_ID() 
ORDER BY usecounts DESC ;

/*** We need to try and find ADHoc Queries that potentially bloat the cache ***/

SELECT TOP ( 100 ) dest.[text] ,         
                   decp.size_in_bytes 
FROM sys.dm_exec_cached_plans AS decp CROSS APPLY sys.dm_exec_sql_text(decp.plan_handle) dest
WHERE decp.cacheobjtype = 'Compiled Plan'
  AND decp.objtype = 'Adhoc'         
  AND decp.usecounts = 1 
ORDER BY decp.size_in_bytes DESC ;

/*********************************/
/*** Digging Deeper into Stats ***/
/*********************************/
/*** CPU Intensive Queries     ***/
/*********************************/
SELECT TOP 3         
        total_worker_time ,         
        execution_count ,         
        total_worker_time / execution_count AS [Avg CPU Time] ,         
        CASE 
          WHEN deqs.statement_start_offset = 0 AND deqs.statement_end_offset = -1 THEN '-- see objectText column--'              
        ELSE 
          '-- query --' + CHAR(13) + CHAR(10) 
          + SUBSTRING(execText.text, deqs.statement_start_offset / 2, 
                     ( ( CASE 
                           WHEN deqs.statement_end_offset = -1 THEN DATALENGTH(execText.text)                                        
                         ELSE 
                           deqs.statement_end_offset 
                         END ) - deqs.statement_start_offset ) / 2)  END AS queryText 
FROM sys.dm_exec_query_stats deqs CROSS APPLY sys.dm_exec_sql_text(deqs.plan_handle) AS execText 
ORDER BY deqs.total_worker_time DESC ;

/*** Lets Group By SQL Handle to find things at batch level ***/
SELECT TOP 100         
      SUM(total_logical_reads) AS total_logical_reads ,         
      COUNT(*) AS num_queries , 
      --number of individual queries in batch         
      --not all usages need be equivalent, in the case of looping         
      --or branching code         
      MAX(execution_count) AS execution_count ,         
      MAX(execText.text) AS queryText 
FROM sys.dm_exec_query_stats deqs CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS execText 
GROUP BY deqs.sql_handle 
HAVING AVG(total_logical_reads / execution_count) <> SUM(total_logical_reads)/ SUM(execution_count) 
ORDER BY 1 DESC

/**********************************************************/
/*** Lets find some info on cached sprocs               ***/
/*** Logical reads relate combined with memory pressure ***/
/**********************************************************/
SELECT p.name AS [SP Name] ,         
       deps.total_logical_reads AS [TotalLogicalReads] ,         
       deps.total_logical_reads / deps.execution_count AS [AvgLogicalReads] ,         
       deps.execution_count ,         
       ISNULL(deps.execution_count / DATEDIFF(Second, deps.cached_time,                                            
       GETDATE()), 0) AS [Calls/Second] ,         
       deps.total_elapsed_time ,         
       deps.total_elapsed_time / deps.execution_count AS [avg_elapsed_time] ,         
       deps.cached_time 
FROM sys.procedures AS p INNER JOIN sys.dm_exec_procedure_stats AS deps ON p.[object_id] = deps.[object_id] 
WHERE   deps.database_id = DB_ID() ORDER BY deps.total_logical_reads DESC ;

SELECT *
FROM sys.dm_exec_query_optimizer_info

--The most valuable options
--optimizations
--elapsed time
--final cost

/***  Go back to the Slides Dummy! ***/


/********************/
/*** Transactions ***/
/********************/

SELECT * FROM sys.dm_tran_active_transactions
SELECT * FROM sys.dm_tran_locks


/************************************/
/*** Lets investigte some Locking ***/
/************************************/
/***  Need some example code here ***/


/**********************/
/*** Shared Locks S ***/
/**********************/
--Shared locks are held on data being read under the pessimistic concurrency model. While a shared lock 
--is being held other transactions can read but can't modify locked data. After the locked data has been 
--read the shared lock is released, unless the transaction is being run with the locking hint 
--(READCOMMITTED, READCOMMITTEDLOCK) or under the isolation level equal or more restrictive than 
--Repeatable Read. In the example you can't see the shared locks because they're taken for the duration 
--of the select statement and are already released when we would select data from sys.dm_tran_locks. That 
--is why an addition of WITH (HOLDLOCK) is needed to see the locks.


BEGIN TRAN 

  SELECT * 
  FROM dbo.Emp WITH (HOLDLOCK)
  WHERE EmpID = 2

  SELECT object_name(p.object_id) as Object, 
         resource_type, 
         request_mode, 
         resource_description, 
         Request_Type, 
         Request_Status, 
         resource_associated_entity_id
  FROM   sys.dm_tran_locks l LEFT JOIN sys.partitions p
    ON l.resource_associated_entity_id = p.hobt_id
  WHERE  resource_type <> 'DATABASE'

  SELECT resource_type,
       DB_NAME(resource_database_id) AS DatabaseName ,
       CASE WHEN dtl.resource_type IN ( 'DATABASE', 'FILE', 'METADATA' ) THEN dtl.resource_type
            WHEN dtl.resource_type = 'OBJECT' THEN OBJECT_NAME(dtl.resource_associated_entity_id,dtl.resource_database_id)
            WHEN dtl.resource_type IN ( 'KEY', 'PAGE', 'RID' ) THEN ( SELECT OBJECT_NAME(object_id) 
                                                                      FROM sys.partitions 
                                                                      WHERE sys.partitions.hobt_id = dtl.resource_associated_entity_id)
      ELSE 
        'Unidentified'
      END AS requested_object_name,
      request_mode,
      resource_description
FROM sys.dm_tran_locks dtl
WHERE dtl.resource_type <> 'DATABASE';

ROLLBACK TRAN



/************************/
/*** Key Range Locks  ***/
/************************/
--Intent locks are a means in which a transaction notifies other transaction that it is intending to 
--lock the data. Thus the name. Their purpose is to assure proper data modification by preventing other 
--transactions to acquire a lock on the object higher in lock hierarchy. What this means is that before 
--you obtain a lock on the page or the row level an intent lock is set on the table. This prevents other 
--transactions from putting exclusive locks on the table that would try to cancel the row/page lock. In 
--the example we can see the intent exclusive locks being placed on the page and the table where the key 
--is to protect the data from being locked by other transactions.

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRAN 

  UPDATE dbo.Emp
    SET FirstName = 'test'
  WHERE FirstName LIke 'Sea%'

  SELECT object_name(p.object_id) as Object, 
         resource_type, 
         request_mode, 
         resource_description, 
         Request_Type, 
         Request_Status
  FROM   sys.dm_tran_locks l LEFT JOIN sys.partitions p
    ON l.resource_associated_entity_id = p.hobt_id
  WHERE  resource_type <> 'DATABASE'

  SELECT resource_type,
       DB_NAME(resource_database_id) AS DatabaseName ,
       CASE WHEN dtl.resource_type IN ( 'DATABASE', 'FILE', 'METADATA' ) THEN dtl.resource_type
            WHEN dtl.resource_type = 'OBJECT' THEN OBJECT_NAME(dtl.resource_associated_entity_id,dtl.resource_database_id)
            WHEN dtl.resource_type IN ( 'KEY', 'PAGE', 'RID' ) THEN ( SELECT OBJECT_NAME(object_id) 
                                                                      FROM sys.partitions 
                                                                      WHERE sys.partitions.hobt_id = dtl.resource_associated_entity_id)
      ELSE 
        'Unidentified'
      END AS requested_object_name,
      request_mode,
      resource_description
FROM sys.dm_tran_locks dtl
WHERE dtl.resource_type <> 'DATABASE';

ROLLBACK TRAN

SET TRANSACTION ISOLATION LEVEL READ COMMITTED
/************************************/
/*** Lets investigte some Blocking ***/
/************************************/
SELECT  dtl.request_session_id AS session_id ,
        DB_NAME(dtl.resource_database_id) AS [Database] ,
        dtl.resource_type ,
        CASE 
          WHEN dtl.resource_type IN ('DATABASE','FILE','METADATA') THEN dtl.resource_type
          WHEN dtl.resource_type =  'OBJECT' THEN OBJECT_NAME(dtl.resource_associated_entity_id, dtl.resource_database_id)
          WHEN dtl.resource_type IN ('KEY','PAGE','RID') THEN ( SELECT OBJECT_NAME([object_id]) 
                                                                    FROM sys.partitions 
                                                                    WHERE sys.partitions.hobt_id = dtl.resource_associated_entity_id)
        ELSE 
          'Unidentified'
        END AS ParentObject ,
        dtl.request_mode AS LockType,
        dtl.request_status AS RequestStatus ,
        der.blocking_session_id ,
        des.login_name ,
        CASE dtl.request_lifetime
          WHEN 0 THEN dest_req.TEXT
        ELSE 
          dest_con.TEXT
        END AS [Statement]
FROM sys.dm_tran_locks dtl LEFT JOIN sys.[dm_exec_requests] der
  ON dtl.[request_session_id] = der.session_id
  INNER JOIN sys.dm_exec_sessions des
  ON dtl.request_session_id = des.session_id
  INNER JOIN sys.dm_exec_connections dec
  ON dtl.request_session_id = dec.most_recent_session_id
  OUTER APPLY sys.dm_exec_sql_text(dec.most_recent_sql_handle)AS dest_con
  OUTER APPLY sys.dm_exec_sql_text(der.sql_handle) AS dest_req
WHERE dtl.resource_database_id = DB_ID()
  AND dtl.resource_type NOT IN ( 'DATABASE', 'METADATA' )
ORDER BY dtl.request_session_id;


/**************************************/
/*** Take a peek at Active Sessions ***/
/**************************************/
/*** Dont forget to create blocked tran ***/
SELECT dtat.transaction_id ,
       dtat.[name] ,
       dtat.transaction_begin_time ,
       CASE dtat.transaction_type
         WHEN 1 THEN 'Read/write'
         WHEN 2 THEN 'Read-only'
         WHEN 3 THEN 'System'
         WHEN 4 THEN 'Distributed'
       END AS transaction_type ,
       CASE dtat.transaction_state
         WHEN 0 THEN 'Not fully initialized'
         WHEN 1 THEN 'Initialized, not started'
         WHEN 2 THEN 'Active'
         WHEN 3 THEN 'Ended' -- only applies to read-only transactions
         WHEN 4 THEN 'Commit initiated'-- distributed transactions only
         WHEN 5 THEN 'Prepared, awaiting resolution'
         WHEN 6 THEN 'Committed'
         WHEN 7 THEN 'Rolling back'
         WHEN 8 THEN 'Rolled back'
       END AS transaction_state ,
       CASE dtat.dtc_state
         WHEN 1 THEN 'Active'
         WHEN 2 THEN 'Prepared'
         WHEN 3 THEN 'Committed'
         WHEN 4 THEN 'Aborted'
         WHEN 5 THEN 'Recovered'
       END AS dtc_state
FROM sys.dm_tran_active_transactions dtat
INNER JOIN sys.dm_tran_session_transactions dtst
ON dtat.transaction_id = dtst.transaction_id
WHERE dtst.is_user_transaction = 1
ORDER BY dtat.transaction_begin_time

/************************/
/*** ISOLATION LEVELS ***/
/************************/

-- Specify that snapshot isolation is enabled
-- does not affect the default behavior.
ALTER DATABASE AdventureWorks2012 SET ALLOW_SNAPSHOT_ISOLATION off ;
GO
-- READ_COMMITTED_SNAPSHOT becomes the default isolation level.
ALTER DATABASE AdventureWorks2012 SET READ_COMMITTED_SNAPSHOT off ;
GO

--Open in multiple Tabs
--BEGIN TRAN 

--  UPDATE dbo.Emp
--    SET FirstName = 'test'
--  WHERE FirstName LIke 'Sea%'

----RollBack Tran

SELECT COUNT([transaction_sequence_num]) AS [snapshot transaction count]
FROM sys.dm_tran_active_snapshot_database_transactions ;

SELECT DTASDT.transaction_id ,
       DTASDT.session_id ,
       DTASDT.transaction_sequence_num ,
       DTASDT.first_snapshot_sequence_num ,
       DTASDT.commit_sequence_num ,
       DTASDT.is_snapshot ,
       DTASDT.elapsed_time_seconds ,
       DEST.text AS [command text]
FROM sys.dm_tran_active_snapshot_database_transactions DTASDT
  INNER JOIN sys.dm_exec_connections DEC
  ON DTASDT.session_id = DEC.most_recent_session_id
  INNER JOIN sys.dm_tran_database_transactions DTDT
  ON DTASDT.transaction_id = DTDT.transaction_id
  CROSS APPLY sys.dm_exec_sql_text(DEC.most_recent_sql_handle) AS DEST
WHERE DTDT.database_id = DB_ID()

/*** Version Store Information ***/
SELECT  DB_NAME(DTVS.database_id) AS [Database Name] ,
        DTVS.[transaction_sequence_num] ,
        DTVS.[version_sequence_num] ,
        CASE DTVS.[status]
        WHEN 0 THEN '1'
        WHEN 1 THEN '2'
        END AS [pages] ,
        DTVS.[record_length_first_part_in_bytes] + DTVS.[record_length_second_part_in_bytes] AS [record length (bytes)]
FROM sys.dm_tran_version_store DTVS
ORDER BY DB_NAME(DTVS.database_id) ,
    DTVS.transaction_sequence_num ,
    DTVS.version_sequence_num


/****************/
/*** Indexing ***/
/****************/

/*******************************************/
/*** Basic Index Stats in the AdventureWorks2012 DB ***/
/*******************************************/

USE AdventureWorks2012
GO

SELECT  DB_NAME(ddius.[database_id]) AS database_name ,
        OBJECT_NAME(ddius.[object_id], ddius.[database_id]) AS [object_name],
        asi.[name] AS index_name ,
        ddius.user_seeks + ddius.user_scans + ddius.user_lookups AS user_reads
FROM sys.dm_db_index_usage_stats ddius INNER JOIN AdventureWorks2012.sys.indexes asi
  ON ddius.[object_id] = asi.[object_id]
  AND ddius.index_id = asi.index_id;


SELECT  OBJECT_NAME(ddius.[object_id], ddius.database_id) AS [object_name] ,
        ddius.index_id ,
        ddius.user_seeks ,
        ddius.user_scans ,
        ddius.user_lookups ,
        ddius.user_seeks + ddius.user_scans + ddius.user_lookups AS user_reads ,
        ddius.user_updates AS user_writes ,
        ddius.last_user_scan ,
        ddius.last_user_update
FROM sys.dm_db_index_usage_stats ddius
WHERE ddius.database_id > 4 -- filter out system tables
AND OBJECTPROPERTY(ddius.object_id, 'IsUserTable') = 1
AND ddius.index_id > 0 -- filter out heaps
ORDER BY ddius.user_scans DESC

/**********************************/
/*** How to find Unused Indexes ***/
/**********************************/
SELECT OBJECT_NAME(i.[object_id]) AS [Table Name] ,
       i.name
FROM sys.indexes AS i INNER JOIN sys.objects AS o ON i.[object_id] = o.[object_id]
WHERE i.index_id NOT IN (SELECT ddius.index_id FROM sys.dm_db_index_usage_stats AS ddius
                         WHERE ddius.[object_id] = i.[object_id]
                         AND i.index_id = ddius.index_id
                         AND database_id = DB_ID() )
      AND o.[type] = 'U'
ORDER BY OBJECT_NAME(i.[object_id]) ASC ;

/***********************************************************/
/*** Possible bad non-clustered indexes (writes > reads) ***/
/***********************************************************/

SELECT  OBJECT_NAME(ddius.object_id) AS TableName ,
        i.name AS IndexName ,
        i.index_id ,
        user_updates AS TotalWrites ,
        user_seeks + user_scans + user_lookups AS TotalReads,
        user_updates - ( user_seeks + user_scans + user_lookups ) AS [Difference]
FROM sys.dm_db_index_usage_stats AS ddius WITH ( NOLOCK ) INNER JOIN sys.indexes AS i WITH ( NOLOCK )
  ON ddius.object_id = i.object_id
  AND i.index_id = ddius.index_id
WHERE OBJECTPROPERTY(ddius.object_id, 'IsUserTable') = 1
  AND ddius.database_id = DB_ID()
  --AND user_updates > ( user_seeks + user_scans + user_lookups )
  --AND i.index_id > 1
ORDER BY  [Difference] DESC ,
          TotalWrites DESC ,
          TotalReads ASC ;


/****************************************/
/*** DEEP DIVE of Detail and Activity ***/
/****************************************/
SELECT '[' + DB_NAME() + '].[' + su.[name] + '].[' + o.[name] + ']' AS [statement] ,
        i.[name] AS [index_name] ,
        ddius.[user_seeks] + ddius.[user_scans] + ddius.[user_lookups] AS [user_reads] ,
        ddius.[user_updates] AS [user_writes] ,
        ddios.[leaf_insert_count] ,
        ddios.[leaf_delete_count] ,
        ddios.[leaf_update_count] ,
        ddios.[nonleaf_insert_count] ,
        ddios.[nonleaf_delete_count] ,
        ddios.[nonleaf_update_count]
FROM sys.dm_db_index_usage_stats ddius JOIN sys.indexes i ON ddius.[object_id] = i.[object_id]
  AND i.[index_id] = ddius.[index_id]
  JOIN sys.partitions SP ON ddius.[object_id] = SP.[object_id]
  AND SP.[index_id] = ddius.[index_id]
  JOIN sys.objects o ON ddius.[object_id] = o.[object_id]
  JOIN sys.sysusers su ON o.[schema_id] = su.[UID]
  JOIN sys.[dm_db_index_operational_stats](DB_ID(), NULL, NULL,NULL)AS ddios
  ON ddius.[index_id] = ddios.[index_id]
  AND ddius.[object_id] = ddios.[object_id]
  AND SP.[partition_number] = ddios.[partition_number]
  AND ddius.[database_id] = ddios.[database_id]
WHERE OBJECTPROPERTY(ddius.[object_id], 'IsUserTable') = 1
  AND ddius.[index_id] > 0
--  AND ddius.[user_seeks] + ddius.[user_scans] + ddius.[user_lookups] = 0
ORDER BY ddius.[user_updates] DESC ,
        su.[name] ,
        o.[name] ,
        i.[name]

/*************************************************************************/
/*** Very Cool way to gather some detailed breakdown of Index activity ***/
/*************************************************************************/
--SELECT '[' + DB_NAME(ddios.[database_id]) + '].[' + su.[name] + '].['+ o.[name] + ']' AS [statement] ,
--        i.[name] AS 'index_name' ,
--        ddios.[partition_number] ,
--        ddios.[row_lock_count] ,
--        ddios.[row_lock_wait_count] ,
--        CAST (100.0 * ddios.[row_lock_wait_count]
--        / ( ddios.[row_lock_count] ) AS DECIMAL(5, 2)) AS [%_times_blocked] ,
--        ddios.[row_lock_wait_in_ms] ,
--        CAST (1.0 * ddios.[row_lock_wait_in_ms]
--        / ddios.[row_lock_wait_count] AS DECIMAL(15, 2))  AS [avg_row_lock_wait_in_ms]
--FROM sys.dm_db_index_operational_stats(DB_ID(), NULL, NULL, NULL) ddios JOIN sys.indexes i ON ddios.[object_id] = i.[object_id]
--  AND i.[index_id] = ddios.[index_id]
--  JOIN sys.objects o ON ddios.[object_id] = o.[object_id]
--  JOIN sys.sysusers su ON o.[schema_id] = su.[UID]
--WHERE ddios.row_lock_wait_count > 0
--  AND OBJECTPROPERTY(ddios.[object_id], 'IsUserTable') = 1
--  AND i.[index_id] > 0
--ORDER BY ddios.[row_lock_wait_count] DESC ,
--         su.[name] ,
--         o.[name] ,
--         i.[name]

/********************************************/
/*** Possible Missing Beneificial Indexes ***/
/********************************************/
SELECT TOP 25
         dm_mid.database_id AS DatabaseID,
         dm_migs.avg_user_impact*(dm_migs.user_seeks+dm_migs.user_scans) Avg_Estimated_Impact,
         dm_migs.last_user_seek AS Last_User_Seek,
         OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) AS [TableName],
         'CREATE INDEX [IX_' + OBJECT_NAME(dm_mid.OBJECT_ID,dm_mid.database_id) + '_'
         + REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.equality_columns,''),', ','_'),'[',''),']','') +
         CASE
         WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL THEN '_'
         ELSE ''
         END
         + REPLACE(REPLACE(REPLACE(ISNULL(dm_mid.inequality_columns,''),', ','_'),'[',''),']','')
          + ']'
         + ' ON ' + dm_mid.statement
         + ' (' + ISNULL (dm_mid.equality_columns,'')
          + CASE WHEN dm_mid.equality_columns IS NOT NULL AND dm_mid.inequality_columns IS NOT NULL THEN ',' ELSE
         '' END
         + ISNULL (dm_mid.inequality_columns, '')
          + ')'
         + ISNULL (' INCLUDE (' + dm_mid.included_columns + ')', '') AS Create_Statement
FROM sys.dm_db_missing_index_groups dm_mig JOIN sys.dm_db_missing_index_group_stats dm_migs
  ON dm_migs.group_handle = dm_mig.index_group_handle
  INNER JOIN sys.dm_db_missing_index_details dm_mid
  ON dm_mig.index_handle = dm_mid.index_handle
WHERE dm_mid.database_ID = DB_ID()
ORDER BY Avg_Estimated_Impact DESC
GO

/******************/
/*** 2016 DMV's ***/
/******************/
 -- sys.dm_db_xtp_merge_requests Dying

dm_column_store_object_pool
dm_db_column_store_row_group_operational_stats
dm_db_column_store_row_group_physical_stats
dm_db_rda_migration_status
dm_exec_compute_node_errors
dm_exec_compute_node_status
dm_exec_compute_nodes
dm_exec_distributed_request_steps
dm_exec_distributed_requests
dm_exec_distributed_sql_requests
dm_exec_dms_services
dm_exec_dms_workers
dm_exec_external_operations
dm_exec_external_work
dm_exec_function_stats
dm_exec_session_wait_stats
