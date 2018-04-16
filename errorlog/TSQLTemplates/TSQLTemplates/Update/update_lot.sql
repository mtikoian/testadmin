USE NETIKIP;
GO

SET XACT_ABORT ON;

PRINT '-------------Script Started at    :' + CONVERT(CHAR(23), GETDATE(), 121) + '------------------------';
PRINT SPACE(100);

DECLARE @Error INTEGER;
DECLARE @Rowcount BIGINT;
DECLARE @TOTALROWS INT;
DECLARE @Updatebatchsize INT;

SET @Updatebatchsize = 10000;
SET @Rowcount = 0;
SET @TOTALROWS = 0;

--check if temp table exists         
IF OBJECT_ID('tempdb..#templot_dg') IS NOT NULL
	DROP TABLE #templot_dg;

--check if temp table exists         
IF OBJECT_ID('tempdb..#tblot_dg') IS NOT NULL
	DROP TABLE #tblot_dg

CREATE TABLE #templot_dg (
	Id INT identity(1, 1) NOT NULL
	,new_instr_id CHAR(16) NOT NULL
	,old_instr_id VARCHAR(16) NOT NULL
	);

CREATE TABLE #tblot_dg (
	RCD_NUM INT NOT NULL PRIMARY KEY
	,old_instr_id CHAR(16) NOT NULL
	);

