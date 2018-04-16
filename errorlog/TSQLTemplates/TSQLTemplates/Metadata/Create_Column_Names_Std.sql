
declare @DataNames table (
    Row_Id      int identity(1,1) primary key clustered,
    DataName_Tx varchar(40)
)    

declare @ActionFl   varchar(20)
declare @Product    varchar(20)
declare @Agg        varchar(10)
declare @TimeMod    varchar(10)
declare @Time       varchar(10)
declare @Action     varchar(20)
declare @BaseMod    varchar(10)
declare @Base       varchar(20)
declare @Class      varchar(5)

/*
    set @ActionFl   = null
    set @Product    = null
    set @Agg        = null
    set @TimeMod    = null
    set @Time       = null
    set @Action     = null 
    set @BaseMod    = null
    set @Base       = ''
    set @Class      = '' 
    
    insert into @DataNames (DataName_Tx)
    select  case when @ActionFl is null then '' else @ActionFl + '_' end +    
            case when @Product is null then '' else @Product + '_' end +
            case when @Agg is null then '' else @Agg + '_' end +
            case when @TimeMod is null then '' else @TimeMod + '_' end +
            case when @Time is null then '' else @Time + '_' end + 
            case when @Action is null then '' else @Action + '_' end +
            case when @BaseMod is null then '' else @BaseMod + '_' end +  
            @Base +  '_' + @Class
*/


begin try	
    -- 
    set @ActionFl   = null
    set @Product    = 'GWPBill'
    set @Agg        = 'Sum'
    set @TimeMod    = null
    set @Time       = 'Mo'
    set @Action     = null 
    set @BaseMod    = null
    set @Base       = 'Mkt'
    set @Class      = 'Val'
    
    insert into @DataNames (DataName_Tx)
    select  case when @ActionFl is null then '' else @ActionFl + '_' end +    
            case when @Product is null then '' else @Product + '_' end +
            case when @Agg is null then '' else @Agg + '_' end +
            case when @TimeMod is null then '' else @TimeMod + '_' end +
            case when @Time is null then '' else @Time + '_' end + 
            case when @Action is null then '' else @Action + '_' end +
            case when @BaseMod is null then '' else @BaseMod + '_' end +  
            @Base +  '_' + @Class
	--
	
	select * 
	from @DataNames 
	order by Row_Id
	
end try
begin catch
	select error_number()
end catch               