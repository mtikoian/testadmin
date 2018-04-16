
	      
select	db_name() as Table_Catalog,
		ss.name	as Table_Schema,
		st.name as Table_Name,
		sc.name as Column_Name,
		sc.column_id as Ordinal_Position,
		sc.is_nullable as Is_Nullable,		
		sty.name as Data_Type,
		sc.max_length as Max_Length,
		sc.precision as Col_Precision,
		sc.scale as Col_Scale,
		sc.is_identity as Is_Identity,
		sc.is_computed as Is_Computed,
		sc.is_rowguidcol as Is_RowGUIDCol,
		sdc.definition as Default_Constraint,
		scc.definition as Check_Constraint
from sys.tables st	
	inner join sys.schemas ss on ss.schema_id = st.schema_id 
	inner join sys.columns sc on sc.object_id = st.object_id 
	inner join sys.types sty on sty.user_type_id = sc.user_type_id
	left outer join sys.identity_columns sic on sic.object_id = sc.object_id 
											and sic.column_id = sc.column_id   
	left outer join sys.default_constraints sdc on sdc.parent_object_id = st.object_id
											   and sdc.parent_column_id = sc.column_id
	left outer join sys.check_constraints scc on scc.parent_object_id = st.object_id
											 and scc.parent_column_id = sc.column_id
											