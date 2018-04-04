DECLARE	@TableHTML NVARCHAR(MAX),
		@MessageBody NVARCHAR(MAX),
		@XMLQuery XML,
		@XMLOut XML,
		@SQL NVARCHAR(MAX);

CREATE TABLE #tmpWhoIsActive ( [dd hh:mm:ss.mss] varchar(15) NULL,[session_id] smallint NOT NULL,[status] varchar(30) NOT NULL,[host_name] nvarchar(128) NULL,[database_name] nvarchar(128) NULL,[reads] varchar(30) NULL,[reads_delta] varchar(30) NULL,[physical_reads] varchar(30) NULL,[physical_reads_delta] varchar(30) NULL,[writes] varchar(30) NULL,[writes_delta] varchar(30) NULL,[sql_command] xml NULL,[sql_text] xml NULL)

exec sp_whoisactive 
		@delta_interval = 30,
		@output_column_list = '[dd%][session_id][status][host_name][database_name][reads][reads_delta][physical_reads][physical_reads_delta][writes][writes_delta][sql_command][sql_text]',
		@show_sleeping_spids = 2,
		@sort_order = '[reads_delta] DESC, [reads] DESC',
		@get_outer_command = 1,
		@destination_table = '#tmpWhoIsActive';

select @TableHTML = '<table border="1"><tr style="background-color:#808080;">' +
(
	select	name "TH"
	from	tempdb.sys.columns 
	where	object_id = object_id('tempdb..#tmpWhoIsActive')
	for xml path('')
) + '</tr>';

SELECT @XMLQuery =  
(
	select	QUOTENAME(name) + ' AS "TD", '''', ' + CHAR(10)
	from	tempdb.sys.columns 
	where	object_id = object_id('tempdb..#tmpWhoIsActive')
	for xml path('')
);

SELECT @SQL = 'SELECT @XMLOut = (SELECT TOP 5 ' +
			  SUBSTRING(@XMLQuery.value('.','NVARCHAR(MAX)'),1,LEN(@XMLQuery.value('.','NVARCHAR(MAX)'))-3) +
			  ' FROM #tmpWhoIsActive ORDER BY [reads_delta] DESC, [reads] DESC FOR XML PATH(''tr''))';

EXEC sp_executesql @SQL, N'@XMLOut XML OUTPUT', @XMLOut = @XMLOut OUTPUT;


SELECT @TableHTML = @TableHTML + CONVERT(VARCHAR(MAX),@XMLOut) + '</table>';

exec msdb.dbo.sp_send_dbmail
	@recipients = 'jfeierman@seic.com',
	@body = @TableHTML,
	@body_format = 'HTML',
	@profile_name = 'EDEV_DBA_Profile',
	@subject = '!!ALERT!! High IO Condition Detected on CTCSQL2005',
	@importance = 'High';

drop table #tmpWhoIsActive;
		

