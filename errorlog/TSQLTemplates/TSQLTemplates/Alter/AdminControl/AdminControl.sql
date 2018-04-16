--User aa for Admin control

exec dw_Role_List 
exec Sp_Explorer_List 
exec dw_MenuFunction_byRole 30605
exec dw_RoleFunction_Insert 'Pending Transaction – Dealboard Detail','Pending Transaction – Dealboard Detail',0,'FNI_014929'
exec dw_RoleFunctionXref_Insert 3088,30605,1
exec dw_RoleFunction_Insert 'Pending Transaction – Dealboard Summary','Pending Transaction – Dealboard Summary',0,'FNI_014930'
exec dw_RoleFunctionXref_Insert 3089,30605,1
exec dw_MenuFunction_byRole 30605




exec sp_Inquiry 'SELECT',17005
exec sp_Inquiry 'SELECT',13874

select * from query_param_Def where typ_qry_rpt_num = 17005
select * from query_param_Def where typ_qry_rpt_num = 13874
sp_setappuser 'ndev01'

exec P_MDB_PERF_LISTDYN_GET '1260-3-4255a','HF','SEI',1,'2014-06-30 23:59:59',default,'2014-06-30 23:59:59',default,'NAM-P',4,0,16706,16706,'(case when rtn_typ in (1,2) then rtn_typ_nme when rtn_typ in (10,11,12) then benchmark_name else key_descr end), A.end_acc_bk + ending_market_value_book, (isnull(rtrim(mtd),'''')), (isnull(rtrim(qtd),'''')), (isnull(rtrim(ytd),'''')), (isnull(rtrim(one_year),'''')), (isnull(rtrim(three_year),'''')), (isnull(rtrim(five_year),'''')), (isnull(rtrim(seven_year),'''')), (isnull(rtrim(ten_year),'''')), (isnull(rtrim(itdc),'''')), (isnull(rtrim(itda),0))',default,default,default,0,default
exec dw_Inqrunval_Select 17005,17005
exec sp_QueryParam_List 'I','S',17005,0
exec dw_ChtDef_Select 17005,17005

exec dw_Inqrunval_Select 13874,13874
exec sp_FldInInq 'SELECT',13874
exec sp_FldInInq 'SELECT',17005