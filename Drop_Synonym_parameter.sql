set nocount on

declare @Schema     varchar(128)
declare @CrLf       char(2) = char(13) + char(10)
declare @ObjectList  table (
    SchemaNm    varchar(128),
    ObjectNm     varchar(128)
);

declare @SchemaList table (
    SchemaNm    varchar(128)
);
insert into @ObjectList
values  ('cmdb', 'cc_company'),
        ('dbo', 'get_company_details');

set @Schema = 'cmdb'

begin try

    -- If the user has supplied table names, use them
    if exists (
        select *
        from @ObjectList
              )
    begin

	 ;with SynonymNames (SchemaNm, ObjectNm) as
        (
            select  s.name,
                    syn.name
            from sys.Synonyms syn
                inner join sys.schemas s on s.schema_id = syn.schema_id
                inner join @ObjectList tl on tl.SchemaNm = s.name
                                        and tl.ObjectNm = syn.name
        )

	--	select * from SynonymNames

		select  'if exists (' + @CrLf +
        '       select 1' + @CrLf +
        '       from sys.Synonyms syn' + @CrLf +
        '           inner join sys.schemas sch on sch.schema_id = syn.Schema_Id' + @CrLf +
        '       where sch.Name = ''' + @Schema + '''' + @CrLf +
        '         and syn.Name = ''' + syn.ObjectNm + '''' + @CrLf +
        '          ) begin' + @CrLf  +
        '    drop synonym ' + @Schema + '.' + syn.ObjectNm + @CrLf +
        'end' + @CrLf + @CrLf  
--select *                    
from SynonymNames syn
   

	 end
	  else begin

	 select  'if exists (' + @CrLf +
        '       select 1' + @CrLf +
        '       from sys.Synonyms syn' + @CrLf +
        '           inner join sys.schemas sch on sch.schema_id = syn.Schema_Id' + @CrLf +
        '       where sch.Name = ''' + @Schema + '''' + @CrLf +
        '         and syn.Name = ''' + syn.name + '''' + @CrLf +
        '          ) begin' + @CrLf  +
        '    drop synonym ' + @Schema + '.' + syn.name + @CrLf +
        'end' + @CrLf + @CrLf  
--select *                    
from sys.synonyms syn
    inner join sys.schemas sch on sch.schema_id = syn.schema_id
where sch.name = @Schema
  --and t.type in ('FN', 'TF', 'IF', 'P', 'TR')
end

end try 
begin catch
	select error_number(),
		error_message(),
		error_line(),
		error_state(),
		error_severity()
end catch


                  