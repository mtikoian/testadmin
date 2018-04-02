use AdventureWorks2014;
go 

sp_addsubscription                   
     @publication = 'SpecialOffer', 
     @subscriber = 'jflannery0753\e1dev', 
     @destination_db = 'AdventureWorks2014Replica', 
     @subscription_type = 'Push', 
     @sync_type = 'automatic', 
     @article = 'all', 
     @update_mode = 'queued failover',   -- MAGIC:  Indicates this is a two way.  By Queued - no DTC.  There may be conflicts.
     @subscriber_type = 0;
go


--sp_dropsubscription                       -- This will take 
--     @publication = 'SpecialOffer', 
--     @subscriber = 'jflannery0753\e1dev', 
--     @destination_db = 'AdventureWorks2014Replica', 
--     @article = 'all'
--go
