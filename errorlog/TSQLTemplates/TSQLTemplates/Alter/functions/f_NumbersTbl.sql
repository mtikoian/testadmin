

if exists (
    select 1 
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_NumbersTbl'
      and ROUTINE_TYPE = 'Function'
        ) begin
    drop function dbo.f_NumbersTbl
end
go

 set ansi_nulls on
go
 set quoted_identifier on
go

create function dbo.f_NumbersTbl(
     @pStartValue	bigint = 1,
     @pEndValue		bigint = 1000000,
     @pIncrement	bigint = 1
 )
 returns table
 as
 /**
 
 Filename: f_NumbersTbl.sql
 Author: Stephen R. McLarnon Sr.
 
 Object: f_NumbersTbl
 ObjectType: Table valued function

$Author: pobrien $
$Date: 2013-08-19 13:58:19 -0400 (Mon, 19 Aug 2013) $
$Rev: 394 $
$URL: http://seisubvapp01/TSU_Utilities/SQL_Library/Functions/f_NumbersTbl.sql $
 
 Description:   Returns a table of integers. The user supplies the start
                value, the ending value and the increment. This is a very fast method
                of producing a table of integers.
 
 Param1: @pStartValue - the starting integer
 Param2: @pEndValue - The highest number to return
 Param3: @pIncrement - The value by which we will increment the table.
 
 OutputType: table
 
 Output1: Number
  
 Revisions:
  Ini |    Date     | Description 
 ---------------------------------
 
 */
 return (
     with BaseNum (N) as (
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
			cross join BaseNum bn2          -- <== This cross join yields 100 rows. 
     ),
     L2 (N) as (
		select	a1.N
		from L1 a1
			cross join L1 a2                -- <== This cross join yields 10000 rows
     ),
     L3 (N) as (
		select top ((abs(case when @pStartValue < @pEndValue
                          then @pEndValue
                          else @pStartValue
                      end -
                      case when @pStartValue < @pEndValue
                          then @pStartValue
                          else @pEndValue
                      end))/abs(@pIncrement)+ 1)
				a1.N
		from L2 a1
			cross join L2 a2
     ),
     Tally (N) as (
		select	row_number()over (order by a1.N)
		from L3 a1
     )
     select	((N - 1) * @pIncrement) + @pStartValue as N
     from Tally
 ); 

go
if exists (
    select 1 
    from information_schema.ROUTINES 
    where SPECIFIC_SCHEMA = 'dbo'
      and ROUTINE_NAME = 'f_NumbersTbl'
      and ROUTINE_TYPE = 'Function'
        ) begin

        declare @Description    varchar(7500);

        set @Description =  'Returns a table of integers. The user supplies the start ' +
                            'value, the ending value and the increment. This is a very fast method ' +
                            'of producing a table of integers.';

        exec sys.sp_addextendedproperty
                @name       = N'MS_Description',
                @value      = @Description,
                @level0type = N'SCHEMA',
                @level0name = N'dbo',
                @level1type = N'FUNCTION',
                @level1name = N'f_NumbersTbl'

        exec sys.sp_addextendedproperty
                @name       = N'SVN Revision',
                @value      = N'$Rev: 394 $' ,
                @level0type = N'SCHEMA',
                @level0name = N'dbo',
                @level1type = N'FUNCTION',
                @level1name = N'f_NumbersTbl';
    
end else begin
    print 'Function dbo.f_NumbersTbl does not exist, create failed'
end
go

/*
--Test Execution

select *
from dbo.f_NumbersTbl(1, 10000, 1)     
     
*/