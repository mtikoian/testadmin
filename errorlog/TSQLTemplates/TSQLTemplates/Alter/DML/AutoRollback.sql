USE NetikIP
GO
/*
================================================================================================== 
* Copyright: This information constitutes the exclusive property of SEI
* Investments Company, and constitutes the confidential and proprietary
* information of SEI Investments Company.  The information shall not be
* used or disclosed for any purpose without the written consent of SEI 
* Investments Company.                 
================================================================================================== 
 File Name				: InvestorAddressSummaryDetailMDBMetadata.sql
 Description   			: Creates a new Report for Investor Address in Manager Dashboard                         
                          
 Created By    			: MSohail
 Created Date  			: 06/30/2014
 Modification History	: 
 ------------------------------------------------------------------------------
 Date		Modified By 		Description 
*/

BEGIN TRY	
	BEGIN TRAN
		DECLARE @inqNum INT,
		@entityNum INT,
		@inqTypNum INT,
		@roleId INT,
		@roleFnId INT;
		
		PRINT ''
		PRINT '----------------------------------------'
		PRINT '--Creating report "Investor Address Detail"'
		PRINT '----------------------------------------'

		SELECT @inqNum =     MAX(inq_num)+1 FROM INQ_DEF;
		SELECT @entityNum =  MAX(entity_num)+1 FROM ENTITY_DEF;
		SELECT @inqTypNum =  131; --MAX(inq_Typ_Num)+1 FROM INQ_TYPE		
		
		--Detail Report
		
		--ENTITY_DEF
		INSERT INTO ENTITY_DEF([ENTITY_NUM], [ENTITY_NME], [ENTITY_DESC], [ENTITY_TYP], [DATA_GRP_DEF_ID], [VIEW_ID], [USER_VIEW_ID], [NAV_INQ_NUM], [HOLD_INQ_NUM], [LST_CHG_TMS], [LST_CHG_USR_ID])
		VALUES (@entityNum,'Investor Address Reports','Investor Address Reports',null,null,'cds.v_InvestorAddress',null,0,0,getdate(),'ADMIN');
		
		--INQ_TYPE
		INSERT INTO INQ_TYPE([INQ_TYP_NUM], [INQ_TYP_NME], [INQ_TYP_TYP], [NLS_CDE], [LST_CHG_TMS], [LST_CHG_USR_ID])
		VALUES (@inqTypNum,'Investor Legal Address','INVADD','ENG',GETDATE(),'ADMIN');
		
		EXEC p_MDB_MOB_Inquiry_Insert
						 @inq_num=              @inqNum                                       
		                ,@inq_nme=              N'Investor Legal Address'                                   
		                ,@inq_desc=             N'Investor Legal Address'                              
		                ,@nls_cde=              N'ENG'                                        
		                ,@org_id=               N''                                           
		                ,@bk_id=                N''                                           
		                ,@acct_id=              N''                                                                 
		                ,@inq_typ_num=          @inqTypNum                                                                     
		                ,@entity_num=           @entityNum                                                                  
		                ,@inq_basis_num=        0                                                                           
		                ,@cls_set_id=           null                                                          
		                ,@user_id=              N'ADMIN'                                      
		                ,@stand_usr_ind=        N'S'                                          
		                ,@dte_typ_num=          0                                                                     
		                ,@dte_per_num=          0                                                                     
		                ,@end_date=             NULL                                                                           
		                ,@start_date=           NULL                                                                                  
		                ,@adjdte_typ_num=       0                                                                             
		                ,@adj_end_date=         NULL                                                                                        
		                ,@adj_start_date=       NULL                                                                                              
		                ,@trndte_typ_num=       0                                                                              
		                ,@startup_vw_num=       0                                                                             
		                ,@max_items_num=        0                                                                          
		                ,@prnt_inq_num=        @inqNum                                                                       
		                ,@list_inq_num=         0                                                                                    
		                ,@grid_ind_int=         0                                               
		                ,@row_ind_int=          0                                             
		                ,@color_row_ind_int=    1                                                    
		                ,@dim_ind_int=          0                                             
		                ,@freeze_ind_int=       0                                             
		                ,@freeze_col=           0                                                                          
		                ,@suprs_col=           0                                                                           
		                ,@sql_select_txt=       N'InvestorThirdPartyID,InvestorName,InvestorLegalAttention,InvestorLegalAttention2,InvestorLegalAddressLine1,InvestorLegalAddressLine2,
