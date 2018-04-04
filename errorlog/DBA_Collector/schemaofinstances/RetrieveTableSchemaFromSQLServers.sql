SET NOCOUNT ON

DECLARE @SQLServer		varchar(128)
		,@Connection	varchar(512)
		,@Cmd			varchar(2048)
		,@Script		varchar(512)
		,@OutputTo		varchar(512)
		,@ReturnValue	int
		,@SuccessCount	varchar(15)
		,@ErrorCount	varchar(15)
		,@Length		int
		,@Total			int
		
SET @Script = 'L:\scriptsforschema\New folder\GatherTableSchemaAllDBs.sql'
SET @OutputTo = 'L:\scriptsforschema\output\serverdbschema.out'

CREATE TABLE #ServerInfo
(
	ServerName		varchar(128)
	,SQLConnection	varchar(512)
)
INSERT INTO #ServerInfo VALUES ('10.224.16.70','10.224.16.70')----------------	AC0GACL010
---------------INSERT INTO #ServerInfo VALUES ('		,'		)----------------	VAVCSQLSECA01\SECA01
---------------INSERT INTO #ServerInfo VALUES ('		,'		)----------------	VAVCSQLSECA02\SECA02
INSERT INTO #ServerInfo VALUES ('30.128.190.193','30.128.190.193')----------------	VAVCSQLSECA01\SECA01
INSERT INTO #ServerInfo VALUES ('30.128.190.192','30.128.190.192')----------------	VAVCSQLSECA02\SECA02
INSERT INTO #ServerInfo VALUES ('30.128.160.24','30.128.160.24')----------------	vaw2krichds1
INSERT INTO #ServerInfo VALUES ('30.128.160.25','30.128.160.25')----------------	vaw2kriclgra
INSERT INTO #ServerInfo VALUES ('30.122.29.38','30.122.29.38')----------------	vaw2kroahds2
INSERT INTO #ServerInfo VALUES ('30.122.29.37','30.122.29.37')----------------	vaw2kroalgrb
INSERT INTO #ServerInfo VALUES ('30.128.160.32','30.128.160.32')----------------	vaw2kricaw1
INSERT INTO #ServerInfo VALUES ('30.128.160.33','30.128.160.33')----------------	vaw2kricaw2
INSERT INTO #ServerInfo VALUES ('30.128.201.101','30.128.201.101')----------------	vcnxdbp01
INSERT INTO #ServerInfo VALUES ('30.128.201.64','30.128.201.64')----------------	vcnxdbp01
INSERT INTO #ServerInfo VALUES ('2.136.12.44','2.136.12.44')----------------	eefa06
INSERT INTO #ServerInfo VALUES ('172.29.112.167','172.29.112.167')----------------	SALINTEGRA01
INSERT INTO #ServerInfo VALUES ('172.29.117.47','172.29.117.47')----------------	SALICMAW1
INSERT INTO #ServerInfo VALUES ('172.29.117.42','172.29.117.42')----------------	SALICMLGRA
INSERT INTO #ServerInfo VALUES ('172.25.220.136','172.25.220.136')----------------	SMECACTUS01
INSERT INTO #ServerInfo VALUES ('172.29.117.43','172.29.117.43')----------------	SALICMHDS1
INSERT INTO #ServerInfo VALUES ('30.135.21.123','30.135.21.123')----------------	VADWVCLUMSQL
INSERT INTO #ServerInfo VALUES ('30.135.21.124','30.135.21.124')----------------	VADWVCLUMSQL
INSERT INTO #ServerInfo VALUES ('30.130.35.162','30.130.35.162')----------------	N2KSECMGR03
INSERT INTO #ServerInfo VALUES ('30.18.24.143','30.18.24.143')----------------	ohw2kaba04
INSERT INTO #ServerInfo VALUES ('30.18.101.190','30.18.101.190')----------------	OHW2KWLM1
-----INSERT INTO #ServerInfo VALUES ('		,'		)----------------	va2kcv01esm
-----INSERT INTO #ServerInfo VALUES ('		,'		)----------------	VA2KCV01ESM\VA2KCV01ESM
INSERT INTO #ServerInfo VALUES ('30.18.24.226','30.18.24.226')----------------	ohw2krxsql03
INSERT INTO #ServerInfo VALUES ('10.175.186.11','10.175.186.11')----------------	mtas2\bkupexec
-----INSERT INTO #ServerInfo VALUES ('		,'		)----------------	mtas2
-----INSERT INTO #ServerInfo VALUES ('		,'		)----------------	bkupexec
INSERT INTO #ServerInfo VALUES ('10.173.8.85','10.173.8.85')----------------	mke310
INSERT INTO #ServerInfo VALUES ('10.173.8.64','10.173.8.64')----------------	catbert3
INSERT INTO #ServerInfo VALUES ('10.221.130.50','10.221.130.50')----------------	FW01A2K010
INSERT INTO #ServerInfo VALUES ('30.22.44.211','30.22.44.211')----------------	OHPWPAP001
----INSERT INTO #ServerInfo VALUES ('		,'		)----------------	VAPVCSQLNIB01
----INSERT INTO #ServerInfo VALUES ('		,		)----------------	VAPVCSQLNIB01
INSERT INTO #ServerInfo VALUES ('30.130.32.192','30.130.32.192')----------------	VAPWPWERDB01
INSERT INTO #ServerInfo VALUES ('30.128.201.71','30.128.201.71')----------------	VCSQL20
INSERT INTO #ServerInfo VALUES ('30.128.201.71','30.128.201.71')----------------	VCSQL20
INSERT INTO #ServerInfo VALUES ('30.130.18.225','30.130.18.225')----------------	VAPWVSQLWEBSNS1\WEBSNS01
INSERT INTO #ServerInfo VALUES ('30.130.18.223','30.130.18.223')----------------	VAPWVSQLWEBSNS1\WEBSNS01
INSERT INTO #ServerInfo VALUES ('30.130.32.118','30.130.32.118')----------------	vapwpsqlimg02
--------INSERT INTO #ServerInfo VALUES ('		,'		)----------------	vapwvhids002
-----INSERT INTO #ServerInfo VALUES ('	,'		)----------------	TBD
INSERT INTO #ServerInfo VALUES ('10.229.66.24','10.229.66.24')----------------	NQ01A2K015
INSERT INTO #ServerInfo VALUES ('10.226.2.32','10.226.2.32')----------------	T101A2K027
INSERT INTO #ServerInfo VALUES ('10.221.130.29','10.221.130.29')----------------	FW0GA2K005
INSERT INTO #ServerInfo VALUES ('10.224.16.192','10.224.16.192')----------------	AC0GA2K139
INSERT INTO #ServerInfo VALUES ('10.224.17.137','10.224.17.137')----------------	AC0GA2K303
INSERT INTO #ServerInfo VALUES ('30.130.35.79','30.130.35.79')----------------	va10pwvsql010
INSERT INTO #ServerInfo VALUES ('30.130.37.42','30.130.37.42')----------------	VA10PWPSQL007
INSERT INTO #ServerInfo VALUES ('10.229.66.80','10.229.66.80')----------------	NQ01A2K032
INSERT INTO #ServerInfo VALUES ('30.22.49.59','30.22.49.59')----------------	OH03VCSQLRSQ01
INSERT INTO #ServerInfo VALUES ('30.22.49.61','30.22.49.61')----------------	OH03VCSQLRSQ01
INSERT INTO #ServerInfo VALUES ('30.144.57.23','30.144.57.23')----------------	MOM9PWPSQL001
---------INSERT INTO #ServerInfo VALUES ('		,'		)----------------	TBD
---------INSERT INTO #ServerInfo VALUES ('	,'		)----------------	SQL01
INSERT INTO #ServerInfo VALUES ('30.128.128.41','30.128.128.41')----------------	va10pwpgep002\sql01
INSERT INTO #ServerInfo VALUES ('30.128.128.42','30.128.128.42')----------------	va10pwpgep003\sql01
INSERT INTO #ServerInfo VALUES ('30.130.38.184','30.130.38.184')----------------	VA10PWVSQL017\SQL01
INSERT INTO #ServerInfo VALUES ('30.130.32.126','30.130.32.126')----------------	VAPWCSQL500\SQL500
INSERT INTO #ServerInfo VALUES ('30.122.28.37','30.122.28.37')----------------	SQL500
INSERT INTO #ServerInfo VALUES ('30.122.28.36','30.122.28.36')----------------	SQL500
INSERT INTO #ServerInfo VALUES ('30.130.32.124','30.130.32.124')----------------	VAPWCSQL500\SQL500
INSERT INTO #ServerInfo VALUES ('30.132.48.31','30.132.48.31')----------------	MOM9PWVSQL002c\SQL01
INSERT INTO #ServerInfo VALUES ('30.132.48.32','30.132.48.32')----------------	MOM9PWVSQL002c\SQL01
-----------INSERT INTO #ServerInfo VALUES ('		,'		)----------------	SQL01
INSERT INTO #ServerInfo VALUES ('30.132.48.63','30.132.48.63')----------------	MOM9PWPSQL005\SQL01
INSERT INTO #ServerInfo VALUES ('30.128.80.58','30.128.80.58')----------------	VA10PWVUNI004\SQL01
-------INSERT INTO #ServerInfo VALUES ('		,'		)----------------	sql01
INSERT INTO #ServerInfo VALUES ('30.128.80.216','30.128.80.216')----------------	va10pwvsql023\sql01
INSERT INTO #ServerInfo VALUES ('30.128.80.56','30.128.80.56')----------------	va10pwvuni002\sql01
--------INSERT INTO #ServerInfo VALUES ('		,'		)----------------	SQL01
INSERT INTO #ServerInfo VALUES ('30.128.80.108','30.128.80.108')----------------	va10pwvuni010\sql01
--------------INSERT INTO #ServerInfo VALUES ('		,'		)----------------	SQL01
INSERT INTO #ServerInfo VALUES ('30.128.80.109','30.128.80.109')----------------	va10pwvuni011\sql01
INSERT INTO #ServerInfo VALUES ('30.128.80.110','30.128.80.110')----------------	va10pwvuni012\sql01
-----------INSERT INTO #ServerInfo VALUES ('	,'		)----------------	SQL01
INSERT INTO #ServerInfo VALUES ('30.128.80.217','30.128.80.217')----------------	va10pwvsql024\sql01
INSERT INTO #ServerInfo VALUES ('30.128.80.218','30.128.80.218')----------------	va10pwvsql025\sql01
--------INSERT INTO #ServerInfo VALUES ('	,'		)----------------	gagopwpsql001\sql01
INSERT INTO #ServerInfo VALUES ('30.128.201.160','30.128.201.160')----------------	n2ksql02
---------INSERT INTO #ServerInfo VALUES ('		,'		)----------------	TBD
INSERT INTO #ServerInfo VALUES ('30.135.20.136','30.135.20.136')----------------	va10dwvsql020\sql01
INSERT INTO #ServerInfo VALUES ('30.128.81.83','30.128.81.83')----------------	va10pwvsql027\sql01
---------INSERT INTO #ServerInfo VALUES ('		,'		)----------------	SQL01
INSERT INTO #ServerInfo VALUES ('30.72.79.65','30.72.79.65')----------------	co01pwpsql001\sql01
-----------------INSERT INTO #ServerInfo VALUES ('		,'		)----------------	va10pwvsql029\sql01
INSERT INTO #ServerInfo VALUES ('30.128.81.104','30.128.81.104')----------------	va10pwvsql030\sql01
INSERT INTO #ServerInfo VALUES ('30.128.80.33','30.128.80.33')----------------	va10pwvno001\sql01
INSERT INTO #ServerInfo VALUES ('30.128.81.101','30.128.81.101')----------------	va10pwvsql032\sql01
INSERT INTO #ServerInfo VALUES ('30.128.81.103','30.128.81.103')----------------	va10pwvsql031\sql01
INSERT INTO #ServerInfo VALUES ('30.130.38.189','30.130.38.189')----------------	vapwvsqlshrpt010
INSERT INTO #ServerInfo VALUES ('172.29.104.83','172.29.104.83')----------------	ALCLM200
INSERT INTO #ServerInfo VALUES ('30.130.32.160','30.130.32.160')----------------	VA10PWPSPBU002
INSERT INTO #ServerInfo VALUES ('30.130.32.78','30.130.32.78')----------------	VAPWPSPAV01
INSERT INTO #ServerInfo VALUES ('30.130.32.90','30.130.32.90')----------------	VAPWPSPAV02
INSERT INTO #ServerInfo VALUES ('172.29.104.78','172.29.104.78')----------------	ALNYS303
INSERT INTO #ServerInfo VALUES ('172.29.104.87','172.29.104.87')----------------	ALSCAN03
INSERT INTO #ServerInfo VALUES ('172.29.104.54','172.29.104.54')----------------	ALUBE200
INSERT INTO #ServerInfo VALUES ('30.128.163.238','30.128.163.238')----------------	VAPWPSP03
INSERT INTO #ServerInfo VALUES ('30.130.32.132','30.130.32.132')----------------	VAPWPSPBU001
INSERT INTO #ServerInfo VALUES ('30.130.32.134'	,'30.130.32.134')----------------	VAPWPSPBU002
INSERT INTO #ServerInfo VALUES ('172.29.104.79','172.29.104.79')----------------	ALXLI200
INSERT INTO #ServerInfo VALUES ('172.29.240.24','172.29.240.24')----------------	BALCV02
INSERT INTO #ServerInfo VALUES ('30.180.34.11','30.180.34.11')----------------	MLUBE600
INSERT INTO #ServerInfo VALUES ('30.128.201.21','30.128.201.21')----------------	VA10PWPSQL002A
INSERT INTO #ServerInfo VALUES ('30.180.4.15','30.180.4.15')----------------	MTNAC304
INSERT INTO #ServerInfo VALUES ('30.180.4.18','30.180.4.18')----------------	MTNAC403
----INSERT INTO #ServerInfo VALUES ('		,'		)----------------	TBD
----INSERT INTO #ServerInfo VALUES ('		,'		)----------------	TBD
----INSERT INTO #ServerInfo VALUES ('		,'		)----------------	TBD
----INSERT INTO #ServerInfo VALUES ('	,'		)----------------	TBD
INSERT INTO #ServerInfo VALUES ('30.128.163.239','30.128.163.239')----------------	VAPWPSS01
INSERT INTO #ServerInfo VALUES ('172.29.126.95','172.29.126.95')----------------	SALSQLVMVS01
INSERT INTO #ServerInfo VALUES ('172.24.110.28','172.24.110.28')----------------	TTPTHINQ01
-----------INSERT INTO #ServerInfo VALUES ('	,'		)----------------	TBD
INSERT INTO #ServerInfo VALUES ('172.25.224.11','172.25.224.11')----------------	IMEUB700
INSERT INTO #ServerInfo VALUES ('172.23.60.34','172.23.60.34')----------------	sql-prpdb.va1.lumenos.com
INSERT INTO #ServerInfo VALUES ('30.135.10.233','30.135.10.233')----------------	VA10DWVSQL007\SQL01
INSERT INTO #ServerInfo VALUES ('30.130.22.183','30.130.22.183')----------------	VAPWPTPU01
INSERT INTO #ServerInfo VALUES ('172.25.220.53','172.25.220.53')----------------	SMESPSQL01
INSERT INTO #ServerInfo VALUES ('172.29.126.95','172.29.126.95')----------------	SALSQLMVS01
INSERT INTO #ServerInfo VALUES ('172.29.113.87','172.29.113.87')----------------	salsqlacs01a
INSERT INTO #ServerInfo VALUES ('30.180.34.13','30.180.34.13')----------------	MLUBE603
INSERT INTO #ServerInfo VALUES ('30.128.160.77','30.128.160.77')----------------	VAPWPWRM01
-------------INSERT INTO #ServerInfo VALUES ('		,'		)----------------	TBD
INSERT INTO #ServerInfo VALUES ('30.180.4.12','30.180.4.12')----------------	MTNAC300
INSERT INTO #ServerInfo VALUES ('172.29.104.84','172.29.104.84')----------------	ALUPLOAD
INSERT INTO #ServerInfo VALUES ('172.29.56.24','172.29.56.24')----------------	SALCOACHFTR03
INSERT INTO #ServerInfo VALUES ('172.29.112.48','172.29.112.48')----------------	SALELDEV01
INSERT INTO #ServerInfo VALUES ('172.29.104.73','172.29.104.73')----------------	SALOLD90
INSERT INTO #ServerInfo VALUES ('172.29.126.107','172.29.126.107')----------------	SALSQLBTS03
INSERT INTO #ServerInfo VALUES ('172.29.126.119','172.29.126.119')----------------	salsqliso01
INSERT INTO #ServerInfo VALUES ('172.29.104.64','172.29.104.64')----------------	SALSQLMON05
INSERT INTO #ServerInfo VALUES ('172.29.124.77','172.29.124.77')----------------	SALSRCSV01
INSERT INTO #ServerInfo VALUES ('172.29.126.55','172.29.126.55')----------------	SALWHATSUP02
INSERT INTO #ServerInfo VALUES ('30.181.34.43','30.181.34.43')----------------	SMLCOACH01
INSERT INTO #ServerInfo VALUES ('30.181.3.17','30.181.3.17')----------------	SMTCOACHFTR01
INSERT INTO #ServerInfo VALUES ('172.25.231.60','172.25.231.60')----------------	SMEECCDS01
INSERT INTO #ServerInfo VALUES ('172.24.110.26','172.24.110.26')----------------	STPOUTSTRT2
INSERT INTO #ServerInfo VALUES ('172.29.126.47','172.29.126.47')----------------	SALXEROX03
INSERT INTO #ServerInfo VALUES ('82.98.86.169','82.98.86.169')----------------	SMECAC01
INSERT INTO #ServerInfo VALUES ('172.25.220.44','172.25.220.44')----------------	SMECOACH01
INSERT INTO #ServerInfo VALUES ('172.25.220.63','172.25.220.63')----------------	SMEIMPPRO01
INSERT INTO #ServerInfo VALUES ('172.25.220.71','172.25.220.71')----------------	SMEIVRSQL01
INSERT INTO #ServerInfo VALUES ('172.25.224.22','172.25.224.22')----------------	SMEMB100
INSERT INTO #ServerInfo VALUES ('172.25.250.120','172.25.250.120')----------------	SMEPCOMGM01
INSERT INTO #ServerInfo VALUES ('172.25.239.18','172.25.239.18')----------------	SMESANEX01
---------------INSERT INTO #ServerInfo VALUES ('		,'		)----------------	TBD
INSERT INTO #ServerInfo VALUES ('172.29.126.44','172.29.126.44')----------------	SALSQLBTS01
INSERT INTO #ServerInfo VALUES ('82.98.86.169','82.98.86.169')----------------	SALSQLMAC01
INSERT INTO #ServerInfo VALUES ('30.180.32.29','30.180.32.29')----------------	SMLCOACHFTR02
INSERT INTO #ServerInfo VALUES ('172.25.224.19','172.25.224.19')----------------	SMEPRC20
INSERT INTO #ServerInfo VALUES ('172.25.220.120','172.25.220.120')----------------	SMESPSQL02
INSERT INTO #ServerInfo VALUES ('82.98.86.169','82.98.86.169')----------------	SALELVIS01
INSERT INTO #ServerInfo VALUES ('172.29.112.174','172.29.112.174')----------------	SALEMC02
INSERT INTO #ServerInfo VALUES ('82.98.86.169','82.98.86.169')----------------	SMLCITDSTOR01
INSERT INTO #ServerInfo VALUES ('82.98.86.169','82.98.86.169')----------------	BLP01
INSERT INTO #ServerInfo VALUES ('172.29.112.58','172.29.112.58')----------------	IALRDB02
INSERT INTO #ServerInfo VALUES ('30.180.34.12','30.180.34.12')----------------	MLUBE602
INSERT INTO #ServerInfo VALUES ('30.180.4.14','30.180.4.14')----------------	MTNAC303
INSERT INTO #ServerInfo VALUES ('30.180.4.17','30.180.4.17')----------------	MTNAC402
INSERT INTO #ServerInfo VALUES ('172.29.240.22','172.29.240.22')----------------	SALBSVSQL01
INSERT INTO #ServerInfo VALUES ('172.29.56.21','172.29.56.21')----------------	SALCOACH01
INSERT INTO #ServerInfo VALUES ('30.180.2.25','30.180.2.25')----------------	MTUPLOAD
INSERT INTO #ServerInfo VALUES ('30.0.50.27','30.0.50.27')----------------	kyw2krecorder
--------------INSERT INTO #ServerInfo VALUES ('		,'		)----------------	TBD
INSERT INTO #ServerInfo VALUES ('172.25.220.12','172.25.220.12')----------------	SMEWHATSUP01
INSERT INTO #ServerInfo VALUES ('172.25.220.206','172.25.220.206')----------------	BMECV01
INSERT INTO #ServerInfo VALUES ('30.180.4.16','30.180.4.16')----------------	MTNAC400
INSERT INTO #ServerInfo VALUES ('172.29.48.24','172.29.48.24')----------------	SALCOACHFTR02
INSERT INTO #ServerInfo VALUES ('172.29.104.72','172.29.104.72')-------ALACSRB1
INSERT INTO #ServerInfo VALUES ('172.29.113.5',	'172.29.113.5')--------ALCACPRD
INSERT INTO #ServerInfo VALUES ('172.29.104.28','172.29.104.28')-------ALFIN100
INSERT INTO #ServerInfo VALUES ('172.24.130.10','172.24.130.10')-------al32b100
INSERT INTO #ServerInfo VALUES ('172.29.104.77','172.29.104.77')--------ALNYS302
INSERT INTO #ServerInfo VALUES ('172.29.104.86','172.29.104.86')-------ALSCAN02
INSERT INTO #ServerInfo VALUES ('172.29.104.88','172.29.104.88')-------ALSCAN04
INSERT INTO #ServerInfo VALUES ('172.29.124.22','172.29.124.22')-------ALSMSP1
INSERT INTO #ServerInfo VALUES ('172.29.240.23','172.29.240.23')-------BALCV01
INSERT INTO #ServerInfo VALUES ('172.25.220.205','172.25.220.205')-----SMEAVDIST01
INSERT INTO #ServerInfo VALUES ('172.25.221.168','172.25.221.168')-----SMECAASQL02
INSERT INTO #ServerInfo VALUES ('172.25.220.109','172.25.220.109')-----SMEDBIMSQL01
INSERT INTO #ServerInfo VALUES ('172.25.220.163','172.25.220.163')-----SMEFCSQL01
INSERT INTO #ServerInfo VALUES ('172.25.221.105','172.25.221.105')-----SMEINTVSQL01
INSERT INTO #ServerInfo VALUES ('172.25.221.110','172.25.221.110')-----SMEIVRSQL02
INSERT INTO #ServerInfo VALUES ('172.25.220.39','172.25.220.39')-------SMEMISQL01
INSERT INTO #ServerInfo VALUES ('172.25.221.128','172.25.221.128')-----SMESAGEPS03
INSERT INTO #ServerInfo VALUES ('172.25.220.187','172.25.220.187')------SMESMARTSVSQL1
INSERT INTO #ServerInfo VALUES ('172.25.221.64','172.25.221.64')------SMESQLVACS01
INSERT INTO #ServerInfo VALUES ('172.25.220.60','172.25.220.60')------SMESQLMVSDR01
INSERT INTO #ServerInfo VALUES ('30.122.28.237','30.122.28.237	')------N2KISQL501
INSERT INTO #ServerInfo VALUES ('172.29.112.131','172.29.112.131	')------SWTCVSQL02
--------INSERT INTO #ServerInfo VALUES (				VACVWSQL002
----------INSERT INTO #ServerInfo VALUES (				TBD
INSERT INTO #ServerInfo VALUES ('172.25.220.102','172.25.220.102')------SMECAASQL01
INSERT INTO #ServerInfo VALUES ('30.18.23.141','30.18.23.141')------OHPWPRAT01
INSERT INTO #ServerInfo VALUES ('172.25.250.100','172.25.250.100')------SMEVCSQL01
INSERT INTO #ServerInfo VALUES ('30.130.19.239','30.130.19.239')------VAPWPSXTSQL01AS
INSERT INTO #ServerInfo VALUES ('10.175.186.13','10.175.186.13')------WIW0PWPSQL001\SQL02
INSERT INTO #ServerInfo VALUES ('172.25.220.200','172.25.220.200')------SMESQLVTMON02\SQLCPTES001
INSERT INTO #ServerInfo VALUES ('172.29.112.59','172.29.112.59')------IALRDB01
INSERT INTO #ServerInfo VALUES ('172.29.104.85','172.29.104.85')------ALSCAN01
----------INSERT INTO #ServerInfo VALUES (				TBD
INSERT INTO #ServerInfo VALUES ('172.29.104.55','172.29.104.55')------ALUBE202
INSERT INTO #ServerInfo VALUES ('172.29.104.56','172.29.104.56')------ALUBE203
INSERT INTO #ServerInfo VALUES ('172.29.104.74','172.29.104.74')------ALUFE100
INSERT INTO #ServerInfo VALUES ('172.29.113.83','172.29.113.83')------SALEISSQL01
INSERT INTO #ServerInfo VALUES ('172.29.112.52','172.29.112.52')------SALELSQL01
INSERT INTO #ServerInfo VALUES ('172.29.124.33','172.29.124.33')------SALMISQL01
INSERT INTO #ServerInfo VALUES ('172.29.239.18','172.29.239.18')------SALSANEX01
INSERT INTO #ServerInfo VALUES ('172.29.124.56','172.29.124.56')------SALSQLBTS02
INSERT INTO #ServerInfo VALUES ('172.29.124.40','172.29.124.40')------SALSQLEST01
INSERT INTO #ServerInfo VALUES ('172.29.126.51','172.29.126.51')------SALSQLMON04
INSERT INTO #ServerInfo VALUES ('172.29.126.29','172.29.126.29')------SALSQLVMON06
INSERT INTO #ServerInfo VALUES ('172.29.113.109','172.29.113.109')------SALSQLVMON3
INSERT INTO #ServerInfo VALUES ('172.29.126.42','172.29.126.42')------SALWEBC1
INSERT INTO #ServerInfo VALUES ('172.29.112.81','172.29.112.81')------SALWEBHOUSE01
INSERT INTO #ServerInfo VALUES ('172.29.126.50','172.29.126.50')------SALWPMDEV01
INSERT INTO #ServerInfo VALUES ('30.181.3.24','30.181.3.24')------SMTCOACH01
INSERT INTO #ServerInfo VALUES ('172.29.112.194','172.29.112.194')------SNYSQLSTAGE1
INSERT INTO #ServerInfo VALUES ('172.25.251.13','172.25.251.13')------SMEICMHDS2
INSERT INTO #ServerInfo VALUES ('10.8.27.56','10.8.27.56')------SALSQLPLM01
INSERT INTO #ServerInfo VALUES ('192.168.31.16','192.168.31.16')------SMECDE02
INSERT INTO #ServerInfo VALUES ('10.8.44.35','10.8.44.35')------SMEPRODMONSQL1
INSERT INTO #ServerInfo VALUES ('172.25.231.74','172.25.231.74')------SMESQLCTXDS01
INSERT INTO #ServerInfo VALUES ('172.24.110.45','172.24.110.45')------STPCOLVDB1
INSERT INTO #ServerInfo VALUES ('172.29.104.76','172.29.104.76')------ALNYS300
INSERT INTO #ServerInfo VALUES ('172.29.48.23','172.29.48.23')------SALCOACHFTR01
INSERT INTO #ServerInfo VALUES ('30.128.195.71','30.128.195')------VAPWPCISSQL0
INSERT INTO #ServerInfo VALUES ('30.128.195.72','30.128.195.72')----VAPWPCISSQL0
INSERT INTO #ServerInfo VALUES ('172.29.113.8','172.29.113.8')------IALRDB04
INSERT INTO #ServerInfo VALUES ('172.29.124.43','172.29.124.43')------SALCAC01
INSERT INTO #ServerInfo VALUES ('172.25.221.153','172.25.221.153')------SMESQLMON01
INSERT INTO #ServerInfo VALUES ('30.128.160.76','30.128.160.76')------VAPWPIDX01
INSERT INTO #ServerInfo VALUES ('172.25.221.123','172.25.221.123')------BMEBSVSQL01
----------------INSERT INTO #ServerInfo VALUES (				TBD
INSERT INTO #ServerInfo VALUES ('30.128.195.72','30.128.195.72')------VAPWPCISSQL02
INSERT INTO #ServerInfo VALUES ('30.128.193.233','30.128.193.233')------	vaw2kmeddiis02
INSERT INTO #ServerInfo VALUES ('172.29.126.54','172.29.126.54')------SALWHATSUP01
INSERT INTO #ServerInfo VALUES ('30.180.4.13','30.180.4.13')------MTNAC302
INSERT INTO #ServerInfo VALUES ('30.128.193.232','30.128.193.232')------vaw2kmeddiis01
INSERT INTO #ServerInfo VALUES ('172.29.104.57','172.29.104.57')------ALUBE204
INSERT INTO #ServerInfo VALUES ('172.25.252.19','172.25.252.19')------SMEICMLGRB
INSERT INTO #ServerInfo VALUES ('172.29.104.80','172.29.104.80')------ALXLI202
INSERT INTO #ServerInfo VALUES ('172.25.251.28','172.25.251.28')------SMEICMCEMDB01
-----------------INSERT INTO #ServerInfo VALUES (				TBD
INSERT INTO #ServerInfo VALUES ('172.29.104.82','172.29.104.82')------ALHRE200
INSERT INTO #ServerInfo VALUES ('172.25.251.24','172.25.251.24')------SMEICMAW2
INSERT INTO #ServerInfo VALUES ('10.8.44.62','10.8.44.62')------smeratsql01
INSERT INTO #ServerInfo VALUES ('172.25.221.41','172.25.221.41')------SMESABADEV01
INSERT INTO #ServerInfo VALUES ('172.29.126.49','172.29.126.49')------SALWPMPRD01
INSERT INTO #ServerInfo VALUES ('172.29.231.11','172.29.231.11')------SALCITDS01
INSERT INTO #ServerInfo VALUES ('172.30.112.36','172.30.112.36')------SMLSPSQL01
INSERT INTO #ServerInfo VALUES ('30.181.3.18','30.181.3.18')------SMTCOACHFTR02
---------------INSERT INTO #ServerInfo VALUES (				TBD
INSERT INTO #ServerInfo VALUES ('30.180.32.28','30.180.32.28')------SMLCOACHFTR01
INSERT INTO #ServerInfo VALUES ('30.128.81.152','30.128.81.152')------va10pwvsql035\SQL01
INSERT INTO #ServerInfo VALUES ('172.23.60.22','172.23.60.22')------SQL-PECDB
INSERT INTO #ServerInfo VALUES ('172.23.60.23','172.23.60.23')------SQL-PECDB
INSERT INTO #ServerInfo VALUES ('172.23.71.25','172.23.71.25')------SQL-PEMDB
INSERT INTO #ServerInfo VALUES ('172.23.71.24','172.23.71.24')------SQL-PEMDB
INSERT INTO #ServerInfo VALUES ('172.23.60.37','172.23.60.37')------SQL-PLPDB
INSERT INTO #ServerInfo VALUES ('172.23.60.26','172.23.60.26')------SQL-PLPDB
INSERT INTO #ServerInfo VALUES ('172.23.60.28','172.23.60.28')------SQL-PLRDB
INSERT INTO #ServerInfo VALUES ('172.23.60.29','172.23.60.29')------SQL-PLRDB
INSERT INTO #ServerInfo VALUES ('172.23.60.31','172.23.60.31')------SQL-PMDDB
INSERT INTO #ServerInfo VALUES ('172.23.60.30','172.23.60.30')------SQL-PMDDB
INSERT INTO #ServerInfo VALUES ('172.23.60.33','172.23.60.33')------SQL-PRPDB
INSERT INTO #ServerInfo VALUES ('172.23.71.24','172.23.71.24')------SQL-QEMDB
INSERT INTO #ServerInfo VALUES ('30.122.224.20','30.122.224.20')------AVIATOR
INSERT INTO #ServerInfo VALUES ('30.128.81.214','30.128.81.214')------va10pwvsql037\sql01


