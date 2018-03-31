/*
2017-10-08
SQL SATURDAY ORLANDO attendees: While prepping this script for upload I noticed it is probably time to update the SQL Server version checks in the script.
Search for ProductVersion to see the lines affected.
I used to check for a specific version but given the deployment of SQL 2014, 2016, 2017 since I originally wrote this script I think it better if I check that the version is greather than 10 instead of equal to 11. I was initially checking for SQL 2012 only. Given that, I have updated the version check accordingly.

This script needs to be executed by a user that will not be affected by it's execution.
The SQL Server service account is one possibility or an individual domain login that has explicit access to the server.

This script will remove any DBA AD group that has the string 'DBA' in the group name from a server that is member of the sysadmin fixed server role.

This script will initially PRINT the commands that would be executed.
To execute the commands to implement Separation of Duties, uncomment the EXEC statements in each step.

DO NOT EXECUTE THIS SCRIPT IN YOUR ENVIRONMENT UNTIL YOU FULLY REVIEW AND UNDERSTAND WHAT IT IS DOING!
IF YOU STILL WANT TO RUN THIS SCRIPT WITHOUT FULLY UNDERSTANDING WHAT IT DOES, I GIVE YOU THE WISE WORDS OF BUCK WOODY TO REFLECT UPON. 

<BuckWoody>
Script Disclaimer, for people who need to be told this sort of thing:
Never trust any script, including those that you find here, until you understand exactly what it does and how it will act on your systems. 
Always check the script on a test system or Virtual Machine, not a production system. 
All scripts on this site are performed by a professional stunt driver on a closed course. 
Your mileage may vary. Void where prohibited. Offer good for a limited time only. 
Keep out of reach of small children. Do not operate heavy machinery while using this script. 
If you experience blurry vision, indigestion or heartburn during the operation of this script, see a physician.
</BuckWoody>

You will have to modify this script to include the domain and group names used in your environment for it to work as advertised.

Original script author: Ron Dameron <ron.dameron@gmail.com>
Thank you for attending SQL Saturday #678 in Orlando, FL.

*/


/*
MSSQL Separation of Duties Deployment Package 
This script will setup the new MSSQL DBA Security model.
Order of execution:
1. Create sp_foreachdb stored procedure.
2. Add Cyber-Ark DBA groups to sysadmin server role.  !!!COMMENTED OUT BECAUSE GROUPS HAVE BEEN ADDED BY ANOTHER TASK!!!
3. Reduced permissions are granted to the DBA groups.
4. Deny DBA access to user database schemas.
5. Drop DBA groups from sysadmin server role
6. Grant DBAs membership to SQLAgentOperatorRole
*/

/*
1. sp_foreachdb
*/
/*
MSSQL Separation of Duties deployment pre-requisite
sp_foreachdb is a pre-requisite for the remaining steps.

*/

USE [master];
GO

IF OBJECT_ID('dbo.sp_foreachdb') IS NOT NULL 
    DROP PROCEDURE dbo.sp_foreachdb
GO

CREATE PROCEDURE dbo.sp_foreachdb
    @command NVARCHAR(MAX) ,
    @replace_character NCHAR(1) = N'?' ,
    @print_dbname BIT = 0 ,
    @print_command_only BIT = 0 ,
    @suppress_quotename BIT = 0 ,
    @system_only BIT = NULL ,
    @user_only BIT = NULL ,
    @name_pattern NVARCHAR(300) = N'%' ,
    @database_list NVARCHAR(MAX) = NULL ,
    @exclude_list NVARCHAR(MAX) = NULL ,
    @recovery_model_desc NVARCHAR(120) = NULL ,
    @compatibility_level TINYINT = NULL ,
    @state_desc NVARCHAR(120) = N'ONLINE' ,
    @is_read_only BIT = 0 ,
    @is_auto_close_on BIT = NULL ,
    @is_auto_shrink_on BIT = NULL ,
    @is_broker_enabled BIT = NULL
