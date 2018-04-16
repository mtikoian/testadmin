

	select 'ALTER INDEX ' + ii.IndexName + ' ON ' + ii.SchemaName + '.' + ii.TableName + ' DISABLE;'
	from (
		select	sc.name as SchemaName, 
				st.name as TableName, 
				si.Name as IndexName
		from sys.tables st
			inner join sys.indexes si on st.[object_id] = si.[object_id]
			inner join sys.schemas sc on st.[schema_id] = sc.[schema_id]
		where st.type = 'U' 
		  and si.type = 2
		  ) ii;
go   



	      

	select 'ALTER INDEX ' + ii.IndexName + ' ON ' + ii.SchemaName + '.' + ii.TableName + ' REBUILD;'
	from (
		select	sc.name as SchemaName, 
				st.name as TableName, 
				si.Name as IndexName
		from sys.tables st
			inner join sys.indexes si on st.[object_id] = si.[object_id]
			inner join sys.schemas sc on st.[schema_id] = sc.[schema_id]
		where st.type = 'U' 
		  and si.type = 2
		  ) ii;
go         
                