

begin try

    --select distinct type_desc from sys.objects
    
    select  o.name,
            o.type_desc
    from  sys.objects o 
    where o.type_desc in ('USER_TABLE', 'SQL_STORED_PROCEDURE', 'SQL_SCALAR_FUNCTION', 'VIEW', 'SQL_INLINE_TABLE_VALUED_FUNCTION', 'SQL_TRIGGER' )
	
    select  ss.name,
            o.name,
            o.type_desc, 
            ep.name, 
            ep.value
    from  sys.objects o 
        inner join sys.schemas ss on ss.schema_id = o.schema_id
        left outer join sys.extended_properties ep on ep.major_id = o.object_id
    where o.type_desc in ('USER_TABLE', 'SQL_STORED_PROCEDURE', 'SQL_SCALAR_FUNCTION', 'VIEW', 'SQL_INLINE_TABLE_VALUED_FUNCTION', 'SQL_TRIGGER' )
      and ep.name like 'MS%'
      and ep.minor_id = 0
    order by ss.name, o.name

end try
begin catch
	select  error_number(),
		    error_message()
end catch               