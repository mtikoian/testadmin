--go to Subscriber
use Subscriber
go

--Try to insert value on Subscriber
insert dbo.A (Name) values ('bla bla bla')
go
	 
set identity_insert dbo.A on

insert dbo.A (ID, Name) values (21, 'bla bla bla')

set identity_insert dbo.A off
go
select * from dbo.A

--go to Publisher
use Publisher
go

insert dbo.A (Name) values ('yo-ho-ho')

select * from dbo.A

update a set Name = 'asdasdasd' where ID = 11
--Look at subscription status


--go to Subscriber
--here we can delete extra row OR reinitilize subscriiption
use Subscriber
go
delete dbo.A where ID = 21

go
select * from dbo.A

 