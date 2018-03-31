
set nocount on;

create table #LoginPermissions
(
	PrincipalName sysname,
	PermissionName nvarchar(128),
	permissionState nvarchar(60)
)
;

create table #LoginRoles
(
	PrincipalName sysname,
	ServerRoleName sysname
)

--// Get login permissions & role membership
insert into #LoginPermissions
select sp.name,
	p.permission_name,
	p.state_desc
from sys.server_permissions as p
join sys.server_principals as sp on p.grantee_principal_id = sp.principal_id
join sys.database_principals as dp on sp.sid = dp.sid
;

insert into #LoginRoles
select distinct sp.name as principalName,
	rp.name as ServerRoleName
from sys.server_role_members as rm
join sys.server_principals as sp on rm.member_principal_id = sp.principal_id
join sys.database_principals as dp on sp.sid = sp.sid
join sys.server_principals as rp on rm.role_principal_id = rp.principal_id
where sp.name in (select PrincipalName from #LoginPermissions)
;

print '--//Remove logins from roles ahead of recreating the logins.'
--// Generate the remove statements ahead of re-creating the logins.
select 'if exists(select 1 from sys.server_principals where name = ''' + principalName + ''')'+char(10)
	+ 'begin' + char(10)
	+ char(9) + 'alter server role ' + quotename(serverRoleName)
	+ ' drop member ' + quotename(principalName) + ';' + char(10) 
	+ 'end' + char(10)
	+'go' 
from #LoginRoles
;

print '--//Clean up permissions ahead of dropping & recreating logins.'
select 'if exists(select 1 from sys.server_principals where name = ''' + PrincipalName + ''')'+char(10)
	+ 'begin' + char(10)
	+ char(9) + 'revoke ' + p.PermissionName + ' to ' + quotename(PrincipalName) +';' + char(10)
	+ 'end' + char(10)
	+'go' 
from #LoginPermissions as p
;

print '--//Recreate logins in case things like the password have changed.'
print '--//The current logon has been excluded from those captured.'
--// Script to drop and create logins
select 'if exists(select 1 from sys.server_principals where name = ''' + sp.name + ''')'+char(10)
	+ 'begin'+char(10)+char(9)+'drop login ' + QUOTENAME(sp.name) +';'+char(10)+'end' +char(10)+'GO'+char(10)+char(10)
	+ 'create login ' + QUOTENAME(sp.name) + char(10)
	+ char(9) + 'with' + char(10)
	+ char(9) + char(9) +'password = ' + convert(varchar(max),loginproperty(sp.name,'passwordhash'),1)+ ' hashed,' + char(10)
	+ char(9) + char(9) +'sid = ' +convert(varchar(max),sp.sid,1) + ',' + char(10)
	+ char(9) + char(9) +'default_database =' + quotename(sp.default_database_name) + ',' + char(10)
	+ char(9) + char(9) +'default_language =' + quotename(sp.default_language_name) + ',' + char(10)
	+ char(9) + char(9) +'check_expiration = ' + case sl.is_policy_checked when 1 then 'on' else 'off' end + ',' + char(10)
	+ char(9) + char(9) +'check_policy = ' + case sl.is_expiration_checked when 1 then 'on' else 'off' end + char(10)
	+';' + char(10)
	+'go' + char(10)
from sys.server_principals as sp
join sys.database_principals as dp on sp.sid = dp.sid
join sys.sql_logins as sl on sp.sid = sl.sid
where sp.name <> suser_name()
union all
select 'if exists(select 1 from sys.server_principals where name = ''' + sp.name + ''')'+char(10)
	+ 'begin'+char(10)+char(9)+'drop login ' + QUOTENAME(sp.name) +';'+char(10)+'end' +char(10)+'GO'+char(10)+char(10)
	+ 'create login ' + QUOTENAME(sp.name) + char(10)
	+ char(9) + 'from windows' + char(10)
	+ char(9) + 'with' + char(10)
	+ case when sp.default_database_name is not null then (char(9) + char(9) +'default_database =' + quotename(sp.default_database_name) + char(10)) else '' end
	+ case when sp.default_language_name is not null then (',' + char(9) + char(9) +'default_language =' + quotename(sp.default_language_name) + char(10)) else '' end
	+';' + char(10)
	+'go' + char(10)
from sys.server_principals as sp
join sys.database_principals as dp on sp.sid = dp.sid
where sp.type_desc like 'windows%'
	and sp.name <> suser_name()
;

--// Add the permissions back to the logins.
print '--//Setting permissions for Logins.'
select
	case
		when permissionState <> 'GRANT_WITH_GRANT_OPTION' then permissionState
		when permissionState = 'GRANT_WITH_GRANT_OPTION' then 'GRANT'
		else ''
	end + ' '
	+ p.PermissionName + ' to ' + quotename(PrincipalName)
	+ case
		when permissionState = 'GRANT_WITH_GRANT_OPTION' then (' WITH GRANT OPTION;' + char(10))
		else (';' + char(10))
	end
	+'go'
from #LoginPermissions as p
;

print '--//Adding logins to server roles.'
select 'alter server role ' + quotename(serverRoleName)
	+ ' add member ' + quotename(principalName) + ';' + char(10) 
	+'go' 
from #LoginRoles
;

drop table #LoginPermissions;
drop table #LoginRoles;
go