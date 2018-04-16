USE NETIKIP;--Change database name
GO

/* ----------------------------------------------------------------------------------------------------
 JIRA#					: MDB-4977
 File Name				: Update Fld_Def MDB_4977
 Business Description   : Update the internl_name of multiple USD fields
 Created By				: Patrick Hart
 Created Date			: 9.22.14
 ------------------------------------------------------------------------------------------------------
 */
PRINT '-------------Script Started at	 :' + convert(CHAR(23), getdate(), 121) + '------------------------';
PRINT SPACE(100);

BEGIN TRY
	BEGIN TRANSACTION;

	---------------------------Start---------------------------------------
		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	
	WHERE fld_bus_nme = 'Unit Cost (USD)'
		AND entity_num = '1'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	
	WHERE fld_bus_nme = 'Unit Price (USD)'
		AND entity_num = '1'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	
	WHERE fld_bus_nme = 'Original Cost (USD)'
		AND entity_num = '1'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	
	WHERE fld_bus_nme = 'Unrealized G/L (USD)'
		AND entity_num = '1'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Market Value (USD)'
		AND entity_num = '1'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Accrued Income (USD)'
		AND entity_num = '1'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Market Value with Accd Inc (USD)'
		AND entity_num = '1'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Unit Cost (USD)'
		AND entity_num = '4'
	SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Unit Price (USD)'
		AND entity_num = '4'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'FX Rate (Local/USD)'
		AND entity_num = '4'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Market Value (USD)'
		AND entity_num = '4'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Accrued Income (USD)'
		AND entity_num = '4'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Market Value with Accd Inc (USD)'
		AND entity_num = '4'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Cost FX Rate (Local/USD)'
		AND entity_num = '4'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Original Cost (USD)'
		AND entity_num = '4'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Market Value (USD)'
		AND entity_num = '22'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Net Assets (USD)'
		AND entity_num = '22'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Equity Market Value (USD)'
		AND entity_num = '22'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Fixed Income Market Value (USD)'
		AND entity_num = '22'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Cash Balance (USD)'
		AND entity_num = '22'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Net Payable/Receivable (USD)'
		AND entity_num = '22'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Estimated Annual Income (USD)'
		AND entity_num = '22'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Currency Equivalent (USD)'
		AND entity_num = '22'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Other (USD)'
		AND entity_num = '22'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Market Value (USD)'
		AND entity_num = '10200'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Net Assets (USD)'
		AND entity_num = '10200'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Equity Market Value (USD)'
		AND entity_num = '10200'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Fixed Income Market Value (USD)'
		AND entity_num = '10200'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Cash Balance (USD)'
		AND entity_num = '10200'
	SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Net Payable/Receivable (USD)'
		AND entity_num = '10200'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Estimated Annual Income (USD)'
		AND entity_num = '10200'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Currency Equivalent (USD)'
		AND entity_num = '10200'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Other (USD)'
		AND entity_num = '10200'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'FX Rate (Base/USD)'
		AND entity_num = '10200'

		SELECT replace((
				replace('UPDATE 
		  dbo.FLD_DEF
		  SET 
		  INTERNL_NAME = <tag>' + cast(INTERNL_NAME AS VARCHAR(max)) + '<tag>' + ' where   
	 entity_num = ' + cast(entity_num AS VARCHAR) + '
	and FLD_NUM  = ' + cast(FLD_NUM AS VARCHAR) + '', '''', '''''')
				), '<tag>', '''')
	FROM [NETIKIP].[dbo].[FLD_DEF]
	WHERE fld_bus_nme = 'Total Accrued Income (USD)'
		AND entity_num = '10200'

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

	RAISERROR (
			@error_Message
			,@error_Severity
			,@error_State
			);
END CATCH;

PRINT SPACE(100);
PRINT '-------------Script completed at :' + convert(CHAR(23), getdate(), 121) + '------------------------';
