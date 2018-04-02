if object_id('dba.ReplStatusHistory') is null
create table dba.replStatusHistory (
 replStatusId bigint identity primary key
 , replStatusTime datetime default (getdate()) not null
 , distributionDb sysname not null
 , publishingServer sysname not null
 , publishingDb sysname not null
 , subscribingServer sysname not null
 , subscribingDb sysname not null
 , subscriptionStatusId tinyint not null
 , PendingCmdCount bigint not null
 , exception bit default 0
 , publicationName sysname not null
)

--Usage sample:
--exec [dba].[monitorReplStatus] @testMode=1, @distributionDb='distribution', @sendEmail=2

CREATE PROCEDURE [dba].[monitorReplStatus]
 @nocEmailThreshold int = 100000
 , @testMode bit =0
 , @distributionDb sysname
 , @testModeEmailAddress nvarchar(1000) = 'some@body.com'
 , @sendEmail tinyint = 2 -- 0= don't mail, 1= always mail, 2=email only on error
 , @exceptionXML xml = N'
&lt;EXCEPTION&gt;
 &lt;Exclude serverName=&quot;SOMESERVER&quot; /&gt;
 &lt;Exclude serverName=&quot;SOMEOTHERSERVER&quot; /&gt;
 &lt;/EXCEPTION&gt;
'
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

declare @html nvarchar(max)
 , @emailRecipients nvarchar(2000)
 , @subj nvarchar(2000)
 , @replStatusTime datetime
 , @loggingWarning nvarchar(max)
 , @sqlGetSubscribers nvarchar(max)
 , @raiseErr bit
 , @i tinyint --iterator for loop
 , @publishingServer sysname
 , @publishingDb sysname
 , @publicationName sysname
 , @subscriptionType tinyint
 , @subscribingServer sysname
 , @subscribingDb sysname
 , @getStatsSql nvarchar(max)

set @replStatusTime=getdate();

declare @replSubscribers table (
 replSubscriberId int identity primary key
 , publishingServer sysname not null
 , publishingDb sysname not null
 , publicationName sysname not null
 , subscriptionType tinyint default (1)
 , subscribingServer sysname not null
 , subscribingDb sysname not null
 , subscriptionStatusId tinyint not null
 , subscriptionStatus nvarchar(256) not null
 , exception bit default(0)
 , pendingCmdCount bigInt null
 , estimatedProcessSeconds bigInt null
)

declare @replStatus table (
 replSubscriberId int primary key
 , pendingCmdCount bigInt
 , estimatedProcessSeconds bigInt
)

declare @exceptions table (
 serverName sysname not null
)

set @subj='Replication Status from ' + @@SERVERNAME + '.' + @distributionDb;
set @loggingWarning='' -- can't be null or it won't work later
set @raiseErr=0 -- should not be null

--First, parse exclusions
insert @exceptions (serverName)
SELECT DISTINCT
 serverName = x.serverName
FROM
 (
 SELECT DISTINCT
 serverName = e.i.value('@serverName','sysname')
 FROM @exceptionXML.nodes('EXCEPTION/Exclude') e(i)
 where e.i.value('@serverName','sysname')  is not null
 ) x

--Now, get our list of subscribers for this distribution db
select @sqlGetSubscribers='
use ' + @distributionDb + ';
select
 publishingServer = pub.srvname
 , publishingDb = coalesce(sb.publisher_db,''????'')
 , publicationName = pb.publication
 , subscriptionType= sb.subscription_type
 , subscribingServer = sub.srvname
 , subscribingDb= coalesce(sb.subscriber_db,''????'')
 , subscriptionStatusId=coalesce(sb.status,-1)
 , subscriptionStatus= case sb.status when 0 then ''Inactive'' when 1 then ''Subscribed'' when 2 then ''Active'' else ''???'' end
from MSSubscriptions sb (nolock)
join MSPublications pb (nolock) on
 sb.publication_id=pb.publication_id
