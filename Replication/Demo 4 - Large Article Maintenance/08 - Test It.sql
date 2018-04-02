use AdventureWorks2014;
go

select * from AdventureWorks2014.Sales.OnlineOrderSourceCode;

select * from AdventureWorks2014Replica.Sales.OnlineOrderSourceCode;




select top 10 OnlineOrderSourceCodeId, * from AdventureWorks2014.Sales.SalesOrderHeader;

select top 10 OnlineOrderSourceCodeId, * from AdventureWorks2014Replica.Sales.SalesOrderHeader;

