SELECT 'INSERT INTO [dbo].[ENTITY_DEF]
           ([ENTITY_NUM]
           ,[ENTITY_NME]
           ,[ENTITY_DESC]
           ,[ENTITY_TYP]
           ,[DATA_GRP_DEF_ID]
           ,[VIEW_ID]
           ,[USER_VIEW_ID]
           ,[NAV_INQ_NUM]
           ,[HOLD_INQ_NUM]
           ,[LST_CHG_TMS]
           ,[LST_CHG_USR_ID])
     VALUES
           ( ' +
			CONVERT(varchar(20),ENTITY_NUM) + ',''' +
			ISNULL(ENTITY_NME,'NULL') +	 ''',''' +
            ISNULL(ENTITY_DESC,'NULL') +	 ''',''' +
			ISNULL(CONVERT(char(8),ENTITY_TYP),'NULL')	+ ''',''' +
            ISNULL(CONVERT(char(8),DATA_GRP_DEF_ID),'NULL')	+ ''',''' +
            ISNULL(VIEW_ID,'NULL') +	 ''',''' +
            ISNULL(USER_VIEW_ID,'NULL') +	 ''',' +
            ISNULL(CONVERT(varchar(20),[NAV_INQ_NUM]),'NULL')	+ ',' +
			ISNULL(CONVERT(varchar(20),[HOLD_INQ_NUM]),'NULL')	+ ',''' +
            ISNULL(CONVERT(varchar(22),GETDATE()), 'NULL')	+ ''',''' +
			RTRIM(ISNULL([LST_CHG_USR_ID], 'NULL'))	+ '''' +
           ') '

			from ENTITY_DEF WHERE ENTITY_NUM=10610