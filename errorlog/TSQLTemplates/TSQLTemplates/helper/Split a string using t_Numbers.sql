


declare	@x	varchar(100)

set @x = 'Steve McLarnon'

select	n.Number as Pos,
		substring(@x, n.Number, 1) as StrChar 
from dbo.t_Numbers n
where n.Number <= datalength(@x)

