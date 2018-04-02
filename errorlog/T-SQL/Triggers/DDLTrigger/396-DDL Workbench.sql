
/* How about automatically tracking and logging all database changes, 
including changes to tables, views, logins, queues and so on. With SQL
Server 2005 it isn't that hard, and we'll show how it is done. If you 
haven't got SQL Server 2005, then get SQL Server Express for free. It 
works on that! While we're about it, we'll show you how to track all
additions, changes and deletions of Logins and Database Users, using
a similar technique.

Contents
	Logging all changes to the database with source code.
	Preventing changes to database objects,
	Logging all changes to the Logins and database users,
	Further reading
 


Logging all changes to the database with source code.
-----------------------------------------------------

To start off, we'll write a simple trigger that tracks all database 
events This will include Creating, Altering or dropping an 
APPLICATION_ROLE, ASSEMBLY, AUTHORIZATION_DATABASE, CERTIFICATE, 
CONTRACT, FUNCTION, INDEX, MESSAGE_TYPE, PARTITION_FUNCTION, 
PARTITION_SCHEME, PROCEDURE, QUEUE, REMOTE_SERVICE_BINDING,
ROLE, ROUTE, SCHEMA, SERVICE, STATISTICS, TABLE, TRIGGER, USER, 
VIEW,  or XML_SCHEMA_COLLECTION. It will also record the creation, 
or dropping of an EVENT_NOTIFICATION, SYNONYM, or TYPE and track 
all GRANT_DATABASE, DENY_DATABASE, and REVOKE_DATABASE DDL.

The new DDL triggers work very like the DML triggers you know and love.
The most radical change is that the details of the event that fired the 
trigger are available only in XML format. You have to get serious with 
XPath queries to extract the XML which is in the format...

<EVENT_INSTANCE>
    <EventType>type</EventType>
    <PostTime>date-time</PostTime>
    <SPID>spid</SPID>
    <ServerName>name</ServerName>
    <LoginName>name</LoginName>
    <UserName>name</UserName>
    <DatabaseName>name</DatabaseName>
    <SchemaName>name</SchemaName>
    <ObjectName>name</ObjectName>
    <ObjectType>type</ObjectType>
    <TSQLCommand>command</TSQLCommand>
</EVENT_INSTANCE>
*/

--Before you do anything else, create a database called TestLogging

USE [TestLogging]
GO
/*now we will create a table that will be a change log. We will put 
in it the detail of each DDL SQL Statement and the user that did it.
We'll trap the login and the original login just to check for context 
switching. We'll record the type of object, the type of event and the 
object name, and, of course the SQL that did it! Who needs source
control?*/
CREATE TABLE [dbo].[DDLChangeLog]
    (
      [DDLChangeLog_ID] [int] IDENTITY(1, 1)
                              NOT NULL,
      [InsertionDate] [datetime] NOT NULL
		 CONSTRAINT [DF_ddl_log_InsertionDate] 
            DEFAULT ( GETDATE() ),
      [CurrentUser] [nvarchar](50) NOT NULL
		 CONSTRAINT [DF_ddl_log_CurrentUser]  
            DEFAULT ( CONVERT([nvarchar](50), USER_NAME(), ( 0 )) ),
      [LoginName] [nvarchar](50) NOT NULL
		 CONSTRAINT [DF_DDLChangeLog_LoginName]  
            DEFAULT ( CONVERT([nvarchar](50), SUSER_SNAME(), ( 0 )) ),
      [Username] [nvarchar](50) NOT NULL
		 CONSTRAINT [DF_DDLChangeLog_Username]  
            DEFAULT ( CONVERT([nvarchar](50), original_login(),(0)) ),
      [EventType] [nvarchar](100) NULL,
      [objectName] [nvarchar](100) NULL,
      [objectType] [nvarchar](100) NULL,
      [TSQL] [nvarchar](MAX) NULL
    )
ON  [PRIMARY]

go
/* now we'll create the trigger that fires whenever any database level
DDL events occur. We won't bother to record CREATE STATISTIC events*/
CREATE TRIGGER trgLogDDLEvent ON DATABASE
    FOR DDL_DATABASE_LEVEL_EVENTS
AS
    DECLARE @data XML
    SET @data = EVENTDATA()
    IF @data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)')
		 <> 'CREATE_STATISTICS' 
        INSERT  INTO DDLChangeLog
                (
                  EventType,
                  ObjectName,
                  ObjectType,
                  TSQL
                )
        VALUES  (
                  @data.value('(/EVENT_INSTANCE/EventType)[1]',
                              'nvarchar(100)'),
                  @data.value('(/EVENT_INSTANCE/ObjectName)[1]',
                              'nvarchar(100)'),
                  @data.value('(/EVENT_INSTANCE/ObjectType)[1]',
                              'nvarchar(100)'),
                  @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]',
                              'nvarchar(max)')
                ) ;
