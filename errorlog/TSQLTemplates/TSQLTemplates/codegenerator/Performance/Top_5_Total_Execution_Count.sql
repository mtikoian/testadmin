


select  top 50 qs.execution_count ,
        total_worker_time / execution_count as [avg CPU time],
        o.Name,
        substring(st.text, (qs.statement_start_offset / 2) + 1, 
        (
            case qs.statement_end_offset
                when -1 then datalength(st.text)
                else qs.statement_end_offset
            end - qs.statement_start_offset)/2 + 1) as Statement_Text,
        qs.*    
from sys.dm_exec_query_stats as qs
    cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
    inner join sys.Objects o on o.Object_Id = st.ObjectId
--where st.DBID = 43    
order by qs.execution_count desc;
        
--select db_id()       

--select * from sys.dm_exec_requests    