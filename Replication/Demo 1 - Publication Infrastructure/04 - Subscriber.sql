use distribution;
go

sp_addsubscriber 
    @subscriber = 'jflannery0753\e1dev',
    @type = 0,                         -- SQL Server.  1 = odbc, 2 = Jet, 3 = OLE DB
    @security_mode = 1,                -- 0 = SQL Authentication - which require the login and password
    --@login = 'Replication',
    --@password = 'VaVeF3E7',                              -- https://identitysafe.norton.com/password-generator
    @description = 'Transactional Replication Subscriber',
    @frequency_type = 64;              -- the default - auto start the agent; continuous replication.  You could use daily (2) to batch all online changes overnight.


-- Note:  there are several @frequency_xxxxx parameters that are documented in books online and available if you are using a frequency type other then 64.
-- Also - there are SEVERAL depricated parameters on this sproc.
go

