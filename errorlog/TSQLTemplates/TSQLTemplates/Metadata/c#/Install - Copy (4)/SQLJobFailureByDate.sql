DECLARE @FailDate char(10) 

SET @FailDate = 'YYYYMMDD' -- PLEASE ENTER A VALID DATE

SELECT 		A.name AS [SQLJobName]
		,CAST
		(
			SUBSTRING
			(
				CAST(run_date AS varchar(8)), 5, 2) + 
					'/' + RIGHT(run_date, 2) + '/' + 
					LEFT(run_date , 4) + ' ' + 
					LEFT(REPLICATE('0', 6 - LEN(CAST(run_time AS varchar(6)))) + 
					CAST(run_time AS varchar(6)), 2) + ':' +
					SUBSTRING(REPLICATE('0', 6-LEN(CAST(run_time AS varchar(6)))) + 
					CAST(run_time AS varchar(6)), 3, 2) + ':' + 
					RIGHT(REPLICATE('0', 6-LEN(CAST(run_time AS varchar(6)))) + 
					CAST(run_time AS varchar(6)), 2
			)
			AS datetime
		) AS [RunDate]
		,B.message
FROM		msdb.dbo.sysjobs A
			JOIN msdb.dbo.sysjobhistory B ON A.job_id = B.job_id
WHERE		B.run_date = @FailDate
  AND		B.run_status = 0
  AND		B.step_id = 0
ORDER BY	A.name
		,CAST
		(
			SUBSTRING
			(
				CAST(run_date AS varchar(8)), 5, 2) + 
					'/' + RIGHT(run_date, 2) + '/' + 
					LEFT(run_date , 4) + ' ' + 
					LEFT(REPLICATE('0', 6 - LEN(CAST(run_time AS varchar(6)))) + 
					CAST(run_time AS varchar(6)), 2) + ':' +
					SUBSTRING(REPLICATE('0', 6-LEN(CAST(run_time AS varchar(6)))) + 
					CAST(run_time AS varchar(6)), 3, 2) + ':' + 
					RIGHT(REPLICATE('0', 6-LEN(CAST(run_time AS varchar(6)))) + 
					CAST(run_time AS varchar(6)), 2
			)
			AS datetime
	    ) 	


/*
-- RUN THIS QUERY IF YOU WANT TO SEE ALL JOB FAILURES PAST 30 DAYS
SELECT 		A.name AS [SQLJobName]
		,CAST(
				SUBSTRING
				(
					CAST(run_date AS varchar(8)), 5, 2) + 
						'/' + RIGHT(run_date, 2) + '/' + 
						LEFT(run_date , 4) + ' ' + 
						LEFT(REPLICATE('0', 6 - LEN(CAST(run_time AS varchar(6)))) + 
						CAST(run_time AS varchar(6)), 2) + ':' +
						SUBSTRING(REPLICATE('0', 6-LEN(CAST(run_time AS varchar(6)))) + 
						CAST(run_time AS varchar(6)), 3, 2) + ':' + 
						RIGHT(REPLICATE('0', 6-LEN(CAST(run_time AS varchar(6)))) + 
						CAST(run_time AS varchar(6)), 2
				)
				AS datetime
		    ) AS [RunDate]
		,B.message
FROM		msdb.dbo.sysjobs A
			JOIN msdb.dbo.sysjobhistory B ON A.job_id = B.job_id
WHERE		B.run_status = 0
  AND		B.step_id = 0
  AND		DATEDIFF 
  		(
				d 
				,CAST(
					SUBSTRING
					(
						CAST(run_date AS varchar(8)), 5, 2) + 
							'/' + RIGHT(run_date, 2) + '/' + 
							LEFT(run_date , 4) + ' ' + 
							LEFT(REPLICATE('0', 6 - LEN(CAST(run_time AS varchar(6)))) + 
							CAST(run_time AS varchar(6)), 2) + ':' +
							SUBSTRING(REPLICATE('0', 6-LEN(CAST(run_time AS varchar(6)))) + 
							CAST(run_time AS varchar(6)), 3, 2) + ':' + 
							RIGHT(REPLICATE('0', 6-LEN(CAST(run_time AS varchar(6)))) + 
							CAST(run_time AS varchar(6)), 2
					)
					AS datetime
			   	    ) 
				,GETDATE()
		) <= 30
ORDER BY	A.name
		,CAST(
				SUBSTRING
				(
					CAST(run_date AS varchar(8)), 5, 2) + 
						'/' + RIGHT(run_date, 2) + '/' + 
						LEFT(run_date , 4) + ' ' + 
						LEFT(REPLICATE('0', 6 - LEN(CAST(run_time AS varchar(6)))) + 
						CAST(run_time AS varchar(6)), 2) + ':' +
						SUBSTRING(REPLICATE('0', 6-LEN(CAST(run_time AS varchar(6)))) + 
						CAST(run_time AS varchar(6)), 3, 2) + ':' + 
						RIGHT(REPLICATE('0', 6-LEN(CAST(run_time AS varchar(6)))) + 
						CAST(run_time AS varchar(6)), 2
				)
				AS datetime
		    ) DESC
*/