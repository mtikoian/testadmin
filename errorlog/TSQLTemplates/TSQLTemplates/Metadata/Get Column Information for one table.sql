
declare @Schema_Nm  varchar(128);
declare @Table_Nm   varchar(128);


set @Schema_Nm = 'Aga';
set @Table_Nm  = 'Group_Recipient';


select	ss.Name as Table_Schema,
		st.Name as Table_Name,
		sc.Name as Column_Name,
		sc.Column_Id as Ordinal_Position,
		sty.Name as Data_Type,
		sc.Max_Length as Character_Maximum_Length,
		sc.is_Nullable,	
		sc.is_identity,
		null as Column_Default,
		sc.Precision as Numeric_Precision,
		sc.Scale as Numeric_Scale,
		sc.Collation_Name,
		sc.is_ansi_padded,
		sc.is_rowguidcol,
		sc.is_computed--,
		--sc.is_sparse,
		--sc.is_column_set
from sys.Columns sc
	inner join sys.Tables st on st.Object_Id = sc.Object_Id
	inner join sys.Schemas ss on ss.Schema_Id = st.Schema_Id
	inner join sys.Types sty on sty.System_Type_Id = sc.System_Type_Id
where sty.Name <> 'sysname'	
  and ss.name = @Schema_Nm
  and st.name = @Table_Nm 
order by sc.Column_Id   

select  space(12) + sc.Name + ','
from sys.Columns sc
	inner join sys.Tables st on st.Object_Id = sc.Object_Id
	inner join sys.Schemas ss on ss.Schema_Id = st.Schema_Id
	inner join sys.Types sty on sty.System_Type_Id = sc.System_Type_Id
where sty.Name <> 'sysname'	
  and ss.name = @Schema_Nm
  and st.name = @Table_Nm 
order by sc.Column_Id               