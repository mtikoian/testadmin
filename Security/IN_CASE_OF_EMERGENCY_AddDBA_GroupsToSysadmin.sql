EXECUTE AS LOGIN = 'Domain\user';
/*
5.  Add DBA groups to sysadmin server role
*/
SET NOCOUNT ON;
GO

IF ((SELECT LEFT(CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(10)), 2)) > 10)
BEGIN
    DECLARE commands2012 CURSOR FOR
    SELECT 'ALTER SERVER ROLE sysadmin ADD MEMBER ' + QUOTENAME(p.name, '[]') + ';'
      FROM sys.server_principals p
      JOIN sys.syslogins s
        ON p.sid = s.sid
     WHERE p.type_desc = 'WINDOWS_GROUP'
       -- Logins that are not process logins
       AND p.name NOT LIKE '##%'
       -- Logins that are sysadmins
       AND s.sysadmin  = 1
       AND p.name LIKE '%DBA%';

    DECLARE @cmd2012 VARCHAR(MAX);
    OPEN commands2012;
    FETCH NEXT FROM commands2012
    INTO @cmd2012;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC (@cmd2012);
        PRINT (@cmd2012);
        FETCH NEXT FROM commands2012
        INTO @cmd2012;
    END;

    CLOSE commands2012;
    DEALLOCATE commands2012;
END;
ELSE
BEGIN
    DECLARE commands CURSOR FOR
    SELECT 'EXEC sp_addsrvrolemember ' + QUOTENAME(p.name, CHAR(39)) + ', ''sysadmin'''
      FROM sys.server_principals p
      JOIN sys.syslogins s
        ON p.sid = s.sid
     WHERE p.type_desc = 'WINDOWS_GROUP'
       -- Logins that are not process logins
       AND p.name NOT LIKE '##%'
       -- Logins that are not sysadmins
       AND s.sysadmin  = 0
       AND p.name LIKE '%DBA%';

    DECLARE @cmd VARCHAR(MAX);
    OPEN commands;
    FETCH NEXT FROM commands
    INTO @cmd;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC (@cmd);
        PRINT (@cmd);
        FETCH NEXT FROM commands
        INTO @cmd;
    END;

    CLOSE commands;
    DEALLOCATE commands;
END;
GO

REVERT;
