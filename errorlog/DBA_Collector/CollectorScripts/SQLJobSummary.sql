SET NOCOUNT ON

DECLARE @Today				datetime
		,@Yesterday			datetime
		,@TwoDaysAgo		datetime
		,@ThreeDaysAgo		datetime
		,@TempDbDate		datetime

SET @Today = CONVERT(char(10), GETDATE(), 112) -- Today's Date @ Midnight
SET @Yesterday = DATEADD(dd, -1, @Today)
SET @TwoDaysAgo = DATEADD(dd, -2, @Today)
SET @ThreeDaysAgo = DATEADD(dd, -3, @Today)

SELECT		@TempDbDate = crdate
FROM		master.dbo.sysdatabases

CREATE TABLE #xp_results 
(
		job_id                UNIQUEIDENTIFIER NOT NULL,
        last_run_date         INT              NOT NULL,
        last_run_time         INT              NOT NULL,
        next_run_date         INT              NOT NULL,
        next_run_time         INT              NOT NULL,
        next_run_schedule_id  INT              NOT NULL,
        requested_to_run      INT              NOT NULL, -- BOOL
        request_source        INT              NOT NULL,
        request_source_id     sysname          COLLATE database_default NULL,
        running               INT              NOT NULL, -- BOOL
        current_step          INT              NOT NULL,
        current_retry_attempt INT              NOT NULL,
        job_state             INT              NOT NULL
)

INSERT INTO #xp_results
EXECUTE master.dbo.xp_sqlagent_enum_jobs 1, 'sa'

