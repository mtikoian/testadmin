use AdventureWorks2014;
go


sp_addsubscription
    @publication = 'AdventureWorks2014', 
    @article = 'all', 
    @subscriber = 'jflannery0753\e1dev', 
    @destination_db = 'AdventureWorks2014Replica', 
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    @sync_type = 'initialize with backup', 
    ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    @status = 'active',
    @update_mode = 'read only', 
    @offloadagent = 0, 
    @dts_package_location = 'distributor',
    @backupdevicetype = 'disk',
    @backupdevicename = 'c:\System00\backup\AdventureWorks2014Replica.bak';




