declare @inq_num int
 declare @inq_num2 int
 declare @inq_num3 int

 set  @inq_num = 15309
 set  @inq_num2 = 15310
 set  @inq_num3 = 15312


DELETE  from DW_FUNCTION_ITEM where INQ_NUM IN (@inq_num,@inq_num2,@inq_num3)
DELETE  from DW_INQRUNVAL_DEF where INQ_NUM IN (@inq_num,@inq_num2,@inq_num3)
DELETE  from DSP_DATE_LIST where  TYP_QRY_RPT_NUM in (120, 121)
DELETE  from QUERY_PARAM_DEF where typ_qry_rpt_num IN (@inq_num,@inq_num2,@inq_num3)
delete a from sei_execution a  
inner join sei_schedule b on 
b.schedule_id = a.schedule_id
inner join sei_chart_def c
on b.inq_num = c.inq_num
where c.inq_num in (@inq_num,@inq_num2,@inq_num3)



delete b from sei_execution a  
inner join sei_schedule b on 
b.schedule_id = a.schedule_id
inner join sei_chart_def c
on b.inq_num = c.inq_num
where c.inq_num in (@inq_num,@inq_num2,@inq_num3)

delete c from sei_execution a  
inner join sei_schedule b on 
b.schedule_id = a.schedule_id
inner join sei_chart_def c
on b.inq_num = c.inq_num
where c.inq_num in (@inq_num,@inq_num2,@inq_num3)


delete  from sei_schedule where inq_num in (@inq_num,@inq_num2,@inq_num3)
delete  from sei_chart_def where inq_num in (@inq_num,@inq_num2,@inq_num3)
 delete from inq_def
 --output deleted.*
 where inq_num in (15309
,15310
,15312)