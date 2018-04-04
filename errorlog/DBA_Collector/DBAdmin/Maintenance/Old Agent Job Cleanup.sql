IF (@@SERVERNAME NOT LIKE 'EDEVSQL2K8R2-02%' AND @@SERVERNAME NOT LIKE 'SEIEDEVUTILDB01' AND @@SERVERNAME NOT LIKE 'SEINETIKQADB02') BEGIN

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'EDEV DBA Daily Maintenance Job')
	EXEC msdb.dbo.sp_delete_job @job_name = 'EDEV DBA Daily Maintenance Job';
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'EDEV DBA Weekend Maintenance Job')
	EXEC msdb.dbo.sp_delete_job @job_name = 'EDEV DBA Weekend Maintenance Job';	
IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = 'EDEV DBA Log Backup Job')
	EXEC msdb.dbo.sp_delete_job @job_name = 'EDEV DBA Log Backup Job';	

END