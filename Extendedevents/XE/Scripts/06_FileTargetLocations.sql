/* SQL 2012 System Health File Target Locations*/
:CONNECT jason_hplaptop2\sql2k12
SELECT module_guid,package_guid,object_name,file_name,file_offset, CAST(event_data AS XML) AS 'event_data_XML'
FROM sys.fn_xe_file_target_read_file('system_health_*.xel'
										, NULL, NULL, NULL)
GO

SELECT module_guid,package_guid,object_name,file_name,file_offset, CAST(event_data AS XML) AS 'event_data_XML'
 FROM sys.fn_xe_file_target_read_file('C:\Database\SQL2K12\MSSQL11.SQL2K12\MSSQL\Log\system_health_*.xel'
										,NULL,NULL,NULL)
GO
/* SQL 2008 Requires that the metadata (xem) file path be declared */
:CONNECT jason_hplaptop2\admin
SELECT module_guid,package_guid,object_name,file_name,file_offset, CAST(event_data AS XML) AS 'event_data_XML' 
 FROM sys.fn_xe_file_target_read_file('C:\Admin\Presentations\XE\PageComp*.xel'
										,'C:\Admin\Presentations\XE\PageComp*.xem'
										,NULL,NULL)
GO

/* Now Try SQL 2008 without Metadata file declared*/
SELECT module_guid,package_guid,object_name,file_name,file_offset, CAST(event_data AS XML) AS 'event_data_XML'
FROM sys.fn_xe_file_target_read_file('system_health_*.xel'
										, NULL, NULL, NULL)
GO