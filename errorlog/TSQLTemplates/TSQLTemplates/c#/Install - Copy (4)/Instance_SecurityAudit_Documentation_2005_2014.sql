/* ====================================================================================================================== */
/* Instance Security Audit Documentation */
/* Runs for all databases, unless a specific database is used in the WHERE clause below */
/* */
/* By VikingDBA 12/28/2011 */
/* ====================================================================================================================== */
/* Modifications:

20121116 DAF Little change to work with DBs with different collates.
08/07/2012 Changed to also do Server Level Permissions (like VIEW ANY DATABASE, or VIEW SERVER STATE)

*/

Use MASTER

SET NOCOUNT ON


/* ==================================================================================================================== */
-- Security Audit for SERVER Roles
DECLARE @sr varchar(100)
DECLARE @mn varchar(150)
DECLARE @cmd varchar(4000)
DECLARE @col1nm varchar(200)
DECLARE @col2nm varchar(200)
DECLARE @col3nm varchar(200)
DECLARE @col4nm varchar(200)
DECLARE @col5nm varchar(200)
DECLARE @col6nm varchar(200)
DECLARE @col7nm varchar(200)
DECLARE @col8nm varchar(200)
DECLARE @col9nm varchar(200)
DECLARE @col10nm varchar(200)
DECLARE @col11nm varchar(200)
DECLARE @col12nm varchar(200)
DECLARE @col13nm varchar(200)
DECLARE @col14nm varchar(200)
DECLARE @col15nm varchar(200)
DECLARE @col16nm varchar(200)
DECLARE @col17nm varchar(200)
DECLARE @col18nm varchar(200)
DECLARE @col19nm varchar(200)
DECLARE @col20nm varchar(200)
DECLARE @col1len int
DECLARE @col2len int
DECLARE @col3len int
DECLARE @col4len int
DECLARE @col5len int
DECLARE @col6len int
DECLARE @col7len int
DECLARE @col8len int
DECLARE @col9len int
DECLARE @col10len int
DECLARE @col11len int
DECLARE @col12len int
DECLARE @col13len int
DECLARE @col14len int
DECLARE @col15len int
DECLARE @col16len int
DECLARE @col17len int
DECLARE @col18len int
DECLARE @col19len int
DECLARE @col20len int
DECLARE @col1max int
DECLARE @col2max int
DECLARE @col3max int
DECLARE @col4max int
DECLARE @col5max int
DECLARE @col6max int
DECLARE @col7max int
DECLARE @col8max int
DECLARE @col9max int
DECLARE @col10max int
DECLARE @col11max int
DECLARE @col12max int
DECLARE @col13max int
DECLARE @col14max int
DECLARE @col15max int
DECLARE @col16max int
DECLARE @col17max int
DECLARE @col18max int
DECLARE @col19max int
DECLARE @col20max int
DECLARE @col1min int
DECLARE @col2min int
DECLARE @col3min int
DECLARE @col4min int
DECLARE @col5min int
DECLARE @col6min int
DECLARE @col7min int
DECLARE @col8min int
DECLARE @col9min int
DECLARE @col10min int
DECLARE @col11min int
DECLARE @col12min int
DECLARE @col13min int
DECLARE @col14min int
DECLARE @col15min int
DECLARE @col16min int
DECLARE @col17min int
DECLARE @col18min int
DECLARE @col19min int
DECLARE @col20min int
DECLARE @rn varchar(200)
DECLARE @un varchar(200)
DECLARE @ut varchar(200)
DECLARE @sd varchar(200)
DECLARE @pn varchar(200)
DECLARE @sn varchar(200)
DECLARE @on varchar(200)
DECLARE @pd varchar(200)
DECLARE @sdmax int
DECLARE @pnmax int
DECLARE @snmax int
DECLARE @onmax int
DECLARE @pdmax int
DECLARE @unmax int
DECLARE @rnmax int
DECLARE @utmax int
DECLARE @outputtype	int
DECLARE @prodlevel varchar(25)
DECLARE @version	varchar(250)
DEClARE @prodver	varchar(50)
DECLARE @edition	varchar(50)
DECLARE @includeobjlvlperms	bit
DECLARE @includeroleinfo	bit
DECLARE @usnm	varchar(128)
DECLARE @ustp	varchar(60)
DECLARE @stdsc	varchar(60)
DECLARE @permnm varchar(128)

