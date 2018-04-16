
select  top 50 
        qs.total_worker_time,
        qs.Execution_Count,
        substring(st.text, (qs.statement_start_offset / 2) + 1, 
        (
            case qs.statement_end_offset
                when -1 then datalength(st.text)
                else qs.statement_end_offset
            end - qs.statement_start_offset)/2 + 1) as Statement_Text,
        qs.*    
from sys.dm_exec_query_stats as qs
    cross apply sys.dm_exec_sql_text(qs.sql_handle) as st
where st.DBID = 30    
order by qs.total_worker_time desc;
       