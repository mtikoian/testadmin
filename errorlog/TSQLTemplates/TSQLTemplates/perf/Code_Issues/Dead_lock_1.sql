use master;
if exists (select 1 from sys.databases where name = 'Deadlocks') begin
  alter database Deadlocks set single_user with rollback immediate;
  drop database Deadlocks;
end

create database Deadlocks;

go

use Deadlocks;
go

create table dbo.Deadlock_Test (
  ID int primary key,
  col char(1) default 'A'
);

with Numbers as
(
  select 1 as n
  union all
  select n+1 as n
    from Numbers
   where n <= 100
)
insert dbo.Deadlock_Test (ID)
select n from Numbers;
go

begin tran

update Deadlock_Test
   set col = 'B'
 where ID = 1;
 
-- Stop execution here and execute the first part of script 2.
 
update Deadlock_Test
   set col = 'B'
 where ID = 2;
 
-- After starting execution here you should see that the script does not finish
-- Go back to script 2 and execute the second statement.
 
commit;
  
