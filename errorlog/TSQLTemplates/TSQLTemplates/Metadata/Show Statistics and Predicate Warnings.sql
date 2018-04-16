SELECT  TE.name AS [EventName] ,
        T.DatabaseName ,
        t.DatabaseID ,
        t.NTDomainName ,
        t.ApplicationName ,
        t.LoginName ,
        t.SPID ,
        t.StartTime
FROM    sys.fn_trace_gettable(CONVERT(VARCHAR(150), ( SELECT TOP 1
                                                              f.[value]
                                                      FROM    sys.fn_trace_getinfo(NULL) f
                                                      WHERE   f.property = 2
                                                    )), DEFAULT) T
        JOIN sys.trace_events TE ON T.EventClass = TE.trace_event_id
WHERE   te.name = 'Missing Column Statistics'
        OR te.name = 'Missing Join Predicate'
