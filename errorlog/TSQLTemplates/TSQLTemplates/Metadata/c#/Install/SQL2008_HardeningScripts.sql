/* 
   *******************************************************************************
    ENVIRONMENT:    SQL 2008

	NAME:           SQL2008_HARDENINGSCRIPT.SQL

    DESCRIPTION:    THIS SCRIPT HARDEN SQL SERVER 2008 BASED ON WHAT GUARDIUM
                    CHECKS FOR.  THIS SCRIPT IS ONLY TO BE USED AS FOR SQL 2008
                    STRAIGHT OUT OF THE BOX.  THIS DOESN'T HARDEN USER DEFINE
                    DATABASES.  THE FOLLOWING ARE THE GUARDIUM TEST THAT IT
                    HARDENS/REMEIDATES
                    
                        *  143 - NO PUBLIC ACCESS TO AGENT JOB CONTROL PROCEDURES
                        *  150 - WINDOWS ADMIN IS NOT IMPLICIT MS SQL ADMIN
                        *  152 - NO SP_MSSETALERTINFO ACCESS
                        *  205 - SQL OLEDB DISABLED (DISALLOWEDADHOCACCESS REGISTRY KEY)
                        *  210 - NO ACCESS TO GENERAL EXTENDED PROCEDURES
                        * 2001 - DISABLE CLR OPTION FOR MSSQL 2005 AND ABOVE
                        * 2002 - DISABLE SQL MAIL USE UNLESS NEEDED FOR MSSQL 2005 AND ABOVE
                        * 2005 - RENAME SA ACCOUNT FOR MSSQL 2005 AND ABOVE
                        * 2006 - DISABLE REMOTE ADMIN CONNECTIONS OPTION FOR MSSQL 2005 AND ABOVE
                        * 2010 - DISABLE AD HOC DISTRIBUTED QUERIES OPTION FOR MSSQL 2005 AND ABOVE
                        * 2011 - DISABLE XP_CMDSHELL OPTION FOR MSSQL 2005 AND ABOVE                        
                    
                    THIS SCRIPT WILL ALSO ADD YOUR WDBS DBA GROUP ACCOUNTS, W9_SQL_DBA & W9_SQL_DBA_AD.
                    
                    
    AUTHOR         DATE       VERSION  DESCRIPTION
    -------------- ---------- -------- ------------------------------------------

   *******************************************************************************
*/
USE [msdb]
GO
-- GUARDIUM TEST 143
REVOKE EXECUTE ON [dbo].[sp_add_job] TO [public] CASCADE;
REVOKE EXECUTE ON [dbo].[sp_add_jobserver] TO [public] CASCADE;
REVOKE EXECUTE ON [dbo].[sp_add_jobstep] TO [public] CASCADE;
REVOKE EXECUTE ON [dbo].[sp_start_job] TO [public] CASCADE;
GO
USE [master]
GO
EXECUTE sp_configure 'show advanced options', 1
RECONFIGURE
GO
IF NOT EXISTS(SELECT * FROM sys.server_principals WHERE UPPER(name) = 'US\W9_SQL_DBA')
	CREATE LOGIN [US\W9_SQL_DBA] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO
EXECUTE master..sp_addsrvrolemember @loginame = N'US\W9_SQL_DBA', @rolename = N'sysadmin'
GO
IF NOT EXISTS(SELECT * FROM sys.server_principals WHERE UPPER(name) = 'US\W9_SQL_DBA_AD')
	CREATE LOGIN [US\W9_SQL_DBA_AD] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO
EXECUTE master..sp_addsrvrolemember @loginame = N'US\W9_SQL_DBA_AD', @rolename = N'sysadmin'
GO
-- GUARDIUM TEST 150
DECLARE @Message	varchar(512)

IF NOT EXISTS(
                SELECT      * 
                FROM        sys.server_principals A 
                                JOIN sys.server_role_members B ON A.principal_id = B.member_principal_id 
                                JOIN sys.server_principals C ON B.role_principal_id = C.principal_id 
                WHERE       UPPER(A.name) = 'US\W9_SQL_DBA_AD' 
                  AND       C.name = 'sysadmin'
            )
	BEGIN
		SET @Message = 'BUILTIN\Administrators account cannot be removed, the US\W9_SQL_DBA_AD account does not exist or does not have sysadmin access.  Please add this group account manually and remove BUILTIN\Administrators.'
		
		RAISERROR (@Message, 18, 1)
	END
ELSE
	 BEGIN
		IF EXISTS(SELECT * FROM sys.server_principals WHERE UPPER(name) = 'BUILTIN\ADMINISTRATORS')
			DROP LOGIN [BUILTIN\Administrators]
			--EXECUTE master..sp_dropsrvrolemember @loginame = N'BUILTIN\Administrators', @rolename = N'sysadmin'
	END
GO
-- GUARDIUM TEST 152
REVOKE EXECUTE ON [sp_MSsetalertinfo] TO [public] CASCADE;
GO
-- GUARDIUM TEST 205
DECLARE @ProviderName	varchar(128)

