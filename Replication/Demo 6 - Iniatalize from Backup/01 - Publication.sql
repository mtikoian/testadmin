use AdventureWorks2014;
go 



begin try;



    exec sp_replicationdboption 
        @dbname = 'AdventureWorks2014', 
        @optname = 'publish', 
        @value = 'true';

 

    exec sp_addpublication 
        @publication = 'AdventureWorks2014',
        @sync_method = 'concurrent',       -- Native mode bulk copy with out table lock.  Other values support non SQL subscribers.
        @repl_freq = 'continuous',         -- or "snapshot".  Produce a new snapshot daily.  (Or on replication interval.)    
        @description = 'Transactional publication of AdventureWorks2014 database from Publisher jflannery0753\e1dev.',
        @status = 'active',                -- The subscribers will get data immediately on subscription
        @independent_agent = 'true ',      -- 
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        @immediate_sync = 'true',          -- IMPORTANT - If set to true - a complete snapshot will be generated every time the snapshot agent starts. 
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        @enabled_for_internet = 'false',   -- the default.  If true - ftp is used for all replication traffic.
        @allow_push = 'true',              -- allow subscriptions that are based on the publisher.  (By based - where the agent job runs.)
        @allow_pull = 'false',             -- the default is true.
        @allow_anonymous = 'false',        -- if true - immediate_sync must also be true.  Your security folks will not be happy with this one.
        @allow_sync_tran = 'false',        -- Allow immediate-updating subscriptions are allowed.  CAUTION:  If true - transactions will not commit until replication is complete.
        @autogen_sync_procs = 'true',      -- Always create the stored procedures.      
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        @retention = 336,                  -- the default.  The time (in hours) that data is maintained in the distribution database.  336 = 14 days.
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        @allow_queued_tran= 'false',       -- Set to true if you are doing two way replication.
        @compress_snapshot = 'false',      -- This one sounds good - but read the doc.  I especially love "... snapshot files > 2GB cannot be compressed..."  
        @queue_type = 'sql',
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        @allow_initialize_from_backup = 'true',
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------        
        @replicate_ddl = 1,                -- True - the default.  Alter commands will be replicated.  But sp_droparticle - reorganization - sp_addarticle the better choice.
        @enabled_for_p2p = 'false',        -- the default.  this is for two way replication.
        @enabled_for_het_sub = 'false',    -- Must be ture if doing non SQL Server subscribers.
        @allow_partition_switch = 'false', -- The default.  You need system time any way to drop partitions.  Sp sp_drop article, do your thing, sp_addarticle.
        @replicate_partition_switch = 'false';




    exec sp_addpublication_snapshot 
        @publication = 'AdventureWorks2014',
        @frequency_type = 1,               -- Run Once.  Default is 4 - Daily.  I do not want to produce snapshots outside of my control.
        @publisher_security_mode = 1;      -- Use Windows authentication.


end try

begin catch;

    throw;

end catch;

