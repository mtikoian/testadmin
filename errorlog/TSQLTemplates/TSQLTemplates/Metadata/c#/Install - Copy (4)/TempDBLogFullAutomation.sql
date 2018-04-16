DECLARE @log_used_percent FLOAT;
DECLARE @log_reuse_wait_desc VARCHAR(256);
DECLARE @msg_body NVARCHAR(MAX);
DECLARE @oldest_spid INT;
DECLARE @profile_name SYSNAME;

DECLARE @opentran TABLE 
(
	tempdb VARCHAR(50),
	opentran VARCHAR(256)
);

DECLARE @logspace TABLE
(
	DatabaseName SYSNAME,
	LogSize FLOAT,
	LogUsed FLOAT,
	Status INT
);

SET NOCOUNT ON;

-- Get log used percent to determine if alerting is required --
INSERT @logspace (DatabaseName,LogSize,LogUsed,Status)
EXEC ('DBCC SQLPERF(LOGSPACE) WITH NO_INFOMSGS');

SELECT	@log_used_percent = LogUsed
FROM	@logspace
WHERE	DatabaseName = 'tempdb';

IF @log_used_percent > 75 BEGIN

	SET @msg_body = '------------------------------------------------------------------' + CHAR(10) +
					'------------------ TEMPDB Transaction Log Alert ------------------' + CHAR(10) +
					'------------------------------------------------------------------' + CHAR(10) +
					'' + CHAR(10) +
					'WARNING: the TEMPDB transaction log is at critical state for server "' + @@SERVERNAME + '".' + CHAR(10) +
					'This requires immediate attention to prevent an outage.' + CHAR(10) + CHAR(10) +
					'The log is currently at ' + CAST(@log_used_percent AS VARCHAR) + ' percent full.' + CHAR(10);

	
	-- Determine what's causing the log to not truncate
	SELECT @log_reuse_wait_desc = log_reuse_wait_desc FROM sys.databases WHERE name = 'tempdb';
	SET @msg_body = @msg_body + 'Reason the log is not truncating: ' + @log_reuse_wait_desc + CHAR(10);


	IF @log_reuse_wait_desc = 'ACTIVE_TRANSACTION' BEGIN

		-- Get information about the oldest SPID with an open transaction
		INSERT @opentran (tempdb, opentran)
		EXEC('dbcc opentran(tempdb) with tableresults,no_infomsgs');
		
		SELECT	@oldest_spid = opentran
		FROM	@opentran
		WHERE	tempdb = 'oldact_spid';
		
		SELECT	@msg_body = @msg_body +
				'----------------------------------------' + CHAR(10) +
				'The transaction log is not truncating because the session below is holding an open transaction. ' +
				'If possible, contact the user based on the information below (using the IP address to locate a machine name, for example). ' +
				'Once the user has been contacted, as them to commit their open transaction or close their open application. ' +
				'If this is not immediately possible, such as the user not understanding how to do this or claiming they do not have ' +
				'any open transactions, run a KILL(SPID) command immediately to kill the offending SPID (replace SPID in the KILL statement ' +
				'with the number of the SPID shown below.' + CHAR(10) +
				'' + CHAR(10) +
				'SPID: ' + CAST(@oldest_spid AS VARCHAR)  + CHAR(10) +
				'Host Name: ' + ISNULL(desess.host_name,'Unknown')  + CHAR(10) +
				'Login Name: ' + desess.login_name  + CHAR(10) +
				'Client IP Address: ' + deconn.client_net_address + CHAR(10) +
				'Request Start: ' + CAST(ISNULL(dereq.start_time,'1-1-1900') AS VARCHAR)  + CHAR(10) +
				'Full SQL Text ' + CHAR(10) +
				'--------------' + CHAR(10) +
				ISNULL(dest.text,'Unknown') + CHAR(10) +
				'--------------' + CHAR(10)
		FROM	sys.dm_exec_sessions desess
					LEFT JOIN sys.dm_exec_requests dereq
						ON desess.session_id = dereq.session_id
					INNER JOIN sys.dm_exec_connections deconn
						ON desess.session_id = deconn.session_id
					OUTER APPLY sys.dm_exec_sql_text(dereq.plan_handle) dest
		WHERE	desess.session_id = @oldest_spid;
		
	END
	ELSE BEGIN
		
		SET @msg_body = @msg_body + CHAR(10) +
						'Please see BOL article at "http://msdn.microsoft.com/en-us/library/ms345414.aspx" for details on this type of wait.';
						
	END
	

	EXEC msdb.dbo.sp_notify_operator @profile_name = 'EDEV_DBA_Profile',
									 @name = 'MSXOperator',
									 @subject = 'TempDB Log Full Alert',
									 @body = @msg_body;
	
END