SET @outputtype = 2	 -- 1=columnar 2=assignment statements
SET @includeobjlvlperms = 1
SET @includeroleinfo = 1

SELECT @prodlevel=CONVERT(varchar(25),SERVERPROPERTY('ProductLevel'))
SELECT @version=CONVERT(varchar(250),@@VERSION)
SELECT @prodver=CONVERT(varchar(50),SERVERPROPERTY('ProductVersion'))
SELECT @edition=CONVERT(varchar(50),SERVERPROPERTY('Edition'))
/* ============================================================================ */
--Find split out line
DECLARE @lvaltouse	varchar(2000)
DECLARE @lvallength	int
DECLARE @lvalct	int
DECLARE @spotcat	int
DECLARE @spotcatval	int
DECLARE @lval1	varchar(2000)
DECLARE @lval2	varchar(2000)
DECLARE @lval3	varchar(2000)
DECLARE @lval4	varchar(2000)
DECLARE @lval5	varchar(2000)
DECLARE @lval6	varchar(2000)
SET @lvaltouse = @version
SET @lvallength = LEN(@lvaltouse)
SET @lvalct = 1
SET @spotcat = 1
SET @lval1 = ''
SET @lval2 = ''
SET @lval3 = ''
SET @lval4 = ''
SET @lval5 = ''
SET @lval6 = ''
WHILE @spotcat <= @lvallength
BEGIN
SET @spotcatval = ASCII(SUBSTRING(@lvaltouse,@spotcat,1))
if @spotcatval = 10	 -- value we are looking for
SET @lvalct = @lvalct + 1	 -- set to go to the next line and start building it
else	 -- add to current value line
BEGIN
if @spotcatval <> 9	 -- values we are wanting to exclude
BEGIN
if @lvalct = 1
SET @lval1 = @lval1 + CHAR(@spotcatval)
if @lvalct = 2
SET @lval2 = @lval2 + CHAR(@spotcatval)
if @lvalct = 3
SET @lval3 = @lval3 + CHAR(@spotcatval)
if @lvalct = 4
SET @lval4 = @lval4 + CHAR(@spotcatval)
if @lvalct = 5
SET @lval5 = @lval5 + CHAR(@spotcatval)
if @lvalct = 6
SET @lval6 = @lval6 + CHAR(@spotcatval)
END
END
SET @spotcat = @spotcat + 1
END
--PRINT 'Line to split=' + @lvaltouse
--PRINT 'line1 = ' + @lval1
--PRINT 'line2 = ' + @lval2
--PRINT 'line3 = ' + @lval3
--PRINT 'line4 = ' + @lval4
--PRINT 'line5 = ' + @lval5
--PRINT 'line6 = ' + @lval6
/* ============================================================================= */


PRINT '============================================================================================================='
PRINT ' Security Audit For Server Instance ' + CONVERT(varchar(128),@@servername)
if @outputtype = 2
PRINT ' Assignment Statements'
PRINT ' For ' + CONVERT(varchar(128),getdate(),101) + ' ' + CONVERT(varchar(128),getdate(),108)
PRINT '============================================================================================================='
PRINT 'SQL Server Version: ' + @lval1
PRINT ' ' + @lval4
PRINT '============================================================================================================='
PRINT 'NOTE: Make sure to get list of logins using the sp_help_revlogin stored procedure in the master database.'
PRINT '============================================================================================================='
PRINT ' Server Role Security Settings'
PRINT ' '
PRINT ' '




CREATE TABLE #rolememberdummy
(ServerRole varchar(100),
MemberName varchar(150),
MemberSID varchar(2000)
)
CREATE TABLE #dummyDBPerms
(	StateDesc	varchar(200),
PermName	varchar(200),
SchemaName	varchar(200),
ObjectName	varchar(200),
UserName	varchar(200),
ObjectType	varchar(200),
UserType	varchar(200)
)


-- Security Audit
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'sysadmin'
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'securityadmin'
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'serveradmin'
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'dbcreator'
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'diskadmin'
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'processadmin'
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'setupadmin'
INSERT INTO #rolememberdummy
EXEC sp_helpsrvrolemember 'bulkadmin'



SET @col1nm = 'Role'
SET @col1len = 20
SET @col2nm = ''
SET @col2len = 8
SET @col3nm = 'Member Name'
SET @col3len = 30
PRINT @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm
PRINT REPLICATE('=',@col1len) + SPACE(@col2len) + REPLICATE('=',@col3len)






