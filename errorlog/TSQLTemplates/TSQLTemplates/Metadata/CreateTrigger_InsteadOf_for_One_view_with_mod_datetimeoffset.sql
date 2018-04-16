set nocount on

declare @Header     varchar(2000)
declare @Trailer    varchar(2000)
declare @Schema     sysname
declare @TableName  sysname
declare @TrObject   sysname
declare @ColString  varchar(8000)
declare @CrLf       char(2) = char(13) + char(10)
declare @CrLfTab    char(4) = char(13) + char(10) + char(9) + char(9)
declare @Tab        char(1) = char(9)
declare @Select     varchar(2000) 
declare @From       varchar(50)
declare @Action     varchar(3)
declare @TrgAction  varchar(30)
declare @CTE        varchar(2000)
declare @Merge      varchar(2000)
declare @IdCol      varchar(128)
declare @Insert     varchar(1000)
declare @UpDate     varchar(1000)
declare @TriggerTyp varchar(10)

declare @Cols   table (
    RowId       int identity(1,1) primary key clustered,
    Column_Ord  smallint,
    ColumnName  varchar(128), 
    DataType    varchar(128)
)

begin try

    set @Schema = 'CorpBill'
    set @TableName = 'PS_Detail_Billing_Metric'
    set @TrObject  = 'v_PS_Detail_Billing_Metric'   
    --set @Select = 'select' + @Tab
    set @From = 'from ' + @Schema + '.' + @TableName
    set @Action = 'IU'
    set @IdCol = 'Work_Step_Id'
    set @TriggerTyp = 'instead of'
    
    set @TrgAction = 
        case
            when @Action = 'IUD' then 'insert, update, delete'
            when @Action = 'IU' then 'insert, update'
            when @Action = 'ID' then 'insert, delete'
            when @Action = 'UD' then 'update, delete'
            when @Action = 'I' then 'insert'
            when @Action = 'U' then 'update'
            when @Action = 'D' then 'delete'
        end
    
    set @Header =   @CrLf + 
                    'print ''--------------------------------------------------''' + @CrLf + 
                    'print ''Start of creation script for trigger tr_' + @TrObject + @Action + '''' +
                    @CrLf + 
                    'print ''Start time is: '' + cast(sysdatetime() as varchar(36))' + @CrLf +
                    'print ''--------------------------------------------------''' + @CrLf +
                    @CrLf + @CrLf +
                    'if exists(' + @CrLf +  
                    '        select *' + @CrLf + 
                    '        from sys.triggers tr' + @CrLf + 
                    '            inner join sys.Objects o on o.Object_Id = tr.Parent_Id' + @CrLf +
                    '            inner join sys.schemas sch on sch.schema_id = o.schema_id' + @CrLf +
                    '        where tr.name = ''tr_' + @TrObject + @Action + '''' + @CrLf +
                    '          and sch.name = ''' + @Schema + '' + '''' + @CrLf +               
                    '          ) begin' + @CrLf + 
                    '    drop trigger ' + @Schema + '.tr_' + @TrObject + @Action + @CrLf +
                    '    print ''trigger ' + @Schema + '.' + 'tr_' + @TrObject + @Action + ' was dropped''' + @CrLf +
                    'end else begin' + @CrLf +
                    '    print ''trigger ' + @Schema + '.' + 'tr_' + @TrObject + @Action + ' does not exist, drop skipped''' + @CrLf +
                    'end' + @CrLf +
                    'go' + @CrLf + @CrLf + @CrLf +
                    'create trigger ' + @Schema + '.tr_' + @TrObject + @Action  + @CrLf +
                    '    on ' +  @Schema + '.' + @TrObject + ' ' + @TriggerTyp + ' ' + @TrgAction + @CrLf +
                    'as'  + @CrLf 
                
    set @Trailer =  @CrLf + @CrLf + 'go' + @CrLf +
                    'if exists(' + @CrLf +  
                    '        select *' + @CrLf + 
                    '        from sys.triggers tr' + @CrLf + 
                    '            inner join sys.Objects o on o.Object_Id = tr.Parent_Id' + @CrLf +
                    '            inner join sys.schemas sch on sch.schema_id = o.schema_id' + @CrLf +
                    '        where tr.name = ''tr_' + @TrObject + @Action + '''' + @CrLf +
                    '          and sch.name = ''' + @Schema + '' + '''' + @CrLf +               
                    '          ) begin' + @CrLf + 
                    '    print ''trigger ' + @Schema + '.tr_' + @TrObject + @Action + ' was created successfully.''' + @CrLf +
                    'end else begin' + @CrLf +
                    '    print ''trigger ' + @Schema + '.tr_' + @TrObject + @Action + ' does not exist, create failed.''' + @CrLf +
                    'end' + @CrLf + @CrLf +
                    'print ''--------------------------------------------------''' + @CrLf +  
                    'print ''End of creation script for trigger ' + @Schema + '.' + 'tr_' + @TrObject + '''' + @CrLf +
                    'print ''End time is: '' + cast(sysdatetime() as varchar(36))' + @CrLf+
                    'print ''--------------------------------------------------''' + @CrLf +
                    'go' + @CrLf        
                   
	insert into @Cols (Column_Ord, ColumnName, DataType)
	select  c.column_id,
	        c.name, 
	        ty.Name
	from sys.columns c
	    inner join sys.objects o on o.object_id = c.object_id
	    inner join sys.systypes ty on ty.xtype = c.system_type_id
	where o.name = @TrObject
	  and ty.name <> 'sysname'		  
	
	-- get the columns that are included in the lists
	;with TblColumns (Column_Ord, ColumnName, DataType) as
	(
	    select  c.Column_Ord,
	            c.ColumnName, 
	            c.DataType
	    from @Cols c	         
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
	                     tc.ColumnName --+
	                     --case 
	                     --   when tc.DataType not like 'datetimeoffset%' 
	                     --       then tc.ColumnName 
	                     --   when tc.DataType like 'datetimeoffset%' 
	                     --    and tc.ColumnName like '%_Dtm%'
	                     --       then 
	                     --           'cast(' + tc.ColumnName + ' as date) as ' + replace(tc.ColumnName, '_Dtm', '_Dt,')
	                     --           + @CrLfTab +
	                     --           'cast(' + tc.ColumnName + ' as time) as ' + replace(tc.ColumnName, '_Dtm', '_Tm,')
	                     --           + @CrLfTab +
	                     --           'datepart(tz, ' + tc.ColumnName + ') as ' + replace(tc.ColumnName, '_Dtm', '_Ofs')                                    	                                 
	                     --   else 'cast(' + tc.ColumnName + ' as date) as ' + tc.ColumnName + '_Dt,'
	                     --        + @CrLfTab +
	                     --        'cast(' + tc.ColumnName + ' as time) as ' + tc.ColumnName + '_Tm,'
	                     --        + @CrLfTab +
	                     --        'datepart(tz, ' + tc.ColumnName + ') as ' + tc.ColumnName + '_Ofs'
	                     --end
	from TblColumns tc
	    inner join Num2 n on n.RNum = tc.Column_Ord
	where (ColumnName not like 'Add_%')
	  and (ColumnName not like 'Insert_%')
    order by tc.Column_Ord
    
    -- now create the update string
	;with TblColumns (Column_Ord, ColumnName, DataType) as
	(
	    select  c.Column_Ord,
	            c.ColumnName, 
	            c.DataType
	    from @Cols c	         
	)
	select  @UpDate = coalesce(@UpDate + 
	                                case 
	                                    when @UpDate = '' then '' 
	                                    else ',' 
	                                end, ''
	                              ) + 
	                     case 
	                        when @UpDate is null then ''
	                        else @CrLfTab + @Tab 
	                     end + 
	                     tc.ColumnName + ' = src.' + tc.ColumnName
	from TblColumns tc
	where (ColumnName <> @IdCol)
	  and (ColumnName not like 'Add_%')
	  and (ColumnName not like 'Insert_%')
	order by Column_Ord
	
	-- and create the insert string
	;with TblColumns (Column_Ord, ColumnName, DataType) as
	(
	    select  c.Column_Ord,
	            c.ColumnName, 
	            c.DataType
	    from @Cols c	         
	)
	select  @Insert = coalesce(@Insert + 
	                                case 
	                                    when @Insert = '' then '' 
	                                    else ',' 
	                                end, ''
	                              ) + 
	                     case 
	                        when @Insert is null then ''
	                        else @CrLfTab 
	                     end + 
	                     tc.ColumnName
	from TblColumns tc
	where (ColumnName <> @IdCol)
	  and (ColumnName not like 'Add_%')
	  and (ColumnName not like 'Insert_%')
	order by Column_Ord
    
    set @CTE =  ';with RowData (' + @CrLfTab + @ColString + @CrLfTab + @Tab + ') as ' 
    set @Select = '(' + @CrLf + 'select' + @Tab + @ColString + @CrLf + 'from inserted' + @CrLf + ')' + @CrLf
    set @Merge  =   'merge into ' + 
                    @Schema + 
                    '.' + 
                    @TableName + 
                    ' as tgt' + 
                    @CrLf + 
                    'using Rowdata as src' + @CrLf +
                    '    on tgt.' + @IdCol + ' = src.' + @IdCol + @CrLf +
                    'when not matched by target then ' + @CrLf +
                    'insert ('  + @CrLfTab + 
                    @Insert + @CrLfTab + ')' + @CrLf + 
                    'values (' + @CrLfTab + @Insert + @CrLfTab + ')' + @CrLf +
                    'when matched then' + @CrLf + @Tab + 'update' + @CrLfTab + 'set '
    
    --select @Header + @Select + @ColString + @CrLf + @From + @Trailer
    --select @ColString
    select @Header + @CTE + @CrLf + @Select + @Merge + @UpDate + ';' + @CrLf + @Trailer
    --select @Select

end try
begin catch
	select	error_number() as ErrorNumber,
			error_message() as ErrorMEssage,
			error_line() as ErrorLine,
			error_state() as ErrorState,
			error_severity() as ErrorSeverity,
			error_procedure() as ErrorProcedure;
end catch;
        