
SELECT  TE.name AS [EventName] ,
        v.subclass_name ,
        t.IsSystem
FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                              f.[value]
                                                      FROM    sys.fn_trace_getinfo(NULL) f
                                                      WHERE   f.property = 2
                                                    )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
        JOIN sys.trace_subclass_values v ON v.trace_event_id = TE.trace_event_id
                                            AND v.subclass_value = t.EventSubClass
WHERE   te.name IN ( 'Server Memory Change' )