--SELECT CONVERT(varchar(30),ServerRole) as ServerRole, CONVERT(varchar(30),MemberName) AS MemberName FROM #rolememberdummy
DECLARE backupFiles CURSOR FOR 
SELECT ServerRole, MemberName FROM #rolememberdummy

OPEN backupFiles 

-- Loop through all the files for the database 
FETCH NEXT FROM backupFiles INTO @sr, @mn

WHILE @@FETCH_STATUS = 0 
BEGIN 
SET @col1nm = @sr
SET @col1len = 20
SET @col2nm = ''
SET @col2len = 8
SET @col3nm = @mn
SET @col3len = 30
PRINT @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm


FETCH NEXT FROM backupFiles INTO @sr, @mn
END 

CLOSE backupFiles 
DEALLOCATE backupFiles 

DROP TABLE #rolememberdummy


PRINT ' '
PRINT ' '
PRINT '==========================================================================================================='
PRINT ' Server Level Permissions'
PRINT ' '
PRINT ' '

CREATE TABLE #serverpermdummy
(UserName varchar(128),
UserType varchar(60),
StateDesc varchar(60),
PermName varchar(128)
)

INSERT INTO #serverpermdummy
SELECT l.name as UserName, l.type_desc AS UserType, p.state_desc AS StateDesc, p.permission_name AS PermName
FROM sys.server_permissions AS p 
JOIN sys.server_principals AS l ON p.grantee_principal_id = l.principal_id 
WHERE ((permission_name <> 'CONNECT SQL' AND permission_name <> 'CONNECT') OR p.state_desc = 'DENY') AND l.type_desc <> 'CERTIFICATE_MAPPED_LOGIN' AND l.name NOT LIKE '%##MS_%'
ORDER BY l.principal_id

--SELECT * FROM sys.server_principals

SET @col1nm = 'User Name'
SET @col1len = 20
SET @col2nm = ''
SET @col2len = 8
SET @col3nm = 'User Type'
SET @col3len = 20
SET @col4nm = ''
SET @col4len = 8
SET @col5nm = 'State Desc'
SET @col5len = 20
SET @col6nm = ''
SET @col6len = 8
SET @col7nm = 'Permission'
SET @col7len = 30

SET @col1min = LEN(@col1nm)
SET @col3min = LEN(@col3nm)
SET @col5min = LEN(@col5nm)
SET @col7min = LEN(@col7nm)

--Get the length of the longest occurance of the columns
SELECT @col1max = ISNULL(MAX(len(LTRIM(RTRIM(UserName)))),0) FROM #serverpermdummy
SELECT @col3max = ISNULL(MAX(len(LTRIM(RTRIM(UserType)))),0) FROM #serverpermdummy
SELECT @col5max = ISNULL(MAX(len(LTRIM(RTRIM(StateDesc)))),0) FROM #serverpermdummy
SELECT @col7max = ISNULL(MAX(len(LTRIM(RTRIM(PermName)))),0) FROM #serverpermdummy


--Set some minimum values so column doesn't print short
if @col1max < @col1min SET @col1len = @col1min else SET @col1len = @col1max
if @col3max < @col3min SET @col3len = @col3min else SET @col3len = @col3max
if @col5max < @col5min SET @col5len = @col5min else SET @col5len = @col5max
if @col7max < @col7min SET @col7len = @col7min else SET @col7len = @col7max


PRINT @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm)) + SPACE(@col4len) + @col5nm + SPACE(@col5len-len(@col5nm)) + SPACE(@col6len) + @col7nm + SPACE(@col7len-len(@col7nm))
PRINT REPLICATE('=',@col1len) + SPACE(@col2len) + REPLICATE('=',@col3len) + SPACE(@col4len) + REPLICATE('=',@col5len) + SPACE(@col6len) + REPLICATE('=',@col7len)



DECLARE backupFiles CURSOR FOR 
SELECT ISNULL(UserName,'') AS UserName, ISNULL(UserType,'') AS UserType, ISNULL(StateDesc,'') AS StateDesc, ISNULL(PermName,'') AS PermName FROM #serverpermdummy

OPEN backupFiles 

-- Loop through all the files for the database 
FETCH NEXT FROM backupFiles INTO @usnm, @ustp, @stdsc, @permnm


