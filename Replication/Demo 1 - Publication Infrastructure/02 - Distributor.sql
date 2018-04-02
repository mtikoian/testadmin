use master;      -- 9 seconds
go


-- exec sp_dropdistributiondb @database= 'distribution'; exec sp_dropdistributor; 

sp_adddistributor 
    @distributor = 'jflannery0753\e1dev',                  -- My convention is distributer name = instance name.  Does not work if multiple distributors on an instance. 
    @heartbeat_interval = 10,                              -- Minutes - agent must log at least a status message every n minutes.  (Default 10) 
    @password = '';                                        -- Reccomendation - always use trusted authentication.  Implecation - the account SQLAgent runs under needs access to targets
go

sp_adddistributiondb 
    @database = 'distribution', 
    @data_folder = 'c:\Data00\data', 
    @data_file = 'distribution.mdf', 
    @data_file_size = 500,                                 -- int - size in MB 
    @log_folder = 'c:\Log00\TransactionLog', 
    @log_file = 'distribution.ldf', 
    @log_file_size = 250,                                  -- int - size in MB
    ---------------------------------------------------------------------------------------------------------------------------------------
    @min_distretention = 0,                                -- Hours - default 0.  Minimum number of hours commands are retained in the distribution database.
    @max_distretention = 72,                               -- Hours - default 72.  Maximum number of hours commands are retained in the distribution database.
    ---------------------------------------------------------------------------------------------------------------------------------------
    @history_retention = 48,                               -- Hours - default 48.
    @security_mode = 1;                                    -- int - default 1.  0 = use SQL Authentication to connect - 1 = use Windows Integrated Security
    -- @login = we are using windows
    -- @passowrd = we are using windows

go


