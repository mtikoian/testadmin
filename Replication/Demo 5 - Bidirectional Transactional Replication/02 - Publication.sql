use AdventureWorks2014;
go
-- Page 318 - Pro SQL Server 2005 Replication  (there is a 2008 version available on Amazon.) 



exec sp_addpublication
     @publication = 'SpecialOffer', 
     @description = 'SpecialOffer Transactional Publication - Push, Updatable.', 
     @sync_method = 'concurrent', 
     @retention = 0,
     @allow_push = 'true',
     @allow_pull = 'true',
     @enabled_for_internet = 'false', 
     @snapshot_in_defaultfolder = 'true', 
     @compress_snapshot = 'false', 
     @allow_subscription_copy = 'false',
     @add_to_active_directory = 'false',
     @repl_freq = 'continuous',
     @status = 'active',
     @independent_agent = 'true', 
     --------------------------------------------------------------------------------------------------
     @immediate_sync = 'true',           -- false in one directional
     @allow_sync_tran = 'true',          -- false in one directional
     @autogen_sync_procs = 'true',       -- false in one directional
     @allow_queued_tran = 'true',        -- new parameter (defaulteded in one directional?)
     @allow_dts = 'false', 
     @conflict_policy = 'pub wins',      -- All below are new.
     @centralized_conflicts = 'true',
     @conflict_retention = 14,
     @queue_type = 'sql',
     --------------------------------------------------------------------------------------------------  
     @replicate_ddl = 1,
     @allow_initialize_from_backup = 'false',
     @enabled_for_p2p = 'false',
     @enabled_for_het_sub = 'false';
go

exec sp_addpublication_snapshot
     @publication = 'SpecialOffer',
     @frequency_type = 1,
     @publisher_security_mode = 1;
go

-- Again - cut and paste from script 5.  I just changed the publication and identity range management.

sp_addarticle
    @publication = 'SpecialOffer',                         -- Change from Demo 1
    @article = 'Sales.SpecialOffer',
    @source_owner = 'Sales',
    @source_object = 'SpecialOffer',
    @type = 'logbased',
    @description = '',
    @creation_script = '',
    @pre_creation_cmd = 'drop',
    @schema_option = 0x00000000000000F3,
    @identityrangemanagementoption = 'manual',             -- Change from Demo 1
    @destination_table = 'SpecialOffer',
    @destination_owner = 'Sales',
    @status = 16,
    @vertical_partition = 'false';
go


