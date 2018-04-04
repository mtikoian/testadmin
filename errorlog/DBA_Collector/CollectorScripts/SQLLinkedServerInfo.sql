SET NOCOUNT ON

IF LEFT(CAST(SERVERPROPERTY('ProductVersion') AS varchar(25)), 1) = '8'
	SELECT		S.srvname + '<1>' +
				ISNULL(P.name, 'Login Not Define') + '<2>' +
				CASE 
						WHEN P.name IS NULL THEN 'Unknown' 
						ELSE 
							CASE WHEN P.isntname = 1 THEN 'WINDOWS_LOGIN' ELSE 'SQL_LOGIN' END 
			    END + '<3>' +
				CASE WHEN LS.xstatus = 192 THEN '1' ELSE '0' END + '<4>' +
				ISNULL(LS.name, 'NULL') + '<5>' +
				CASE 
					WHEN P.name IS NOT NULL THEN 'NULL' 
					WHEN LD.xstatus IS NULL THEN 'Not Be Made'
					WHEN LD.xstatus = 64 AND LD.name IS NULL THEN 'Be made without using a security context'
					WHEN LD.xstatus = 192 AND LD.name IS NULL THEN 'Be made using the login''s current security context'
               				ELSE 'Be made using this security context:  ' + LD.name
				END  + '<6>' +
				ISNULL(S.providername, 'NULL') + '<7>' +
				ISNULL(S.datasource, 'NULL') + '<8>' +
				ISNULL(S.location, 'NULL') + '<9>' +
				REPLACE(REPLACE(ISNULL(S.providerstring, 'NULL'), CHAR(10), ' '), CHAR(13), ' ') + '<10>' +
				ISNULL(S.catalog, 'NULL') + '<11>' +
				CAST(S.collationcompatible AS char(1)) + '<12>' +
				CAST(S.dataaccess AS char(1)) + '<13>' +
				CAST(S.isremote AS char(1)) + '<14>' +
				CAST(S.rpc AS char(1)) + '<15>' +
				CAST(S.useremotecollation AS char(1)) + '<16>' +
				ISNULL(S.collation, 'NULL') + '<17>' +
				CAST(S.connecttimeout AS varchar(10)) + '<18>' +
				CAST(S.querytimeout AS varchar(10))
	FROM		master.dbo.sysservers S
					JOIN master.dbo.sysxlogins LS ON S.srvid = LS.srvid
					JOIN master.dbo.syslogins P ON LS.sid = P.sid
					LEFT JOIN (
									SELECT		srvid
												,name
												,xstatus
									FROM		master.dbo.sysxlogins
									WHERE		sid IS NULL
							   ) LD ON S.srvid = LD.srvid
	WHERE		S.srvid <> 0
ELSE
	SELECT		S.name + '<1>' +
				ISNULL(P.name, 'Login Not Define') + '<2>' +
				ISNULL(P.type_desc COLLATE DATABASE_DEFAULT, 'Unknown')  + '<3>' +
				CAST(LS.uses_self_credential AS char(1)) + '<4>' +
				ISNULL(LS.remote_name, 'NULL')  + '<5>' +
				CASE 
					WHEN P.name IS NOT NULL THEN 'NULL' 
					WHEN LD.uses_self_credential IS NULL THEN 'Not Be Made'
					WHEN LD.uses_self_credential = 0 AND LD.remote_name IS NULL THEN 'Be made without using a security context'
					WHEN LD.uses_self_credential = 1 AND LD.remote_name IS NULL THEN 'Be made using the login''s current security context'
					ELSE 'Be made using this security context:  ' + LD.remote_name
				END + '<6>' +
				ISNULL(S.provider, 'NULL') + '<7>' +
				ISNULL(S.data_source, 'NULL') + '<8>' +
				ISNULL(S.location, 'NULL') + '<9>' +
				REPLACE(REPLACE(ISNULL(S.provider_string, 'NULL'), CHAR(10), ' '), CHAR(13), ' ') + '<10>' +
				ISNULL(S.catalog, 'NULL') + '<11>' +
				CAST(S.is_collation_compatible AS char(1)) + '<12>' +
				CAST(S.is_data_access_enabled AS char(1)) + '<13>' +
				CAST(S.is_remote_login_enabled AS char(1)) + '<14>' +
				CAST(S.is_rpc_out_enabled AS char(1)) + '<15>' +
				CAST(S.uses_remote_collation AS char(1)) + '<16>' +
				ISNULL(S.collation_name, 'NULL') + '<17>' +
				CAST(S.connect_timeout AS varchar(10)) + '<18>' + 
				CAST(S.query_timeout AS varchar(10)) 
	FROM		master.sys.servers S
					JOIN master.sys.linked_logins LS ON S.server_id = LS.server_id
					LEFT JOIN master.sys.server_principals P ON LS.local_principal_id = P.principal_id
					LEFT JOIN (
									SELECT		server_id
												,uses_self_credential
												,remote_name
									FROM		master.sys.linked_logins
									WHERE		local_principal_id = 0
							   ) LD ON S.server_id = LD.server_id
	WHERE		S.server_id <> 0
