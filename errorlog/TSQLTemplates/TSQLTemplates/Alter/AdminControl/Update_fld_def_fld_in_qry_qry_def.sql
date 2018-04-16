USE NetikIP; 
GO

/*
* Copyright: This information constitutes the exclusive property of SEI
* Investments Company, and constitutes the confidential and proprietary
* information of SEI Investments Company.  The information shall not be
* used or disclosed for any purpose without the written consent of SEI 
* Investments Company. 
----------------------------------------------------------------------------------------------------
 JIRA#					: MDB-4995
 File Name				: Update_MDB_4995.sql
 Created By				: VBANDI
 Created Date			:  09/10/2014
 Description				: Update metadata 
 ------------------------------------------------------------------------------------------------------
 */ 
 

PRINT '-------------Script Started at	 :' +  convert(char(23),getdate(),121) + '------------------------';
PRINT SPACE(100);

BEGIN TRY
	BEGIN TRANSACTION;
	---------------------------Start---------------------------------------
UPDATE dbo.FLD_DEF
SET INTERNL_NAME = 'ISS_CL_VALUE'
OUTPUT DELETED.INTERNL_NAME
	,deleted.entity_num
	,deleted.FLD_NUM
WHERE (INTERNL_NAME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCC''))%'
or [INTERNL_NAME] LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''''SCC''''))%');

PRINT 'SCC Updated in FLD_DEF';

UPDATE dbo.fld_in_qry
SET INTERNL_NME = 'ISS_CL_VALUE'
OUTPUT DELETED.INTERNL_NME
	,deleted.INQ_NUM
	,deleted.QRY_NUM
	,deleted.ENTITY_NUM
	,deleted.FLD_NUM
	,deleted.SEQ_NUM
WHERE INTERNL_NME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCC''))%';

PRINT 'SCC Updated in fld_in_qry';

UPDATE dbo.qry_def
SET select_stmt = REPLACE(select_stmt, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCC''))', 'ISS_CL_VALUE')
OUTPUT DELETED.select_stmt
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE select_stmt LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCC''))%';

UPDATE dbo.qry_def
SET select_stmt = REPLACE(select_stmt, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SCC''))', 'ISS_CL_VALUE')
OUTPUT DELETED.select_stmt
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE SELECT_STMT LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SCC''))%';

UPDATE dbo.qry_def
SET groupby = REPLACE(groupby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCC''))', 'ISS_CL_VALUE')
OUTPUT DELETED.groupby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE groupby LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCC''))%';
UPDATE dbo.qry_def
SET groupby = REPLACE(groupby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SCC''))', 'ISS_CL_VALUE')
OUTPUT DELETED.groupby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE groupby LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SCC''))%';

UPDATE dbo.qry_def
SET orderby = REPLACE(orderby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCC''))', 'ISS_CL_VALUE')
OUTPUT DELETED.orderby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE orderby LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCC''))%';

UPDATE dbo.qry_def
SET orderby = REPLACE(orderby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SCC''))', 'ISS_CL_VALUE')
OUTPUT DELETED.orderby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE orderby LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SCC''))%';

/****************Update 2*******************/
UPDATE dbo.FLD_DEF
SET INTERNL_NAME = 'ISS_CL_NME'
OUTPUT DELETED.INTERNL_NAME
	,deleted.entity_num
	,deleted.FLD_NUM
WHERE (INTERNL_NAME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCN''))%'
or INTERNL_NAME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''''SCN''''))%');

PRINT 'SCN Updated in FLD_DEF';

UPDATE dbo.fld_in_qry
SET INTERNL_NME = 'ISS_CL_NME'
OUTPUT DELETED.INTERNL_NME
	,deleted.INQ_NUM
	,deleted.QRY_NUM
	,deleted.ENTITY_NUM
	,deleted.FLD_NUM
	,deleted.SEQ_NUM
WHERE INTERNL_NME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCN''))%';

PRINT 'SCN Updated in fld_in_qry';

UPDATE dbo.qry_def
SET select_stmt = REPLACE(select_stmt, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCN''))', 'ISS_CL_NME')
OUTPUT DELETED.select_stmt
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE select_stmt LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCN''))%';

UPDATE dbo.qry_def
SET select_stmt = REPLACE(select_stmt, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SCN''))', 'ISS_CL_NME')
OUTPUT DELETED.select_stmt
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE select_stmt LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SCN''))%';

UPDATE dbo.qry_def
SET groupby = REPLACE(groupby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCN''))', 'ISS_CL_NME')
OUTPUT DELETED.groupby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE groupby LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCN''))%';
UPDATE dbo.qry_def
SET groupby = REPLACE(groupby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SCN''))', 'ISS_CL_NME')
OUTPUT DELETED.groupby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
where groupby LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SCN''))%';

UPDATE dbo.qry_def
SET orderby = REPLACE(orderby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCN''))', 'ISS_CL_NME')
OUTPUT DELETED.orderby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE orderby LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SCN''))%';

