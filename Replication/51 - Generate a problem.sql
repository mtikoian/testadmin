use AdventureWorks2014;
go

select * from AdventureWorks2014.HumanResources.Department where DepartmentId = 9;
go

select * from AdventureWorks2014Replica.HumanResources.Department where DepartmentId = 9;
go

-- This is bad.  Delete from the subscriber....  (Note - as is this would not work on publisher.  Referential Integrity.) 

delete from AdventureWorks2014Replica.HumanResources.Department where DepartmentId = 9;
go

-- and then update that row.
update AdventureWorks2014.HumanResources.Department 
   set IncludeInLayoffs = 1 
where DepartmentId = 9;



sp_helparticle AdventureWorks2014, 'HumanResources.Department'


use distribution;
go

sp_help sp_browsereplcmds;
go

sp_browsereplcmds
    @xact_seqno_start =  '0x0000004200000D48000300000000';

-- By looking at the failing command - I can tell it is the Department table that has experienced the error.  Being a small table - I would immediately drop and 
-- recreate the article.

