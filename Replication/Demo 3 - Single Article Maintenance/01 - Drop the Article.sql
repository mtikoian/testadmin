use AdventureWorks2014;
go 

exec sp_dropsubscription 
    @publication = 'AdventureWorks2014', 
    @article = 'HumanResources.Department', 
    @subscriber = 'all', 
    @destination_db = 'all';
go

exec sp_droparticle 
    @publication = 'AdventureWorks2014', 
    @article = 'HumanResources.Department', 
    @force_invalidate_snapshot = 1;
go

--   sp_helparticle 'AdventureWorks2014', 'HumanResources.Department';
--
