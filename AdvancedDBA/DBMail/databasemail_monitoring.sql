DECLARE @days_ago_start INT

---------------------------------------------------------------------------------------

SET @days_ago_start = 7

---------------------------------------------------------------------------------------

SELECT  fi.send_request_date AS send_date,
        fi.send_request_user AS send_user,
        fi.recipients,
        fi.copy_recipients,
        fi.blind_copy_recipients,
        fi.[subject],
        fi.body,
        fi.sent_status,
        p.name AS profile_name,
        fi.body_format,
        fi.importance,
        fi.sensitivity,
        fi.file_attachments,
        fi.attachment_encoding,
        fi.query,
        fi.execute_query_database,
        fi.attach_query_result_as_file,
        fi.query_result_header,
        fi.query_result_width,
        fi.query_result_separator,
        fi.exclude_query_output,
        fi.append_query_error,
        fi.sent_account_id,
        fi.sent_date,
        fi.last_mod_date,
        fi.last_mod_user,
        fi.mailitem_id
FROM    msdb.dbo.sysmail_faileditems fi
        JOIN msdb.dbo.sysmail_profile p ON fi.profile_id = p.profile_id
WHERE   fi.send_request_date > DATEADD(day, -@days_ago_start, GETDATE())
ORDER BY fi.send_request_date ;

--SELECT * FROM msdb.dbo.sysmail_log WHERE mailitem_id IN (9265, 9303)

-- failed message log
SELECT  l.[description] AS log_description,
        mi.recipients,
        mi.copy_recipients,
        mi.blind_copy_recipients,
        mi.[subject],
        mi.body,
        mi.body_format,
        mi.importance,
        mi.sensitivity,
        mi.append_query_error,
        mi.send_request_date,
        mi.send_request_user,
        mi.sent_account_id,
        CASE mi.sent_status
          WHEN 0 THEN 'unsent'
          WHEN 1 THEN 'sent'
          WHEN 3 THEN 'retrying'
          ELSE 'failed'
        END AS sent_status,
        mi.sent_date,
        mi.last_mod_date,
        mi.last_mod_user,
        N'EXEC msdb.dbo.sp_send_dbmail @profile_name=''' + p.name + N''',@recipients=''' + mi.recipients + N''',@subject=''' + mi.[subject]
        + N''',@body_format=''' + mi.body_format + N''',@body=''' + mi.body + N'''' AS resend_exec
FROM    msdb.dbo.sysmail_mailitems mi
        JOIN msdb.dbo.sysmail_log l ON mi.mailitem_id = l.mailitem_id
        JOIN msdb.dbo.sysmail_profile p ON mi.profile_id = p.profile_id
WHERE   mi.send_request_date > DATEADD(day, -@days_ago_start, GETDATE())
        AND mi.sent_status NOT IN (1, 3)
ORDER BY mi.send_request_date DESC ;

--SELECT TOP 10
--        *
--FROM    msdb.dbo.sysmail_log
--WHERE   log_date > DATEADD(day, -1, GETDATE())
--ORDER BY log_date DESC