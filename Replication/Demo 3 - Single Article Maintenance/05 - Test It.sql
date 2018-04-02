use AdventureWorks2014;
go 

select * from AdventureWorks2014.HumanResources.Department;
go

select * from AdventureWorks2014Replica.HumanResources.Department;
go


update AdventureWorks2014.HumanResources.Department
    set IncludeInLayoffs = 0 
where Name = 'Human Resources';          -- Those S.O.B.s

