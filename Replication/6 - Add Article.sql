--Connect to Publisher
use Publisher
go

create table YetAnotherTable (
	ID int not null primary key identity(1,1),
	Value varchar(1000),
	Moment datetime not null default getdate()

)
go

insert YetAnotherTable (Value) 
select name 
from sys.objects
go

--Add table roo Publication

--try to add column - it's ok. Look at subscriber
alter table YetAnotherTable add SomeColumn int null
go

--try to rename columns - error
exec sp_rename 'dbo.YetAnotherTable.SomeColumn', 'BlaBlaBla', 'COLUMN'
go

--try to rename columns - error
alter table YetAnotherTable drop column SomeColumn 
go


--Try to drop table - error
drop table YetAnotherTable