/* Verify Trace ID */
SELECT * FROM sys.fn_trace_getinfo(DEFAULT) 
GO

/* Stop the Trace */
EXEC sp_trace_setstatus @traceid = 2, @status = 0;
GO

/* Close the Trace */
EXEC sp_trace_setstatus @traceid = 2, @status = 2;
GO

/* Read the Trace */
/* Open in SQL Profiler or */
/* Query using fn_trace_gettable from the instance which created it*/

/* Notice in results that the sp_trace* and fn_trace* is deprecated in 2012, but not earlier */
 
SELECT * 
FROM fn_trace_gettable('c:\SQLOutput\TraceDeprecation2008.trc', default);

SELECT * 
FROM fn_trace_gettable('c:\SQLOutput\TraceDeprecation2008R2.trc', default);

SELECT * 
FROM fn_trace_gettable('c:\SQLOutput\TraceDeprecation2012.trc', default);
