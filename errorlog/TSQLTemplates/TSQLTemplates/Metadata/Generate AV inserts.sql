set nocount on

declare @CrLf   char(2) = char(13) + char(10)

select  'insert into <Schema_Nme, varchar, >.<Tbl_Nme, varchar, >  (' + @CrLf +
        space(8) + '<Tbl_Nme, varchar, >_Cd,' + @CrLf +
        space(8) + '<Tbl_Nme, varchar, >_Display_Cd,' + @CrLf +
        space(8) + '<Tbl_Nme, varchar, >_Dsc' + @CrLf +
        ')' + @CrLf +
        'values'
  
select  space(8) + '(' + @CrLf + 
        space(8) + '''' + <Tbl_Nme, varchar, >_Cd + ''', ''' +   <Tbl_Nme, varchar, >_Display_Cd + ''',' + @CrLf +
        space(8) + '''' + <Tbl_Nme, varchar, >_Dsc + '''' + @CrLf +
        space(8) + '),'
from <Schema_Nme, varchar, >.<Tbl_Nme, varchar, >
where <Tbl_Nme, varchar, >_Id > 0
order by <Tbl_Nme, varchar, >_Id