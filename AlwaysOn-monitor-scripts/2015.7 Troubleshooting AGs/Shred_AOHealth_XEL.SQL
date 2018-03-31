SET NOCOUNT ON
USE [master]
GO
BEGIN TRY
    CREATE DATABASE [<Database_Name, sysname, Case_Number>]
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 1801 BEGIN
        SELECT ERROR_NUMBER(), ERROR_MESSAGE()
        RAISERROR ('Severe error.  Terminating connection...', 19, 1) WITH LOG
    END
END CATCH
GO
BEGIN TRY
    ALTER DATABASE [<Database_Name, sysname, Case_Number>] SET RECOVERY SIMPLE
    --ALTER DATABASE [<Database_Name, sysname, Case_Number>] MODIFY FILE ( NAME = N'<Database_Name, sysname, Case_Number>', SIZE = 5120000KB )
    --ALTER DATABASE [<Database_Name, sysname, Case_Number>] MODIFY FILE ( NAME = N'<Database_Name, sysname, Case_Number>_log', SIZE = 5120000KB )
END TRY
BEGIN CATCH
    IF (ERROR_NUMBER() <> 5039) BEGIN
    SELECT ERROR_NUMBER(), ERROR_MESSAGE()
    RAISERROR ('Severe error.  Terminating connection...', 19, 1) WITH LOG
    END
END CATCH

USE [<Database_Name, sysname, Case_Number>] 

--construct path & file name for SQLDIAG_*.xel files to load
DECLARE @XELPath VARCHAR(max) = '<XEL Folder Path, varchar(max), D:\Path\Where\AO Health XEL Files are stored\>'
IF RIGHT(@XELPath, 1) <> '\'
    SELECT @XELPath += '\'
DECLARE @XELFile VARCHAR(max) = @XELPath + '<XELFile, varchar(max), AlwaysOn_health*.xel>'

--create table, indexes
BEGIN TRY
CREATE TABLE AOHealth_XELData
    (ID INT IDENTITY PRIMARY KEY CLUSTERED,
    object_name varchar(max),
    EventData XML,
    file_name varchar(max),
    file_offset bigint);
END TRY
BEGIN CATCH
    IF (ERROR_NUMBER() = 2714) BEGIN
        TRUNCATE TABLE AOHealth_XELData
        DROP INDEX sXML ON AOHealth_XELData
        DROP INDEX pXML ON AOHealth_XELData
    END ELSE 
    SELECT ERROR_NUMBER(), ERROR_MESSAGE()
END CATCH

--read from the files into the table
INSERT INTO AOHealth_XELData
SELECT object_name, cast(event_data as XML) AS EventData,
  file_name, File_Offset
  FROM sys.fn_xe_file_target_read_file(
  @XELFile, NULL, null, null);

--create XML indexes
CREATE PRIMARY XML INDEX pXML ON AOHealth_XELData(EventData);
CREATE XML INDEX sXML 
    ON AOHealth_XELData (EventData)
    USING XML INDEX pXML FOR PATH ;


-- Create table for "error_reported" events
BEGIN TRY
SELECT  object_name, EventData.value('(event/@timestamp)[1]', 'datetime') AS TimeStamp,
    EventData.value('(event/data/value)[1]', 'int') AS ErrorNum,
    EventData.value('(event/data/value)[2]', 'int') AS Severity,
    EventData.value('(event/data/value)[3]', 'int') AS State,
    EventData.value('(event/data/value)[4]', 'varchar(max)') AS UserDefined,
    EventData.value('(event/data/text)[5]', 'varchar(max)') AS Category,
    EventData.value('(event/data/text)[6]', 'varchar(max)') AS DestinationLog,
    EventData.value('(event/data/value)[7]', 'varchar(max)') AS IsIntercepted,
    EventData.value('(event/data/value)[8]', 'varchar(max)') AS ErrMessage,
    EventData
    INTO error_reported
    FROM AOHealth_XELData
    WHERE EventData.value('(event/@name)[1]', 'varchar(max)') = 'error_reported';