CREATE TABLE #OLEDBProv 
(
		ProviderName varchar(128) NOT NULL
		,ParseName varchar(50) NOT NULL
		,Description varchar(255) NOT NULL 
) 

INSERT INTO #OLEDBProv 
EXECUTE master.dbo.xp_enum_oledb_providers

CREATE TABLE #OLEDBProp
(
	provider_name			varchar(128)
	,allow_in_process		bit
	,disallow_adhoc_access	bit
	,dynamic_parameters		bit
	,index_as_access_path	bit
	,level_zero_only		bit
	,nested_queries			bit
	,non_transacted_updates bit
	,sql_server_like		bit
) 

DECLARE CURSOR_PROVIDER CURSOR FAST_FORWARD
FOR
	SELECT		RTRIM(ProviderName)
	FROM		#OLEDBProv
	ORDER BY	ProviderName

OPEN CURSOR_PROVIDER
 
FETCH NEXT FROM CURSOR_PROVIDER 
INTO @ProviderName 

WHILE @@FETCH_STATUS = 0
BEGIN 
	INSERT INTO #OLEDBProp 
	(
			provider_name
			,allow_in_process
			,disallow_adhoc_access
			,dynamic_parameters
			,index_as_access_path
			,level_zero_only
			,nested_queries
			,non_transacted_updates
			,sql_server_like
	) 
	EXECUTE master.dbo.sp_MSset_oledb_prop @ProviderName

	FETCH NEXT FROM CURSOR_PROVIDER 
	INTO @ProviderName 
END 

CLOSE CURSOR_PROVIDER 
DEALLOCATE CURSOR_PROVIDER

DECLARE CURSOR_PROVIDER CURSOR FAST_FORWARD
FOR
	SELECT		provider_name
	FROM		#OLEDBProp
	WHERE		disallow_adhoc_access = 0
	ORDER BY	provider_name

OPEN CURSOR_PROVIDER
 
FETCH NEXT FROM CURSOR_PROVIDER 
INTO @ProviderName 

WHILE @@FETCH_STATUS = 0
BEGIN 
	EXECUTE master.dbo.sp_MSset_oledb_prop @ProviderName , N'DisallowAdHocAccess', 1

	FETCH NEXT FROM CURSOR_PROVIDER 
	INTO @ProviderName 
END 

CLOSE CURSOR_PROVIDER 
DEALLOCATE CURSOR_PROVIDER

DROP TABLE #OLEDBProv
DROP TABLE #OLEDBProp
GO
-- GUARDIUM TEST 210
REVOKE EXECUTE ON [sys].[xp_cmdshell] TO [public] CASCADE;
REVOKE EXECUTE ON [sys].[xp_dirtree] TO [public] CASCADE;
REVOKE EXECUTE ON [sys].[xp_enumerrorlogs] TO [public] CASCADE;
REVOKE EXECUTE ON [sys].[xp_enumgroups] TO [public] CASCADE;
REVOKE EXECUTE ON [sys].[xp_fixeddrives] TO [public] CASCADE;
REVOKE EXECUTE ON [sys].[xp_getnetname] TO [public] CASCADE;
REVOKE EXECUTE ON [sys].[xp_logevent] TO [public] CASCADE;
REVOKE EXECUTE ON [sys].[xp_loginconfig] TO [public] CASCADE;
REVOKE EXECUTE ON [sys].[xp_msver] TO [public] CASCADE;
REVOKE EXECUTE ON [sys].[xp_readerrorlog] TO [public] CASCADE;
REVOKE EXECUTE ON [sys].[xp_servicecontrol] TO [public] CASCADE;
REVOKE EXECUTE ON [sys].[xp_sprintf] TO [public] CASCADE;
REVOKE EXECUTE ON [sys].[xp_sscanf] TO [public] CASCADE;
REVOKE EXECUTE ON [sys].[xp_subdirs] TO [public] CASCADE;
GO
-- GUARDIUM TEST 2001
EXECUTE sp_configure 'clr enabled', 0
RECONFIGURE
GO
-- GUARDIUM TEST 2002
EXECUTE sp_configure 'SQL Mail XPs', 0
RECONFIGURE
GO
-- GUARDIUM TEST 2005
ALTER LOGIN [sa] WITH NAME = [ssaid]
GO
-- GUARDIUM TEST 2006
EXECUTE sp_configure 'remote admin connections', 0
RECONFIGURE
GO
-- GUARDIUM TEST 2010
EXECUTE sp_configure 'Ad Hoc Distributed Queries', 0
RECONFIGURE
GO
-- GUARDIUM TEST 2011
EXECUTE sp_configure 'xp_cmdshell', 0
RECONFIGURE
GO
-- ADD MO-AOC_MSSQL ACCOUNT
CREATE LOGIN [US\MO-AOC_MSSQL] FROM WINDOWS
WITH DEFAULT_DATABASE = master,
     DEFAULT_LANGUAGE = us_english
go
EXECUTE sp_addsrvrolemember 'US\MO-AOC_MSSQL', 'securityadmin'
GO
GRANT CONNECT SQL TO [US\MO-AOC_MSSQL]
GO

