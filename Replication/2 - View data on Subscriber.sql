--on Subscriber
use Subscriber 
go
select * from dbo.A
go 
select * from dbo.C 

--Check identity value in table A
DBCC Checkident ('dbo.A')