AS 
    BEGIN
        SET NOCOUNT ON;

        DECLARE @sql NVARCHAR(MAX) ,
            @dblist NVARCHAR(MAX) ,
            @exlist NVARCHAR(MAX) ,
            @db NVARCHAR(300) ,
            @i INT;

        IF @database_list > N'' 
            BEGIN
       ;
                WITH    n ( n )
                          AS ( SELECT   ROW_NUMBER() OVER ( ORDER BY s1.name )
                                        - 1
                               FROM     sys.objects AS s1
                                        CROSS JOIN sys.objects AS s2
                             )
                    SELECT  @dblist = REPLACE(REPLACE(REPLACE(x, '</x><x>',
                                                              ','), '</x>', ''),
                                              '<x>', '')
                    FROM    ( SELECT DISTINCT
                                        x = 'N'''
                                        + LTRIM(RTRIM(SUBSTRING(@database_list,
                                                              n,
                                                              CHARINDEX(',',
                                                              @database_list
                                                              + ',', n) - n)))
                                        + ''''
                              FROM      n
                              WHERE     n <= LEN(@database_list)
                                        AND SUBSTRING(',' + @database_list, n,
                                                      1) = ','
                            FOR
                              XML PATH('')
                            ) AS y ( x );
            END
			
-- Added for @exclude_list
        IF @exclude_list > N'' 
            BEGIN
       ;
                WITH    n ( n )
                          AS ( SELECT   ROW_NUMBER() OVER ( ORDER BY s1.name )
                                        - 1
                               FROM     sys.objects AS s1
                                        CROSS JOIN sys.objects AS s2
                             )
                    SELECT  @exlist = REPLACE(REPLACE(REPLACE(x, '</x><x>',
                                                              ','), '</x>', ''),
                                              '<x>', '')
                    FROM    ( SELECT DISTINCT
                                        x = 'N'''
                                        + LTRIM(RTRIM(SUBSTRING(@exclude_list,
                                                              n,
                                                              CHARINDEX(',',
                                                              @exclude_list
                                                              + ',', n) - n)))
                                        + ''''
                              FROM      n
                              WHERE     n <= LEN(@exclude_list)
                                        AND SUBSTRING(',' + @exclude_list, n,
                                                      1) = ','
                            FOR
                              XML PATH('')
                            ) AS y ( x );
            END
			
        CREATE TABLE #x ( db NVARCHAR(300) );

        SET @sql = N'SELECT name FROM sys.databases WHERE 1=1'
            + CASE WHEN @system_only = 1 THEN ' AND database_id IN (1,2,3,4)'
                   ELSE ''
              END
            + CASE WHEN @user_only = 1
                   THEN ' AND database_id NOT IN (1,2,3,4)'
                   ELSE ''
              END
-- added by me so I can exclude DBA Utility databases from changes	
            + CASE WHEN @exlist IS NOT NULL
                   THEN ' AND name NOT IN (' + @exlist + ')'
                   ELSE ''
              END + CASE WHEN @name_pattern <> N'%'
                         THEN ' AND name LIKE N''%' + REPLACE(@name_pattern,
                                                              '''', '''''')
                              + '%'''
                         ELSE ''
                    END + CASE WHEN @dblist IS NOT NULL
                               THEN ' AND name IN (' + @dblist + ')'
                               ELSE ''
                          END
            + CASE WHEN @recovery_model_desc IS NOT NULL
                   THEN ' AND recovery_model_desc = N'''
                        + @recovery_model_desc + ''''
                   ELSE ''
              END
            + CASE WHEN @compatibility_level IS NOT NULL
                   THEN ' AND compatibility_level = '
                        + RTRIM(@compatibility_level)
                   ELSE ''
              END
            + CASE WHEN @state_desc IS NOT NULL
                   THEN ' AND state_desc = N''' + @state_desc + ''''
                   ELSE ''
              END
            + CASE WHEN @is_read_only IS NOT NULL
                   THEN ' AND is_read_only = ' + RTRIM(@is_read_only)
                   ELSE ''
              END
            + CASE WHEN @is_auto_close_on IS NOT NULL
                   THEN ' AND is_auto_close_on = ' + RTRIM(@is_auto_close_on)
                   ELSE ''
              END
            + CASE WHEN @is_auto_shrink_on IS NOT NULL
                   THEN ' AND is_auto_shrink_on = ' + RTRIM(@is_auto_shrink_on)
                   ELSE ''
              END
            + CASE WHEN @is_broker_enabled IS NOT NULL
                   THEN ' AND is_broker_enabled = ' + RTRIM(@is_broker_enabled)
                   ELSE ''
              END;

        INSERT  #x
                EXEC sp_executesql @sql;

        DECLARE c CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY
        FOR
            SELECT  CASE WHEN @suppress_quotename = 1 THEN db
                         ELSE QUOTENAME(db)
                    END
            FROM    #x
            ORDER BY db;

        OPEN c;

        FETCH NEXT FROM c INTO @db;

        WHILE @@FETCH_STATUS = 0 
            BEGIN
                SET @sql = REPLACE(@command, @replace_character, @db);

                IF @print_command_only = 1 
                    BEGIN
                        PRINT '/* For ' + @db + ': */' + CHAR(13) + CHAR(10)
                            + CHAR(13) + CHAR(10) + @sql + CHAR(13) + CHAR(10)
                            + CHAR(13) + CHAR(10);
                    END
                ELSE 
                    BEGIN
                        IF @print_dbname = 1 
                            BEGIN
                                PRINT '/* ' + @db + ' */';
                            END

                        EXEC sp_executesql @sql;
                    END

                FETCH NEXT FROM c INTO @db;
            END

        CLOSE c;
        DEALLOCATE c;
    END
GO


/*
2. Add Cyber-Ark DBA groups to sysadmin server role
*/

/*
DECLARE @SVRNAME VARCHAR(150)
SELECT  @SVRNAME = @@SERVERNAME 

IF (SELECT STUFF(SUSER_SNAME(), CHARINDEX('\', SUSER_SNAME()), LEN(SUSER_SNAME()), ''))= 'Domain1'  -- Handle servers in domain 1
	BEGIN
	IF ( @SVRNAME LIKE '%TCSQL%' )  -- TRICARE
		BEGIN
			IF ( ( SELECT   LEFT(CAST (SERVERPROPERTY('ProductVersion') AS VARCHAR(10)),2)) > 10 )   -- SQL Server 2012 or highter
				BEGIN
					IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'D1\xxx_xxxxx_xxxxxx')
						BEGIN 
							CREATE LOGIN [D1\xxx_xxxxx_xxxxxx] FROM WINDOWS;
							EXEC('ALTER SERVER ROLE sysadmin ADD MEMBER [D1\xxx_xxxxx_xxx];') 
						END
				END
			ELSE 
				BEGIN
					IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'D1\xxx_xxx_xxxx')
						BEGIN
							CREATE LOGIN [D1\xxx_xxxxx_xxxxxx] FROM WINDOWS;
							EXEC sp_addsrvrolemember 'D1\xxx_xxx_xxxx', 'sysadmin';
						END
				END
		END
	ELSE 
		BEGIN
			IF ( ( SELECT   LEFT(CAST (SERVERPROPERTY('ProductVersion') AS VARCHAR(10)),2)) > 10 )  -- SQL Server 2012 or higher
				BEGIN
					IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'D1\xxx_xxx_xxxx')
						BEGIN 
							CREATE LOGIN [D1\xxx_xxxxx_xxxxxx] FROM WINDOWS;
							EXEC('ALTER SERVER ROLE sysadmin ADD MEMBER [xxx_xxx_xxxx];') 
						END
				END
			ELSE 
				BEGIN
					IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'D1\xxx_xxx_xxxxx')
						BEGIN 
							CREATE LOGIN [D1\xxx_xxx_xxxxx] FROM WINDOWS;
							EXEC sp_addsrvrolemember 'D2\xxx_xxx_xxxxx', 'sysadmin';
						END
				END
		END
END
ELSE -- Handle servers in D2 domain
	BEGIN 
		IF (SELECT STUFF(SUSER_SNAME(), CHARINDEX('\', SUSER_SNAME()), LEN(SUSER_SNAME()), ''))= 'Domain2'
			BEGIN
				IF ( ( SELECT   LEFT(CAST (SERVERPROPERTY('ProductVersion') AS VARCHAR(10)),2)) > 10 )   -- SQL Server 2012 or higher
					BEGIN
						IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'D2\xxx_xxx_xxxx')
							BEGIN 
								CREATE LOGIN [D2\xxx_xxx_xxxx] FROM WINDOWS;
								EXEC('ALTER SERVER ROLE sysadmin ADD MEMBER [xxx_xxx_xxxx];') 
							END
					END
				ELSE 
					BEGIN
						IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'D2\xxx_xxx_xxxx')
							BEGIN 
								CREATE LOGIN [D2\xxx_xxx_xxxx] FROM WINDOWS;
								EXEC sp_addsrvrolemember 'D2\xxx_xxx_xxxx', 'sysadmin';
							END
					END
			END
	END	
*/
	
/*
3. Grant minimum permissions needed to existing DBA groups for new MSSQL Security model
*/
USE master
GO

SET NOCOUNT ON

DECLARE @cmds TABLE ( Cmd VARCHAR(500) )

-- load commands to be executed
INSERT  @cmds
VALUES  ( 'GRANT CONTROL SERVER TO [' )

INSERT  @cmds
VALUES  ( 'DENY ALTER ANY LOGIN TO [' )
	
INSERT  @cmds
VALUES  ( 'DENY ALTER ANY CREDENTIAL TO [' )

INSERT  @cmds
VALUES  ( 'GRANT CREATE ANY DATABASE TO [' )

--	Add an additional INSERT here to add DENY IMPERSONATE when ready for it.

-- Get major version number by finding the first period in the string with PATINDEX.  Then, use position of period in LEFT function to get major version number 	
IF ( SELECT LEFT(CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(10)),
                 PATINDEX('%.%',
                          ( CAST (SERVERPROPERTY('ProductVersion') AS VARCHAR(10)) ))
                 - 1)
   ) > '10' 
    BEGIN
        INSERT  @cmds
        VALUES  ( 'DENY ALTER ANY SERVER ROLE TO [' )
    END

DECLARE CmdsOuter CURSOR LOCAL FAST_FORWARD
FOR
    SELECT  Cmd
    FROM    @cmds

DECLARE @cmdOuter VARCHAR(MAX)
OPEN CmdsOuter
FETCH NEXT FROM CmdsOuter INTO @cmdOuter
WHILE @@FETCH_STATUS = 0 
    BEGIN
        DECLARE commands CURSOR LOCAL FAST_FORWARD
        FOR
            SELECT  @cmdOuter + p.name + '];'
            FROM    sys.server_principals p
                    JOIN sys.syslogins s ON p.sid = s.sid
            --WHERE   p.type_desc = 'WINDOWS_GROUP'  
			WHERE	p.type_desc = 'SQL_LOGIN'  -- included for demo
			-- Logins that are not process logins
                    AND p.name NOT LIKE '##%'
			-- Logins that are sysadmins
                    AND s.sysadmin = 1
                    AND p.name LIKE '%DBA%'
					--AND p.name NOT LIKE 'R1\DBATools'
			
        DECLARE @cmd VARCHAR(MAX)
        OPEN commands
        FETCH NEXT FROM commands INTO @cmd
        WHILE @@FETCH_STATUS = 0 
            BEGIN
				--EXEC(@cmd)  -- uncomment when ready to execute
                PRINT ( @cmd )
                FETCH NEXT FROM commands INTO @cmd
            END

        CLOSE commands
        DEALLOCATE commands        
        FETCH NEXT FROM CmdsOuter INTO @cmdOuter
    END

CLOSE CmdsOuter
DEALLOCATE CmdsOuter
	
			
/*
4. DENY DBA access to USER database schemas to prevent DBA access to data in USER databases.
*/
SET QUOTED_IDENTIFIER OFF;  
GO

DECLARE @result VARCHAR(MAX);
DECLARE @result2 VARCHAR(MAX);

SELECT  @result = COALESCE(@result + ', ', '') + QUOTENAME(QUOTENAME(p.name,
                                                              '[]'), CHAR(39))
FROM    sys.server_principals p
        JOIN sys.syslogins s ON p.sid = s.sid
--WHERE   p.type_desc = 'WINDOWS_GROUP'
WHERE	p.type_desc = 'SQL_LOGIN' -- included for demo
			-- Logins that are not process logins
        AND p.name NOT LIKE '##%'
			-- Logins that are sysadmins
        AND s.sysadmin = 1
        AND p.name LIKE '%DBA%'
		--AND p.name NOT LIKE 'R1\DBATools'
	
--SELECT  @result    
SELECT  @result2 = REPLACE(@result, CHAR(39), '')

DECLARE @cmdexec VARCHAR(MAX);	
SELECT  @cmdexec = 'USE ?;
DECLARE commands CURSOR LOCAL FAST_FORWARD
FOR
    SELECT  ''DENY ALTER, SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::''
			+ QUOTENAME(name, ''[]'') + '' TO ' + @result2 + '; '''
        + 'FROM    sys.schemas
	WHERE   name NOT LIKE ''db[_]%''
        AND name NOT LIKE ''D1%''
        AND name NOT LIKE ''D2%''
        AND name NOT LIKE ''R1%''
		AND name NOT IN ( ''sys'', ''INFORMATION_SCHEMA'', SUSER_NAME())
	AND name NOT IN ( SELECT    p.name COLLATE DATABASE_DEFAULT
                          FROM      sys.server_principals p
                                    JOIN sys.syslogins s ON p.sid = s.sid
                          --WHERE     p.type_desc = ''WINDOWS_GROUP''
						  WHERE	p.type_desc = ''SQL_LOGIN''
			-- Logins that are not process logins
                                    AND p.name NOT LIKE ''##%''' + ');' + '	

DECLARE @cmd VARCHAR(MAX);

OPEN commands
FETCH NEXT FROM commands INTO @cmd
WHILE @@FETCH_STATUS = 0 
    BEGIN
		PRINT @cmd
        --EXEC(@cmd)
        FETCH NEXT FROM commands INTO @cmd
    END

CLOSE commands
DEALLOCATE commands'    
                     
EXEC sp_foreachdb @user_only = 1, @exclude_list = 'DBAUtilityDB, tracedb', @print_dbname = 1, @command = @cmdexec 

SET QUOTED_IDENTIFIER ON;
GO

/*
5.  Drop DBA groups from sysadmin server role
*/
SET NOCOUNT ON
GO

IF (SELECT LEFT(CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(10)),PATINDEX('%.%',( CAST (SERVERPROPERTY('ProductVersion') AS VARCHAR(10)))) - 1)) > '10'  
    BEGIN
        DECLARE commands2012 CURSOR LOCAL FAST_FORWARD
        FOR
            SELECT  'ALTER SERVER ROLE sysadmin DROP MEMBER ' + QUOTENAME(p.name, '[]')
                    + ';'
            FROM    sys.server_principals p
                    JOIN sys.syslogins s ON p.sid = s.sid
            --WHERE   p.type_desc = 'WINDOWS_GROUP'
			WHERE	p.type_desc = 'SQL_LOGIN'  -- included for demo
        -- Logins that are not process logins
                    AND p.name NOT LIKE '##%'
        -- Logins that are sysadmins
                    AND s.sysadmin = 1
                    AND p.name LIKE '%DBA%'
					--AND p.name NOT LIKE 'R1\DBATools'
        
        DECLARE @cmd2012 VARCHAR(MAX)
        OPEN commands2012
        FETCH NEXT FROM commands2012 INTO @cmd2012
        WHILE @@FETCH_STATUS = 0 
            BEGIN
        		--EXEC(@cmd2012)  -- uncomment when ready
                PRINT ( @cmd2012 )
                FETCH NEXT FROM commands2012 INTO @cmd2012
            END

        CLOSE commands2012
        DEALLOCATE commands2012        
    END
ELSE 
    BEGIN
		DECLARE commands CURSOR LOCAL FAST_FORWARD
        FOR
            SELECT  'EXEC sp_dropsrvrolemember ' + QUOTENAME(p.name, CHAR(39)) + ', ''sysadmin'''
            FROM    sys.server_principals p
                    JOIN sys.syslogins s ON p.sid = s.sid
            --WHERE   p.type_desc = 'WINDOWS_GROUP'
			WHERE	p.type_desc = 'SQL_LOGIN' -- included for demo
        -- Logins that are not process logins
                    AND p.name NOT LIKE '##%'
        -- Logins that are sysadmins
                    AND s.sysadmin = 1
                    AND p.name LIKE '%DBA%'
					--AND p.name NOT LIKE 'R1\DBATools'
        
        DECLARE @cmd VARCHAR(MAX)
        OPEN commands
        FETCH NEXT FROM commands INTO @cmd
        WHILE @@FETCH_STATUS = 0 
            BEGIN
				--EXEC(@cmd)  -- uncomment when ready
                PRINT ( @cmd )
                FETCH NEXT FROM commands INTO @cmd
            END

        CLOSE commands
        DEALLOCATE commands        
    END
GO

/*
6.  Grant DBAs membership to SQLAgentOperatorRole, db_ssisadmin, db_dtsadmin
*/
IF (SELECT LEFT(CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR(10)),PATINDEX('%.%',( CAST (SERVERPROPERTY('ProductVersion') AS VARCHAR(10)))) - 1)) = '9' 
	BEGIN
			DECLARE commands CURSOR LOCAL FAST_FORWARD
			        FOR
						SELECT         
							'USE [master];
							ALTER LOGIN ' + '[' +  p.name + ']' + ' WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english];
							USE [msdb];
							IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = ''' + p.NAME + ''') BEGIN
							CREATE USER ' + '[' +  p.name + ']' + ' FOR LOGIN [' + p.name + '];  END 
							USE [msdb];
							EXEC sp_addrolemember N''SQLAgentOperatorRole'', N''' +  p.name + '''' + '; 
							EXEC sp_addrolemember N''db_dtsadmin'', N''' +  p.name + '''' + ';'
							FROM    sys.server_principals p
									JOIN sys.syslogins s ON p.sid = s.sid
							--WHERE   p.type_desc = 'WINDOWS_GROUP'
							WHERE	p.type_desc = 'SQL_LOGIN'  -- included for demo
										-- Logins that are not process logins
									AND p.name NOT LIKE '##%'
										-- Logins that are sysadmins
									--AND s.sysadmin = 1
									AND p.name LIKE '%DBA%'
									--AND p.name NOT LIKE 'R1\DBATools'
					
			        DECLARE @cmd2005 VARCHAR(MAX)
			        OPEN commands
			        FETCH NEXT FROM commands INTO @cmd2005
			        WHILE @@FETCH_STATUS = 0 
			            BEGIN
							--EXEC(@cmd2005)  -- uncomment when ready
			                PRINT ( @cmd2005 )
			                FETCH NEXT FROM commands INTO @cmd2005
			            END
			
			        CLOSE commands
			        DEALLOCATE commands   	
	END
