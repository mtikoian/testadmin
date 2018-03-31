SET nocount ON ;

DECLARE @login_name SYSNAME = 'WAGGERTAIL\IWantToRead';
DECLARE @perms NVARCHAR(MAX)
DECLARE @debug bit
DECLARE @error_message NVARCHAR(4000);

SET @debug=0

/*********************
* Master perms
*********************/
USE [master] ;

--Create Login if needed
IF ( SELECT COUNT(*)
 FROM   sys.server_principals
 WHERE  name = @login_name
 ) = 0
 BEGIN
 PRINT '--Creating Login ' + QUOTENAME(@login_name) + ' on ' + @@SERVERNAME
 SET @perms = 'CREATE LOGIN ' + QUOTENAME(@login_name) + ' FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english] ;'

 IF @debug=1 PRINT @PERMS
 ELSE
 begin try
 exec sp_executesql @perms ;
 end try
 begin catch
 SELECT @error_message = ERROR_MESSAGE();
 RAISERROR (@error_message, 16, 2 );
 end catch
 END
ELSE
 PRINT '--Login already exists on ' + @@SERVERNAME

--If the login still doesn't exist, just return, something's wrong...
IF ( SELECT COUNT(*)
 FROM   sys.server_principals
 WHERE  name = @login_name
 ) = 0
BEGIN
 SELECT @error_message = 'We didn''t create our login... what''s going wrong??'
 RAISERROR (@error_message, 16, 2 );
 RETURN;
END

--Grant view server state if needed
IF ( SELECT COUNT(*)
 FROM   sys.server_principals users
 JOIN sys.server_permissions prm ON users.principal_id = prm.grantee_principal_id
 WHERE  users.name = @login_name
 AND permission_name = 'VIEW SERVER STATE'
 ) = 0
 BEGIN
 PRINT '--Granting Server State on ' + @@SERVERNAME + ' TO ' + QUOTENAME(@login_name);
 SET @perms = 'GRANT VIEW SERVER STATE TO ' + QUOTENAME(@login_name);

 IF @debug=1 PRINT @PERMS
 ELSE
 begin try
 exec sp_executesql @perms ;
 end try
 begin catch
 SELECT @error_message = ERROR_MESSAGE();
 RAISERROR (@error_message, 16, 2 );
 end catch
 END
ELSE
 PRINT '--View Server State already granted on ' + @@SERVERNAME

/*********************
* MSDB perms
*********************/
USE [msdb] ;

-- Create user if needed
IF ( SELECT COUNT(*)
 FROM   sys.database_principals users
 WHERE  users.name = @login_name
 AND users.type = 'G' -- Windows Group
 ) = 0
 BEGIN
 PRINT CHAR(10) + '--Working on msdb...'

 PRINT '--Creating user...'
 SET @perms = 'CREATE USER ' + QUOTENAME(@login_name) + ' FOR LOGIN ' + QUOTENAME(@login_name);

 IF @debug=1 PRINT @PERMS
 ELSE
 begin try
 exec sp_executesql @perms ;
 end try
 begin catch
 SELECT @error_message = ERROR_MESSAGE();
 RAISERROR (@error_message, 16, 2 );
 end catch
 END
ELSE
 PRINT '--User ' + QUOTENAME(@login_name) + ' already created in MSDB'

IF ( SELECT COUNT(*)
 FROM   sys.database_principals dbrole
 JOIN sys.database_role_members rel ON rel.role_principal_id = dbrole.principal_id
 JOIN sys.database_principals mem ON rel.member_principal_id = mem.principal_id
 AND mem.name = @login_name
 WHERE  dbrole.name = 'db_datareader'
 ) = 0
 BEGIN

 PRINT '--Granting datareader...'
 IF @debug=1 PRINT 'EXEC sp_addrolemember N''db_datareader'',' +  @login_name
 ELSE
 EXEC sp_addrolemember N'db_datareader', @login_name
 END
ELSE
 PRINT '--Datareader for ' + @login_name + ' already granted in MSDB'

IF ( SELECT COUNT(*)
 FROM   sys.database_principals dbrole
 JOIN sys.database_role_members rel ON rel.role_principal_id = dbrole.principal_id
 JOIN sys.database_principals mem ON rel.member_principal_id = mem.principal_id
 AND mem.name = @login_name
 WHERE  dbrole.name = 'SQLAgentReaderRole'
 ) = 0
 BEGIN
 PRINT '--Granting SQLAgentReaderRole...'

 IF @debug=1 PRINT 'EXEC sp_addrolemember N''SQLAgentReaderRole'',' + @login_name
 ELSE
 EXEC sp_addrolemember N'SQLAgentReaderRole', @login_name
 END
ELSE
 PRINT '--SQLAgentReaderRole for ' + @login_name + ' already granted in MSDB'

