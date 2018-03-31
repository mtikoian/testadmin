/* check session existence */
DECLARE @SessionName VARCHAR(64) = 'BackupThroughput';
 
SELECT sn.SessionName
	, CASE WHEN ISNULL(es.name,'No') = 'No'
		THEN 'NO'
		ELSE 'YES'
		END AS XESessionExists
	, CASE WHEN ISNULL(xe.name,'No') = 'No'
		THEN 'NO'
		ELSE 'YES'
		END AS XESessionRunning
	FROM (SELECT @SessionName AS SessionName) sn
		LEFT OUTER JOIN sys.server_event_sessions es
			ON sn.SessionName = es.name
		LEFT OUTER JOIN sys.dm_xe_sessions xe
			ON es.name = xe.name
	;

GO

/* V2 Session Check */
DECLARE @SessionName VARCHAR(128) = NULL --'sp_server_diagnostics session' --NULL for all
;

SELECT ISNULL(ses.name,xse.name) AS SessionName
		, CASE
			WHEN ISNULL(ses.name,'') = ''
			THEN 'Private'
			ELSE 'Public'
			END AS SessionVisibility
		, CASE
			WHEN ISNULL(xse.name,'') = ''
			THEN 'NO'
			ELSE 'YES'
			END AS SessionRunning
		, CASE
			WHEN ISNULL(xse.name,'') = ''
				AND ISNULL(ses.name,'') = ''
			THEN 'NO'
			ELSE 'YES'
			END AS IsDeployed
	FROM sys.server_event_sessions ses
	FULL OUTER JOIN sys.dm_xe_sessions xse
		ON xse.name =ses.name
	WHERE COALESCE(@SessionName, ses.name, xse.name) = ISNULL(ses.name, xse.name)
	ORDER BY ses.event_session_id;

/* explore current sessions */

--see all available "server" sessions that are not hidden
SELECT *
	FROM sys.server_event_sessions es;
GO

--hidden / "internal" sessions
SELECT *
	FROM sys.dm_xe_sessions xe
	WHERE session_source = 'internal';

--note hekaton session, server_diag session, and server security audits

/* ? Security Audits ? */

SELECT sas.event_session_address, xe.name as XEName, sa.name as AuditName,sas.audit_file_path,sas.status_desc
		,xe.session_source
	FROM sys.server_audits sa
		INNER JOIN sys.dm_server_audit_status sas
			ON sa.audit_id = sas.audit_id
		INNER JOIN sys.dm_xe_sessions xe
			ON xe.address = sas.event_session_address;
GO