SELECT		J.name + '<1>' +
				CAST(J.enabled AS varchar(1)) + '<2>' +
				RTRIM(ISNULL(MAX(
					CASE WHEN H.run_status = 0 
						THEN CONVERT
							 (
								char(19)
								,DATEADD
								(
									ss
									,CAST(RIGHT(REPLICATE('0', 10-LEN(CAST(H.run_duration AS varchar(10)))) + CAST(H.run_duration AS varchar(10)), 2) AS int)
									,DATEADD
										 (
											mi
											,CAST(SUBSTRING(REPLICATE('0', 10-LEN(CAST(H.run_duration AS varchar(10)))) + CAST(H.run_duration AS varchar(10)), 3, 2) AS int)
											,DATEADD
												(
													hh
													,CAST(LEFT(REPLICATE('0', 10-LEN(CAST(H.run_duration AS varchar(10)))) + CAST(H.run_duration AS varchar(10)), 2) AS int)
													,CONVERT(char(19), SUBSTRING(CAST(H.run_date AS varchar(8)), 5, 2) + '/' + SUBSTRING(CAST(H.run_date AS varchar(8)), 7, 2) + '/' + LEFT(CAST(H.run_date AS varchar(8)), 4) + ' ' + 
														LEFT(REPLICATE('0', 6 - LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 2) + ':' +
														SUBSTRING(REPLICATE('0', 6-LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 3, 2) + ':' + 
														RIGHT(REPLICATE('0', 6-LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 2), 120)								
												)
										 )
								 )
								 ,120
							  )
						ELSE NULL
					END
					), 'NULL')) + '<3>' +
				RTRIM(ISNULL(CAST(
							DATEDIFF(
										ss
										,MAX(
												CASE WHEN H.run_status = 0 
													THEN CONVERT(char(19), SUBSTRING(CAST(H.run_date AS varchar(8)), 5, 2) + '/' + SUBSTRING(CAST(H.run_date AS varchar(8)), 7, 2) + '/' + LEFT(CAST(H.run_date AS varchar(8)), 4) + ' ' + 
															LEFT(REPLICATE('0', 6 - LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 2) + ':' +
															SUBSTRING(REPLICATE('0', 6-LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 3, 2) + ':' + 
															RIGHT(REPLICATE('0', 6-LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 2), 120)								
													ELSE NULL
												END
											)
										,MAX(
												CASE WHEN H.run_status = 0
													THEN DATEADD
														 (
															ss
															,CAST(RIGHT(REPLICATE('0', 10-LEN(CAST(H.run_duration AS varchar(10)))) + CAST(H.run_duration AS varchar(10)), 2) AS int)
															,DATEADD
																 (
																	mi
																	,CAST(SUBSTRING(REPLICATE('0', 10-LEN(CAST(H.run_duration AS varchar(10)))) + CAST(H.run_duration AS varchar(10)), 3, 2) AS int)
																	,DATEADD
																		(
																			hh
																			,CAST(LEFT(REPLICATE('0', 10-LEN(CAST(H.run_duration AS varchar(10)))) + CAST(H.run_duration AS varchar(10)), 2) AS int)
																			,CONVERT(char(19), SUBSTRING(CAST(H.run_date AS varchar(8)), 5, 2) + '/' + SUBSTRING(CAST(H.run_date AS varchar(8)), 7, 2) + '/' + LEFT(CAST(H.run_date AS varchar(8)), 4) + ' ' + 
																				LEFT(REPLICATE('0', 6 - LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 2) + ':' +
																				SUBSTRING(REPLICATE('0', 6-LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 3, 2) + ':' + 
																				RIGHT(REPLICATE('0', 6-LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 2), 120)								
																		)
																 )
														 )
													ELSE NULL
												END
											) 
					) AS varchar(25)), 'NULL')) + '<4>' +
				RTRIM(ISNULL(MAX(
						CASE WHEN H.run_status = 1
						THEN CONVERT
							 (
								char(19)
								,DATEADD
								(
									ss
									,CAST(RIGHT(REPLICATE('0', 10-LEN(CAST(H.run_duration AS varchar(10)))) + CAST(H.run_duration AS varchar(10)), 2) AS int)
									,DATEADD
										 (
											mi
											,CAST(SUBSTRING(REPLICATE('0', 10-LEN(CAST(H.run_duration AS varchar(10)))) + CAST(H.run_duration AS varchar(10)), 3, 2) AS int)
											,DATEADD
												(
													hh
													,CAST(LEFT(REPLICATE('0', 10-LEN(CAST(H.run_duration AS varchar(10)))) + CAST(H.run_duration AS varchar(10)), 2) AS int)
													,CONVERT(char(19), SUBSTRING(CAST(H.run_date AS varchar(8)), 5, 2) + '/' + SUBSTRING(CAST(H.run_date AS varchar(8)), 7, 2) + '/' + LEFT(CAST(H.run_date AS varchar(8)), 4) + ' ' + 
														LEFT(REPLICATE('0', 6 - LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 2) + ':' +
														SUBSTRING(REPLICATE('0', 6-LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 3, 2) + ':' + 
														RIGHT(REPLICATE('0', 6-LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 2), 120)								
												)
										 )
								 )
								 ,120
							  )
							ELSE NULL
						END
					), 'NULL')) + '<5>' +
				RTRIM(ISNULL(CAST(
							DATEDIFF(
										ss
										,MAX(
												CASE WHEN H.run_status = 1 
													THEN CONVERT(char(19), SUBSTRING(CAST(H.run_date AS varchar(8)), 5, 2) + '/' + SUBSTRING(CAST(H.run_date AS varchar(8)), 7, 2) + '/' + LEFT(CAST(H.run_date AS varchar(8)), 4) + ' ' + 
															LEFT(REPLICATE('0', 6 - LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 2) + ':' +
															SUBSTRING(REPLICATE('0', 6-LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 3, 2) + ':' + 
															RIGHT(REPLICATE('0', 6-LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 2), 120)								
													ELSE NULL
												END
											)
										,MAX(
												CASE WHEN H.run_status = 1
													THEN DATEADD
														 (
															ss
															,CAST(RIGHT(REPLICATE('0', 10-LEN(CAST(H.run_duration AS varchar(10)))) + CAST(H.run_duration AS varchar(10)), 2) AS int)
															,DATEADD
																 (
																	mi
																	,CAST(SUBSTRING(REPLICATE('0', 10-LEN(CAST(H.run_duration AS varchar(10)))) + CAST(H.run_duration AS varchar(10)), 3, 2) AS int)
																	,DATEADD
																		(
																			hh
																			,CAST(LEFT(REPLICATE('0', 10-LEN(CAST(H.run_duration AS varchar(10)))) + CAST(H.run_duration AS varchar(10)), 2) AS int)
																			,CONVERT(char(19), SUBSTRING(CAST(H.run_date AS varchar(8)), 5, 2) + '/' + SUBSTRING(CAST(H.run_date AS varchar(8)), 7, 2) + '/' + LEFT(CAST(H.run_date AS varchar(8)), 4) + ' ' + 
																				LEFT(REPLICATE('0', 6 - LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 2) + ':' +
																				SUBSTRING(REPLICATE('0', 6-LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 3, 2) + ':' + 
																				RIGHT(REPLICATE('0', 6-LEN(CAST(H.run_time AS varchar(6)))) + CAST(H.run_time AS varchar(6)), 2), 120)								
																		)
																 )
														 )
													ELSE NULL
												END
											) 
					) AS varchar(25)), 'NULL')) + '<6>' +
				RTRIM(ISNULL(MIN(
						CASE WHEN X.next_run_date = 0
							THEN NULL
							ELSE
								CONVERT(varchar(19), SUBSTRING(CAST(X.next_run_date AS varchar(8)), 5, 2) + '/' + SUBSTRING(CAST(X.next_run_date AS varchar(8)), 7, 2) + '/' + LEFT(CAST(X.next_run_date AS varchar(8)), 4) + ' ' + 
									LEFT(REPLICATE('0', 6 - LEN(CAST(X.next_run_time AS varchar(6)))) + CAST(X.next_run_time AS varchar(6)), 2) + ':' +
									SUBSTRING(REPLICATE('0', 6-LEN(CAST(X.next_run_time AS varchar(6)))) + CAST(X.next_run_time AS varchar(6)), 3, 2) + ':' + 
									RIGHT(REPLICATE('0', 6-LEN(CAST(X.next_run_time AS varchar(6)))) + CAST(X.next_run_time AS varchar(6)), 2), 120)
						END
					), 'NULL')) + '<7>' +
				CAST(X.running AS char(1)) + '<8>' + 
				CAST(CASE WHEN X.running = 1
					THEN
						DATEDIFF(
									ss
									,MIN(
											 CASE WHEN X.next_run_date = 0 
												THEN @TempDbDate
												ELSE 
													CONVERT(varchar(19), SUBSTRING(CAST(X.next_run_date AS varchar(8)), 5, 2) + '/' + SUBSTRING(CAST(X.next_run_date AS varchar(8)), 7, 2) + '/' + LEFT(CAST(X.next_run_date AS varchar(8)), 4) + ' ' + 
														LEFT(REPLICATE('0', 6 - LEN(CAST(X.next_run_time AS varchar(6)))) + CAST(X.next_run_time AS varchar(6)), 2) + ':' +
														SUBSTRING(REPLICATE('0', 6-LEN(CAST(X.next_run_time AS varchar(6)))) + CAST(X.next_run_time AS varchar(6)), 3, 2) + ':' + 
														RIGHT(REPLICATE('0', 6-LEN(CAST(X.next_run_time AS varchar(6)))) + CAST(X.next_run_time AS varchar(6)), 2), 120)
											 END
										 )
									,GETDATE()
							     )
					ELSE 0
				END AS varchar(25)) + '<9>' +
				CAST(SUM(
						CASE WHEN CONVERT(char(8), H.run_date, 112) >= @Today 
							THEN CASE WHEN H.run_status = 0
									THEN 1
									ELSE 0
								 END
							ELSE 0
						END
					) AS varchar(9)) + '<10>' +
				CAST(SUM(
						CASE WHEN CONVERT(char(8), H.run_date, 112) >= @Today 
							THEN CASE WHEN H.run_status = 1
									THEN 1
									ELSE 0
								 END
							ELSE 0
						END
					) AS varchar(9)) + '<11>' +
				CAST(SUM(
						CASE WHEN CONVERT(char(8), H.run_date, 112) BETWEEN @Yesterday AND DATEADD(ss, -1, @Today) 
							THEN CASE WHEN H.run_status = 0
									THEN 1
									ELSE 0
								 END
							ELSE 0
						END
					)AS varchar(9)) + '<12>' + 
				CAST(SUM(
						CASE WHEN CONVERT(char(8), H.run_date, 112) BETWEEN @Yesterday AND DATEADD(ss, -1, @Today)
							THEN CASE WHEN H.run_status = 1
									THEN 1
									ELSE 0
								 END
							ELSE 0
						END
					)AS varchar(9)) + '<13>' +
				CAST(SUM(
						CASE WHEN CONVERT(char(8), H.run_date, 112) BETWEEN @TwoDaysAgo AND DATEADD(ss, -1, @Yesterday)
							THEN CASE WHEN H.run_status = 0
									THEN 1
									ELSE 0
								 END
							ELSE 0
						END
					)AS varchar(9)) + '<14>' + 
				CAST(SUM(
						CASE WHEN CONVERT(char(8), H.run_date, 112) BETWEEN @TwoDaysAgo AND DATEADD(ss, -1, @Yesterday)
							THEN CASE WHEN H.run_status = 1
									THEN 1
									ELSE 0
								 END
							ELSE 0
						END
					)AS varchar(9)) + '<15>' + 
				CAST(SUM(
						CASE WHEN CONVERT(char(8), H.run_date, 112) BETWEEN @ThreeDaysAgo AND DATEADD(ss, -1, @TwoDaysAgo)
							THEN CASE WHEN H.run_status = 0
									THEN 1
									ELSE 0
								 END
							ELSE 0
						END
					)AS varchar(9)) + '<16>' + 
				CAST(SUM(
						CASE WHEN CONVERT(char(8), H.run_date, 112) BETWEEN @ThreeDaysAgo AND DATEADD(ss, -1, @TwoDaysAgo)
							THEN CASE WHEN H.run_status = 1
									THEN 1
									ELSE 0
								 END
							ELSE 0
						END
					) AS varchar(9)) 
FROM		msdb.dbo.sysjobs							J
				JOIN #xp_results						X ON J.job_id = X.job_id
				LEFT JOIN msdb.dbo.sysjobhistory		H ON J.job_id = H.job_id
														 AND H.step_id = 0
														 AND CONVERT(char(8), H.run_date, 112) >= @ThreeDaysAgo
GROUP BY	J.name
			,J.enabled
			,X.running
ORDER BY	J.name

DROP TABLE #xp_results