/******************************************
* Loop through user dbs and set perms...
******************************************/

DECLARE @dbs TABLE ( dbname SYSNAME )

DECLARE @dbname SYSNAME ;

INSERT  @dbs
 SELECT  name
 FROM    sys.databases
 WHERE   database_id > 4

WHILE ( SELECT  COUNT(*)
 FROM    @dbs
 ) > 0
 BEGIN
 SELECT TOP 1
 @dbname = dbname
 FROM    @dbs

 PRINT CHAR(10) + '--Working on ' + QUOTENAME(@dbName) +  '...'

 SELECT  @perms = '
 use ' + QUOTENAME(@dbName) +  '
 if (select count(*)
 from sys.database_principals users
 where users.name=' + QUOTENAME(@login_name,'''') + '
 and users.type=''G'' -- Windows Group
 ) = 0
 BEGIN
 print ''--Creating user ''' + QUOTENAME(@login_name,'''') + ''' on '' + DB_NAME()
 CREATE USER ' + QUOTENAME(@login_name) + ' FOR LOGIN ' + QUOTENAME(@login_name) + '
 END
 ELSE
 print ''--User ' + QUOTENAME(@login_name) + ' already created in '' + @@SERVERNAME + ''.'' + DB_NAME()
 '
 if @debug=1 PRINT @PERMS
 else
 begin try
 exec sp_executesql @perms ;
 end try
 begin catch
 SELECT @error_message = ERROR_MESSAGE();
 RAISERROR (@error_message, 16, 2 );
 end catch

 SELECT  @perms = '
 use ' + QUOTENAME(@dbName) +  '
 if (select count(*)
 from sys.database_principals dbrole
 join sys.database_role_members rel on
 rel.role_principal_id=dbrole.principal_id
 join sys.database_principals mem on
 rel.member_principal_id=mem.principal_id
 and mem.name=' + QUOTENAME(@login_name,'''') + '
 where dbrole.name = ''db_datareader''
 ) = 0
 begin
 print ''--Granting db_datareader ''' + QUOTENAME(@login_name,'''') + ''' on '' + DB_NAME()
 exec sp_addrolemember @rolename=''db_datareader'', @membername=' + QUOTENAME(@login_name,'''') + '
 END
 ELSE
 print ''--VIEW DEFINITION already granted to ''' + QUOTENAME(@login_name,'''') + ''' on '' + DB_NAME()
 '
 if @debug=1 PRINT @PERMS
 else
 begin try
 exec sp_executesql @perms ;
 end try
 begin catch
 SELECT @error_message = ERROR_MESSAGE();
 RAISERROR (@error_message, 16, 2 );
 end catch

 SELECT  @perms = '
 use ' + QUOTENAME(@dbName) +  '
 if (select count(*)
 from sys.database_principals users
 join sys.database_permissions prm on
 users.principal_id =prm.grantee_principal_id
 where users.name=' + QUOTENAME(@login_name,'''') + '
 and permission_name=''VIEW DEFINITION''
 ) = 0
 begin
 print ''--Granting VIEW DEFINITION ''' + QUOTENAME(@login_name,'''') + ''' on '' + DB_NAME()
 GRANT VIEW DEFINITION TO ' + QUOTENAME(@login_name) + '
 end
 ELSE
 print ''--VIEW DEFINITION already granted to ''' + QUOTENAME(@login_name,'''') + ''' on '' + DB_NAME()
 '
 if @debug=1 PRINT @PERMS
 else
 begin try
 exec sp_executesql @perms ;
 end try
 begin catch
 SELECT @error_message = ERROR_MESSAGE();
 RAISERROR (@error_message, 16, 2 );
 end catch

 SELECT  @perms = '
 use ' + QUOTENAME(@dbName) +  '
 if (select count(*)
 from sys.database_principals users
 join sys.database_permissions prm on
 users.principal_id =prm.grantee_principal_id
 where users.name=' + QUOTENAME(@login_name,'''') + '
 and permission_name=''SHOWPLAN''
 ) = 0
 begin
 print ''--Granting SHOWPLAN ''' + QUOTENAME(@login_name,'''') + ''' on '' + DB_NAME()
 GRANT SHOWPLAN TO ' + QUOTENAME(@login_name) + '
 end
 ELSE
 print ''--SHOWPLAN already granted to ''' + QUOTENAME(@login_name,'''') + ''' on '' + DB_NAME()
 '
 if @debug=1 PRINT @PERMS
 else
 begin try
 exec sp_executesql @perms ;
 end try
 begin catch
 SELECT @error_message = ERROR_MESSAGE();
 RAISERROR (@error_message, 16, 2 );
 end catch

 -- Move on to the next DB
 DELETE  FROM @dbs
 WHERE   dbname = @dbname

 END