GO

--lets create a Table, view, and procedure, and then drop them, and after
-- that, see what was recorded in the log
USE [TestLogging]
GO
CREATE TABLE [dbo].[PublicHouses]--the test Table
    (
      [pubname] [varchar](100) NOT NULL,
      [Address] [varchar](100) NOT NULL,
      [postcode] [varchar](20) NOT NULL,
      [outcode] VARCHAR(4)
    )
ON  [PRIMARY]
GO
USE [TestLogging]
GO
CREATE VIEW [dbo].[vCambridgePubs]--the test view
AS  SELECT TOP ( 100 ) PERCENT
            pubname,
            Address + '  ' + postcode AS Expr1
    FROM    dbo.PublicHouses
    WHERE   ( postcode LIKE 'CM%' )
GO
CREATE PROCEDURE spInsertPub--the test stored procedure
    @pubname VARCHAR(100),
    @Address VARCHAR(100),
    @postcode VARCHAR(20)
AS 
    INSERT  INTO PublicHouse
            (
              pubname,
              Address,
              Postcode,
              outcode
            )
            SELECT  @pubname,
                    @Address,
                    @Postcode,
                    LEFT(LEFT(@Postcode, 
						CHARINDEX(' ', 
						@Postcode + ' ') - 1),
                        4)
go
DROP VIEW vCambridgePubs
go
DROP PROCEDURE spInsertPub ;
GO
DROP TABLE PublicHouses ;
GO
-- now, having done all that we can then see what happened. As you know,
-- this is the only way you'll ever see the current build statements for
-- your tables! Now try changing the database objects via SSMS and have a
-- look at the SQL DDL that gets executed!

SELECT  *
FROM    DDLChangeLog
ORDER BY insertionDate 

-- To help, here is a better rendering of the log. We create an HTML table
--and format it up prettily
DECLARE @HTMLCode VARCHAR(MAX)
SELECT  @HTMLCode = COALESCE(@HTMLCode, ' <style type="text/css">
    <!--
    #changes{
    	border: 1px solid silver;
    	font-family: Arial, Helvetica, sans-serif;
    	font-size: 11px;
    	padding: 10px 10px 10px 10px;
    }
    #changes td.date{ font-style: italic; }
    #changes td.tsql{ border-bottom: 1px solid silver; color: #00008B; }
    -->
    </style><table id="changes">
') + '<tr class="recordtop">
<td class="date">' + CONVERT(CHAR(18), InsertionDate, 113) + '</td>
<td class="currentuser">' + currentUser + '</td>
<td class="loginname">' + LoginName
        + CASE WHEN loginName <> UserName THEN '(' + UserName + ')'
               ELSE ''
          END + '</td>
<td class="eventtype">' + EventType + '</td>
<td class="objectname">' + ObjectName + '&nbsp;(' + objectType + ')'
        + '</td></tr>
<tr class="recordbase"><td colspan="6" class="TSQL"><pre>' + TSQL
        + '</pre></td></tr>
'
FROM    DDLChangeLog
ORDER BY insertionDate ;
SELECT  @HTMLCode + '
</table>'
GO
--Which gives this...


--once we finish logging we can...
--Drop the trigger.
DROP TRIGGER trgLogDDLEvent ON DATABASE
GO
--Drop table ddl_log.
DROP TABLE DDLChangeLog
GO
/*
Of course, this can be very valuable for Database Development work.

Preventing changes to database objects,
---------------------------------------

BOL seem to be very proud of their example code that prevents a table
being altered, though, if you have security nailed down properly, this
shouldn't happen anyway. */

CREATE TRIGGER trgNoMonkeying ON DATABASE
    FOR DROP_TABLE, ALTER_TABLE
