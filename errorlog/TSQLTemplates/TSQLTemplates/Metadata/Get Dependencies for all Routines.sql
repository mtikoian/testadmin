
declare @sp table (
    Row_Id      int identity(1,1) primary key clustered,
    sp_Name     varchar(128)
)

declare @sp_Name    varchar(128)
declare @Min        int
declare @Max        int
declare @Cnt        int
declare @Sql        varchar(1000)
declare @Sch        varchar(128)

create table #Referencing (
    Called_Nm           varchar(128),
    Entity_Name         varchar(128),
    Referencing_Class   varchar(128),
    Class_Dsc           varchar(1000),
    Referencing_Id      int,
    Schema_Nm           varchar(128)
)
set nocount on

begin try

    set @Sch = 'dbo'

    insert into @sp (sp_Name)
    select  Specific_Name
    from INFORMATION_SCHEMA.ROUTINES
    where SPECIFIC_SCHEMA = @Sch

    select  @Min = min(Row_Id),
            @Max = max(Row_Id)
    from @sp 

    --select *
    --from @sp
    
    set @Cnt = @Min
    while @Cnt <= @Max begin
        select @sp_Name = sp_Name
        from @sp
        where Row_Id = @Cnt
        
        set @sql = '
        select  ' + '''' + @sp_Name + ''',' +
                'x.referencing_entity_name, 
                x.referencing_class, 
                x.referencing_class_desc, 
                x.referencing_id,
                x.referencing_schema_name
        from sys.dm_sql_referencing_entities (''' + @Sch + '.' + @sp_Name + ''', ''OBJECT'') x;'
            
        insert into #Referencing
        execute (@sql)    
    
        set @Cnt = @Cnt +1   --vbandi
    
    end

    select  sp.sp_Name as Called_Nm,
            r.Entity_Name as Calling_Name
    from @sp sp
        left outer join #Referencing r on r.Called_Nm = sp.sp_Name
    order by sp.sp_Name

end try
begin catch
	select error_number(),
		error_message(),
		error_line(),
		error_state(),
		error_severity()
end catch   

drop table #Referencing             