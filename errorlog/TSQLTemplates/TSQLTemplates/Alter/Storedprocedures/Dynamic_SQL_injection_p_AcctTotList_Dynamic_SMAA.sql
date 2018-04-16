USE NetikIP
GO

-- Drop stored procedure if it already exists
IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.ROUTINES
		WHERE SPECIFIC_SCHEMA = N'dbo'
			AND SPECIFIC_NAME = N'p_AcctTotList_Dynamic_SMAA'
		)
BEGIN
	DROP PROCEDURE dbo.p_AcctTotList_Dynamic_SMAA;

	PRINT 'PROCEDURE dbo.p_AcctTotList_Dynamic_SMAA has been dropped.';
END;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

/*        
==================================================================================================        
Name		: p_AcctTotList_Dynamic_SMAA.sql        
Author		: RZKUMAR   - 09/13/2013        
Description : Process Fetches Account information        
Process  needed to run using NETIK UI and same parameters are needed
existing NETIK screen has functionality of selecting select, filter, order by and 
Dynamic SQL is used for same purpose
===================================================================================================        
Parameters :     
Name             |I/O|			Description   
@acct_id          I              Acct Id           
@bk_id            I				 Book ID
@org_id           I				 Organisation Id
@inq_basis_num    I				 Inq basis number
@start_tms        I              Start Time          
@start_adjst_tms  I              Adjust Time          
@end_tms          I              End Time          
@end_adjst_tms    I              End Adjust Time          
@cls_set_id       I              Close Set ID          
@date_typ_num     I              Data Type Number 
@adjust_ind       I              Adjust Indicator
@inq_num          I              Inquiry number
@qry_num          I              qry number
@pselect_txt      I              select statement
@porderby_txt     I              order by statement
@pfilter_txt      I              Filter statement
@pgroupby_txt     I              Group by 
@row_limit        I              Row limit 
@val_curr_cde     I              Currency Code
----------------------------------------------------------------        
Returns  : Return table
The columns of the return table not fixed in advance. These can be changed dynamically from the interface.  
      
Usage	 : 

exec p_AcctTotList_Dynamic_SMAA '1231-1-00001 ','HF','SEI ',1,'2012-12-31 23:59:59:000',default,'2012-12-31 23:59:59:000',default,'NAM-P   ',5,0,13077,13077,'A.chr006_txt, A.chr007_txt, 
sum(a.AccountCloseValue)','A.chr006_txt Asc, A.chr007_txt Asc',default,'A.chr006_txt, 
A.chr007_txt',0,default

exec p_AcctTotList_Dynamic_SMAA '1317-SA00423','SMA  ','SEI ',1,'2012-12-31 23:59:59:000',default,'2012-12-31 23:59:59:000',default,'NAM-P   ',5,0,13077,13077,'A.chr006_txt, A.chr007_txt, 
sum(a.AccountCloseValue)','A.chr006_txt Asc, A.chr007_txt Asc',default,'A.chr006_txt, 
A.chr007_txt',0,default

exec p_AcctTotList_Dynamic_SMAA '1317-SD02145','SMA','SEI',1,'2013-09-13 23:59:59:000','2013-09-13 15:14:17:000','2012-12-31 23:59:59:000','2013-09-13 15:14:17:000','NAM-P',5,0,13096,13096,'A.chr006_txt, A.chr007_txt, sum(OpenAccounts), sum(OpenInitialValue), sum(LatestMarketValue), sum(ClosedAccounts), sum(ClosedInitialValue), 
sum(AccountCloseValue)','A.chr006_txt Asc, A.chr007_txt Asc',default,'A.chr006_txt, A.chr007_txt',0,default

exec p_AcctTotList_Dynamic_SMAA 'WHVTEST3','USER','USER',1,'2013-09-13 23:59:59:000','2012-09-12 15:14:17:000','2012-09-12 23:59:59:000','2012-09-12 15:14:17:000','NAM-P',6,0,13096,13096,'A.chr006_txt, A.chr007_txt, sum(OpenAccounts), sum(OpenInitialValue), sum(LatestMarketValue), sum(ClosedAccounts), sum(ClosedInitialValue), 
sum(AccountCloseValue)','A.chr006_txt Asc, A.chr007_txt Asc',default,'A.chr006_txt, A.chr007_txt',0,default

History:        
        
Name        Date        Description        
---------- ---------- --------------------------------------------------------        
RZkumar     09132013      First Version 
RZkumar     09162013      Updated as per SME inputs     
========================================================================================================        
*/
CREATE PROCEDURE dbo.p_AcctTotList_Dynamic_SMAA (
	@acct_id CHAR(12)
	,@bk_id CHAR(4)
	,@org_id CHAR(4)
	,@inq_basis_num INT = 1
	,@start_tms DATETIME = NULL
	,@start_adjst_tms DATETIME = NULL
	,@end_tms DATETIME = NULL
	,@end_adjst_tms DATETIME = NULL
	,@cls_set_id CHAR(8) = 'DIM'
	,@date_typ_num INT = 1
	,@adjust_ind INT = 0
	,@inq_num INT = 11
	,@qry_num INT = 11
	,@pselect_txt VARCHAR(4000) = NULL
	,@porderby_txt VARCHAR(255) = NULL
	,@pfilter_txt VARCHAR(1000) = NULL
	,@pgroupby_txt VARCHAR(255) = NULL
	,@row_limit INT = 0
	,@val_curr_cde CHAR(3) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON
	SET ANSI_WARNINGS OFF

	DECLARE @app_user_id CHAR(8);
	DECLARE @acct_type CHAR(1);
	DECLARE @asof_tms DATETIME;
	DECLARE @adjust_tms DATETIME;
	DECLARE @asof_start_tms DATETIME;
	DECLARE @adjust_start_tms DATETIME;
	DECLARE @Data_Group_ID INT;
	DECLARE @Valid INT;
	DECLARE @tmp_start_tms DATETIME;
	DECLARE @tmp_end_tms DATETIME;
	DECLARE @alt_curr_cde CHAR(3);
	DECLARE @curr_cde CHAR(3);
	DECLARE @curr_ctr INT;
	DECLARE @row_count_str VARCHAR(100);
	DECLARE @errno INT;
	DECLARE @fld_nme VARCHAR(255);
	DECLARE @sql_txt1 NVARCHAR(max);
	DECLARE @filter_txt1 VARCHAR(1000);
	DECLARE @sort_txt1 VARCHAR(255);
	DECLARE @grp_txt1 VARCHAR(255);
	DECLARE @ReturnCode INTEGER;--RZkumar     09162013
	DECLARE @msg VARCHAR(200);--RZkumar     09162013

	SET @errno = 0;
	SET @acct_id = Ltrim(Rtrim(@acct_id))
	SET @row_count_str = 'set rowcount ' + Str(@row_limit)

	--check if temp table exists 
	IF Object_id('tempdb..#tempacct') IS NOT NULL
		DROP TABLE #tempacct

	IF Object_id('tempdb..#ActTotal') IS NOT NULL
		DROP TABLE #ActTotal

	CREATE TABLE #tempacct (acct_id VARCHAR(20) NOT NULL PRIMARY KEY CLUSTERED)

	CREATE TABLE #ActTotal (
		AT_NUM INT NOT NULL
		,acct_id CHAR(12) NOT NULL
		,USER_ID CHAR(8) NOT NULL
		,ORG_ID CHAR(4) NOT NULL
		,BK_ID CHAR(4) NOT NULL
		,chr006_txt VARCHAR(40) NULL
		,chr007_txt VARCHAR(40) NULL
		,openaccounts INT NULL
		,openinitialvalue FLOAT NULL
		,latestmarketvalue FLOAT NULL
		,closedaccounts INT NULL
		,closedinitialvalue FLOAT NULL
		,accountclosevalue FLOAT NULL
		,PRIMARY KEY CLUSTERED (
			AT_NUM
			,acct_id
			,USER_ID
			,ORG_ID
			,BK_ID
			)
		)

	BEGIN TRY
		--Check if is a valid account   
		/*Start RZkumar     09162013*/                    			
		EXEC @ReturnCode = dbo.sp_UserAccount @ACCT_ID = @acct_id
			,@ORG_ID = @org_id
			,@BK_ID = @bk_id
			,@Valid = @Valid OUTPUT

		IF @ReturnCode <> 0
		BEGIN
			SET @msg = 'Unable to check Account information ReturnCode=' + cast(@errno AS VARCHAR(12));

			RAISERROR (
					@msg
					,16
					,1
					);
		END;
		/*End RZkumar     09162013*/  
		IF @Valid = 0
			RETURN (0)

		SELECT @app_user_id = dbo.fndw_appuser()

		--Check what type of account I= individual G= Group                         
		SELECT @acct_type = ACCT_GRP_TYP
			,@alt_curr_cde = ALT_CURR_CDE
		FROM dbo.IVW_ACCT
		WHERE (
				USER_ID = 'HOST'
				OR USER_ID = @app_user_id
				)
			AND ACCT_ID = @ACCT_ID
			AND BK_ID = @bk_id
			AND ORG_ID = @org_id

		IF @date_typ_num NOT IN (
				6
				,12
				,13
				,14
				)
		BEGIN
		/*Start RZkumar     09162013*/  
			EXEC @ReturnCode = sp_DateType_GetDates @ACCT_ID = @acct_id
				,@BK_ID = @bk_id
				,@ORG_ID = @org_id
				,@acct_type = @acct_type
				,@inq_basis_num = @inq_basis_num
				,@cls_set_id = @cls_set_id
				,@date_typ_num = @date_typ_num
				,@data_grp_def_id = 'POSITION'
				,@date_1 = @tmp_start_tms OUTPUT
				,@date_2 = @tmp_end_tms OUTPUT

			IF @ReturnCode <> 0
			BEGIN
				SET @msg = 'Unable to Return dates for a given date type number ReturnCode=' + cast(@errno AS VARCHAR(12));

				RAISERROR (
						@msg
						,16
						,1
						);
			END;
		/*End RZkumar     09162013*/ 
			SET @start_tms = @tmp_start_tms
			SET @end_tms = @tmp_end_tms
		END

		SET @sql_txt1 = ' '
		SET @filter_txt1 = ' '
		SET @sort_txt1 = ' '

		IF @inq_num IS NOT NULL
		BEGIN
		/*Start RZkumar     09162013*/  
			EXEC @ReturnCode = sp_Inquiry_BldSqlStrings @inq_num = @inq_num
				,@qry_num = @qry_num
				,@sql_text = @sql_txt1 OUTPUT
				,@filter_text = @filter_txt1 OUTPUT
				,@sort_text = @sort_txt1 OUTPUT
				,@groupby_text = @grp_txt1 OUTPUT

			IF @ReturnCode <> 0
			BEGIN
				SET @msg = 'Unable to return build string parameters ReturnCode=' + cast(@errno AS VARCHAR(12));

				RAISERROR (
						@msg
						,16
						,1
						);
			END;
			/*End RZkumar     09162013*/ 
		END

		-- Override sql strings if sql string parameter has any value                        
		IF (
				DATALENGTH(rtrim(@pselect_txt)) > 0
				OR @pselect_txt IS NOT NULL
				)
		BEGIN
			SELECT @sql_txt1 = CASE 
					WHEN DATALENGTH(rtrim(@pselect_txt)) = 0
						THEN @sql_txt1
					WHEN @pselect_txt IS NULL
						THEN @sql_txt1
					ELSE rtrim(@pselect_txt)
					END
				,@filter_txt1 = CASE 
					WHEN DATALENGTH(rtrim(@pfilter_txt)) = 0
						THEN ' '
					WHEN @pfilter_txt IS NULL
						THEN ' '
					ELSE ' and (' + rtrim(@pfilter_txt) + ')'
					END
				,@sort_txt1 = CASE 
					WHEN DATALENGTH(rtrim(@porderby_txt)) = 0
						THEN ' '
					WHEN @porderby_txt IS NULL
						THEN ' '
					ELSE ' order by ' + rtrim(@porderby_txt)
					END
				,@grp_txt1 = CASE 
					WHEN DATALENGTH(rtrim(@pgroupby_txt)) = 0
						THEN ' '
					WHEN @pgroupby_txt IS NULL
						THEN ' '
					ELSE ' group by ' + rtrim(@pgroupby_txt)
					END
		END
		ELSE
		BEGIN
			SELECT @filter_txt1 = CASE 
					WHEN DATALENGTH(rtrim(@filter_txt1)) = 0
						THEN ''
					WHEN @filter_txt1 IS NULL
						THEN ''
					ELSE ' and (' + rtrim(@filter_txt1) + ')'
					END
		END

		IF (
				@acct_type = 'U'
				OR @acct_type = 'G'
				)
		BEGIN
			INSERT INTO #tempacct (acct_id)
			SELECT DISTINCT acct_id
			FROM dbo.acctgroupview AGV
			WHERE AGV.grp_acct_id = @acct_id
		END
		ELSE
			INSERT INTO #tempacct (acct_id)
			VALUES (@acct_id)

		INSERT INTO #ActTotal (
			AT_NUM
			,acct_id
			,USER_ID
			,ORG_ID
			,BK_ID
			,chr006_txt
			,chr007_txt
			,OpenAccounts
			,OpenInitialValue
			,LatestMarketValue
			,ClosedAccounts
			,ClosedInitialValue
			,AccountCloseValue
			)
		SELECT t.AT_NUM
			,t.acct_id
			,t.USER_ID
			,t.ORG_ID
			,t.BK_ID
			,t.chr006_txt
			,t.chr007_txt
			,CASE 
				WHEN t.acct_cls_dte IS NULL
					THEN 1
				ELSE 0
				END AS 'OpenAccounts'
			,CASE 
				WHEN t.acct_cls_dte IS NULL
					THEN t.dec010_val
				ELSE 0
				END AS 'OpenInitialValue'
			,CASE 
				WHEN t.acct_cls_dte IS NULL
					THEN t.dec001_val
				ELSE 0
				END AS 'LatestMarketValue'
			,CASE 
				WHEN t.acct_cls_dte IS NOT NULL
					THEN 1
				ELSE 0
				END AS 'ClosedAccounts'
			,CASE 
				WHEN t.acct_cls_dte IS NOT NULL
					THEN t.dec010_val
				ELSE 0
				END AS 'ClosedInitialValue'
			,CASE 
				WHEN t.acct_cls_dte IS NOT NULL
					THEN t.dec009_val
				ELSE 0
				END AS 'AccountCloseValue'
		FROM dbo.accounttotalview t
		INNER JOIN #tempacct tmpact ON tmpact.acct_id = t.acct_id
		WHERE CONVERT(CHAR(10), t.end_tms, 121) = CONVERT(CHAR(10), @start_tms, 121)

		--Note: We are using the dynamic query because the columns to select not fixed in advance. These can be changed dynamically from the interface.
		SELECT @sql_txt1 = 'select ''1'',' + @sql_txt1 + ' from #ActTotal A ' + '' + @grp_txt1 + @filter_txt1 + @sort_txt1
		/*Start RZkumar     09162013*/ 
		--Make sure that SQL Inject 
		if	charindex('drop',@sql_txt1) > 0 or
			charindex('delete',@sql_txt1) > 0 or	
			charindex('update',@sql_txt1) > 0 or	
			charindex('truncate',@sql_txt1) > 0 or	
			charindex('grant',@sql_txt1) > 0 
		BEGIN
			SET @msg = 'Invalid SQL statment -drop/delete/update/truncate/grant found in the SQL statement'

			RAISERROR (
						@msg
						,16
						,1
						);
		END				
	/*End RZkumar     09162013*/ 
		IF @row_limit > 0
			SELECT @sql_txt1 = @row_count_str + ' ' + @sql_txt1 + ' set rowcount 0 '

		EXECUTE sp_executesql @sql_txt1;
	END TRY

	BEGIN CATCH
		DECLARE @errmsg NVARCHAR(2048)
			,@errsev INT
			,@errstate INT;

		SET @errno = ERROR_NUMBER()
		SET @errmsg = ERROR_MESSAGE()
		SET @errsev = ERROR_SEVERITY()
		SET @errstate = ERROR_STATE();

		RAISERROR (
				@errmsg
				,@errsev
				,@errstate
				)
	END CATCH

	RETURN @errno
END /*----Procedure Begin*/
GO

-- Validate if procedure has been created.
IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.ROUTINES
		WHERE SPECIFIC_SCHEMA = N'dbo'
			AND SPECIFIC_NAME = N'p_AcctTotList_Dynamic_SMAA'
		)
BEGIN
	PRINT 'PROCEDURE dbo.p_AcctTotList_Dynamic_SMAA has been created.';
END;
ELSE
BEGIN
	PRINT 'PROCEDURE dbo.p_AcctTotList_Dynamic_SMAA has NOT been created.'
END;
GO

GRANT EXECUTE
	ON dbo.p_AcctTotList_Dynamic_SMAA
	TO netikapp_user
GO