END TRY
BEGIN CATCH
    IF (ERROR_NUMBER() = 2714) BEGIN
        TRUNCATE TABLE error_reported
        INSERT INTO error_reported
        SELECT  object_name, EventData.value('(event/@timestamp)[1]', 'datetime') AS TimeStamp,
        EventData.value('(event/data/value)[1]', 'int') AS ErrorNum,
        EventData.value('(event/data/value)[2]', 'int') AS Severity,
        EventData.value('(event/data/value)[3]', 'int') AS State,
        EventData.value('(event/data/value)[4]', 'varchar(max)') AS UserDefined,
        EventData.value('(event/data/text)[5]', 'varchar(max)') AS Category,
        EventData.value('(event/data/text)[6]', 'varchar(max)') AS DestinationLog,
        EventData.value('(event/data/value)[7]', 'varchar(max)') AS IsIntercepted,
        EventData.value('(event/data/value)[8]', 'varchar(max)') AS ErrMessage,
        EventData
        FROM AOHealth_XELData
        WHERE EventData.value('(event/@name)[1]', 'varchar(max)') = 'error_reported';
    END ELSE
    SELECT ERROR_NUMBER(), ERROR_MESSAGE()
END CATCH

-- Create table for "alwayson_ddl_executed" events
BEGIN TRY
SELECT  object_name, EventData.value('(event/@timestamp)[1]', 'datetime') AS TimeStamp,
    EventData.value('(event/data/text)[1]', 'varchar(max)') AS DDLAction,
    EventData.value('(event/data/text)[2]', 'varchar(max)') AS DDLPhase,
    EventData.value('(event/data/value)[5]', 'varchar(max)') AS AGName,
    EventData.value('(event/data/value)[3]', 'varchar(max)') AS DDLStatement,
    EventData
    INTO AO_ddl_executed
    FROM AOHealth_XELData
    WHERE EventData.value('(event/@name)[1]', 'varchar(max)') = 'alwayson_ddl_executed';
END TRY
BEGIN CATCH
    IF (ERROR_NUMBER() = 2714) BEGIN
        TRUNCATE TABLE AO_ddl_executed
        INSERT INTO AO_ddl_executed
        SELECT  object_name, EventData.value('(event/@timestamp)[1]', 'datetime') AS TimeStamp,
        EventData.value('(event/data/text)[1]', 'varchar(max)') AS DDLAction,
        EventData.value('(event/data/text)[2]', 'varchar(max)') AS DDLPhase,
        EventData.value('(event/data/value)[5]', 'varchar(max)') AS AGName,
        EventData.value('(event/data/value)[3]', 'varchar(max)') AS DDLStatement,
        EventData
        FROM AOHealth_XELData
        WHERE EventData.value('(event/@name)[1]', 'varchar(max)') = 'alwayson_ddl_executed';
    END ELSE
    SELECT ERROR_NUMBER(), ERROR_MESSAGE()
END CATCH

-- Create table for "lease expiration" events
BEGIN TRY
SELECT  object_name, EventData.value('(event/@timestamp)[1]', 'datetime') AS TimeStamp,
    EventData.value('(event/data/value)[2]', 'varchar(max)') AS AGName,
    EventData.value('(event/data/value)[1]', 'varchar(max)') AS AG_ID,
    EventData
    INTO AO_lease_expired
    FROM AOHealth_XELData
    WHERE EventData.value('(event/@name)[1]', 'varchar(max)') = 'availability_group_lease_expired';
END TRY
BEGIN CATCH
    IF (ERROR_NUMBER() = 2714) BEGIN
        TRUNCATE TABLE AO_lease_expired
        INSERT INTO AO_lease_expired
		SELECT  object_name, EventData.value('(event/@timestamp)[1]', 'datetime') AS TimeStamp,
		EventData.value('(event/data/value)[2]', 'varchar(max)') AS AGName,
		EventData.value('(event/data/value)[1]', 'varchar(max)') AS AG_ID,
		EventData
		FROM AOHealth_XELData
		WHERE EventData.value('(event/@name)[1]', 'varchar(max)') = 'availability_group_lease_expired';
    END ELSE
    SELECT ERROR_NUMBER(), ERROR_MESSAGE()