PRINT CONVERT(varchar(30), GETDATE(), 109) + ' INPUT VARIABLE INFORMATOIN'
PRINT CONVERT(varchar(30), GETDATE(), 109) + '     @Script:    ' + @Script
PRINT CONVERT(varchar(30), GETDATE(), 109) + '     @OutputTo:  ' + @OutputTo

DECLARE CUSROR_SERVERS CURSOR FAST_FORWARD
FOR
	SELECT		ServerName
				,SQLConnection
	FROM		#ServerInfo
	ORDER BY	ServerName
	
OPEN CUSROR_SERVERS

SET @SuccessCount = 0
SET @ErrorCount = 0

FETCH FROM CUSROR_SERVERS
INTO @SQLServer, @Connection	

-- Reset Output File
SET @Cmd = 'echo.> "' + @OutputTo + '"'
EXECUTE xp_cmdshell  @Cmd, NO_OUTPUT

PRINT CONVERT(varchar(30), GETDATE(), 109) 

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT CONVERT(varchar(30), GETDATE(), 109) + ' GRABBING INFO FROM SQL SERVER ' + @SQLServer
	
	SET @Cmd = 'sqlcmd -S ' + @Connection + ' -d master -E -b -Q "SELECT @@VERSION" -l 10'
	
	EXECUTE @ReturnValue = xp_cmdshell @Cmd, NO_OUTPUT					

	IF @ReturnValue <> 0
		BEGIN
			SET @ErrorCount = @ErrorCount + 1
			PRINT CONVERT(varchar(30), GETDATE(), 109) + ' *** ERROR UNABLE TO CONNECT TO SQL'			
		END
	ELSE
		BEGIN		
			SET @Cmd = 'sqlcmd -S ' + @Connection + ' -d master -E -b -i "' + 
					   @Script + '" -h -1 -l 30 -t 300 -W >> "' + @OutputTo  + '"'

			EXECUTE @ReturnValue = xp_cmdshell @Cmd, NO_OUTPUT					

			IF @ReturnValue <> 0
				BEGIN
					SET @ErrorCount = @ErrorCount + 1
					PRINT CONVERT(varchar(30), GETDATE(), 109) + ' *** ERROR RUNNING SCRIPT'			
				END
			ELSE
				BEGIN
					SET @SuccessCount = @SuccessCount + 1

					PRINT CONVERT(varchar(30), GETDATE(), 109) + ' FINISH GRABBING INFO FROM SQL SERVER ' + @SQLServer
				END
		END
		
	PRINT CONVERT(varchar(30), GETDATE(), 109) 
	
	FETCH FROM CUSROR_SERVERS
	INTO @SQLServer, @Connection	
