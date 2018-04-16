/*
	Tom Sawyer
	We do not use SQL mail on our SQL servers.  So, we developed this trigger on sysjobhistory
	to notify us of job failures.
	We use xp_smtp_sendmail which is available free from http://www.sqldev.net/xp/xpsmtp.htm
*/
use msdb
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
if exists (select * from sysobjects where name = 'checkForJobFail')
	drop TRIGGER [checkForJobFail]
go
CREATE TRIGGER [checkForJobFail] ON [dbo].[sysjobhistory] 
FOR INSERT
AS
declare @msg varchar(2048), @maillist varchar(256), @mailfrom varchar(256), @jobName sysname, @subject varchar(256), @failStepID int
if (select step_id from inserted) <> 0
	return
else
begin
	select @jobName = name
		from inserted i join sysjobs j on i.job_id = j.job_id
	if (select run_status from inserted) = 0  	--the job failed
	begin
		select @msg = message from inserted
	end
	else
	if (exists (select h.instance_id
		from inserted i join sysjobhistory h on i.job_id = h.job_id
		where i.run_date <= h.run_date
		  and i.run_time <= h.run_time
		  and h.run_status = 0
		  and h.step_id > 0))	--any step in the job failed
	begin
		select @failStepID = min(h.instance_id)
			from inserted i join sysjobhistory h on i.job_id = h.job_id
			where i.run_date <= h.run_date
			  and i.run_time <= h.run_time
			  and h.run_status = 0
			  and h.step_id > 0
		select @msg = 'Step ' + cast(h.step_id as varchar(3)) + ' failed 
		' +h.message from inserted i 
			join sysjobhistory h on i.job_id = h.job_id 
			where h.instance_id = @failStepID
	end
	else return -- the job didn't fail and no steps failed

	DECLARE	@DetailDomainName	varchar(128)

	SET @DetailDomainName = NULL

	EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE'
		,'SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
		,'Domain'
		,@DetailDomainName OUTPUT

	select @maillist = 'DL-WDBS-SQL-DBA@anthem.com'
	select @mailfrom = 'DBAlert@' + replace(@@servername, '\', '_') + @DetailDomainName
	
	select @subject = 'Job ''' + @jobName + ''' failed on ' + @@servername + '.' + @DetailDomainName	
	exec master.dbo.xp_smtp_sendmail
	 

end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
