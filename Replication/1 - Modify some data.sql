--check tables on the subscriber
use Subscriber
go

select * from dbo.A
select * from dbo.C

use Publisher
go

--Let's insert more data
insert dbo.A (Name) 
select distinct top 5 name 
from master..spt_values
go

delete top (3) A
from dbo.A A
where A.ID not in (select AID from dbo.B)

go

update c 
set Value = 100
where ID = 2

go

--run this statement and check replicated commands
--it will send to subscriber by separate commands
set xact_abort on
begin tran

	insert C (Value) values (111)
	insert C (Value) values (222)
	insert C (Value) values (333)

commit

select * from Publisher.dbo.A
select * from Subscriber.dbo.A

select * from Publisher.dbo.C
select * from Subscriber.dbo.C
