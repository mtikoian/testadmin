SELECT 'INSERT INTO [dbo].[FLD_DEF]
           ([ENTITY_NUM]
           ,[FLD_NUM]
           ,[SEQ_NUM]
           ,[INTERNL_NAME]
           ,[FLD_BUS_NME]
           ,[FLD_DESC]
           ,[FLD_NME]
           ,[NLS_CDE]
           ,[DATA_CLS_NUM]
           ,[DATA_CLS_TYP]
           ,[GRID_WIDTH_NUM]
           ,[GRID_ALIGN_NUM]
           ,[SORT_OPT_TYP]
           ,[FORMULA_IND]
           ,[FORMAT_OPT_NUM]
           ,[TOTAL_OPT_NUM]
           ,[FORMAT_TXT]
           ,[GROUP_BY_IND]
           ,[GROUP_BY_METH]
           ,[LST_CHG_TMS]
           ,[LST_CHG_USR_ID]
           ,[DATA_TYP_NUM]
           ,[FILTER_SUPPRESS_IND]
           ,[TABLE_NME]
           ,[CHART_TYP_NUM]
           ,[CATEGORY]
           ,[INQ_TYP]
           ,[RESERV_IND]
           ,[SHOW_IND]
           ,[RLTD_ENTITY_NUM]
           ,[RLTD_FLD_NUM]
           ,[PERF_PER_DIM_IND]
           ,[DATA_CALC_IND]
           ,[FORMULA_ID]
           ,[ACCUM_PER_CODE]
           ,[FLD_TYP])
     VALUES( ' +
	  convert(varchar(20),ENTITY_NUM) + ',' +
	  convert(varchar(20),FLD_NUM) +	 ',' +
      convert(varchar(20),SEQ_NUM) +	 ',''' +
      INTERNL_NAME	+ ''',''' +
      isnull(FLD_BUS_NME,'NULL') +	 ''',''' +
      isnull(FLD_DESC,'NULL')	+	 ''',''' +
      isnull(FLD_NME, 'NULL')	+ ''',''' +
	  isnull(NLS_CDE, 'NULL')	+ ''',' +
	  isnull(convert(varchar(20),DATA_CLS_NUM), 'NULL') +  ',''' +
      isnull(convert(char(1),DATA_CLS_TYP),'NULL')	+ ''',' +
	  isnull(convert(varchar(20),[GRID_WIDTH_NUM]),'NULL')	+ ',' +
      isnull(convert(varchar(20),[GRID_ALIGN_NUM]),'NULL')	+ ',''' +
      isnull(SORT_OPT_TYP, 'NULL')	+ ''',' +
	  convert(char(1),[FORMULA_IND])	+ ',' +
	  isnull(convert(varchar(20),[FORMAT_OPT_NUM]), 'NULL')	+ ',' +
      isnull(convert(varchar(20),[TOTAL_OPT_NUM]), 'NULL')	+ ',''' +
      isnull([FORMAT_TXT], 'NULL')	+ ''',' +
      convert(varchar(5),[GROUP_BY_IND]) 	+ ',''' +
      isnull([GROUP_BY_METH], 'NULL')	+ ''',''' +
      isnull(convert(varchar(22),Getdate()), 'NULL')	+ ''',''' +
      isnull([LST_CHG_USR_ID], 'NULL')	+ ''',' +
      isnull(convert(varchar(20),[DATA_TYP_NUM]), 'NULL')	+ ',' +
      convert(varchar(5),[FILTER_SUPPRESS_IND])	+ ',''' +
      isnull([TABLE_NME], 'NULL')	+ ''',' +
      isnull(convert(varchar(20),[CHART_TYP_NUM]), 'NULL')	+ ',' +
      isnull(convert(varchar(8),[CATEGORY]), 'NULL')	+ ',' +
      isnull(convert(varchar(8),[INQ_TYP]), 'NULL')	+ ',''' +
      isnull([RESERV_IND], 'NULL')	+ ''',' +
      isnull(convert(varchar(20),[SHOW_IND]), 'NULL')	+ ',' +
      isnull(convert(varchar(20),[RLTD_ENTITY_NUM]), 'NULL')	+ ',' +
      isnull(convert(varchar(20),[RLTD_FLD_NUM]), 'NULL')		+ ',' +
      isnull(convert(varchar(20),[PERF_PER_DIM_IND]), 'NULL')	+ ',' +
      isnull(convert(varchar(10),[DATA_CALC_IND]), 'NULL')		+ ',' +
      isnull(convert(varchar(20),[FORMULA_ID]), 'NULL')			+ ',''' +
      rtrim(isnull([ACCUM_PER_CODE], 'NULL'))		+ ''',''' +
      rtrim(isnull([FLD_TYP], 'NULL'))	+ '''' +		
	   ') ' 	
	  FROM FLD_DEF where ENTITY_NUM = 10200