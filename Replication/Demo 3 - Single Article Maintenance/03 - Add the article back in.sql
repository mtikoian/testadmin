use AdventureWorks2014;
go

--  KICK THE SNAPSHOT AGENT After!!!!

-- sp_helparticle 'AdventureWorks2014', 'HumanResources.Department';

-- select * from AdventureWorks2014Replica.HumanResources.Department;

-- Note - the below sp_addarticle is cut/paste from script 5.

sp_addarticle
    @publication = 'AdventureWorks2014',
    @article = 'HumanResources.Department',
    @source_owner = 'HumanResources',
    @source_object = 'Department',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'none',  -- must be manual for InitializeFromBackup
    @destination_table = 'Department',
    @destination_owner = 'HumanResources',
    @status = 16,
    @vertical_partition = 'false',
    @ins_cmd = 'CALL HumanResources.zRepl_ins_Department',
    @del_cmd = 'CALL HumanResources.zRepl_del_Department',
    @upd_cmd = 'MCALL HumanResources.zRepl_upd_Department';
go    

-- Even though I say @article = 'all' - there is only 1 article the subscriber is not subscribed to.  Only 1 article subscription will be created.
-- This script can be used unaltered if I changed 1, 5, 24 articles.  It only needs to be run once. 
  
exec sp_addsubscription
    @publication = 'AdventureWorks2014', 
    --------------------------------------------------------------------------------------------------
    @article = 'all',
    --------------------------------------------------------------------------------------------------                            
    @subscriber = 'jflannery0753\e1dev', 
    @destination_db = 'AdventureWorks2014Replica', 
    @sync_type = 'automatic',                    --  sync type is automatic.  A snap shot will be taken.
    @update_mode = 'read only', 
    @offloadagent = 0, 
    @dts_package_location = 'distributor';


--  KICK THE SNAPSHOT AGENT!!!

