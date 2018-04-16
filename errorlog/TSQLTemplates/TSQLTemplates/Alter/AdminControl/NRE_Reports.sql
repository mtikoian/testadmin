--EXEC sp_executesql N'SELECT TOP 3 id,itemNum,itemId,priority,fileName,SCHD_NUM,stage,state,workerAlias FROM SCH_QUEUE WITH (ROWLOCK,UPDLOCK)  WHERE stage=@stage AND state=@state ORDER BY priority DESC, id'
--	,N'@stage int,@state int,@workerAlias nvarchar(14)'
--	,@stage = 1
--	,@state = 0
--	,@workerAlias = N'SEINETIKTEST04'
--EXEC sp_executesql N'SELECT TOP 1 id, itemNum, itemId, priority, stage, SCHD_NUM, workeralias, fileName, state FROM SCH_QUEUE WHERE state=@state'
--	,N'@state int'
--	,@state = 8
SELECT TOP 3 id
	,itemNum
	,itemId
	,priority
	,fileName
	,SCHD_NUM
	,stage
	,STATE
	,workerAlias
FROM SCH_QUEUE
WHERE stage = 1
	AND STATE = 0
ORDER BY priority DESC
	,id

EXEC sch_ScheduleTask_List @ready_ind = 0

SELECT TOP 1 id
	,itemNum
	,itemId
	,priority
	,stage
	,SCHD_NUM
	,workeralias
	,fileName
	,STATE
FROM SCH_QUEUE
WHERE STATE = 8

SELECT TOP 1 Id
	,SeqNotified
	,EventName
	,CorrelationId
	,PropertiesXml
FROM XnEventLog
WHERE EventState = 0
	AND EventName = 'ScheduleReportTrigger'
ORDER BY SeqNotified

EXEC sch_ScheduleTask_UpdateStatus @schd_task_num = 143581
	,@task_id = N'{7A2D97A0-4AEF-42B7-8F2A-A5E117E5BC45}'
	,@status = 4
	,@task_status_msg = DEFAULT

EXEC sp_executesql N'SELECT NextVal  FROM xn_sequence WITH (ROWLOCK,UPDLOCK)  WHERE name=@name'
	,N'@name nvarchar(9)'
	,@name = N'SCH_QUEUE'

EXEC sp_executesql N'UPDATE xn_sequence set NextVal=@NextVal WHERE name=@name'
	,N'@NextVal int,@name nvarchar(9)'
	,@NextVal = 252071
	,@name = N'SCH_QUEUE'

EXEC sp_executesql N'INSERT INTO SCH_QUEUE(id, itemNum, itemId, priority, stage, state, requestTime, fileName, SCHD_NUM, reprocessedId, workerAlias) VALUES (@id,@itemNum,@itemId,@priority,@stage,@state,@requestTime,@fileName,@SCHD_NUM,@reprocessedId,@workerAlias)'
	,N'@id int,@itemNum int,@itemId nvarchar(36),@priority int,@stage int,@state int,@requestTime datetime,@fileName nvarchar(32),@SCHD_NUM nvarchar(4000),@reprocessedId nvarchar(4000),@workerAlias nvarchar(4000)'
	,@id = 252070
	,@itemNum = 143581
	,@itemId = N'7a2d97a0-4aef-42b7-8f2a-a5e117e5bc45'
	,@priority = 5
	,@stage = 0
	,@state = 0
	,@requestTime = '2014-06-27 13:48:00.470'
	,@fileName = N'F4E9F52310B64AC79457102EA7CA95E7'
	,@SCHD_NUM = NULL
	,@reprocessedId = NULL
	,@workerAlias = NULL

EXEC sp_executesql N'SELECT TOP 3 id,itemNum,itemId,priority,fileName,SCHD_NUM,stage,state,workerAlias FROM SCH_QUEUE WITH (ROWLOCK,UPDLOCK)  WHERE stage=@stage AND state=@state ORDER BY priority DESC, id'
	,N'@stage int,@state int'
	,@stage = 0
	,@state = 0

EXEC sp_executesql N'UPDATE SCH_QUEUE SET state=@state, processId=@processId, workerAlias=@workerAlias WHERE id=@id AND state=@prevState'
	,N'@state int,@processId int,@workerAlias nvarchar(14),@id int,@prevState int'
	,@state = 1
	,@processId = 2032
	,@workerAlias = N'SEINETIKTEST04'
	,@id = 252070
	,@prevState = 0
exec sp_executesql N'UPDATE SCH_QUEUE SET state=@state, threadId=@threadId, startTime=@startTime WHERE id=@id AND state=@prevState',N'@state int,@threadId int,@startTime datetime,@id int,@prevState int',@state=2,@threadId=7,@startTime='2014-06-27 13:48:00.827',@id=252070,@prevState=1
exec sch_ScheduleTask_UpdateStatus @schd_task_num=143581,@task_id=N'{7A2D97A0-4AEF-42B7-8F2A-A5E117E5BC45}',@status=3,@task_status_msg=default
exec dw_Task_Prog_Get @TASK_ID=N'{7A2D97A0-4AEF-42B7-8F2A-A5E117E5BC45}'
exec dw_Task_Detail @task_id=N'{7A2D97A0-4AEF-42B7-8F2A-A5E117E5BC45}'
exec sp_executesql N'
            SELECT 
              PAPER_SIZE, PREF_PAPER_WIDTH, PREF_PAPER_HEIGHT, PREF_DTE_FMT, PREF_TMZN 
            FROM IVW_USER
            WHERE RTRIM(USER_ID) = RTRIM(@user_id)',N'@user_id nvarchar(6)',@user_id=N'ndev01'
