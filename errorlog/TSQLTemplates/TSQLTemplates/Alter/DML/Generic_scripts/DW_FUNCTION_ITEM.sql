SELECT 'INSERT INTO [dbo].[DW_FUNCTION_ITEM]
           ([FN_ID]
           ,[FN_NME]
           ,[FN_DESC]
           ,[FN_MNEM]
           ,[FN_TYP]
           ,[FN_TXT]
           ,[FN_STYLE_IND]
           ,[FN_STYLE_ID]
           ,[FN_LVL_NUM]
           ,[FN_SEQ_NUM]
           ,[INQ_NUM]
           ,[RPT_NUM]
           ,[PRNT_FN_ID]
           ,[FN_ENABLE_IND]
           ,[FN_STD_USR_IND]
           ,[FN_BGIMG_ID]
           ,[FN_ACIMG_ID]
           ,[FN_SAIMG_ID]
           ,[FN_MOIMG_ID]
           ,[FN_URLASP_TXT]
           ,[LST_CHG_TMS]
           ,[LST_CHG_USR_ID]
           ,[FN_FILTER_TXT]
           ,[APP_GUID])
     VALUES 
           (''' + convert(char(10),FN_ID)  + ''',''' +
           ISNULL(FN_NME,'NULL') + ''',''' +
           ISNULL(FN_DESC, 'NULL') + ''',''' +
           RTRIM(ISNULL(FN_MNEM, 'NULL')) + ''',''' +
           ISNULL(FN_TYP, 'NULL') + ''',''' +
           ISNULL(FN_TXT, 'NULL') + ''',''' +
           ISNULL(FN_STYLE_IND, 'NULL') + ''',''' +
           RTRIM(ISNULL(FN_STYLE_ID, 'NULL')) + ''',' +
           ISNULL(CONVERT(varchar(20),[FN_LVL_NUM]), 'NULL') +  ',''' +
		   ISNULL(CONVERT(varchar(20),[FN_SEQ_NUM]), 'NULL') +  ''',' +
           ISNULL(CONVERT(varchar(20),[INQ_NUM]), 'NULL') +  ',' +
           ISNULL(CONVERT(varchar(20),[RPT_NUM]), 'NULL') +  ',''' +
           RTRIM(ISNULL(PRNT_FN_ID, 'NULL')) + ''',''' +
           ISNULL(FN_ENABLE_IND, 'NULL') + ''',''' +
		   ISNULL(FN_STD_USR_IND, 'NULL') + ''',' +
           ISNULL(CONVERT(varchar(20),[FN_BGIMG_ID]), 'NULL') + ',''' +
           ISNULL(CONVERT(varchar(20),[FN_ACIMG_ID]), 'NULL') +  ''',' +
		   ISNULL(CONVERT(varchar(20),[FN_SAIMG_ID]), 'NULL') +  ',' +
		   ISNULL(CONVERT(varchar(20),[FN_MOIMG_ID]), 'NULL') +  ',''' +	
           ISNULL(FN_URLASP_TXT, 'NULL') + ''',''' +
           isnull(convert(varchar(22),GETDATE()), 'NULL')	+ ''',''' +
           RTRIM(ISNULL([LST_CHG_USR_ID], 'NULL'))	+ ''',' +
           ISNULL(FN_FILTER_TXT, 'NULL') + ',''' +         
           RTRIM(ISNULL(APP_GUID, 'NULL')) + '''' +
           ') ' 
			FROM DW_FUNCTION_ITEM WHERE FN_ID IN ('FNI_012614','MatchBtch')
			
			
