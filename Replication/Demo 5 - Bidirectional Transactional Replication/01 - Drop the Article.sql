use AdventureWorks2014;
go 

-- sp_helparticle 'AdventureWorks2014', 'Sales.SpecialOffer';


-- In this scenario - I want to establish two way on a table in an existing publication (AdventureWorks2014).  I must remove the article from 
-- that publication.

begin try

    exec sp_dropsubscription 
        @publication = 'AdventureWorks2014', 
        @article = 'Sales.SpecialOffer', 
        @subscriber = 'all', 
        @destination_db = 'all';


    exec sp_droparticle 
        @publication = 'AdventureWorks2014', 
        @article = 'Sales.SpecialOffer', 
        @force_invalidate_snapshot = 1;

end try

begin catch

    throw;

end catch


