set nocount on

declare @Header     varchar(1000)
declare @Trailer    varchar(1000)
declare @Schema     sysname
declare @TableName  sysname
declare @ColString  varchar(1000)
declare @CrLf       char(2) = char(13) + char(10)
declare @CrLfTab    char(4) = char(13) + char(10) + char(9) + char(9)
declare @Tab        char(1) = char(9)
declare @Select     varchar(10) 
declare @From       varchar(50)

begin try
    

    set @Schema = 'dbApp'
    set @TableName = 'dbRule'   
    set @Select = 'select' + @Tab
    set @From = 'from ' + @Schema + '.' + @TableName
    
    set @Header =   @CrLf + 
                    'print ''--------------------------------------------------''' + @CrLf + 
                    'print ''Start of creation script for view v_' + @TableName + '''' +
                    @CrLf + 
                    'print ''Start time is: '' + cast(sysdatetime() as varchar(36))' + @CrLf +
                    'print ''--------------------------------------------------''' + @CrLf +
                    @CrLf + @CrLf +
                    'if exists(' + @CrLf +  
                    '       select *' + @CrLf + 
                    '        from sys.views v' + @CrLf + 
                    '            inner join sys.schemas sch on sch.schema_id = v.schema_id' + @CrLf +
                    '        where v.name = ''v_' + @TableName + '''' + @CrLf +
                    '          and sch.name = ''' + @Schema + '' + '''' + @CrLf +               
                    '          ) begin' + @CrLf + 
                    '   drop view ' + @Schema + '.v_' + @TableName + @CrLf +
                    '    print ''view ' + @Schema + '.' + 'v_' + @TableName + ' was dropped''' + @CrLf +
                    'end else begin' + @CrLf +
                    '    print ''view ' + @Schema + '.' + 'v_' + @TableName + ' does not exist, drop skipped''' + @CrLf +
                    'end' + @CrLf +
                    'go' + @CrLf + @CrLf + @CrLf +
                    'create view ' + @Schema + '.v_' + @TableName  + @CrLf +
                    'as'  + @CrLf 
                
    set @Trailer =  @CrLf + @CrLf + 'go' + @CrLf +
                    'if exists(' + @CrLf +  
                    '       select *' + @CrLf + 
                    '        from sys.views v' + @CrLf + 
                    '            inner join sys.schemas sch on sch.schema_id = v.schema_id' + @CrLf +
                    '        where v.name = ''v_' + @TableName + '''' + @CrLf +
                    '          and sch.name = ''' + @Schema + '' + '''' + @CrLf +               
                    '          ) begin' + @CrLf + 
                    '    print ''view ' + @Schema + '.' + @TableName + ' was created successfully ''' + @CrLf +
                    'end else begin' + @CrLf +
                    '    print ''view ' + @Schema + '.' + @TableName + ' does not exist, create failed.''' + @CrLf +
                    'end' + @CrLf + @CrLf +
                    'print ''--------------------------------------------------''' + @CrLf +  
                    'print ''End of creation script for view ' + @Schema + '.' + 'v_' + @TableName + '''' + @CrLf +
                    'print ''End time is: '' + cast(sysdatetime() as varchar(36))' + @CrLf+
                    'print ''--------------------------------------------------''' + @CrLf +
                    'go' + @CrLf        
                   
	
	;with TblColumns (Column_Ord, ColumnName, DataType) as
	(
	    select  c.column_id,
	            c.name, 
	            ty.Name
	    from sys.columns c
	        inner join sys.objects o on o.object_id = c.object_id
	        inner join sys.systypes ty on ty.xtype = c.system_type_id
	where o.name = @TableName
	  and ty.name <> 'sysname'	 
	),
	Num1 (n) as
	(
	    select 1 union all select 1 union all select 1 union all select 1 union all 
	    select 1 union all select 1 union all select 1 union all select 1 union all 
	    select 1 union all select 1
	),
	Num2 (n, RNum) as
	(
	    select  n1.n,
	            row_number() over(order by n1.n)
	    from Num1 n1
	        cross join Num1 n2
	)
	select  @ColString = coalesce(@ColString + 
	                                case 
	                                    when @ColString = '' then '' 
	                                    else ',' 
	                                end, ''
	                              ) + 
	                     case 
	                        when @ColString is null then ''
	                        else @CrLfTab 
	                     end + 
	                     tc.ColumnName 
	from TblColumns tc
	    inner join Num2 n on n.RNum = tc.Column_Ord
    order by tc.Column_Ord
    
    select @Header + @Select + @ColString + @CrLf + @From + @Trailer

end try
begin catch
	select	error_number() as ErrorNumber,
			error_message() as ErrorMEssage,
			error_line() as ErrorLine,
			error_state() as ErrorState,
			error_severity() as ErrorSeverity,
			error_procedure() as ErrorProcedure;
end catch;
        