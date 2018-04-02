use AdventureWorks2014Replica;
go

-- KICK THE SNAP SHOT AGENT - after.  Remember - it is a new publication.
-- remember to replication monitor in main window wehn practicing.

-- The below covers the price of admission.  :)
-- You do not need to execute sp_subscription_cleanup the first time you are setting up the subscription.  BUT - if you take down the publication 
-- for what ever reason (SAN reorg, SQL Upgrade) and want to reestablish it - you will not be able to until you run this.  And it is buried DEEP
-- in books online.  Guess how I discovered this.  :(
-- Since it does not hurt to run it the first time - I include it here:

exec sp_subscription_cleanup 
    @publisher = 'jflannery0753\e1dev',
    @publisher_db =  'AdventureWorks2014',
    @publication = 'SpecialOffer';
go

exec sp_link_publication 
     @publisher = 'jflannery0753\e1dev', 
     @publisher_db = 'AdventureWorks2014', 
     @publication = 'AdventureWorks2014', 
     @distributor = 'jflannery0753\e1dev', 
     @security_mode = 2;
go