join master.dbo.sysservers sub (nolock) on
 sb.subscriber_id= sub.srvid
join master.dbo.sysservers pub (nolock) on
 sb.publisher_id= pub.srvid
group by
 pub.srvname
 , sb.publisher_db
 , pb.publication
 , sb.subscription_type
 , sub.srvname
 , sb.subscriber_db
 , sb.status
'
if @testMode=1 print @sqlGetSubscribers

begin try
 insert @replSubscribers (publishingServer, publishingDb, publicationName, subscriptionType, subscribingServer, subscribingDb, subscriptionStatusId, subscriptionStatus)
 exec sp_executesql @sqlGetSubscribers

 if @@rowcount =0
 begin
 set @loggingWarning=@loggingWarning + 'No subscribers found.'
 set @raiseErr=1
 end
 else
 update @replSubscribers
 set exception =1
 from @replSubscribers  rs
 join @exceptions x on
 rs.subscribingServer=x.serverName

end try
begin catch
 set @loggingWarning=@loggingWarning + 'Could not pull subscriber list.'
 set @raiseErr=1
end catch

set @i=1;

--Now get the undelivered commands for each subscriber

while @raiseErr != 1 and @i = @nocEmailThreshold and exception =0) &gt;= 1
begin
 set @sendEmail=1
end

