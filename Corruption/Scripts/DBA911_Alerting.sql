/*******************************************************************************

DBA 911: Database Corruption
SQL Saturday, Columbus Ohio
David M Maxwell, SQL DBA
June, 2013

This is a simple script for setting up alerts for corruption errors on the 
server of your choice. I hope you find it helpful. Note that many of these 
commands below are simplified, taking many of the defaults. You will want to 
check out Books Online for further information on sp_add_operator, sp_add_alert
and sp_add_notification. 

*******************************************************************************/
/* Operators and alerts reside in MSDB. */
USE [msdb]
GO

/* Here, set the operator name, and email address, that you would like to use. */
DECLARE @OperatorName nvarchar(128) = 'DBA';
DECLARE @OperatorEmail nvarchar(128) = 'DBA@internal.company.com';

/* The following command creates the operator. */

EXEC msdb.dbo.sp_add_operator @name=@OperatorName, 
		@enabled=1, 
		@email_address=@OperatorEmail
;

/* Now that we have someone to receive alerts, let's create some. */

/* The first alert is for an 823 error, which indicates that SQL Server was
   unable to read a data page from disk. 
*/

EXEC msdb.dbo.sp_add_alert @name=N'823 - IO Read Failure', 
		@message_id=823, 
		@enabled=1, 
		@include_event_description_in=1
;

EXEC msdb.dbo.sp_add_notification 
	@alert_name=N'823 - IO Read Failure', 
	@operator_name=@OperatorName, 
	@notification_method = 1
;

/* The next alert is for an 824 error, which indicates that SQL Server 
   read the page from disk, but the checksum calculated did not match
   the stored page checksum, so something changed on the page since the 
   last time SQL Server update the page checksum. This only works if you
   have the PAGE_VERIFICATION option of the database set to CHECKSUM.
*/

EXEC msdb.dbo.sp_add_alert @name=N'824 - IO Checksum Failure', 
		@message_id=824, 
		@enabled=1, 
		@include_event_description_in=1
;

EXEC msdb.dbo.sp_add_notification 
	@alert_name=N'824 - IO Checksum Failure', 
	@operator_name=@OperatorName, 
	@notification_method = 1
;


/* The next alert is for an 825 error, which indicates that SQL Server 
   read the page from disk, but it took multiple tries to do so. You 
   will want to check for disk subsystem issues in this case. Even though
   the read succeeded, the disks are beginning to fail.
*/

EXEC msdb.dbo.sp_add_alert @name=N'825 - Read Retry Error', 
		@message_id=825, 
		@severity=0, 
		@enabled=1, 
		@include_event_description_in=1
;

EXEC msdb.dbo.sp_add_notification 
	@alert_name=N'825 - Read Retry Error', 
	@operator_name=@OperatorName, 
	@notification_method = 1
;

/* Finally, there's error 832. This indicates that some process outside 
   of SQL Server changed the page while it was still in the buffer pool.
   This is an in-memory corruption, rather than on-disk, and is very 
   nasty. You should have the server's memory checked for errors as soon
   as possible. 
*/

EXEC msdb.dbo.sp_add_alert @name=N'832 - In-Memory Checksum Failure', 
		@message_id=832, 
		@enabled=1, 
		@include_event_description_in=1
;

EXEC msdb.dbo.sp_add_notification 
	@alert_name=N'832 - In-Memory Checksum Failure', 
	@operator_name=@OperatorName, 
	@notification_method = 1
;

GO