InvestorLegalAddressLine3,InvestorLegalAddressLine4,InvestorLegalAddressCity,InvestorLegalAddressState
,InvestorLegalAddressPostalCode,InvestorLegalAddressCountry'                                            
		                ,@sql_groupby_txt=      N''                                                         
		                ,@sql_orderby_txt=      N''                                                         
		                ,@sql_filter_txt=       null                                                                                                                          
		                ,@sp_txt=               N'cds.p_Ii_InvestorAddress'                                              
		                ,@sp_txt_MDB=           N''                                                          
		                ,@sp_ind_int=           0                                             
		                ,@ind1=                0                                              
		                ,@ind2=                 0                                             
		                ,@ind3=                1                                              
		                ,@xls_nme=              null                                                 
		                ,@sub_total_ind_int=    0                                                    
		                ,@total_ind_int=        0                                             
		                ,@query_ind_int=       0                                              
		                ,@item_cnt_ind_int=    0                                              
		                ,@cht_nme=             null                                                
		                ,@proj_per=             0                                                            
		                ,@proj_per_unit=        0                                                                           
		                ,@proj_sum_unit=        0                                                                           
		                ,@based_upon=           0                                             
		                ,@fund_id=             0                                                 
		                ,@shr_class_id=         0                                                                
		                ,@instr_id=            0                                                    
		                ,@acct_cab_ind=        0                                                                        
		                ,@dlg_xslname=          N'InvestorAddressRpt.xsl'                                                             
		                ,@dsp_xslname=          N'InvestorAddressRpt.xsl'                                                             
		                ,@shared_ind=           0                                                                  
		                ,@hdr_proc_nme=         null                                                                
		                ,@param_xmlstring=      N''                                           
		                ,@dashbrd_ind=          1                                                                     
		                ,@style_id=             0                                                            
		                ,@subtotal_posn=       0                                              
		                ,@allow_subtotal_ind=  1                                                  
		                ,@allow_grandtotal_ind= 1                                                     
		                ,@inq_notes=            N''                                                       
		                ,@allow_edit_select=    1                                                
		                ,@allow_edit_format=    1                                               
		                ,@allow_edit_filter=    1                                                
		                ,@allow_edit_advanced=  1                                                    
		                ,@allow_edit_sort=      1                                             
		                ,@editable_ind=         1                                             
		                ,@webprint_ind=        0                                              
		                ,@schedule_ind=         0                                             
		                ,@download_ind=        0                                              
		                ,@allow_edit_grpFltr=  1                                                                                          
		                ,@rltd_entity_num=      0                                                                                 
		                ,@cht_ind=              0                                             
		                ,@lock_inq_basis=       0                                                                             
		                ,@autorun_ind=         1                                                                   
		                ,@hide_inqdiag_ind=     1                                                                                  
		                ,@grp_filter_txt=       NULL  ;                                        
		
		--FLD_DEF

		INSERT INTO FLD_DEF VALUES(@entityNum,2,2,'InvestorId','Investor Id','Investor Id','Investor Id','ENG',0,NULL,20,0,NULL,0,0,0,NULL,0,NULL,GETDATE(),'ADMIN',2,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,3,3,'InvestorThirdPartyID','Investor Third Party ID','Investor Third Party ID','Investor Third Party ID','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,4,4,'InvestorSecondaryID','Investor Secondary ID','Investor Secondary ID','Investor Secondary ID','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,5,5,'InvestorName','Investor Name','Investor Name','Investor Name','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,6,6,'InvestorShortName','Investor Short Name','Investor Short Name','Investor Short Name','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,7,7,'InvestorShortName2','Investor Short Name 2','Investor Short Name 2','Investor Short Name 2','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,8,8,'PrimaryTaxId','Primary Tax Id','Primary Tax Id','Primary Tax Id','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,9,9,'SecondaryTaxId','Secondary Tax Id','Secondary Tax Id','Secondary Tax Id','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,10,10,'ForeignTaxId','Foreign Tax Id','Foreign Tax Id','Foreign Tax Id','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,11,11,'BirthDate','Birth Date','Birth Date','Birth Date','ENG',0,NULL,20,0,NULL,0,0,0,NULL,0,NULL,GETDATE(),'ADMIN',4,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,12,12,'BirthCountry','Birth Country','Birth Country','Birth Country','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,13,13,'DomicileCountry','Domicile Country','Domicile Country','Domicile Country','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,14,14,'PrincipalPlaceOfBusinessCountry','Principal Place Of Business Country','Principal Place Of Business Country','PrincipalPlaceOfBusinessCountry','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,15,15,'TaxType','Tax Type','Tax Type','Tax Type','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,16,16,'SubscriberType','Subscriber Type','Subscriber Type','Subscriber Type','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,17,17,'ERISA','ERISA','ERISA','ERISA','ENG',0,NULL,20,0,NULL,0,0,0,NULL,0,NULL,GETDATE(),'ADMIN',2,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,18,18,'ERISAPercentage','ERISA Percentage','ERISA Percentage','ERISA Percentage','ENG',0,NULL,20,0,NULL,0,0,0,NULL,0,NULL,GETDATE(),'ADMIN',3,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,19,19,'InvestorLegalAttention','Investor Legal Attention','Investor Legal Attention','Investor Legal Attention','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,20,20,'InvestorLegalAttention2','Investor Legal Attention 2','Investor Legal Attention 2','Investor Legal Attention 2','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,21,21,'InvestorLegalAddressLine1','Investor Legal Address Line 1','Investor Legal Address Line 1','Investor Legal Address Line 1','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,22,22,'InvestorLegalAddressLine2','Investor Legal Address Line 2','Investor Legal Address Line 2','Investor Legal Address Line 2','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,23,23,'InvestorLegalAddressLine3','Investor Legal Address Line 3','Investor Legal Address Line 3','Investor LegalAddress Line 3','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,24,24,'InvestorLegalAddressLine4','Investor Legal Address Line 4','Investor Legal Address Line 4','Investor Legal Address Line 4','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,25,25,'InvestorLegalAddressCity','Investor Legal Address City','Investor Legal Address City','Investor Legal Address City','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,26,26,'InvestorLegalAddressState','Investor Legal Address State','Investor Legal Address State','Investor Legal Address State','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,27,27,'InvestorLegalAddressPostalCode','Investor Legal Address Postal Code','Investor Legal Address Postal Code','Investor Legal Address Postal Code','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,28,28,'InvestorLegalAddressCountry','Investor Legal Address Country','Investor Legal Address Country','InvestorLegalAddressCountry','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,29,29,'InvestorMailAddressAttention','Investor Mail Address Attention','Investor Mail Address Attention','InvestorMailAddressAttention','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,30,30,'InvestorMailAddressAttention2','Investor Mail Address Attention 2','Investor Mail Address Attention 2','InvestorMailAddressAttention2','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,31,31,'InvestorMailAddressLine1','Investor Mail Address Line 1','Investor Mail Address Line 1','Investor Mail Address Line 1','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,32,32,'InvestorMailAddressLine2','Investor Mail Address Line 2','Investor Mail Address Line 2','Investor Mail Address Line 2','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,33,33,'InvestorMailAddressLine3','Investor Mail Address Line 3','Investor Mail Address Line 3','Investor Mail Address Line 3','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,34,34,'InvestorMailAddressLine4','Investor Mail Address Line 4','Investor Mail Address Line 4','Investor Mail Address Line 4','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,35,35,'InvestorMailAddressCity','Investor Mail Address City','Investor Mail Address City','Investor Mail Address City','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,36,36,'InvestorMailAddressState','Investor Mail Address State','Investor Mail Address State','Investor Mail Address State','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,37,37,'InvestorMailAddressPostalCode','Investor Mail Address Postal Code','Investor Mail Address Postal Code','InvestorMailAddressPostalCode','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,38,38,'InvestorMailAddressCountry','Investor Mail Address Country','Investor Mail Address Country','InvestorMailAddressCountry','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,39,39,'InvestorTaxAddressAttention','Investor Tax Address Attention','Investor Tax Address Attention','InvestorTaxAddressAttention','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,40,40,'InvestorTaxAddressAttention2','Investor Tax Address Attention 2','Investor Tax Address Attention 2','InvestorTaxAddressAttention2','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,41,41,'InvestorTaxAddressLine1','Investor Tax Address Line 1','Investor Tax Address Line 1','InvestorTaxAddressLine1','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,42,42,'InvestorTaxAddressLine2','Investor Tax Address Line 2','Investor Tax Address Line 2','Investor Tax Address Line 2','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,43,43,'InvestorTaxAddressLine3','Investor Tax Address Line 3','Investor Tax Address Line 3','Investor TaxAddressLine3','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,44,44,'InvestorTaxAddressLine4','Investor Tax Address Line 4','Investor Tax Address Line 4','InvestorTaxAddressLine4','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,45,45,'InvestorTaxAddressCity','Investor Tax Address City','Investor Tax Address City','InvestorTaxAddressCity','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,46,46,'InvestorTaxAddressState','Investor Tax Address State','Investor Tax Address State','InvestorTaxAddressState','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,47,47,'InvestorTaxAddressPostalCode','Investor Tax Address Postal Code','Investor Tax Address Postal Code','InvestorTaxAddressPostalCode','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,48,48,'InvestorTaxAddressCountry','Investor Tax Address Country','Investor Tax Address Country','InvestorTaxAddressCountry','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,49,49,'PhoneNumber1','Phone Number 1','Phone Number 1','Phone Number 1','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,50,50,'PhoneNumber2','Phone Number 2','Phone Number 2','PhoneNumber 2','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,51,51,'PhoneNumber3','Phone Number 3','Phone Number 3','PhoneNumber 3','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,52,52,'PhoneNumber4','Phone Number 4','Phone Number 4','Phone Number 4','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,53,53,'Email','Email','Email','Email','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,54,54,'Fax','Fax','Fax','Fax','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,55,55,'ContactByInvestorDashboard','Contact By Investor Dashboard','ContactByInvestorDashboard','ContactByInvestorDashboard','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,56,56,'ContactByEmail','Contact By Email','Contact By Email','ContactByEmail','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,57,57,'ContactByHardCopy','Contact By Hard Copy','Contact By Hard Copy','ContactByHardCopy','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,58,58,'ContactByHoldMail','Contact By Hold Mail','Contact By Hold Mail','Contact By Hold Mail','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,59,59,'Phone1CountryCode','Phone 1 Country Code','Phone 1 Country Code','Phone1CountryCode','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,60,60,'Phone2CountryCode','Phone 2 Country Code','Phone 2 Country Code','Phone2CountryCode','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,61,61,'Phone3CountryCode','Phone 3 Country Code','Phone 3 Country Code','Phone3CountryCode','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		INSERT INTO FLD_DEF VALUES(@entityNum,62,62,'Phone4CountryCode','Phone 4 Country Code','Phone 4 Country Code','Phone4CountryCode','ENG',0,NULL,20,0,NULL,0,0,0,NULL,1,NULL,GETDATE(),'ADMIN',1,0,'na',0,1,@inqTypNum,NULL,1,0,0,0,0,1,NULL,NULL,NULL)
		
		--FLD_IN_QRY																																																																																																																										
		INSERT INTO FLD_IN_QRY([INQ_NUM],[QRY_NUM],[ENTITY_NUM],[FLD_NUM],[SEQ_NUM],[INTERNL_NME],[FLD_BUS_NME],[NLS_CDE],[DATA_CLS_NUM],[DATA_TYP_NUM],[GRID_ALIGN_NUM],[GRID_WIDTH_NUM],[FORMAT_OPT_NUM],[FORMAT_TXT],[TOTAL_OPT_NUM],[INDENT_BY],[INDENT_BY_AMT],[FILTER_SUPPRESS_IND],[FORMULA_ID],[GROUP_BY_IND],[SCALE],[TOTAL_BY],[INCL_GRAND],[SORT_OPT],[BREAK_SUBTOTAL],[VALUE_COL],[DUPS],[LST_CHG_USR_ID],[LST_CHG_TMS],[HIDE_IND],[GRPVAL_IN_SUBTOTAL_IND],[REQD_IND],[DATA_CALC_IND],[Hide_Label_IND],[Chart_Value]) VALUES(@inqNum,@inqNum,@entityNum,3,1,	'InvestorThirdPartyID','Investor Third Party ID','ENG',0,1,0,20,0,NULL,0,0,0,0,0,1,1,NULL,0,0,0,0,0,'ADMIN',GETDATE(),0,0,0,0,0,NULL)
		INSERT INTO FLD_IN_QRY([INQ_NUM],[QRY_NUM],[ENTITY_NUM],[FLD_NUM],[SEQ_NUM],[INTERNL_NME],[FLD_BUS_NME],[NLS_CDE],[DATA_CLS_NUM],[DATA_TYP_NUM],[GRID_ALIGN_NUM],[GRID_WIDTH_NUM],[FORMAT_OPT_NUM],[FORMAT_TXT],[TOTAL_OPT_NUM],[INDENT_BY],[INDENT_BY_AMT],[FILTER_SUPPRESS_IND],[FORMULA_ID],[GROUP_BY_IND],[SCALE],[TOTAL_BY],[INCL_GRAND],[SORT_OPT],[BREAK_SUBTOTAL],[VALUE_COL],[DUPS],[LST_CHG_USR_ID],[LST_CHG_TMS],[HIDE_IND],[GRPVAL_IN_SUBTOTAL_IND],[REQD_IND],[DATA_CALC_IND],[Hide_Label_IND],[Chart_Value]) VALUES(@inqNum,@inqNum,@entityNum,5,2,	'InvestorName','Investor Name','ENG',0,1,0,20,0,NULL,0,0,0,0,0,1,1,NULL,0,0,0,0,0,'ADMIN',GETDATE(),0,0,0,0,0,NULL)
		INSERT INTO FLD_IN_QRY([INQ_NUM],[QRY_NUM],[ENTITY_NUM],[FLD_NUM],[SEQ_NUM],[INTERNL_NME],[FLD_BUS_NME],[NLS_CDE],[DATA_CLS_NUM],[DATA_TYP_NUM],[GRID_ALIGN_NUM],[GRID_WIDTH_NUM],[FORMAT_OPT_NUM],[FORMAT_TXT],[TOTAL_OPT_NUM],[INDENT_BY],[INDENT_BY_AMT],[FILTER_SUPPRESS_IND],[FORMULA_ID],[GROUP_BY_IND],[SCALE],[TOTAL_BY],[INCL_GRAND],[SORT_OPT],[BREAK_SUBTOTAL],[VALUE_COL],[DUPS],[LST_CHG_USR_ID],[LST_CHG_TMS],[HIDE_IND],[GRPVAL_IN_SUBTOTAL_IND],[REQD_IND],[DATA_CALC_IND],[Hide_Label_IND],[Chart_Value]) VALUES(@inqNum,@inqNum,@entityNum,19,2,	'InvestorLegalAttention','Investor Legal Attention','ENG',0,1,0,20,0,NULL,0,0,0,0,0,1,1,NULL,0,0,0,0,0,'ADMIN',GETDATE(),0,0,0,0,0,NULL)
		INSERT INTO FLD_IN_QRY([INQ_NUM],[QRY_NUM],[ENTITY_NUM],[FLD_NUM],[SEQ_NUM],[INTERNL_NME],[FLD_BUS_NME],[NLS_CDE],[DATA_CLS_NUM],[DATA_TYP_NUM],[GRID_ALIGN_NUM],[GRID_WIDTH_NUM],[FORMAT_OPT_NUM],[FORMAT_TXT],[TOTAL_OPT_NUM],[INDENT_BY],[INDENT_BY_AMT],[FILTER_SUPPRESS_IND],[FORMULA_ID],[GROUP_BY_IND],[SCALE],[TOTAL_BY],[INCL_GRAND],[SORT_OPT],[BREAK_SUBTOTAL],[VALUE_COL],[DUPS],[LST_CHG_USR_ID],[LST_CHG_TMS],[HIDE_IND],[GRPVAL_IN_SUBTOTAL_IND],[REQD_IND],[DATA_CALC_IND],[Hide_Label_IND],[Chart_Value]) VALUES(@inqNum,@inqNum,@entityNum,20,3,	'InvestorLegalAttention2','Investor Legal Attention 2','ENG',0,1,0,20,0,NULL,0,0,0,0,0,1,1,NULL,0,0,0,0,0,'ADMIN',GETDATE(),0,0,0,0,0,NULL)
		INSERT INTO FLD_IN_QRY([INQ_NUM],[QRY_NUM],[ENTITY_NUM],[FLD_NUM],[SEQ_NUM],[INTERNL_NME],[FLD_BUS_NME],[NLS_CDE],[DATA_CLS_NUM],[DATA_TYP_NUM],[GRID_ALIGN_NUM],[GRID_WIDTH_NUM],[FORMAT_OPT_NUM],[FORMAT_TXT],[TOTAL_OPT_NUM],[INDENT_BY],[INDENT_BY_AMT],[FILTER_SUPPRESS_IND],[FORMULA_ID],[GROUP_BY_IND],[SCALE],[TOTAL_BY],[INCL_GRAND],[SORT_OPT],[BREAK_SUBTOTAL],[VALUE_COL],[DUPS],[LST_CHG_USR_ID],[LST_CHG_TMS],[HIDE_IND],[GRPVAL_IN_SUBTOTAL_IND],[REQD_IND],[DATA_CALC_IND],[Hide_Label_IND],[Chart_Value]) VALUES(@inqNum,@inqNum,@entityNum,21,4,	'InvestorLegalAddressLine1','Investor Legal Address Line 1','ENG',0,1,0,20,0,NULL,0,0,0,0,0,1,1,NULL,0,0,0,0,0,'ADMIN',GETDATE(),0,0,0,0,0,NULL)
		INSERT INTO FLD_IN_QRY([INQ_NUM],[QRY_NUM],[ENTITY_NUM],[FLD_NUM],[SEQ_NUM],[INTERNL_NME],[FLD_BUS_NME],[NLS_CDE],[DATA_CLS_NUM],[DATA_TYP_NUM],[GRID_ALIGN_NUM],[GRID_WIDTH_NUM],[FORMAT_OPT_NUM],[FORMAT_TXT],[TOTAL_OPT_NUM],[INDENT_BY],[INDENT_BY_AMT],[FILTER_SUPPRESS_IND],[FORMULA_ID],[GROUP_BY_IND],[SCALE],[TOTAL_BY],[INCL_GRAND],[SORT_OPT],[BREAK_SUBTOTAL],[VALUE_COL],[DUPS],[LST_CHG_USR_ID],[LST_CHG_TMS],[HIDE_IND],[GRPVAL_IN_SUBTOTAL_IND],[REQD_IND],[DATA_CALC_IND],[Hide_Label_IND],[Chart_Value]) VALUES(@inqNum,@inqNum,@entityNum,22,5,	'InvestorLegalAddressLine2','Investor Legal Address Line 2','ENG',0,1,0,20,0,NULL,0,0,0,0,0,1,1,NULL,0,0,0,0,0,'ADMIN',GETDATE(),0,0,0,0,0,NULL)
		INSERT INTO FLD_IN_QRY([INQ_NUM],[QRY_NUM],[ENTITY_NUM],[FLD_NUM],[SEQ_NUM],[INTERNL_NME],[FLD_BUS_NME],[NLS_CDE],[DATA_CLS_NUM],[DATA_TYP_NUM],[GRID_ALIGN_NUM],[GRID_WIDTH_NUM],[FORMAT_OPT_NUM],[FORMAT_TXT],[TOTAL_OPT_NUM],[INDENT_BY],[INDENT_BY_AMT],[FILTER_SUPPRESS_IND],[FORMULA_ID],[GROUP_BY_IND],[SCALE],[TOTAL_BY],[INCL_GRAND],[SORT_OPT],[BREAK_SUBTOTAL],[VALUE_COL],[DUPS],[LST_CHG_USR_ID],[LST_CHG_TMS],[HIDE_IND],[GRPVAL_IN_SUBTOTAL_IND],[REQD_IND],[DATA_CALC_IND],[Hide_Label_IND],[Chart_Value]) VALUES(@inqNum,@inqNum,@entityNum,23,6,	'InvestorLegalAddressLine3','Investor Legal Address Line 3','ENG',0,1,0,20,0,NULL,0,0,0,0,0,1,1,NULL,0,0,0,0,0,'ADMIN',GETDATE(),0,0,0,0,0,NULL)
		INSERT INTO FLD_IN_QRY([INQ_NUM],[QRY_NUM],[ENTITY_NUM],[FLD_NUM],[SEQ_NUM],[INTERNL_NME],[FLD_BUS_NME],[NLS_CDE],[DATA_CLS_NUM],[DATA_TYP_NUM],[GRID_ALIGN_NUM],[GRID_WIDTH_NUM],[FORMAT_OPT_NUM],[FORMAT_TXT],[TOTAL_OPT_NUM],[INDENT_BY],[INDENT_BY_AMT],[FILTER_SUPPRESS_IND],[FORMULA_ID],[GROUP_BY_IND],[SCALE],[TOTAL_BY],[INCL_GRAND],[SORT_OPT],[BREAK_SUBTOTAL],[VALUE_COL],[DUPS],[LST_CHG_USR_ID],[LST_CHG_TMS],[HIDE_IND],[GRPVAL_IN_SUBTOTAL_IND],[REQD_IND],[DATA_CALC_IND],[Hide_Label_IND],[Chart_Value]) VALUES(@inqNum,@inqNum,@entityNum,24,7,	'InvestorLegalAddressLine4','Investor Legal Address Line 4','ENG',0,1,0,20,0,NULL,0,0,0,0,0,1,1,NULL,0,0,0,0,0,'ADMIN',GETDATE(),0,0,0,0,0,NULL)
		INSERT INTO FLD_IN_QRY([INQ_NUM],[QRY_NUM],[ENTITY_NUM],[FLD_NUM],[SEQ_NUM],[INTERNL_NME],[FLD_BUS_NME],[NLS_CDE],[DATA_CLS_NUM],[DATA_TYP_NUM],[GRID_ALIGN_NUM],[GRID_WIDTH_NUM],[FORMAT_OPT_NUM],[FORMAT_TXT],[TOTAL_OPT_NUM],[INDENT_BY],[INDENT_BY_AMT],[FILTER_SUPPRESS_IND],[FORMULA_ID],[GROUP_BY_IND],[SCALE],[TOTAL_BY],[INCL_GRAND],[SORT_OPT],[BREAK_SUBTOTAL],[VALUE_COL],[DUPS],[LST_CHG_USR_ID],[LST_CHG_TMS],[HIDE_IND],[GRPVAL_IN_SUBTOTAL_IND],[REQD_IND],[DATA_CALC_IND],[Hide_Label_IND],[Chart_Value]) VALUES(@inqNum,@inqNum,@entityNum,25,8,	'InvestorLegalAddressCity','Investor Legal Address City','ENG',0,1,0,20,0,NULL,0,0,0,0,0,1,1,NULL,0,0,0,0,0,'ADMIN',GETDATE(),0,0,0,0,0,NULL)
		INSERT INTO FLD_IN_QRY([INQ_NUM],[QRY_NUM],[ENTITY_NUM],[FLD_NUM],[SEQ_NUM],[INTERNL_NME],[FLD_BUS_NME],[NLS_CDE],[DATA_CLS_NUM],[DATA_TYP_NUM],[GRID_ALIGN_NUM],[GRID_WIDTH_NUM],[FORMAT_OPT_NUM],[FORMAT_TXT],[TOTAL_OPT_NUM],[INDENT_BY],[INDENT_BY_AMT],[FILTER_SUPPRESS_IND],[FORMULA_ID],[GROUP_BY_IND],[SCALE],[TOTAL_BY],[INCL_GRAND],[SORT_OPT],[BREAK_SUBTOTAL],[VALUE_COL],[DUPS],[LST_CHG_USR_ID],[LST_CHG_TMS],[HIDE_IND],[GRPVAL_IN_SUBTOTAL_IND],[REQD_IND],[DATA_CALC_IND],[Hide_Label_IND],[Chart_Value]) VALUES(@inqNum,@inqNum,@entityNum,26,9,	'InvestorLegalAddressState','Investor Legal Address State','ENG',0,1,0,20,0,NULL,0,0,0,0,0,1,1,NULL,0,0,0,0,0,'ADMIN',GETDATE(),0,0,0,0,0,NULL)
		INSERT INTO FLD_IN_QRY([INQ_NUM],[QRY_NUM],[ENTITY_NUM],[FLD_NUM],[SEQ_NUM],[INTERNL_NME],[FLD_BUS_NME],[NLS_CDE],[DATA_CLS_NUM],[DATA_TYP_NUM],[GRID_ALIGN_NUM],[GRID_WIDTH_NUM],[FORMAT_OPT_NUM],[FORMAT_TXT],[TOTAL_OPT_NUM],[INDENT_BY],[INDENT_BY_AMT],[FILTER_SUPPRESS_IND],[FORMULA_ID],[GROUP_BY_IND],[SCALE],[TOTAL_BY],[INCL_GRAND],[SORT_OPT],[BREAK_SUBTOTAL],[VALUE_COL],[DUPS],[LST_CHG_USR_ID],[LST_CHG_TMS],[HIDE_IND],[GRPVAL_IN_SUBTOTAL_IND],[REQD_IND],[DATA_CALC_IND],[Hide_Label_IND],[Chart_Value]) VALUES(@inqNum,@inqNum,@entityNum,27,10,	'InvestorLegalAddressPostalCode','Investor Legal Address Postal Code','ENG',0,1,0,20,0,NULL,0,0,0,0,0,1,1,NULL,0,0,0,0,0,'ADMIN',GETDATE(),0,0,0,0,0,NULL)
		INSERT INTO FLD_IN_QRY([INQ_NUM],[QRY_NUM],[ENTITY_NUM],[FLD_NUM],[SEQ_NUM],[INTERNL_NME],[FLD_BUS_NME],[NLS_CDE],[DATA_CLS_NUM],[DATA_TYP_NUM],[GRID_ALIGN_NUM],[GRID_WIDTH_NUM],[FORMAT_OPT_NUM],[FORMAT_TXT],[TOTAL_OPT_NUM],[INDENT_BY],[INDENT_BY_AMT],[FILTER_SUPPRESS_IND],[FORMULA_ID],[GROUP_BY_IND],[SCALE],[TOTAL_BY],[INCL_GRAND],[SORT_OPT],[BREAK_SUBTOTAL],[VALUE_COL],[DUPS],[LST_CHG_USR_ID],[LST_CHG_TMS],[HIDE_IND],[GRPVAL_IN_SUBTOTAL_IND],[REQD_IND],[DATA_CALC_IND],[Hide_Label_IND],[Chart_Value]) VALUES(@inqNum,@inqNum,@entityNum,28,11,	'InvestorLegalAddressCountry','Investor Legal Address Country','ENG',0,1,0,20,0,NULL,0,0,0,0,0,1,1,NULL,0,0,0,0,0,'ADMIN',GETDATE(),0,0,0,0,0,NULL)
				
		--QUERY_PARAM_DEF
		INSERT INTO QUERY_PARAM_DEF([DEF_TYP], [TYP_IND], [TYP_QRY_RPT_NUM], [PARAM_SEQ], [PARAM_NME], [PARAM_FLD_NME], [PARAM_FLD_DATATYPE], [PARAM_ENTITY_NUM], [PARAM_FLD_NUM], [PARAM_DFLT_INTVAL], [PARAM_DFLT_FLOATVAL], [PARAM_DFLT_DATEVAL], [PARAM_DFLT_CHARVAL], [PARAM_DFLT_VARCHARVAL], [LST_CHG_TMS], [LST_CHG_USR_ID], [PARAM_REQ_IND]) VALUES('I','S',@inqNum,1,'@p_Funds','p_Funds'   ,1,	@entityNum,	0,NULL,	NULL,	NULL,	NULL,	NULL,	getdate(),'ADMIN',0);	
		INSERT INTO QUERY_PARAM_DEF([DEF_TYP], [TYP_IND], [TYP_QRY_RPT_NUM], [PARAM_SEQ], [PARAM_NME], [PARAM_FLD_NME], [PARAM_FLD_DATATYPE], [PARAM_ENTITY_NUM], [PARAM_FLD_NUM], [PARAM_DFLT_INTVAL], [PARAM_DFLT_FLOATVAL], [PARAM_DFLT_DATEVAL], [PARAM_DFLT_CHARVAL], [PARAM_DFLT_VARCHARVAL], [LST_CHG_TMS], [LST_CHG_USR_ID], [PARAM_REQ_IND]) VALUES('I','S',@inqNum,2,'@inq_num' ,NULL ,2,	@entityNum,	0,NULL,	NULL,	NULL,	NULL,	NULL,	getdate(),'ADMIN',0);		
		INSERT INTO QUERY_PARAM_DEF([DEF_TYP], [TYP_IND], [TYP_QRY_RPT_NUM], [PARAM_SEQ], [PARAM_NME], [PARAM_FLD_NME], [PARAM_FLD_DATATYPE], [PARAM_ENTITY_NUM], [PARAM_FLD_NUM], [PARAM_DFLT_INTVAL], [PARAM_DFLT_FLOATVAL], [PARAM_DFLT_DATEVAL], [PARAM_DFLT_CHARVAL], [PARAM_DFLT_VARCHARVAL], [LST_CHG_TMS], [LST_CHG_USR_ID], [PARAM_REQ_IND]) VALUES('I','S',@inqNum,3,'@qry_num',	    NULL,2,	@entityNum,0,NULL,NULL,NULL,NULL,NULL,	getdate(),'ADMIN',0);
		INSERT INTO QUERY_PARAM_DEF([DEF_TYP], [TYP_IND], [TYP_QRY_RPT_NUM], [PARAM_SEQ], [PARAM_NME], [PARAM_FLD_NME], [PARAM_FLD_DATATYPE], [PARAM_ENTITY_NUM], [PARAM_FLD_NUM], [PARAM_DFLT_INTVAL], [PARAM_DFLT_FLOATVAL], [PARAM_DFLT_DATEVAL], [PARAM_DFLT_CHARVAL], [PARAM_DFLT_VARCHARVAL], [LST_CHG_TMS], [LST_CHG_USR_ID], [PARAM_REQ_IND]) VALUES('I','S',@inqNum,4,'@pselect_txt',  NULL,1,	@entityNum,0,NULL,NULL,NULL,NULL,NULL,	getdate(),'ADMIN',0);
		INSERT INTO QUERY_PARAM_DEF([DEF_TYP], [TYP_IND], [TYP_QRY_RPT_NUM], [PARAM_SEQ], [PARAM_NME], [PARAM_FLD_NME], [PARAM_FLD_DATATYPE], [PARAM_ENTITY_NUM], [PARAM_FLD_NUM], [PARAM_DFLT_INTVAL], [PARAM_DFLT_FLOATVAL], [PARAM_DFLT_DATEVAL], [PARAM_DFLT_CHARVAL], [PARAM_DFLT_VARCHARVAL], [LST_CHG_TMS], [LST_CHG_USR_ID], [PARAM_REQ_IND]) VALUES('I','S',@inqNum,5,'@porderby_txt',	NULL,1,	@entityNum,0,NULL,NULL,NULL,NULL,NULL,	getdate(),'ADMIN',0);
		INSERT INTO QUERY_PARAM_DEF([DEF_TYP], [TYP_IND], [TYP_QRY_RPT_NUM], [PARAM_SEQ], [PARAM_NME], [PARAM_FLD_NME], [PARAM_FLD_DATATYPE], [PARAM_ENTITY_NUM], [PARAM_FLD_NUM], [PARAM_DFLT_INTVAL], [PARAM_DFLT_FLOATVAL], [PARAM_DFLT_DATEVAL], [PARAM_DFLT_CHARVAL], [PARAM_DFLT_VARCHARVAL], [LST_CHG_TMS], [LST_CHG_USR_ID], [PARAM_REQ_IND]) VALUES('I','S',@inqNum,6,'@pfilter_txt',  NULL,1,	@entityNum,0,NULL,NULL,NULL,NULL,NULL,	getdate(),'ADMIN',0);
		INSERT INTO QUERY_PARAM_DEF([DEF_TYP], [TYP_IND], [TYP_QRY_RPT_NUM], [PARAM_SEQ], [PARAM_NME], [PARAM_FLD_NME], [PARAM_FLD_DATATYPE], [PARAM_ENTITY_NUM], [PARAM_FLD_NUM], [PARAM_DFLT_INTVAL], [PARAM_DFLT_FLOATVAL], [PARAM_DFLT_DATEVAL], [PARAM_DFLT_CHARVAL], [PARAM_DFLT_VARCHARVAL], [LST_CHG_TMS], [LST_CHG_USR_ID], [PARAM_REQ_IND]) VALUES('I','S',@inqNum,7,'@pgroupby_txt',	NULL,1,	@entityNum,0,NULL,NULL,NULL,NULL,NULL,	getdate(),'ADMIN',0);
		
		--DW_INQRUNVAL_DEF
		INSERT INTO DW_INQRUNVAL_DEF([INQ_NUM],[QRY_NUM],[RUN_PRM_NME],[RUN_PRM_TYP],[RUN_PRM_VAL],[LST_CHG_TMS],[LST_CHG_USR_ID]) VALUES(@inqNum,@inqNum,'p_Funds',	1,	0,getdate(),'ADMIN');
		
		--DW_FUNCTION_ITEM		   			
		INSERT INTO DW_FUNCTION_ITEM([FN_ID],[FN_NME],[FN_DESC],[FN_MNEM],[FN_TYP],[FN_TXT],[FN_STYLE_IND],[FN_STYLE_ID],[FN_LVL_NUM],[FN_SEQ_NUM],[INQ_NUM],[RPT_NUM],[PRNT_FN_ID],[FN_ENABLE_IND],[FN_STD_USR_IND],[FN_BGIMG_ID],[FN_ACIMG_ID],[FN_SAIMG_ID],[FN_MOIMG_ID],[FN_URLASP_TXT],[LST_CHG_TMS],[LST_CHG_USR_ID],[FN_FILTER_TXT],[APP_GUID],[app_used]) VALUES 
		('AMLEGADD','Investor Address Reports','Investor Address Reports',					   'LEGADDRPT'					   ,'PLC','Investor Legal Address','T',	2,0,600,NULL,NULL,NULL,'Y','S',10,11,10,10,null,getdate(),'ADMIN',NULL,NULL,NULL);
		--INSERT INTO DW_FUNCTION_ITEM VALUES 
		--('AMFATCADET','Detail','FATCA detail reports',					   'FATCADETRPT'					   ,'PLC','FATCA Detail Reports','T',	2,1,0,NULL,NULL,'AMFATCA','Y','S',10,11,10,10,null,getdate(),'ADMIN',NULL,NULL,NULL);		
		INSERT INTO DW_FUNCTION_ITEM VALUES ('FNI_0'+CAST(@inqNum AS VARCHAR(5)),'Investor Legal Address','Investor Legal Address','FNI_0'++CAST(@inqNum AS VARCHAR(5)),'INQ','Post Filing Report' ,'T',	1,1,0,@inqNum,NULL,'AMLEGADD','Y','S',1,1,1,1,null,getdate(),'ADMIN',NULL,NULL,NULL)	;	

		
		--DW_EXPLORER_FUNCTION
		DECLARE @seq_num int;
		SELECT  @seq_num = MAX(seq_num) +1 FROM DW_EXPLORER_FUNCTION WHERE EXP_ID = 'AM'
		INSERT INTO DW_EXPLORER_FUNCTION VALUES ('AM','AMLEGADD',@seq_num,GETDATE(),'ADMIN')	;	

		--DW_ROLE
		SELECT @roleId    =  MAX(ROLEID)+1 FROM DW_ROLE		
		INSERT INTO DW_ROLE VALUES(@roleId, 'Investor Address Reports', 'Investor Address Reports', 'STANDARD','S',NULL,GETDATE(),'ADMIN');		

		--DW_ROLEFUNCTION
		SELECT @roleFnId = max(rolefnid)+1 FROM DW_ROLEFUNCTION
		INSERT INTO DW_ROLEFUNCTION VALUES (@roleFnId, 'Investor Address Reports','Investor Address Reports',0,'FNI_0'+CAST(@inqNum as VARCHAR(5)),GETDATE(),'ADMIN');		
		
		--DW_ROLEFUNCTIONXREF
		INSERT INTO DW_ROLEFUNCTIONXREF VALUES(@roleFnId,@roleId,1,NULL,NULL,GETDATE(),'ADMIN',NULL);

		PRINT '';
		PRINT '--Inquiry created successfully';
		PRINT '--ENTITY_NUM' PRINT @entityNum;
		PRINT '--INQ_NUM' PRINT @inqNum;
		PRINT '----------------------------------------';
		PRINT '--Delete Script:';
		PRINT '----------------------------------------';
		PRINT 'USE NetikIP;
		GO
		BEGIN TRY	
			BEGIN TRAN'
		PRINT 'DELETE FROM ENTITY_DEF WHERE ENTITY_NUM = ' PRINT @entityNum ;
		PRINT 'DELETE FROM INQ_TYPE WHERE INQ_TYP_NUM = '  PRINT @inqTypNum ;
		PRINT 'DELETE FROM FLD_DEF WHERE ENTITY_NUM = '    PRINT @entityNum ;
		PRINT 'DELETE FROM INQ_DEF WHERE INQ_NUM='         PRINT @inqNum ;
		PRINT 'DELETE FROM DW_FUNCTION_ITEM WHERE FN_ID = ''AMLEGADD''';
		PRINT 'DELETE FROM DW_FUNCTION_ITEM WHERE FN_ID = ''FNI_0'+CAST(@inqNum AS VARCHAR(5)) +''''	;	
		PRINT 'DELETE FROM DW_ROLE WHERE ROLEID = '        PRINT @roleId;
		PRINT 'DELETE FROM DW_EXPLORER_FUNCTION WHERE EXP_ID = ''AM'' AND FN_ID = ''AMLEGADD''';
		PRINT 'DELETE FROM DW_ROLEFUNCTION WHERE RoleFnId = ' PRINT @roleFnId;
		PRINT 'COMMIT TRAN;	
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN;
			SELECT	ERROR_NUMBER()		as ErrorNumber,
					ERROR_MESSAGE()		as ErrorMEssage,
					ERROR_LINE()		as ErrorLine,
					ERROR_STATE()		as ErrorState,
					ERROR_SEVERITY()	as ErrorSeverity,
					ERROR_PROCEDURE()	as ErrorProcedure;
		END CATCH;'
		
	COMMIT TRAN	;
END TRY
BEGIN CATCH
	ROLLBACK TRAN;
	SELECT	ERROR_NUMBER()		as ErrorNumber,
			ERROR_MESSAGE()		as ErrorMEssage,
			ERROR_LINE()		as ErrorLine,
			ERROR_STATE()		as ErrorState,
			ERROR_SEVERITY()	as ErrorSeverity,
			ERROR_PROCEDURE()	as ErrorProcedure;
END CATCH;


