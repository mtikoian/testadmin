SELECT 'INSERT INTO [dbo].[INQ_DEF]
           ([INQ_NUM]
           ,[INQ_NME]
           ,[INQ_DESC]
           ,[NLS_CDE]
           ,[ORG_ID]
           ,[BK_ID]
           ,[ACCT_ID]
           ,[INQ_TYP_NUM]
           ,[ENTITY_NUM]
           ,[INQ_BASIS_NUM]
           ,[USER_ID]
           ,[CLS_SET_ID]
           ,[STAND_USR_IND]
           ,[DTE_TYP_NUM]
           ,[DTE_PER_NUM]
           ,[END_DATE]
           ,[START_DATE]
           ,[ADJDTE_TYP_NUM]
           ,[ADJ_END_DATE]
           ,[ADJ_START_DATE]
           ,[TRNDTE_TYP_NUM]
           ,[STARTUP_VW_NUM]
           ,[MAX_ITEMS_NUM]
           ,[PRNT_INQ_NUM]
           ,[GRID_LINE_IND]
           ,[ROW_NUM_IND]
           ,[COLOR_ROW_IND]
           ,[COLOR_ROW_HEX]
           ,[STYLE_ID]
           ,[DIM_BAR_IND]
           ,[FREEZE_COL_IND]
           ,[FREEZE_COL_NUM]
           ,[SUPRS_DUP_COL_NUM]
           ,[HOR_SCROLL_IND]
           ,[MULTI_DTE_IND]
           ,[MULTI_ACCT_IND]
           ,[XLS_NME]
           ,[SUB_TOTAL_IND]
           ,[TOTAL_IND]
           ,[QUERY_IND]
           ,[ITEM_CNT_IND]
           ,[CHT_NME]
           ,[LST_CHG_USR_ID]
           ,[LST_CHG_TMS]
           ,[PROJ_PER]
           ,[PROJ_PER_UNIT]
           ,[PROJ_SUM_UNIT]
           ,[BASED_UPON]
           ,[FUND_ID]
           ,[SHR_CLASS_ID]
           ,[INSTR_ID]
           ,[ACCT_CAB_IND]
           ,[DLG_XSLNAME]
           ,[DSP_XSLNAME]
           ,[SHARED_IND]
           ,[HDR_PROC_NME]
           ,[DASHBRD_IND]
           ,[SUBTOTAL_POSN]
           ,[ALLOW_SUBTOTAL_IND]
           ,[ALLOW_GRANDTOTAL_IND]
           ,[INQ_NOTES]
           ,[ALLOW_EDIT_SELECT]
           ,[ALLOW_EDIT_FORMAT]
           ,[ALLOW_EDIT_FILTER]
           ,[ALLOW_EDIT_ADVANCED]
           ,[ALLOW_EDIT_SORT]
           ,[EDITABLE_IND]
           ,[WEBPRINT_IND]
           ,[SCHEDULE_IND]
           ,[DOWNLOAD_IND]
           ,[GRP_FILTER_NUM]
           ,[RLTD_ENTITY_NUM]
           ,[LOCK_INQ_BASIS]
           ,[AUTORUN_IND]
           ,[HIDE_INQDIAG_IND]
           ,[ALLOW_EDIT_GRPFLTR])
     VALUES
           (' +
			convert(varchar(20),INQ_NUM) + ',''' +
			isnull(INQ_NME,'NULL') +	 ''',''' +
            isnull(INQ_DESC,'NULL') +	 ''',''' +
            rtrim(isnull(convert(char(8),[NLS_CDE]),'NULL'))	+ ''',''' +
            rtrim(isnull(convert(char(4),[ORG_ID]),'NULL'))	+ ''',''' +
			rtrim(isnull(convert(char(4),[BK_ID]),'NULL'))+ ''',''' +
			rtrim(isnull(convert(char(12),[ACCT_ID]),'NUll'))	+ ''','	 +
            isnull(convert(varchar(20),INQ_TYP_NUM),'NULL') + ',' +
            isnull(convert(varchar(20),ENTITY_NUM),'NULL') + ',' +
            isnull(convert(varchar(20),INQ_BASIS_NUM),'NULL') + ',''' +
            rtrim(convert(char(8),[USER_ID]))	+ ''',''' +
            rtrim(convert(char(8),[CLS_SET_ID]))	+ ''',''' +
            rtrim(convert(char(8),[STAND_USR_IND]))	+ ''',' +
            isnull(convert(varchar(20),DTE_TYP_NUM),'NULL') + ',' +
            isnull(convert(varchar(20),DTE_PER_NUM),'NULL') + ',''' +
            isnull(convert(varchar(22),[END_DATE]), 'NULL')	+ ''',''' +
            isnull(convert(varchar(22),[START_DATE]), 'NULL')	+ ''',' +
            isnull(convert(varchar(20),ADJDTE_TYP_NUM),'NULL') + ',' +
            isnull(convert(varchar(22),[ADJ_END_DATE]), 'NULL')	+ ',' +
            isnull(convert(varchar(22),[ADJ_START_DATE]), 'NULL')	+ ',' +
            isnull(convert(varchar(20),TRNDTE_TYP_NUM),'NULL') + ',' +
            isnull(convert(varchar(20),STARTUP_VW_NUM),'NULL') + ',' +
            isnull(convert(varchar(20),MAX_ITEMS_NUM),'NULL') + ',' +
            isnull(convert(varchar(20),PRNT_INQ_NUM),'NULL') + ',''' +
            convert(char(1),[GRID_LINE_IND]) + ''',''' +
            convert(char(1),[ROW_NUM_IND])	+ ''',''' +
            convert(char(1),[COLOR_ROW_IND]) + ''',' +
            isnull(convert(char(4),[COLOR_ROW_HEX]),'NULL') + ',' +
            isnull(convert(varchar(20),STYLE_ID),'NULL') + ',' +
            convert(char(1),[DIM_BAR_IND]) + ',' +
			convert(char(1),[FREEZE_COL_IND]) + ',' +
            isnull(convert(varchar(20),FREEZE_COL_NUM),'NULL') + ',' +
            isnull(convert(varchar(20),SUPRS_DUP_COL_NUM),'NULL') + ',' +
            convert(char(4),[HOR_SCROLL_IND]) + ',' +
			convert(char(4),[MULTI_DTE_IND]) + ',' +
            convert(char(4),[MULTI_ACCT_IND]) + ',''' +
            isnull(XLS_NME,'NULL') +	 ''',' +
            convert(char(1),[SUB_TOTAL_IND]) + ',' +
			convert(char(1),[TOTAL_IND]) + ',' +
            convert(char(1),[QUERY_IND]) + ',' +
            convert(char(1),[ITEM_CNT_IND]) + ',''' +
            isnull(CHT_NME,'NULL') +	 ''',''' +
            isnull([LST_CHG_USR_ID], 'NULL')	+ ''',''' +
            isnull(convert(varchar(22),GETDATE()), 'NULL')	+ ''',' +
            isnull(convert(varchar(20),PROJ_PER),'NULL') + ',' +
            isnull(convert(varchar(20),PROJ_PER_UNIT),'NULL') + ',' +
			rtrim(isnull(convert(varchar(20),PROJ_SUM_UNIT),'NULL')) + ',' +
            convert(char(1),[BASED_UPON]) + ',' +
            rtrim(isnull(convert(char(12),[FUND_ID]),'NULL')) + ',''' +
            rtrim(isnull(convert(char(12),[SHR_CLASS_ID]),'NULL') )+ ''',''' +
            rtrim(isnull(convert(char(16),[INSTR_ID]),'NULL')) + ''',' +
            isnull(convert(varchar(20),ACCT_CAB_IND),'NULL') + ',''' +
            isnull(DLG_XSLNAME,'NULL') +	 ''',''' +
			isnull(DSP_XSLNAME,'NULL') +	 ''',' +
			isnull(convert(varchar(20),SHARED_IND),'NULL') + ',''' +
			isnull(HDR_PROC_NME,'NULL') +	 ''',' +
            isnull(convert(varchar(20),DASHBRD_IND),'NULL') + ',' +
			convert(varchar(20),SUBTOTAL_POSN) + ',' +
			convert(varchar(20),ALLOW_SUBTOTAL_IND) + ',' +
			convert(varchar(20),ALLOW_GRANDTOTAL_IND) + ',''' +
			isnull(INQ_NOTES,'NULL') +	 ''',' +
            convert(varchar(20),ALLOW_EDIT_SELECT) + ',' +
			convert(varchar(20),ALLOW_EDIT_FORMAT) + ',' +
			convert(varchar(20),ALLOW_EDIT_FILTER) + ',' +
			convert(varchar(20),ALLOW_EDIT_SORT) + ',' +
            convert(varchar(20),ALLOW_EDIT_ADVANCED) + ',' +
			convert(varchar(20),EDITABLE_IND) + ',' +
			convert(varchar(20),WEBPRINT_IND) + ',' +
			convert(varchar(20),SCHEDULE_IND) + ',' +
			convert(varchar(20),DOWNLOAD_IND) + ',' +
			isnull(convert(varchar(20),GRP_FILTER_NUM),'NULL') + ',' +
			isnull(convert(varchar(20),RLTD_ENTITY_NUM),'NULL') + ',' +
			isnull(convert(varchar(20),LOCK_INQ_BASIS),'NULL') + ',' +
			isnull(convert(varchar(20),AUTORUN_IND),'NULL') + ',' +
			isnull(convert(varchar(20),HIDE_INQDIAG_IND),'NULL') + ',' +
			isnull(convert(varchar(20),ALLOW_EDIT_GRPFLTR),'NULL') + '' +
           ') '
			FROM INQ_DEF WHERE INQ_NUM IN (12721,12717)

