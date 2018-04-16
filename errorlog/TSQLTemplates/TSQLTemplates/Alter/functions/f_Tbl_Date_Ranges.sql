if exists (
    select 1
    from information_schema.ROUTINES
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Tbl_Date_Ranges'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_Tbl_Date_Ranges
end

go

create function dbo.f_Tbl_Date_Ranges 
    (
        @i_StartDt  datetime,
        @i_EndDt    datetime,
        @i_RangeTp  char(1)        
    )

returns table

as
-- =pod
/**

Filename   : f_Tbl_Date_Ranges.sql
Author     : Stephen R. McLarnon Sr.
Created    : 2012-12-26 

SCM
$Author: smclarnon $
$Date: 2013-01-17 09:08:00 -0500 (Thu, 17 Jan 2013) $
$Rev: 253 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_Tbl_Date_Ranges.sql $



Object: dbo.f_Tbl_Date_Ranges
ObjectType : Table valued function

Description: Returns a table of date ranges. There are 5 possible range types
             allowed by this function; daily, weekly, monthly, quaterly and 
             yearly. For each range type, the function returns a start date
             which is a datetime value at midnight, and an end date which is
             a datetime value at 23:59:59.997.  

Params:
Name           | Datatype  | Description            
----------------------------------------------------------------------------
@i_StartDt      datetime    The starting date for the desired set of ranges 
@i_EndDt        datetime    The final date for the desired set of ranges
@i_RangeTp      char(1)     Character that determines the type or range. 
                            Possible values are D (daily), M (Monthly) W (Weekly)
                            Q (Quaterly) and Y (Yearly).


$ResultSet:
----------------------------------------------------------------------------
StartDt         datetime    The first date in the range, time at midnight
EndDt           datetime    The last date in the range, time at 23:59:59.997    


$Revisions:
  Ini |    Date     | Description 
---------------------------------
$End
*/
-- =cut

return (
    with RangeTotal (StartVal, EndVal)
    as
    (
        select  0,
                case
                    when  @i_StartDt <= @i_EndDt then datediff(dd, @i_StartDt, @i_EndDt)
                    else datediff(dd, @i_EndDt, @i_StartDt)
                end
    ), 
    BaseNum (N) as (
		select 1 union all
		 select 1 union all
		 select 1 union all
		 select 1 union all
		 select 1 union all
		 select 1 union all
		 select 1 union all
		 select 1 union all
		 select 1 union all
		 select 1
    ),
    L1 (N) as (
		select	bn1.N
		from BaseNum bn1
			cross join BaseNum bn2
    ),
    L2 (N) as (
		select	a1.N
		from L1 a1
			cross join L1 a2
    ),
    L3 (N) as (
		select top ((select top 1 r.EndVal - r.StartVal from RangeTotal r) + 1) a1.N
		from L2 a1
		    cross join RangeTotal r 
			cross join L2 a2
    ),
    Tally (N) as (
		select	row_number()over (order by a1.N)
		from L3 a1
    ),
    Numbers (NumberVal) as
     (
        select	(N - 1) + r.StartVal as N
        from Tally
            cross join RangeTotal r
    ),
    DatesTable (Date_Val, SoW, SoM, SoQ, SoY)
    as
    (
        select  dateadd(dd, NumberVal, @i_StartDt),
                case when datepart(dw, dateadd(dd, NumberVal, @i_StartDt)) = 1 then 1 else 0 end,
                case when datepart(dd, dateadd(dd, NumberVal, @i_StartDt)) = 1 then 1 else 0 end,
                case when 
                        datepart(dd, dateadd(dd, NumberVal, @i_StartDt)) = 1 
                        and
                        datepart(mm, dateadd(dd, NumberVal, @i_StartDt)) in (1, 4, 7, 10) then 1 else 0 end,
                case when datepart(dy, dateadd(dd, NumberVal, @i_StartDt)) = 1 then 1 else 0 end                        
        from Numbers
    )
    --select * -- Date_Val
    select  Date_Val as StartDt,
            case @i_RangeTp
                when 'D' then dateadd(ms, -3, dateadd(dd, 1, Date_Val)) 
                when 'M' then dateadd(ms, -3, dateadd(mm, 1, Date_Val)) 
                when 'W' then dateadd(ms, -3, dateadd(dd, 7, Date_Val))  
                when 'Y' then dateadd(ms, -3, dateadd(yy, 1, Date_Val))  
                when 'Q' then dateadd(ms, -3, dateadd(mm, 3, Date_Val))
            end as EndDt
    from DatesTable
    where case
            when @i_RangeTp = 'D' then 1
            when @i_RangeTp = 'M' then SoM
            when @i_RangeTp = 'W' then SoW
            when @i_RangeTp = 'Y' then SoY
            when @i_RangeTp = 'Q' then SoQ 
          end = 1
    );
go

if not exists (
    select 1 
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_Tbl_Date_Ranges'
      and ROUTINE_TYPE = 'Function'
        ) begin 

    print 'Function dbo.f_Tbl_Date_Ranges does not exist, create failed'

end else begin

    declare @Description    varchar(7500);

    set @Description =  'Returns a table of date ranges. There are 5 possible range types ' +
                        'allowed by this function; daily, weekly, monthly, quaterly and ' + 
                        'yearly. For each range type, the function returns a start date ' +
                        'which is a datetime value at midnight, and an end date which is ' +
                        'a datetime value at 23:59:59.997.';

    exec sys.sp_addextendedproperty
            @name       = N'MS_Description', 
            @value      = N'Returns a table of date ranges',
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'FUNCTION',
            @level1name = N'f_Tbl_Date_Ranges'; 

    exec sys.sp_addextendedproperty
            @name       = N'SVN Revision',
            @value      = N'$Rev: 253 $' ,
            @level0type = N'SCHEMA',
            @level0name = N'dbo',
            @level1type = N'FUNCTION',
            @level1name = 'f_Tbl_Date_Ranges';

end;

go    

/*

-- Test

select * from dbo.f_Tbl_Date_Ranges ('2012-01-01', '2012-07-31', 'Q')

*/