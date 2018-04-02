use master;
go


if  exists (select name from sys.databases where name = 'AdventureWorks2014Replica')
begin
    alter database AdventureWorks2014Replica set  single_user with rollback immediate;

    drop database AdventureWorks2014Replica;
end
go


-- restore filelistonly from disk = 'c:\System00\backup\AdventureWorks2014Replica.bak';

restore database AdventureWorks2014Replica
    from disk = 'c:\System00\backup\AdventureWorks2014Replica.bak'
    with
        move 'AdventureWorks2014_Data' to 'c:\data00\data\AdventureWorks2012Replica_Data.mdf',
        move 'Trans2011Q2' to 'c:\data00\data\TransReplica2011Q2.ndf',
        move 'Trans2011Q3' to 'c:\data00\data\TransReplica2011Q3.ndf',
        move 'Trans2011Q4' to 'c:\data00\data\TransReplica2011Q4.ndf',
        move 'Trans2012Q1' to 'c:\data00\data\TransReplica2012Q1.ndf',
        move 'Trans2012Q2' to 'c:\data00\data\TransReplica2012Q2.ndf',
        move 'Trans2012Q3' to 'c:\data00\data\TransReplica2012Q3.ndf',
        move 'Trans2012Q4' to 'c:\data00\data\TransReplica2012Q4.ndf',
        move 'Trans2013Q1' to 'c:\data00\data\TransReplica2013Q1.ndf',
        move 'Trans2013Q2' to 'c:\data00\data\TransReplica2013Q2.ndf',
        move 'Trans2013Q3' to 'c:\data00\data\TransReplica2013Q3.ndf',
        move 'Trans2013Q4' to 'c:\data00\data\TransReplica2013Q4.ndf',
        move 'Trans2014Q1' to 'c:\data00\data\TransReplica2014Q1.ndf',
        move 'Trans2014Q2' to 'c:\data00\data\TransReplica2014Q2.ndf',
        move 'TransFuture' to 'c:\data00\data\TransReplicaFuture.ndf',
        move 'AdventureWorks2014_Log' to 'c:\log00\TransactionLog\AdventureWorks2014Replica_Log.ldf',
        checksum;
go

use AdventureWorks2014Replica;
go

sp_changedbowner 'sa';                           -- Very important in replication.  Make sure the DB owner is sa.
go                                               -- http://social.msdn.microsoft.com/Forums/en-US/sqlreplication/thread/b662bab0-ece9-452c-9089-e67b6801b7ff


sp_MSforeachtable @command1="alter table ? disable trigger all";  -- http://blogs.msdn.com/b/repltalk/archive/2010/12/06/how-to-initialize-a-transactional-subscription-from-a-backup-with-multiple-backup-files.aspx
go

   
         