USE NETIKdP
GO

SET NOCOUNT ON

DECLARE @Error INTEGER;
DECLARE @Rowcount BIGINT;
	DECLARE @DATA_CLS_NUM INT
SET @Rowcount = 0;


	SET @DATA_CLS_NUM = 100;

BEGIN TRY
	BEGIN TRANSACTION



	--SELECT @DATA_CLS_NUM = ISNULL(MAX(DATA_CLS_NUM),0)  + 1 FROM [dbo].[DATA_CLASS]
	--INSERT [dbo].[DATA_CLASS] ([DATA_CLS_NUM], [DATA_CLS_NME], [DATA_CLS_DESC], [NLS_CDE], [DATA_CLS_TYP], [DATA_TYP_NUM], [LST_CHG_TMS], [LST_CHG_USR_ID], [RESERV_IND], [DV_FEAT_IND], [APP_ID], [DV_SORT_OPTN]) VALUES (@DATA_CLS_NUM, N'ISO Country Definition', N'ISO Country Definition', N'ENG     ', N'code    ', 1, NULL, N'ADMIN   ', N'Y', NULL, N'DW          ', NULL)
	/****** Object:  Table [dbo].[DOMAIN_VALUE]    Script Date: 07/24/2013 16:39:42 ******/
	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ABW         '
		,N'Aruba'
		,N'Aruba'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,1
		)
		SET @RowCount = @RowCount + @@ROWCOUNT

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'AFG         '
		,N'Afghanistan'
		,N'Afghanistan'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,2
		)
SET @RowCount = @RowCount + @@ROWCOUNT
	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'AGO         '
		,N'Angola'
		,N'Angola'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,3
		)
SET @RowCount = @RowCount + @@ROWCOUNT
	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'AIA         '
		,N'Anguilla'
		,N'Anguilla'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,4
		)
SET @RowCount = @RowCount + @@ROWCOUNT
	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ALA         '
		,N'Åland Islands'
		,N'Åland Islands'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,5
		)
SET @RowCount = @RowCount + @@ROWCOUNT
	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ALB         '
		,N'Albania'
		,N'Albania'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,6
		)
SET @RowCount = @RowCount + @@ROWCOUNT
	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'AND         '
		,N'Andorra'
		,N'Andorra'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,7
		)
SET @RowCount = @RowCount + @@ROWCOUNT
	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ARE         '
		,N'United Arab Emirates'
		,N'United Arab Emirates'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,8
		)
SET @RowCount = @RowCount + @@ROWCOUNT
	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ARG         '
		,N'Argentina'
		,N'Argentina'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,9
		)
SET @RowCount = @RowCount + @@ROWCOUNT
	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ARM         '
		,N'Armenia'
		,N'Armenia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,10
		)