INSERT INTO #templot_dg
select 'MD_263335','MD_720274'   union all
select 'MD_235576','MD_320886'   union all
select 'MD_320808','MD_545969'   union all
select 'MD_256456','MD_353852'   union all
select 'MD_432410','MD_707559'   union all
select 'MD_255919','MD_730586'   union all
select 'MD_347739','MD_369743'   union all
select 'MD_235743','MD_315312'   union all
select 'MD_251373','MD_395228'   union all
select 'MD_254928','MD_315332'   union all
select 'MD_369283','MD_716902'   union all
select 'MD_326226','MD_516410'   union all
select 'MD_332165','MD_332217'   union all
select 'MD_254874','MD_667562'   union all
select 'MD_711556','MD_716907'   union all
select 'MD_2874'  ,'MD_716908'   union all
select 'MD_255359','MD_531938'   union all
select 'MD_239621','MD_402731'   union all
select 'MD_458838','MD_668570'   union all
select 'MD_475806','MD_716706'   union all
select 'MD_353901','MD_380265'   union all
select 'MD_237252','MD_268638'   union all
select 'MD_337603','MD_337772'   union all
select 'MD_711440','MD_480237'   union all
select 'MD_718309','MD_357905'   union all
select 'MD_643097','MD_716716'   union all
select 'MD_353980','MD_688856'   union all
select 'MD_608947','MD_639069'   union all
select 'MD_654'   ,'MD_713314'   union all
select 'MD_712649','MD_716741'   union all
select 'MD_1135'  ,'MD_716743'   union all
select 'MD_232354','MD_725753'   union all
select 'MD_399864','MD_437397'   union all
select 'MD_240614','MD_718052'   union all
select 'MD_260584','MD_326361'   union all
select 'MD_250509','MD_739869'   union all
select 'MD_446190','MD_538563'   union all
select 'MD_233183','MD_268129'   union all
select 'MD_268636','MD_327328'   union all
select 'MD_233318','MD_268639'   union all
select 'MD_233351','MD_268633'   union all
select 'MD_233353','MD_268634'   union all
select 'MD_233502','MD_268637'   union all
select 'MD_233914','MD_720578'   union all
select 'MD_234387','MD_352910'   union all
select 'MD_260596','MD_326396'   union all
select 'MD_691389','MD_518611'   union all
select 'MD_471264','MD_602098'   union all
select 'MD_354685','MD_653241'   union all
select 'MD_334998','MD_755702'   union all
select 'MD_422218','MD_711783'   union all
select 'MD_449693','MD_475259'   union all
select 'MD_692527','MD_545460'   union all
select 'MD_715627','MD_716819'   union all
select 'MD_359124','MD_359121'   union all
select 'MD_262607','MD_684664'   union all
select 'MD_262607','MD_689708'   union all
select 'MD_262607','MD_707449'   union all
select 'MD_622693','MD_674990'   union all
select 'MD_578166','MD_674922'   union all
select 'MD_626236','MD_675008'   union all
select 'MD_471719','MD_504601'   union all
select 'MD_428996','MD_550402'   union all
select 'MD_619940','MD_674985'   union all
select 'MD_395174','MD_504599'   union all
select 'MD_283763','MD_704091'   union all
select 'MD_464086','MD_550523'   union all
select 'MD_486142','MD_550575'   union all
select 'MD_638475','MD_675037'   union all
select 'MD_636749','MD_638651'   union all
select 'MD_411311','MD_666114'   union all
select 'MD_575759','MD_582484'   union all
select 'MD_706327','MD_706193'   union all
select 'MD_554377','MD_569299'   union all
select 'MD_714408','MD_716708'   union all
select 'MD_600880','MD_674957'   union all
select 'MD_659684','MD_660234'   union all
select 'MD_458198','MD_550510'   union all
select 'MD_544944','MD_569275'   union all
select 'MD_471000','MD_547811'   union all
select 'MD_711380','MD_716710'   union all
select 'MD_758714','MD_759489'   union all
select 'MD_758713','MD_759488'   union all
select 'MD_710754','MD_716711'   union all
select 'MD_710708','MD_716712'   union all
select 'MD_440643','MD_550437'   union all
select 'MD_515144','MD_569235'   union all
select 'MD_721022','MD_721164'   union all
select 'MD_600159','MD_674956'   union all
select 'MD_711018','MD_716715'   union all
select 'MD_625313','MD_675001'   union all
select 'MD_623810','MD_674992'   union all
select 'MD_585236','MD_674928'   union all
select 'MD_711082','MD_716717'   union all
select 'MD_754422','MD_754474'   union all
select 'MD_752906','MD_752958'   union all
select 'MD_752905','MD_752957'   union all
select 'MD_742033','MD_744205'   union all
select 'MD_742032','MD_752956'   union all
select 'MD_742031','MD_744206'   union all
select 'MD_747219','MD_747278'   union all
select 'MD_513156','MD_550649'   union all
select 'MD_598923','MD_599369'   union all
select 'MD_591775','MD_692679'   union all
select 'MD_648939','MD_716718'   union all
select 'MD_440367','MD_550431'   union all
select 'MD_715632','MD_716719'   union all
select 'MD_445838','MD_452546'   union all
select 'MD_455288','MD_550458'   union all
select 'MD_281785','MD_550425'   union all
select 'MD_280363','MD_492461'   union all
select 'MD_584609','MD_674927'   union all
select 'MD_659031','MD_675097'   union all
select 'MD_513792','MD_550656'   union all
select 'MD_458195','MD_550507'   union all
select 'MD_710652','MD_719210'   union all
select 'MD_440373','MD_550432'   union all
select 'MD_380460','MD_456544'   union all
select 'MD_2987'  ,'MD_716726'   union all
select 'MD_575752','MD_581140'   union all
select 'MD_545276','MD_569279'   union all
select 'MD_278803','MD_453759'   union all
select 'MD_547807','MD_553178'   union all
select 'MD_545270','MD_569277'   union all
select 'MD_647147','MD_675061'   union all
select 'MD_639973','MD_675047'   union all
select 'MD_620679','MD_707134'   union all
select 'MD_476838','MD_550555'   union all
select 'MD_701438','MD_682447'   union all
select 'MD_626231','MD_675006'   union all
select 'MD_574556','MD_674915'   union all
select 'MD_634689','MD_675025'   union all
select 'MD_370613','MD_605328'   union all
select 'MD_589153','MD_674936'   union all
select 'MD_696724','MD_527676'   union all
select 'MD_2835'  ,'MD_716749'   union all
select 'MD_492829','MD_550591'   union all
select 'MD_508393','MD_550617'   union all
select 'MD_353183','MD_437370'   union all
select 'MD_516138','MD_550670'   union all
select 'MD_415432','MD_712543'   union all
select 'MD_744075','MD_744207'   union all
select 'MD_744076','MD_744208'   union all
select 'MD_710884','MD_716763'   union all
select 'MD_1211'  ,'MD_716764'   union all
select 'MD_745459','MD_745337'   union all
select 'MD_712247','MD_716766'   union all
select 'MD_712246','MD_716767'   union all
select 'MD_429014','MD_550409'   union all
select 'MD_429015','MD_550410'   union all
select 'MD_717723','MD_422811'   union all
select 'MD_356704','MD_357607'   union all
select 'MD_356703','MD_357608'   union all
select 'MD_356701','MD_357609'   union all
select 'MD_356407','MD_357610'   union all
select 'MD_472842','MD_550536'   union all
select 'MD_2939'  ,'MD_716770'   union all
select 'MD_714106','MD_716771'   union all
select 'MD_583512','MD_674924'   union all
select 'MD_473605','MD_550542'   union all
select 'MD_556072','MD_569304'   union all
select 'MD_509023','MD_550618'   union all
select 'MD_631115','MD_675017'   union all
select 'MD_713963','MD_716772'   union all
select 'MD_533357','MD_569260'   union all
select 'MD_753847','MD_753967'   union all
select 'MD_753848','MD_753968'   union all
select 'MD_755813','MD_755859'   union all
select 'MD_755814','MD_755860'   union all
select 'MD_755812','MD_755858'   union all
select 'MD_667655','MD_675115'   union all
select 'MD_493019','MD_569245'   union all
select 'MD_403792','MD_550427'   union all
select 'MD_711416','MD_716778'   union all
select 'MD_402729','MD_550461'   union all
select 'MD_734279','MD_389792'   union all
select 'MD_545080','MD_569276'   union all
select 'MD_516126','MD_550669'   union all
select 'MD_699370','MD_759098'   union all
select 'MD_723513','MD_431455'   union all
select 'MD_554812','MD_569301'   union all
select 'MD_575744','MD_579409'   union all
select 'MD_711965','MD_716783'   union all
select 'MD_719911','MD_719810'   union all
select 'MD_623157','MD_674991'   union all
select 'MD_715946','MD_715726'   union all
select 'MD_565150','MD_569316'   union all
select 'MD_1016'  ,'MD_716791'   union all
select 'MD_713478','MD_716792'   union all
select 'MD_489932','MD_550584'   union all
select 'MD_473607','MD_550544'   union all
select 'MD_540649','MD_569264'   union all
select 'MD_590234','MD_626894'   union all
select 'MD_712001','MD_716794'   union all
select 'MD_342091','MD_715947'   union all
select 'MD_464055','MD_550516'   union all
select 'MD_416922','MD_457515'   union all
select 'MD_711598','MD_716795'   union all
select 'MD_711599','MD_716796'   union all
select 'MD_711600','MD_716797'   union all
select 'MD_715629','MD_716798'   union all
select 'MD_702478','MD_518580'   union all
select 'MD_476402','MD_550553'   union all
select 'MD_648844','MD_675068'   union all
select 'MD_1119'  ,'MD_716805'   union all
select 'MD_550867','MD_569292'   union all
select 'MD_441323','MD_550311'   union all
select 'MD_575777','MD_578943'   union all
select 'MD_575824','MD_578944'   union all
select 'MD_711370','MD_716811'   union all
select 'MD_564006','MD_569315'   union all
select 'MD_510598','MD_550628'   union all
select 'MD_522853','MD_569256'   union all
select 'MD_466028','MD_550532'   union all
select 'MD_466027','MD_550531'   union all
select 'MD_653151','MD_653613'   union all
select 'MD_656141','MD_675087'   union all
select 'MD_561620','MD_569310'   union all
select 'MD_474992','MD_550549'   union all
select 'MD_613940','MD_716814'   union all
select 'MD_633171','MD_675023'   union all
select 'MD_626650','MD_675011'   union all
select 'MD_619000','MD_674982'   union all
select 'MD_605580','MD_700446'   union all
select 'MD_711601','MD_716818'   union all
select 'MD_457342','MD_550502'   union all
select 'MD_609093','MD_674975'   union all
select 'MD_501196','MD_550443'   union all
select 'MD_440693','MD_550444'   union all
select 'MD_546923','MD_569282'   union all
select 'MD_535543','MD_633388'   union all
select 'MD_714272','MD_716821'   union all
select 'MD_457330','MD_550472'   union all
select 'MD_553788','MD_569296'   union all
select 'MD_710857','MD_716824'   union all
select 'MD_601156','MD_603777'   union all
select 'MD_400315','MD_550385'   union all
select 'MD_715510','MD_716828'   union all
select 'MD_383347','MD_788'	   union all
select 'MD_331480','MD_716829'   union all
select 'MD_1199'  ,'MD_716830'   union all
select 'MD_575885','MD_585047'   union all
select 'MD_544151','MD_569271'   union all
select 'MD_714367','MD_716833'   union all
select 'MD_675060','MD_717938'   union all
select 'MD_678993','MD_708969'   union all
select 'MD_678994','MD_708968'   union all
select 'MD_446635','MD_582213'   union all
select 'MD_541737','MD_749804'   union all
select 'MD_428864','MD_543359'   union all
select 'MD_597293','MD_692680'   union all
select 'MD_701444','MD_689946'   union all
select 'MD_357877','MD_744031'   union all
select 'MD_612508','MD_674971'   union all
select 'MD_606543','MD_674969'   union all
select 'MD_715628','MD_716840'   union all
select 'MD_711020','MD_716841'   union all
select 'MD_710979','MD_716842'   union all
select 'MD_710974','MD_716843'   union all
select 'MD_713474','MD_716844'   union all
select 'MD_585237','MD_674929'   union all
select 'MD_606320','MD_674966'   union all
select 'MD_575852','MD_585321'   union all
select 'MD_1112'  ,'MD_716845'   union all
select 'MD_1110'  ,'MD_716846'   union all
select 'MD_575899','MD_585322'   union all
select 'MD_451681','MD_543857'   union all
select 'MD_555839','MD_569303'   union all
select 'MD_354589','MD_543576'   union all
select 'MD_584393','MD_600875'   union all
select 'MD_656938','MD_675093'   union all
select 'MD_540037','MD_569263'   union all
select 'MD_474993','MD_550550'   union all
select 'MD_624374','MD_692432'   union all
select 'MD_257328','MD_346369'   union all
select 'MD_510482','MD_550619'   union all
select 'MD_513790','MD_550654'   union all
select 'MD_591774','MD_592713'   union all
select 'MD_547800','MD_569284'   union all
select 'MD_575790','MD_595150'   union all
select 'MD_550546','MD_659892'   union all
select 'MD_712110','MD_716853'   union all
select 'MD_711369','MD_716854'   union all
select 'MD_690280','MD_698708'   union all
select 'MD_575861','MD_595158'   union all
select 'MD_610905','MD_692431'   union all
select 'MD_458202','MD_550310'   union all
select 'MD_349480','MD_455549'   union all
select 'MD_473604','MD_550541'   union all
select 'MD_490392','MD_550585'   union all
select 'MD_459185','MD_625223'   union all
select 'MD_575819','MD_595154'   union all
select 'MD_544942','MD_569274'   union all
select 'MD_713083','MD_716860'   union all
select 'MD_657605','MD_675094'   union all
select 'MD_715454','MD_716862'   union all
select 'MD_712677','MD_716863'   union all
select 'MD_712751','MD_716864'   union all
select 'MD_713925','MD_716865'   union all
select 'MD_714352','MD_716866'   union all
select 'MD_575742','MD_582724'   union all
select 'MD_620066','MD_674986'   union all
select 'MD_476837','MD_550554'   union all
select 'MD_575803','MD_595152'   union all
select 'MD_235089','MD_722427'   union all
select 'MD_479532','MD_550566'   union all
select 'MD_479534','MD_550568'   union all
select 'MD_562232','MD_566523'   union all
select 'MD_712982','MD_716870'   union all
select 'MD_575019','MD_664617'   union all
select 'MD_710751','MD_716871'   union all
select 'MD_548925','MD_569289'   union all
select 'MD_627724','MD_675013'   union all
select 'MD_615285','MD_674979'   union all
select 'MD_564002','MD_674909'   union all
select 'MD_719149','MD_759627'   union all
select 'MD_540036','MD_569262'   union all
select 'MD_249596','MD_716658'   union all
select 'MD_276091','MD_276092'   union all
select 'MD_265475','MD_716912'   union all
select 'MD_236653','MD_267026'   union all
select 'MD_283369','MD_717363'   union all
select 'MD_498831','MD_568670'   union all
select 'MD_368056','MD_497933'   union all
select 'MD_341207','MD_341495'   union all
select 'MD_262564','MD_734883'   union all
select 'MD_262564','MD_739511'   union all
select 'MD_732407','MD_720259'   union all
select 'MD_260285','MD_337353'   union all
select 'MD_353281','MD_399659'   union all
select 'MD_283444','MD_336902'   union all
select 'MD_321106','MD_387013'   union all
select 'MD_347294','MD_354865'   union all
select 'MD_453296','MD_496566'   union all
select 'MD_350407','MD_354866'   union all
select 'MD_365536','MD_365575'   union all
select 'MD_448522','MD_532564'   union all
select 'MD_712931','MD_716916'   union all
select 'MD_426714','MD_430650'   union all
select 'MD_503676','MD_503726'   union all
select 'MD_425239','MD_574579'   union all
select 'MD_473933','MD_477991'   union all
select 'MD_711536','MD_711572'   union all
select 'MD_373186','MD_707563'   union all
select 'MD_651788','MD_723486'   union all
select 'MD_427965','MD_574580'   union all
select 'MD_433447','MD_436181'   union all
select 'MD_369972','MD_547626'   union all
select 'MD_561578','MD_561749'   union all
select 'MD_528103','MD_532571'   union all
select 'MD_628728','MD_719280'   union all
select 'MD_602073','MD_716923'   union all
select 'MD_618988','MD_623909'   union all
select 'MD_626179','MD_642952'   union all
select 'MD_633779','MD_716925'   union all
select 'MD_652175','MD_653193'   union all
select 'MD_664108','MD_668958'   union all
select 'MD_677077','MD_678190'   union all
select 'MD_689148','MD_717499'   union all
select 'MD_1218'  ,'MD_712238'   union all
select 'MD_733128','MD_750226'   union all
select 'MD_441702','MD_735193'   union all
select 'MD_619397','MD_746795'   union all
select 'MD_743931','MD_744579'   union all
select 'MD_744306','MD_744580'   union all
select 'MD_470532','MD_765707'   union all
select 'MD_328940','MD_329300'   union all
select 'MD_754115','MD_758120'   union all
select 'MD_689569','MD_764912'   union all
select 'MD_754117','MD_758121'   union all
select 'MD_754112','MD_758129'   union all
select 'MD_754113','MD_758130'   union all
select 'MD_754114','MD_758131'   union all
select 'MD_405258','MD_769888'   union all
select 'MD_386722','MD_392128'   union all
select 'MD_744453','MD_759629'   union all
select 'MD_744453','MD_760497'   union all
select 'MD_510596','MD_550626'   union all
select 'MD_561607','MD_569309'   union all
select 'MD_674263','MD_704090'   union all
select 'MD_518000','MD_579025'   union all
select 'MD_768353','MD_768358'   union all
select 'MD_768354','MD_768359'   union all
select 'MD_625931','MD_625950'   union all
select 'MD_548475','MD_715636'   union all
select 'MD_289410','MD_321871'   union all
select 'MD_291923','MD_321950'   union all
select 'MD_232181','MD_249479'   union all
select 'MD_765406','MD_767187'   union all
select 'MD_285047','MD_716666'   union all
select 'MD_284396','MD_716667'   union all
select 'MD_716929','MD_502921'   union all
select 'MD_679412','MD_466930'   union all
select 'MD_627987','MD_632709'   union all
select 'MD_626577','MD_626608'   union all
select 'MD_380845','MD_392000'   union all
select 'MD_752913','MD_755863'   union all
select 'MD_752914','MD_755866'   union all
select 'MD_752915','MD_756161'   union all
select 'MD_742770','MD_743206'   union all
select 'MD_634690','MD_675026'   union all
select 'MD_702411','MD_696283'   union all
select 'MD_658744','MD_716883'   union all
select 'MD_542189','MD_542561'   union all
select 'MD_591781','MD_674940'   union all
select 'MD_515150','MD_569251'   union all
select 'MD_402923','MD_409002'   union all
select 'MD_720049','MD_723998'   union all
select 'MD_631424','MD_633400'   union all
select 'MD_631434','MD_632764'   union all
select 'MD_409235','MD_716669'   union all
select 'MD_765582','MD_458018'   union all
select 'MD_372060','MD_391950'   union all
select 'MD_382409','MD_392019'   union all
select 'MD_249613','MD_717646'   union all
select 'MD_249519','MD_716670'   union all
select 'MD_361413','MD_361545'   union all
select 'MD_361414','MD_361546'   union all
select 'MD_361415','MD_361547'   union all
select 'MD_728424','MD_752839'   union all
select 'MD_249524','MD_716672'   union all
select 'MD_249525','MD_716673'   union all
select 'MD_614983','MD_625222'   union all
select 'MD_659689','MD_660085'   union all
select 'MD_442036','MD_550452'   union all
select 'MD_652252','MD_675074'   union all
select 'MD_570590','MD_629781'   union all
select 'MD_766546','MD_766577'   union all
select 'MD_766545','MD_766578'   union all
select 'MD_769222','MD_769529'   union all
select 'MD_769221','MD_769530'   union all
select 'MD_767715','MD_768046'   union all
select 'MD_767716','MD_768047'   union all
select 'MD_767717','MD_768048'   union all
select 'MD_351169','MD_352021'   union all
select 'MD_369796','MD_370891'   union all
select 'MD_342970','MD_345251'   union all
select 'MD_768355','MD_768360'   union all
select 'MD_768356','MD_768361'   union all
select 'MD_525073','MD_674899'   union all
select 'MD_525726','MD_550681'   union all
select 'MD_525727','MD_550682'   union all
select 'MD_525728','MD_550683'   union all
select 'MD_428995','MD_550401'   union all
select 'MD_278669','MD_419154'   union all
select 'MD_278669','MD_721655'   union all
select 'MD_278679','MD_419117'   union all
select 'MD_429096','MD_550419'   union all
select 'MD_280931','MD_510628'   union all
select 'MD_278676','MD_492826'   union all
select 'MD_278678','MD_510421'   union all
select 'MD_278837','MD_510418'   union all
select 'MD_429069','MD_550416'   union all
select 'MD_458256','MD_736413'   union all
select 'MD_598727','MD_599018'   union all
select 'MD_436879','MD_490203'   union all
select 'MD_436880','MD_490204'   union all
select 'MD_436881','MD_490205'   union all
select 'MD_491541','MD_674888'   union all
select 'MD_502918','MD_508392'   union all
select 'MD_502917','MD_508391'   union all
select 'MD_527909','MD_550686'   union all
select 'MD_527910','MD_550687'   union all
select 'MD_515700','MD_550668'   union all
select 'MD_515698','MD_550667'   union all
select 'MD_557819','MD_674907'   union all
select 'MD_537462','MD_583805'   union all
select 'MD_543858','MD_569269'   union all
select 'MD_543858','MD_597157'   union all
select 'MD_583169','MD_583426'   union all
select 'MD_560103','MD_560388'   union all
select 'MD_718175','MD_718664'   union all
select 'MD_429075','MD_674884'   union all
select 'MD_494077','MD_614603'   union all
select 'MD_624945','MD_626044'   union all
select 'MD_705271','MD_706748'   union all
select 'MD_712759','MD_716679'   union all
select 'MD_715472','MD_716680'   union all
select 'MD_720673','MD_721030'   union all
select 'MD_756517','MD_759097'   union all
select 'MD_297926','MD_738543'   union all
select 'MD_301274','MD_741753'   union all
select 'MD_327345','MD_739514'   union all
select 'MD_327345','MD_539289'   union all
select 'MD_307970','MD_734617'   union all
select 'MD_304622','MD_731437'   union all
select 'MD_311318','MD_740627'   union all
select 'MD_239501','MD_381384'   union all
select 'MD_314666','MD_731932'   union all
select 'MD_265035','MD_334711'   union all
select 'MD_653371','MD_675080'   union all
select 'MD_403072','MD_437262'   union all
select 'MD_388049','MD_392284'   union all
select 'MD_381179','MD_392007'   union all
select 'MD_381178','MD_392006'   union all
select 'MD_249556','MD_716687'   union all
select 'MD_539840','MD_608985'   union all
select 'MD_591773','MD_674939'   union all
select 'MD_249564','MD_716688'   union all
select 'MD_384739','MD_392069'   union all
select 'MD_375874','MD_391969'   union all
select 'MD_249565','MD_716691'   union all
select 'MD_238153','MD_368638'   union all
select 'MD_749585','MD_752630'   union all
select 'MD_749584','MD_752629'   union all
select 'MD_750430','MD_752628'   union all
select 'MD_750835','MD_752631'   union all
select 'MD_750834','MD_752632'   union all
select 'MD_758633','MD_765404'   union all
select 'MD_761581','MD_766472'   union all
select 'MD_760914','MD_766470'   union all
select 'MD_762288','MD_766471'   union all
select 'MD_504925','MD_513186'   union all
select 'MD_542109','MD_571284'   union all
select 'MD_361695','MD_391922'   union all
select 'MD_375745','MD_391966'   union all
select 'MD_383167','MD_392030'   union all
select 'MD_387009','MD_392166'   union all
select 'MD_385019','MD_392078'   union all
select 'MD_387008','MD_392165'   union all
select 'MD_385020','MD_392079'   union all
select 'MD_265812','MD_324167'   union all
select 'MD_716930','MD_559267'   union all
select 'MD_382249','MD_392016'   union all
select 'MD_361696','MD_391923'   union all
select 'MD_385018','MD_392077'   union all
select 'MD_387007','MD_392164'   union all
select 'MD_249594','MD_718035'   union all
select 'MD_657258','MD_719278'   union all
select 'MD_728950','MD_516175'   union all
select 'MD_624059','MD_624209'   union all
select 'MD_624040','MD_624057'   union all
select 'MD_621285','MD_633054'   union all
select 'MD_622701','MD_633055'   union all
select 'MD_758969','MD_768039'   union all
select 'MD_249599','MD_716700'   union all
select 'MD_249604','MD_716701'   union all
select 'MD_380836','MD_391999'   union all
select 'MD_387409','MD_392201'   union all
select 'MD_666098','MD_693355'   union all
select 'MD_365465','MD_494241'   union all
select 'MD_568324','MD_716900'   union all
select 'MD_706360','MD_696929'   union all
select 'MD_380267','MD_354811'   union all
select 'MD_717023','MD_715326'   union all
select 'MD_717094','MD_715342'   union all
select 'MD_753969','MD_696179'   union all
select 'MD_753970','MD_753849'   union all
select 'MD_724949','MD_1018'	   union all
select 'MD_732317','MD_732314'   union all
select 'MD_1027'  ,'MD_724954'   union all
select 'MD_602635','MD_674961'   union all
select 'MD_1033'  ,'MD_724962'   union all
select 'MD_755855','MD_755809'   union all
select 'MD_755856','MD_755810'   union all
select 'MD_755857','MD_755811'   union all
select 'MD_753972','MD_753851'   union all
select 'MD_753971','MD_753850'   union all
select 'MD_550625','MD_510592'   union all
select 'MD_1039'  ,'MD_742618'   union all
select 'MD_1040'  ,'MD_724976'   union all
select 'MD_732318','MD_732315'   union all
select 'MD_716915','MD_715217'   union all
select 'MD_427300','MD_243421'   union all
select 'MD_645632','MD_644802'   union all
select 'MD_727985','MD_727915'   union all
select 'MD_1063'  ,'MD_724998'   union all
select 'MD_717798','MD_717813'   union all
select 'MD_717075','MD_715228'   union all
select 'MD_756620','MD_731976'   union all
select 'MD_713560','MD_713561'   union all
select 'MD_713593','MD_713592'   union all
select 'MD_713633','MD_713638'   union all
select 'MD_713587','MD_713590'   union all
select 'MD_713597','MD_713595'   union all
select 'MD_713634','MD_713639'   union all
select 'MD_713653','MD_713655'   union all
select 'MD_689339','MD_713859'   union all
select 'MD_689339','MD_713863'   union all
select 'MD_727989','MD_728353'   union all
select 'MD_1002'  ,'MD_722808'   union all
select 'MD_297954','MD_72'	   union all
select 'MD_749078','MD_677734'   union all
select 'MD_301302','MD_749415'   union all
select 'MD_307998','MD_740628'   union all
select 'MD_304650','MD_739735'   union all
select 'MD_748794','MD_753973'   union all
select 'MD_311346','MD_743211'   union all
select 'MD_314694','MD_741750'   union all
select 'MD_727979','MD_728343'   union all
select 'MD_728350','MD_727986'   union all
select 'MD_681632','MD_681584'   union all
select 'MD_733573','MD_733871'   union all
select 'MD_724065','MD_724066'   union all
select 'MD_756955','MD_757615'   union all
select 'MD_756955','MD_757971'   union all
select 'MD_756955','MD_756521'   union all
select 'MD_756955','MD_758280'   union all
select 'MD_756955','MD_758569'   union all
select 'MD_756955','MD_760818'   union all
select 'MD_756955','MD_758894'   union all
select 'MD_756955','MD_759918'   union all
select 'MD_756955','MD_763067'   union all
select 'MD_756955','MD_764275'   union all
select 'MD_756955','MD_764690'   union all
select 'MD_756955','MD_762541'   union all
select 'MD_756955','MD_761153'   union all
select 'MD_756955','MD_761454'   union all
select 'MD_756955','MD_763972'   union all
select 'MD_756955','MD_765217'   union all
select 'MD_756955','MD_726842'   union all
select 'MD_756955','MD_727219'   union all
select 'MD_756955','MD_728342'   union all
select 'MD_756955','MD_728688'   union all
select 'MD_756955','MD_733802'   union all
select 'MD_756955','MD_732207'   union all
select 'MD_756955','MD_732650'   union all
select 'MD_756955','MD_734590'   union all
select 'MD_756955','MD_735822'   union all
select 'MD_756955','MD_737633'   union all
select 'MD_756955','MD_736414'   union all
select 'MD_756955','MD_734928'   union all
select 'MD_756955','MD_739566'   union all
select 'MD_756955','MD_751037'   union all
select 'MD_756955','MD_751376'   union all
select 'MD_756955','MD_751777'   union all
select 'MD_756955','MD_752195'   union all
select 'MD_756955','MD_754971'   union all
select 'MD_756955','MD_754410'  