--Fix up the email and send it
if @sendEmail=1
begin

 SELECT @html=
 '

 BODY  {background-color:floralwhite; font-family: sans-serif}
 TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
 TH    {border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:#f0f0f0; text-align: center; padding: 8px;}
 TD    {border-width: 1px;padding: 2px;border-style: solid;border-color: black; background-color:#f9f9f9; text-align: center; padding: 8px;}

 &lt;H1&gt;PROD Replication Undelivered Commands&lt;/H1&gt;'
 + case when @loggingWarning is not null then '&lt;H3&gt;&lt;font color=&quot;red&quot;&gt;' + @loggingWarning + '&lt;/font&gt;&lt;/H3&gt;' else '' end
 + '
Replication status from ' + @@SERVERNAME + '.' + @distributionDb
 + ' is summarized below. Please ticket and escalate any instances of undelivered commands for production servers over &lt;font color=&quot;red&quot;&gt;'
 + cast(@nocEmailThreshold  as nvarchar) + '&lt;/font&gt; as as per the &lt;a href=&quot;http://yourTSG/OrOpsGuide/'+ @@SERVERNAME + '&quot;&gt;'+ @@SERVERNAME +' wiki&lt;/a&gt;.

&lt;H2&gt;Production Servers&lt;/H2&gt;
 '
 --Build the upper table to display production data

 SELECT
 @html=@html + '
 &lt;TABLE&gt;
 &lt;TR&gt;
 &lt;TH&gt;
 publishing server
 &lt;/TH&gt;&lt;TH&gt;
 publishing db
 &lt;/TH&gt;&lt;TH&gt;
 subscribing server
 &lt;/TH&gt;&lt;TH&gt;
 subscribing db
 &lt;/TH&gt;&lt;TH&gt;
 publication name
 &lt;/TH&gt;&lt;TH&gt;
 subscription status
 &lt;/TH&gt;&lt;TH&gt;
 undelivered commands
 &lt;/TH&gt;
 &lt;/TR&gt;
 ';

 SELECT
 @html=@html +
 '&lt;TR&gt;
 &lt;TD&gt;' + publishingServer
 + '&lt;/TD&gt;
 &lt;TD&gt;'+
 publishingDb
 + '&lt;/TD&gt;
 &lt;TD&gt;'+
 subscribingServer
 + '&lt;/TD&gt;
 &lt;TD&gt;'+
 subscribingDb
 + '&lt;/TD&gt;
 &lt;TD&gt;'+
 publicationName
 + '&lt;/TD&gt;
 &lt;TD&gt;'+
 subscriptionStatus
 + '&lt;/TD&gt;
 &lt;TD&gt;'
 + case when coalesce(PendingCmdCount,-1) &gt;= @nocEmailThreshold then '&lt;font color=&quot;red&quot;&gt;' else '' end
 + cast (coalesce(PendingCmdCount,-1) as nvarchar(256))
 + case when (coalesce(PendingCmdCount,-1) &gt;= @nocEmailThreshold ) then '&lt;/font&gt;' else '' end
 + '&lt;/TD&gt;
 &lt;/TR&gt;
 '
 from @replSubscribers sub
 where exception = 0
 order by
 publishingServer
 , publishingDb
 , subscribingServer
 , subscribingDb

 SELECT @html=@html +
 '&lt;/TABLE&gt;'

 --Build the lower table to display exceptions (which are just an FYI)
 SELECT
 @html=@html + '
&lt;H2&gt;Non-Production Servers (informational only, do not ticket)&lt;/H2&gt;
'

 SELECT
 @html=@html + '
 &lt;TABLE&gt;
 &lt;TR&gt;
 &lt;TH&gt;
 publishing server
 &lt;/TH&gt;&lt;TH&gt;
 publishing db
 &lt;/TH&gt;&lt;TH&gt;
 subscribing server
 &lt;/TH&gt;&lt;TH&gt;
 subscribing db
 &lt;/TH&gt;&lt;TH&gt;
 publication name
 &lt;/TH&gt;&lt;TH&gt;
 subscription status
 &lt;/TH&gt;&lt;TH&gt;
 undelivered commands
 &lt;/TH&gt;
 &lt;/TR&gt;
 ';

 SELECT
 @html=@html +
 '&lt;TR&gt;
 &lt;TD&gt;' + publishingServer
 + '&lt;/TD&gt;
 &lt;TD&gt;'+
 publishingDb
 + '&lt;/TD&gt;
 &lt;TD&gt;'+
 subscribingServer
 + '&lt;/TD&gt;
 &lt;TD&gt;'+
 subscribingDb
 + '&lt;/TD&gt;
 &lt;TD&gt;'+
 publicationName
 + '&lt;/TD&gt;
 &lt;TD&gt;'+
 subscriptionStatus
 + '&lt;/TD&gt;
 &lt;TD&gt;'
 -- don't color these red, they have exceptions....
 + cast (coalesce(PendingCmdCount,-1) as nvarchar(256))
 + '&lt;/TD&gt;
 &lt;/TR&gt;
 '
 from @replSubscribers sub
 where exception = 1
 order by
 publishingServer
 , publishingDb
 , subscribingServer
 , subscribingDb

 SELECT @html=@html +
 '&lt;/TABLE&gt;'

 --Build the foooter
 SELECT
 @html=@html + '
'

 if @testMode=1
 begin
 select * from @exceptions
 select * from @replSubscribers sub

 select
 @emailRecipients = @testModeEmailAddress

 end
 else
 select
 @emailRecipients= 'some@body.com' + case when count(*) &gt; 0 then ';some@body.com' else '' end
 from @replSubscribers sub
 where PendingCmdCount &gt;= @nocEmailThreshold
 and exception =0

 exec msdb..sp_send_dbmail
 @profile_name=@@SERVERNAME
 , @recipients = @emailRecipients
 , @subject= @subj
 , @body_format = 'HTML'
 , @body=@html
 ;

end

--Clean up history
delete from dba.ReplStatusHistory
where replStatusTime = @nocEmailThreshold and exception =0) &gt;= 1
begin
 set @raiseErr=1
 set @loggingWarning=@loggingWarning+ 'Error threshold exceeded for one or more subscriptions, please investigate.'
end

--Finish up and raise an error if we need to
if @raiseErr=1
begin
 print 'Logging warning: ' + @loggingWarning
 RAISERROR(@loggingWarning,16,1)
end
