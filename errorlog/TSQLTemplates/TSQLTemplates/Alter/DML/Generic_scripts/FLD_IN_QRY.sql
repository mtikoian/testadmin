SELECT 'INSERT INTO [dbo].[FLD_IN_QRY]
           ([INQ_NUM]
           ,[QRY_NUM]
           ,[ENTITY_NUM]
           ,[FLD_NUM]
           ,[SEQ_NUM]
           ,[INTERNL_NME]
           ,[FLD_BUS_NME]
           ,[NLS_CDE]
           ,[DATA_CLS_NUM]
           ,[DATA_TYP_NUM]
           ,[GRID_ALIGN_NUM]
           ,[GRID_WIDTH_NUM]
           ,[FORMAT_OPT_NUM]
           ,[FORMAT_TXT]
           ,[TOTAL_OPT_NUM]
           ,[INDENT_BY]
           ,[INDENT_BY_AMT]
           ,[FILTER_SUPPRESS_IND]
           ,[FORMULA_ID]
           ,[GROUP_BY_IND]
           ,[SCALE]
           ,[TOTAL_BY]
           ,[INCL_GRAND]
           ,[SORT_OPT]
           ,[BREAK_SUBTOTAL]
           ,[VALUE_COL]
           ,[DUPS]
           ,[LST_CHG_USR_ID]
           ,[LST_CHG_TMS]
           ,[HIDE_IND]
           ,[GRPVAL_IN_SUBTOTAL_IND]
           ,[REQD_IND]
           ,[DATA_CALC_IND])
     VALUES( ' +
		convert(varchar(20),INQ_NUM) + ',' +
		convert(varchar(20),QRY_NUM) +	 ',' +
		convert(varchar(20),ENTITY_NUM) + ',' +
        convert(varchar(20),FLD_NUM) +	 ',' +
		convert(varchar(20),SEQ_NUM) + ',''' + 
		ISNULL(INTERNL_NME,'NULL')	+ ''',''' +  
        ISNULL(FLD_BUS_NME,'NULL')	+ ''',''' +  
        ISNULL(NLS_CDE, 'NULL')	+ ''',' +  
        ISNULL(convert(varchar(20),[DATA_CLS_NUM]), 'NULL') + ',' +
		ISNULL(convert(varchar(20),[DATA_TYP_NUM]), 'NULL') +  ',' +
        ISNULL(convert(varchar(20),[GRID_ALIGN_NUM]), 'NULL') + ',' +
		ISNULL(convert(varchar(20),[GRID_WIDTH_NUM]), 'NULL') +  ',' +  
        ISNULL(convert(varchar(20),[FORMAT_OPT_NUM]), 'NULL') +  ',''' +    
        isnull(FORMAT_TXT, 'NULL')	+''',' +   
		ISNULL(convert(varchar(20),TOTAL_OPT_NUM), 'NULL') +  ',' +	
        convert(char(1),[INDENT_BY])	+ ',' +  
        isnull(convert(varchar(20),[INDENT_BY_AMT]), 'NULL')	+ ',' +   
        convert(char(1),[FILTER_SUPPRESS_IND])	+ ',' +   
        isnull(convert(varchar(20),[FORMULA_ID]), 'NULL')	+ ',''' +   
        convert(char(1),[GROUP_BY_IND])	+ ''',' +   
        isnull(convert(varchar(20),[SCALE]), 'NULL')	+ ',''' +  
        rtrim(isnull([TOTAL_BY], 'NULL'))		+ ''',' +
        convert(char(1),[INCL_GRAND])	+ ',' +   
        isnull(convert(varchar(20),[SORT_OPT]), 'NULL')	+ ',' +    
        convert(char(1),[BREAK_SUBTOTAL])	+ ',' +    
        isnull(convert(varchar(20),[VALUE_COL]), 'NULL')	+ ',' +    
        convert(char(1),[DUPS])	+ ',''' +    
        rtrim(isnull([LST_CHG_USR_ID], 'NULL'))	+ ''',''' +  
        isnull(convert(varchar(22),Getdate()), 'NULL')	+ ''',' +   
        isnull(convert(varchar(20),[HIDE_IND]), 'NULL')	+ ',' +      
        isnull(convert(varchar(20),[GRPVAL_IN_SUBTOTAL_IND]), 'NULL')	+ ',' +    
        isnull(convert(varchar(20),[REQD_IND]), 'NULL')	+ ',''' + 
		isnull(convert(varchar(20),[DATA_CALC_IND]), 'NULL')	+ '''' +   
        ') '
from FLD_IN_QRY WHERE INQ_NUM IN (12721,12717)


