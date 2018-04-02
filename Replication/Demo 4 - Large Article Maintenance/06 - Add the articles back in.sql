use AdventureWorks2014;
go

-- KICK THE SNAP SHOT AGENT - after.

-- MAGIC at line 65


-- Note - Here I am adding a new article into an existing publication.  Well - actually both of these do that.  :)  But this article
-- NEVER existed in the publication before.

sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.OnlineOrderSourceCode',
    @source_owner = 'Sales',
    @source_object = 'OnlineOrderSourceCode',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'none',  -- must be manual for InitializeFromBackup
    @destination_table = 'OnlineOrderSourceCode',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_OnlineOrderSourceCode',
    @del_cmd = 'CALL Sales.zRepl_del_OnlineOrderSourceCode',
    @upd_cmd = 'MCALL Sales.zRepl_upd_OnlineOrderSourceCode';
go


-- Note - the below sp_addarticle is cut/paste from script 5.

sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'Sales.SalesOrderHeader',
    @source_owner = 'Sales',
    @source_object = 'SalesOrderHeader',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000001C00F3,      -- schema options for keeping the article on the partitioned file system
    @identityrangemanagementoption = 'none',  -- must be manual for InitializeFromBackup
    @destination_table = 'SalesOrderHeader',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL Sales.zRepl_ins_SalesOrderHeader',
    @del_cmd = 'CALL Sales.zRepl_del_SalesOrderHeader',
    @upd_cmd = 'MCALL Sales.zRepl_upd_SalesOrderHeader';
go


-- MAGIC HERE!!!  What I am doing is I'm going to resubscribe the Sales.SalesOrderHeader with sync_type replication support only.
-- Thus - we avoid the snapshot on that 1 article.  Then - I am going to resubscribe all.  I have introduced one other 
-- article.  So - I expect 1 snap shot (for Sales.OnlineOrderSourceCode) to be generated.
  
sp_addsubscription
    @publication = 'AdventureWorks2014', 
    @article = 'Sales.SalesOrderHeader',                            
    @subscriber = 'jflannery0753\e1dev', 
    @destination_db = 'AdventureWorks2014Replica', 
    @sync_type = 'replication support only',                   
    @update_mode = 'read only', 
    @offloadagent = 0, 
    @dts_package_location = 'distributor';
go

sp_addsubscription
    @publication = 'AdventureWorks2014', 
    @article = 'all',                            
    @subscriber = 'jflannery0753\e1dev', 
    @destination_db = 'AdventureWorks2014Replica', 
    @sync_type = 'automatic',                    
    @update_mode = 'read only', 
    @offloadagent = 0, 
    @dts_package_location = 'distributor';
go
