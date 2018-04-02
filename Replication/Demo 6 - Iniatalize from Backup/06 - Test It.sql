use AdventureWorks2014
go

-- Test 1:

select SickLeaveHours, * from AdventureWorks2014.HumanResources.Employee where BusinessEntityId = 1;
go

select SickLeaveHours, * from AdventureWorks2014Replica.HumanResources.Employee where BusinessEntityId = 1;
go


update HumanResources.Employee
   set SickLeaveHours = 100
where BusinessEntityId = 1;
    





-- Test 2:

select max(BusinessEntityId) from Person.BusinessEntity
go

select max(BusinessEntityId) from AdventureWorks2014Replica.Person.BusinessEntity
go

insert into Person.BusinessEntity (rowguid, ModifiedDate) 
    values (NewId(), GetDate());
go

select * from Person.BusinessEntity where BusinessEntityId = 20779;
go

select * from AdventureWorks2014Replica.Person.BusinessEntity where BusinessEntityId = 20779;
go






-- Test 3:

select * from Person.PersonPhone where BusinessEntityId = 20776;  

select * from AdventureWorks2014Replica.Person.PersonPhone where BusinessEntityId = 20776;  


delete from Person.PersonPhone  where BusinessEntityId = 20776;







