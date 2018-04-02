use AdventureWorks2014
go

-- Test 1:

select SickLeaveHours, * from AdventureWorks2014.HumanResources.Employee where BusinessEntityId = 1;
go

select SickLeaveHours, * from AdventureWorks2014Replica.HumanResources.Employee where BusinessEntityId = 1;
go


update AdventureWorks2014.HumanResources.Employee
   set SickLeaveHours = 120
where BusinessEntityId = 1;
    





-- Test 2:

select max(BusinessEntityId) from AdventureWorks2014.Person.BusinessEntity
go

select max(BusinessEntityId) from AdventureWorks2014Replica.Person.BusinessEntity
go

insert into AdventureWorks2014.Person.BusinessEntity (rowguid, ModifiedDate) 
    values (NewId(), GetDate());
go

select * from AdventureWorks2014.Person.BusinessEntity where BusinessEntityId = 20778;
go

select * from AdventureWorks2014Replica.Person.BusinessEntity where BusinessEntityId = 20778;
go






-- Test 3:

select * from AdventureWorks2014.Person.PersonPhone where BusinessEntityId = 20777;  

select * from AdventureWorks2014Replica.Person.PersonPhone where BusinessEntityId = 20777;  


delete from AdventureWorks2014.Person.PersonPhone  where BusinessEntityId = 20777;







