SET NOCOUNT ON

SELECT		J.name + '<1>' + 
				S.name + '<2>' + 
				REPLACE(
						REPLACE(
									CASE S.freq_type
										WHEN   1 THEN 'Start on ' + SUBSTRING(CAST(active_start_date AS varchar(8)), 5, 2) + '/' + RIGHT(active_start_date, 2) + '/' + LEFT(active_start_date , 4) + ' ' + 
																		LEFT(REPLICATE('0', 6 - LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 2) + ':' +
																			SUBSTRING(REPLICATE('0', 6-LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 3, 2) + ':' + 
																			RIGHT(REPLICATE('0', 6-LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 2)

										WHEN   4 THEN 'Occurs every ' + CAST(freq_interval AS varchar(10)) + ' day(s)' 
										WHEN   8 THEN 'Occurs every ' + CAST(freq_recurrence_factor AS varchar(10)) + ' week(s) on ' +
																			CASE WHEN freq_interval &  1 = 1 	THEN 'Sunday, ' 	ELSE '' END +
																			CASE WHEN freq_interval &  2 = 2 	THEN 'Monday, ' 	ELSE '' END +
																			CASE WHEN freq_interval &  4 = 4 	THEN 'Tuesday, ' 	ELSE '' END +
																			CASE WHEN freq_interval &  8 = 8 	THEN 'Wednesday, '	ELSE '' END +
																			CASE WHEN freq_interval & 16 = 16	THEN 'Thursday, ' 	ELSE '' END +
																			CASE WHEN freq_interval & 32 = 32	THEN 'Friday, ' 	ELSE '' END +
																			CASE WHEN freq_interval & 64 = 64	THEN 'Saturday, ' 	ELSE '' END								
										WHEN  16 THEN 'Occurs every ' + CAST(freq_recurrence_factor AS varchar(10)) + ' month(s) on day ' +
																		CAST(freq_interval AS varchar(10)) + ' of that month'
										WHEN  32 THEN 'Occurs every ' + CAST(freq_recurrence_factor AS varchar(10)) + ' month(s) on the ' +
																			CASE freq_relative_interval 
																				WHEN  1 THEN 'First'
																				WHEN  2 THEN 'Second'
																				WHEN  4 THEN 'Third'
																				WHEN  8 THEN 'Fourth'
																				WHEN 16 THEN 'Last'
																				ELSE 'N/A'
																			END + ' ' +
																			CASE freq_interval
																				WHEN 1 THEN 'Sunday'
																				WHEN 2 THEN 'Monday'
																				WHEN 3 THEN 'Tuesday'
																				WHEN 4 THEN 'Wednesday'
																				WHEN 5 THEN 'Thursday'
																				WHEN 6 THEN 'Friday'
																				WHEN 7 THEN 'Saturday'
																				WHEN 8 THEN 'Day'
																				WHEN 9 THEN 'Weekday'
																				WHEN 10 THEN 'Weekend Day'
																				ELSE ''
																			END
										WHEN  64 THEN 'Start automatically when SQL Server Agent Starts'
										WHEN 128 THEN 'Start whenever CPU(s) becomes idle'
										ELSE 'N/A'
									END +
									CASE freq_subday_type
										WHEN 1 THEN ', at ' + LEFT(REPLICATE('0', 6 - LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 2) + ':' +
																SUBSTRING(REPLICATE('0', 6-LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 3, 2) + ':' + 
																RIGHT(REPLICATE('0', 6-LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 2)
										WHEN 2 THEN ', every ' + CAST(freq_subday_interval AS varchar(10)) + ' second(s) between ' + LEFT(REPLICATE('0', 6 - LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 2) + ':' +
																SUBSTRING(REPLICATE('0', 6-LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 3, 2) + ':' + 
																RIGHT(REPLICATE('0', 6-LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 2)
																	+ ' and ' + 
																			LEFT(REPLICATE('0', 6 - LEN(CAST(active_end_time AS varchar(6)))) + CAST(active_end_time AS varchar(6)), 2) + ':' +
																			SUBSTRING(REPLICATE('0', 6-LEN(CAST(active_end_time AS varchar(6)))) + CAST(active_end_time AS varchar(6)), 3, 2) + ':' + 
																			RIGHT(REPLICATE('0', 6-LEN(CAST(active_end_time AS varchar(6)))) + CAST(active_end_time AS varchar(6)), 2)
										WHEN 4 THEN ', every ' + CAST(freq_subday_interval AS varchar(10)) + ' minute(s) between ' + LEFT(REPLICATE('0', 6 - LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 2) + ':' +
																SUBSTRING(REPLICATE('0', 6-LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 3, 2) + ':' + 
																RIGHT(REPLICATE('0', 6-LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 2)
																	+ ' and ' + 
																			LEFT(REPLICATE('0', 6 - LEN(CAST(active_end_time AS varchar(6)))) + CAST(active_end_time AS varchar(6)), 2) + ':' +
																			SUBSTRING(REPLICATE('0', 6-LEN(CAST(active_end_time AS varchar(6)))) + CAST(active_end_time AS varchar(6)), 3, 2) + ':' + 
																			RIGHT(REPLICATE('0', 6-LEN(CAST(active_end_time AS varchar(6)))) + CAST(active_end_time AS varchar(6)), 2)
										WHEN 8 THEN ', every ' + CAST(freq_subday_interval AS varchar(10)) + ' hour(s) between ' + LEFT(REPLICATE('0', 6 - LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 2) + ':' +
																SUBSTRING(REPLICATE('0', 6-LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 3, 2) + ':' + 
																RIGHT(REPLICATE('0', 6-LEN(CAST(active_start_time AS varchar(6)))) + CAST(active_start_time AS varchar(6)), 2)
																	+ ' and ' + 
																			LEFT(REPLICATE('0', 6 - LEN(CAST(active_end_time AS varchar(6)))) + CAST(active_end_time AS varchar(6)), 2) + ':' +
																			SUBSTRING(REPLICATE('0', 6-LEN(CAST(active_end_time AS varchar(6)))) + CAST(active_end_time AS varchar(6)), 3, 2) + ':' + 
																			RIGHT(REPLICATE('0', 6-LEN(CAST(active_end_time AS varchar(6)))) + CAST(active_end_time AS varchar(6)), 2)

										ELSE 'N/A'
									END, ', ,', ','
						), ', at', ' at'
				) + '<3>' +
				CASE S.freq_type
					WHEN 1	THEN 'One Time'
					WHEN 64	THEN 'Start automatically when SQL Server Agent Starts'
					WHEN 128 THEN 'Start whenever CPU(s) becomes idle'
					ELSE 'Recurring'
				END + '<4>' +
				CASE WHEN S.freq_type IN (64, 128)
					THEN 'NULL'
					ELSE
						SUBSTRING(CAST(active_start_date AS varchar(8)), 5, 2) + 
							'/' + RIGHT(active_start_date, 2) + '/' + 
							LEFT(active_start_date , 4) + ' ' + 
							LEFT(REPLICATE('0', 6 - LEN(CAST(active_start_time AS varchar(6)))) + 
							CAST(active_start_time AS varchar(6)), 2) + ':' +
							SUBSTRING(REPLICATE('0', 6-LEN(CAST(active_start_time AS varchar(6)))) + 
							CAST(active_start_time AS varchar(6)), 3, 2) + ':' + 
							RIGHT(REPLICATE('0', 6-LEN(CAST(active_start_time AS varchar(6)))) + 
							CAST(active_start_time AS varchar(6)), 2)	
				END  + '<5>' +
				CASE WHEN S.freq_type IN (64, 128)
					THEN 'NULL'
					ELSE
						LEFT(REPLICATE('0', 6 - LEN(CAST(active_start_time AS varchar(6)))) + 
							CAST(active_start_time AS varchar(6)), 2) + ':' +
							SUBSTRING(REPLICATE('0', 6-LEN(CAST(active_start_time AS varchar(6)))) + 
							CAST(active_start_time AS varchar(6)), 3, 2) + ':' + 
							RIGHT(REPLICATE('0', 6-LEN(CAST(active_start_time AS varchar(6)))) + 
							CAST(active_start_time AS varchar(6)), 2)	
				 END  + '<6>' +
				 CASE WHEN S.freq_type IN (1, 64, 128)
					THEN 'NULL'
					ELSE
						SUBSTRING(CAST(active_end_date AS varchar(8)), 5, 2) + 
						'/' + RIGHT(active_end_date, 2) + '/' + 
						LEFT(active_end_date , 4) + ' ' + 
						LEFT(REPLICATE('0', 6 - LEN(CAST(active_end_time AS varchar(6)))) + 
						CAST(active_end_time AS varchar(6)), 2) + ':' +
						SUBSTRING(REPLICATE('0', 6-LEN(CAST(active_end_time AS varchar(6)))) + 
						CAST(active_end_time AS varchar(6)), 3, 2) + ':' + 
						RIGHT(REPLICATE('0', 6-LEN(CAST(active_end_time AS varchar(6)))) + 
						CAST(active_end_time AS varchar(6)), 2)	
				 END + '<7>' +
				 CASE WHEN S.freq_type IN (1, 64, 128)
					THEN 'NULL'
					ELSE
						LEFT(REPLICATE('0', 6 - LEN(CAST(active_end_time AS varchar(6)))) + 
						CAST(active_end_time AS varchar(6)), 2) + ':' +
						SUBSTRING(REPLICATE('0', 6-LEN(CAST(active_end_time AS varchar(6)))) + 
						CAST(active_end_time AS varchar(6)), 3, 2) + ':' + 
						RIGHT(REPLICATE('0', 6-LEN(CAST(active_end_time AS varchar(6)))) + 
						CAST(active_end_time AS varchar(6)), 2)	
				 END  + '<8>' +
				 CASE 
					WHEN S.freq_type = 4 THEN 'Daily'
					WHEN S.freq_type = 8 THEN 'Weekly'
					WHEN S.freq_type IN (16, 32) THEN 'Monthly'
					ELSE 'NULL'
				 END + '<9>' +
				 CAST(
						CASE 
							WHEN S.freq_type IN (16) THEN freq_interval
							ELSE 0
						END
					      AS varchar(25))  + '<10>' +
				 CASE 
					WHEN S.freq_type IN (32) 
						THEN 
							CASE freq_relative_interval 
								WHEN  1 THEN 'First'
								WHEN  2 THEN 'Second'
								WHEN  4 THEN 'Third'
								WHEN  8 THEN 'Fourth'
								WHEN 16 THEN 'Last'
								ELSE 'N/A'
							END + ' ' +
							CASE freq_interval
								WHEN 1 THEN 'Sunday'
								WHEN 2 THEN 'Monday'
								WHEN 3 THEN 'Tuesday'
								WHEN 4 THEN 'Wednesday'
								WHEN 5 THEN 'Thursday'
								WHEN 6 THEN 'Friday'
								WHEN 7 THEN 'Saturday'
								WHEN 8 THEN 'Day'
								WHEN 9 THEN 'Weekday'
								WHEN 10 THEN 'Weekend Day'
								ELSE 'N/A'
							END
					ELSE 'N/A'
				 END  + '<11>' +			
 				 CAST(
						CASE 
							WHEN S.freq_type = 4 THEN freq_interval
							WHEN S.freq_type = 8 THEN freq_recurrence_factor
							WHEN S.freq_type IN (16, 32) THEN freq_recurrence_factor
							ELSE '0'
						END  
							AS varchar(25)) + '<12>' +
				 CAST(
						CASE WHEN freq_subday_type IN (4, 8) 
								THEN freq_subday_interval
								ELSE 0
						 END  
							AS varchar(25)) + '<13>' +
				 CASE freq_subday_type
							WHEN 4 THEN 'Minutes'
							WHEN 8 THEN 'Hours'
							ELSE 'NULL'
				  END + '<14>' +
				 CASE 
					WHEN S.freq_type = 4 THEN '1'
					WHEN S.freq_type = 8 THEN 
							CASE WHEN freq_interval &  1 = 1 
								THEN '1'
								ELSE '0'
							END
					ELSE '0'
				 END + '<15>' +
				 CASE 
					WHEN S.freq_type = 4 THEN '1'
					WHEN S.freq_type = 8 THEN 
							CASE WHEN freq_interval &  2 = 2
								THEN '1'
								ELSE '0'
							END
					ELSE '0'
				 END + '<16>' +
				 CASE 
					WHEN S.freq_type = 4 THEN '1'
					WHEN S.freq_type = 8 THEN 
							CASE WHEN freq_interval &  4 = 4
								THEN '1'
								ELSE '0'
							END
					ELSE '0'
				 END + '<17>' +
				 CASE 
					WHEN S.freq_type = 4 THEN '1'
					WHEN S.freq_type = 8 THEN 
							CASE WHEN freq_interval &  8 = 8
								THEN '1'
								ELSE '0'
							END
					ELSE '0'
				 END + '<18>' +
				 CASE 
					WHEN S.freq_type = 4 THEN '1'
					WHEN S.freq_type = 8 THEN 
							CASE WHEN freq_interval &  16 = 16
								THEN '1'
								ELSE '0'
							END
					ELSE '0'
				 END + '<19>' +
				 CASE 
					WHEN S.freq_type = 4 THEN '1'
					WHEN S.freq_type = 8 THEN 
							CASE WHEN freq_interval &  32 = 32
								THEN '1'
								ELSE '0'
							END
					ELSE '0'
				 END + '<20>' +
				 CASE 
					WHEN S.freq_type = 4 THEN '1'
					WHEN S.freq_type = 8 THEN 
							CASE WHEN freq_interval &  64 = 64
								THEN '1'
								ELSE '0'
							END
					ELSE '0'
				 END + '<21>' +
				 ISNULL(L.name, 'NULL')
FROM		msdb.dbo.sysjobs							J
				JOIN msdb.dbo.sysjobschedules			JS	ON J.job_id			= JS.job_id
				JOIN msdb.dbo.sysschedules				S	ON JS.schedule_id	= S.schedule_id
				LEFT JOIN master.sys.server_principals	L	ON J.owner_sid		= L.sid
WHERE		J.enabled= 1
  AND		S.enabled = 1
ORDER BY	J.name


