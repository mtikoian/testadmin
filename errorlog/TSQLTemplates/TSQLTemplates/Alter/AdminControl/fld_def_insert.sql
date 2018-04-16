USE [NetikIP]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[sp_FieldDef]
		@Tran = 'INSERT',
		@Order = 0,
		@entity_num = 3,
		@fld_num = 0,
		@seq_num = 0,
		@internl_name = 'ClosingMethod',
		@fld_bus_nme = 'ClosingMethod',
		@fld_desc ='AccountSleeve ClosingMethod',
		@fld_nme = 'ClosingMethod',
		@nls_cde = 'ENG',
		@data_cls_num = 0,
		@data_cls_typ = default, 
		@grid_width_num = 10,
		@grid_align_num = 0,
		@sort_opt_typ = default,
		@formula_txt = default,
		@format_opt_num = 0,
		@total_opt_num = 0,
		@format_txt = default,
		@group_by_ind = 0,
		@group_by_meth = default,
		@data_typ_num = 1,
		@formula_ind = 0,
		@chart_typ_num = 0,
		@filter_suppress_ind = 0,
		@formula_id = 1,
		@show_ind = 1

SELECT	'Return Value' = @return_value

GO