AS
    DECLARE @Message VARCHAR(255)
    SELECT  @message = 'You are forbiddent to alter or delete the '''
            + EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]',
                                'nvarchar(100)') + ''' table'
    RAISERROR ( @Message, 16, 1 )
    ROLLBACK ;
GO



CREATE TABLE NewTable ( Column1 INT ) ;
GO
DROP TABLE NewTable
/*
'Msg 3609, Level 16, State 2, Line 1
The transaction ended in the trigger. The batch has been aborted.
Msg 50000, Level 18, State 1, Procedure trg, Line 8
You are forbiddent to alter or delete the 'NewTable' table'

Logging all changes to the Logins and database users
----------------------------------------------------


 another good use for triggers is to provide information about security
 events*/
go
USE master
go
--in MASTER, we'll creat a log for all the databases security events. 
CREATE TABLE [DDLSecurityLog]
    (
      [DDLSecurityLog_ID] [int] IDENTITY(1, 1)
                                NOT NULL,
      [InsertionDate] [datetime] NOT NULL
           CONSTRAINT [DF_ddl_log_InsertionDate] 
               DEFAULT ( GETDATE() ),
      [CurrentUser] [nvarchar](50) NOT NULL
           CONSTRAINT [DF_ddl_log_CurrentUser] 
               DEFAULT ( CONVERT([nvarchar](50), USER_NAME(), ( 0 )) ),
      [LoginName] [nvarchar](50) NOT NULL
           CONSTRAINT [DF_DDLSecurityLog_LoginName] 
               DEFAULT ( CONVERT([nvarchar](50), SUSER_SNAME(), ( 0 )) ),
      [Username] [nvarchar](50) NOT NULL
           CONSTRAINT [DF_DDLSecurityLog_Username] 
               DEFAULT ( CONVERT([nvarchar](50), original_login(), ( 0 )) ),
      [EventType] [nvarchar](100) NULL,
      [objectName] [nvarchar](100) NULL,
      [objectType] [nvarchar](100) NULL,
	  [DatabaseName] [nvarchar](100) null,
      [TSQL] [nvarchar](MAX) NULL
    )
ON  [PRIMARY]
/*
Now we will write a trigger that inserts into our security log all
server security events. There is a bug which prevents you just 
specifying all the security events, you have to list 'em*/


IF EXISTS ( SELECT  *
            FROM    sys.server_triggers
            WHERE   name = 'trgLogServerSecurityEvents' ) 
    DROP TRIGGER trgLogServerSecurityEvents ON ALL SERVER
GO
CREATE TRIGGER trgLogServerSecurityEvents ON ALL SERVER
    FOR CREATE_LOGIN, ALTER_LOGIN, DROP_LOGIN, GRANT_SERVER, DENY_SERVER,
        REVOKE_SERVER, ALTER_AUTHORIZATION_SERVER
AS
    DECLARE @data XML
    SET @data = EVENTDATA()
    INSERT  INTO master..DDLSecurityLog
       (
       EventType,
       ObjectName,
       ObjectType,
       TSQL,
	   DatabaseName
       )
    VALUES
       (
        @data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'),
        @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(100)'),
        @data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'nvarchar(100)'),
		   'Server',
        @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(max)')
        ) 
GO
/*
Now we have to create another trigger in each database which recors all
the database security changes*/
use testlogging--back to outr database!
go
CREATE TRIGGER trgLogDatabaseSecurityEvents ON DATABASE
    FOR DDL_DATABASE_SECURITY_EVENTS
AS
    DECLARE @data XML
    SET @data = EVENTDATA()
    INSERT  INTO master..DDLSecurityLog
         (
         EventType,
         ObjectName,
         ObjectType,
		 DatabaseName,
         TSQL
         )
    VALUES  
         (
         @data.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'),
         @data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(100)'),
         @data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'nvarchar(100)'),
         @data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'nvarchar(max)'),
         @data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'nvarchar(max)')
         ) 
GO
/* now everything is in place lets test it. We will simulate an intruder's
cunning attempt to create himself as a loging with sysAdmin rights and his
gaining access as a database user. We could always prevent the transaction 
but that would just draw his attention to the trigger being there!
*/ 

USE [master]
GO
/* Heh! Heh!*/
CREATE LOGIN [Intruder] WITH PASSWORD= N'silly', DEFAULT_DATABASE=
    [TestLogging], DEFAULT_LANGUAGE= [Português (Brasil)], CHECK_EXPIRATION=
    OFF, CHECK_POLICY= OFF
GO
EXEC master..sp_addsrvrolemember @loginame = N'Intruder',
    @rolename = N'sysadmin'
GO
USE [TestLogging]
GO
CREATE USER [Intruder] FOR LOGIN [Intruder]
GO
--now we will drop the database user
IF EXISTS ( SELECT  *
            FROM    sys.server_principals
            WHERE   name = N'Intruder' ) 
    DROP LOGIN [Intruder]
GO
--and drop the login
DROP USER [Intruder]
GO
/* now we can see that the whole activity has been logged. Because the
initial CREATE  LOGIN contained a password, it has not been recorded.
*/
SELECT  * FROM    master..DDLSecurityLog


--so to end up, we just clean up!
DROP TRIGGER trgLogDatabaseSecurityEvents ON DATABASE
DROP TRIGGER [trgNoMonkeying] ON DATABASE
go
use master
go
DROP TRIGGER trgLogServerSecurityEvents ON ALL SERVER
Drop table DDLSecurityLog 
GO
USE [TestLogging]
GO
Drop table NewTable
GO

