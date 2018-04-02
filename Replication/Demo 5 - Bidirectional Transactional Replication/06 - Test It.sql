use AdventureWorks2014;
go 

select msrepl_tran_version, * from AdventureWorks2014.Sales.SpecialOffer
where SpecialOfferId = 1;
go

select msrepl_tran_version, * from AdventureWorks2014Replica.Sales.SpecialOffer
where SpecialOfferId = 1;
go



update AdventureWorks2014.Sales.SpecialOffer
    set Description = 'I was Updated in AdventureWorks2014'
where SpecialOfferId = 1;




update AdventureWorks2014Replica.Sales.SpecialOffer
    set Description = 'I was Updated in AdventureWorks2014Replica'
where SpecialOfferId = 1;
go


--  select * from AdventureWorks2014.Sales.[conflict_SpecialOffer_Sales.SpecialOffer]
--  Notice the period in the table name.  You must use the brackets.