ELSE
	BEGIN
			DECLARE commands CURSOR LOCAL FAST_FORWARD
			        FOR
						SELECT         
							'USE [master];
							ALTER LOGIN ' + '[' +  p.name + ']' + ' WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english];
							USE [msdb];
							IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = ''' + p.NAME + ''') BEGIN
							CREATE USER ' + '[' +  p.name + ']' + ' FOR LOGIN [' + p.name + '];  END 
							USE [msdb];
							EXEC sp_addrolemember N''SQLAgentOperatorRole'', N''' +  p.name + '''' + '; 
							EXEC sp_addrolemember N''db_ssisadmin'', N''' +  p.name + '''' + ';'
							FROM    sys.server_principals p
									JOIN sys.syslogins s ON p.sid = s.sid
							--WHERE   p.type_desc = 'WINDOWS_GROUP'
							WHERE	p.type_desc = 'SQL_LOGIN'  -- included for demo
										-- Logins that are not process logins
									AND p.name NOT LIKE '##%'
										-- Logins that are sysadmins
									--AND s.sysadmin = 1
									AND p.name LIKE '%DBA%'
									--AND p.name NOT LIKE 'R1\DBATools'
					
			        DECLARE @cmd VARCHAR(MAX)
			        OPEN commands
			        FETCH NEXT FROM commands INTO @cmd
			        WHILE @@FETCH_STATUS = 0 
			            BEGIN
							--EXEC(@cmd)  -- uncomment when ready
			                PRINT ( @cmd )
			                FETCH NEXT FROM commands INTO @cmd
			            END
			
			        CLOSE commands
			        DEALLOCATE commands   	
	END
     
GO

REVERT;