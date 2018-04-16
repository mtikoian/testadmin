	
	/*****Update Node*****/
	--DECLARE @newValue varchar(50)
	--set @newValue = ''
	--UPDATE  netikip.dbo.sei_parameter
	--SET parameter_xml.modify('replace value of (/JobParameters/pgroupby_txt/text())[1] with sql:variable("@newValue")') where 
	--Schedule_id in (1198, 1199,  1200, 1201, 1202) 


  select tbl.jobname 
		,tbl.EmailAddresses
		,tb.Parameter_Id
        ,tb.Schedule_Id
		from NETIKIP.dbo.SEI_Parameter tb
 left outer join (
   SELECT  a.Parameter_Id
 ,e.P.value('JobName[1]', 'varchar(1000)') AS 'JobName'
 ,P.value('(FTP)[1]', 'VARCHAR(50)') AS 'FTP'
 ,P.value('Email[1]', 'VARCHAR(50)') AS 'Email'
 ,o.value('EmailAddresses[1]', 'VARCHAR(1000)') AS 'EmailAddresses'
 ,o.value('Pdf[1]', 'VARCHAR(1000)') AS 'Pdf'
 ,o.value('Csv[1]', 'VARCHAR(1000)') AS 'Csv'
 ,o.value('Pipe[1]', 'VARCHAR(1000)') AS 'Pipe'
 ,o.value('Tab[1]', 'VARCHAR(1000)') AS 'Tab'
 ,o.value('Zip[1]', 'VARCHAR(1000)') AS 'Zip'
 ,SR.value('Sunday[1]', 'VARCHAR(1000)') AS 'Sunday'
 ,SR.value('Monday[1]', 'VARCHAR(1000)') AS 'Monday'
 ,SR.value('Tuesday[1]', 'VARCHAR(1000)') AS 'Tuesday'
 ,SR.value('Wednesday[1]', 'VARCHAR(1000)') AS 'Wednesday'
 ,SR.value('Thursday[1]', 'VARCHAR(1000)') AS 'Thursday'
 ,SR.value('Friday[1]', 'VARCHAR(1000)') AS 'Friday'
 ,SR.value('Saturday[1]', 'VARCHAR(1000)') AS 'Saturday'
 ,SR.value('MonthRecurrType[1]', 'VARCHAR(1000)') AS 'MonthRecurrType'
 ,SR.value('DayOfMonth[1]', 'VARCHAR(1000)') AS 'DayOfMonth'
 ,SR.value('WeekOfMonth[1]', 'VARCHAR(1000)') AS 'WeekOfMonth'
 ,SR.value('DayOfWeek[1]', 'VARCHAR(1000)') AS 'DayOfWeek'
 ,SR.value('MonthInterval[1]', 'VARCHAR(1000)') AS 'MonthInterval'
 ,p.value('TimezoneId[1]', 'VARCHAR(1000)') AS 'TimezoneId'
 FROM 
     NETIKIP.dbo.SEI_Parameter a
		CROSS APPLY
			Execution_Def_Xml.nodes('/JobDefinition') AS E(P)
				 CROSS APPLY Execution_Def_Xml.nodes('/JobDefinition/Output') AS Members(o)
	 					CROSS APPLY Execution_Def_Xml.nodes('/JobDefinition/ScheduleRecurance') AS Val(SR)
		 )tbl
							on tbl.Parameter_Id = tb.Parameter_Id

--Find failed schedules
select  * from SEI_SCHEDULE sch
inner join SEI_EXECUTION_STATUS es on
sch.last_exec_status =  es.Execution_Status_ID
where 
--[Schedule_Id] = 1225


LAST_EXEC_STATUS = 4
order by Last_Run_Dt



SELECT * FROM dbo.SEI_Parameter WHERE Schedule_Id = 1286
select  


* from SEI_SCHEDULE sch
--inner join SEI_EXECUTION_STATUS es on
--sch.last_exec_status =  es.Execution_Status_ID
where SCHEDULE_ID = 1286
order by Last_Run_Dt

--To find execution queue
select * from [v_MDB_MOB_ExecutionQueue]

--To find Active schedules
select * from [v_MDB_MOB_AllSchedules]