WHILE @@FETCH_STATUS = 0 
BEGIN 
SET @col1nm = @usnm
SET @col2nm = ''
SET @col3nm = @ustp
SET @col4nm = ''
SET @col5nm = @stdsc
SET @col6nm = ''
SET @col7nm = @permnm
PRINT @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm)) + SPACE(@col4len) + @col5nm + SPACE(@col5len-len(@col5nm)) + SPACE(@col6len) + @col7nm + SPACE(@col7len-len(@col7nm))


FETCH NEXT FROM backupFiles INTO @usnm, @ustp, @stdsc, @permnm
END 

CLOSE backupFiles 
DEALLOCATE backupFiles 


DROP TABLE #serverpermdummy

PRINT ' '
PRINT ' '
PRINT '==========================================================================================================='
PRINT ' Information By Database'
PRINT ' '
PRINT ' '

CREATE TABLE #DummyDBDesc
(	RecID	 int	IDENTITY	NOT NULL,
ServerName	 varchar(128)	NULL,
DBName	 varchar(100)	NULL,
RecoveryModel	 varchar(10)	 NULL,
CompatibilityLevel	varchar(30)	 NULL,
ReadWriteDesc	 varchar(10)	 NULL
)
CREATE TABLE #dummyDBRoles
(	RoleName	varchar(200),
UserName	varchar(200),
UserType	varchar(200)
)
CREATE TABLE #dummyDBUsers
(	UserName	varchar(200),
UserType	varchar(200)
)
INSERT INTO #DummyDBDesc
select CONVERT(varchar(128),@@servername) AS ServerName, CONVERT(varchar(100),name) as DBName, CONVERT(varchar(10),recovery_model_desc) as RecoveryModel,	 --database_id, 
CASE compatibility_level
WHEN 80 THEN CONVERT(varchar(4),compatibility_level) + ' - SQL 2000 *'
WHEN 90 THEN CONVERT(varchar(4),compatibility_level) + ' - SQL 2005'
WHEN 100 THEN CONVERT(varchar(4),compatibility_level) + ' - SQL 2008'
WHEN 105 THEN CONVERT(varchar(4),compatibility_level) + ' - SQL 2008 R2'
WHEN 110 THEN CONVERT(varchar(4),compatibility_level) + ' - SQL 2012'
WHEN 120 THEN CONVERT(varchar(4),compatibility_level) + ' - SQL 2014'
ELSE CONVERT(varchar(4),compatibility_level)
END AS CompatibilityLevel,
CASE is_read_only
WHEN 0 THEN CONVERT(varchar(10),'RW')
ELSE CONVERT(varchar(10),'R')
END as ReadWriteDesc
FROM sys.databases
WHERE name NOT IN('tempdb','master','msdb','model') and name NOT LIKE '%ReportServer%'
--AND name = 'MyDatabase'
ORDER BY name



DECLARE backupFiles CURSOR FOR
SELECT DBName, RecoveryModel, CompatibilityLevel, ReadWriteDesc FROM #DummyDBDesc 
--where DBName = 'SMG_Siniestros'
ORDER BY DBName

OPEN backupFiles 

DECLARE @dbn varchar(100)
DECLARE @rm varchar(10)
DECLARE @cl varchar(30)
DECLARE @rwd varchar(10)


-- Loop through all the files for the database 
FETCH NEXT FROM backupFiles INTO @dbn, @rm, @cl, @rwd 

WHILE @@FETCH_STATUS = 0 
BEGIN 

PRINT 'Database Name : ' + @dbn
PRINT 'Recovery Model : ' + @rm
PRINT 'Compatibility Level: ' + @cl
PRINT 'Read/Write : ' + @rwd
PRINT ' '
PRINT ' '


/* ================================================================================================================================================================= */
/* Database User Information */

--Start with a clean table to load the values
TRUNCATE TABLE #dummyDBUsers

-- Get roles for this database and load into the temp table
SET @cmd = 'USE [' + @dbn + ']; INSERT INTO #dummyDBUsers SELECT CONVERT(varchar(100),name) AS UserName, CONVERT(varchar(100),type_desc) as UserType FROM sys.database_principals WHERE (type = ''S'' OR type = ''U'' OR type = ''G'') AND is_fixed_role = 0 AND (name NOT IN (''guest'',''dbo'',''INFORMATION_SCHEMA'',''sys''))'
--PRINT @cmd
EXEC (@cmd) 

