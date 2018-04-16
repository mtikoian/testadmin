-- start first code execution
use Deadlocks;
go

begin tran

update Deadlock_Test
   set col = 'B'
 where ID = 2;

-- stop first code execution
-- Go back to script 1.
 
update Deadlock_Test
   set col = 'B'
 where ID = 1; 
 
-- Within a few seconds of starting the above statement you will get a deadlock. 
--Lookup Error - SQL Server Database Error: Transaction (Process ID 54) was deadlocked on lock resources with 
--another process and has been chosen as the deadlock victim. Rerun the transaction.