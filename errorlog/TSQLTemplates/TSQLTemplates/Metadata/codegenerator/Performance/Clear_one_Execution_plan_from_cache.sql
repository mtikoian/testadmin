

declare @planHandle varbinary(64);
declare @CreateProcStmnt varchar(100);

set @CreateProcStmnt = 'CREATE PROCEDURE CodeRev.Add_Code_Review%';

SELECT  @planHandle = cp.plan_handle
FROM    sys.dm_exec_cached_plans AS cp
        CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
WHERE   st.[text] LIKE @CreateProcStmnt;

if (@planHandle is not null)
begin
   print 'Freeing plan cache ' + cast(@planHandle as varchar(100));
   DBCC FREEPROCCACHE(@planHandle);
end
else
begin
   print 'Unable to find procedure';
end;
               