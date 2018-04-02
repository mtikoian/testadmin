use distribution;
go

sp_adddistpublisher 
    @publisher = 'jflannery0753\e1dev',
    @distribution_db = 'distribution', 
    @security_mode = 1,                                    -- 0 = SQL Authentication - which require the login and password
    --@login = 'Replication',
    --@password = 'VaVeF3E7',                              -- http://www.pctools.com/guides/password
    @trusted = 'false',                                    -- depricated -= must be false 
    @thirdparty_flag = 0,                                  -- 0 = SQL Serevr, 1 = other.
    @publisher_type = 'MSSQLSERVER';                       -- or "ORACLE".  Bahhhh.
go