SET @RowCount = @RowCount + @@ROWCOUNT
	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ASM         '
		,N'American Samoa'
		,N'American Samoa'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,11
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ATA         '
		,N'Antarctica'
		,N'Antarctica'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,12
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ATF         '
		,N'French Southern Territories'
		,N'French Southern Territories'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,13
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ATG         '
		,N'Antigua and Barbuda'
		,N'Antigua and Barbuda'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,14
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'AUS         '
		,N'Australia'
		,N'Australia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,15
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'AUT         '
		,N'Austria'
		,N'Austria'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,16
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'AZE         '
		,N'Azerbaijan'
		,N'Azerbaijan'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,17
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BDI         '
		,N'Burundi'
		,N'Burundi'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,18
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BEL         '
		,N'Belgium'
		,N'Belgium'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,19
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BEN         '
		,N'Benin'
		,N'Benin'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,20
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BES         '
		,N'Bonaire, Sint Eustatius and Saba'
		,N'Bonaire, Sint Eustatius and Saba'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,21
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BFA         '
		,N'Burkina Faso'
		,N'Burkina Faso'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,22
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BGD         '
		,N'Bangladesh'
		,N'Bangladesh'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,23
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BGR         '
		,N'Bulgaria'
		,N'Bulgaria'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,24
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BHR         '
		,N'Bahrain'
		,N'Bahrain'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,25
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BHS         '
		,N'Bahamas'
		,N'Bahamas'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,26
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BIH         '
		,N'Bosnia and Herzegovina'
		,N'Bosnia and Herzegovina'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,27
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BLM         '
		,N'Saint Barthélemy'
		,N'Saint Barthélemy'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,28
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BLR         '
		,N'Belarus'
		,N'Belarus'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,29
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BLZ         '
		,N'Belize'
		,N'Belize'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,30
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BMU         '
		,N'Bermuda'
		,N'Bermuda'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,31
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BOL         '
		,N'Bolivia, Plurinational State of'
		,N'Bolivia, Plurinational State of'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,32
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BRA         '
		,N'Brazil'
		,N'Brazil'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,33
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BRB         '
		,N'Barbados'
		,N'Barbados'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,34
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BRN         '
		,N'Brunei Darussalam'
		,N'Brunei Darussalam'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,35
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BTN         '
		,N'Bhutan'
		,N'Bhutan'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,36
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BVT         '
		,N'Bouvet Island'
		,N'Bouvet Island'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,37
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'BWA         '
		,N'Botswana'
		,N'Botswana'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,38
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CAF         '
		,N'Central African Republic'
		,N'Central African Republic'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,39
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CAN         '
		,N'Canada'
		,N'Canada'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,40
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CCK         '
		,N'Cocos (Keeling) Islands'
		,N'Cocos (Keeling) Islands'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,41
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CHE         '
		,N'Switzerland'
		,N'Switzerland'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,42
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CHL         '
		,N'Chile'
		,N'Chile'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,43
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CHN         '
		,N'China'
		,N'China'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,44
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CIV         '
		,N'Côte d''Ivoire'
		,N'Côte d''Ivoire'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,45
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CMR         '
		,N'Cameroon'
		,N'Cameroon'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,46
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'COD         '
		,N'Congo, the Democratic Republic of the'
		,N'Congo, the Democratic Republic of the'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,47
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'COG         '
		,N'Congo'
		,N'Congo'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,48
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'COK         '
		,N'Cook Islands'
		,N'Cook Islands'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,49
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'COL         '
		,N'Colombia'
		,N'Colombia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,50
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'COM         '
		,N'Comoros'
		,N'Comoros'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,51
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CPV         '
		,N'Cape Verde'
		,N'Cape Verde'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,52
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CRI         '
		,N'Costa Rica'
		,N'Costa Rica'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,53
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CUB         '
		,N'Cuba'
		,N'Cuba'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,54
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CUW         '
		,N'Curaçao'
		,N'Curaçao'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,55
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CXR         '
		,N'Christmas Island'
		,N'Christmas Island'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,56
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CYM         '
		,N'Cayman Islands'
		,N'Cayman Islands'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,57
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CYP         '
		,N'Cyprus'
		,N'Cyprus'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,58
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'CZE         '
		,N'Czech Republic'
		,N'Czech Republic'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,59
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'DEU         '
		,N'Germany'
		,N'Germany'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,60
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'DJI         '
		,N'Djibouti'
		,N'Djibouti'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,61
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'DMA         '
		,N'Dominica'
		,N'Dominica'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,62
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'DNK         '
		,N'Denmark'
		,N'Denmark'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,63
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'DOM         '
		,N'Dominican Republic'
		,N'Dominican Republic'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,64
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'DZA         '
		,N'Algeria'
		,N'Algeria'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,65
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ECU         '
		,N'Ecuador'
		,N'Ecuador'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,66
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'EGY         '
		,N'Egypt'
		,N'Egypt'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,67
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ERI         '
		,N'Eritrea'
		,N'Eritrea'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,68
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ESH         '
		,N'Western Sahara'
		,N'Western Sahara'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,69
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ESP         '
		,N'Spain'
		,N'Spain'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,70
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'EST         '
		,N'Estonia'
		,N'Estonia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,71
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ETH         '
		,N'Ethiopia'
		,N'Ethiopia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,72
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'FIN         '
		,N'Finland'
		,N'Finland'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,73
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'FJI         '
		,N'Fiji'
		,N'Fiji'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,74
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'FLK         '
		,N'Falkland Islands (Malvinas)'
		,N'Falkland Islands (Malvinas)'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,75
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'FRA         '
		,N'France'
		,N'France'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,76
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'FRO         '
		,N'Faroe Islands'
		,N'Faroe Islands'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,77
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'FSM         '
		,N'Micronesia, Federated States of'
		,N'Micronesia, Federated States of'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,78
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GAB         '
		,N'Gabon'
		,N'Gabon'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,79
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GBR         '
		,N'United Kingdom'
		,N'United Kingdom'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,80
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GEO         '
		,N'Georgia'
		,N'Georgia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,81
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GGY         '
		,N'Guernsey'
		,N'Guernsey'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,82
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GHA         '
		,N'Ghana'
		,N'Ghana'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,83
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GIB         '
		,N'Gibraltar'
		,N'Gibraltar'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,84
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GIN         '
		,N'Guinea'
		,N'Guinea'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,85
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GLP         '
		,N'Guadeloupe'
		,N'Guadeloupe'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,86
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GMB         '
		,N'Gambia'
		,N'Gambia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,87
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GNB         '
		,N'Guinea-Bissau'
		,N'Guinea-Bissau'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,88
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GNQ         '
		,N'Equatorial Guinea'
		,N'Equatorial Guinea'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,89
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GRC         '
		,N'Greece'
		,N'Greece'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,90
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GRD         '
		,N'Grenada'
		,N'Grenada'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,91
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GRL         '
		,N'Greenland'
		,N'Greenland'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,92
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GTM         '
		,N'Guatemala'
		,N'Guatemala'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,93
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GUF         '
		,N'French Guiana'
		,N'French Guiana'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,94
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GUM         '
		,N'Guam'
		,N'Guam'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,95
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'GUY         '
		,N'Guyana'
		,N'Guyana'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,96
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'HKG         '
		,N'Hong Kong'
		,N'Hong Kong'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,97
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'HMD         '
		,N'Heard Island and McDonald Islands'
		,N'Heard Island and McDonald Islands'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,98
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'HND         '
		,N'Honduras'
		,N'Honduras'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,99
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'HRV         '
		,N'Croatia'
		,N'Croatia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,100
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'HTI         '
		,N'Haiti'
		,N'Haiti'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,101
		)

	--PRINT 'Processed 100 total records'

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'HUN         '
		,N'Hungary'
		,N'Hungary'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,102
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'IDN         '
		,N'Indonesia'
		,N'Indonesia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,103
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'IMN         '
		,N'Isle of Man'
		,N'Isle of Man'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,104
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'IND         '
		,N'India'
		,N'India'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,105
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'IOT         '
		,N'British Indian Ocean Territory'
		,N'British Indian Ocean Territory'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,106
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'IRL         '
		,N'Ireland'
		,N'Ireland'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,107
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'IRN         '
		,N'Iran, Islamic Republic of'
		,N'Iran, Islamic Republic of'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,108
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'IRQ         '
		,N'Iraq'
		,N'Iraq'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,109
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ISL         '
		,N'Iceland'
		,N'Iceland'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,110
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ISR         '
		,N'Israel'
		,N'Israel'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,111
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ITA         '
		,N'Italy'
		,N'Italy'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,112
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'JAM         '
		,N'Jamaica'
		,N'Jamaica'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,113
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'JEY         '
		,N'Jersey'
		,N'Jersey'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,114
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'JOR         '
		,N'Jordan'
		,N'Jordan'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,115
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'JPN         '
		,N'Japan'
		,N'Japan'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,116
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'KAZ         '
		,N'Kazakhstan'
		,N'Kazakhstan'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,117
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'KEN         '
		,N'Kenya'
		,N'Kenya'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,118
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'KGZ         '
		,N'Kyrgyzstan'
		,N'Kyrgyzstan'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,119
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'KHM         '
		,N'Cambodia'
		,N'Cambodia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,120
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'KIR         '
		,N'Kiribati'
		,N'Kiribati'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,121
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'KNA         '
		,N'Saint Kitts and Nevis'
		,N'Saint Kitts and Nevis'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,122
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'KOR         '
		,N'Korea, Republic of'
		,N'Korea, Republic of'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,123
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'KWT         '
		,N'Kuwait'
		,N'Kuwait'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,124
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'LAO         '
		,N'Lao People''s Democratic Republic'
		,N'Lao People''s Democratic Republic'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,125
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'LBN         '
		,N'Lebanon'
		,N'Lebanon'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,126
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'LBR         '
		,N'Liberia'
		,N'Liberia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,127
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'LBY         '
		,N'Libya'
		,N'Libya'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,128
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'LCA         '
		,N'Saint Lucia'
		,N'Saint Lucia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,129
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'LIE         '
		,N'Liechtenstein'
		,N'Liechtenstein'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,130
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'LKA         '
		,N'Sri Lanka'
		,N'Sri Lanka'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,131
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'LSO         '
		,N'Lesotho'
		,N'Lesotho'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,132
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'LTU         '
		,N'Lithuania'
		,N'Lithuania'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,133
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'LUX         '
		,N'Luxembourg'
		,N'Luxembourg'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,134
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'LVA         '
		,N'Latvia'
		,N'Latvia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,135
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MAC         '
		,N'Macao'
		,N'Macao'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,136
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MAF         '
		,N'Saint Martin (French part)'
		,N'Saint Martin (French part)'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,137
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MAR         '
		,N'Morocco'
		,N'Morocco'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,138
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MCO         '
		,N'Monaco'
		,N'Monaco'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,139
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MDA         '
		,N'Moldova, Republic of'
		,N'Moldova, Republic of'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,140
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MDG         '
		,N'Madagascar'
		,N'Madagascar'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,141
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MDV         '
		,N'Maldives'
		,N'Maldives'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,142
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MEX         '
		,N'Mexico'
		,N'Mexico'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,143
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MHL         '
		,N'Marshall Islands'
		,N'Marshall Islands'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,144
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MKD         '
		,N''
		,N'Macedonia, the former Yugoslav Republic of'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,145
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MLI         '
		,N'Mali'
		,N'Mali'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,146
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MLT         '
		,N'Malta'
		,N'Malta'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,147
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MMR         '
		,N'Myanmar'
		,N'Myanmar'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,148
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MNE         '
		,N'Montenegro'
		,N'Montenegro'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,149
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MNG         '
		,N'Mongolia'
		,N'Mongolia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,150
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MNP         '
		,N'Northern Mariana Islands'
		,N'Northern Mariana Islands'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,151
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MOZ         '
		,N'Mozambique'
		,N'Mozambique'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,152
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MRT         '
		,N'Mauritania'
		,N'Mauritania'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,153
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MSR         '
		,N'Montserrat'
		,N'Montserrat'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,154
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MTQ         '
		,N'Martinique'
		,N'Martinique'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,155
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MUS         '
		,N'Mauritius'
		,N'Mauritius'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,156
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MWI         '
		,N'Malawi'
		,N'Malawi'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,157
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MYS         '
		,N'Malaysia'
		,N'Malaysia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,158
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'MYT         '
		,N'Mayotte'
		,N'Mayotte'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,159
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'NAM         '
		,N'Namibia'
		,N'Namibia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,160
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'NCL         '
		,N'New Caledonia'
		,N'New Caledonia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,161
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'NER         '
		,N'Niger'
		,N'Niger'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,162
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'NFK         '
		,N'Norfolk Island'
		,N'Norfolk Island'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,163
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'NGA         '
		,N'Nigeria'
		,N'Nigeria'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,164
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'NIC         '
		,N'Nicaragua'
		,N'Nicaragua'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,165
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'NIU         '
		,N'Niue'
		,N'Niue'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,166
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'NLD         '
		,N'Netherlands'
		,N'Netherlands'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,167
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'NOR         '
		,N'Norway'
		,N'Norway'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,168
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'NPL         '
		,N'Nepal'
		,N'Nepal'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,169
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'NRU         '
		,N'Nauru'
		,N'Nauru'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,170
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'NZL         '
		,N'New Zealand'
		,N'New Zealand'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,171
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'OMN         '
		,N'Oman'
		,N'Oman'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,172
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'PAK         '
		,N'Pakistan'
		,N'Pakistan'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,173
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'PAN         '
		,N'Panama'
		,N'Panama'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,174
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'PCN         '
		,N'Pitcairn'
		,N'Pitcairn'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,175
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'PER         '
		,N'Peru'
		,N'Peru'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,176
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'PHL         '
		,N'Philippines'
		,N'Philippines'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,177
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'PLW         '
		,N'Palau'
		,N'Palau'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,178
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'PNG         '
		,N'Papua New Guinea'
		,N'Papua New Guinea'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,179
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'POL         '
		,N'Poland'
		,N'Poland'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,180
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'PRI         '
		,N'Puerto Rico'
		,N'Puerto Rico'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,181
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'PRK         '
		,N'Korea, Democratic People''s Republic of'
		,N'Korea, Democratic People''s Republic of'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,182
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'PRT         '
		,N'Portugal'
		,N'Portugal'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,183
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'PRY         '
		,N'Paraguay'
		,N'Paraguay'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,184
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'PSE         '
		,N'Palestine, State of'
		,N'Palestine, State of'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,185
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'PYF         '
		,N'French Polynesia'
		,N'French Polynesia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,186
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'QAT         '
		,N'Qatar'
		,N'Qatar'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,187
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'REU         '
		,N'Réunion'
		,N'Réunion'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,188
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ROU         '
		,N'Romania'
		,N'Romania'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,189
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'RUS         '
		,N'Russian Federation'
		,N'Russian Federation'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,190
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'RWA         '
		,N'Rwanda'
		,N'Rwanda'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,191
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SAU         '
		,N'Saudi Arabia'
		,N'Saudi Arabia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,192
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SDN         '
		,N'Sudan'
		,N'Sudan'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,193
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SEN         '
		,N'Senegal'
		,N'Senegal'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,194
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SGP         '
		,N'Singapore'
		,N'Singapore'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,195
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SGS         '
		,N''
		,N'South Georgia and the South Sandwich Islands'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,196
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SHN         '
		,N''
		,N'Saint Helena, Ascension and Tristan da Cunha'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,197
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SJM         '
		,N'Svalbard and Jan Mayen'
		,N'Svalbard and Jan Mayen'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,198
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SLB         '
		,N'Solomon Islands'
		,N'Solomon Islands'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,199
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SLE         '
		,N'Sierra Leone'
		,N'Sierra Leone'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,200
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SLV         '
		,N'El Salvador'
		,N'El Salvador'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,201
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SMR         '
		,N'San Marino'
		,N'San Marino'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,202
		)

	--PRINT 'Processed 200 total records'

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SOM         '
		,N'Somalia'
		,N'Somalia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,203
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SPM         '
		,N'Saint Pierre and Miquelon'
		,N'Saint Pierre and Miquelon'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,204
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SRB         '
		,N'Serbia'
		,N'Serbia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,205
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SSD         '
		,N'South Sudan'
		,N'South Sudan'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,206
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'STP         '
		,N'Sao Tome and Principe'
		,N'Sao Tome and Principe'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,207
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SUR         '
		,N'Suriname'
		,N'Suriname'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,208
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SVK         '
		,N'Slovakia'
		,N'Slovakia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,209
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SVN         '
		,N'Slovenia'
		,N'Slovenia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,210
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SWE         '
		,N'Sweden'
		,N'Sweden'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,211
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SWZ         '
		,N'Swaziland'
		,N'Swaziland'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,212
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SXM         '
		,N'Sint Maarten (Dutch part)'
		,N'Sint Maarten (Dutch part)'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,213
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SYC         '
		,N'Seychelles'
		,N'Seychelles'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,214
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'SYR         '
		,N'Syrian Arab Republic'
		,N'Syrian Arab Republic'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,215
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'TCA         '
		,N'Turks and Caicos Islands'
		,N'Turks and Caicos Islands'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,216
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'TCD         '
		,N'Chad'
		,N'Chad'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,217
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'TGO         '
		,N'Togo'
		,N'Togo'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,218
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'THA         '
		,N'Thailand'
		,N'Thailand'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,219
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'TJK         '
		,N'Tajikistan'
		,N'Tajikistan'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,220
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'TKL         '
		,N'Tokelau'
		,N'Tokelau'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,221
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'TKM         '
		,N'Turkmenistan'
		,N'Turkmenistan'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,222
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'TLS         '
		,N'Timor-Leste'
		,N'Timor-Leste'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,223
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'TON         '
		,N'Tonga'
		,N'Tonga'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,224
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'TTO         '
		,N'Trinidad and Tobago'
		,N'Trinidad and Tobago'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,225
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'TUN         '
		,N'Tunisia'
		,N'Tunisia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,226
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'TUR         '
		,N'Turkey'
		,N'Turkey'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,227
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'TUV         '
		,N'Tuvalu'
		,N'Tuvalu'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,228
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'TWN         '
		,N'Taiwan, Province of China'
		,N'Taiwan, Province of China'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,229
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'TZA         '
		,N'Tanzania, United Republic of'
		,N'Tanzania, United Republic of'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,230
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'UGA         '
		,N'Uganda'
		,N'Uganda'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,231
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'UKR         '
		,N'Ukraine'
		,N'Ukraine'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,232
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'UMI         '
		,N'United States Minor Outlying Islands'
		,N'United States Minor Outlying Islands'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,233
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'URY         '
		,N'Uruguay'
		,N'Uruguay'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,234
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'USA         '
		,N'United States'
		,N'United States'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,235
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'UZB         '
		,N'Uzbekistan'
		,N'Uzbekistan'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,236
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'VAT         '
		,N'Holy See (Vatican City State)'
		,N'Holy See (Vatican City State)'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,237
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'VCT         '
		,N'Saint Vincent and the Grenadines'
		,N'Saint Vincent and the Grenadines'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,238
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'VEN         '
		,N'Venezuela, Bolivarian Republic of'
		,N'Venezuela, Bolivarian Republic of'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,239
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'VGB         '
		,N'Virgin Islands, British'
		,N'Virgin Islands, British'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,240
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'VIR         '
		,N'Virgin Islands, U.S.'
		,N'Virgin Islands, U.S.'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,241
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'VNM         '
		,N'Viet Nam'
		,N'Viet Nam'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,242
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'VUT         '
		,N'Vanuatu'
		,N'Vanuatu'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,243
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'WLF         '
		,N'Wallis and Futuna'
		,N'Wallis and Futuna'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,244
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'WSM         '
		,N'Samoa'
		,N'Samoa'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,245
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'YEM         '
		,N'Yemen'
		,N'Yemen'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,246
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ZAF         '
		,N'South Africa'
		,N'South Africa'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,247
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ZMB         '
		,N'Zambia'
		,N'Zambia'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,248
		)

	INSERT [dbo].[DOMAIN_VALUE] (
		[DATA_CLS_NUM]
		,[INTRL_DMN_VAL_ID]
		,[FLD_DATA_CL_ID]
		,[NLS_CDE]
		,[FLD_ID]
		,[DMV_VALUE]
		,[DMV_NME]
		,[DMV_DESC]
		,[LST_CHG_TMS]
		,[LST_CHG_USR_ID]
		,[ORG_ID]
		,[WGHT_FCTR_NUM]
		,[DMV1_IND]
		,[DMV2_IND]
		,[DMV3_IND]
		,[DMV4_IND]
		,[DMV5_IND]
		,[DMV_VAL_SEQ]
		)
	VALUES (
		@DATA_CLS_NUM
		,NULL
		,NULL
		,N'ENG     '
		,NULL
		,N'ZWE         '
		,N'Zimbabwe'
		,N'Zimbabwe'
		,GETDATE()
		,N'ADMIN   '
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,NULL
		,249
		)
		
SET @RowCount = @RowCount + @@ROWCOUNT
	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION;

		PRINT REPLICATE('*', 60)
		PRINT 'Total Records Inserted = ' + cast(@RowCount AS VARCHAR(10));
		PRINT REPLICATE('*', 60)
	END
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0 OR Xact_state() <> 0
		ROLLBACK TRANSACTION;

	SET @Error = ERROR_NUMBER();

	RAISERROR (
			'Error during Insertion'
			,16
			,1
			);

	SELECT ERROR_NUMBER() AS ErrorNumber
		,ERROR_MESSAGE() AS ErrorMessage;
END CATCH

IF @Error <> 0
BEGIN
	IF @@TRANCOUNT <> 0
		ROLLBACK TRANSACTION;
END;
