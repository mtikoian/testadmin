

-- If the procedure does not exist, create it as a placeholder stub.
if not exists
     (select 1
      from   information_schema.routines
      where  specific_schema = N'dbo' and specific_name = N'This_is_a_Test')
  begin
    
    declare @stmnt nvarchar(200);
    set @stmnt = N'create procedure dbo.This_is_a_Test as raiserror(''This is a stub routine and should not exist'',16,1)';
    exec sp_executesql @stmnt;

    if (@@error <> 0)
      begin
        print 'ERROR: Unable to create stub procedure dbo.This_is_a_Test!';
        raiserror ('ERROR: Unable to create stub procedure dbo.This_is_a_Test!', 16, 1);
      end;
  end;
go
-- test 
exec dbo.This_is_a_Test
go
-- Alter the procedures
alter procedure dbo.This_is_a_Test
as
select top 10 * from sys.tables;
go

-- test
exec dbo.This_is_a_Test

grant execute on dbo.This_is_a_Test to JEstadt;

grant execute on dbo.This_is_a_Test to JEstadt;






      