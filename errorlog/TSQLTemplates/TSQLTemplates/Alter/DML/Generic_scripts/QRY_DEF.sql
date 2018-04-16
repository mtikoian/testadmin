SELECT 'INSERT INTO [dbo].[QRY_DEF]
           ([INQ_NUM]
           ,[QRY_NUM]
           ,[QRY_NME]
           ,[QRY_DESC]
           ,[DTE_TYP_NUM]
           ,[DTE_PER_NUM]
           ,[DTE_START]
           ,[DTE_END]
           ,[ADJ_DTE_TYP_NUM]
           ,[ADJ_DTE_END]
           ,[ADJ_DTE_START]
           ,[TRN_DTE_TYP_NUM]
           ,[DRILL_DOWN_QRY_NUM]
           ,[SUPRS_DUP_COL_NUM]
           ,[FILTER_NUM]
           ,[SELECT_STMT]
           ,[CRITERIA_STMT]
           ,[GROUPBY]
           ,[ORDERBY]
           ,[SP_IND]
           ,[SP_NME]
           ,[ROW_BREAK]
           ,[LIMIT_ITEM_TOP]
           ,[LIMIT_ITEM_BOTTOM]
           ,[LBL_TOP]
           ,[LBL_BOTTOM]
           ,[LIMIT_FLD]
           ,[STARTROW]
           ,[STARTCOL]
           ,[STARTUP_VW]
           ,[USER_ID]
           ,[CHT_NME]
           ,[SYSTEM_DEFINED]
           ,[LST_CHG_USR_ID]
           ,[LST_CHG_TMS]
           ,[PARAM_XMLSTRING]
           ,[CHT_IND])
     VALUES
           (' +
			convert(varchar(20),INQ_NUM) + ',' +
			convert(varchar(20),QRY_NUM) +	 ',''' +
			isnull(QRY_NME,'NULL') +	 ''',''' +
			isnull(QRY_DESC,'NULL') +	 ''',' +
            isnull(convert(varchar(20),DTE_TYP_NUM), 'NULL') +  ',' +
			isnull(convert(varchar(20),DTE_PER_NUM), 'NULL') +  ',''' +
            isnull(convert(varchar(22),GETDATE()), 'NULL')	+ ''',''' +
            isnull(convert(varchar(22),GETDATE()), 'NULL')	+ ''',' +
            isnull(convert(varchar(20),ADJ_DTE_TYP_NUM), 'NULL') +  ',' +
            isnull(convert(varchar(22),[ADJ_DTE_END]), 'NULL')	+ ',' +
            isnull(convert(varchar(22),[ADJ_DTE_START]), 'NULL')	+ ',' +
			isnull(convert(varchar(20),TRN_DTE_TYP_NUM), 'NULL') +  ',' +
			isnull(convert(varchar(20),DRILL_DOWN_QRY_NUM), 'NULL') +  ',' +
            isnull(convert(varchar(20),SUPRS_DUP_COL_NUM), 'NULL') +  ',' +
            isnull(convert(varchar(20),FILTER_NUM), 'NULL') +  ',''' +
			isnull(SELECT_STMT,'NULL') +	 ''',''' +
            isnull(CRITERIA_STMT,'NULL') +	 ''',''' +
            isnull(GROUPBY,'NULL') +	 ''',''' +
			isnull(ORDERBY,'NULL') +	 ''',' +
            convert(char(1),[SP_IND]) + ',''' +
            isnull(convert(char(30),[SP_NME]),'NULL') +''',' +
            convert(char(1),[ROW_BREAK]) + ',' +
            isnull(convert(varchar(20),LIMIT_ITEM_TOP), 'NULL') +  ',' +
            isnull(convert(varchar(20),LIMIT_ITEM_BOTTOM), 'NULL') +  ',''' +
            isnull(LBL_TOP,'NULL') +	 ''',''' +
            isnull(LBL_BOTTOM,'NULL') +	 ''',' +
            isnull(convert(varchar(20),LIMIT_FLD), 'NULL') +  ',' +
            isnull(convert(varchar(20),STARTROW), 'NULL') +  ',' +
            isnull(convert(varchar(20),STARTCOL), 'NULL') +  ',' +
            convert(char(1),[STARTUP_VW]) + ',''' +
            isnull(convert(char(8),[USER_ID]),'NULL') +''',''' +
            isnull(CHT_NME,'NULL') +	 ''',''' +
            isnull(convert(char(1),[SYSTEM_DEFINED]),'NULL') +''',''' +
            isnull(convert(char(8),LST_CHG_USR_ID),'NULL') +''',''' +
            isnull(convert(varchar(22),GETDATE()), 'NULL')	+ ''',''' +
            isnull(PARAM_XMLSTRING,'NULL') +	 ''',' +
            isnull(convert(varchar(20),CHT_IND), 'NULL') +  '' +
          ') ' 
			from QRY_DEF WHERE INQ_NUM IN (12721,12717) AND QRY_NUM IN (12721,12717)