INSERT INTO #tblot_dg
SELECT rcd_num
	,instr_id
FROM lot_dg
WHERE instr_id IN ('MD_720274'   
,'MD_320886'
,'MD_545969'
,'MD_353852'
,'MD_707559'
,'MD_730586'
,'MD_369743'
,'MD_315312'
,'MD_395228'
,'MD_315332'
,'MD_716902'
,'MD_516410'
,'MD_332217'
,'MD_667562'
,'MD_716907'
,'MD_716908'
,'MD_531938'
,'MD_402731'
,'MD_668570'
,'MD_716706'
,'MD_380265'
,'MD_268638'
,'MD_337772'
,'MD_480237'
,'MD_357905'
,'MD_716716'
,'MD_688856'
,'MD_639069'
,'MD_713314'
,'MD_716741'
,'MD_716743'
,'MD_725753'
,'MD_437397'
,'MD_718052'
,'MD_326361'
,'MD_739869'
,'MD_538563'
,'MD_268129'
,'MD_327328'
,'MD_268639'
,'MD_268633'
,'MD_268634'
,'MD_268637'
,'MD_720578'
,'MD_352910'
,'MD_326396'
,'MD_518611'
,'MD_602098'
,'MD_653241'
,'MD_755702'
,'MD_711783'
,'MD_475259'
,'MD_545460'
,'MD_716819'
,'MD_359121'
,'MD_684664'
,'MD_689708'
,'MD_707449'
,'MD_674990'
,'MD_674922'
,'MD_675008'
,'MD_504601'
,'MD_550402'
,'MD_674985'
,'MD_504599'
,'MD_704091'
,'MD_550523'
,'MD_550575'
,'MD_675037'
,'MD_638651'
,'MD_666114'
,'MD_582484'
,'MD_706193'
,'MD_569299'
,'MD_716708'
,'MD_674957'
,'MD_660234'
,'MD_550510'
,'MD_569275'
,'MD_547811'
,'MD_716710'
,'MD_759489'
,'MD_759488'
,'MD_716711'
,'MD_716712'
,'MD_550437'
,'MD_569235'
,'MD_721164'
,'MD_674956'
,'MD_716715'
,'MD_675001'
,'MD_674992'
,'MD_674928'
,'MD_716717'
,'MD_754474'
,'MD_752958'
,'MD_752957'
,'MD_744205'
,'MD_752956'
,'MD_744206'
,'MD_747278'
,'MD_550649'
,'MD_599369'
,'MD_692679'
,'MD_716718'
,'MD_550431'
,'MD_716719'
,'MD_452546'
,'MD_550458'
,'MD_550425'
,'MD_492461'
,'MD_674927'
,'MD_675097'
,'MD_550656'
,'MD_550507'
,'MD_719210'
,'MD_550432'
,'MD_456544'
,'MD_716726'
,'MD_581140'
,'MD_569279'
,'MD_453759'
,'MD_553178'
,'MD_569277'
,'MD_675061'
,'MD_675047'
,'MD_707134'
,'MD_550555'
,'MD_682447'
,'MD_675006'
,'MD_674915'
,'MD_675025'
,'MD_605328'
,'MD_674936'
,'MD_527676'
,'MD_716749'
,'MD_550591'
,'MD_550617'
,'MD_437370'
,'MD_550670'
,'MD_712543'
,'MD_744207'
,'MD_744208'
,'MD_716763'
,'MD_716764'
,'MD_745337'
,'MD_716766'
,'MD_716767'
,'MD_550409'
,'MD_550410'
,'MD_422811'
,'MD_357607'
,'MD_357608'
,'MD_357609'
,'MD_357610'
,'MD_550536'
,'MD_716770'
,'MD_716771'
,'MD_674924'
,'MD_550542'
,'MD_569304'
,'MD_550618'
,'MD_675017'
,'MD_716772'
,'MD_569260'
,'MD_753967'
,'MD_753968'
,'MD_755859'
,'MD_755860'
,'MD_755858'
,'MD_675115'
,'MD_569245'
,'MD_550427'
,'MD_716778'
,'MD_550461'
,'MD_389792'
,'MD_569276'
,'MD_550669'
,'MD_759098'
,'MD_431455'
,'MD_569301'
,'MD_579409'
,'MD_716783'
,'MD_719810'
,'MD_674991'
,'MD_715726'
,'MD_569316'
,'MD_716791'
,'MD_716792'
,'MD_550584'
,'MD_550544'
,'MD_569264'
,'MD_626894'
,'MD_716794'
,'MD_715947'
,'MD_550516'
,'MD_457515'
,'MD_716795'
,'MD_716796'
,'MD_716797'
,'MD_716798'
,'MD_518580'
,'MD_550553'
,'MD_675068'
,'MD_716805'
,'MD_569292'
,'MD_550311'
,'MD_578943'
,'MD_578944'
,'MD_716811'
,'MD_569315'
,'MD_550628'
,'MD_569256'
,'MD_550532'
,'MD_550531'
,'MD_653613'
,'MD_675087'
,'MD_569310'
,'MD_550549'
,'MD_716814'
,'MD_675023'
,'MD_675011'
,'MD_674982'
,'MD_700446'
,'MD_716818'
,'MD_550502'
,'MD_674975'
,'MD_550443'
,'MD_550444'
,'MD_569282'
,'MD_633388'
,'MD_716821'
,'MD_550472'
,'MD_569296'
,'MD_716824'
,'MD_603777'
,'MD_550385'
,'MD_716828'
,'MD_788'
,'MD_716829'
,'MD_716830'
,'MD_585047'
,'MD_569271'
,'MD_716833'
,'MD_717938'
,'MD_708969'
,'MD_708968'
,'MD_582213'
,'MD_749804'
,'MD_543359'
,'MD_692680'
,'MD_689946'
,'MD_744031'
,'MD_674971'
,'MD_674969'
,'MD_716840'
,'MD_716841'
,'MD_716842'
,'MD_716843'
,'MD_716844'
,'MD_674929'
,'MD_674966'
,'MD_585321'
,'MD_716845'
,'MD_716846'
,'MD_585322'
,'MD_543857'
,'MD_569303'
,'MD_543576'
,'MD_600875'
,'MD_675093'
,'MD_569263'
,'MD_550550'
,'MD_692432'
,'MD_346369'
,'MD_550619'
,'MD_550654'
,'MD_592713'
,'MD_569284'
,'MD_595150'
,'MD_659892'
,'MD_716853'
,'MD_716854'
,'MD_698708'
,'MD_595158'
,'MD_692431'
,'MD_550310'
,'MD_455549'
,'MD_550541'
,'MD_550585'
,'MD_625223'
,'MD_595154'
,'MD_569274'
,'MD_716860'
,'MD_675094'
,'MD_716862'
,'MD_716863'
,'MD_716864'
,'MD_716865'
,'MD_716866'
,'MD_582724'
,'MD_674986'
,'MD_550554'
,'MD_595152'
,'MD_722427'
,'MD_550566'
,'MD_550568'
,'MD_566523'
,'MD_716870'
,'MD_664617'
,'MD_716871'
,'MD_569289'
,'MD_675013'
,'MD_674979'
,'MD_674909'
,'MD_759627'
,'MD_569262'
,'MD_716658'
,'MD_276092'
,'MD_716912'
,'MD_267026'
,'MD_717363'
,'MD_568670'
,'MD_497933'
,'MD_341495'
,'MD_734883'
,'MD_739511'
,'MD_720259'
,'MD_337353'
,'MD_399659'
,'MD_336902'
,'MD_387013'
,'MD_354865'
,'MD_496566'
,'MD_354866'
,'MD_365575'
,'MD_532564'
,'MD_716916'
,'MD_430650'
,'MD_503726'
,'MD_574579'
,'MD_477991'
,'MD_711572'
,'MD_707563'
,'MD_723486'
,'MD_574580'
,'MD_436181'
,'MD_547626'
,'MD_561749'
,'MD_532571'
,'MD_719280'
,'MD_716923'
,'MD_623909'
,'MD_642952'
,'MD_716925'
,'MD_653193'
,'MD_668958'
,'MD_678190'
,'MD_717499'
,'MD_712238'
,'MD_750226'
,'MD_735193'
,'MD_746795'
,'MD_744579'
,'MD_744580'
,'MD_765707'
,'MD_329300'
,'MD_758120'
,'MD_764912'
,'MD_758121'
,'MD_758129'
,'MD_758130'
,'MD_758131'
,'MD_769888'
,'MD_392128'
,'MD_759629'
,'MD_760497'
,'MD_550626'
,'MD_569309'
,'MD_704090'
,'MD_579025'
,'MD_768358'
,'MD_768359'
,'MD_625950'
,'MD_715636'
,'MD_321871'
,'MD_321950'
,'MD_249479'
,'MD_767187'
,'MD_716666'
,'MD_716667'
,'MD_502921'
,'MD_466930'
,'MD_632709'
,'MD_626608'
,'MD_392000'
,'MD_755863'
,'MD_755866'
,'MD_756161'
,'MD_743206'
,'MD_675026'
,'MD_696283'
,'MD_716883'
,'MD_542561'
,'MD_674940'
,'MD_569251'
,'MD_409002'
,'MD_723998'
,'MD_633400'
,'MD_632764'
,'MD_716669'
,'MD_458018'
,'MD_391950'
,'MD_392019'
,'MD_717646'
,'MD_716670'
,'MD_361545'
,'MD_361546'
,'MD_361547'
,'MD_752839'
,'MD_716672'
,'MD_716673'
,'MD_625222'
,'MD_660085'
,'MD_550452'
,'MD_675074'
,'MD_629781'
,'MD_766577'
,'MD_766578'
,'MD_769529'
,'MD_769530'
,'MD_768046'
,'MD_768047'
,'MD_768048'
,'MD_352021'
,'MD_370891'
,'MD_345251'
,'MD_768360'
,'MD_768361'
,'MD_674899'
,'MD_550681'
,'MD_550682'
,'MD_550683'
,'MD_550401'
,'MD_419154'
,'MD_721655'
,'MD_419117'
,'MD_550419'
,'MD_510628'
,'MD_492826'
,'MD_510421'
,'MD_510418'
,'MD_550416'
,'MD_736413'
,'MD_599018'
,'MD_490203'
,'MD_490204'
,'MD_490205'
,'MD_674888'
,'MD_508392'
,'MD_508391'
,'MD_550686'
,'MD_550687'
,'MD_550668'
,'MD_550667'
,'MD_674907'
,'MD_583805'
,'MD_569269'
,'MD_597157'
,'MD_583426'
,'MD_560388'
,'MD_718664'
,'MD_674884'
,'MD_614603'
,'MD_626044'
,'MD_706748'
,'MD_716679'
,'MD_716680'
,'MD_721030'
,'MD_759097'
,'MD_738543'
,'MD_741753'
,'MD_739514'
,'MD_539289'
,'MD_734617'
,'MD_731437'
,'MD_740627'
,'MD_381384'
,'MD_731932'
,'MD_334711'
,'MD_675080'
,'MD_437262'
,'MD_392284'
,'MD_392007'
,'MD_392006'
,'MD_716687'
,'MD_608985'
,'MD_674939'
,'MD_716688'
,'MD_392069'
,'MD_391969'
,'MD_716691'
,'MD_368638'
,'MD_752630'
,'MD_752629'
,'MD_752628'
,'MD_752631'
,'MD_752632'
,'MD_765404'
,'MD_766472'
,'MD_766470'
,'MD_766471'
,'MD_513186'
,'MD_571284'
,'MD_391922'
,'MD_391966'
,'MD_392030'
,'MD_392166'
,'MD_392078'
,'MD_392165'
,'MD_392079'
,'MD_324167'
,'MD_559267'
,'MD_392016'
,'MD_391923'
,'MD_392077'
,'MD_392164'
,'MD_718035'
,'MD_719278'
,'MD_516175'
,'MD_624209'
,'MD_624057'
,'MD_633054'
,'MD_633055'
,'MD_768039'
,'MD_716700'
,'MD_716701'
,'MD_391999'
,'MD_392201'
,'MD_693355'
,'MD_494241'
,'MD_716900'
,'MD_696929'
,'MD_354811'
,'MD_715326'
,'MD_715342'
,'MD_696179'
,'MD_753849'
,'MD_1018'
,'MD_732314'
,'MD_724954'
,'MD_674961'
,'MD_724962'
,'MD_755809'
,'MD_755810'
,'MD_755811'
,'MD_753851'
,'MD_753850'
,'MD_510592'
,'MD_742618'
,'MD_724976'
,'MD_732315'
,'MD_715217'
,'MD_243421'
,'MD_644802'
,'MD_727915'
,'MD_724998'
,'MD_717813'
,'MD_715228'
,'MD_731976'
,'MD_713561'
,'MD_713592'
,'MD_713638'
,'MD_713590'
,'MD_713595'
,'MD_713639'
,'MD_713655'
,'MD_713859'
,'MD_713863'
,'MD_728353'
,'MD_722808'
,'MD_72'
,'MD_677734'
,'MD_749415'
,'MD_740628'
,'MD_739735'
,'MD_753973'
,'MD_743211'
,'MD_741750'
,'MD_728343'
,'MD_727986'
,'MD_681584'
,'MD_733871'
,'MD_724066'
,'MD_757615'
,'MD_757971'
,'MD_756521'
,'MD_758280'
,'MD_758569'
,'MD_760818'
,'MD_758894'
,'MD_759918'
,'MD_763067'
,'MD_764275'
,'MD_764690'
,'MD_762541'
,'MD_761153'
,'MD_761454'
,'MD_763972'
,'MD_765217'
,'MD_726842'
,'MD_727219'
,'MD_728342'
,'MD_728688'
,'MD_733802'
,'MD_732207'
,'MD_732650'
,'MD_734590'
,'MD_735822'
,'MD_737633'
,'MD_736414'
,'MD_734928'
,'MD_739566'
,'MD_751037'
,'MD_751376'
,'MD_751777'
,'MD_752195'
,'MD_754971'
,'MD_754410')