SELECT 
	SS.SCHEDULE_ID,
	SS.INQ_NUM,
	SS.PERIOD_ID,
	SS.PERIOD_COUNT,
	SS.LAST_RUN_DT,
	SS.LAST_EXEC_STATUS, 
	SS.START_DT,	
	SS.END_DT,
	SS.DASHBOARD_FL,
	SS.OWNER_ID,
	SS.CREATE_DT,
	SE.EXECUTION_ID,
	SE.SCHEDULED_RUN_TM,	
	SE.ADHOC_IND,
	tbl.JobName ,
	tbl.EmailAddresses,
	SP.PARAMETER_ID,
	SP.PARAMETER_XML,
	SP.EXECUTION_DEF_XML
FROM dbo.SEI_SCHEDULE SS 
INNER JOIN dbo.SEI_EXECUTION SE 
	ON 
		SS.SCHEDULE_ID = SE.SCHEDULE_ID 
INNER JOIN dbo.SEI_PARAMETER SP 
	ON 
		SE.PARAMETER_ID = SP.PARAMETER_ID

		inner join (
   SELECT  a.Parameter_Id
 ,CASE WHEN e.P.value('JobName[1]', 'varchar(1000)') IS NULL 
    THEN e.P.value('JobName[2]', 'varchar(1000)') 
	ELSE e.P.value('JobName[1]', 'varchar(1000)')
  END AS 'JobName'
 ,P.value('(FTP)[1]', 'VARCHAR(50)') AS 'FTP'
 ,P.value('Email[1]', 'VARCHAR(50)') AS 'Email'
 ,o.value('EmailAddresses[1]', 'VARCHAR(1000)') AS 'EmailAddresses'
 ,o.value('Pdf[1]', 'VARCHAR(1000)') AS 'Pdf'
 ,o.value('Csv[1]', 'VARCHAR(1000)') AS 'Csv'
 ,o.value('Pipe[1]', 'VARCHAR(1000)') AS 'Pipe'
 ,o.value('Tab[1]', 'VARCHAR(1000)') AS 'Tab'
 ,o.value('Zip[1]', 'VARCHAR(1000)') AS 'Zip'
 ,SR.value('Sunday[1]', 'VARCHAR(1000)') AS 'Sunday'
 ,SR.value('Monday[1]', 'VARCHAR(1000)') AS 'Monday'
 ,SR.value('Tuesday[1]', 'VARCHAR(1000)') AS 'Tuesday'
 ,SR.value('Wednesday[1]', 'VARCHAR(1000)') AS 'Wednesday'
 ,SR.value('Thursday[1]', 'VARCHAR(1000)') AS 'Thursday'
 ,SR.value('Friday[1]', 'VARCHAR(1000)') AS 'Friday'
 ,SR.value('Saturday[1]', 'VARCHAR(1000)') AS 'Saturday'
 ,SR.value('MonthRecurrType[1]', 'VARCHAR(1000)') AS 'MonthRecurrType'
 ,SR.value('DayOfMonth[1]', 'VARCHAR(1000)') AS 'DayOfMonth'
 ,SR.value('WeekOfMonth[1]', 'VARCHAR(1000)') AS 'WeekOfMonth'
 ,SR.value('DayOfWeek[1]', 'VARCHAR(1000)') AS 'DayOfWeek'
 ,SR.value('MonthInterval[1]', 'VARCHAR(1000)') AS 'MonthInterval'
 ,p.value('TimezoneId[1]', 'VARCHAR(1000)') AS 'TimezoneId'
 FROM 
     NETIKIP.dbo.SEI_Parameter a
		CROSS APPLY
			Execution_Def_Xml.nodes('/JobDefinition') AS E(P)
				 CROSS APPLY Execution_Def_Xml.nodes('/JobDefinition/Output') AS Members(o)
	 					CROSS APPLY Execution_Def_Xml.nodes('/JobDefinition/ScheduleRecurance') AS Val(SR)
		 )tbl
							on tbl.Parameter_Id = SP.Parameter_Id
WHERE 
	SE.ISCURRENT = 1
	AND SS.Inq_Num= 18140;