END CATCH


-- Create table for "availability_replica_manager_state_change" events
BEGIN TRY
SELECT object_name, EventData.value('(event/@timestamp)[1]', 'datetime') AS TimeStamp,
    EventData.value('(event/data/value)[1]', 'int') AS CurrentStateValue,
    EventData.value('(event/data/text)[1]', 'varchar(max)') AS CurrentStateDesc,
    EventData
    INTO AR_Repl_Mgr_State_Change
    FROM AOHealth_XELData
    WHERE EventData.value('(event/@name)[1]', 'varchar(max)') = 'availability_replica_manager_state_change';
END TRY
BEGIN CATCH
    IF (ERROR_NUMBER() = 2714) BEGIN
        TRUNCATE TABLE AR_Repl_Mgr_State_Change
        INSERT INTO AR_Repl_Mgr_State_Change
        SELECT object_name, EventData.value('(event/@timestamp)[1]', 'datetime') AS TimeStamp,
        EventData.value('(event/data/value)[1]', 'int') AS CurrentStateValue,
        EventData.value('(event/data/text)[1]', 'varchar(max)') AS CurrentStateDesc,
        EventData
        FROM AOHealth_XELData
        WHERE EventData.value('(event/@name)[1]', 'varchar(max)') = 'availability_replica_manager_state_change';
    END ELSE
    SELECT ERROR_NUMBER(), ERROR_MESSAGE()
END CATCH

-- Create table for "availability_replica_state_change" events
BEGIN TRY
SELECT object_name, EventData.value('(event/@timestamp)[1]', 'datetime') AS TimeStamp,
    EventData.value('(event/data/value)[4]', 'varchar(max)') AS AGName,
    EventData.value('(event/data/value)[5]', 'varchar(max)') AS ReplicaID,
    EventData.value('(event/data/value)[1]', 'int') AS PrevStateValue,
    EventData.value('(event/data/value)[2]', 'int') AS CurrentStateValue,
    EventData.value('(event/data/text)[1]', 'varchar(max)') AS PrevStateDesc,
    EventData.value('(event/data/text)[2]', 'varchar(max)') AS CurrentStateDesc,
    EventData
    INTO AR_State_Change
    FROM AOHealth_XELData
    WHERE EventData.value('(event/@name)[1]', 'varchar(max)') = 'availability_replica_state_change';
END TRY
BEGIN CATCH
    IF (ERROR_NUMBER() = 2714) BEGIN
        TRUNCATE TABLE AR_State_Change
        INSERT INTO AR_State_Change
        SELECT object_name, EventData.value('(event/@timestamp)[1]', 'datetime') AS TimeStamp,
        EventData.value('(event/data/value)[4]', 'varchar(max)') AS AGName,
        EventData.value('(event/data/value)[5]', 'varchar(max)') AS ReplicaID,
        EventData.value('(event/data/value)[1]', 'int') AS PrevStateValue,
        EventData.value('(event/data/value)[2]', 'int') AS CurrentStateValue,
        EventData.value('(event/data/text)[1]', 'varchar(max)') AS PrevStateDesc,
        EventData.value('(event/data/text)[2]', 'varchar(max)') AS CurrentStateDesc,
        EventData
        FROM AOHealth_XELData
        WHERE EventData.value('(event/@name)[1]', 'varchar(max)') = 'availability_replica_state_change';
    END ELSE
    SELECT ERROR_NUMBER(), ERROR_MESSAGE()
END CATCH;


GO
SET NOCOUNT ON

PRINT 'Error events'
PRINT '============'
PRINT '';
--display results from "error_reported" event data
WITH ErrorCTE (ErrorNum, ErrorCount, FirstDate, LastDate) AS (
SELECT ErrorNum, Count(ErrorNum), min(TimeStamp), max(TimeStamp) As ErrorCount FROM error_reported
    GROUP BY ErrorNum) 