UPDATE dbo.qry_def
SET orderby = REPLACE(orderby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SCN''))', 'ISS_CL_NME')
OUTPUT DELETED.orderby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE orderby LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SCN''))%';

/****************Update 3*******************/
UPDATE dbo.FLD_DEF
SET INTERNL_NAME = 'ISSUE_CLS3_CDE'
OUTPUT DELETED.INTERNL_NAME
	,deleted.entity_num
	,deleted.FLD_NUM
WHERE INTERNL_NAME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INC''))%'
or INTERNL_NAME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''''INC''''))%';

PRINT 'INC Updated in FLD_DEF';

UPDATE dbo.fld_in_qry
SET INTERNL_NME = 'ISSUE_CLS3_CDE'
OUTPUT DELETED.INTERNL_NME
	,deleted.INQ_NUM
	,deleted.QRY_NUM
	,deleted.ENTITY_NUM
	,deleted.FLD_NUM
	,deleted.SEQ_NUM
WHERE INTERNL_NME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INC''))%';

PRINT 'INC Updated in fld_in_qry';

UPDATE dbo.qry_def
SET select_stmt = REPLACE(select_stmt, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INC''))', 'ISSUE_CLS3_CDE')
OUTPUT DELETED.select_stmt
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE select_stmt LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INC''))%';

UPDATE dbo.qry_def
SET select_stmt = REPLACE(select_stmt, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''INC''))', 'ISSUE_CLS3_CDE')
OUTPUT DELETED.select_stmt
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE select_stmt LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''INC''))%';

UPDATE dbo.qry_def
SET groupby = REPLACE(groupby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INC''))', 'ISSUE_CLS3_CDE')
OUTPUT DELETED.groupby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE groupby LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INC''))%';

UPDATE dbo.qry_def
SET groupby = REPLACE(groupby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''INC''))', 'ISSUE_CLS3_CDE')
OUTPUT DELETED.groupby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE  groupby LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''INC''))%';

UPDATE dbo.qry_def
SET orderby = REPLACE(orderby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INC''))', 'ISSUE_CLS3_CDE')
OUTPUT DELETED.orderby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE orderby LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INC''))%';

UPDATE dbo.qry_def
SET orderby = REPLACE(orderby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''INC''))', 'ISSUE_CLS3_CDE')
OUTPUT DELETED.orderby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE orderby LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''INC''))%';

/****************Update 4*******************/
UPDATE dbo.FLD_DEF
SET INTERNL_NAME = 'issue_cls3_nme'
OUTPUT DELETED.INTERNL_NAME
	,deleted.entity_num
	,deleted.FLD_NUM
WHERE INTERNL_NAME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INN''))%'
or INTERNL_NAME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''''INN''''))%';

PRINT 'INN Updated in FLD_DEF';

UPDATE dbo.fld_in_qry
SET INTERNL_NME = 'issue_cls3_nme'
OUTPUT DELETED.INTERNL_NME
	,deleted.INQ_NUM
	,deleted.QRY_NUM
	,deleted.ENTITY_NUM
	,deleted.FLD_NUM
	,deleted.SEQ_NUM
WHERE INTERNL_NME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INN''))%';

PRINT 'INN Updated in fld_in_qry';

UPDATE dbo.qry_def
SET select_stmt = REPLACE(select_stmt, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INN''))', 'issue_cls3_nme')
OUTPUT DELETED.select_stmt
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE select_stmt LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INN''))%';

UPDATE dbo.qry_def
SET select_stmt = REPLACE(select_stmt, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''INN''))', 'issue_cls3_nme')
OUTPUT DELETED.select_stmt
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE select_stmt LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''INN''))%';

UPDATE dbo.qry_def
SET groupby = REPLACE(groupby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INN''))', 'issue_cls3_nme')
OUTPUT DELETED.groupby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE groupby LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INN''))%';
UPDATE dbo.qry_def
SET groupby = REPLACE(groupby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''INN''))', 'issue_cls3_nme')
OUTPUT DELETED.groupby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE  groupby LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''INN''))%';

UPDATE dbo.qry_def
SET orderby = REPLACE(orderby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INN''))', 'issue_cls3_nme')
OUTPUT DELETED.orderby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE orderby LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''INN''))%';

UPDATE dbo.qry_def
SET orderby = REPLACE(orderby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''INN''))', 'issue_cls3_nme')
OUTPUT DELETED.orderby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE orderby LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''INN''))%';

/****************Update 5*******************/
UPDATE dbo.FLD_DEF
SET INTERNL_NAME = 'ISSUE_CLS4_CDE'
OUTPUT DELETED.INTERNL_NAME
	,deleted.entity_num
	,deleted.FLD_NUM
WHERE INTERNL_NAME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIC''))%'
or  INTERNL_NAME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''''sic''''))%';

PRINT 'SIC Updated in FLD_DEF';

