BEGIN TRANSACTION 
BEGIN Try 
DECLARE @collection_set_id_1 INT 
DECLARE @collection_set_uid_2 uniqueidentifier 
EXEC [msdb].[dbo].[sp_syscollector_create_collection_set] @name=N'system_health_deadlock', @collection_mode=1, 
@description=N'system_health_deadlock', @logging_level=1, @days_until_expiration=14, 
@schedule_name=N'CollectorSchedule_Every_15min', @collection_set_id=@collection_set_id_1 OUTPUT, 
@collection_set_uid=@collection_set_uid_2 OUTPUT 

SELECT @collection_set_id_1, @collection_set_uid_2 
  
DECLARE @collector_type_uid_3 uniqueidentifier 
SELECT @collector_type_uid_3 = collector_type_uid FROM [msdb].[dbo].[syscollector_collector_types] 
WHERE name = N'Generic T-SQL Query Collector Type'; 
DECLARE @collection_item_id_4 INT 
EXEC [msdb].[dbo].[sp_syscollector_create_collection_item] 
@name=N'system_health_deadlock'
, @parameters=N'<ns:TSQLQueryCollector xmlns:ns="DataCollectorType"><Query><Value>

SELECT CAST(
                  REPLACE(
                        REPLACE(XEventData.XEvent.value(''(data/value)[1]'', ''varchar(max)''), 
                        '''', ''''),
                  '''','''')
            AS XML) AS DeadlockGraph
FROM
(SELECT CAST(target_data AS XML) AS TargetData
from sys.dm_xe_session_targets st
join sys.dm_xe_sessions s on s.address = st.event_session_address
where name = ''system_health'') AS Data
CROSS APPLY TargetData.nodes (''//RingBufferTarget/event'') AS XEventData (XEvent)
where XEventData.XEvent.value(''@name'', ''varchar(4000)'') = ''xml_deadlock_report'' 
  
</Value><OutputTable>system_health_deadlock</OutputTable></Query></ns:TSQLQueryCollector>', 
@collection_item_id=@collection_item_id_4 OUTPUT
, @frequency=900 --#seconds in collection interval
,@collection_set_id=@collection_set_id_1
, @collector_type_uid=@collector_type_uid_3 

SELECT @collection_item_id_4 
  
COMMIT TRANSACTION; 
END Try 
BEGIN Catch 
ROLLBACK TRANSACTION; 
DECLARE @ErrorMessage NVARCHAR(4000); 
DECLARE @ErrorSeverity INT; 
DECLARE @ErrorState INT; 
DECLARE @ErrorNumber INT; 
DECLARE @ErrorLine INT; 
DECLARE @ErrorProcedure NVARCHAR(200); 
SELECT @ErrorLine = ERROR_LINE(), 
@ErrorSeverity = ERROR_SEVERITY(), 
@ErrorState = ERROR_STATE(), 
@ErrorNumber = ERROR_NUMBER(), 
@ErrorMessage = ERROR_MESSAGE(), 
@ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-'); 
RAISERROR (14684, @ErrorSeverity, 1 , @ErrorNumber, @ErrorSeverity, @ErrorState, @ErrorProcedure, 
@ErrorLine, @ErrorMessage); 
  
END Catch; 
  
GO 