SELECT CAST(ErrorNum as CHAR(10)) ErrorNum,
    CAST(ErrorCount as CHAR(10)) ErrorCount,
    CONVERT(CHAR(25), FirstDate,121) FirstDate,
    CONVERT(CHAR(25), LastDate, 121) LastDate,
        CAST(CASE ErrorNum 
        WHEN 35202 THEN 'A connection for availability group ... has been successfully established...'
        WHEN 1480 THEN 'The %S_MSG database "%.*ls" is changing roles ... because the AG failed over ...'
        WHEN 35206 THEN 'A connection timeout has occurred on a previously established connection ...'
        WHEN 35201 THEN 'A connection timeout has occurred while attempting to establish a connection ...'
        WHEN 41050 THEN 'Waiting for local WSFC service to start.'
        WHEN 41051 THEN 'Local WSFC service started.'
        WHEN 41052 THEN 'Waiting for local WSFC node to start.'
        WHEN 41053 THEN 'Local WSFC node started.'
        WHEN 41054 THEN 'Waiting for local WSFC node to come online.'
        WHEN 41055 THEN 'Local WSFC node is online.'
        WHEN 41048 THEN 'Local WSFC service has become unavailable.'
        WHEN 41049 THEN 'Local WSFC node is no longer online.'
        ELSE m.text END AS VARCHAR(81)) [Abbreviated Message]
     FROM
    ErrorCTE ec LEFT JOIN sys.messages m on ec.ErrorNum = m.message_id
    and m.language_id = 1033
order by CAST(ErrorCount as INT) DESC

PRINT 'Non-failover DDL Events'
PRINT '======================='
PRINT ''
SELECT TimeStamp, CAST(DDLPhase as varchar(10)) DDLPhase,
    CASE WHEN LEN(DDLStatement) > 220
    THEN CAST(DDLStatement as varchar(1155)) + char(10) 
    ELSE CAST(Replace(DDLStatement, char(10), '') as varchar(220)) 
    END as DDLStatement
    FROM AO_ddl_executed WHERE DDLStatement NOT LIKE '%FAILOVER%'
    --OR DDLStatement like 'CREATE%'  or DDLStatement like 'ALTER%'
    ORDER BY TimeStamp

PRINT 'Availability Replica Manager state changes'
PRINT '=========================================='
PRINT ''
-- display results for "availability_replica_manager_state_change" events
SELECT  CONVERT(char(25), TimeStamp, 121) TimeStamp, 
    CAST(CurrentStateDesc as CHAR(30)) [State]
FROM AR_Repl_Mgr_State_Change ORDER BY TimeStamp

PRINT 'Failover DDL Events'
PRINT '======================='
PRINT ''
-- Display results "alwayson_ddl_executed" events
SELECT TimeStamp, CAST(DDLPhase as varchar(10)) DDLPhase, 
    CAST(Replace(DDLStatement, char(10), '') as varchar(80)) as DDLStatement
    FROM AO_ddl_executed WHERE (DDLStatement LIKE '%FAILOVER;%' OR DDLStatement LIKE '%FORCE%')
        AND DDLStatement not like 'CREATE%'
    ORDER BY TimeStamp

PRINT 'Availability Replica state changes'
PRINT '=================================='
PRINT ''
-- display results for "availability_replica_state_change" events
SELECT TimeStamp, cast(AGName as varchar(20)) AGName,
    cast(PrevStateDesc as varchar(30)) [Prev state],
    cast(CurrentStateDesc as varchar(30)) [New State] FROM AR_State_Change
    ORDER BY TimeStamp


PRINT 'Lease Expiration Events'
PRINT '======================='
PRINT ''
-- Display results "lease expiration" events
SELECT TimeStamp, CAST(AGName as varchar(25)) AGName, 
	CAST(AG_ID as varchar(36)) AG_ID
    FROM AO_lease_expired
    ORDER BY TimeStamp