UPDATE dbo.fld_in_qry
SET INTERNL_NME = 'ISSUE_CLS4_CDE'
OUTPUT DELETED.INTERNL_NME
	,deleted.INQ_NUM
	,deleted.QRY_NUM
	,deleted.ENTITY_NUM
	,deleted.FLD_NUM
	,deleted.SEQ_NUM
WHERE INTERNL_NME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIC''))%';

PRINT 'SIC Updated in fld_in_qry';

UPDATE dbo.qry_def
SET select_stmt = REPLACE(select_stmt, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIC''))', 'ISSUE_CLS4_CDE')
OUTPUT DELETED.select_stmt
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE select_stmt LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIC''))%';

UPDATE dbo.qry_def
SET select_stmt = REPLACE(select_stmt, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SIC''))', 'ISSUE_CLS4_CDE')
OUTPUT DELETED.select_stmt
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE select_stmt LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SIC''))%';

UPDATE dbo.qry_def
SET groupby = REPLACE(groupby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIC''))', 'ISSUE_CLS4_CDE')
OUTPUT DELETED.groupby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE groupby LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIC''))%';
UPDATE dbo.qry_def
SET groupby = REPLACE(groupby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SIC''))', 'ISSUE_CLS4_CDE')
OUTPUT DELETED.groupby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE groupby LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SIC''))%';

UPDATE dbo.qry_def
SET orderby = REPLACE(orderby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIC''))', 'ISSUE_CLS4_CDE')
OUTPUT DELETED.orderby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE orderby LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIC''))%';

UPDATE dbo.qry_def
SET orderby = REPLACE(orderby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SIC''))', 'ISSUE_CLS4_CDE')
OUTPUT DELETED.orderby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE  orderby LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SIC''))%';

/****************Update 6*******************/
UPDATE dbo.FLD_DEF
SET INTERNL_NAME = 'issue_cls4_nme'
OUTPUT DELETED.INTERNL_NAME
	,deleted.entity_num
	,deleted.FLD_NUM
WHERE (INTERNL_NAME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIN''))%'
or INTERNL_NAME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''''sin''''))%');

PRINT 'SIN Updated in FLD_DEF';

UPDATE dbo.fld_in_qry
SET INTERNL_NME = 'issue_cls4_nme'
OUTPUT DELETED.INTERNL_NME
	,deleted.INQ_NUM
	,deleted.QRY_NUM
	,deleted.ENTITY_NUM
	,deleted.FLD_NUM
	,deleted.SEQ_NUM
WHERE INTERNL_NME LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIN''))%';

PRINT 'SIN Updated in fld_in_qry';

UPDATE dbo.qry_def
SET select_stmt = REPLACE(select_stmt, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIN''))', 'issue_cls4_nme')
OUTPUT DELETED.select_stmt
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE select_stmt LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIN''))%';

UPDATE dbo.qry_def
SET select_stmt = REPLACE(select_stmt, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SIN''))', 'issue_cls4_nme')
OUTPUT DELETED.select_stmt
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE  select_stmt LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''sin''))%';

UPDATE dbo.qry_def
SET groupby = REPLACE(groupby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIN''))', 'issue_cls4_nme')
OUTPUT DELETED.groupby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE groupby LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIN''))%';

UPDATE dbo.qry_def
SET groupby = REPLACE(groupby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SIN''))', 'issue_cls4_nme')
OUTPUT DELETED.groupby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE groupby LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''sin''))%';

UPDATE dbo.qry_def
SET orderby = REPLACE(orderby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIN''))', 'issue_cls4_nme')
OUTPUT DELETED.orderby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE orderby LIKE '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID,''SIN''))%';

UPDATE dbo.qry_def
SET orderby = REPLACE(orderby, '(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''SIN''))', 'issue_cls4_nme')
OUTPUT DELETED.orderby
	,deleted.INQ_NUM
	,deleted.QRY_NUM
WHERE orderby LIKE  '%(dbo.fndw_SEI_GICSCodes(A.INSTR_ID, ''sin''))%';
---------------------------End------------------------------------------
	PRINT SPACE(100);
	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION;		
		PRINT 'Transaction COMMIT successfully';
	END;
	
	PRINT 'Record inserted/updated/Deleted successfully';

		
END TRY
BEGIN CATCH

	PRINT 'Error occured in script';
    IF @@TRANCOUNT > 0
	BEGIN
        ROLLBACK TRANSACTION;
		PRINT 'Transaction ROLLBACK successfully';
	END;

    DECLARE @error_Message VARCHAR(2100); 
    DECLARE @error_Severity INT; 
    DECLARE @error_State INT; 

    SET @error_Message = Error_message();
    SET @error_Severity = Error_severity(); 
    SET @error_State = Error_state(); 

    RAISERROR (@error_Message,@error_Severity,@error_State); 
END CATCH;


PRINT SPACE(100);
PRINT '-------------Script completed at :' +  convert(char(23),getdate(),121) + '------------------------';