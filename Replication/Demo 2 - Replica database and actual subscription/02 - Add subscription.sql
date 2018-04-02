use AdventureWorks2014;
go

-- Kick the snap shot agent after doing this.

sp_addsubscription
    @publication = 'AdventureWorks2014', 
    @article = 'all', 
    @subscriber = 'jflannery0753\e1dev', 
    @destination_db = 'AdventureWorks2014Replica', 
    @subscription_type = 'Push', 
    @sync_type = 'automatic', 
    @status = 'subscribed',            -- This subscription will need to be initialized.
    @update_mode = 'read only', 
    @subscriber_type = 0;



