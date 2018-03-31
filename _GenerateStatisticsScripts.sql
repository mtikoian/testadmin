--// This script will pull out the stats detail and create a T-SQL Statement that you can use to create the stats on the primary.

select 'create statistics ' + quotename((object_schema_name(s.object_id)) + '_'+ object_name(s.object_id) +'_' + c.name) + char(10)
	+ char(9) + 'on ' + quotename(object_schema_name(s.object_id)) +'.' + quotename(object_name(s.object_id)) + '(' + quotename(c.name) + ');' + char(10)
	+ 'go'
from sys.stats as s
join sys.stats_columns as sc on s.stats_id = sc.stats_id
join sys.columns as c on sc.object_id = c.object_id
	and sc.column_id = c.column_id
where s.is_temporary = 1
;

--// Explain the alternative of creating statements that will execute when
--// the server comes online to create them on the secondary and not the primary.