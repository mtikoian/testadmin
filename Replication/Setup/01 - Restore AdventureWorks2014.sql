use master;
go

--restore filelistonly from disk = 'C:\System00\Backup\AdventureWorks2014.bak' 


if  exists (select name from sys.databases where name = 'AdventureWorks2014')
begin
    alter database AdventureWorks2014 set  single_user with rollback immediate;

    drop database AdventureWorks2014;
end
go

if  exists (select name from sys.databases where name = 'AdventureWorks2014Replica')
begin
    alter database AdventureWorks2014Replica set  single_user with rollback immediate;

    drop database AdventureWorks2014Replica;
end
go

restore database AdventureWorks2014
    from disk = 'C:\System00\Backup\AdventureWorks2014.bak' 
    with move 'AdventureWorks2014_Data' to 'c:\Data00\Data\AdventureWorks2014_Data.mdf',
         move 'AdventureWorks2014_Log' to 'c:\Log00\TransactionLog\AdventureWorks2014_Log.ldf';
go         
         
use AdventureWorks2014;
go

sp_changedbowner 'sa';                           -- Very important in replication.  Make sure the DB owner is sa.
go                                               -- http://social.msdn.microsoft.com/Forums/en-US/sqlreplication/thread/b662bab0-ece9-452c-9089-e67b6801b7ff

     
         