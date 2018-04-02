if not exists 
(select 1 from sys.databases where name = 'Publisher') 
    create database Publisher
go

if not exists 
(select 1 from sys.databases where name = 'Subscriber') 
    create database Subscriber
go

use Publisher
go

--Create tables for publication
create table dbo.A (
		ID int not null identity primary key, 
		Name varchar(100), 
		Moment datetime default getdate(),
		ServerName sysname default @@servername,
		Creator sysname default suser_sname()
		)

go

--!!! Table dbo.B without PK constraint !!!
create table dbo.B (
	ID int not null,
	AID int not null references dbo.A(ID),
	Descript varchar(1000),
	Moment datetime default getdate(),
	ServerName sysname default @@servername,
	Creator sysname default suser_sname()
)
go

create table dbo.C (
		ID int not null identity primary key, 
		Value money,
		Moment datetime default getdate(),
		ServerName sysname default @@servername,
		Creator sysname default suser_sname()
)

go


--insert some data
insert dbo.A(Name) 
select top 5 name 
from master..spt_values
where name is not null
order by newid()

go 

insert dbo.B(ID, AID, Descript) 
select top 5 number, (select top 1 ID from dbo.A order by newid()), name
from master..spt_values
where name is not null
order by newid()
go

insert dbo.C (Value) values (1), (2), (3)
go

select * from dbo.A
select * from dbo.B
select * from dbo.C

use master

--Create publication and subscriber