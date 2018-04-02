use AdventureWorks2014;
go 

begin try

    exec sp_dropsubscription 
        @publication = 'AdventureWorks2014', 
        @article = 'Sales.SalesOrderHeader', 
        @subscriber = 'all', 
        @destination_db = 'all';


    exec sp_droparticle 
        @publication = 'AdventureWorks2014', 
        @article = 'Sales.SalesOrderHeader', 
        @force_invalidate_snapshot = 1;

end try

begin catch

    throw;

end catch

-- sp_helparticle 'AdventureWorks2014', 'Sales.SalesOrderHeader';

