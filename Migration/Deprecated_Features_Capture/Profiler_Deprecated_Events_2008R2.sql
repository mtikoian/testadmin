/* Connect to 2008R2 Instance */

/****************************************************/
/* Created by: SQL Server 2012  Profiler          */
/* Date: 02/11/2014  09:14:41 AM         */
/****************************************************/


-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
set @maxfilesize = 5

-- Please replace the text InsertFileNameHere, with an appropriate
-- filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
-- will be appended to the filename automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share

exec @rc = sp_trace_create @TraceID output, 0, N'InsertFileNameHere', @maxfilesize, NULL 
if (@rc != 0) goto error

-- Client side File and Table cannot be scripted

-- Set the events
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 125, 1, @on
exec sp_trace_setevent @TraceID, 125, 9, @on
exec sp_trace_setevent @TraceID, 125, 3, @on
exec sp_trace_setevent @TraceID, 125, 11, @on
exec sp_trace_setevent @TraceID, 125, 4, @on
exec sp_trace_setevent @TraceID, 125, 6, @on
exec sp_trace_setevent @TraceID, 125, 7, @on
exec sp_trace_setevent @TraceID, 125, 8, @on
exec sp_trace_setevent @TraceID, 125, 10, @on
exec sp_trace_setevent @TraceID, 125, 12, @on
exec sp_trace_setevent @TraceID, 125, 14, @on
exec sp_trace_setevent @TraceID, 125, 22, @on
exec sp_trace_setevent @TraceID, 125, 26, @on
exec sp_trace_setevent @TraceID, 125, 34, @on
exec sp_trace_setevent @TraceID, 125, 35, @on
exec sp_trace_setevent @TraceID, 125, 41, @on
exec sp_trace_setevent @TraceID, 125, 49, @on
exec sp_trace_setevent @TraceID, 125, 50, @on
exec sp_trace_setevent @TraceID, 125, 51, @on
exec sp_trace_setevent @TraceID, 125, 55, @on
exec sp_trace_setevent @TraceID, 125, 60, @on
exec sp_trace_setevent @TraceID, 125, 61, @on
exec sp_trace_setevent @TraceID, 125, 63, @on
exec sp_trace_setevent @TraceID, 125, 64, @on
exec sp_trace_setevent @TraceID, 126, 1, @on
exec sp_trace_setevent @TraceID, 126, 9, @on
exec sp_trace_setevent @TraceID, 126, 3, @on
exec sp_trace_setevent @TraceID, 126, 11, @on
exec sp_trace_setevent @TraceID, 126, 4, @on
exec sp_trace_setevent @TraceID, 126, 6, @on
exec sp_trace_setevent @TraceID, 126, 7, @on
exec sp_trace_setevent @TraceID, 126, 8, @on
exec sp_trace_setevent @TraceID, 126, 10, @on
exec sp_trace_setevent @TraceID, 126, 12, @on
exec sp_trace_setevent @TraceID, 126, 14, @on
exec sp_trace_setevent @TraceID, 126, 22, @on
exec sp_trace_setevent @TraceID, 126, 26, @on
exec sp_trace_setevent @TraceID, 126, 34, @on
exec sp_trace_setevent @TraceID, 126, 35, @on
exec sp_trace_setevent @TraceID, 126, 41, @on
exec sp_trace_setevent @TraceID, 126, 49, @on
exec sp_trace_setevent @TraceID, 126, 50, @on
exec sp_trace_setevent @TraceID, 126, 51, @on
exec sp_trace_setevent @TraceID, 126, 55, @on
exec sp_trace_setevent @TraceID, 126, 60, @on
exec sp_trace_setevent @TraceID, 126, 61, @on
exec sp_trace_setevent @TraceID, 126, 63, @on
exec sp_trace_setevent @TraceID, 126, 64, @on


-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go