exec sp_Inquiry @tran=N'SELECT',@inq_num=12110
exec sp_FldInInq @tran=N'SELECT',@inq_num=12110
exec sp_QueryParam_List @def_typ=N'I',@typ_ind=N'S',@typ_qry_rpt_num=12110
exec sp_SetAppUser @app_usr_id=N'ndev01',@session_id=N'78d798dc-77a5-4e89-8c73-d62cd0157e7f'
exec sp_PositionVal_HdrInfo_Select @acct_id=N'1022-3-10001',@bk_id=N'HF',@org_id=N'SEI',@inq_basis_num=1,@start_tms='2013-12-31 23:59:59',@start_adjst_tms=NULL,@end_tms='2013-12-31 23:59:59',@end_adjst_tms=NULL,@cls_set_id=N'NAM-P',@date_typ_num=5,@adjust_ind=0,@inq_num=12110,@qry_num=12110,@pselect_txt=NULL,@porderby_txt=NULL,@pfilter_txt=NULL,@pgroupby_txt=NULL,@row_limit=0,@val_curr_cde=NULL
exec sp_ReSetAppUser @app_usr_id=N'ndev01',@session_id=N'78d798dc-77a5-4e89-8c73-d62cd0157e7f'


exec sp_executesql N'SELECT TOP 3 id,itemNum,itemId,priority,fileName,SCHD_NUM,stage,state,workerAlias FROM SCH_QUEUE WITH (ROWLOCK,UPDLOCK)  WHERE stage=@stage AND state=@state ORDER BY priority DESC, id',N'@stage int,@state int,@workerAlias nvarchar(14)',@stage=1,@state=0,@workerAlias=N'SEINETIKTEST04'




--send report
exec sp_executesql N'SELECT NextVal  FROM xn_sequence WITH (ROWLOCK,UPDLOCK)  WHERE name=@name',N'@name nvarchar(9)',@name=N'SCH_QUEUE'
exec sp_executesql N'UPDATE xn_sequence set NextVal=@NextVal WHERE name=@name',N'@NextVal int,@name nvarchar(9)',@NextVal=252072,@name=N'SCH_QUEUE'
exec sp_executesql N'UPDATE SCH_QUEUE SET state=@state, fileName=@fileName, endTime=@endTime WHERE id=@id AND state=@prevState',N'@state int,@fileName nvarchar(36),@endTime datetime,@id int,@prevState int',@state=3,@fileName=N'F4E9F52310B64AC79457102EA7CA95E7.csv',@endTime='2014-06-27 13:48:01.093',@id=252070,@prevState=2
exec sp_executesql N'INSERT INTO SCH_QUEUE(id, itemNum, itemId, priority, stage, state, requestTime, fileName, SCHD_NUM, reprocessedId, workerAlias) VALUES (@id,@itemNum,@itemId,@priority,@stage,@state,@requestTime,@fileName,@SCHD_NUM,@reprocessedId,@workerAlias)',N'@id int,@itemNum int,@itemId nvarchar(50),@priority int,@stage int,@state int,@requestTime datetime,@fileName nvarchar(36),@SCHD_NUM nvarchar(4000),@reprocessedId nvarchar(4000),@workerAlias nvarchar(14)',@id=252071,@itemNum=143581,@itemId=N'7a2d97a0-4aef-42b7-8f2a-a5e117e5bc45              ',@priority=5,@stage=1,@state=0,@requestTime='2014-06-27 13:48:01.110',@fileName=N'F4E9F52310B64AC79457102EA7CA95E7.csv',@SCHD_NUM=NULL,@reprocessedId=NULL,@workerAlias=N'SEINETIKTEST04'
exec dw_Task_Prog_Get @TASK_ID=N'{7A2D97A0-4AEF-42B7-8F2A-A5E117E5BC45}'
exec dw_Task_EmailDlvry_Get @task_id=N'{7A2D97A0-4AEF-42B7-8F2A-A5E117E5BC45}'
exec sp_executesql N'UPDATE SCH_QUEUE SET state=@state, fileName=@fileName, endTime=@endTime WHERE id=@id AND state=@prevState',N'@state int,@fileName nvarchar(36),@endTime datetime,@id int,@prevState int',@state=3,@fileName=N'F4E9F52310B64AC79457102EA7CA95E7.csv',@endTime='2014-06-27 13:48:01.313',@id=252071,@prevState=2
exec sch_ScheduleTask_UpdateStatus @schd_task_num=143581,@task_id=N'{7A2D97A0-4AEF-42B7-8F2A-A5E117E5BC45}',@status=1,@task_status_msg=default
exec sp_executesql N'SELECT TOP 3 id,itemNum,itemId,priority,fileName,SCHD_NUM,stage,state,workerAlias FROM SCH_QUEUE WITH (ROWLOCK,UPDLOCK)  WHERE stage=@stage AND state=@state ORDER BY priority DESC, id',N'@stage int,@state int,@workerAlias nvarchar(14)',@stage=1,@state=0,@workerAlias=N'SEINETIKTEST04'
