---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--For "QRY_PARAM_DEF" Table
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Use NetikIP
SELECT 'INSERT INTO [dbo].[QUERY_PARAM_DEF]
           ([DEF_TYP]
           ,[TYP_IND]
           ,[TYP_QRY_RPT_NUM]
           ,[PARAM_SEQ]
           ,[PARAM_NME]
           ,[PARAM_FLD_NME]
           ,[PARAM_FLD_DATATYPE]
           ,[PARAM_ENTITY_NUM]
           ,[PARAM_FLD_NUM]
           ,[PARAM_DFLT_INTVAL]
           ,[PARAM_DFLT_FLOATVAL]
           ,[PARAM_DFLT_DATEVAL]
           ,[PARAM_DFLT_CHARVAL]
           ,[PARAM_DFLT_VARCHARVAL]
           ,[LST_CHG_TMS]
           ,[LST_CHG_USR_ID]
           ,[PARAM_REQ_IND])
     VALUES ( ' + RTRIM('''' +CONVERT(VARCHAR(1),DEF_TYP)) + '''' + ','                      
                + RTRIM('''' +CONVERT(VARCHAR(1),TYP_IND))  + '''' + ',' 
				+ RTRIM(CONVERT(VARCHAR(10),TYP_QRY_RPT_NUM))  + ','
				+ RTRIM(CONVERT(VARCHAR(2),PARAM_SEQ))  + ','
               + RTRIM('''' +convert(char(40),PARAM_NME)+'''')  + ','
                    + RTRIM(isnull(CONVERT(CHAR(30),PARAM_FLD_NME),'NULL')) + ','
                + RTRIM(isnull(CONVERT(VARCHAR(10),PARAM_FLD_DATATYPE),'NULL')) + ','
                + RTRIM(isnull(CONVERT(VARCHAR(10),PARAM_ENTITY_NUM),'NULL')) + ','
                + RTRIM(isnull(CONVERT(VARCHAR(10),PARAM_FLD_NUM),'NULL')) + ','
                + RTRIM(isnull(CONVERT(VARCHAR(10),PARAM_DFLT_INTVAL),'NULL')) + ','
                + RTRIM(isnull(CONVERT(VARCHAR(10),PARAM_DFLT_FLOATVAL),'NULL')) + ','
                + RTRIM(isnull(''''+CONVERT(VARCHAR(40),GETDATE())+'''', 'NULL')) + ','
                 + RTRIM(isnull(CONVERT(CHAR(40),PARAM_DFLT_CHARVAL),'NULL')) + ','
				--+ RTRIM('''' +convert(char(40),PARAM_DFLT_CHARVAL)+'''')  + ','
    --            + RTRIM('''' +convert(char(255),PARAM_DFLT_VARCHARVAL)+'''')  + ','
    + RTRIM(isnull(CONVERT(CHAR(255),PARAM_DFLT_VARCHARVAL),'NULL')) + ','
                + RTRIM(isnull(''''+CONVERT(VARCHAR(40),GETDATE())+'''', 'NULL')) + ','
                + RTRIM(isnull('''' +CONVERT(CHAR(8),LST_CHG_USR_ID)+'''', 'NULL'))+ ',' 
                + RTRIM(isnull(CONVERT(VARCHAR(10),PARAM_REQ_IND),'NULL'))         +                                  
             ')'        
FROM QUERY_PARAM_DEF where param_entity_num =67 and TYP_QRY_RPT_NUM=12695