use master;
go

backup database AdventureWorks2014
    to disk = 'c:\System00\backup\AdventureWorks2014Replica.bak'
    with init, format, compression, checksum, retaindays = 90;
go    
    
restore verifyonly 
    from disk = 'c:\System00\backup\AdventureWorks2014Replica.bak'
    with checksum, continue_after_error;


use AdventureWorks2014;
go

select SickLeaveHours, * from HumanResources.Employee where BusinessEntityId = 1;
go

update HumanResources.Employee
   set SickLeaveHours = 77
where BusinessEntityId = 1;     
go

select SickLeaveHours, * from HumanResources.Employee where BusinessEntityId = 1;
go

