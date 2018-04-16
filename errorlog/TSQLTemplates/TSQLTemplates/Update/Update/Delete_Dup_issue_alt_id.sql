USE NetikIP; --Change database name
GO

/* ----------------------------------------------------------------------------------------------------
 
 File Name			:Delete_Dup_issue_alt_id
 Business Description    :
 Created By			:VBANDI
 Created Date			: 10/09/2014
 ------------------------------------------------------------------------------------------------------
 */ 
 

PRINT '-------------Script Started at	 :' +  convert(char(23),getdate(),121) + '------------------------';
PRINT SPACE(100);

BEGIN TRY
	BEGIN TRANSACTION;
	---------------------------Start---------------------------------------
--issue_alt_id deletes
delete from dbo.issue_alt_id where instr_id in 
('MD_724954''MD_724998','MD_710846','MD_712239','MD_711152','MD_713233','MD_479642','MD_762875','MD_590040','MD_496006','MD_716931','MD_333584','MD_739513','MD_720359','MD_336322','MD_707478','MD_427300','MD_513671','MD_700466','MD_573530','MD_472391','MD_337350','MD_419907','MD_346310','MD_315285','MD_479144','MD_353502','MD_641731','MD_352003','MD_262607','MD_707422','MD_329926','MD_545178','MD_756639','MD_547246','MD_341314','MD_583429','MD_583428','MD_585473','MD_681322','MD_640367','MD_345434','MD_734752','MD_72','MD_730448','MD_749415','MD_725370','MD_739735','MD_743646','MD_731438','MD_740628','MD_743211','MD_726237','MD_741750','MD_642897','MD_740843','MD_365218','MD_336743','MD_515745','MD_423732','MD_423733','MD_419908','MD_419909','MD_424057','MD_424058','MD_424059','MD_424060','MD_424061','MD_424062','MD_430649','MD_437368','MD_353847','MD_506985','MD_385432','MD_609097','MD_608942','MD_651266','MD_380267','MD_362690','MD_466946','MD_363297','MD_709710','MD_366577','MD_407439','MD_713432','MD_465965','MD_410856','MD_382498','MD_411951','MD_453182','MD_713431','MD_427134','MD_542159','MD_435758','MD_448066','MD_543575','MD_674206','MD_763844','MD_502015',
'MD_455554','MD_513673','MD_455553','MD_473521','MD_478082','MD_757186','MD_736626','MD_654366','MD_501027','MD_501028','MD_756348','MD_550625','MD_549772','MD_674902','MD_662582','MD_536280','MD_569288','MD_571659','MD_567630','MD_567920','MD_583048','MD_603571','MD_583049','MD_583050','MD_585476','MD_674934','MD_763845','MD_763971','MD_763846','MD_674942','MD_674946','MD_674948','MD_763847','MD_674960','MD_674961','MD_674973','MD_640215','MD_725029','MD_624941','MD_675002','MD_675004','MD_627309','MD_675016','MD_633472','MD_654039','MD_675020','MD_675022','MD_763848','MD_633779','MD_635400','MD_675035','MD_675050',
'MD_675051','MD_643300','MD_645395','MD_675054','MD_645632','MD_763849','MD_647001','MD_678179','MD_657984','MD_675067','MD_650776','MD_653163','MD_653162','MD_675081','MD_657660','MD_675099','MD_666998','MD_763850','MD_749078','MD_698956','MD_679662','MD_681632','MD_689722','MD_762329','MD_693135','MD_763851','MD_695582','MD_753969','MD_706360','MD_391825','MD_326356','MD_708077','MD_704630','MD_704634','MD_733284','MD_717075','MD_717073','MD_717095','MD_717023','MD_717094','MD_715217','MD_717813','MD_728465','MD_727985','MD_728343','MD_728350','MD_727989','MD_756620','MD_732317','MD_732318','MD_733850','MD_736422','MD_736423','MD_742748','MD_742761','MD_741778','MD_742861','MD_743866','MD_743867','MD_746803','MD_746804','MD_753973','MD_749651','MD_749549','MD_749550','MD_749551','MD_749552','MD_749649','MD_752274','MD_758900','MD_754957','MD_753255','MD_753256','MD_753257','MD_753258','MD_752954','MD_752960','MD_752959','MD_753333','MD_753970','MD_753971','MD_753972','MD_755855','MD_755856','MD_755857','MD_764694','MD_761574','MD_761573','MD_764695','MD_778359','MD_778371','MD_778383','MD_778395')



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