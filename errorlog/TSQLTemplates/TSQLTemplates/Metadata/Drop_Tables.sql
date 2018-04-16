set nocount on;

declare @CrLf char(2) = char(13) + char(10);

declare @TableList  table (
    SchemaNm    varchar(128),
    TableNm     varchar(128)
);

declare @SchemaList table (
    SchemaNm    varchar(128)
);

--insert into @TableList
--values  ('aga', 'Group_Type'),
--        ('dbo', 'Account');

insert into @SchemaList 
values  ('dbo')--,
--        ('aga');

print '-- Drop tables --'

begin try

    -- If the user has supplied table names, use them
    if exists (
        select *
        from @TableList
              )
    begin

        ;with TableNames (SchemaNm, TableNm) as
        (
            select  s.name,
                    t.name
            from sys.tables t
                inner join sys.schemas s on s.schema_id = t.schema_id
                inner join @TableList tl on tl.SchemaNm = s.name
                                        and tl.TableNm = t.name
        )
        select  'if exists (' + @CrLf +
                '   select *' + @CrLf +
                '   from information_schema.tables' + @CrLf +
                '   where Table_Schema = ''' + tn.SchemaNm + '''' + @CrLf +
                '     and Table_Name = ''' + tn.TableNm + '''' + @CrLf +
                '          ) begin' + @CrLf +
                '   print ''Dropping table ' + tn.SchemaNm + '.' + tn.TableNm + '''' + @CrLf +
                '   drop table ' + tn.SchemaNm + '.' + tn.TableNm + @CrLf +
                'end;' + @CrLf +  'go' + @CrLf + @CrLf 
        from TableNames tn;
    
    end else 
    if exists (     -- or else if the user has supplied schema names
        select *
        from @SchemaList
              ) 
    begin -- get tables for a schema

        ;with TableNames (SchemaNm, TableNm) as
        (
            select  s.name,
                    t.name
            from sys.tables t
                inner join sys.schemas s on s.schema_id = t.schema_id
                inner join @SchemaList sl on sl.SchemaNm = s.name
        )
        select  'if exists (' + @CrLf +
                '   select *' + @CrLf +
                '   from information_schema.tables' + @CrLf +
                '   where Table_Schema = ''' + tn.SchemaNm + '''' + @CrLf +
                '     and Table_Name = ''' + tn.TableNm + '''' + @CrLf +
                '          ) begin' + @CrLf +
                '   print ''Dropping table ' + tn.SchemaNm + '.' + tn.TableNm + '''' + @CrLf +
                '   drop table ' + tn.SchemaNm + '.' + tn.TableNm +  @CrLf +
                'end;' + @CrLf + 'go' + @CrLf + @CrLf  
        from TableNames tn;
        
    end else begin -- otherwise, get all tables in all schemas

        ;with TableNames (SchemaNm, TableNm) as
        (
            select  s.name,
                    t.name
            from sys.tables t
                inner join sys.schemas s on s.schema_id = t.schema_id
        )
        select  'if exists (' + @CrLf +
                '   select *' + @CrLf +
                '   from information_schema.tables' + @CrLf +
                '   where Table_Schema = ''' + tn.SchemaNm + '''' + @CrLf +
                '     and Table_Name = ''' + tn.TableNm + '''' + @CrLf +
                '          ) begin' + @CrLf +
                '   drop table ' + tn.SchemaNm + '.' + tn.TableNm + @CrLf +
                'end' + @CrLf + @CrLf  
        from TableNames tn;
    end

end try
begin catch
	select error_number(),
		error_message(),
		error_line(),
		error_state(),
		error_severity()
end catch