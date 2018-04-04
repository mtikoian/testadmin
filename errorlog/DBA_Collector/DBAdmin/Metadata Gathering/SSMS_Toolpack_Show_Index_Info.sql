SELECT 'Index Information'
SELECT	i.name [Index Name],
		i.type_desc [Index Type],
		CASE i.is_primary_key
			WHEN 1 THEN 'Yes'
			ELSE 'No'
		END [Is Primary Key],
		(
			SELECT	c2.name + ', '
			FROM	sys.index_columns ikc
						JOIN sys.columns c2
							ON ikc.column_id = c2.column_id
							AND ikc.object_id = c2.object_id
							AND ikc.is_included_column = 0
			WHERE	ikc.index_id = i.index_id
					AND ikc.object_id = i.object_id
			ORDER BY ikc.index_column_id ASC
			FOR XML PATH('')
		) [Index Columns],
		(
			SELECT	c1.name + ', '
			FROM	sys.index_columns ikc
						JOIN sys.columns c1
							ON ikc.column_id = c1.column_id
							AND ikc.object_id = c1.object_id
							AND ikc.is_included_column = 1
			WHERE	ikc.index_id = i.index_id
			ORDER BY ikc.index_column_id ASC
			FOR XML PATH('')
		) [Included Columns]

FROM	sys.indexes i 
			JOIN sys.objects o 
				ON i.object_id = o.object_id
			JOIN sys.schemas s 
				ON o.schema_id = s.schema_id
WHERE	o.name = '|ObjectName|'
		AND s.name = '|SchemaName|'
		
	