--SELECT *
--FROM #templot_dg

--SELECT *
--FROM #tblot_dg

--SELECT rcd_num
--	,tb.old_instr_id
--	,tmp.new_instr_id
--FROM #templot_dg tmp
--INNER JOIN #tblot_dg tb ON tmp.new_instr_id = tb.old_instr_id
BEGIN TRY
	WHILE 1 = 1
	BEGIN
		BEGIN TRANSACTION;

		UPDATE TOP (@Updatebatchsize) l
		SET l.instr_id = tbl.new_instr_id
		FROM dbo.lot_dg l
		INNER JOIN (
			SELECT rcd_num
				,tb.old_instr_id
				,tmp.new_instr_id
			FROM #templot_dg tmp
			INNER JOIN #tblot_dg tb ON tmp.old_instr_id = tb.old_instr_id
			) tbl ON tbl.RCD_NUM = l.rcd_num
			and tbl.old_instr_id = l.instr_id;

		SET @RowCount = @@rowcount;
		SET @TOTALROWS = @TOTALROWS + @RowCount;

		IF @RowCount = 0 -- terminating condition;
		BEGIN
			COMMIT TRANSACTION;

			BREAK;
		END;

		COMMIT TRANSACTION;

		-- WAITFOR DELAY '00:00:01';
		PRINT 'Total records Updated as of now ' + CAST(@TOTALROWS AS VARCHAR) + ' total rows';
	END;
END TRY

BEGIN CATCH
	IF XACT_STATE() <> 0
		OR @@TRANCOUNT > 0
	BEGIN
		ROLLBACK TRANSACTION;
	END;

	DECLARE @error_Message VARCHAR(4000);
	DECLARE @error_Severity INT;
	DECLARE @error_State INT;

	SET @error_Message = 'Error encoutered while updating records for tables dbo.Position_dg ' + ERROR_MESSAGE();
	SET @error_Severity = ERROR_SEVERITY();
	SET @error_State = ERROR_STATE();

	RAISERROR (
			@error_Message
			,@error_Severity
			,@error_State
			);
END CATCH;

PRINT SPACE(100);
PRINT '-------------Script completed at :' + CONVERT(CHAR(23), GETDATE(), 121) + '------------------------';

