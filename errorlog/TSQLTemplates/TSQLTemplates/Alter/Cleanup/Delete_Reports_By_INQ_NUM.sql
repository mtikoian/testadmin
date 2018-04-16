USE NetikIP --Change database name
GO

/* ----------------------------------------------------------------------------------------------------
 JIRA#					: MDB-5124 
 File Name				: Delete_Reports_By_INQ_NUM.sql
 Business Description   : To delete old reports from database.
 Created By				: vperala
 Created Date			: 08/20/2014
 ------------------------------------------------------------------------------------------------------
 */ 
 

PRINT '-------------Script Started at	 :' +  convert(char(23),getdate(),121) + '------------------------';
PRINT SPACE(100);

BEGIN TRY
	BEGIN TRANSACTION;
	---------------------------Start---------------------------------------
	--Writes SQL statement 
	DECLARE @TBL_INQ_NUM TABLE(INQ_NUM INT NOT NULL PRIMARY KEY);

	INSERT INTO @TBL_INQ_NUM(INQ_NUM) 
		SELECT INQ_NUM
		FROM dbo.inq_def 
		where INQ_NUM in
		(14043,14103,14104,14106,14107,14108,14109,14110,14111,14112
		,14113,14114,14115,14116,14118,14119,14120,14158,15197,15198
		,15291,15292,15293,15294,15295,15296,15297,15298,15299,15300
		,15301,15302,15303,15304,15305,15306,15307,15308,15309,15310
		,15311,15313,15314,15315,15316,15317,15318,15319,15320,15321
		,15322,15323,15324,15325,15326,15327,15328,15329,15330,15331
		,15332,15333,15521,15522,15523,15524,15525,15526,15527,15528
		,15529,15530,15531,15532,15533,15542,15543,15544,15545,15546
		,15747,15749,16150,16547
		);

	--Step1: Delete from dbo.sei_execution 
	DELETE a 
	FROM dbo.sei_execution a  
	INNER JOIN dbo.sei_schedule b 
		ON 
			b.schedule_id = a.schedule_id
	INNER JOIN @TBL_INQ_NUM c
		ON 
			b.inq_num = c.inq_num;

	--Step2: Delete from dbo.sei_schedule 
	DELETE b 
	FROM dbo.sei_schedule b 
	INNER JOIN @TBL_INQ_NUM c
		ON 
			b.inq_num = c.inq_num;

	--Step3: Delete from dbo.sei_chart_palette
	DELETE a 
	FROM dbo.sei_chart_palette a  
	INNER JOIN dbo.sei_chart_def b 
		ON 
			b.chart_def_id = a.chart_def_id
	INNER JOIN @TBL_INQ_NUM c
		ON 
			b.inq_num = c.inq_num;

	--Step4: Delete from dbo.sei_chart_def
	DELETE b 
	FROM dbo.sei_chart_def b 
	INNER JOIN @TBL_INQ_NUM c
		ON 
			b.inq_num = c.inq_num;

	--Step5: Delete from dbo.inq_def
	DELETE b 
	FROM dbo.inq_def b 
	INNER JOIN @TBL_INQ_NUM c
		ON 
			b.inq_num = c.inq_num;

	---------------------------End------------------------------------------
	PRINT SPACE(100);
	COMMIT TRANSACTION;		
	PRINT 'Transaction COMMIT successfully';
		
END TRY
BEGIN CATCH

	PRINT 'Error occured in script';
    ROLLBACK TRANSACTION;
	PRINT 'Transaction ROLLBACK successfully';

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