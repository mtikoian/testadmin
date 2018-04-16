/***
================================================================================
Name : p_role_nav.sql
Author : Jason L. van Brackel - 2012-07-06 
Description : Creates object p_role_nav.sql in the database.
===============================================================================
 
Revisions :
--------------------------------------------------------------------------------
Ini|   Date   | Description
--------------------------------------------------------------------------------
JvB	2012-07-06	Created
================================================================================
***/


IF NOT EXISTS(SELECT * 
          FROM sys.database_role_members AS RM 
          JOIN sys.database_principals AS U 
            ON RM.member_principal_id = U.principal_id 
          JOIN sys.database_principals AS R 
            ON RM.role_principal_id = R.principal_id 
          WHERE U.name = N'SEI-DOMAIN-1\NAV_APP_USER' 
            AND R.name = N'p_role_nav')
EXEC dbo.sp_addrolemember @rolename=N'p_role_nav', @membername=N'SEI-DOMAIN-1\NAV_APP_USER'
GO

IF NOT EXISTS(SELECT * 
          FROM sys.database_role_members AS RM 
          JOIN sys.database_principals AS U 
            ON RM.member_principal_id = U.principal_id 
          JOIN sys.database_principals AS R 
            ON RM.role_principal_id = R.principal_id 
          WHERE U.name = N'SEI-DOMAIN-1\NAV_APP_ADMIN' 
            AND R.name = N'p_role_nav')
EXEC dbo.sp_addrolemember @rolename=N'p_role_nav', @membername=N'SEI-DOMAIN-1\NAV_APP_ADMIN'
GO