END

CLOSE CUSROR_SERVERS
DEALLOCATE CUSROR_SERVERS

SET @Total = CAST(@SuccessCount AS int) + CAST(@ErrorCount AS int)
SET @Length = LEN(CAST(@Total AS varchar(15)))

PRINT ''
PRINT 'SUCCESSFUL:   ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@SuccessCount)) + @SuccessCount
PRINT 'ERROR COUNT:  ' + REPLICATE('0', 5) + REPLICATE('0', @Length - LEN(@ErrorCount)) + @ErrorCount
PRINT '              ' + REPLICATE('-', @Length + 5)
PRINT 'TOTAL:        ' + REPLICATE('0', 5) + CAST(@Total AS varchar(15))


CREATE TABLE #tbl_schema 
(
	Instance_Nm		sysname
	,Database_Nm	sysname
	,Table_Nm		sysname
	,Column_Nm		sysname
	,Data_Type		sysname
	,Length			smallint
	,Prec			smallint
	,Scale			int
	,IsComputed		bit
	,IsNullable		bit
)


SET @Cmd = 'BULK INSERT #tbl_schema '
SET @Cmd = @Cmd + 
		   'FROM "' + @OutputTo + '" '
SET @Cmd = @Cmd + 
		   '   WITH '           
SET @Cmd = @Cmd + 
		   '   ( '
SET @Cmd = @Cmd + 
		   '       BATCHSIZE = 5000 '                      
SET @Cmd = @Cmd + 
		   '       ,FIRSTROW = 2 '
SET @Cmd = @Cmd + 
		   '   ) '

EXECUTE (@Cmd)

SELECT * FROM #tbl_schema                                     

DROP TABLE #ServerInfo
DROP TABLE #tbl_schema
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    