--Get the length of the longest occurance of the columns
SELECT @unmax = ISNULL(MAX(len(UserName)),0) FROM #dummyDBUsers
SELECT @utmax = ISNULL(MAX(len(UserType)),0) FROM #dummyDBUsers

--Set some minimum values so column doesn't print short
if @unmax < 25 SET @unmax = 25
if @utmax < 25 SET @utmax = 25

--Set and print the column headings for the role information
SET @col1nm = 'UserName'
SET @col1len = @unmax
SET @col2nm = ''
SET @col2len = 5
SET @col3nm = 'UserType'
SET @col3len = @utmax
PRINT ' '
PRINT SPACE(10) + @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm)) 
PRINT SPACE(10) + REPLICATE('=',@col1len) + SPACE(@col2len) + REPLICATE('=',@col3len)

DECLARE backupFiles2 CURSOR FOR 
SELECT UserName, UserType FROM #dummyDBUsers ORDER BY UserName

OPEN backupFiles2 
-- Loop through all the files for the database 
FETCH NEXT FROM backupFiles2 INTO @un, @ut

WHILE @@FETCH_STATUS = 0 
BEGIN 
--Set and print the row details for the role information
SET @col1nm = SUBSTRING(@un,1,@unmax)
SET @col3nm = SUBSTRING(@ut,1,@utmax)

PRINT SPACE(10) + @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm)) 

FETCH NEXT FROM backupFiles2 INTO @un, @ut
END 

CLOSE backupFiles2 
DEALLOCATE backupFiles2

PRINT ' '
PRINT ' '

if @includeroleinfo = 1
BEGIN
/* ================================================================================================================================================================= */
/* Role Information */

--Start with a clean table to load the values
TRUNCATE TABLE #dummyDBRoles
-- Get roles for this database and load into the temp table
SET @cmd = 'USE [' + @dbn + ']; INSERT INTO #dummyDBRoles select CONVERT(varchar(200),roles.name) AS RoleName, CONVERT(varchar(200),members.name) AS UserName, CONVERT(varchar(200),members.type_desc) AS UserType from sys.database_principals members inner join sys.database_role_members drm on members.principal_id = drm.member_principal_id inner join sys.database_principals roles on drm.role_principal_id = roles.principal_id where members.name <> ''dbo'' ORDER BY members.name, roles.name'
--PRINT @cmd
EXEC (@cmd) 
-- Now add in any roles that are present in the database that do not have anyone assigned to them (those that are already in the temp table)
SET @cmd = 'USE [' + @dbn + ']; INSERT INTO #dummyDBRoles SELECT CONVERT(varchar(200),name) AS RoleName, ''--none--'' As UserName, '''' AS UserType FROM sys.database_principals database_default WHERE type = ''R'' and is_fixed_role = 0 and name <> ''public'' AND (name NOT IN (SELECT RoleName collate database_default FROM #dummyDBRoles))'
--PRINT @cmd
EXEC (@cmd) 
--Get the length of the longest occurance of the columns
SELECT @rnmax = ISNULL(MAX(len(RoleName)),0) FROM #dummyDBRoles
SELECT @unmax = ISNULL(MAX(len(UserName)),0) FROM #dummyDBRoles
SELECT @utmax = ISNULL(MAX(len(UserType)),0) FROM #dummyDBRoles

--Set some minimum values so column doesn't print short
if @rnmax < 25 SET @rnmax = 25
if @unmax < 25 SET @unmax = 25
if @utmax < 25 SET @utmax = 25

--Set and print the column headings for the role information
SET @col1nm = 'RoleName'
SET @col1len = @rnmax
SET @col2nm = ''
SET @col2len = 5
SET @col3nm = 'UserName'
SET @col3len = @unmax
SET @col4nm = ''
SET @col4len = 5
SET @col5nm = 'UserType'
SET @col5len = @utmax
PRINT ' '
PRINT SPACE(10) + @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm)) + SPACE(@col4len) + @col5nm + SPACE(@col5len-len(@col5nm)) 
PRINT SPACE(10) + REPLICATE('=',@col1len) + SPACE(@col2len) + REPLICATE('=',@col3len) + SPACE(@col4len) + REPLICATE('=',@col5len)

-- Print the script to set the database context
if @outputtype = 2
BEGIN
PRINT 'USE ' + @dbn
PRINT 'GO'
PRINT ' '
END

--statement to get all roles for this database
--SELECT name FROM sys.database_principals WHERE type = 'R' and is_fixed_role = 0 and name <> 'public'
--can use to script the CREATE ROLE statements

-- Now loop through the roles
DECLARE backupFiles2 CURSOR FOR 
SELECT RoleName, UserName, UserType FROM #dummyDBRoles ORDER BY RoleName

OPEN backupFiles2 

-- Loop through all the files for the database 
FETCH NEXT FROM backupFiles2 INTO @rn, @un, @ut 

WHILE @@FETCH_STATUS = 0 
BEGIN 
--Set and print the row details for the role information
SET @col1nm = SUBSTRING(@rn,1,@rnmax)
SET @col3nm = SUBSTRING(@un,1,@unmax)
SET @col5nm = SUBSTRING(@ut,1,@utmax)
if @outputtype = 1
PRINT SPACE(10) + @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm)) + SPACE(@col4len) + @col5nm + SPACE(@col5len-len(@col5nm)) 
if @outputtype = 2
BEGIN
if @col3nm <> '--none--'
PRINT 'exec sp_addrolemember [' + @col1nm + '], [' + @col3nm + '] --Usertype= ' + @col5nm
else
PRINT SPACE(10) + @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm)) + SPACE(@col4len) + @col5nm + SPACE(@col5len-len(@col5nm))
END

FETCH NEXT FROM backupFiles2 INTO @rn, @un, @ut 
END 

CLOSE backupFiles2 
DEALLOCATE backupFiles2

PRINT ' '
PRINT ' '
END


if @includeobjlvlperms = 1
BEGIN
/* ================================================================================================================================================================= */
/* Object-Level Permissions Information */
--Start with a clean table to load the values
TRUNCATE TABLE #dummyDBPerms

-- Get permissions for this database and load into the temp table
-- I'm sure some of this part came from elsewhere. My appologies to the originator.
SET @cmd = 'USE [' + @dbn + ']; INSERT INTO #dummyDBPerms '
SET @cmd = @cmd + 'select p.state_desc, p.permission_name, s.name, o.name, u.name, CASE o.type WHEN ''P'' THEN ''SPROC''
WHEN ''V'' THEN ''View''
WHEN ''U'' THEN ''Table''
WHEN ''FN'' THEN ''Function (scaler)''
WHEN ''TF'' THEN ''Function (table-valued)''
ELSE o.type_desc END AS ObjectType,
CONVERT(varchar(200),u.type_desc) AS UserType
from sys.database_permissions p 
inner join sys.objects o on p.major_id = o.object_id 
inner join sys.schemas s on s.schema_id = o.schema_id 
inner join sys.database_principals u on p.grantee_principal_id = u.principal_id
ORDER BY o.type, o.name collate Latin1_general_CI_AS, u.name collate Latin1_general_CI_AS'
--PRINT @cmd
EXEC (@cmd) 

--Get the length of the longest occurance of each of the columns
SELECT @sdmax = ISNULL(MAX(len(StateDesc)),0) FROM #dummyDBPerms
SELECT @pnmax = ISNULL(MAX(len(PermName)),0) FROM #dummyDBPerms
SELECT @snmax = ISNULL(MAX(len(SchemaName)),0) FROM #dummyDBPerms
SELECT @onmax = ISNULL(MAX(len(ObjectName)),0) FROM #dummyDBPerms
SELECT @unmax = ISNULL(MAX(len(UserName)),0) FROM #dummyDBPerms
SELECT @pdmax = ISNULL(MAX(len(ObjectType)),0) FROM #dummyDBPerms
SELECT @utmax = ISNULL(MAX(len(UserType)),0) FROM #dummyDBPerms

--Set some minimum values so column doesn't print short
if @sdmax < 15 SET @sdmax = 15
if @pnmax < 15 SET @pnmax = 15
if @snmax < 10 SET @snmax = 10
if @onmax < 15 SET @onmax = 15
if @unmax < 15 SET @unmax = 15
if @pdmax < 15 SET @pdmax = 15	 --ObjectType
if @utmax < 15 SET @utmax = 15	 --UserType

--Set and print the column headings for the permissions information
SET @col1nm = 'StateDesc'
SET @col1len = @sdmax
SET @col2nm = ''
SET @col2len = 5
SET @col3nm = 'PermName'
SET @col3len = @pnmax
SET @col4nm = ''
SET @col4len = 5
SET @col5nm = 'Schema'
SET @col5len = @snmax
SET @col6nm = ''
SET @col6len = 5
SET @col7nm = 'Object'
SET @col7len = @onmax
SET @col8nm = ''
SET @col8len = 5
SET @col9nm = 'User'
SET @col9len = @unmax
SET @col10nm = ''
SET @col10len = 5
SET @col11nm = 'ObjectType'
SET @col11len = @pdmax
SET @col12nm = ''
SET @col12len = 5
SET @col13nm = 'UserType'
SET @col13len = @utmax

PRINT ' '
PRINT SPACE(10) + @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm)) + SPACE(@col4len)+ @col5nm + SPACE(@col5len-len(@col5nm)) + SPACE(@col6len)+ @col7nm + SPACE(@col7len-len(@col7nm)) + SPACE(@col8len) + @col9nm + SPACE(@col9len-len(@col9nm)) + SPACE(@col10len) + @col11nm + SPACE(@col11len-len(@col11nm)) + SPACE(@col12len) + @col13nm + SPACE(@col13len-len(@col13nm))
PRINT SPACE(10) + REPLICATE('=',@col1len) + SPACE(@col2len) + REPLICATE('=',@col3len) + SPACE(@col4len) + REPLICATE('=',@col5len) + SPACE(@col6len) + REPLICATE('=',@col7len) + SPACE(@col8len) + REPLICATE('=',@col9len) + SPACE(@col10len) + REPLICATE('=',@col11len) + SPACE(@col12len) + REPLICATE('=',@col13len)

--Loop through the permissions for this database and format and print them
DECLARE backupFiles2 CURSOR FOR 
SELECT StateDesc,PermName,SchemaName,ObjectName,UserName,ObjectType,UserType FROM #dummyDBPerms ORDER BY Schemaname,ObjectName,UserName

OPEN backupFiles2 

-- Loop through all the files for the database 
FETCH NEXT FROM backupFiles2 INTO @sd, @pn, @sn, @on, @un, @pd, @ut

WHILE @@FETCH_STATUS = 0 
BEGIN 
--Set and print the row details for the permissions information
SET @col1nm = SUBSTRING(@sd,1,@sdmax)
SET @col3nm = SUBSTRING(@pn,1,@pnmax)
SET @col5nm = SUBSTRING(@sn,1,@snmax)
SET @col7nm = SUBSTRING(@on,1,@onmax)
SET @col9nm = SUBSTRING(@un,1,@unmax)
SET @col11nm = SUBSTRING(@pd,1,@pdmax)
SET @col13nm = SUBSTRING(@ut,1,@utmax)

--print the detail record for the permissions
if @outputtype = 1
PRINT SPACE(10) + @col1nm + SPACE(@col1len-len(@col1nm)) + SPACE(@col2len) + @col3nm + SPACE(@col3len-len(@col3nm)) + SPACE(@col4len)+ @col5nm + SPACE(@col5len-len(@col5nm)) + SPACE(@col6len)+ @col7nm + SPACE(@col7len-len(@col7nm)) + SPACE(@col8len) + @col9nm + SPACE(@col9len-len(@col9nm)) + SPACE(@col10len) + @col11nm + SPACE(@col11len-len(@col11nm)) + SPACE(@col12len) + @col13nm + SPACE(@col13len-len(@col13nm))
if @outputtype = 2
PRINT @col1nm + ' ' + @col3nm + ' ON [' + @col5nm + '].[' + @col7nm + '] TO [' + @col9nm + '] --ObjectType=' + @col11nm + ' UserType=' + @col13nm


FETCH NEXT FROM backupFiles2 INTO @sd, @pn, @sn, @on, @un, @pd,@ut
END 

CLOSE backupFiles2 
DEALLOCATE backupFiles2

PRINT ' '
PRINT ' '

END
PRINT '==========================================================================================================='

--Get the next database name and info to use in the database loop
FETCH NEXT FROM backupFiles INTO @dbn, @rm, @cl, @rwd 
END 

CLOSE backupFiles 
DEALLOCATE backupFiles 

/* =============================================================================================== */
--Dispose of the temporary tables
DROP TABLE #DummyDBDesc
DROP TABLE #dummyDBRoles
DROP TABLE #dummyDBUsers
DROP TABLE #dummyDBPerms

SET NOCOUNT OFF